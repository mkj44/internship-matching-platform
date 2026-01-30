-- =====================================================
-- MATCHING ALGORITHM & RANKING QUERIES
-- =====================================================

-- =====================================================
-- STORED PROCEDURE: Calculate Match Score
-- =====================================================

DELIMITER //

CREATE PROCEDURE CalculateMatchScores(IN p_internship_id INT)
BEGIN
    -- Clear previous match results for this internship
    DELETE FROM Match_Result WHERE internship_id = p_internship_id;
    
    -- Calculate and insert new match scores
    INSERT INTO Match_Result (
        student_id, 
        internship_id, 
        match_score, 
        skill_match_score, 
        cgpa_score, 
        experience_score,
        mandatory_skills_met,
        total_skills_matched,
        total_skills_required
    )
    SELECT 
        s.student_id,
        i.internship_id,
        -- Overall Match Score (weighted average)
        LEAST(100, (
            (COALESCE(skill_scores.skill_match_score, 0) * 0.60) +  -- 60% weightage to skills
            (COALESCE(cgpa_scores.cgpa_score, 0) * 0.25) +          -- 25% weightage to CGPA
            (COALESCE(exp_scores.experience_score, 0) * 0.15)       -- 15% weightage to experience
        )) as match_score,
        
        COALESCE(skill_scores.skill_match_score, 0) as skill_match_score,
        COALESCE(cgpa_scores.cgpa_score, 0) as cgpa_score,
        COALESCE(exp_scores.experience_score, 0) as experience_score,
        COALESCE(skill_scores.mandatory_met, FALSE) as mandatory_skills_met,
        COALESCE(skill_scores.matched_skills, 0) as total_skills_matched,
        skill_scores.total_required as total_skills_required
        
    FROM Student s
    CROSS JOIN Internship i
    
    -- Skill Match Calculation
    LEFT JOIN (
        SELECT 
            s.student_id,
            i.internship_id,
            -- Calculate weighted skill match score
            SUM(
                CASE 
                    -- Exact proficiency match or higher
                    WHEN (isk.required_proficiency = 'Beginner' AND ss.proficiency_level IN ('Beginner', 'Intermediate', 'Advanced', 'Expert')) THEN isk.weightage * 10
                    WHEN (isk.required_proficiency = 'Intermediate' AND ss.proficiency_level IN ('Intermediate', 'Advanced', 'Expert')) THEN isk.weightage * 10
                    WHEN (isk.required_proficiency = 'Advanced' AND ss.proficiency_level IN ('Advanced', 'Expert')) THEN isk.weightage * 10
                    WHEN (isk.required_proficiency = 'Expert' AND ss.proficiency_level = 'Expert') THEN isk.weightage * 10
                    
                    -- Partial match (one level below)
                    WHEN (isk.required_proficiency = 'Intermediate' AND ss.proficiency_level = 'Beginner') THEN isk.weightage * 5
                    WHEN (isk.required_proficiency = 'Advanced' AND ss.proficiency_level = 'Intermediate') THEN isk.weightage * 5
                    WHEN (isk.required_proficiency = 'Expert' AND ss.proficiency_level = 'Advanced') THEN isk.weightage * 5
                    
                    ELSE 0
                END
            ) * 100.0 / NULLIF(SUM(isk.weightage * 10), 0) as skill_match_score,
            
            COUNT(DISTINCT ss.skill_id) as matched_skills,
            COUNT(DISTINCT isk.skill_id) as total_required,
            
            -- Check if all mandatory skills are met
            CASE 
                WHEN COUNT(DISTINCT CASE WHEN isk.is_mandatory = TRUE THEN isk.skill_id END) = 
                     COUNT(DISTINCT CASE 
                         WHEN isk.is_mandatory = TRUE 
                         AND (
                             (isk.required_proficiency = 'Beginner' AND ss.proficiency_level IN ('Beginner', 'Intermediate', 'Advanced', 'Expert'))
                             OR (isk.required_proficiency = 'Intermediate' AND ss.proficiency_level IN ('Intermediate', 'Advanced', 'Expert'))
                             OR (isk.required_proficiency = 'Advanced' AND ss.proficiency_level IN ('Advanced', 'Expert'))
                             OR (isk.required_proficiency = 'Expert' AND ss.proficiency_level = 'Expert')
                         )
                         THEN isk.skill_id 
                     END)
                THEN TRUE
                ELSE FALSE
            END as mandatory_met
            
        FROM Student s
        CROSS JOIN Internship i
        INNER JOIN Internship_Skills isk ON i.internship_id = isk.internship_id
        LEFT JOIN Student_Skills ss ON s.student_id = ss.student_id AND isk.skill_id = ss.skill_id
        WHERE i.internship_id = p_internship_id
        GROUP BY s.student_id, i.internship_id
    ) skill_scores ON s.student_id = skill_scores.student_id AND i.internship_id = skill_scores.internship_id
    
    -- CGPA Score Calculation (normalized to 100)
    LEFT JOIN (
        SELECT 
            s.student_id,
            i.internship_id,
            CASE 
                WHEN s.cgpa >= i.minimum_cgpa THEN 
                    LEAST(100, ((s.cgpa - i.minimum_cgpa) / (10.0 - i.minimum_cgpa)) * 100)
                ELSE 0
            END as cgpa_score
        FROM Student s
        CROSS JOIN Internship i
        WHERE i.internship_id = p_internship_id
    ) cgpa_scores ON s.student_id = cgpa_scores.student_id AND i.internship_id = cgpa_scores.internship_id
    
    -- Experience Score (based on average years of experience in relevant skills)
    LEFT JOIN (
        SELECT 
            s.student_id,
            i.internship_id,
            LEAST(100, AVG(ss.years_of_experience) * 20) as experience_score
        FROM Student s
        CROSS JOIN Internship i
        INNER JOIN Internship_Skills isk ON i.internship_id = isk.internship_id
        INNER JOIN Student_Skills ss ON s.student_id = ss.student_id AND isk.skill_id = ss.skill_id
        WHERE i.internship_id = p_internship_id
        GROUP BY s.student_id, i.internship_id
    ) exp_scores ON s.student_id = exp_scores.student_id AND i.internship_id = exp_scores.internship_id
    
    WHERE i.internship_id = p_internship_id
    AND s.is_active = TRUE
    AND s.cgpa >= i.minimum_cgpa;
    
    -- Update recommendation ranks
    SET @rank = 0;
    UPDATE Match_Result mr
    INNER JOIN (
        SELECT 
            match_id,
            @rank := @rank + 1 as new_rank
        FROM Match_Result
        WHERE internship_id = p_internship_id
        ORDER BY 
            mandatory_skills_met DESC,
            match_score DESC,
            skill_match_score DESC
    ) ranked ON mr.match_id = ranked.match_id
    SET mr.recommendation_rank = ranked.new_rank
    WHERE mr.internship_id = p_internship_id;
    
END//

DELIMITER ;

-- =====================================================
-- FUNCTION: Get Proficiency Level Value (for comparison)
-- =====================================================

DELIMITER //

CREATE FUNCTION GetProficiencyValue(proficiency VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN CASE proficiency
        WHEN 'Beginner' THEN 1
        WHEN 'Intermediate' THEN 2
        WHEN 'Advanced' THEN 3
        WHEN 'Expert' THEN 4
        ELSE 0
    END;
END//

DELIMITER ;

-- =====================================================
-- COMMON QUERIES FOR THE MATCHING SYSTEM
-- =====================================================

-- Query 1: Get Top Matched Students for an Internship
-- Usage: Replace internship_id = 1 with desired internship
DELIMITER //
CREATE PROCEDURE GetTopCandidates(IN p_internship_id INT, IN p_limit INT)
BEGIN
    SELECT 
        s.student_id,
        s.full_name,
        s.email,
        s.department,
        s.year_of_study,
        s.cgpa,
        mr.match_score,
        mr.skill_match_score,
        mr.cgpa_score,
        mr.experience_score,
        mr.mandatory_skills_met,
        mr.total_skills_matched,
        mr.total_skills_required,
        mr.recommendation_rank,
        CASE 
            WHEN a.application_id IS NOT NULL THEN a.application_status
            ELSE 'Not Applied'
        END as application_status
    FROM Match_Result mr
    JOIN Student s ON mr.student_id = s.student_id
    LEFT JOIN Applications a ON s.student_id = a.student_id AND mr.internship_id = a.internship_id
    WHERE mr.internship_id = p_internship_id
    AND mr.mandatory_skills_met = TRUE
    ORDER BY mr.recommendation_rank
    LIMIT p_limit;
END//
DELIMITER ;

-- Query 2: Get Recommended Internships for a Student
DELIMITER //
CREATE PROCEDURE GetStudentRecommendations(IN p_student_id INT, IN p_limit INT)
BEGIN
    SELECT 
        i.internship_id,
        i.title,
        i.company_name,
        i.type,
        i.location,
        i.is_remote,
        i.duration_months,
        i.stipend,
        i.application_deadline,
        mr.match_score,
        mr.skill_match_score,
        mr.mandatory_skills_met,
        mr.total_skills_matched,
        mr.total_skills_required,
        CONCAT(mr.total_skills_matched, '/', mr.total_skills_required) as skills_ratio,
        CASE 
            WHEN a.application_id IS NOT NULL THEN a.application_status
            ELSE 'Not Applied'
        END as application_status
    FROM Match_Result mr
    JOIN Internship i ON mr.internship_id = i.internship_id
    LEFT JOIN Applications a ON mr.student_id = a.student_id AND mr.internship_id = a.internship_id
    WHERE mr.student_id = p_student_id
    AND i.status = 'Open'
    AND i.application_deadline >= CURDATE()
    ORDER BY 
        mr.mandatory_skills_met DESC,
        mr.match_score DESC
    LIMIT p_limit;
END//
DELIMITER ;

-- Query 3: Detailed Skill Gap Analysis
DELIMITER //
CREATE PROCEDURE GetSkillGapAnalysis(IN p_student_id INT, IN p_internship_id INT)
BEGIN
    SELECT 
        sk.skill_name,
        sk.category,
        isk.required_proficiency,
        isk.is_mandatory,
        isk.weightage,
        COALESCE(ss.proficiency_level, 'Not Available') as student_proficiency,
        COALESCE(ss.years_of_experience, 0) as student_experience,
        CASE 
            WHEN ss.skill_id IS NULL THEN 'Missing Skill'
            WHEN GetProficiencyValue(ss.proficiency_level) >= GetProficiencyValue(isk.required_proficiency) 
                THEN 'Meets Requirement'
            WHEN GetProficiencyValue(ss.proficiency_level) = GetProficiencyValue(isk.required_proficiency) - 1 
                THEN 'Close Match'
            ELSE 'Below Requirement'
        END as match_status
    FROM Internship_Skills isk
    JOIN Skills sk ON isk.skill_id = sk.skill_id
    LEFT JOIN Student_Skills ss ON isk.skill_id = ss.skill_id AND ss.student_id = p_student_id
    WHERE isk.internship_id = p_internship_id
    ORDER BY 
        isk.is_mandatory DESC,
        isk.weightage DESC,
        match_status;
END//
DELIMITER ;

-- Query 4: Student Analytics Dashboard
DELIMITER //
CREATE PROCEDURE GetStudentAnalytics(IN p_student_id INT)
BEGIN
    SELECT 
        s.full_name,
        s.department,
        s.year_of_study,
        s.cgpa,
        COUNT(DISTINCT ss.skill_id) as total_skills,
        COUNT(DISTINCT a.application_id) as total_applications,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Shortlisted' THEN a.application_id END) as shortlisted,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as accepted,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Rejected' THEN a.application_id END) as rejected,
        AVG(mr.match_score) as avg_match_score,
        MAX(mr.match_score) as best_match_score
    FROM Student s
    LEFT JOIN Student_Skills ss ON s.student_id = ss.student_id
    LEFT JOIN Applications a ON s.student_id = a.student_id
    LEFT JOIN Match_Result mr ON s.student_id = mr.student_id
    WHERE s.student_id = p_student_id
    GROUP BY s.student_id;
END//
DELIMITER ;

-- Query 5: Recruiter Analytics - Application Statistics
DELIMITER //
CREATE PROCEDURE GetRecruiterAnalytics(IN p_recruiter_id INT)
BEGIN
    SELECT 
        i.internship_id,
        i.title,
        i.company_name,
        i.status,
        i.max_positions,
        COUNT(DISTINCT a.application_id) as total_applications,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Shortlisted' THEN a.application_id END) as shortlisted_count,
        COUNT(DISTINCT CASE WHEN a.application_status = 'Accepted' THEN a.application_id END) as accepted_count,
        COUNT(DISTINCT mr.student_id) as total_matched_students,
        AVG(mr.match_score) as avg_match_score,
        DATEDIFF(i.application_deadline, CURDATE()) as days_remaining
    FROM Internship i
    LEFT JOIN Applications a ON i.internship_id = a.internship_id
    LEFT JOIN Match_Result mr ON i.internship_id = mr.internship_id AND mr.mandatory_skills_met = TRUE
    WHERE i.recruiter_id = p_recruiter_id
    GROUP BY i.internship_id
    ORDER BY i.created_at DESC;
END//
DELIMITER ;

-- Query 6: Most In-Demand Skills
CREATE VIEW vw_most_demanded_skills AS
SELECT 
    sk.skill_id,
    sk.skill_name,
    sk.category,
    COUNT(DISTINCT isk.internship_id) as internship_count,
    COUNT(DISTINCT CASE WHEN isk.is_mandatory = TRUE THEN isk.internship_id END) as mandatory_count,
    AVG(isk.weightage) as avg_weightage,
    COUNT(DISTINCT ss.student_id) as students_with_skill,
    CONCAT(ROUND((COUNT(DISTINCT ss.student_id) * 100.0 / (SELECT COUNT(*) FROM Student WHERE is_active = TRUE)), 1), '%') as skill_penetration
FROM Skills sk
LEFT JOIN Internship_Skills isk ON sk.skill_id = isk.skill_id
LEFT JOIN Internship i ON isk.internship_id = i.internship_id AND i.status = 'Open'
LEFT JOIN Student_Skills ss ON sk.skill_id = ss.skill_id
GROUP BY sk.skill_id
ORDER BY internship_count DESC, mandatory_count DESC;

-- Query 7: Skill Category Distribution
CREATE VIEW vw_skill_category_distribution AS
SELECT 
    sk.category,
    COUNT(DISTINCT sk.skill_id) as total_skills_in_category,
    COUNT(DISTINCT ss.student_id) as students_count,
    COUNT(DISTINCT isk.internship_id) as internships_requiring_category,
    AVG(CASE 
        WHEN ss.proficiency_level = 'Beginner' THEN 1
        WHEN ss.proficiency_level = 'Intermediate' THEN 2
        WHEN ss.proficiency_level = 'Advanced' THEN 3
        WHEN ss.proficiency_level = 'Expert' THEN 4
    END) as avg_proficiency_level
FROM Skills sk
LEFT JOIN Student_Skills ss ON sk.skill_id = ss.skill_id
LEFT JOIN Internship_Skills isk ON sk.skill_id = isk.skill_id
GROUP BY sk.category
ORDER BY students_count DESC;

-- =====================================================
-- EXAMPLE USAGE
-- =====================================================

-- Calculate matches for internship 1
-- CALL CalculateMatchScores(1);

-- Get top 10 candidates for internship 1
-- CALL GetTopCandidates(1, 10);

-- Get top 10 recommendations for student 1
-- CALL GetStudentRecommendations(1, 10);

-- Get skill gap analysis for student 1 and internship 1
-- CALL GetSkillGapAnalysis(1, 1);

-- Get analytics for student 1
-- CALL GetStudentAnalytics(1);

-- Get recruiter analytics
-- CALL GetRecruiterAnalytics(1);

-- View most in-demand skills
-- SELECT * FROM vw_most_demanded_skills LIMIT 20;
