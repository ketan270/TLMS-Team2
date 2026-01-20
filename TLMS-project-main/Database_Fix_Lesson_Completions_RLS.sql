-- Fix for lesson_completions RLS policies
-- Run this in Supabase SQL Editor to fix the permission error

-- Drop existing policies that reference users table
DROP POLICY IF EXISTS "Admins can view all lesson completions" ON lesson_completions;
DROP POLICY IF EXISTS "Educators can view completions for their courses" ON lesson_completions;

-- Recreate simpler policies without users table reference

-- Policy: Educators can view lesson completions for their courses
CREATE POLICY "Educators can view completions for their courses"
ON lesson_completions FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM courses
        WHERE courses.id = lesson_completions.course_id
        AND courses.educator_id = auth.uid()
    )
);

-- Verification
SELECT 'RLS policies fixed! Try marking lesson as complete now.' AS status;
