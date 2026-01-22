-- Populate Course Content: Modules and Lessons
-- Run this script in Supabase SQL Editor to add sample content to existing courses
-- Fixed version with proper JSON handling

-- ============================================
-- MARKETING COURSES
-- ============================================

-- Update "Content Marketing Strategy & Creation"
UPDATE courses
SET modules = '[
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Introduction to Content Marketing",
    "description": "Learn the fundamentals of content marketing",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "What is Content Marketing?",
        "content": "https://example.com/video1.mp4",
        "type": "Video",
        "duration": 900,
        "transcript": "[00:00] Welcome to this course on content marketing.\\n[00:15] Content marketing is a strategic approach focused on creating valuable content.\\n[00:30] In this lesson, we''ll explore what makes content marketing effective.\\n[00:45] Let''s start with the definition and core principles."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Content Strategy Fundamentals",
        "content": "https://example.com/video2.mp4",
        "type": "Video",
        "duration": 1200,
        "transcript": "[00:00] In this lesson, we cover content strategy basics.\\n[00:20] A solid strategy starts with understanding your audience.\\n[00:40] We''ll discuss audience personas and content goals.\\n[01:00] Let''s dive into creating a content calendar."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Creating Engaging Content",
    "description": "Master the art of content creation",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Writing for Your Audience",
        "content": "https://example.com/video3.mp4",
        "type": "Video",
        "duration": 1500,
        "transcript": "[00:00] Welcome to the lesson on audience-focused writing.\\n[00:25] Understanding your audience is crucial for effective content.\\n[00:50] We''ll explore different writing techniques and styles.\\n[01:15] Practice exercises will help solidify these concepts."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Visual Content Best Practices",
        "content": "Learn how to create compelling visual content",
        "type": "Text",
        "textContent": "Visual content is 40x more likely to be shared on social media. Key principles include: 1) Use high-quality images, 2) Maintain brand consistency, 3) Optimize for different platforms."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Content Calendar Planning",
        "content": "Master content scheduling",
        "type": "Text",
        "textContent": "A content calendar helps you plan, organize, and schedule content in advance. Benefits include consistency, better organization, and strategic alignment."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Distribution & Analytics",
    "description": "Learn to distribute and measure content success",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Publishing Platforms Overview",
        "content": "https://example.com/video4.mp4",
        "type": "Video",
        "duration": 1000,
        "transcript": "[00:00] Today we explore different publishing platforms.\\n[00:16] Each platform has unique characteristics and audiences.\\n[00:32] We''ll cover blogs, social media, and email newsletters.\\n[00:48] Choose platforms that align with your goals."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Measuring Content Success",
        "content": "https://example.com/video5.mp4",
        "type": "Video",
        "duration": 1100,
        "transcript": "[00:00] Understanding metrics is key to content marketing success.\\n[00:18] We''ll cover engagement rates, conversions, and ROI.\\n[00:36] Learn to use analytics tools effectively.\\n[00:54] Data-driven decisions lead to better results."
      }
    ]
  }
]'::jsonb
WHERE title ILIKE '%Content Marketing%';

-- Update "Digital Marketing Strategy"
UPDATE courses
SET modules = '[
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Digital Marketing Foundations",
    "description": "Core concepts of digital marketing",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Introduction to Digital Marketing",
        "content": "https://example.com/video-dm1.mp4",
        "type": "Video",
        "duration": 800,
        "transcript": "[00:00] Welcome to Digital Marketing 101.\\n[00:13] Digital marketing encompasses all marketing efforts using electronic devices.\\n[00:26] This includes SEO, social media, email, and more.\\n[00:39] Let''s explore each channel in detail."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Understanding Your Digital Audience",
        "content": "https://example.com/video-dm2.mp4",
        "type": "Video",
        "duration": 950,
        "transcript": "[00:00] Knowing your audience is the foundation of successful marketing.\\n[00:15] We''ll discuss buyer personas and customer journey mapping.\\n[00:30] Digital tools make audience research more precise.\\n[00:45] Let''s look at practical examples."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "SEO & SEM Strategies",
    "description": "Search engine optimization and marketing",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "SEO Fundamentals",
        "content": "https://example.com/video-seo.mp4",
        "type": "Video",
        "duration": 1300,
        "transcript": "[00:00] Search Engine Optimization is crucial for online visibility.\\n[00:21] We''ll cover keyword research, on-page SEO, and link building.\\n[00:42] Technical SEO ensures search engines can crawl your site.\\n[01:03] Consistent practice leads to better rankings."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Google Ads & SEM",
        "content": "https://example.com/video-sem.mp4",
        "type": "Video",
        "duration": 1200,
        "transcript": "[00:00] Search Engine Marketing delivers immediate results.\\n[00:20] Learn to create effective Google Ads campaigns.\\n[00:40] Bidding strategies and ad quality scores matter.\\n[01:00] ROI measurement is essential for success."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Social Media Marketing",
    "description": "Leverage social platforms effectively",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Social Media Strategy",
        "content": "https://example.com/video-social.mp4",
        "type": "Video",
        "duration": 1100,
        "transcript": "[00:00] Social media connects brands with billions of users.\\n[00:18] Each platform serves different purposes and audiences.\\n[00:36] Create platform-specific content for best results.\\n[00:54] Engagement and community building are key."
      }
    ]
  }
]'::jsonb
WHERE title ILIKE '%Digital Marketing%';

-- ============================================
-- PROGRAMMING/DEVELOPMENT COURSES
-- ============================================

-- Update Java courses
UPDATE courses
SET modules = '[
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Java Basics",
    "description": "Introduction to Java programming",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Introduction to Java",
        "content": "https://example.com/java-intro.mp4",
        "type": "Video",
        "duration": 1400,
        "transcript": "[00:00] Hello and welcome to Java programming.\\n[00:23] Java is a versatile, object-oriented programming language.\\n[00:46] Used for web, mobile, and enterprise applications.\\n[01:09] Let''s set up your development environment."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Variables and Data Types",
        "content": "https://example.com/java-variables.mp4",
        "type": "Video",
        "duration": 1600,
        "transcript": "[00:00] Understanding variables is fundamental to programming.\\n[00:26] Java has primitive and reference data types.\\n[00:52] Int, double, boolean, and String are commonly used.\\n[01:18] Let''s write some code examples together."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Control Flow Statements",
        "content": "https://example.com/java-control.mp4",
        "type": "Video",
        "duration": 1500,
        "transcript": "[00:00] Control flow determines the order of code execution.\\n[00:25] If-else statements help make decisions.\\n[00:50] Loops allow repetitive operations efficiently.\\n[01:15] Practice is key to mastering these concepts."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Object-Oriented Programming",
    "description": "Master OOP concepts in Java",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Classes and Objects",
        "content": "https://example.com/java-classes.mp4",
        "type": "Video",
        "duration": 1800,
        "transcript": "[00:00] Object-oriented programming organizes code into objects.\\n[00:30] Classes are blueprints for creating objects.\\n[01:00] Objects contain both data and methods.\\n[01:30] Let''s create your first class together."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Inheritance and Polymorphism",
        "content": "https://example.com/java-inheritance.mp4",
        "type": "Video",
        "duration": 1700,
        "transcript": "[00:00] Inheritance allows classes to inherit properties.\\n[00:28] This promotes code reusability and organization.\\n[00:56] Polymorphism enables flexible and extensible code.\\n[01:24] These are powerful OOP features."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Advanced Java Concepts",
    "description": "Dive deeper into Java programming",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Exception Handling",
        "content": "https://example.com/java-exceptions.mp4",
        "type": "Video",
        "duration": 1400,
        "transcript": "[00:00] Exception handling prevents program crashes.\\n[00:23] Try-catch blocks manage errors gracefully.\\n[00:46] Understanding exception types is important.\\n[01:09] Proper error handling improves user experience."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "File I/O Operations",
        "content": "https://example.com/java-file-io.mp4",
        "type": "Video",
        "duration": 1500,
        "transcript": "[00:00] Reading and writing files is essential for applications.\\n[00:25] Java provides powerful I/O classes and methods.\\n[00:50] We''ll work with text and binary files.\\n[01:15] Always close resources to prevent memory leaks."
      }
    ]
  }
]'::jsonb
WHERE title ILIKE '%Java%' AND category ILIKE '%programming%';

-- Update Cybersecurity course
UPDATE courses
SET modules = '[
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Introduction to Cybersecurity",
    "description": "Fundamentals of digital security",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Cybersecurity Overview",
        "content": "https://example.com/cyber-intro.mp4",
        "type": "Video",
        "duration": 1300,
        "transcript": "[00:00] Welcome to Cybersecurity Fundamentals.\\n[00:21] Cybersecurity protects systems from digital attacks.\\n[00:42] Understanding threats is the first step to defense.\\n[01:03] We''ll cover key concepts and best practices."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Common Security Threats",
        "content": "https://example.com/cyber-threats.mp4",
        "type": "Video",
        "duration": 1600,
        "transcript": "[00:00] Cyber threats evolve constantly worldwide.\\n[00:26] Malware, phishing, and ransomware are common.\\n[00:52] Social engineering exploits human psychology.\\n[01:18] Awareness is your first line of defense."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Network Security",
    "description": "Protecting network infrastructure",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Firewalls and VPNs",
        "content": "https://example.com/cyber-network.mp4",
        "type": "Video",
        "duration": 1500,
        "transcript": "[00:00] Network security safeguards data in transit.\\n[00:25] Firewalls filter incoming and outgoing traffic.\\n[00:50] VPNs encrypt connections for privacy.\\n[01:15] Proper configuration is critical for security."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Security Best Practices",
    "description": "Implementing security measures",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Password Security",
        "content": "https://example.com/cyber-passwords.mp4",
        "type": "Video",
        "duration": 1200,
        "transcript": "[00:00] Strong passwords are essential for account security.\\n[00:20] Use unique passwords for each service.\\n[00:40] Password managers simplify secure password use.\\n[01:00] Two-factor authentication adds extra protection."
      }
    ]
  }
]'::jsonb
WHERE title ILIKE '%Cybersecurity%';

-- ============================================
-- DESIGN COURSES
-- ============================================

-- Update Mobile App Design course
UPDATE courses
SET modules = '[
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Mobile UI/UX Principles",
    "description": "Design beautiful mobile interfaces",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Introduction to Mobile Design",
        "content": "https://example.com/mobile-design-intro.mp4",
        "type": "Video",
        "duration": 1300,
        "transcript": "[00:00] Mobile design requires special considerations.\\n[00:21] Screen size and touch interactions are unique.\\n[00:42] User experience is paramount on mobile.\\n[01:03] Let''s explore mobile design principles."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "iOS vs Android Design Guidelines",
        "content": "https://example.com/ios-android.mp4",
        "type": "Video",
        "duration": 1500,
        "transcript": "[00:00] iOS and Android have different design languages.\\n[00:25] Human Interface Guidelines govern iOS design.\\n[00:50] Material Design defines Android aesthetics.\\n[01:15] Understanding both creates better apps."
      }
    ]
  },
  {
    "id": "' || gen_random_uuid()::text || '",
    "title": "Prototyping & User Testing",
    "description": "Create and test mobile prototypes",
    "lessons": [
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "Creating Interactive Prototypes",
        "content": "https://example.com/prototyping.mp4",
        "type": "Video",
        "duration": 1700,
        "transcript": "[00:00] Prototypes bring designs to life interactively.\\n[00:28] Tools like Figma enable rapid prototyping.\\n[00:56] Test flows before writing code.\\n[01:24] Iteration improves design quality significantly."
      },
      {
        "id": "' || gen_random_uuid()::text || '",
        "title": "User Testing Methods",
        "content": "https://example.com/user-testing.mp4",
        "type": "Video",
        "duration": 1400,
        "transcript": "[00:00] User testing validates design decisions.\\n[00:23] Observe real users interacting with prototypes.\\n[00:46] Collect feedback and identify pain points.\\n[01:09] Data-driven design creates better products."
      }
    ]
  }
]'::jsonb
WHERE title ILIKE '%Mobile App Design%';

-- Verify the updates
SELECT 
    title, 
    category,
    jsonb_array_length(modules) as module_count,
    (SELECT COUNT(*) FROM jsonb_array_elements(modules) as m, jsonb_array_elements(m->'lessons') as l) as lesson_count
FROM courses
WHERE modules IS NOT NULL
ORDER BY category, title;
