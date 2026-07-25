-- ============================================================
-- Only apply the new changes after the existing SQL was already run
-- ============================================================

-- 1) Set the default seat limit to 2 for future inserts
ALTER TABLE public.subjects
ALTER COLUMN max_seats SET DEFAULT 2;

-- 2) Update all existing subjects to have a max limit of 2
UPDATE public.subjects
SET max_seats = 2;

-- 3) Reset all course seats to 0 and reopen them
UPDATE public.subjects
SET filled_seats = 0,
    status = 'open';

-- 4) Optional: if you want to ensure the seed values are also 2
-- (use this only if you have not already inserted data)
-- INSERT INTO public.subjects (subject_code, subject_name, max_seats, filled_seats, status)
-- VALUES
--   ('VD22704', 'Embedded System Simulation', 2, 0, 'open'),
--   ('VD22702', 'Artificial Neural Networks', 2, 0, 'open'),
--   ('VD22712', 'Standards for Electronics and Communication Engineers', 2, 0, 'open'),
--   ('VD22705', 'Hardware Modeling and Analysis using EDA Tool', 2, 0, 'open')
-- ON CONFLICT (subject_code) DO NOTHING;

-- 5) Verification
SELECT subject_code, subject_name, max_seats, filled_seats, status
FROM public.subjects
ORDER BY subject_code;
