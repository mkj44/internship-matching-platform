-- =====================================================
-- TRIGGERS FOR DATA INTEGRITY & AUTOMATION
-- =====================================================

-- =====================================================
-- TRIGGERS FOR AUTOMATIC CALCULATIONS
-- =====================================================

-- Trigger 1: Auto-update Internship Status based on deadline
DELIMITER //

CREATE TRIGGER trg_check_internship_deadline
BEFORE UPDATE ON Internship
FOR EACH ROW
BEGIN
    IF NEW.application_deadline < CURDATE() AND NEW.status = 'Open' THEN
        SET NEW.status = 'Closed';
    END IF;
END//

DELIMITER ;

-- Trigger 2: Prevent application after deadline
DELIMITER //

CREATE TRIGGER trg_check_application_deadline
BEFORE INSERT ON Applications
FOR EACH ROW
BEGIN
    DECLARE deadline DATE;
    DECLARE int_status VARCHAR(20);
    
    SELECT application_deadline, status INTO deadline, int_status
    FROM Internship 
    WHERE internship_id = NEW.internship_id;
    
    IF deadline < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot apply: Application deadline has passed';
    END IF;
    
    IF int_status != 'Open' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot apply: Internship is not open for applications';
    END IF;
END//

DELIMITER ;

-- Trigger 3: Check CGPA eligibility before application
DELIMITER //

CREATE TRIGGER trg_check_cgpa_eligibility
BEFORE INSERT ON Applications
FOR EACH ROW
BEGIN
    DECLARE student_cgpa DECIMAL(3,2);
    DECLARE min_cgpa DECIMAL(3,2);
    
    SELECT s.cgpa, i.minimum_cgpa 
    INTO student_cgpa, min_cgpa
    FROM Student s, Internship i
    WHERE s.student_id = NEW.student_id 
    AND i.internship_id = NEW.internship_id;
    
    IF student_cgpa < min_cgpa THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot apply: CGPA below minimum requirement';
    END IF;
END//

DELIMITER ;

-- Trigger 4: Update timestamp on application status change
DELIMITER //

CREATE TRIGGER trg_update_application_timestamp
BEFORE UPDATE ON Applications
FOR EACH ROW
BEGIN
    IF NEW.application_status != OLD.application_status THEN
        SET NEW.reviewed_at = CURRENT_TIMESTAMP;
    END IF;
END//

DELIMITER ;

-- Trigger 5: Auto-recalculate matches when internship skills are updated
DELIMITER //

CREATE TRIGGER trg_recalc_on_internship_skill_insert
AFTER INSERT ON Internship_Skills
FOR EACH ROW
BEGIN
    -- Set a flag or call stored procedure to recalculate
    -- In real implementation, this could trigger async job
    INSERT INTO Match_Result (student_id, internship_id, match_score, calculated_at)
    SELECT NEW.internship_id, 0, 0, CURRENT_TIMESTAMP
    FROM DUAL
    WHERE NOT EXISTS (
        SELECT 1 FROM Match_Result 
        WHERE internship_id = NEW.internship_id 
        AND calculated_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)
    )
    LIMIT 1;
    -- Note: Actual recalculation should be done via batch job
END//

DELIMITER ;

-- Trigger 6: Prevent duplicate student skills
DELIMITER //

CREATE TRIGGER trg_prevent_duplicate_skills
BEFORE INSERT ON Student_Skills
FOR EACH ROW
BEGIN
    DECLARE skill_exists INT;
    
    SELECT COUNT(*) INTO skill_exists
    FROM Student_Skills
    WHERE student_id = NEW.student_id 
    AND skill_id = NEW.skill_id;
    
    IF skill_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Skill already exists for this student. Use UPDATE instead.';
    END IF;
END//

DELIMITER ;

-- Trigger 7: Log when a student gets accepted
DELIMITER //

CREATE TABLE Application_History (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),
    INDEX idx_student (student_id),
    INDEX idx_internship (internship_id)
);

CREATE TRIGGER trg_log_application_status_change
AFTER UPDATE ON Applications
FOR EACH ROW
BEGIN
    IF NEW.application_status != OLD.application_status THEN
        INSERT INTO Application_History (
            application_id, 
            student_id, 
            internship_id, 
            old_status, 
            new_status
        ) VALUES (
            NEW.application_id,
            NEW.student_id,
            NEW.internship_id,
            OLD.application_status,
            NEW.application_status
        );
    END IF;
END//

DELIMITER ;

-- Trigger 8: Check maximum positions before accepting
DELIMITER //

CREATE TRIGGER trg_check_max_positions
BEFORE UPDATE ON Applications
FOR EACH ROW
BEGIN
    DECLARE accepted_count INT;
    DECLARE max_pos INT;
    
    IF NEW.application_status = 'Accepted' AND OLD.application_status != 'Accepted' THEN
        SELECT 
            COUNT(*), 
            i.max_positions
        INTO accepted_count, max_pos
        FROM Applications a
        JOIN Internship i ON a.internship_id = i.internship_id
        WHERE a.internship_id = NEW.internship_id 
        AND a.application_status = 'Accepted'
        GROUP BY i.max_positions;
        
        IF accepted_count >= max_pos THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot accept: Maximum positions already filled';
        END IF;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- TRIGGERS FOR DATA VALIDATION
-- =====================================================

-- Trigger 9: Validate proficiency level progression
DELIMITER //

CREATE TRIGGER trg_validate_proficiency_update
BEFORE UPDATE ON Student_Skills
FOR EACH ROW
BEGIN
    -- Ensure proficiency doesn't decrease without justification
    IF GetProficiencyValue(NEW.proficiency_level) < GetProficiencyValue(OLD.proficiency_level) THEN
        IF NEW.years_of_experience >= OLD.years_of_experience THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot decrease proficiency level without reducing experience';
        END IF;
    END IF;
END//

DELIMITER ;

-- Trigger 10: Validate CGPA range
DELIMITER //

CREATE TRIGGER trg_validate_cgpa_student
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    IF NEW.cgpa < 0 OR NEW.cgpa > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'CGPA must be between 0 and 10';
    END IF;
END//

CREATE TRIGGER trg_validate_cgpa_student_update
BEFORE UPDATE ON Student
FOR EACH ROW
BEGIN
    IF NEW.cgpa < 0 OR NEW.cgpa > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'CGPA must be between 0 and 10';
    END IF;
END//

DELIMITER ;

-- =====================================================
-- AUDIT TRIGGERS
-- =====================================================

-- Create audit log table
CREATE TABLE Audit_Log (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INT NOT NULL,
    user_type VARCHAR(20),
    user_id INT,
    old_values TEXT,
    new_values TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_table_operation (table_name, operation),
    INDEX idx_timestamp (timestamp)
);

-- Trigger 11: Audit critical student profile changes
DELIMITER //

CREATE TRIGGER trg_audit_student_update
AFTER UPDATE ON Student
FOR EACH ROW
BEGIN
    IF OLD.cgpa != NEW.cgpa OR OLD.department != NEW.department OR OLD.year_of_study != NEW.year_of_study THEN
        INSERT INTO Audit_Log (table_name, operation, record_id, user_type, user_id, old_values, new_values)
        VALUES (
            'Student',
            'UPDATE',
            NEW.student_id,
            'Student',
            NEW.student_id,
            CONCAT('CGPA:', OLD.cgpa, ',Dept:', OLD.department, ',Year:', OLD.year_of_study),
            CONCAT('CGPA:', NEW.cgpa, ',Dept:', NEW.department, ',Year:', NEW.year_of_study)
        );
    END IF;
END//

DELIMITER ;

-- Trigger 12: Audit internship modifications
DELIMITER //

CREATE TRIGGER trg_audit_internship_update
AFTER UPDATE ON Internship
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status OR OLD.minimum_cgpa != NEW.minimum_cgpa THEN
        INSERT INTO Audit_Log (table_name, operation, record_id, user_type, user_id, old_values, new_values)
        VALUES (
            'Internship',
            'UPDATE',
            NEW.internship_id,
            'Recruiter',
            NEW.recruiter_id,
            CONCAT('Status:', OLD.status, ',MinCGPA:', OLD.minimum_cgpa),
            CONCAT('Status:', NEW.status, ',MinCGPA:', NEW.minimum_cgpa)
        );
    END IF;
END//

DELIMITER ;

-- =====================================================
-- CLEANUP TRIGGERS
-- =====================================================

-- Trigger 13: Cleanup old match results when internship is closed
DELIMITER //

CREATE TRIGGER trg_cleanup_matches_on_close
AFTER UPDATE ON Internship
FOR EACH ROW
BEGIN
    IF NEW.status IN ('Closed', 'Filled', 'Cancelled') AND OLD.status = 'Open' THEN
        -- Archive or delete old matches
        DELETE FROM Match_Result 
        WHERE internship_id = NEW.internship_id;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- NOTIFICATION TRIGGERS (Conceptual - would integrate with app)
-- =====================================================

-- Create notification queue table
CREATE TABLE Notification_Queue (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    recipient_type ENUM('Student', 'Recruiter', 'Admin') NOT NULL,
    recipient_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(50),
    reference_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_recipient (recipient_type, recipient_id, is_read)
);

-- Trigger 14: Notify student on application status change
DELIMITER //

CREATE TRIGGER trg_notify_student_status_change
AFTER UPDATE ON Applications
FOR EACH ROW
BEGIN
    IF NEW.application_status != OLD.application_status THEN
        INSERT INTO Notification_Queue (
            recipient_type,
            recipient_id,
            notification_type,
            title,
            message,
            reference_type,
            reference_id
        )
        SELECT 
            'Student',
            NEW.student_id,
            'APPLICATION_STATUS_UPDATE',
            CONCAT('Application Status Updated: ', i.title),
            CONCAT('Your application for ', i.title, ' at ', i.company_name, 
                   ' has been updated to: ', NEW.application_status),
            'Application',
            NEW.application_id
        FROM Internship i
        WHERE i.internship_id = NEW.internship_id;
    END IF;
END//

DELIMITER ;

-- Trigger 15: Notify recruiter on new application
DELIMITER //

CREATE TRIGGER trg_notify_recruiter_new_application
AFTER INSERT ON Applications
FOR EACH ROW
BEGIN
    INSERT INTO Notification_Queue (
        recipient_type,
        recipient_id,
        notification_type,
        title,
        message,
        reference_type,
        reference_id
    )
    SELECT 
        'Recruiter',
        i.recruiter_id,
        'NEW_APPLICATION',
        CONCAT('New Application: ', i.title),
        CONCAT(s.full_name, ' has applied for ', i.title),
        'Application',
        NEW.application_id
    FROM Internship i
    JOIN Student s ON s.student_id = NEW.student_id
    WHERE i.internship_id = NEW.internship_id;
END//

DELIMITER ;

-- Trigger 16: Notify students about deadline approaching
-- Note: This would typically be a scheduled job, not a trigger
-- But shown here for completeness
DELIMITER //

CREATE EVENT evt_notify_approaching_deadlines
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO Notification_Queue (
        recipient_type,
        recipient_id,
        notification_type,
        title,
        message,
        reference_type,
        reference_id
    )
    SELECT DISTINCT
        'Student',
        mr.student_id,
        'DEADLINE_REMINDER',
        CONCAT('Deadline Approaching: ', i.title),
        CONCAT('The application deadline for ', i.title, ' at ', i.company_name, 
               ' is in ', DATEDIFF(i.application_deadline, CURDATE()), ' days'),
        'Internship',
        i.internship_id
    FROM Match_Result mr
    JOIN Internship i ON mr.internship_id = i.internship_id
    LEFT JOIN Applications a ON mr.student_id = a.student_id AND mr.internship_id = a.internship_id
    WHERE i.status = 'Open'
    AND i.application_deadline BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND a.application_id IS NULL
    AND mr.mandatory_skills_met = TRUE
    AND mr.match_score >= 70;
END//

DELIMITER ;
