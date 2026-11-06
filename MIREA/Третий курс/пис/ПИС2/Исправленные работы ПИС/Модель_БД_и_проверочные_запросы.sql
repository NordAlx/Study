-- Логическая модель образовательного ИТ-хаба. SQL совместим с PostgreSQL.
-- Пароли и сеансы обеспечивает подсистема аутентификации; они не входят
-- в учебную ER-модель предметной области.
CREATE TABLE hub_user (
 user_id INTEGER PRIMARY KEY,
 email VARCHAR(254) NOT NULL UNIQUE,
 full_name VARCHAR(200) NOT NULL,
 role VARCHAR(20) NOT NULL CHECK(role IN ('student','mentor','coordinator','admin')),
 is_active BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE course (
 course_id INTEGER PRIMARY KEY,
 title VARCHAR(200) NOT NULL,
 description TEXT NOT NULL,
 level VARCHAR(50) NOT NULL,
 is_published BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE TABLE study_group (
 group_id INTEGER PRIMARY KEY,
 course_id INTEGER NOT NULL REFERENCES course(course_id),
 mentor_id INTEGER NOT NULL REFERENCES hub_user(user_id),
 starts_at TIMESTAMP NOT NULL,
 capacity INTEGER NOT NULL CHECK(capacity BETWEEN 1 AND 50),
 status VARCHAR(20) NOT NULL CHECK(status IN ('planned','active','completed'))
);
CREATE TABLE enrollment (
 enrollment_id INTEGER PRIMARY KEY,
 student_id INTEGER NOT NULL REFERENCES hub_user(user_id),
 group_id INTEGER NOT NULL REFERENCES study_group(group_id),
 status VARCHAR(20) NOT NULL CHECK(status IN ('pending','active','rejected','completed')),
 applied_at TIMESTAMP NOT NULL,
 UNIQUE(student_id,group_id)
);
CREATE TABLE lesson (
 lesson_id INTEGER PRIMARY KEY,
 group_id INTEGER NOT NULL REFERENCES study_group(group_id),
 starts_at TIMESTAMP NOT NULL,
 ends_at TIMESTAMP NOT NULL,
 location TEXT NOT NULL,
 CHECK(ends_at > starts_at)
);
CREATE TABLE material (
 material_id INTEGER PRIMARY KEY,
 group_id INTEGER NOT NULL REFERENCES study_group(group_id),
 title VARCHAR(200) NOT NULL,
 file_url TEXT NOT NULL
);
CREATE TABLE task (
 task_id INTEGER PRIMARY KEY,
 group_id INTEGER NOT NULL REFERENCES study_group(group_id),
 title VARCHAR(200) NOT NULL,
 criteria TEXT NOT NULL,
 max_score INTEGER NOT NULL CHECK(max_score > 0),
 pass_score INTEGER NOT NULL CHECK(pass_score BETWEEN 0 AND max_score),
 deadline TIMESTAMP NOT NULL,
 max_attempts INTEGER NOT NULL CHECK(max_attempts > 0),
 is_required BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE submission (
 submission_id INTEGER PRIMARY KEY,
 task_id INTEGER NOT NULL REFERENCES task(task_id),
 enrollment_id INTEGER NOT NULL REFERENCES enrollment(enrollment_id),
 version_no INTEGER NOT NULL CHECK(version_no > 0),
 file_url TEXT NOT NULL,
 status VARCHAR(20) NOT NULL CHECK(status IN ('submitted','in_review','returned','accepted')),
 submitted_at TIMESTAMP NOT NULL,
 UNIQUE(task_id,enrollment_id,version_no)
);
CREATE UNIQUE INDEX one_accepted_version
 ON submission(task_id,enrollment_id) WHERE status='accepted';
CREATE UNIQUE INDEX one_pending_version
 ON submission(task_id,enrollment_id) WHERE status IN ('submitted','in_review');
CREATE TABLE review (
 review_id INTEGER PRIMARY KEY,
 submission_id INTEGER NOT NULL UNIQUE REFERENCES submission(submission_id),
 mentor_id INTEGER NOT NULL REFERENCES hub_user(user_id),
 score INTEGER NOT NULL CHECK(score >= 0),
 decision VARCHAR(20) NOT NULL CHECK(decision IN ('accepted','returned')),
 remarks TEXT NOT NULL DEFAULT '',
 reviewed_at TIMESTAMP NOT NULL,
 CHECK(decision <> 'returned' OR LENGTH(TRIM(remarks)) > 0)
);
CREATE TABLE certificate (
 certificate_id INTEGER PRIMARY KEY,
 enrollment_id INTEGER NOT NULL UNIQUE REFERENCES enrollment(enrollment_id),
 number VARCHAR(100) NOT NULL UNIQUE,
 issued_at TIMESTAMP NOT NULL
);

-- Межтабличные правила требуют транзакционной проверки сервисом или триггерами:
-- группа задания = группа зачисления; студент и наставник имеют нужные роли;
-- наставник рецензии назначен группе; балл <= max_score; accepted >= pass_score;
-- сдача разрешена по сроку, статусу зачисления и лимиту попыток;
-- принятая версия и её рецензия согласованы; запись рецензии и статуса атомарна;
-- сертификат выдаётся при принятии всех обязательных заданий (их число > 0).
-- Вместимость проверяется при зачислении с блокировкой строки группы.

-- Q1. Число активных слушателей каждой группы; пустые группы сохраняются.
SELECT g.group_id, COUNT(e.enrollment_id) AS active_students
FROM study_group g
LEFT JOIN enrollment e
 ON e.group_id=g.group_id AND e.status='active'
GROUP BY g.group_id
ORDER BY g.group_id;

-- Q2. Очередь проверки наставника с кодом пользователя 2.
SELECT s.submission_id, t.title, u.full_name, s.version_no
FROM submission s
JOIN task t ON t.task_id=s.task_id
JOIN enrollment e ON e.enrollment_id=s.enrollment_id
JOIN hub_user u ON u.user_id=e.student_id
JOIN study_group g ON g.group_id=t.group_id
WHERE g.mentor_id=2
 AND e.group_id=t.group_id
 AND s.status IN ('submitted','in_review')
ORDER BY s.submitted_at, s.submission_id;

-- Q3. Зачисления, для которых можно выдать сертификат.
SELECT e.enrollment_id
FROM enrollment e
WHERE e.status IN ('active','completed')
 AND EXISTS (
  SELECT 1 FROM task t
  WHERE t.group_id=e.group_id AND t.is_required=TRUE
 )
 AND NOT EXISTS (
  SELECT 1 FROM task t
  WHERE t.group_id=e.group_id AND t.is_required=TRUE
   AND NOT EXISTS (
    SELECT 1 FROM submission s
    JOIN review r ON r.submission_id=s.submission_id
    WHERE s.task_id=t.task_id
     AND s.enrollment_id=e.enrollment_id
     AND s.status='accepted' AND r.decision='accepted'
     AND r.score BETWEEN t.pass_score AND t.max_score
   )
 )
 AND NOT EXISTS (
  SELECT 1 FROM certificate c WHERE c.enrollment_id=e.enrollment_id
 );

-- Q4. Контроль нарушения принадлежности к учебной группе (ожидается 0 строк).
SELECT s.submission_id
FROM submission s
JOIN task t ON t.task_id=s.task_id
JOIN enrollment e ON e.enrollment_id=s.enrollment_id
WHERE t.group_id<>e.group_id;

-- Q5. Недопустимые решения и несогласованность рецензии со статусом версии.
SELECT r.review_id
FROM review r
JOIN submission s ON s.submission_id=r.submission_id
JOIN task t ON t.task_id=s.task_id
JOIN study_group g ON g.group_id=t.group_id
WHERE r.score>t.max_score
 OR r.mentor_id<>g.mentor_id
 OR r.decision<>s.status
 OR (r.decision='accepted' AND r.score<t.pass_score);
