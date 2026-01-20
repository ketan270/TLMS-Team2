-- Quick check: Do you have any certificates in the database?
-- Run this in Supabase SQL Editor

SELECT 
    user_name,
    course_name,
    certificate_number,
    TO_CHAR(completion_date, 'Mon DD, YYYY') as completion_date
FROM certificates
ORDER BY created_at DESC;

-- If this returns 0 rows, you need to run the Generate_Certificates.sql script first!
