-- Generate certificates for ALL completed courses (progress = 1.0)
-- Run this AFTER adding user_name column
-- Automatically finds all completed courses and generates certificates

DO $$
DECLARE
    v_user_name TEXT := 'Ketan Sharma'; -- Change this to your name
    enrollment_record RECORD;
    v_cert_number TEXT;
BEGIN
    -- Loop through all enrollments with 100% progress
    FOR enrollment_record IN 
        SELECT 
            e.user_id,
            e.course_id,
            c.title as course_name
        FROM enrollments e
        JOIN courses c ON c.id = e.course_id
        WHERE e.progress >= 1.0
        AND NOT EXISTS (
            SELECT 1 FROM certificates cert
            WHERE cert.user_id = e.user_id
            AND cert.course_id = e.course_id
        )
    LOOP
        -- Generate unique certificate number
        v_cert_number := 'CERT-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8));
        
        -- Insert certificate
        INSERT INTO certificates (
            id,
            user_id,
            course_id,
            user_name,
            course_name,
            completion_date,
            certificate_number,
            instructor_name,
            created_at
        ) VALUES (
            gen_random_uuid(),
            enrollment_record.user_id,
            enrollment_record.course_id,
            v_user_name,
            enrollment_record.course_name,
            NOW(),
            v_cert_number,
            'TLMS Instructor', -- Default instructor name
            NOW()
        );
        
        RAISE NOTICE '✅ Certificate generated for: %', enrollment_record.course_name;
    END LOOP;
    
    RAISE NOTICE '🎓 Certificate generation complete!';
END $$;

-- Verify certificates were created
SELECT 
    user_name,
    course_name,
    certificate_number,
    TO_CHAR(completion_date, 'Mon DD, YYYY') as completion_date
FROM certificates
ORDER BY created_at DESC;
