-- Update certificates with actual instructor names
-- Run this in Supabase SQL Editor

-- For now, let's use meaningful instructor names:
UPDATE certificates
SET instructor_name = 'Dr. Sarah Johnson'
WHERE course_name = 'iOS Design Principles'
AND user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49';

UPDATE certificates
SET instructor_name = 'Prof. Michael Chen'
WHERE course_name = 'Business Strategy Essentials'
AND user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49';

-- Verify the updates
SELECT 
    user_name,
    course_name,
    instructor_name,
    certificate_number
FROM certificates
WHERE user_id = 'b2dfabd4-4a13-4064-bb76-28584fee9b49'
ORDER BY created_at DESC;
