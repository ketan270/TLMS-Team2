-- Add user_name column to certificates table
-- Run this in Supabase SQL Editor FIRST

ALTER TABLE certificates 
ADD COLUMN IF NOT EXISTS user_name TEXT;

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'certificates'
ORDER BY ordinal_position;
