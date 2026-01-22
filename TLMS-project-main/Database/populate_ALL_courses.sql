-- Complete Course Population Script
-- Adds modules to ALL courses that currently have 0 modules
-- Uses real demo video URLs from publicly available sources

-- ============================================
-- BUSINESS COURSES
-- ============================================

-- Agile Project Management & Scrum
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Introduction to Agile',
    'description', 'Learn Agile methodology fundamentals',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(), 
        'title', 'What is Agile?', 
        'content', 'https://www.youtube.com/watch?v=Z9QbYZh1YXY', 
        'type', 'Video', 
        'duration', 600,
        'transcript', '[00:00] Welcome to the world of Agile.\n[00:15] Agile is more than just a set of rules.\n[00:30] It is about mindset and collaboration.\n[00:45] We will explore the Scrum framework today.'
      ),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Agile Principles', 'content', 'https://www.youtube.com/watch?v=GzzkpAOxHXs', 'type', 'Video', 'duration', 800)
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Scrum Framework',
    'description', 'Master the Scrum framework',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Scrum Basics', 'content', 'https://www.youtube.com/watch?v=XU0llRltyFM', 'type', 'Video', 'duration', 900),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Scrum Roles', 'type', 'Text', 'textContent', 'Scrum has three key roles: Product Owner, Scrum Master, and Development Team.')
    )
  )
)
WHERE title ILIKE 'Agile Project Management%' AND jsonb_array_length(modules) = 0;

-- Financial Analysis & Modeling
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Financial Statement Analysis',
    'description', 'Understand financial statements',
    'lessons', jsonb_build_array(
      jsonb_build_object(
        'id', gen_random_uuid(), 
        'title', 'Reading Financial Statements', 
        'content', 'https://www.youtube.com/watch?v=WEDIj9JBTC8', 
        'type', 'Video', 
        'duration', 1200,
        'transcript', '[00:00] Understanding financial statements is the bedrock of investing.\n[00:15] There are three main statements: Income, Balance Sheet, and Cash Flow.\n[00:30] The Income Statement shows profitability over a period.\n[00:45] The Balance Sheet shows resources and obligations at a single point in time.'
      ),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Ratio Analysis', 'type', 'Text', 'textContent', 'Key financial ratios include liquidity, profitability, and solvency ratios.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Financial Modeling',
    'description', 'Build financial models',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Excel for Finance', 'content', 'https://www.youtube.com/watch?v=rwbho0CgEAE', 'type', 'Video', 'duration', 1500)
    )
  )
)
WHERE title ILIKE 'Financial Analysis%' AND jsonb_array_length(modules) = 0;

-- Strategic Business Management
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Business Strategy Fundamentals',
    'description', 'Core strategy concepts',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Strategy Overview', 'content', 'https://www.youtube.com/watch?v=mJF8Jk709s8', 'type', 'Video', 'duration', 900),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Competitive Analysis', 'type', 'Text', 'textContent', 'Porter''s Five Forces is a framework for analyzing industry competition.')
    )
  )
)
WHERE title ILIKE 'Strategic Business%' AND jsonb_array_length(modules) = 0;

-- ============================================
-- DATA SCIENCE COURSES
-- ============================================

-- Advanced Machine Learning & AI
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Machine Learning Fundamentals',
    'description', 'Core ML concepts',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Introduction to ML', 'content', 'https://www.youtube.com/watch?v=ukzFI9rgwfU', 'type', 'Video', 'duration', 1200),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Supervised Learning', 'content', 'https://www.youtube.com/watch?v=1FZ0A1QCMWc', 'type', 'Video', 'duration', 1500)
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Deep Learning',
    'description', 'Neural networks and deep learning',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Neural Networks', 'content', 'https://www.youtube.com/watch?v=aircAruvnKk', 'type', 'Video', 'duration', 1800)
    )
  )
)
WHERE title ILIKE 'Advanced Machine Learning%' AND jsonb_array_length(modules) = 0;

-- Data Visualization with Tableau & D3.js
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Tableau Basics',
    'description', 'Getting started with Tableau',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Introduction to Tableau', 'content', 'https://www.youtube.com/watch?v=6xv1KvCMF1Q', 'type', 'Video', 'duration', 1000),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Creating Dashboards', 'type', 'Text', 'textContent', 'Dashboards combine multiple visualizations into a single view.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'D3.js Fundamentals',
    'description', 'Interactive data visualizations',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'D3.js Introduction', 'content', 'https://www.youtube.com/watch?v=_8V5o2UHG0E', 'type', 'Video', 'duration', 1200)
    )
  )
)
WHERE title ILIKE 'Data Visualization%' AND jsonb_array_length(modules) = 0;

-- Python for Data Science & Machine Learning
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Python for Data Science',
    'description', 'Python basics for data analysis',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Python Basics', 'content', 'https://www.youtube.com/watch?v=rfscVS0vtbw', 'type', 'Video', 'duration', 1400),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'NumPy and Pandas', 'content', 'https://www.youtube.com/watch?v=GPVsHOlRBBI', 'type', 'Video', 'duration', 1600)
    )
  )
)
WHERE title ILIKE 'Python for Data Science%' AND jsonb_array_length(modules) = 0;

-- ============================================
-- DESIGN COURSES
-- ============================================

-- Graphic Design Essentials
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Design Principles',
    'description', 'Fundamental design principles',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Color Theory', 'content', 'https://www.youtube.com/watch?v=_2LLXnUdUIc', 'type', 'Video', 'duration', 900),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Typography Basics', 'content', 'https://www.youtube.com/watch?v=sByzHoiYFX0', 'type', 'Video', 'duration', 800)
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Adobe Creative Suite',
    'description', 'Master design tools',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Photoshop Basics', 'content', 'https://www.youtube.com/watch?v=IyR_uYsRdPs', 'type', 'Video', 'duration', 1200)
    )
  )
)
WHERE title ILIKE 'Graphic Design%' AND jsonb_array_length(modules) = 0;

-- UI/UX Design Masterclass
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'UX Research',
    'description', 'User research methods',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'User Research Basics', 'content', 'https://www.youtube.com/watch?v=WpzmOH0hrEM', 'type', 'Video', 'duration', 1000),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Creating Personas', 'type', 'Text', 'textContent', 'User personas represent your target users based on research.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'UI Design',
    'description', 'User interface design',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Design Systems', 'content', 'https://www.youtube.com/watch?v=wc5krC28ynQ', 'type', 'Video', 'duration', 1100)
    )
  )
)
WHERE title ILIKE 'UI/UX Design%' AND jsonb_array_length(modules) = 0;

-- ============================================
-- PROGRAMMING COURSES
-- ============================================

-- Blockchain & Smart Contract Development
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Blockchain Fundamentals',
    'description', 'Understanding blockchain technology',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'What is Blockchain?', 'content', 'https://www.youtube.com/watch?v=SSo_EIwHSd4', 'type', 'Video', 'duration', 1000),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Cryptocurrency Basics', 'type', 'Text', 'textContent', 'Cryptocurrencies use blockchain for secure, decentralized transactions.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Smart Contracts',
    'description', 'Developing smart contracts',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Solidity Basics', 'content', 'https://www.youtube.com/watch?v=M576WGiDBdQ', 'type', 'Video', 'duration', 1500)
    )
  )
)
WHERE title ILIKE 'Blockchain%' AND jsonb_array_length(modules) = 0;

-- Complete iOS Development with Swift
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Swift Programming',
    'description', 'Learn Swift language',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Swift Basics', 'content', 'https://www.youtube.com/watch?v=Ulp1Kimblg0', 'type', 'Video', 'duration', 1300),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Swift Data Types', 'type', 'Text', 'textContent', 'Swift has strong typing with Int, Double, String, Bool, and more.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'UIKit Fundamentals',
    'description', 'Building iOS interfaces',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'UIKit Basics', 'content', 'https://www.youtube.com/watch?v=09TeUXjzpKs', 'type', 'Video', 'duration', 1400)
    )
  )
)
WHERE title ILIKE 'Complete iOS Development%' AND jsonb_array_length(modules) = 0;

-- Full Stack Web Development Bootcamp
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Frontend Fundamentals',
    'description', 'HTML, CSS, JavaScript',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'HTML & CSS Basics', 'content', 'https://www.youtube.com/watch?v=G3e-cpL7ofc', 'type', 'Video', 'duration', 1500),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'JavaScript Fundamentals', 'content', 'https://www.youtube.com/watch?v=W6NZfCO5SIk', 'type', 'Video', 'duration', 1800)
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Backend Development',
    'description', 'Server-side programming',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Node.js Basics', 'content', 'https://www.youtube.com/watch?v=TlB_eWDSMt4', 'type', 'Video', 'duration', 1600)
    )
  )
)
WHERE title ILIKE 'Full Stack%' AND jsonb_array_length(modules) = 0;

-- Unity Game Development
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Unity Basics',
    'description', 'Getting started with Unity',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Unity Interface', 'content', 'https://www.youtube.com/watch?v=pwZpJzpE2lQ', 'type', 'Video', 'duration', 1100),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'C# for Unity', 'type', 'Text', 'textContent', 'Unity uses C# as its primary scripting language.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', '2D Game Development',
    'description', 'Creating 2D games',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', '2D Sprites', 'content', 'https://www.youtube.com/watch?v=c0t6wOTLHlU', 'type', 'Video', 'duration', 1300)
    )
  )
)
WHERE title ILIKE 'Unity Game%' AND jsonb_array_length(modules) = 0;

-- ============================================
-- MUSIC & PHOTOGRAPHY
-- ============================================

-- Electronic Music Production with Ableton
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Ableton Live Basics',
    'description', 'Getting started with Ableton',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Ableton Interface', 'content', 'https://www.youtube.com/watch?v=RnuTbvVrBoY', 'type', 'Video', 'duration', 1200),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'MIDI Basics', 'type', 'Text', 'textContent', 'MIDI controls virtual instruments and synthesizers.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Sound Design',
    'description', 'Creating unique sounds',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Synthesis Basics', 'content', 'https://www.youtube.com/watch?v=atvtBE6t48M', 'type', 'Video', 'duration', 1400)
    )
  )
)
WHERE title ILIKE 'Electronic Music%' AND jsonb_array_length(modules) = 0;

-- Professional Photography
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Photography Fundamentals',
    'description', 'Camera basics and composition',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Camera Settings', 'content', 'https://www.youtube.com/watch?v=V7z7BAZdt2M', 'type', 'Video', 'duration', 1000),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Composition Rules', 'content', 'https://www.youtube.com/watch?v=xAx6lYXs-n8', 'type', 'Video', 'duration', 900)
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Photo Editing',
    'description', 'Post-processing techniques',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Lightroom Basics', 'content', 'https://www.youtube.com/watch?v=8q_M8F6TQdw', 'type', 'Video', 'duration', 1200)
    )
  )
)
WHERE title ILIKE 'Professional Photography%' AND jsonb_array_length(modules) = 0;

-- ============================================
-- MARKETING & WRITING
-- ============================================

-- Social Media Marketing Mastery
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Social Media Strategy',
    'description', 'Planning social campaigns',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Platform Overview', 'content', 'https://www.youtube.com/watch?v=7YFaWC3Dexw', 'type', 'Video', 'duration', 1100),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Content Planning', 'type', 'Text', 'textContent', 'Create a content calendar with diverse post types.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Social Media Advertising',
    'description', 'Paid social campaigns',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Facebook Ads', 'content', 'https://www.youtube.com/watch?v=hLDW1bC6eLQ', 'type', 'Video', 'duration', 1300)
    )
  )
)
WHERE title ILIKE 'Social Media Marketing%' AND jsonb_array_length(modules) = 0;

-- Creative Writing Workshop
UPDATE courses SET modules = jsonb_build_array(
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Writing Fundamentals',
    'description', 'Core writing skills',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Story Structure', 'content', 'https://www.youtube.com/watch?v=_n8TuRUT8h4', 'type', 'Video', 'duration', 1000),
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Character Development', 'type', 'Text', 'textContent', 'Create compelling characters with clear motivations and arcs.')
    )
  ),
  jsonb_build_object(
    'id', gen_random_uuid(),
    'title', 'Writing Practice',
    'description', 'Exercises and techniques',
    'lessons', jsonb_build_array(
      jsonb_build_object('id', gen_random_uuid(), 'title', 'Writing Exercises', 'type', 'Quiz', 'quizQuestions', jsonb_build_array())
    )
  )
)
WHERE title ILIKE 'Creative Writing%' AND jsonb_array_length(modules) = 0;

-- ============================================
-- VERIFY RESULTS
-- ============================================

SELECT 
    title, 
    category,
    jsonb_array_length(modules) as module_count,
    (SELECT COUNT(*) FROM jsonb_array_elements(modules) as m, jsonb_array_elements(m->'lessons') as l) as lesson_count
FROM courses
ORDER BY category, title;
