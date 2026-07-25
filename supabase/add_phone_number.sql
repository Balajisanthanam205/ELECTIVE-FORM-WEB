-- ============================================================
--  PATCH: Add phone_number field to existing registrations table
--  Run this in Supabase SQL Editor on your LIVE database
-- ============================================================

-- Step 1: Add phone_number column (nullable first for existing rows)
ALTER TABLE public.registrations
  ADD COLUMN IF NOT EXISTS phone_number TEXT;

-- Step 2: (Optional) Set a placeholder for any existing rows
UPDATE public.registrations
  SET phone_number = 'N/A'
  WHERE phone_number IS NULL;

-- Step 3: Make it NOT NULL going forward
ALTER TABLE public.registrations
  ALTER COLUMN phone_number SET NOT NULL;

-- Step 4: Replace the register_student function with the new signature
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

  -- Lock the subject row for update
  SELECT * INTO v_subject
  FROM public.subjects
  WHERE id = p_subject_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'subject_not_found',
      'message', 'Selected subject does not exist.'
    );
  END IF;

  IF v_subject.filled_seats >= v_subject.max_seats THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'subject_full',
      'message', 'Selected subject is already full.'
    );
  END IF;

  -- Insert registration with phone_number
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
    IF SQLERRM LIKE '%roll_number%' THEN
      RETURN jsonb_build_object('success', false, 'code', 'duplicate_roll', 'message', 'This roll number has already registered.');
    ELSIF SQLERRM LIKE '%college_email%' THEN
      RETURN jsonb_build_object('success', false, 'code', 'duplicate_email', 'message', 'This college email has already registered.');
    ELSE
      RETURN jsonb_build_object('success', false, 'code', 'duplicate', 'message', 'Duplicate registration detected.');
    END IF;
  WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'code', 'error', 'message', SQLERRM);
END;
$$;

-- Step 5: Grant execute on the NEW function signature
GRANT EXECUTE ON FUNCTION public.register_student(TEXT, TEXT, TEXT, TEXT, TEXT, UUID)
  TO anon, authenticated;

-- Verification
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'registrations' AND column_name = 'phone_number';
