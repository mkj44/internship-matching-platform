# Entity-Relationship Diagram
## Skill-Based Internship & Project Matching Platform

---

## 📊 Complete ER Diagram Description

### Entities and Attributes

#### 1. STUDENT (Primary Entity)
**Primary Key**: student_id
**Attributes**:
- student_id (PK)
- username (UNIQUE)
- email (UNIQUE)
- password_hash
- full_name
- college_name
- department
- year_of_study (1-5)
- cgpa (0-10)
- phone
- resume_url
- linkedin_url
- github_url
- profile_created_at
- profile_updated_at
- is_active

**Relationships**:
- HAS_SKILL (M:M with SKILLS via STUDENT_SKILLS)
- APPLIES_FOR (1:M with APPLICATIONS)
- MATCHED_TO (1:M with MATCH_RESULT)

---

#### 2. RECRUITER (Primary Entity)
**Primary Key**: recruiter_id
**Attributes**:
- recruiter_id (PK)
- username (UNIQUE)
- email (UNIQUE)
- password_hash
- full_name
- company_name
- company_website
- designation
- phone
- is_verified
- created_at
- last_login

**Relationships**:
- POSTS (1:M with INTERNSHIP)

---

#### 3. ADMIN (Primary Entity)
**Primary Key**: admin_id
**Attributes**:
- admin_id (PK)
- username (UNIQUE)
- email (UNIQUE)
- password_hash
- full_name
- created_at
- last_login

**Relationships**:
- MANAGES (monitors all entities)

---

#### 4. SKILLS (Master Entity)
**Primary Key**: skill_id
**Attributes**:
- skill_id (PK)
- skill_name (UNIQUE)
- category
- description
- created_at

**Relationships**:
- KNOWN_BY (M:M with STUDENT via STUDENT_SKILLS)
- REQUIRED_FOR (M:M with INTERNSHIP via INTERNSHIP_SKILLS)

---

#### 5. STUDENT_SKILLS (Junction Table)
**Primary Key**: student_skill_id
**Foreign Keys**: student_id, skill_id
**Attributes**:
- student_skill_id (PK)
- student_id (FK)
- skill_id (FK)
- proficiency_level (ENUM: Beginner, Intermediate, Advanced, Expert)
- years_of_experience
- certification_url
- added_at
- updated_at

**Relationships**:
- Links STUDENT and SKILLS (M:M)

---

#### 6. INTERNSHIP (Primary Entity)
**Primary Key**: internship_id
**Foreign Key**: recruiter_id
**Attributes**:
- internship_id (PK)
- recruiter_id (FK)
- title
- type (ENUM: Internship, Project, Both)
- description
- company_name
- location
- is_remote
- duration_months
- stipend
- minimum_cgpa
- preferred_year
- application_deadline
- start_date
- max_positions
- status (ENUM: Open, Closed, Filled, Cancelled)
- created_at
- updated_at

**Relationships**:
- POSTED_BY (M:1 with RECRUITER)
- REQUIRES_SKILL (1:M with INTERNSHIP_SKILLS)
- RECEIVES (1:M with APPLICATIONS)
- MATCHED_WITH (1:M with MATCH_RESULT)

---

#### 7. INTERNSHIP_SKILLS (Junction Table)
**Primary Key**: internship_skill_id
**Foreign Keys**: internship_id, skill_id
**Attributes**:
- internship_skill_id (PK)
- internship_id (FK)
- skill_id (FK)
- required_proficiency (ENUM: Beginner, Intermediate, Advanced, Expert)
- is_mandatory (BOOLEAN)
- weightage (1-10)

**Relationships**:
- Links INTERNSHIP and SKILLS (M:M)

---

#### 8. APPLICATIONS (Relationship Entity)
**Primary Key**: application_id
**Foreign Keys**: student_id, internship_id
**Attributes**:
- application_id (PK)
- student_id (FK)
- internship_id (FK)
- application_status (ENUM: Applied, Under Review, Shortlisted, Rejected, Accepted, Withdrawn)
- cover_letter
- applied_at
- reviewed_at
- status_updated_at
- recruiter_notes

**Relationships**:
- SUBMITTED_BY (M:1 with STUDENT)
- FOR_POSITION (M:1 with INTERNSHIP)
- ASSESSED_BY (1:M with ASSESSMENT)

---

#### 9. ASSESSMENT (Weak Entity)
**Primary Key**: assessment_id
**Foreign Key**: application_id
**Attributes**:
- assessment_id (PK)
- application_id (FK)
- assessment_type (ENUM: Technical Test, Aptitude Test, Coding Challenge, Interview, Other)
- score
- max_score
- feedback
- assessed_at

**Relationships**:
- EVALUATES (M:1 with APPLICATIONS)

---

#### 10. MATCH_RESULT (Derived Entity)
**Primary Key**: match_id
**Foreign Keys**: student_id, internship_id
**Attributes**:
- match_id (PK)
- student_id (FK)
- internship_id (FK)
- match_score (0-100)
- skill_match_score
- cgpa_score
- experience_score
- mandatory_skills_met
- total_skills_matched
- total_skills_required
- recommendation_rank
- calculated_at

**Relationships**:
- MATCHES (links STUDENT and INTERNSHIP)

---

## 🔗 Relationship Cardinalities

### One-to-Many Relationships
1. **RECRUITER → INTERNSHIP**
   - One recruiter can post many internships
   - Each internship belongs to one recruiter
   - Cardinality: 1:M

2. **STUDENT → APPLICATIONS**
   - One student can apply to many internships
   - Each application belongs to one student
   - Cardinality: 1:M

3. **INTERNSHIP → APPLICATIONS**
   - One internship can receive many applications
   - Each application is for one internship
   - Cardinality: 1:M

4. **APPLICATION → ASSESSMENT**
   - One application can have many assessments
   - Each assessment belongs to one application
   - Cardinality: 1:M

### Many-to-Many Relationships
1. **STUDENT ↔ SKILLS** (via STUDENT_SKILLS)
   - One student can have many skills
   - One skill can be possessed by many students
   - Junction Table: STUDENT_SKILLS
   - Additional Attributes: proficiency_level, years_of_experience

2. **INTERNSHIP ↔ SKILLS** (via INTERNSHIP_SKILLS)
   - One internship requires many skills
   - One skill can be required by many internships
   - Junction Table: INTERNSHIP_SKILLS
   - Additional Attributes: required_proficiency, is_mandatory, weightage

---

## 📐 ASCII ER Diagram

```
                    ┌─────────────┐
                    │    ADMIN    │
                    ├─────────────┤
                    │ admin_id PK │
                    │ username    │
                    │ email       │
                    └─────────────┘
                           │
                           │ MANAGES
                           ▼
    ┌──────────────────────────────────────────────────┐
    │                                                  │
    │                                                  │
    ▼                                                  ▼
┌─────────────┐                                ┌─────────────┐
│   STUDENT   │                                │  RECRUITER  │
├─────────────┤                                ├─────────────┤
│student_id PK│                                │recruiter_id │
│ username    │                                │ username    │
│ email       │                                │ company     │
│ cgpa        │                                └──────┬──────┘
│ department  │                                       │
└──────┬──────┘                                       │ POSTS (1:M)
       │                                              │
       │ HAS_SKILL (M:M)                             ▼
       │                              ┌─────────────────────────┐
       │                              │     INTERNSHIP          │
       │                              ├─────────────────────────┤
       ├──────────────────┐           │ internship_id PK        │
       │                  │           │ recruiter_id FK         │
       ▼                  ▼           │ title                   │
┌─────────────┐    ┌─────────────┐   │ type                    │
│STUDENT_SKILL│    │   SKILLS    │   │ minimum_cgpa            │
├─────────────┤    ├─────────────┤   │ application_deadline    │
│student_id FK│───▶│ skill_id PK │◀──│ status                  │
│ skill_id FK │    │ skill_name  │   └───────────┬─────────────┘
│proficiency  │    │ category    │               │
│ experience  │    └─────────────┘               │ REQUIRES_SKILL (1:M)
└─────────────┘           │                      │
       │                  │                      ▼
       │                  │            ┌──────────────────┐
       │                  └───────────▶│INTERNSHIP_SKILLS │
       │                               ├──────────────────┤
       │                               │internship_id FK  │
       │ APPLIES_FOR (1:M)             │ skill_id FK      │
       │                               │required_prof     │
       ▼                               │ is_mandatory     │
┌─────────────────┐                    │ weightage        │
│  APPLICATIONS   │                    └──────────────────┘
├─────────────────┤
│application_id PK│
│ student_id FK   │
│internship_id FK │
│ status          │
│ applied_at      │
└────────┬────────┘
         │
         │ HAS_ASSESSMENT (1:M)
         ▼
┌─────────────────┐
│   ASSESSMENT    │
├─────────────────┤
│assessment_id PK │
│application_id FK│
│ type            │
│ score           │
│ feedback        │
└─────────────────┘

         MATCHING ENGINE
              │
              ▼
    ┌──────────────────┐
    │  MATCH_RESULT    │
    ├──────────────────┤
    │ match_id PK      │
    │ student_id FK    │
    │ internship_id FK │
    │ match_score      │
    │ rank             │
    └──────────────────┘
```

---

## 🎯 Functional Dependencies

### STUDENT
- student_id → username, email, full_name, college_name, department, year_of_study, cgpa, phone
- email → student_id (UNIQUE)
- username → student_id (UNIQUE)

### RECRUITER
- recruiter_id → username, email, full_name, company_name, designation
- email → recruiter_id (UNIQUE)

### SKILLS
- skill_id → skill_name, category, description
- skill_name → skill_id (UNIQUE)

### INTERNSHIP
- internship_id → recruiter_id, title, type, description, company_name, location, stipend, minimum_cgpa, deadline, status
- internship_id, recruiter_id → (all internship attributes)

### STUDENT_SKILLS
- (student_id, skill_id) → proficiency_level, years_of_experience, certification_url
- Composite key ensures no duplicate skills per student

### APPLICATIONS
- application_id → student_id, internship_id, application_status, applied_at
- (student_id, internship_id) → application_id (UNIQUE - one application per student per internship)

---

## 🔄 Data Flow

### Application Workflow
```
1. STUDENT registers → creates STUDENT record
2. STUDENT adds skills → creates STUDENT_SKILLS records
3. RECRUITER posts job → creates INTERNSHIP and INTERNSHIP_SKILLS records
4. SYSTEM calculates matches → creates MATCH_RESULT records
5. STUDENT views recommendations → queries MATCH_RESULT
6. STUDENT applies → creates APPLICATION record
7. RECRUITER reviews → updates APPLICATION status
8. RECRUITER conducts tests → creates ASSESSMENT records
9. RECRUITER accepts/rejects → updates APPLICATION status → triggers notifications
```

---

## 📋 Normalization Analysis

### First Normal Form (1NF)
✓ All attributes are atomic
✓ No repeating groups
✓ Each cell contains single value

### Second Normal Form (2NF)
✓ All non-key attributes fully dependent on primary key
✓ No partial dependencies
✓ Composite keys properly defined

### Third Normal Form (3NF)
✓ No transitive dependencies
✓ All non-key attributes depend only on primary key
✓ Properly decomposed tables

### Boyce-Codd Normal Form (BCNF)
✓ For every functional dependency X → Y, X is a superkey
✓ No redundancy in primary keys

---

## 🔍 Key Constraints

### Primary Keys
- Auto-increment INTEGER for all tables
- Ensures uniqueness and efficient indexing

### Foreign Keys
- ON DELETE CASCADE for dependent data
- ON DELETE RESTRICT for critical references
- Maintains referential integrity

### Unique Constraints
- username, email (STUDENT, RECRUITER, ADMIN)
- skill_name (SKILLS)
- (student_id, skill_id) in STUDENT_SKILLS
- (student_id, internship_id) in APPLICATIONS
- (internship_id, skill_id) in INTERNSHIP_SKILLS

### Check Constraints
- cgpa BETWEEN 0 AND 10
- year_of_study BETWEEN 1 AND 5
- weightage BETWEEN 1 AND 10
- proficiency_level in defined ENUM values
- application_status in defined ENUM values

---

## 📊 Cardinality Summary

| Relationship | Type | Cardinality | Description |
|--------------|------|-------------|-------------|
| Student → Student_Skills | 1:M | 1 student has many skills | |
| Skills → Student_Skills | 1:M | 1 skill known by many students | |
| Recruiter → Internship | 1:M | 1 recruiter posts many internships | |
| Internship → Internship_Skills | 1:M | 1 internship requires many skills | |
| Skills → Internship_Skills | 1:M | 1 skill required by many internships | |
| Student → Applications | 1:M | 1 student applies to many internships | |
| Internship → Applications | 1:M | 1 internship receives many applications | |
| Application → Assessment | 1:M | 1 application has many assessments | |
| Student → Match_Result | 1:M | 1 student matched to many internships | |
| Internship → Match_Result | 1:M | 1 internship matched with many students | |

---

## 📝 Notes

1. **MATCH_RESULT** is a materialized/computed table for performance
2. Junction tables (**STUDENT_SKILLS**, **INTERNSHIP_SKILLS**) resolve M:M relationships
3. All timestamps use CURRENT_TIMESTAMP with automatic updates
4. Soft deletes possible via `is_active` flags
5. Audit tables track all critical changes
