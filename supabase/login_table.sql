-- ============================================================
--  VAC Portal — Login System + Student Seed Data
--  Run this ENTIRE script in Supabase SQL Editor
--  Portal opens: 2026-07-25 14:10:00 IST (2:10 PM)
-- ============================================================

-- ─── 1. DROP OLD OBJECTS (safe re-run) ────────────────────────
DROP FUNCTION IF EXISTS public.student_login(TEXT);
DROP FUNCTION IF EXISTS public.verify_session_token(TEXT);
DROP FUNCTION IF EXISTS public.student_logout(TEXT);
DROP TABLE IF EXISTS public.portal_settings CASCADE;
DROP TABLE IF EXISTS public.students CASCADE;

-- ─── 2. STUDENTS TABLE ────────────────────────────────────────
-- Login credential = univ_reg_no (from ece_nominal_roll_2024.json)
-- active_session_token enforces single-device sessions

CREATE TABLE public.students (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  reg_number            TEXT        NOT NULL UNIQUE,
  student_name          TEXT,
  active_session_token  TEXT,
  session_started_at    TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_students_reg   ON public.students(reg_number);
CREATE INDEX idx_students_token ON public.students(active_session_token);

-- ─── 3. PORTAL SETTINGS TABLE ─────────────────────────────────
-- Control open time from Supabase dashboard.
-- portal_enabled = true  → portal is on
-- portal_open_time       → exact datetime login is allowed

CREATE TABLE public.portal_settings (
  id               INTEGER     PRIMARY KEY DEFAULT 1,
  portal_open_time TIMESTAMPTZ NOT NULL,
  portal_enabled   BOOLEAN     NOT NULL DEFAULT true,
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);

-- Portal opens at 2:10 PM IST on 2026-07-25
INSERT INTO public.portal_settings (id, portal_open_time, portal_enabled)
VALUES (1, '2026-07-25 14:10:00+05:30', true);

-- ─── 4. SEED ALL 193 STUDENTS ─────────────────────────────────
-- Source: ece_nominal_roll_2024.json → univ_reg_no + student_name

INSERT INTO public.students (reg_number, student_name) VALUES
  ('2127240701001', 'A AADHITHYA NARAYANAN'),
  ('2127240701002', 'ABHIMANYU SINGH BHATI'),
  ('2127240701003', 'ABIJESH JP'),
  ('2127240701004', 'ABRAR'),
  ('2127240701005', 'ADITYA K'),
  ('2127240701006', 'AGILAPRIYAN D'),
  ('2127240701007', 'AKASH RAM CHITTIBABU SULEKHA'),
  ('2127240701008', 'AKSHAYAKIRUTHIGA S T'),
  ('2127240701009', 'AKSHAYATH   VIJAYAKUMAR'),
  ('2127240701010', 'AMIRTHAVARSHINI R M'),
  ('2127240701011', 'ARUN K S'),
  ('2127240701012', 'ARUNAGEETHAYAN A'),
  ('2127240701013', 'ARUNSANKAR S'),
  ('2127240701014', 'ASHWIN   V'),
  ('2127240701015', 'ASHWINKUMAR T'),
  ('2127240701016', 'ASHWINTH R'),
  ('2127240701017', 'ASMITHA S'),
  ('2127240701018', 'ATHMAJA G'),
  ('2127240701019', 'B S AARTI'),
  ('2127240701020', 'B S SHRENIK'),
  ('2127240701021', 'B THIRUMAGANSRIRAM'),
  ('2127240701022', 'BALAMURUGAN L'),
  ('2127240701023', 'BALAMURUGAN S'),
  ('2127240701024', 'BHAKYA LAKSHMI P'),
  ('2127240701025', 'BHARATH KALYAN B'),
  ('2127240701026', 'BHAVANA S'),
  ('2127240701027', 'BHOOMINATH S'),
  ('2127240701028', 'BHUWANESHWARAN D'),
  ('2127240701029', 'CINTHIYAN R D'),
  ('2127240701030', 'DARUN H'),
  ('2127240701031', 'DEEPAKBALAN C M'),
  ('2127240701032', 'DEVADHARSHINI S A'),
  ('2127240701033', 'DHANYA M'),
  ('2127240701034', 'DHARUN KUMAR K'),
  ('2127240701035', 'DHEVADHURSHANIE E'),
  ('2127240701036', 'DHIVYA S'),
  ('2127240701037', 'DINESH KUMAR M'),
  ('2127240701038', 'DINESH S'),
  ('2127240701039', 'ENTHEZHIL T'),
  ('2127240701040', 'G RUKMANI BALA'),
  ('2127240701041', 'GIRISHA GAYATHRI B'),
  ('2127240701042', 'GOKUL E'),
  ('2127240701043', 'GOKUL M'),
  ('2127240701044', 'GOROCHHANA VIGNESH'),
  ('2127240701045', 'GOWTHAM D'),
  ('2127240701046', 'GRISLER PAUL J'),
  ('2127240701047', 'GURU ANIRUD V'),
  ('2127240701048', 'GURU P'),
  ('2127240701049', 'HAREENA MAHESH M D'),
  ('2127240701050', 'HARI PRASATH S'),
  ('2127240701051', 'HARI S'),
  ('2127240701052', 'HARIHARA R J'),
  ('2127240701053', 'HARIHARAN S'),
  ('2127240701054', 'HARINI SRI M'),
  ('2127240701055', 'HARISH S'),
  ('2127240701056', 'HARSHA VARDHAN N'),
  ('2127240701057', 'HARSITH PRITHVI D S'),
  ('2127240701058', 'HASMATH FARHANA B'),
  ('2127240701059', 'HEMALATHA R'),
  ('2127240701060', 'HEMANTH D'),
  ('2127240701061', 'IRFANAA PARVEEN M'),
  ('2127240701062', 'JADILA SUBRAMANIYAN V S'),
  ('2127240701063', 'JANARTHAN S M'),
  ('2127240701064', 'JAYASRI J'),
  ('2127240701065', 'JOHN JOSHUA SOLOMON RAJESH'),
  ('2127240701066', 'K BUVANESWARAN'),
  ('2127240701067', 'K R KIRUTHICK KUMAR'),
  ('2127240701068', 'K STAVROSH'),
  ('2127240701069', 'K THARUN VEL'),
  ('2127240701070', 'KAAMESH S'),
  ('2127240701071', 'KALAISELVAN K'),
  ('2127240701072', 'KALANITHI A'),
  ('2127240701073', 'KAMALINA K'),
  ('2127240701074', 'KARTHIK M'),
  ('2127240701075', 'KARTHIKEYAN M'),
  ('2127240701076', 'KAVIRAJAN P'),
  ('2127240701077', 'KAVIYA S'),
  ('2127240701078', 'KAVIYA SRI S'),
  ('2127240701079', 'KEERTHANA R'),
  ('2127240701080', 'KEERTHIGA   S'),
  ('2127240701081', 'KEERTHIKA M'),
  ('2127240701082', 'KESHORE P'),
  ('2127240701083', 'KRITHIKA RAJAPANDIAN'),
  ('2127240701084', 'LAVANYA C'),
  ('2127240701085', 'LIKITHA E'),
  ('2127240701086', 'LOGESHWARAN M'),
  ('2127240701087', 'LOGESHWARAN R'),
  ('2127240701088', 'LOHITH G'),
  ('2127240701089', 'LOKESH M'),
  ('2127240701090', 'M DEEPAK'),
  ('2127240701091', 'M KESHAVARAM'),
  ('2127240701092', 'M NIRANJAN'),
  ('2127240701093', 'MADHU MITHA N'),
  ('2127240701094', 'MAHALAKSHMI L'),
  ('2127240701095', 'MAHESH K R V'),
  ('2127240701096', 'MANOJ R'),
  ('2127240701097', 'MANOOJ KUMAR N'),
  ('2127240701098', 'MEYYAPPAN MEENAKSHI'),
  ('2127240701099', 'MOHANAPRIYA P'),
  ('2127240701100', 'MONICA S'),
  ('2127240701101', 'N RAHUL'),
  ('2127240701102', 'N YAAZHINII'),
  ('2127240701103', 'NANDHAGOPAL B'),
  ('2127240701104', 'NANDHITHASRI K K'),
  ('2127240701105', 'NARENDRAPRASATH M L'),
  ('2127240701106', 'NEHAA SRI M S'),
  ('2127240701107', 'NISHA L'),
  ('2127240701108', 'NITHILAN CHELLATHURAI'),
  ('2127240701109', 'NITHIN JAASIEL B'),
  ('2127240701110', 'NITHISH KUMAR N'),
  ('2127240701111', 'PARTHIBHARAJAN R'),
  ('2127240701112', 'PAVITHRA   M'),
  ('2127240701113', 'PRATHIBA M S K'),
  ('2127240701114', 'PRAVEEN BABU G'),
  ('2127240701115', 'PRAVIN D A'),
  ('2127240701116', 'PREETHIKA R'),
  ('2127240701117', 'PREMNATH N'),
  ('2127240701118', 'PRINCY NIKITHA J'),
  ('2127240701119', 'PRIYADHARSHAN   A B'),
  ('2127240701120', 'R V SAI SIRISH'),
  ('2127240701121', 'RAGHAV G S'),
  ('2127240701122', 'RAHUL G'),
  ('2127240701123', 'RAHUL S'),
  ('2127240701124', 'RAHUL SURIYA V'),
  ('2127240701125', 'RAMASAMY SP'),
  ('2127240701126', 'RAMSUBEESHA R S'),
  ('2127240701127', 'RAVEENDRAN K'),
  ('2127240701128', 'RB YUVAN'),
  ('2127240701129', 'RENGAVADIVELAMMAAL C'),
  ('2127240701130', 'RUPASHVINAYAK DHANAPAL'),
  ('2127240701131', 'RUPESH J'),
  ('2127240701132', 'S B SNIGDHA'),
  ('2127240701133', 'S HARI PRASHAD'),
  ('2127240701134', 'S MEENA'),
  ('2127240701135', 'S NAGAMANI KANDAN'),
  ('2127240701136', 'S SANTHOSH'),
  ('2127240701137', 'SAI VIGNESH S'),
  ('2127240701138', 'SAISHA PRIYADARSHINI S'),
  ('2127240701139', 'SANCHITHA D'),
  ('2127240701140', 'SANJAI P'),
  ('2127240701141', 'SANJAY SRINIVASAN B'),
  ('2127240701142', 'SANTHOSH KARTHICK M'),
  ('2127240701143', 'SANYU J'),
  ('2127240701144', 'SARABESH ADITHYA D'),
  ('2127240701145', 'SARABHESWARAN E S'),
  ('2127240701146', 'SARATHI SELVAM D'),
  ('2127240701147', 'SARVESH M'),
  ('2127240701148', 'SEDHURAMAN S'),
  ('2127240701149', 'SETHURAJAN S'),
  ('2127240701150', 'SHAMITHA SARAVANAN'),
  ('2127240701151', 'SHANJAY C'),
  ('2127240701152', 'SHARVESH VARSHAN M K'),
  ('2127240701153', 'SHAWN ABRAHAM JOSEPH L'),
  ('2127240701154', 'SHIVARAMAN S'),
  ('2127240701155', 'SHREE RAGHAV KUMAR E'),
  ('2127240701156', 'SIVAPRIYA S'),
  ('2127240701157', 'SIVARAMAN A'),
  ('2127240701158', 'SN ARJUN'),
  ('2127240701159', 'SREEKHA P V'),
  ('2127240701161', 'SRI HARIHARAN V'),
  ('2127240701162', 'SRI RAM S'),
  ('2127240701163', 'SRI RAMANA KISHORE K'),
  ('2127240701164', 'SUBASAKTHI PALANIAPPAN A'),
  ('2127240701165', 'SUBHACHARAN M'),
  ('2127240701166', 'SURYANARAYANAN V'),
  ('2127240701167', 'TAMILARASAN K'),
  ('2127240701168', 'TAMILPRIYAN M'),
  ('2127240701169', 'TARUN ADITYA G G'),
  ('2127240701170', 'TEENA SHIRLEY SAVARIMUTHU'),
  ('2127240701171', 'TEJASH D'),
  ('2127240701172', 'THARRUN G M'),
  ('2127240701173', 'THIRULOGASUNDAR M'),
  ('2127240701174', 'THRISHNAA PRASANTH'),
  ('2127240701175', 'V N SANJAI'),
  ('2127240701176', 'V S SURYA'),
  ('2127240701177', 'VANISHREE G'),
  ('2127240701178', 'VARUN S N'),
  ('2127240701179', 'VARUNAN K'),
  ('2127240701181', 'VIGNESHWAR K'),
  ('2127240701183', 'VIJAYASARATHY B'),
  ('2127240701184', 'VISWANATHAN L'),
  ('2127240701185', 'YASHWANTH RAJ R'),
  ('2127240701186', 'YOKESH G'),
  ('2127240701187', 'YORICK BRADLEY P'),
  ('2127240701301', 'BALU G'),
  ('2127240701302', 'DILLIBABU M'),
  ('2127240701303', 'G SRI MEGHANAMALINI'),
  ('2127240701304', 'KESAVAN V'),
  ('2127240701305', 'MAGIDISWARAN D'),
  ('2127240701306', 'RAMYA D'),
  ('2127240701307', 'RAMYADEVI S'),
  ('2127240701308', 'VENKATADRI P'),
  ('2127240701501', 'MURALIKRISHNA R');

-- ─── 5. RLS ───────────────────────────────────────────────────

ALTER TABLE public.students        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_settings ENABLE ROW LEVEL SECURITY;

-- Block all direct client access to students (use RPC only)
CREATE POLICY "no_direct_student_read"
  ON public.students FOR SELECT TO anon, authenticated USING (false);
CREATE POLICY "no_direct_student_write"
  ON public.students FOR INSERT TO anon, authenticated WITH CHECK (false);

-- Allow public read of portal_settings (for countdown display)
CREATE POLICY "public_read_portal_settings"
  ON public.portal_settings FOR SELECT TO anon, authenticated USING (true);

-- ─── 6. LOGIN FUNCTION ────────────────────────────────────────
-- Validates reg_number, generates a session token, stores it.
-- A new login REPLACES any existing session token (single-device).

CREATE OR REPLACE FUNCTION public.student_login(p_reg_number TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_student  public.students%ROWTYPE;
  v_token    TEXT;
BEGIN
  SELECT * INTO v_student
  FROM public.students
  WHERE reg_number = TRIM(p_reg_number);

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'code',    'invalid_reg',
      'message', 'Registration number not found. Please check and try again.'
    );
  END IF;

  -- Generate a new session token (hex-encoded 32 random bytes)
  v_token := encode(gen_random_bytes(32), 'hex');

  UPDATE public.students
  SET active_session_token = v_token,
      session_started_at   = NOW()
  WHERE id = v_student.id;

  RETURN jsonb_build_object(
    'success',       true,
    'code',          'login_ok',
    'session_token', v_token,
    'student_name',  COALESCE(v_student.student_name, ''),
    'reg_number',    v_student.reg_number
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'code', 'error', 'message', SQLERRM);
END;
$$;

-- ─── 7. SESSION VERIFY FUNCTION ───────────────────────────────
-- Used by the main page (server-side) to enforce single session.
-- If another device logged in, this token won't match → invalid.

CREATE OR REPLACE FUNCTION public.verify_session_token(p_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_student public.students%ROWTYPE;
BEGIN
  SELECT * INTO v_student
  FROM public.students
  WHERE active_session_token = p_token;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('valid', false);
  END IF;

  RETURN jsonb_build_object(
    'valid',        true,
    'student_name', COALESCE(v_student.student_name, ''),
    'reg_number',   v_student.reg_number
  );
END;
$$;

-- ─── 8. LOGOUT FUNCTION ───────────────────────────────────────

CREATE OR REPLACE FUNCTION public.student_logout(p_token TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.students
  SET active_session_token = NULL,
      session_started_at   = NULL
  WHERE active_session_token = p_token;
END;
$$;

-- ─── 9. GRANT EXECUTE ─────────────────────────────────────────

GRANT EXECUTE ON FUNCTION public.student_login(TEXT)        TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.verify_session_token(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.student_logout(TEXT)       TO anon, authenticated;

-- ─── DONE ─────────────────────────────────────────────────────
-- To change portal open time:
--   UPDATE public.portal_settings
--   SET portal_open_time = '2026-07-25 14:10:00+05:30'
--   WHERE id = 1;
--
-- To disable portal entirely:
--   UPDATE public.portal_settings SET portal_enabled = false WHERE id = 1;
--
-- To check who is logged in:
--   SELECT reg_number, student_name, session_started_at
--   FROM public.students
--   WHERE active_session_token IS NOT NULL;
