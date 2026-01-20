-- Add progress column to enrollments table if it doesn't exist
-- Run this in Supabase SQL Editor

-- Add progress column (0.0 to 1.0, where 1.0 = 100%)
ALTER TABLE enrollments 
ADD COLUMN IF NOT EXISTS progress DOUBLE PRECISION DEFAULT 0.0;

-- Update existing enrollments to have 0 progress
UPDATE enrollments 
SET progress = 0.0 
WHERE progress IS NULL;

-- Verify the column was added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'enrollments'
ORDER BY ordinal_position;

-- Check current enrollments
SELECT 
    user_id,
    course_id,
    progress,
    enrolled_at
FROM enrollments
ORDER BY enrolled_at DESC
LIMIT 10;
