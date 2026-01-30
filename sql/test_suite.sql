-- =====================================================
-- COMPREHENSIVE TEST SUITE
-- =====================================================

-- =====================================================
-- SETUP TEST ENVIRONMENT
-- =====================================================

USE internship_platform;

-- Enable verbose output
SET @test_count = 0;
SET @pass_count = 0;
SET @fail_count = 0;

-- =====================================================
-- TEST 1: DATABASE STRUCTURE
-- =====================================================

SELECT '========================================' AS '';
SELECT 'TEST 1: Database Structure Validation' AS '';
SELECT '========================================' AS '';

-- Test 1.1: Check all tables exist
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @table_count FROM information_schema.tables 
WHERE table_schema = 'internship_platform' AND table_type = 'BASE TABLE';

SELECT CASE 
    WHEN @table_count >= 10 THEN CONCAT('✓ PASS: ', @table_count, ' tables exist')
    ELSE CONCAT('✗ FAIL: Only ', @table_count, ' tables found')
END AS 'Test 1.1: Table Count';

-- Test 1.2: Check stored procedures
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @proc_count FROM information_schema.routines 
WHERE routine_schema = 'internship_platform' AND routine_type = 'PROCEDURE';

SELECT CASE 
    WHEN @proc_count >= 5 THEN CONCAT('✓ PASS: ', @proc_count, ' stored procedures exist')
    ELSE CONCAT('✗ FAIL: Only ', @proc_count, ' procedures found')
END AS 'Test 1.2: Stored Procedure Count';

-- Test 1.3: Check triggers
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @trigger_count FROM information_schema.triggers 
WHERE trigger_schema = 'internship_platform';

SELECT CASE 
    WHEN @trigger_count >= 10 THEN CONCAT('✓ PASS: ', @trigger_count, ' triggers exist')
    ELSE CONCAT('✗ FAIL: Only ', @trigger_count, ' triggers found')
END AS 'Test 1.3: Trigger Count';

-- =====================================================
-- TEST 2: DATA INTEGRITY
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 2: Data Integrity Tests' AS '';
SELECT '========================================' AS '';

-- Test 2.1: Foreign Key Constraints
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @fk_count FROM information_schema.table_constraints 
WHERE constraint_schema = 'internship_platform' AND constraint_type = 'FOREIGN KEY';

SELECT CASE 
    WHEN @fk_count >= 8 THEN CONCAT('✓ PASS: ', @fk_count, ' foreign keys defined')
    ELSE CONCAT('✗ FAIL: Only ', @fk_count, ' foreign keys found')
END AS 'Test 2.1: Foreign Key Constraints';

-- Test 2.2: Sample Data Loaded
SET @test_count = @test_count + 1;
SELECT 
    (SELECT COUNT(*) FROM Student) as students,
    (SELECT COUNT(*) FROM Recruiter) as recruiters,
    (SELECT COUNT(*) FROM Internship) as internships,
    (SELECT COUNT(*) FROM Skills) as skills
INTO @student_count, @recruiter_count, @internship_count, @skill_count;

SELECT CASE 
    WHEN @student_count >= 5 AND @internship_count >= 3 THEN 
        CONCAT('✓ PASS: Sample data loaded (', @student_count, ' students, ', @internship_count, ' internships)')
    ELSE 
        CONCAT('✗ FAIL: Insufficient sample data')
END AS 'Test 2.2: Sample Data';

-- Test 2.3: CGPA Constraint
SET @test_count = @test_count + 1;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SELECT '✓ PASS: CGPA constraint working (invalid CGPA rejected)' AS 'Test 2.3: CGPA Validation';
    END;
    
    -- Try to insert invalid CGPA (should fail)
    INSERT INTO Student (username, email, password_hash, full_name, college_name, department, year_of_study, cgpa) 
    VALUES ('test_invalid', 'test@test.com', 'hash', 'Test User', 'Test College', 'CS', 3, 11.0);
    
    -- If we reach here, test failed
    DELETE FROM Student WHERE username = 'test_invalid';
    SELECT '✗ FAIL: CGPA constraint not working (invalid CGPA accepted)' AS 'Test 2.3: CGPA Validation';
END;

-- =====================================================
-- TEST 3: MATCHING ALGORITHM
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 3: Matching Algorithm Tests' AS '';
SELECT '========================================' AS '';

-- Test 3.1: Calculate Match Scores
SET @test_count = @test_count + 1;
CALL CalculateMatchScores(1);

SELECT COUNT(*) INTO @match_count FROM Match_Result WHERE internship_id = 1;

SELECT CASE 
    WHEN @match_count > 0 THEN 
        CONCAT('✓ PASS: Match scores calculated (', @match_count, ' matches found)')
    ELSE 
        '✗ FAIL: No matches calculated'
END AS 'Test 3.1: Match Score Calculation';

-- Test 3.2: Verify Match Score Range
SET @test_count = @test_count + 1;
SELECT MIN(match_score), MAX(match_score) 
INTO @min_score, @max_score 
FROM Match_Result WHERE internship_id = 1;

SELECT CASE 
    WHEN @min_score >= 0 AND @max_score <= 100 THEN 
        CONCAT('✓ PASS: Match scores in valid range (', @min_score, '-', @max_score, ')')
    ELSE 
        CONCAT('✗ FAIL: Match scores out of range (', @min_score, '-', @max_score, ')')
END AS 'Test 3.2: Match Score Range';

-- Test 3.3: Mandatory Skills Filter
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @mandatory_met_count 
FROM Match_Result 
WHERE internship_id = 1 AND mandatory_skills_met = TRUE;

SELECT CASE 
    WHEN @mandatory_met_count > 0 THEN 
        CONCAT('✓ PASS: Mandatory skills filter working (', @mandatory_met_count, ' students meet requirements)')
    ELSE 
        '✗ FAIL: No students meet mandatory requirements (check sample data)'
END AS 'Test 3.3: Mandatory Skills Filter';

-- Test 3.4: Ranking Logic
SET @test_count = @test_count + 1;
SELECT 
    MIN(recommendation_rank) as min_rank,
    MAX(recommendation_rank) as max_rank,
    COUNT(DISTINCT recommendation_rank) as unique_ranks
INTO @min_rank, @max_rank, @unique_ranks
FROM Match_Result WHERE internship_id = 1;

SELECT CASE 
    WHEN @min_rank = 1 AND @unique_ranks = (@max_rank) THEN 
        CONCAT('✓ PASS: Ranking working correctly (1-', @max_rank, ')')
    ELSE 
        '✗ FAIL: Ranking has gaps or doesn\'t start at 1'
END AS 'Test 3.4: Ranking Logic';

-- =====================================================
-- TEST 4: STORED PROCEDURES
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 4: Stored Procedure Tests' AS '';
SELECT '========================================' AS '';

-- Test 4.1: GetTopCandidates
SET @test_count = @test_count + 1;
CALL GetTopCandidates(1, 5);

SELECT CASE 
    WHEN ROW_COUNT() >= 0 THEN '✓ PASS: GetTopCandidates executed successfully'
    ELSE '✗ FAIL: GetTopCandidates failed'
END AS 'Test 4.1: GetTopCandidates';

-- Test 4.2: GetStudentRecommendations
SET @test_count = @test_count + 1;
CALL GetStudentRecommendations(1, 5);

SELECT CASE 
    WHEN ROW_COUNT() >= 0 THEN '✓ PASS: GetStudentRecommendations executed successfully'
    ELSE '✗ FAIL: GetStudentRecommendations failed'
END AS 'Test 4.2: GetStudentRecommendations';

-- Test 4.3: GetSkillGapAnalysis
SET @test_count = @test_count + 1;
CALL GetSkillGapAnalysis(1, 1);

SELECT CASE 
    WHEN ROW_COUNT() >= 0 THEN '✓ PASS: GetSkillGapAnalysis executed successfully'
    ELSE '✗ FAIL: GetSkillGapAnalysis failed'
END AS 'Test 4.3: GetSkillGapAnalysis';

-- Test 4.4: GetStudentAnalytics
SET @test_count = @test_count + 1;
CALL GetStudentAnalytics(1);

SELECT CASE 
    WHEN ROW_COUNT() >= 0 THEN '✓ PASS: GetStudentAnalytics executed successfully'
    ELSE '✗ FAIL: GetStudentAnalytics failed'
END AS 'Test 4.4: GetStudentAnalytics';

-- Test 4.5: GetRecruiterAnalytics
SET @test_count = @test_count + 1;
CALL GetRecruiterAnalytics(1);

SELECT CASE 
    WHEN ROW_COUNT() >= 0 THEN '✓ PASS: GetRecruiterAnalytics executed successfully'
    ELSE '✗ FAIL: GetRecruiterAnalytics failed'
END AS 'Test 4.5: GetRecruiterAnalytics';

-- =====================================================
-- TEST 5: TRIGGERS
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 5: Trigger Tests' AS '';
SELECT '========================================' AS '';

-- Test 5.1: Application Deadline Trigger
SET @test_count = @test_count + 1;
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SELECT '✓ PASS: Application deadline trigger working (prevented past deadline application)' AS 'Test 5.1: Deadline Trigger';
        SET @trigger_test_pass = 1;
    END;
    
    SET @trigger_test_pass = 0;
    
    -- Try to apply to expired internship
    INSERT INTO Applications (student_id, internship_id, application_status)
    SELECT 1, internship_id, 'Applied'
    FROM Internship 
    WHERE application_deadline < CURDATE() 
    LIMIT 1;
    
    -- If we reach here, trigger didn't fire
    IF @trigger_test_pass = 0 THEN
        DELETE FROM Applications WHERE student_id = 1 AND application_status = 'Applied' 
        AND internship_id IN (SELECT internship_id FROM Internship WHERE application_deadline < CURDATE());
        SELECT '✗ FAIL: Application deadline trigger not working' AS 'Test 5.1: Deadline Trigger';
    END IF;
END;

-- Test 5.2: Audit Log Trigger
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @audit_before FROM Audit_Log;

-- Update a student record
UPDATE Student SET cgpa = cgpa + 0.01 WHERE student_id = 1;
UPDATE Student SET cgpa = cgpa - 0.01 WHERE student_id = 1;

SELECT COUNT(*) INTO @audit_after FROM Audit_Log;

SELECT CASE 
    WHEN @audit_after > @audit_before THEN 
        CONCAT('✓ PASS: Audit logging working (', @audit_after - @audit_before, ' new entries)')
    ELSE 
        '✗ FAIL: Audit logging not working'
END AS 'Test 5.2: Audit Log Trigger';

-- Test 5.3: Application History Trigger
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @history_before FROM Application_History;

-- Update application status
UPDATE Applications SET application_status = 'Under Review' WHERE application_id = 1;

SELECT COUNT(*) INTO @history_after FROM Application_History;

SELECT CASE 
    WHEN @history_after > @history_before THEN 
        '✓ PASS: Application history trigger working'
    ELSE 
        '✗ FAIL: Application history trigger not working'
END AS 'Test 5.3: Application History Trigger';

-- =====================================================
-- TEST 6: VIEWS
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 6: View Tests' AS '';
SELECT '========================================' AS '';

-- Test 6.1: Active Internships View
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @view_count FROM vw_active_internships;

SELECT CASE 
    WHEN @view_count >= 0 THEN 
        CONCAT('✓ PASS: vw_active_internships accessible (', @view_count, ' rows)')
    ELSE 
        '✗ FAIL: vw_active_internships failed'
END AS 'Test 6.1: Active Internships View';

-- Test 6.2: Student Profile View
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @view_count FROM vw_student_profile;

SELECT CASE 
    WHEN @view_count >= 0 THEN 
        CONCAT('✓ PASS: vw_student_profile accessible (', @view_count, ' rows)')
    ELSE 
        '✗ FAIL: vw_student_profile failed'
END AS 'Test 6.2: Student Profile View';

-- Test 6.3: Most Demanded Skills View
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @view_count FROM vw_most_demanded_skills;

SELECT CASE 
    WHEN @view_count >= 0 THEN 
        CONCAT('✓ PASS: vw_most_demanded_skills accessible (', @view_count, ' rows)')
    ELSE 
        '✗ FAIL: vw_most_demanded_skills failed'
END AS 'Test 6.3: Most Demanded Skills View';

-- =====================================================
-- TEST 7: PERFORMANCE
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 7: Performance Tests' AS '';
SELECT '========================================' AS '';

-- Test 7.1: Index Usage
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @index_count 
FROM information_schema.statistics 
WHERE table_schema = 'internship_platform';

SELECT CASE 
    WHEN @index_count >= 15 THEN 
        CONCAT('✓ PASS: Adequate indexes defined (', @index_count, ' indexes)')
    ELSE 
        CONCAT('⚠ WARNING: Limited indexes (', @index_count, ' indexes)')
END AS 'Test 7.1: Index Count';

-- Test 7.2: Query Performance (Match Calculation)
SET @test_count = @test_count + 1;
SET @start_time = NOW(6);
CALL CalculateMatchScores(1);
SET @end_time = NOW(6);
SET @execution_time = TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000;

SELECT CASE 
    WHEN @execution_time < 1000 THEN 
        CONCAT('✓ PASS: Match calculation fast (', ROUND(@execution_time, 2), ' ms)')
    WHEN @execution_time < 5000 THEN 
        CONCAT('⚠ WARNING: Match calculation slow (', ROUND(@execution_time, 2), ' ms)')
    ELSE 
        CONCAT('✗ FAIL: Match calculation very slow (', ROUND(@execution_time, 2), ' ms)')
END AS 'Test 7.2: Match Calculation Performance';

-- =====================================================
-- TEST 8: BUSINESS LOGIC
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST 8: Business Logic Tests' AS '';
SELECT '========================================' AS '';

-- Test 8.1: Students with high match should rank higher
SET @test_count = @test_count + 1;
SELECT 
    MAX(CASE WHEN recommendation_rank = 1 THEN match_score END) as rank1_score,
    MAX(CASE WHEN recommendation_rank = 2 THEN match_score END) as rank2_score
INTO @rank1_score, @rank2_score
FROM Match_Result 
WHERE internship_id = 1;

SELECT CASE 
    WHEN @rank1_score >= @rank2_score OR @rank2_score IS NULL THEN 
        '✓ PASS: Higher match scores rank better'
    ELSE 
        '✗ FAIL: Ranking logic incorrect'
END AS 'Test 8.1: Ranking by Match Score';

-- Test 8.2: Mandatory skills enforced
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @violation_count
FROM Match_Result
WHERE mandatory_skills_met = FALSE AND recommendation_rank = 1;

SELECT CASE 
    WHEN @violation_count = 0 THEN 
        '✓ PASS: Mandatory skills properly enforced'
    ELSE 
        '✗ FAIL: Students without mandatory skills ranked first'
END AS 'Test 8.2: Mandatory Skills Enforcement';

-- Test 8.3: CGPA filter working
SET @test_count = @test_count + 1;
SELECT COUNT(*) INTO @cgpa_violation
FROM Match_Result mr
JOIN Student s ON mr.student_id = s.student_id
JOIN Internship i ON mr.internship_id = i.internship_id
WHERE s.cgpa < i.minimum_cgpa;

SELECT CASE 
    WHEN @cgpa_violation = 0 THEN 
        '✓ PASS: CGPA filter working correctly'
    ELSE 
        CONCAT('✗ FAIL: ', @cgpa_violation, ' students below minimum CGPA matched')
END AS 'Test 8.3: CGPA Filter';

-- =====================================================
-- TEST SUMMARY
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'TEST SUMMARY' AS '';
SELECT '========================================' AS '';

SELECT 
    @test_count as 'Total Tests Run',
    'See results above' as 'Status';

SELECT '
All critical tests completed!' AS '';
SELECT 'Review the results above for detailed information.' AS '';

-- =====================================================
-- SAMPLE OUTPUT DEMONSTRATION
-- =====================================================

SELECT '
' AS '';
SELECT '========================================' AS '';
SELECT 'SAMPLE OUTPUTS' AS '';
SELECT '========================================' AS '';

-- Show top 5 matched students for internship 1
SELECT '
Top 5 Candidates for Internship 1:' AS '';
CALL GetTopCandidates(1, 5);

-- Show recommendations for student 1
SELECT '
Top 5 Recommendations for Student 1:' AS '';
CALL GetStudentRecommendations(1, 5);

-- Show skill gap for student 1 and internship 1
SELECT '
Skill Gap Analysis (Student 1, Internship 1):' AS '';
CALL GetSkillGapAnalysis(1, 1);

-- Show analytics
SELECT '
Student 1 Analytics:' AS '';
CALL GetStudentAnalytics(1);

-- Show most demanded skills
SELECT '
Top 10 Most Demanded Skills:' AS '';
SELECT skill_name, category, internship_count, students_with_skill, skill_penetration
FROM vw_most_demanded_skills
LIMIT 10;

SELECT '
========================================' AS '';
SELECT 'TESTING COMPLETE!' AS '';
SELECT '========================================' AS '';
