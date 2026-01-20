-- Manual fix to update progress for courses with completed lessons
-- Run this in Supabase SQL Editor

-- Update progress for iOS Design Principles (2 lessons completed out of 2)
UPDATE enrollments
SET progress = 1.0
WHERE course_id = '1a1df132-e20d-48f4-aeee-8aa614bcba56'
AND user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49';

-- Update progress for Business Strategy Essentials (2 lessons completed out of 2)
UPDATE enrollments
SET progress = 1.0
WHERE course_id = 'ab97e876-c5cf-4d1c-a1bc-5199279b0ab1'
AND user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49';

-- Verify the updates
SELECT 
    e.user_id,
    c.title,
    e.progress,
    (SELECT COUNT(*) FROM lesson_completions lc WHERE lc.course_id = e.course_id AND lc.user_id = e.user_id) as completed_lessons
FROM enrollments e
JOIN courses c ON c.id = e.course_id
WHERE e.user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49'
ORDER BY e.enrolled_at DESC;

-- Now generate certificates for completed courses
-- (The app should do this automatically, but we can trigger it manually)
