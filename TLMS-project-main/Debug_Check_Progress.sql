-- Debug query to check lesson completions and progress
-- Run this in Supabase SQL Editor to see what's actually in the database

-- 1. Check lesson completions
SELECT 
    lc.user_id,
    lc.course_id,
    lc.lesson_id,
    lc.completed_at,
    c.title as course_title
FROM lesson_completions lc
LEFT JOIN courses c ON c.id = lc.course_id
ORDER BY lc.completed_at DESC
LIMIT 20;

-- 2. Check enrollments and their progress
SELECT 
    e.user_id,
    e.course_id,
    e.progress,
    e.enrolled_at,
    c.title as course_title
FROM enrollments e
LEFT JOIN courses c ON c.id = e.course_id
ORDER BY e.enrolled_at DESC;

-- 3. Count lessons per course vs completed lessons
SELECT 
    c.id as course_id,
    c.title,
    jsonb_array_length(c.modules) as module_count,
    (
        SELECT COUNT(*)
        FROM lesson_completions lc
        WHERE lc.course_id = c.id
    ) as completed_lessons,
    e.progress as stored_progress
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
WHERE c.status = 'published'
ORDER BY c.created_at DESC;
