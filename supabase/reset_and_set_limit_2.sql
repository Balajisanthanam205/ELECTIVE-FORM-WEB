-- ============================================================
-- Reset the entire database and set every course limit to 2
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1) Clear registrations first (child table)
DELETE FROM public.registrations;

-- 2) Clear subjects
DELETE FROM public.subjects;

-- 3) Reset the subject capacity to 2 for all seeded courses
INSERT INTO public.subjects (subject_code, subject_name, max_seats, filled_seats, status)
VALUES
  ('VD22704', 'Embedded System Simulation', 2, 0, 'open'),
  ('VD22702', 'Artificial Neural Networks', 2, 0, 'open'),
  ('VD22712', 'Standards for Electronics and Communication Engineers', 2, 0, 'open'),
  ('VD22705', 'Hardware Modeling and Analysis using EDA Tool', 2, 0, 'open')
ON CONFLICT (subject_code) DO UPDATE
SET
  max_seats = EXCLUDED.max_seats,
  filled_seats = 0,
  status = 'open';

-- 4) Optional: if you want to enforce the new limit everywhere, update existing rows too
UPDATE public.subjects
SET max_seats = 2,
    filled_seats = CASE WHEN filled_seats > 2 THEN 2 ELSE filled_seats END,
    status = CASE WHEN filled_seats > 2 THEN 'full' ELSE 'open' END;

-- 5) Verification
SELECT subject_code, subject_name, max_seats, filled_seats, status
FROM public.subjects
ORDER BY subject_code;
