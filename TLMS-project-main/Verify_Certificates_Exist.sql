-- Quick verification: Check if certificates exist for your user
-- Run this in Supabase SQL Editor

SELECT 
    c.id,
    c.user_id,
    c.user_name,
    c.course_name,
    c.certificate_number,
    c.completion_date
FROM certificates c
ORDER BY c.created_at DESC
LIMIT 10;

-- If this returns 0 rows, you need to run Generate_Certificates.sql first!
-- If it returns rows, then the issue is with the app's certificate fetching logic.
