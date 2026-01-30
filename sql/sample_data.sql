-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert Admins
INSERT INTO Admin (username, email, password_hash, full_name) VALUES
('admin1', 'admin@college.edu', 'hashed_password_1', 'System Administrator'),
('admin2', 'admin2@college.edu', 'hashed_password_2', 'Database Administrator');

-- Insert Students
INSERT INTO Student (username, email, password_hash, full_name, college_name, department, year_of_study, cgpa, phone) VALUES
('john_doe', 'john.doe@student.edu', 'hash1', 'John Doe', 'MIT College', 'Computer Science', 3, 8.5, '+1234567890'),
('jane_smith', 'jane.smith@student.edu', 'hash2', 'Jane Smith', 'MIT College', 'Information Technology', 4, 9.2, '+1234567891'),
('mike_johnson', 'mike.j@student.edu', 'hash3', 'Mike Johnson', 'MIT College', 'Computer Science', 2, 7.8, '+1234567892'),
('sarah_williams', 'sarah.w@student.edu', 'hash4', 'Sarah Williams', 'MIT College', 'Data Science', 3, 8.9, '+1234567893'),
('alex_brown', 'alex.b@student.edu', 'hash5', 'Alex Brown', 'MIT College', 'Computer Science', 4, 9.0, '+1234567894'),
('emily_davis', 'emily.d@student.edu', 'hash6', 'Emily Davis', 'MIT College', 'Information Technology', 2, 7.5, '+1234567895'),
('chris_wilson', 'chris.w@student.edu', 'hash7', 'Chris Wilson', 'MIT College', 'Computer Science', 3, 8.7, '+1234567896'),
('lisa_taylor', 'lisa.t@student.edu', 'hash8', 'Lisa Taylor', 'MIT College', 'Data Science', 4, 9.3, '+1234567897'),
('david_moore', 'david.m@student.edu', 'hash9', 'David Moore', 'MIT College', 'Computer Science', 3, 8.2, '+1234567898'),
('anna_lee', 'anna.l@student.edu', 'hash10', 'Anna Lee', 'MIT College', 'Information Technology', 2, 8.0, '+1234567899');

-- Insert Recruiters
INSERT INTO Recruiter (username, email, password_hash, full_name, company_name, designation, is_verified) VALUES
('recruiter_google', 'hr@google.com', 'hash_r1', 'Robert Anderson', 'Google Inc.', 'Technical Recruiter', TRUE),
('recruiter_microsoft', 'hr@microsoft.com', 'hash_r2', 'Maria Garcia', 'Microsoft Corporation', 'HR Manager', TRUE),
('recruiter_amazon', 'hr@amazon.com', 'hash_r3', 'James Martinez', 'Amazon', 'Talent Acquisition', TRUE),
('recruiter_meta', 'hr@meta.com', 'hash_r4', 'Jennifer Lopez', 'Meta Platforms', 'Recruiting Lead', TRUE),
('recruiter_startup', 'hr@techstartup.com', 'hash_r5', 'Kevin Chen', 'TechStartup Inc.', 'Co-founder', TRUE);

-- Insert Student Skills (with varying proficiency levels)
INSERT INTO Student_Skills (student_id, skill_id, proficiency_level, years_of_experience) VALUES
-- John Doe (Strong in Web Dev & Python)
(1, 1, 'Advanced', 2.0),  -- Python
(1, 3, 'Advanced', 2.5),  -- JavaScript
(1, 8, 'Advanced', 2.0),  -- React
(1, 10, 'Intermediate', 1.5), -- Node.js
(1, 15, 'Advanced', 2.0), -- MySQL
(1, 35, 'Intermediate', 1.0), -- Git

-- Jane Smith (Full Stack + ML)
(2, 1, 'Expert', 3.0),    -- Python
(2, 3, 'Advanced', 2.5),  -- JavaScript
(2, 8, 'Expert', 3.0),    -- React
(2, 11, 'Advanced', 2.0), -- Django
(2, 15, 'Advanced', 2.5), -- MySQL
(2, 20, 'Advanced', 2.0), -- Machine Learning
(2, 35, 'Advanced', 2.5), -- Git

-- Mike Johnson (Beginner, learning fundamentals)
(3, 1, 'Beginner', 0.5),  -- Python
(3, 2, 'Intermediate', 1.0), -- Java
(3, 13, 'Beginner', 0.5), -- HTML/CSS
(3, 15, 'Beginner', 0.5), -- MySQL

-- Sarah Williams (Data Science focused)
(4, 1, 'Expert', 3.5),    -- Python
(4, 20, 'Advanced', 2.0), -- Machine Learning
(4, 22, 'Advanced', 2.0), -- TensorFlow
(4, 26, 'Advanced', 2.5), -- Data Analysis
(4, 27, 'Advanced', 2.0), -- Pandas
(4, 28, 'Advanced', 2.0), -- NumPy
(4, 15, 'Intermediate', 1.5), -- MySQL

-- Alex Brown (Strong all-rounder)
(5, 1, 'Advanced', 2.5),  -- Python
(5, 2, 'Advanced', 2.0),  -- Java
(5, 3, 'Advanced', 2.5),  -- JavaScript
(5, 8, 'Advanced', 2.0),  -- React
(5, 15, 'Advanced', 2.0), -- MySQL
(5, 17, 'Intermediate', 1.5), -- MongoDB
(5, 31, 'Advanced', 2.0), -- Docker
(5, 33, 'Intermediate', 1.5), -- AWS

-- Emily Davis (Mobile Development)
(6, 2, 'Intermediate', 1.5), -- Java
(6, 3, 'Intermediate', 1.0), -- JavaScript
(6, 37, 'Advanced', 2.0), -- Android
(6, 39, 'Intermediate', 1.5), -- React Native

-- Chris Wilson (Backend focused)
(7, 1, 'Advanced', 2.5),  -- Python
(7, 11, 'Advanced', 2.0), -- Django
(7, 14, 'Advanced', 2.0), -- REST API
(7, 15, 'Expert', 3.0),   -- MySQL
(7, 16, 'Advanced', 2.0), -- PostgreSQL
(7, 31, 'Advanced', 2.0), -- Docker

-- Lisa Taylor (AI/ML Expert)
(8, 1, 'Expert', 4.0),    -- Python
(8, 20, 'Expert', 3.5),   -- Machine Learning
(8, 21, 'Advanced', 2.5), -- Deep Learning
(8, 22, 'Expert', 3.0),   -- TensorFlow
(8, 23, 'Advanced', 2.0), -- PyTorch
(8, 24, 'Advanced', 2.5), -- NLP
(8, 25, 'Advanced', 2.0), -- Computer Vision

-- David Moore (DevOps)
(9, 1, 'Intermediate', 1.5), -- Python
(9, 31, 'Advanced', 2.5), -- Docker
(9, 32, 'Advanced', 2.0), -- Kubernetes
(9, 33, 'Advanced', 2.5), -- AWS
(9, 35, 'Expert', 3.0),   -- Git
(9, 36, 'Advanced', 2.0), -- CI/CD

-- Anna Lee (UI/UX + Frontend)
(10, 3, 'Advanced', 2.0), -- JavaScript
(10, 8, 'Advanced', 2.5), -- React
(10, 13, 'Expert', 3.0),  -- HTML/CSS
(10, 43, 'Advanced', 2.5); -- UI/UX Design

-- Insert Internships
INSERT INTO Internship (recruiter_id, title, type, description, company_name, location, is_remote, 
                        duration_months, stipend, minimum_cgpa, preferred_year, application_deadline, start_date, max_positions, status) 
VALUES
(1, 'Software Engineering Intern', 'Internship', 
 'Work on cutting-edge web technologies and contribute to Google products', 
 'Google Inc.', 'Mountain View, CA', TRUE, 6, 8000.00, 8.0, 3, '2026-03-15', '2026-06-01', 5, 'Open'),

(2, 'Machine Learning Research Intern', 'Internship',
 'Research and develop ML models for Microsoft Azure services',
 'Microsoft Corporation', 'Redmond, WA', FALSE, 6, 7500.00, 8.5, 4, '2026-03-20', '2026-06-15', 3, 'Open'),

(3, 'Full Stack Developer Intern', 'Internship',
 'Build scalable web applications for Amazon retail platform',
 'Amazon', 'Seattle, WA', TRUE, 3, 6500.00, 7.5, 3, '2026-03-10', '2026-05-20', 8, 'Open'),

(4, 'Data Science Intern', 'Internship',
 'Analyze user data and build recommendation systems',
 'Meta Platforms', 'Menlo Park, CA', FALSE, 6, 8500.00, 8.5, 4, '2026-03-25', '2026-06-10', 4, 'Open'),

(5, 'Mobile App Development Project', 'Project',
 'Build a cross-platform mobile application for food delivery',
 'TechStartup Inc.', 'Remote', TRUE, 4, 3000.00, 7.0, 2, '2026-02-28', '2026-04-01', 2, 'Open'),

(1, 'Cloud Infrastructure Intern', 'Internship',
 'Work with Google Cloud Platform and infrastructure automation',
 'Google Inc.', 'Remote', TRUE, 6, 7800.00, 8.0, 3, '2026-03-18', '2026-06-05', 4, 'Open'),

(2, 'Backend Development Intern', 'Internship',
 'Develop REST APIs and microservices using .NET and Azure',
 'Microsoft Corporation', 'Bangalore, India', FALSE, 6, 5000.00, 7.8, 3, '2026-03-12', '2026-05-25', 6, 'Open');

-- Insert Required Skills for Internships
INSERT INTO Internship_Skills (internship_id, skill_id, required_proficiency, is_mandatory, weightage) VALUES
-- Internship 1: Google Software Engineering (Web focused)
(1, 3, 'Advanced', TRUE, 10),   -- JavaScript
(1, 8, 'Advanced', TRUE, 10),   -- React
(1, 1, 'Intermediate', TRUE, 8), -- Python
(1, 15, 'Intermediate', TRUE, 7), -- MySQL
(1, 14, 'Intermediate', FALSE, 6), -- REST API
(1, 35, 'Intermediate', TRUE, 5), -- Git

-- Internship 2: Microsoft ML Research
(2, 1, 'Advanced', TRUE, 10),   -- Python
(2, 20, 'Advanced', TRUE, 10),  -- Machine Learning
(2, 22, 'Advanced', TRUE, 9),   -- TensorFlow
(2, 23, 'Intermediate', FALSE, 7), -- PyTorch
(2, 27, 'Advanced', TRUE, 8),   -- Pandas
(2, 28, 'Advanced', TRUE, 7),   -- NumPy

-- Internship 3: Amazon Full Stack
(3, 3, 'Intermediate', TRUE, 9),  -- JavaScript
(3, 8, 'Intermediate', TRUE, 8),  -- React
(3, 10, 'Intermediate', TRUE, 8), -- Node.js
(3, 15, 'Intermediate', TRUE, 7), -- MySQL
(3, 31, 'Beginner', FALSE, 5),   -- Docker
(3, 35, 'Intermediate', TRUE, 6), -- Git

-- Internship 4: Meta Data Science
(4, 1, 'Expert', TRUE, 10),     -- Python
(4, 20, 'Advanced', TRUE, 10),  -- Machine Learning
(4, 26, 'Advanced', TRUE, 9),   -- Data Analysis
(4, 27, 'Advanced', TRUE, 8),   -- Pandas
(4, 15, 'Intermediate', TRUE, 7), -- MySQL
(4, 29, 'Intermediate', FALSE, 6), -- Tableau

-- Internship 5: TechStartup Mobile Project
(5, 39, 'Intermediate', TRUE, 10), -- React Native
(5, 3, 'Intermediate', TRUE, 8),   -- JavaScript
(5, 14, 'Beginner', FALSE, 6),     -- REST API

-- Internship 6: Google Cloud Infrastructure
(6, 33, 'Advanced', TRUE, 10),   -- AWS
(6, 31, 'Advanced', TRUE, 9),    -- Docker
(6, 32, 'Intermediate', TRUE, 8), -- Kubernetes
(6, 1, 'Intermediate', TRUE, 7),  -- Python
(6, 36, 'Intermediate', TRUE, 7), -- CI/CD

-- Internship 7: Microsoft Backend
(7, 1, 'Advanced', TRUE, 9),     -- Python
(7, 11, 'Advanced', TRUE, 10),   -- Django
(7, 14, 'Advanced', TRUE, 9),    -- REST API
(7, 15, 'Advanced', TRUE, 8),    -- MySQL
(7, 16, 'Intermediate', FALSE, 6), -- PostgreSQL
(7, 31, 'Intermediate', FALSE, 5); -- Docker

-- Insert some Applications
INSERT INTO Applications (student_id, internship_id, application_status, cover_letter) VALUES
(1, 1, 'Applied', 'I am passionate about web development and have 2 years of React experience.'),
(2, 1, 'Shortlisted', 'I have extensive full-stack experience and would love to contribute to Google.'),
(2, 2, 'Applied', 'My ML research background makes me perfect for this role.'),
(4, 2, 'Shortlisted', 'I have published research in ML and have strong Python skills.'),
(4, 4, 'Applied', 'Data science is my passion and I have worked on multiple recommendation systems.'),
(5, 1, 'Applied', 'I am a versatile developer with strong fundamentals.'),
(5, 3, 'Under Review', 'My experience with both frontend and backend makes me suitable.'),
(7, 7, 'Shortlisted', 'Backend development is my specialty with Django expertise.'),
(8, 2, 'Accepted', 'I have extensive AI/ML research experience.'),
(9, 6, 'Applied', 'DevOps and cloud infrastructure are my core strengths.'),
(10, 3, 'Applied', 'I can contribute to frontend development with my React skills.');

-- Insert Assessment Scores
INSERT INTO Assessment (application_id, assessment_type, score, max_score, feedback) VALUES
(2, 'Technical Test', 92.0, 100, 'Excellent problem-solving skills'),
(2, 'Coding Challenge', 88.0, 100, 'Clean and efficient code'),
(4, 'Technical Test', 95.0, 100, 'Outstanding ML knowledge'),
(8, 'Coding Challenge', 90.0, 100, 'Great Django implementation'),
(9, 'Technical Test', 98.0, 100, 'Exceptional ML expertise'),
(9, 'Interview', 96.0, 100, 'Perfect fit for the role');
