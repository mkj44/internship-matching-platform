-- =====================================================
-- ADDITIONAL ANALYSIS QUERIES
-- =====================================================

-- =====================================================
-- ADVANCED QUERIES FOR INSIGHTS
-- =====================================================

-- Query 1: Find Students with Rare/Valuable Skills
SELECT 
    sk.skill_name,
    sk.category,
    COUNT(DISTINCT ss.student_id) as student_count,
    COUNT(DISTINCT isk.internship_id) as demand_count,
    ROUND(COUNT(DISTINCT isk.internship_id) * 1.0 / NULLIF(COUNT(DISTINCT ss.student_id), 0), 2) as demand_supply_ratio
FROM Skills sk
LEFT JOIN Student_Skills ss ON sk.skill_id = ss.skill_id
LEFT JOIN Internship_Skills isk ON sk.skill_id = isk.skill_id
INNER JOIN Internship i ON isk.internship_id = i.internship_id AND i.status = 'Open'
GROUP BY sk.skill_id
HAVING student_count > 0 AND demand_count > 0
ORDER BY demand_supply_ratio DESC
LIMIT 20;

-- Query 2: Students Who Should Apply (High Match but Not Applied)
SELECT 
    s.student_id,
    s.full_name,
    s.email,
    i.internship_id,
    i.title,
    i.company_name,
    mr.match_score,
    mr.mandatory_skills_met,
    i.application_deadline,
    DATEDIFF(i.application_deadline, CURDATE()) as days_left
FROM Match_Result mr
JOIN Student s ON mr.student_id = s.student_id
JOIN Internship i ON mr.internship_id = i.internship_id
LEFT JOIN Applications a ON s.student_id = a.student_id AND i.internship_id = a.internship_id
WHERE a.application_id IS NULL
AND mr.mandatory_skills_met = TRUE
AND mr.match_score >= 70
AND i.status = 'Open'
AND i.application_deadline >= CURDATE()
ORDER BY mr.match_score DESC, days_left;

-- Query 3: Internships with Low Application Rate
SELECT 
    i.internship_id,
    i.title,
    i.company_name,
    i.application_deadline,
    i.max_positions,
    COUNT(DISTINCT a.application_id) as applications_received,
    COUNT(DISTINCT mr.student_id) as eligible_students,
    ROUND((COUNT(DISTINCT a.application_id) * 100.0 / NULLIF(COUNT(DISTINCT mr.student_id), 0)), 1) as application_rate,
    DATEDIFF(i.application_deadline, CURDATE()) as days_remaining
FROM Internship i
LEFT JOIN Applications a ON i.internship_id = a.internship_id
LEFT JOIN Match_Result mr ON i.internship_id = mr.internship_id 
    AND mr.mandatory_skills_met = TRUE 
    AND mr.match_score >= 60
WHERE i.status = 'Open'
AND i.application_deadline >= CURDATE()
GROUP BY i.internship_id
HAVING eligible_students > 0
ORDER BY application_rate ASC;

-- Query 4: Student Skill Proficiency Distribution
SELECT 
    s.student_id,
    s.full_name,
    COUNT(DISTINCT CASE WHEN ss.proficiency_level = 'Expert' THEN ss.skill_id END) as expert_skills,
    COUNT(DISTINCT CASE WHEN ss.proficiency_level = 'Advanced' THEN ss.skill_id END) as advanced_skills,
    COUNT(DISTINCT CASE WHEN ss.proficiency_level = 'Intermediate' THEN ss.skill_id END) as intermediate_skills,
    COUNT(DISTINCT CASE WHEN ss.proficiency_level = 'Beginner' THEN ss.skill_id END) as beginner_skills,
    COUNT(DISTINCT ss.skill_id) as total_skills,
    s.cgpa,
    s.year_of_study
FROM Student s
LEFT JOIN Student_Skills ss ON s.student_id = ss.student_id
WHERE s.is_active = TRUE
GROUP BY s.student_id
ORDER BY expert_skills DESC, advanced_skills DESC, s.cgpa DESC;

-- Query 5: Companies and Their Skill Requirements
SELECT 
    i.company_name,
    COUNT(DISTINCT i.internship_id) as total_openings,
    COUNT(DISTINCT isk.skill_id) as unique_skills_required,
    GROUP_CONCAT(DISTINCT sk.skill_name ORDER BY sk.skill_name SEPARATOR ', ') as required_skills,
    AVG(i.stipend) as avg_stipend,
    AVG(i.minimum_cgpa) as avg_min_cgpa
FROM Internship i
JOIN Internship_Skills isk ON i.internship_id = isk.internship_id AND isk.is_mandatory = TRUE
JOIN Skills sk ON isk.skill_id = sk.skill_id
WHERE i.status = 'Open'
GROUP BY i.company_name
ORDER BY total_openings DESC;

-- Query 6: Application Success Rate by Student
SELECT 
    s.student_id,
    s.full_name,
    s.department,
    s.cgpa,
    COUNT(DISTINCT a.application_id) as total_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Shortlisted' THEN a.application_id END) as shortlisted,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as accepted,
    ROUND((COUNT(DISTINCT CASE WHEN a.application_status = 'Shortlisted' THEN a.application_id END) * 100.0 / 
           NULLIF(COUNT(DISTINCT a.application_id), 0)), 1) as shortlist_rate,
    ROUND((COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) * 100.0 / 
           NULLIF(COUNT(DISTINCT a.application_id), 0)), 1) as success_rate
FROM Student s
LEFT JOIN Applications a ON s.student_id = a.student_id
WHERE s.is_active = TRUE
GROUP BY s.student_id
HAVING total_applications > 0
ORDER BY success_rate DESC, shortlist_rate DESC;

-- Query 7: Department-wise Performance Analysis
SELECT 
    s.department,
    COUNT(DISTINCT s.student_id) as total_students,
    ROUND(AVG(s.cgpa), 2) as avg_cgpa,
    ROUND(AVG(skill_counts.skill_count), 1) as avg_skills_per_student,
    COUNT(DISTINCT a.application_id) as total_applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as total_accepted,
    ROUND((COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) * 100.0 / 
           NULLIF(COUNT(DISTINCT a.application_id), 0)), 1) as acceptance_rate
FROM Student s
LEFT JOIN Applications a ON s.student_id = a.student_id
LEFT JOIN (
    SELECT student_id, COUNT(DISTINCT skill_id) as skill_count
    FROM Student_Skills
    GROUP BY student_id
) skill_counts ON s.student_id = skill_counts.student_id
WHERE s.is_active = TRUE
GROUP BY s.department
ORDER BY acceptance_rate DESC;

-- Query 8: Time-based Application Trends
SELECT 
    DATE_FORMAT(a.applied_at, '%Y-%m') as month,
    COUNT(DISTINCT a.application_id) as total_applications,
    COUNT(DISTINCT a.student_id) as unique_students,
    COUNT(DISTINCT a.internship_id) as unique_internships,
    ROUND(AVG(s.cgpa), 2) as avg_applicant_cgpa
FROM Applications a
JOIN Student s ON a.student_id = s.student_id
GROUP BY DATE_FORMAT(a.applied_at, '%Y-%m')
ORDER BY month DESC;

-- Query 9: Skill Combinations that Lead to Success
SELECT 
    GROUP_CONCAT(DISTINCT sk.skill_name ORDER BY sk.skill_name SEPARATOR ' + ') as skill_combination,
    COUNT(DISTINCT s.student_id) as student_count,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as acceptances,
    ROUND((COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) * 100.0 / 
           NULLIF(COUNT(DISTINCT a.application_id), 0)), 1) as success_rate
FROM Student s
JOIN Student_Skills ss ON s.student_id = ss.student_id
JOIN Skills sk ON ss.skill_id = sk.skill_id
LEFT JOIN Applications a ON s.student_id = a.student_id
WHERE ss.proficiency_level IN ('Advanced', 'Expert')
GROUP BY s.student_id
HAVING COUNT(DISTINCT sk.skill_id) >= 2 AND COUNT(DISTINCT a.application_id) > 0
ORDER BY success_rate DESC
LIMIT 20;

-- Query 10: Identify Over-qualified and Under-qualified Applications
SELECT 
    a.application_id,
    s.full_name as student_name,
    i.title as internship_title,
    s.cgpa,
    i.minimum_cgpa,
    mr.match_score,
    mr.skill_match_score,
    mr.total_skills_matched,
    mr.total_skills_required,
    a.application_status,
    CASE 
        WHEN mr.match_score >= 90 AND s.cgpa > i.minimum_cgpa + 1 THEN 'Over-qualified'
        WHEN mr.match_score < 60 OR NOT mr.mandatory_skills_met THEN 'Under-qualified'
        ELSE 'Good Match'
    END as qualification_status
FROM Applications a
JOIN Student s ON a.student_id = s.student_id
JOIN Internship i ON a.internship_id = i.internship_id
LEFT JOIN Match_Result mr ON a.student_id = mr.student_id AND a.internship_id = mr.internship_id
ORDER BY a.applied_at DESC;

-- =====================================================
-- REPORTING QUERIES
-- =====================================================

-- Report 1: Platform Summary Dashboard
SELECT 
    (SELECT COUNT(*) FROM Student WHERE is_active = TRUE) as total_active_students,
    (SELECT COUNT(*) FROM Recruiter WHERE is_verified = TRUE) as total_verified_recruiters,
    (SELECT COUNT(*) FROM Internship WHERE status = 'Open') as total_open_positions,
    (SELECT COUNT(*) FROM Applications WHERE application_status = 'Applied') as pending_applications,
    (SELECT COUNT(*) FROM Applications WHERE application_status = 'Accepted') as total_placements,
    (SELECT COUNT(DISTINCT skill_id) FROM Skills) as total_skills_available,
    (SELECT ROUND(AVG(match_score), 2) FROM Match_Result WHERE mandatory_skills_met = TRUE) as avg_match_quality;

-- Report 2: Top Performing Students
SELECT 
    s.student_id,
    s.full_name,
    s.department,
    s.year_of_study,
    s.cgpa,
    COUNT(DISTINCT ss.skill_id) as total_skills,
    COUNT(DISTINCT CASE WHEN ss.proficiency_level IN ('Advanced', 'Expert') THEN ss.skill_id END) as advanced_skills,
    COUNT(DISTINCT a.application_id) as applications,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as acceptances,
    ROUND(AVG(mr.match_score), 2) as avg_match_score
FROM Student s
LEFT JOIN Student_Skills ss ON s.student_id = ss.student_id
LEFT JOIN Applications a ON s.student_id = a.student_id
LEFT JOIN Match_Result mr ON s.student_id = mr.student_id
WHERE s.is_active = TRUE
GROUP BY s.student_id
ORDER BY acceptances DESC, avg_match_score DESC, s.cgpa DESC
LIMIT 10;

-- Report 3: Most Competitive Internships
SELECT 
    i.internship_id,
    i.title,
    i.company_name,
    i.stipend,
    i.max_positions,
    COUNT(DISTINCT a.application_id) as total_applications,
    ROUND(COUNT(DISTINCT a.application_id) * 1.0 / i.max_positions, 2) as competition_ratio,
    ROUND(AVG(mr.match_score), 2) as avg_applicant_match,
    COUNT(DISTINCT CASE WHEN a.application_status = 'Shortlisted' THEN a.application_id END) as shortlisted
FROM Internship i
LEFT JOIN Applications a ON i.internship_id = a.internship_id
LEFT JOIN Match_Result mr ON i.internship_id = mr.internship_id AND mr.student_id = a.student_id
WHERE i.status = 'Open'
GROUP BY i.internship_id
ORDER BY competition_ratio DESC
LIMIT 10;

-- Report 4: Skills Gap Analysis (Platform-wide)
SELECT 
    sk.skill_name,
    sk.category,
    COUNT(DISTINCT isk.internship_id) as required_by_internships,
    COUNT(DISTINCT ss.student_id) as students_having_skill,
    COUNT(DISTINCT isk.internship_id) - COUNT(DISTINCT ss.student_id) as gap,
    CASE 
        WHEN COUNT(DISTINCT ss.student_id) = 0 THEN 'Critical Gap'
        WHEN COUNT(DISTINCT isk.internship_id) > COUNT(DISTINCT ss.student_id) * 2 THEN 'High Gap'
        WHEN COUNT(DISTINCT isk.internship_id) > COUNT(DISTINCT ss.student_id) THEN 'Moderate Gap'
        ELSE 'Sufficient Supply'
    END as gap_status
FROM Skills sk
JOIN Internship_Skills isk ON sk.skill_id = isk.skill_id
JOIN Internship i ON isk.internship_id = i.internship_id AND i.status = 'Open'
LEFT JOIN Student_Skills ss ON sk.skill_id = ss.skill_id 
    AND ss.proficiency_level IN ('Advanced', 'Expert')
GROUP BY sk.skill_id
ORDER BY gap DESC;

-- Report 5: Monthly Platform Activity
SELECT 
    DATE_FORMAT(CURDATE(), '%Y-%m') as current_month,
    (SELECT COUNT(*) FROM Applications WHERE DATE_FORMAT(applied_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')) as applications_this_month,
    (SELECT COUNT(*) FROM Internship WHERE DATE_FORMAT(created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')) as new_positions_this_month,
    (SELECT COUNT(*) FROM Student WHERE DATE_FORMAT(profile_created_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')) as new_students_this_month,
    (SELECT COUNT(*) FROM Applications WHERE application_status = 'Accepted' AND DATE_FORMAT(status_updated_at, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')) as placements_this_month;
