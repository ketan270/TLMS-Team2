-- TLMS Sample Course Content - Simplified Version
-- Run this in your Supabase SQL Editor
-- Creates 5 courses with embedded JSON modules and lessons

DO $$
DECLARE
    v_educator_id UUID;
BEGIN
    -- Get first user as educator
    SELECT id INTO v_educator_id FROM auth.users LIMIT 1;
    
    IF v_educator_id IS NULL THEN
        RAISE EXCEPTION 'No users found. Please create a user account first.';
    END IF;
    
    RAISE NOTICE 'Using educator ID: %', v_educator_id;
    
    -- Course 1: SwiftUI Mastery (FREE)
    INSERT INTO courses (id, title, description, category, price, status, educator_id, modules, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'SwiftUI Mastery: Build Modern iOS Apps',
        'Learn to build beautiful iOS applications with SwiftUI. Master views, state management, animations, and more.',
        'Programming',
        0,
        'published',
        v_educator_id,
        jsonb_build_array(
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'SwiftUI Fundamentals',
                'description', 'Learn the basics of SwiftUI',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Introduction to SwiftUI',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                        'contentDescription', 'Welcome to SwiftUI! Learn what makes it revolutionary.'
                    ),
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Views and Modifiers',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
                        'contentDescription', 'Master SwiftUI views and modifiers.'
                    )
                )
            ),
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'State Management',
                'description', 'Master state in SwiftUI',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', '@State and @Binding',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
                        'contentDescription', 'Learn state management with @State and @Binding.'
                    )
                )
            )
        ),
        NOW(),
        NOW()
    );
    
    -- Course 2: iOS Design Principles (PAID)
    INSERT INTO courses (id, title, description, category, price, status, educator_id, modules, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'iOS Design Principles',
        'Master the art of designing beautiful iOS applications following Apple''s Human Interface Guidelines.',
        'Design',
        999,
        'published',
        v_educator_id,
        jsonb_build_array(
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'Design Fundamentals',
                'description', 'Core design principles',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Color Theory for iOS',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
                        'contentDescription', 'Understanding color psychology in iOS design.'
                    ),
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Typography Best Practices',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
                        'contentDescription', 'Learn effective typography for iOS apps.'
                    )
                )
            )
        ),
        NOW(),
        NOW()
    );
    
    -- Course 3: Data Science with Python (FREE)
    INSERT INTO courses (id, title, description, category, price, status, educator_id, modules, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'Data Science with Python',
        'Complete guide to data science using Python, pandas, and machine learning.',
        'Data Science',
        0,
        'published',
        v_educator_id,
        jsonb_build_array(
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'Python Basics',
                'description', 'Introduction to Python',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Python Introduction',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
                        'contentDescription', 'Get started with Python for data science.'
                    ),
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Variables and Data Types',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
                        'contentDescription', 'Learn Python variables and data types.'
                    )
                )
            ),
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'Data Analysis',
                'description', 'Working with pandas',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Introduction to Pandas',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
                        'contentDescription', 'Master data manipulation with pandas.'
                    )
                )
            )
        ),
        NOW(),
        NOW()
    );
    
    -- Course 4: Digital Marketing (PAID)
    INSERT INTO courses (id, title, description, category, price, status, educator_id, modules, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'Digital Marketing Fundamentals',
        'Learn the essentials of digital marketing including SEO, social media, and content marketing.',
        'Marketing',
        1499,
        'published',
        v_educator_id,
        jsonb_build_array(
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'Marketing Basics',
                'description', 'Core marketing concepts',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Introduction to Digital Marketing',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
                        'contentDescription', 'Overview of digital marketing landscape.'
                    ),
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'SEO Fundamentals',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
                        'contentDescription', 'Learn search engine optimization basics.'
                    )
                )
            )
        ),
        NOW(),
        NOW()
    );
    
    -- Course 5: Business Strategy (FREE)
    INSERT INTO courses (id, title, description, category, price, status, educator_id, modules, created_at, updated_at)
    VALUES (
        gen_random_uuid(),
        'Business Strategy Essentials',
        'Learn strategic thinking and business planning for startups and enterprises.',
        'Business',
        0,
        'published',
        v_educator_id,
        jsonb_build_array(
            jsonb_build_object(
                'id', gen_random_uuid(),
                'title', 'Strategy Fundamentals',
                'description', 'Core strategy concepts',
                'lessons', jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Strategic Planning',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
                        'contentDescription', 'Learn to create effective business strategies.'
                    ),
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'title', 'Competitive Analysis',
                        'type', 'Video',
                        'fileURL', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
                        'contentDescription', 'Understanding competition and market positioning.'
                    )
                )
            )
        ),
        NOW(),
        NOW()
    );
    
    RAISE NOTICE '✅ Successfully created 5 courses with video content!';
    
END $$;

-- Verification Query
SELECT 
    title,
    category,
    CASE WHEN price = 0 THEN 'FREE' ELSE price::text || ' INR' END as price,
    jsonb_array_length(modules) as module_count,
    status
FROM courses
WHERE status = 'published'
ORDER BY created_at DESC
LIMIT 10;
