# Quick Start Guide
## Skill-Based Internship & Project Matching Platform

---

## ⚡ 5-Minute Setup

### Step 1: Prerequisites Check
```bash
# Check if MySQL is installed
mysql --version

# You should see something like: mysql  Ver 8.0.x
```

### Step 2: Create Database
```bash
# Login to MySQL
mysql -u root -p

# In MySQL prompt, run:
CREATE DATABASE internship_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE internship_platform;
```

### Step 3: One-Command Setup
```bash
# Exit MySQL and run all scripts in order:
cd /path/to/project

# Run all SQL files in sequence
mysql -u root -p internship_platform < schema.sql
mysql -u root -p internship_platform < sample_data.sql
mysql -u root -p internship_platform < matching_algorithm.sql
mysql -u root -p internship_platform < triggers.sql
mysql -u root -p internship_platform < analysis_queries.sql
```

### Step 4: Verify Installation
```bash
# Run test suite
mysql -u root -p internship_platform < test_suite.sql

# You should see green checkmarks (✓) for passing tests
```

---

## 🚀 First Usage Examples

### Example 1: Calculate Matches for an Internship
```sql
USE internship_platform;

-- Calculate matches for Google Software Engineering Internship (ID: 1)
CALL CalculateMatchScores(1);

-- View top 10 matched candidates
CALL GetTopCandidates(1, 10);
```

**Expected Output:**
```
+------------+-------------+-------+------+------------+-------------+...
| student_id | full_name   | email | cgpa | match_score| rank        |...
+------------+-------------+-------+------+------------+-------------+...
| 2          | Jane Smith  | ...   | 9.2  | 95.50      | 1           |...
| 5          | Alex Brown  | ...   | 9.0  | 88.75      | 2           |...
+------------+-------------+-------+------+------------+-------------+...
```

### Example 2: Get Student Recommendations
```sql
-- Get top 5 internship recommendations for Jane Smith (ID: 2)
CALL GetStudentRecommendations(2, 5);
```

**Expected Output:**
```
+---------------+-----------------------------+--------------+-------------+...
| internship_id | title                       | company_name | match_score |...
+---------------+-----------------------------+--------------+-------------+...
| 1             | Software Engineering Intern | Google Inc.  | 95.50       |...
| 2             | ML Research Intern          | Microsoft    | 92.30       |...
+---------------+-----------------------------+--------------+-------------+...
```

### Example 3: Skill Gap Analysis
```sql
-- See what skills John Doe (ID: 1) needs for Google internship (ID: 1)
CALL GetSkillGapAnalysis(1, 1);
```

**Expected Output:**
```
+-------------+----------------+----------------------+------------------+----------------+
| skill_name  | required_prof  | student_proficiency  | is_mandatory     | match_status   |
+-------------+----------------+----------------------+------------------+----------------+
| JavaScript  | Advanced       | Advanced             | Yes              | Meets Req      |
| React       | Advanced       | Advanced             | Yes              | Meets Req      |
| Python      | Intermediate   | Advanced             | Yes              | Meets Req      |
| MySQL       | Intermediate   | Advanced             | Yes              | Meets Req      |
| REST API    | Intermediate   | Not Available        | No               | Missing Skill  |
+-------------+----------------+----------------------+------------------+----------------+
```

---

## 📊 Common Queries

### Query 1: View All Open Internships
```sql
SELECT * FROM vw_active_internships;
```

### Query 2: Check Platform Statistics
```sql
SELECT 
    (SELECT COUNT(*) FROM Student WHERE is_active = TRUE) as total_students,
    (SELECT COUNT(*) FROM Internship WHERE status = 'Open') as open_positions,
    (SELECT COUNT(*) FROM Applications) as total_applications,
    (SELECT COUNT(*) FROM Applications WHERE application_status = 'Accepted') as total_placements;
```

### Query 3: Most In-Demand Skills
```sql
SELECT skill_name, category, internship_count, students_with_skill
FROM vw_most_demanded_skills
LIMIT 10;
```

### Query 4: Application Success Rate by Student
```sql
SELECT 
    s.full_name,
    COUNT(a.application_id) as total_apps,
    COUNT(CASE WHEN a.application_status = 'Accepted' THEN 1 END) as accepted,
    ROUND(COUNT(CASE WHEN a.application_status = 'Accepted' THEN 1 END) * 100.0 / 
          COUNT(a.application_id), 1) as success_rate
FROM Student s
LEFT JOIN Applications a ON s.student_id = a.student_id
GROUP BY s.student_id
HAVING total_apps > 0
ORDER BY success_rate DESC;
```

---

## 🎓 Tutorial: Adding New Data

### Add a New Student
```sql
-- 1. Create student profile
INSERT INTO Student (username, email, password_hash, full_name, college_name, department, year_of_study, cgpa)
VALUES ('new_student', 'new@student.edu', 'hashed_pass', 'New Student', 'MIT College', 'Computer Science', 3, 8.5);

-- Get the student_id (let's say it's 11)
SET @student_id = LAST_INSERT_ID();

-- 2. Add student skills
INSERT INTO Student_Skills (student_id, skill_id, proficiency_level, years_of_experience)
VALUES 
    (@student_id, 1, 'Advanced', 2.0),  -- Python
    (@student_id, 3, 'Intermediate', 1.5),  -- JavaScript
    (@student_id, 15, 'Advanced', 2.0);  -- MySQL

-- 3. Get recommendations
CALL GetStudentRecommendations(@student_id, 5);
```

### Add a New Internship
```sql
-- 1. Create internship
INSERT INTO Internship (recruiter_id, title, type, description, company_name, location, is_remote, 
                        duration_months, stipend, minimum_cgpa, application_deadline, start_date, max_positions)
VALUES (1, 'Backend Developer Intern', 'Internship', 
        'Work on scalable backend systems', 
        'TechCorp', 'Remote', TRUE, 6, 7000.00, 7.5, '2026-04-30', '2026-06-15', 3);

-- Get the internship_id
SET @internship_id = LAST_INSERT_ID();

-- 2. Add required skills
INSERT INTO Internship_Skills (internship_id, skill_id, required_proficiency, is_mandatory, weightage)
VALUES 
    (@internship_id, 1, 'Advanced', TRUE, 10),  -- Python
    (@internship_id, 11, 'Advanced', TRUE, 10),  -- Django
    (@internship_id, 15, 'Intermediate', TRUE, 8),  -- MySQL
    (@internship_id, 31, 'Beginner', FALSE, 5);  -- Docker

-- 3. Calculate matches
CALL CalculateMatchScores(@internship_id);

-- 4. View top candidates
CALL GetTopCandidates(@internship_id, 10);
```

### Submit an Application
```sql
-- Student 1 applies to Internship 3
INSERT INTO Applications (student_id, internship_id, application_status, cover_letter)
VALUES (1, 3, 'Applied', 'I am very interested in this position...');
```

---

## 🔍 Troubleshooting

### Problem: "Access denied for user"
**Solution:**
```bash
# Grant necessary permissions
mysql -u root -p
GRANT ALL PRIVILEGES ON internship_platform.* TO 'your_user'@'localhost';
FLUSH PRIVILEGES;
```

### Problem: "Stored procedure not found"
**Solution:**
```bash
# Re-run the matching algorithm file
mysql -u root -p internship_platform < matching_algorithm.sql
```

### Problem: "No matches calculated"
**Solution:**
```sql
-- Manually trigger match calculation
CALL CalculateMatchScores(1);  -- For internship 1
CALL CalculateMatchScores(2);  -- For internship 2
-- etc.
```

### Problem: "Trigger not firing"
**Solution:**
```bash
# Re-create triggers
mysql -u root -p internship_platform < triggers.sql
```

---

## 📈 Performance Tips

### Tip 1: Regular Maintenance
```sql
-- Optimize tables monthly
OPTIMIZE TABLE Match_Result;
OPTIMIZE TABLE Applications;
OPTIMIZE TABLE Student_Skills;

-- Analyze tables for better query planning
ANALYZE TABLE Match_Result;
ANALYZE TABLE Applications;
```

### Tip 2: Batch Processing
```sql
-- Instead of calculating matches one by one:
-- Create a batch script to calculate for all open internships

DELIMITER //
CREATE PROCEDURE CalculateAllMatches()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE iid INT;
    DECLARE cur CURSOR FOR SELECT internship_id FROM Internship WHERE status = 'Open';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO iid;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL CalculateMatchScores(iid);
    END LOOP;
    CLOSE cur;
END//
DELIMITER ;

-- Run it:
CALL CalculateAllMatches();
```

### Tip 3: Clean Up Old Data
```sql
-- Archive closed internships older than 1 year
CREATE TABLE Internship_Archive AS 
SELECT * FROM Internship 
WHERE status IN ('Closed', 'Filled') 
AND application_deadline < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Delete from main table
DELETE FROM Internship 
WHERE status IN ('Closed', 'Filled') 
AND application_deadline < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
```

---

## 🎯 Key Files Reference

| File | Purpose |
|------|---------|
| `schema.sql` | Database structure, tables, indexes |
| `sample_data.sql` | Sample data for testing |
| `matching_algorithm.sql` | Core matching logic, stored procedures |
| `triggers.sql` | Data integrity, audit, notifications |
| `analysis_queries.sql` | Reports and analytics queries |
| `test_suite.sql` | Comprehensive testing |
| `README.md` | Full documentation |
| `ER_DIAGRAM.md` | Database design details |

---

## 💡 Best Practices

### 1. Always Backup Before Changes
```bash
# Backup database
mysqldump -u root -p internship_platform > backup_$(date +%Y%m%d).sql

# Restore if needed
mysql -u root -p internship_platform < backup_20260130.sql
```

### 2. Use Transactions for Critical Operations
```sql
START TRANSACTION;

-- Your operations
UPDATE Applications SET application_status = 'Accepted' WHERE application_id = 5;
-- More operations...

-- If everything looks good:
COMMIT;

-- If there's a problem:
-- ROLLBACK;
```

### 3. Monitor Performance
```sql
-- Check slow queries
SELECT * FROM mysql.slow_log ORDER BY query_time DESC LIMIT 10;

-- Check table sizes
SELECT 
    table_name, 
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)"
FROM information_schema.tables
WHERE table_schema = 'internship_platform'
ORDER BY (data_length + index_length) DESC;
```

---

## 📞 Need Help?

1. **Check the README**: Full documentation in `README.md`
2. **Run Tests**: Execute `test_suite.sql` to verify setup
3. **Review ER Diagram**: See `ER_DIAGRAM.md` for database design
4. **Sample Queries**: Check `analysis_queries.sql` for examples

---

## ✅ Checklist for Setup

- [ ] MySQL 8.0+ installed
- [ ] Database created
- [ ] All SQL scripts executed in order
- [ ] Test suite passes
- [ ] Sample data loaded
- [ ] Can run stored procedures
- [ ] Triggers are active
- [ ] Views are accessible

**You're ready to go! 🚀**
