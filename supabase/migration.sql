-- ============================================================
--  Elective Course Registration Portal — Supabase SQL Schema
--  Run this entire script in Supabase SQL Editor
-- ============================================================

-- ─── 1. SUBJECTS TABLE ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.subjects (
  id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_code  TEXT          NOT NULL UNIQUE,
  subject_name  TEXT          NOT NULL,
  max_seats     INTEGER       NOT NULL DEFAULT 48 CHECK (max_seats > 0),
  filled_seats  INTEGER       NOT NULL DEFAULT 0 CHECK (filled_seats >= 0),
  status        TEXT          NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'full')),
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT filled_not_exceed_max CHECK (filled_seats <= max_seats)
);

-- Index for fast status lookups
CREATE INDEX IF NOT EXISTS idx_subjects_status ON public.subjects(status);

-- ─── 2. REGISTRATIONS TABLE ───────────────────────────────────

CREATE TABLE IF NOT EXISTS public.registrations (
  id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  student_name   TEXT          NOT NULL,
  roll_number    TEXT          NOT NULL UNIQUE,
  phone_number   TEXT          NOT NULL,
  section        TEXT          NOT NULL,
  college_email  TEXT          NOT NULL UNIQUE,
  subject_id     UUID          NOT NULL REFERENCES public.subjects(id) ON DELETE RESTRICT,
  registered_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Indexes for fast uniqueness checks
CREATE INDEX IF NOT EXISTS idx_registrations_roll     ON public.registrations(roll_number);
CREATE INDEX IF NOT EXISTS idx_registrations_email    ON public.registrations(college_email);
CREATE INDEX IF NOT EXISTS idx_registrations_subject  ON public.registrations(subject_id);

-- ─── 3. SEED SUBJECTS DATA ────────────────────────────────────

INSERT INTO public.subjects (subject_code, subject_name, max_seats, filled_seats, status)
VALUES
  ('VD22704', 'Embedded System Simulation',                               48, 0, 'open'),
  ('VD22702', 'Artificial Neural Networks',                               48, 0, 'open'),
  ('VD22712', 'Standards for Electronics and Communication Engineers',    48, 0, 'open'),
  ('VD22705', 'Hardware Modeling and Analysis using EDA Tool',            48, 0, 'open')
ON CONFLICT (subject_code) DO NOTHING;

-- ─── 4. ATOMIC REGISTRATION FUNCTION ─────────────────────────
--
--  This function runs entirely inside a single SERIALIZABLE transaction.
--  It uses SELECT FOR UPDATE to lock the subject row, preventing any
--  race condition where two students grab the last seat simultaneously.
--
--  Returns JSON: { success: bool, code: text, message: text }

CREATE OR REPLACE FUNCTION public.register_student(
  p_student_name  TEXT,
  p_roll_number   TEXT,
  p_phone_number  TEXT,
  p_section       TEXT,
  p_college_email TEXT,
  p_subject_id    UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subject       public.subjects%ROWTYPE;
  v_roll_exists   BOOLEAN;
  v_email_exists  BOOLEAN;
BEGIN

  -- Check duplicate roll number
  SELECT EXISTS (
    SELECT 1 FROM public.registrations
    WHERE roll_number = UPPER(TRIM(p_roll_number))
  ) INTO v_roll_exists;

  IF v_roll_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'duplicate_roll',
      'message', 'This roll number has already registered.'
    );
  END IF;

  -- Check duplicate email
  SELECT EXISTS (
    SELECT 1 FROM public.registrations
    WHERE college_email = LOWER(TRIM(p_college_email))
  ) INTO v_email_exists;

  IF v_email_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'duplicate_email',
      'message', 'This college email has already registered.'
    );
  END IF;

  -- Lock the subject row for update (prevents concurrent overbooking)
  SELECT * INTO v_subject
  FROM public.subjects
  WHERE id = p_subject_id
  FOR UPDATE;

  -- Subject not found
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'subject_not_found',
      'message', 'Selected subject does not exist.'
    );
  END IF;

  -- Check if subject is full
  IF v_subject.filled_seats >= v_subject.max_seats THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'subject_full',
      'message', 'Selected subject is already full.'
    );
  END IF;

  -- Insert registration
  INSERT INTO public.registrations (
    student_name,
    roll_number,
    phone_number,
    section,
    college_email,
    subject_id
  ) VALUES (
    TRIM(p_student_name),
    UPPER(TRIM(p_roll_number)),
    TRIM(p_phone_number),
    TRIM(p_section),
    LOWER(TRIM(p_college_email)),
    p_subject_id
  );

  -- Increment filled_seats atomically
  UPDATE public.subjects
  SET
    filled_seats = filled_seats + 1,
    status = CASE WHEN filled_seats + 1 >= max_seats THEN 'full' ELSE 'open' END
  WHERE id = p_subject_id;

  RETURN jsonb_build_object(
    'success', true,
    'code',    'registered',
    'message', 'Registration Successful.'
  );

EXCEPTION
  WHEN unique_violation THEN
    -- Handle any edge-case concurrent unique constraint violation
    IF SQLERRM LIKE '%roll_number%' THEN
      RETURN jsonb_build_object(
        'success', false,
        'code',    'duplicate_roll',
        'message', 'This roll number has already registered.'
      );
    ELSIF SQLERRM LIKE '%college_email%' THEN
      RETURN jsonb_build_object(
        'success', false,
        'code',    'duplicate_email',
        'message', 'This college email has already registered.'
      );
    ELSE
      RETURN jsonb_build_object(
        'success', false,
        'code',    'duplicate',
        'message', 'Duplicate registration detected.'
      );
    END IF;
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'error',
      'message', SQLERRM
    );
END;
$$;

-- ─── 5. ROW LEVEL SECURITY ────────────────────────────────────

-- Enable RLS on both tables
ALTER TABLE public.subjects      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

-- Allow anyone to READ subjects (for seat availability display)
DROP POLICY IF EXISTS "public_read_subjects" ON public.subjects;
CREATE POLICY "public_read_subjects"
  ON public.subjects FOR SELECT
  TO anon, authenticated
  USING (true);

-- Block all direct inserts/updates to subjects from client (use RPC only)
DROP POLICY IF EXISTS "no_direct_subject_write" ON public.subjects;
CREATE POLICY "no_direct_subject_write"
  ON public.subjects FOR INSERT
  TO anon, authenticated
  WITH CHECK (false);

-- Block all direct reads/writes to registrations from client
-- (all registration operations go through the secure RPC function)
DROP POLICY IF EXISTS "no_direct_registration_read" ON public.registrations;
CREATE POLICY "no_direct_registration_read"
  ON public.registrations FOR SELECT
  TO anon
  USING (false);

DROP POLICY IF EXISTS "no_direct_registration_write" ON public.registrations;
CREATE POLICY "no_direct_registration_write"
  ON public.registrations FOR INSERT
  TO anon
  WITH CHECK (false);

-- Allow service role (used by our API) to bypass RLS
-- (SECURITY DEFINER on the function handles this automatically)

-- ─── 6. GRANT EXECUTE ON RPC FUNCTION ────────────────────────

-- Allow the anon role to call the registration function
-- The SECURITY DEFINER means it executes with owner privileges
GRANT EXECUTE ON FUNCTION public.register_student(TEXT, TEXT, TEXT, TEXT, TEXT, UUID)
  TO anon, authenticated;

-- ─── END OF MIGRATION ─────────────────────────────────────────
--
--  VERIFICATION QUERIES (run separately to check):
--
--  SELECT * FROM public.subjects;
--  SELECT COUNT(*) FROM public.registrations;
--  SELECT s.subject_code, s.subject_name, s.filled_seats, s.max_seats
--    FROM public.subjects s ORDER BY s.subject_code;
