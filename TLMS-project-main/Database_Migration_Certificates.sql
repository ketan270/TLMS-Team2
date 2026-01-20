-- TLMS Database Migration: Certificates System
-- Run this in your Supabase SQL Editor
-- Version: 1.0
-- Date: 2026-01-20

-- ============================================
-- 1. CREATE CERTIFICATES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    course_name TEXT NOT NULL,
    completion_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    certificate_number TEXT UNIQUE NOT NULL,
    instructor_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_certificates_user_id 
ON certificates(user_id);

CREATE INDEX IF NOT EXISTS idx_certificates_course_id 
ON certificates(course_id);

CREATE INDEX IF NOT EXISTS idx_certificates_number 
ON certificates(certificate_number);

CREATE INDEX IF NOT EXISTS idx_certificates_created_at 
ON certificates(created_at DESC);

-- ============================================
-- 3. ADD UNIQUE CONSTRAINT
-- ============================================

-- Ensure one certificate per user per course
CREATE UNIQUE INDEX IF NOT EXISTS idx_certificates_user_course 
ON certificates(user_id, course_id);

-- ============================================
-- 4. ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. CREATE RLS POLICIES
-- ============================================

-- Policy: Users can view their own certificates
CREATE POLICY "Users can view own certificates"
ON certificates
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own certificates (via service)
CREATE POLICY "Users can insert own certificates"
ON certificates
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Educators can view certificates for their courses
CREATE POLICY "Educators can view course certificates"
ON certificates
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM courses
        WHERE courses.id = certificates.course_id
        AND courses.educator_id = auth.uid()
    )
);

-- Policy: Admins can view all certificates
-- Note: Update this policy based on your admin identification logic
-- For now, commented out - uncomment and modify if you have an admin role system
/*
CREATE POLICY "Admins can view all certificates"
ON certificates
FOR SELECT
USING (
    -- Add your admin check here
    -- Example: auth.jwt() ->> 'role' = 'admin'
    true
);
*/

-- ============================================
-- 6. CREATE UPDATED_AT TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_certificates_updated_at
BEFORE UPDATE ON certificates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 7. VERIFICATION QUERIES
-- ============================================

-- Verify table creation
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'certificates'
ORDER BY ordinal_position;

-- Verify indexes
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'certificates';

-- Verify RLS is enabled
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'certificates';

-- ============================================
-- 8. SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ============================================

-- Uncomment to insert sample certificate for testing
/*
INSERT INTO certificates (
    user_id,
    course_id,
    course_name,
    certificate_number,
    instructor_name
) VALUES (
    'YOUR_USER_ID_HERE',
    'YOUR_COURSE_ID_HERE',
    'Sample Course Name',
    'TLMS-' || EXTRACT(EPOCH FROM NOW())::BIGINT || '-' || (RANDOM() * 9999)::INT,
    'Instructor Name'
);
*/

-- ============================================
-- MIGRATION COMPLETE
-- ============================================

-- Run this query to confirm migration success
SELECT 'Certificates table migration completed successfully!' AS status;
