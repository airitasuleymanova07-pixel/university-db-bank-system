-- Задача 1: Создание таблицы студентов
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    group_number VARCHAR(20) NOT NULL
);

-- Создание таблицы предметов
CREATE TABLE subjects (
    subject_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);

-- Создание таблицы оценок
CREATE TABLE grades (
    grade_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),
    subject_id INTEGER REFERENCES subjects(subject_id),
    grade INTEGER CHECK (grade BETWEEN 1 AND 5)
);

-- Создание таблицы посещаемости
CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),
    date_attended DATE NOT NULL,
    status VARCHAR(10) CHECK (status IN ('present', 'absent', 'late'))
);

-- Создание таблицы заметок
CREATE TABLE notes (
    note_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),
    note_text TEXT NOT NULL
);

-- Задача2: Добавление студентов (6 студентов одной группы)
INSERT INTO students (full_name, group_number) VALUES
('Иванов Иван Иванович', 'Группа 101'),
('Петров Петр Петрович', 'Группа 101'),
('Сидорова Мария Сергеевна', 'Группа 101'),
('Кузнецов Алексей Владимирович', 'Группа 101'),
('Смирнова Екатерина Андреевна', 'Группа 101'),
('Васильев Дмитрий Николаевич', 'Группа 101');

-- Добавление предметов
INSERT INTO subjects (subject_name) VALUES
('Математический анализ'),
('Аналитическая геометрия'),
('Информатика');

-- Добавление оценок для всех студентов по каждому предмету
INSERT INTO grades (student_id, subject_id, grade)
SELECT s.student_id, sub.subject_id, 
       CASE 
           WHEN RANDOM() < 0.3 THEN 4
           WHEN RANDOM() < 0.6 THEN 5
           ELSE 3
       END as grade
FROM students s
CROSS JOIN subjects sub;

-- Добавление записей посещаемости
INSERT INTO attendance (student_id, date_attended, status)
SELECT student_id, 
       CURRENT_DATE - INTERVAL '1 day' as date_attended,
       CASE WHEN RANDOM() < 0.8 THEN 'present' ELSE 'absent' END
FROM students
UNION ALL
SELECT student_id, 
       CURRENT_DATE as date_attended,
       CASE WHEN RANDOM() < 0.9 THEN 'present' ELSE 'late' END
FROM students;

-- Добавление заметок
INSERT INTO notes (student_id, note_text) VALUES
(1, 'Любит информатику'),
(2, 'Нужна помощь по информатике'),
(3, 'Редко посещает занятия по информатике'),
(4, 'Отличник по всем предметам'),
(5, 'Хорошо работает в команде'),
(6, 'Прогресс по информатике');

-- Задача3: 
-- Индекс для поиска одногруппников
CREATE INDEX idx_students_group ON students(group_number);

-- Индекс для агрегированных запросов оценок
CREATE INDEX idx_grades_student ON grades(student_id);

-- GIN индекс для полнотекстового поиска
CREATE INDEX idx_notes_text ON notes USING gin(to_tsvector('russian', note_text));

--Задача4:
-- Представление для среднего балла студентов
CREATE VIEW student_avg_grades AS
SELECT 
    s.student_id,
    s.full_name,
    s.group_number,
    ROUND(AVG(g.grade)::numeric, 2) as avg_grade
FROM students s
LEFT JOIN grades g ON s.student_id = g.student_id
GROUP BY s.student_id, s.full_name, s.group_number;

-- Задача 5: 
BEGIN;

-- Добавление нового студента
INSERT INTO students (full_name, group_number) 
VALUES ('Новый Студент Тестовый', 'Группа 101')
RETURNING student_id;

-- Получение ID нового студента (предположим, что это 7)
-- Добавление оценок для нового студента
INSERT INTO grades (student_id, subject_id, grade) VALUES
(7, 1, 4),
(7, 2, 5),
(7, 3, 4);

COMMIT;

--Задача6:
-- 1. Найти 5 одногруппников студента (2 до и 3 после по student_id)
WITH target_student AS (
    SELECT student_id, group_number 
    FROM students 
    WHERE student_id = 3
)
SELECT * FROM students 
WHERE group_number = (SELECT group_number FROM target_student)
  AND student_id != (SELECT student_id FROM target_student)
ORDER BY student_id
LIMIT 5;

-- 2. Посмотреть средний балл конкретного студента через представление
SELECT * FROM student_avg_grades WHERE student_id = 3;

-- 3. Агрегировать средний балл по предмету «Информатика»
SELECT 
    s.subject_name,
    ROUND(AVG(g.grade)::numeric, 2) as avg_grade
FROM subjects s
JOIN grades g ON s.subject_id = g.subject_id
WHERE s.subject_name = 'Информатика'
GROUP BY s.subject_name;

-- 4. Полнотекстовый поиск по заметкам
SELECT n.*, s.full_name
FROM notes n
JOIN students s ON n.student_id = s.student_id
WHERE to_tsvector('russian', note_text) @@ to_tsquery('russian', 'информатика');

-- 5. Обновить посещаемость студента через транзакцию
BEGIN;
UPDATE attendance 
SET status = 'present'
WHERE student_id = 1 
  AND date_attended = CURRENT_DATE;
COMMIT;
