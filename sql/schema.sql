-- =====================================================
-- SKILL-BASED INTERNSHIP & PROJECT MATCHING PLATFORM
-- Database Schema Design
-- =====================================================

-- Drop existing tables (in reverse order of dependencies)
DROP TABLE IF EXISTS Match_Result;
DROP TABLE IF EXISTS Applications;
DROP TABLE IF EXISTS Assessment;
DROP TABLE IF EXISTS Internship_Skills;
DROP TABLE IF EXISTS Student_Skills;
DROP TABLE IF EXISTS Internship;
DROP TABLE IF EXISTS Skills;
DROP TABLE IF EXISTS Recruiter;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Admin;

-- =====================================================
-- CORE USER TABLES
-- =====================================================

-- Admin Table
CREATE TABLE Admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

-- Student Table
CREATE TABLE Student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    college_name VARCHAR(200) NOT NULL,
    department VARCHAR(100) NOT NULL,
    year_of_study INT CHECK (year_of_study BETWEEN 1 AND 5),
    cgpa DECIMAL(3,2) CHECK (cgpa BETWEEN 0 AND 10),
    phone VARCHAR(15),
    resume_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    profile_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    profile_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_cgpa (cgpa),
    INDEX idx_department (department)
);

-- Recruiter Table
CREATE TABLE Recruiter (
    recruiter_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    company_website VARCHAR(500),
    designation VARCHAR(100),
    phone VARCHAR(15),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_company (company_name)
);

-- =====================================================
-- SKILLS MANAGEMENT
-- =====================================================

-- Skills Master Table
CREATE TABLE Skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL, -- e.g., Programming, Database, Web Dev, ML, Design
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category)
);

-- Student Skills (Many-to-Many with proficiency)
CREATE TABLE Student_Skills (
    student_skill_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') NOT NULL,
    years_of_experience DECIMAL(3,1) DEFAULT 0,
    certification_url VARCHAR(500),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id) ON DELETE CASCADE,
    UNIQUE KEY unique_student_skill (student_id, skill_id),
    INDEX idx_proficiency (proficiency_level)
);

-- =====================================================
-- INTERNSHIP/PROJECT MANAGEMENT
-- =====================================================

-- Internship/Project Table
CREATE TABLE Internship (
    internship_id INT PRIMARY KEY AUTO_INCREMENT,
    recruiter_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    type ENUM('Internship', 'Project', 'Both') NOT NULL,
    description TEXT NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    location VARCHAR(200),
    is_remote BOOLEAN DEFAULT FALSE,
    duration_months INT,
    stipend DECIMAL(10,2),
    minimum_cgpa DECIMAL(3,2) DEFAULT 0,
    preferred_year INT, -- Which year students are preferred
    application_deadline DATE NOT NULL,
    start_date DATE,
    max_positions INT DEFAULT 1,
    status ENUM('Open', 'Closed', 'Filled', 'Cancelled') DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (recruiter_id) REFERENCES Recruiter(recruiter_id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_deadline (application_deadline),
    INDEX idx_type (type)
);

-- Required Skills for Internship (Many-to-Many)
CREATE TABLE Internship_Skills (
    internship_skill_id INT PRIMARY KEY AUTO_INCREMENT,
    internship_id INT NOT NULL,
    skill_id INT NOT NULL,
    required_proficiency ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') NOT NULL,
    is_mandatory BOOLEAN DEFAULT TRUE, -- Some skills are preferred, not mandatory
    weightage INT DEFAULT 1, -- Importance of this skill (1-10)
    FOREIGN KEY (internship_id) REFERENCES Internship(internship_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id) ON DELETE CASCADE,
    UNIQUE KEY unique_internship_skill (internship_id, skill_id),
    CHECK (weightage BETWEEN 1 AND 10)
);

-- =====================================================
-- APPLICATION & ASSESSMENT
-- =====================================================

-- Applications Table
CREATE TABLE Applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    application_status ENUM('Applied', 'Under Review', 'Shortlisted', 'Rejected', 'Accepted', 'Withdrawn') DEFAULT 'Applied',
    cover_letter TEXT,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    status_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    recruiter_notes TEXT,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (internship_id) REFERENCES Internship(internship_id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (student_id, internship_id),
    INDEX idx_status (application_status),
    INDEX idx_applied_date (applied_at)
);

-- Assessment/Test Scores (Optional)
CREATE TABLE Assessment (
    assessment_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    assessment_type ENUM('Technical Test', 'Aptitude Test', 'Coding Challenge', 'Interview', 'Other') NOT NULL,
    score DECIMAL(5,2), -- Out of 100
    max_score DECIMAL(5,2) DEFAULT 100,
    feedback TEXT,
    assessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES Applications(application_id) ON DELETE CASCADE,
    INDEX idx_score (score)
);

-- =====================================================
-- MATCHING SYSTEM
-- =====================================================

-- Match Results (Pre-calculated matches for performance)
CREATE TABLE Match_Result (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    match_score DECIMAL(5,2) NOT NULL, -- Overall matching score (0-100)
    skill_match_score DECIMAL(5,2), -- Skill-based score
    cgpa_score DECIMAL(5,2), -- CGPA-based score
    experience_score DECIMAL(5,2), -- Experience-based score
    mandatory_skills_met BOOLEAN DEFAULT FALSE,
    total_skills_matched INT DEFAULT 0,
    total_skills_required INT DEFAULT 0,
    recommendation_rank INT, -- Rank for this internship
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (internship_id) REFERENCES Internship(internship_id) ON DELETE CASCADE,
    UNIQUE KEY unique_match (student_id, internship_id),
    INDEX idx_match_score (match_score),
    INDEX idx_rank (recommendation_rank)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Additional composite indexes for common queries
CREATE INDEX idx_student_active_cgpa ON Student(is_active, cgpa DESC);
CREATE INDEX idx_internship_status_deadline ON Internship(status, application_deadline);
CREATE INDEX idx_application_student_status ON Applications(student_id, application_status);
CREATE INDEX idx_application_internship_status ON Applications(internship_id, application_status);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View: Active Internships with Details
CREATE VIEW vw_active_internships AS
SELECT 
    i.*,
    r.company_name as recruiter_company,
    r.full_name as recruiter_name,
    COUNT(DISTINCT a.application_id) as total_applications,
    COUNT(DISTINCT isk.skill_id) as required_skills_count
FROM Internship i
JOIN Recruiter r ON i.recruiter_id = r.recruiter_id
LEFT JOIN Applications a ON i.internship_id = a.internship_id
LEFT JOIN Internship_Skills isk ON i.internship_id = isk.internship_id
WHERE i.status = 'Open' AND i.application_deadline >= CURDATE()
GROUP BY i.internship_id;

-- View: Student Profile Summary
CREATE VIEW vw_student_profile AS
SELECT 
    s.*,
    COUNT(DISTINCT ss.skill_id) as total_skills,
    COUNT(DISTINCT a.application_id) as total_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as accepted_applications
FROM Student s
LEFT JOIN Student_Skills ss ON s.student_id = ss.student_id
LEFT JOIN Applications a ON s.student_id = a.student_id
GROUP BY s.student_id;

-- =====================================================
-- INITIAL DATA SETUP
-- =====================================================

-- Insert Sample Skills
INSERT INTO Skills (skill_name, category, description) VALUES
-- Programming Languages
('Python', 'Programming', 'General-purpose programming language'),
('Java', 'Programming', 'Object-oriented programming language'),
('JavaScript', 'Programming', 'Web programming language'),
('C++', 'Programming', 'System programming language'),
('C', 'Programming', 'Low-level programming language'),
('Go', 'Programming', 'Concurrent programming language'),
('Rust', 'Programming', 'Systems programming language'),

-- Web Development
('React', 'Web Development', 'JavaScript library for UI'),
('Angular', 'Web Development', 'TypeScript-based web framework'),
('Node.js', 'Web Development', 'JavaScript runtime'),
('Django', 'Web Development', 'Python web framework'),
('Flask', 'Web Development', 'Python micro-framework'),
('HTML/CSS', 'Web Development', 'Web markup and styling'),
('REST API', 'Web Development', 'RESTful web services'),

-- Database
('MySQL', 'Database', 'Relational database management'),
('PostgreSQL', 'Database', 'Advanced relational database'),
('MongoDB', 'Database', 'NoSQL document database'),
('Redis', 'Database', 'In-memory data structure store'),
('Oracle DB', 'Database', 'Enterprise database system'),

-- Machine Learning & AI
('Machine Learning', 'AI/ML', 'ML algorithms and models'),
('Deep Learning', 'AI/ML', 'Neural networks'),
('TensorFlow', 'AI/ML', 'ML framework'),
('PyTorch', 'AI/ML', 'Deep learning framework'),
('NLP', 'AI/ML', 'Natural Language Processing'),
('Computer Vision', 'AI/ML', 'Image processing and analysis'),

-- Data Science
('Data Analysis', 'Data Science', 'Analyzing datasets'),
('Pandas', 'Data Science', 'Data manipulation library'),
('NumPy', 'Data Science', 'Numerical computing'),
('Tableau', 'Data Science', 'Data visualization tool'),
('Power BI', 'Data Science', 'Business intelligence'),

-- DevOps & Cloud
('Docker', 'DevOps', 'Containerization platform'),
('Kubernetes', 'DevOps', 'Container orchestration'),
('AWS', 'Cloud', 'Amazon Web Services'),
('Azure', 'Cloud', 'Microsoft cloud platform'),
('Git', 'DevOps', 'Version control system'),
('CI/CD', 'DevOps', 'Continuous Integration/Deployment'),

-- Mobile Development
('Android', 'Mobile', 'Android app development'),
('iOS', 'Mobile', 'iOS app development'),
('React Native', 'Mobile', 'Cross-platform mobile development'),
('Flutter', 'Mobile', 'Cross-platform mobile framework'),

-- Other
('System Design', 'Architecture', 'Designing scalable systems'),
('Agile', 'Methodology', 'Agile development methodology'),
('UI/UX Design', 'Design', 'User interface and experience design'),
('GraphQL', 'Web Development', 'Query language for APIs'),
('Blockchain', 'Emerging Tech', 'Distributed ledger technology');
