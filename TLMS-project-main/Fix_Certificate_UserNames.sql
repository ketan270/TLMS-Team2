-- Fix existing certificates by adding user_name
-- Run this in Supabase SQL Editor

UPDATE certificates
SET user_name = 'Ketan Sharma'
WHERE user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49'
AND user_name IS NULL;

-- Verify the update
SELECT 
    user_name,
    course_name,
    certificate_number,
    TO_CHAR(completion_date, 'Mon DD, YYYY') as completion_date
FROM certificates
WHERE user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49'
ORDER BY created_at DESC;
