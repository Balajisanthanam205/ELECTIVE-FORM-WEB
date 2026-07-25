-- ============================================================
-- Update all courses to 48 seats, except Standards course to 49
-- ============================================================

-- 1) Update all courses to 48 seats and reset counts
UPDATE public.subjects
SET
  max_seats = 48,
  filled_seats = 0,
  status = 'open';

-- 2) Update only "Standards for Electronics and Communication Engineers" to 49 seats
UPDATE public.subjects
SET max_seats = 49
WHERE subject_code = 'VD22712';

-- 3) Update the default for future inserts
ALTER TABLE public.subjects
ALTER COLUMN max_seats SET DEFAULT 48;

-- 4) Verification
SELECT subject_code, subject_name, max_seats, filled_seats, status
FROM public.subjects
ORDER BY subject_code;
