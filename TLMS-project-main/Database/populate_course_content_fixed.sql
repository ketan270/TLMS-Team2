-- Populate Course Content: Modules and Lessons (Fixed Version)
-- Run this script in Supabase SQL Editor to add sample content to existing courses

-- ============================================
-- MARKETING: Content Marketing Strategy
-- ============================================

UPDATE courses
SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Introduction to Content Marketing',
    'description', 'Learn the fundamentals of content marketing',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'What is Content Marketing?',
        'content', 'https://example.com/video1.mp4',
        'type', 'Video',
        'duration', 900,
        'transcript', E'[00:00] Welcome to this course on content marketing.\n[00:15] Content marketing is a strategic approach focused on creating valuable content.\n[00:30] In this lesson, we will explore what makes content marketing effective.\n[00:45] Let us start with the definition and core principles.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Content Strategy Fundamentals',
        'content', 'https://example.com/video2.mp4',
        'type', 'Video',
        'duration', 1200,
        'transcript', E'[00:00] In this lesson, we cover content strategy basics.\n[00:20] A solid strategy starts with understanding your audience.\n[00:40] We will discuss audience personas and content goals.\n[01:00] Let us dive into creating a content calendar.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Creating Engaging Content',
    'description', 'Master the art of content creation',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Writing for Your Audience',
        'content', 'https://example.com/video3.mp4',
        'type', 'Video',
        'duration', 1500,
        'transcript', E'[00:00] Welcome to the lesson on audience-focused writing.\n[00:25] Understanding your audience is crucial for effective content.\n[00:50] We will explore different writing techniques and styles.\n[01:15] Practice exercises will help solidify these concepts.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Visual Content Best Practices',
        'type', 'Text',
        'textContent', 'Visual content is 40x more likely to be shared on social media. Key principles include: 1) Use high-quality images, 2) Maintain brand consistency, 3) Optimize for different platforms.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Content Calendar Planning',
        'type', 'Text',
        'textContent', 'A content calendar helps you plan, organize, and schedule content in advance. Benefits include consistency, better organization, and strategic alignment.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Distribution & Analytics',
    'description', 'Learn to distribute and measure content success',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Publishing Platforms Overview',
        'content', 'https://example.com/video4.mp4',
        'type', 'Video',
        'duration', 1000,
        'transcript', E'[00:00] Today we explore different publishing platforms.\n[00:16] Each platform has unique characteristics and audiences.\n[00:32] We will cover blogs, social media, and email newsletters.\n[00:48] Choose platforms that align with your goals.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Measuring Content Success',
        'content', 'https://example.com/video5.mp4',
        'type', 'Video',
        'duration', 1100,
        'transcript', E'[00:00] Understanding metrics is key to content marketing success.\n[00:18] We will cover engagement rates, conversions, and ROI.\n[00:36] Learn to use analytics tools effectively.\n[00:54] Data-driven decisions lead to better results.'
      )
    )
  )
)
WHERE title ILIKE '%Content Marketing%';

-- ============================================
-- MARKETING: Digital Marketing Strategy
-- ============================================

UPDATE courses
SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Digital Marketing Foundations',
    'description', 'Core concepts of digital marketing',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Introduction to Digital Marketing',
        'content', 'https://example.com/video-dm1.mp4',
        'type', 'Video',
        'duration', 800,
        'transcript', E'[00:00] Welcome to Digital Marketing 101.\n[00:13] Digital marketing encompasses all marketing efforts using electronic devices.\n[00:26] This includes SEO, social media, email, and more.\n[00:39] Let us explore each channel in detail.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Understanding Your Digital Audience',
        'content', 'https://example.com/video-dm2.mp4',
        'type', 'Video',
        'duration', 950,
        'transcript', E'[00:00] Knowing your audience is the foundation of successful marketing.\n[00:15] We will discuss buyer personas and customer journey mapping.\n[00:30] Digital tools make audience research more precise.\n[00:45] Let us look at practical examples.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'SEO & SEM Strategies',
    'description', 'Search engine optimization and marketing',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'SEO Fundamentals',
        'content', 'https://example.com/video-seo.mp4',
        'type', 'Video',
        'duration', 1300,
        'transcript', E'[00:00] Search Engine Optimization is crucial for online visibility.\n[00:21] We will cover keyword research, on-page SEO, and link building.\n[00:42] Technical SEO ensures search engines can crawl your site.\n[01:03] Consistent practice leads to better rankings.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Google Ads & SEM',
        'content', 'https://example.com/video-sem.mp4',
        'type', 'Video',
        'duration', 1200,
        'transcript', E'[00:00] Search Engine Marketing delivers immediate results.\n[00:20] Learn to create effective Google Ads campaigns.\n[00:40] Bidding strategies and ad quality scores matter.\n[01:00] ROI measurement is essential for success.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Social Media Marketing',
    'description', 'Leverage social platforms effectively',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Social Media Strategy',
        'content', 'https://example.com/video-social.mp4',
        'type', 'Video',
        'duration', 1100,
        'transcript', E'[00:00] Social media connects brands with billions of users.\n[00:18] Each platform serves different purposes and audiences.\n[00:36] Create platform-specific content for best results.\n[00:54] Engagement and community building are key.'
      )
    )
  )
)
WHERE title ILIKE '%Digital Marketing%';

-- ============================================
-- PROGRAMMING: Java
-- ============================================

UPDATE courses
SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Java Basics',
    'description', 'Introduction to Java programming',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Introduction to Java',
        'content', 'https://example.com/java-intro.mp4',
        'type', 'Video',
        'duration', 1400,
        'transcript', E'[00:00] Hello and welcome to Java programming.\n[00:23] Java is a versatile, object-oriented programming language.\n[00:46] Used for web, mobile, and enterprise applications.\n[01:09] Let us set up your development environment.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Variables and Data Types',
        'content', 'https://example.com/java-variables.mp4',
        'type', 'Video',
        'duration', 1600,
        'transcript', E'[00:00] Understanding variables is fundamental to programming.\n[00:26] Java has primitive and reference data types.\n[00:52] Int, double, boolean, and String are commonly used.\n[01:18] Let us write some code examples together.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Control Flow Statements',
        'content', 'https://example.com/java-control.mp4',
        'type', 'Video',
        'duration', 1500,
        'transcript', E'[00:00] Control flow determines the order of code execution.\n[00:25] If-else statements help make decisions.\n[00:50] Loops allow repetitive operations efficiently.\n[01:15] Practice is key to mastering these concepts.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Object-Oriented Programming',
    'description', 'Master OOP concepts in Java',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Classes and Objects',
        'content', 'https://example.com/java-classes.mp4',
        'type', 'Video',
        'duration', 1800,
        'transcript', E'[00:00] Object-oriented programming organizes code into objects.\n[00:30] Classes are blueprints for creating objects.\n[01:00] Objects contain both data and methods.\n[01:30] Let us create your first class together.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Inheritance and Polymorphism',
        'content', 'https://example.com/java-inheritance.mp4',
        'type', 'Video',
        'duration', 1700,
        'transcript', E'[00:00] Inheritance allows classes to inherit properties.\n[00:28] This promotes code reusability and organization.\n[00:56] Polymorphism enables flexible and extensible code.\n[01:24] These are powerful OOP features.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Advanced Java Concepts',
    'description', 'Dive deeper into Java programming',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Exception Handling',
        'content', 'https://example.com/java-exceptions.mp4',
        'type', 'Video',
        'duration', 1400,
        'transcript', E'[00:00] Exception handling prevents program crashes.\n[00:23] Try-catch blocks manage errors gracefully.\n[00:46] Understanding exception types is important.\n[01:09] Proper error handling improves user experience.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'File I/O Operations',
        'content', 'https://example.com/java-file-io.mp4',
        'type', 'Video',
        'duration', 1500,
        'transcript', E'[00:00] Reading and writing files is essential for applications.\n[00:25] Java provides powerful I/O classes and methods.\n[00:50] We will work with text and binary files.\n[01:15] Always close resources to prevent memory leaks.'
      )
    )
  )
)
WHERE title ILIKE '%Java%' AND category ILIKE '%programming%';

-- ============================================
-- PROGRAMMING: Cybersecurity
-- ============================================

UPDATE courses
SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Introduction to Cybersecurity',
    'description', 'Fundamentals of digital security',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Cybersecurity Overview',
        'content', 'https://example.com/cyber-intro.mp4',
        'type', 'Video',
        'duration', 1300,
        'transcript', E'[00:00] Welcome to Cybersecurity Fundamentals.\n[00:21] Cybersecurity protects systems from digital attacks.\n[00:42] Understanding threats is the first step to defense.\n[01:03] We will cover key concepts and best practices.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Common Security Threats',
        'content', 'https://example.com/cyber-threats.mp4',
        'type', 'Video',
        'duration', 1600,
        'transcript', E'[00:00] Cyber threats evolve constantly worldwide.\n[00:26] Malware, phishing, and ransomware are common.\n[00:52] Social engineering exploits human psychology.\n[01:18] Awareness is your first line of defense.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Network Security',
    'description', 'Protecting network infrastructure',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Firewalls and VPNs',
        'content', 'https://example.com/cyber-network.mp4',
        'type', 'Video',
        'duration', 1500,
        'transcript', E'[00:00] Network security safeguards data in transit.\n[00:25] Firewalls filter incoming and outgoing traffic.\n[00:50] VPNs encrypt connections for privacy.\n[01:15] Proper configuration is critical for security.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Security Best Practices',
    'description', 'Implementing security measures',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Password Security',
        'content', 'https://example.com/cyber-passwords.mp4',
        'type', 'Video',
        'duration', 1200,
        'transcript', E'[00:00] Strong passwords are essential for account security.\n[00:20] Use unique passwords for each service.\n[00:40] Password managers simplify secure password use.\n[01:00] Two-factor authentication adds extra protection.'
      )
    )
  )
)
WHERE title ILIKE '%Cybersecurity%';

-- ============================================
-- DESIGN: Mobile App Design
-- ============================================

UPDATE courses
SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Mobile UI/UX Principles',
    'description', 'Design beautiful mobile interfaces',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Introduction to Mobile Design',
        'content', 'https://example.com/mobile-design-intro.mp4',
        'type', 'Video',
        'duration', 1300,
        'transcript', E'[00:00] Mobile design requires special considerations.\n[00:21] Screen size and touch interactions are unique.\n[00:42] User experience is paramount on mobile.\n[01:03] Let us explore mobile design principles.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'iOS vs Android Design Guidelines',
        'content', 'https://example.com/ios-android.mp4',
        'type', 'Video',
        'duration', 1500,
        'transcript', E'[00:00] iOS and Android have different design languages.\n[00:25] Human Interface Guidelines govern iOS design.\n[00:50] Material Design defines Android aesthetics.\n[01:15] Understanding both creates better apps.'
      )
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Prototyping & User Testing',
    'description', 'Create and test mobile prototypes',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'Creating Interactive Prototypes',
        'content', 'https://example.com/prototyping.mp4',
        'type', 'Video',
        'duration', 1700,
        'transcript', E'[00:00] Prototypes bring designs to life interactively.\n[00:28] Tools like Figma enable rapid prototyping.\n[00:56] Test flows before writing code.\n[01:24] Iteration improves design quality significantly.'
      ),
      jsonb_build_object(
        'id', gen_random_uuid(),
        'title', 'User Testing Methods',
        'content', 'https://example.com/user-testing.mp4',
        'type', 'Video',
        'duration', 1400,
        'transcript', E'[00:00] User testing validates design decisions.\n[00:23] Observe real users interacting with prototypes.\n[00:46] Collect feedback and identify pain points.\n[01:09] Data-driven design creates better products.'
      )
    )
  )
)
WHERE title ILIKE '%Mobile App Design%';

-- ============================================
-- VERIFY RESULTS
-- ============================================

SELECT 
    title, 
    category,
    jsonb_array_length(modules) as module_count,
    (SELECT COUNT(*) FROM jsonb_array_elements(modules) as m, jsonb_array_elements(m->'lessons') as l) as lesson_count
FROM courses
WHERE modules IS NOT NULL
ORDER BY category, title;
