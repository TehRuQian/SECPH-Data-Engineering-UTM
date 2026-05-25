-- Task 1 Question 1
CREATE DATABASE hostel_mgmt_jyrq;

use hostel_mgmt_jyrq;

-- Task 1 Question 2
CREATE TABLE room_types(
	type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(20) NOT NULL,
    rent DOUBLE NOT NULL,
    deposit DOUBLE NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE rooms(
	room_id INT AUTO_INCREMENT PRIMARY KEY,
    type_id INT NOT NULL,
    room_no VARCHAR(10) NOT NULL,
    floor_no INT NOT NULL,
    is_occupied BOOLEAN NOT NULL
);

CREATE TABLE students(
	student_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    fname VARCHAR(30) NOT NULL,
    lname VARCHAR(30) NOT NULL,
    status ENUM('ACTIVE', 'NON_ACTIVE') NOT NULL,
    checkin_date DATE,
    email VARCHAR(255) NOT NULL
);

CREATE TABLE maintenance(
	maint_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    issue_desc VARCHAR(255) NOT NULL,
    severity ENUM('LOW', 'MEDIUM', 'HIGH') NOT NULL,
    status ENUM('OPEN', 'RESOLVED') NOT NULL,
    reported_on DATE NOT NULL,
    resolved_on DATE
);

CREATE TABLE payments(
	payment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    amount DOUBLE NOT NULL,
    paid_on DATE NOT NULL,
    method ENUM('CASH', 'FPX', 'CARD', 'TNG') NOT NULL,
    note VARCHAR(255)
);

-- Task 1 Question 3
ALTER TABLE room_types
ADD CONSTRAINT uq_type_name UNIQUE (type_name);

ALTER TABLE rooms
ADD CONSTRAINT uq_room_no UNIQUE (room_no),
ADD CONSTRAINT fk_rooms_type FOREIGN KEY (type_id) REFERENCES room_types(type_id);

ALTER TABLE students
ADD CONSTRAINT fk_students_room FOREIGN KEY (room_id) REFERENCES rooms(room_id);

ALTER TABLE maintenance
ADD CONSTRAINT fk_maintenance_room FOREIGN KEY (room_id) REFERENCES rooms(room_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_student FOREIGN KEY (student_id) REFERENCES students(student_id);

-- Task 1 Question 4
INSERT INTO room_types (type_name, rent, deposit, capacity)
VALUES
('Economy', 300.00, 150.00, 1),
('Single', 500.00, 200.00, 1),
('Standard', 600.00, 250.00, 2),
('Double', 800.00, 300.00, 2),
('Executive', 900.00, 300.00, 2),
('Triple', 1000.00, 350.00, 3),
('Premium', 1200.00, 400.00, 3),
('Family', 1500.00, 500.00, 4),
('Suite', 1800.00, 600.00, 4),
('Deluxe', 2500.00, 800.00, 6);

INSERT INTO rooms (type_id, room_no, floor_no, is_occupied)
VALUES
(1, 'A101', 1, TRUE),
(2, 'A201', 1, FALSE),
(3, 'A301', 2, FALSE),
(4, 'A401', 3, TRUE),
(5, 'B101', 1, FALSE),
(6, 'B201', 2, FALSE),
(7, 'B301', 3, TRUE),
(8, 'C101', 1, FALSE),
(9, 'C201', 2, TRUE),
(10, 'C301', 3, FALSE);

INSERT INTO students (room_id, fname, lname, status, checkin_date, email)
VALUES
(1, 'Ahmad', 'Zaki', 'ACTIVE', '2025-11-01', 'ahmad@email.com'),
(2, 'Bruce', 'Lee', 'NON_ACTIVE', '2025-10-22', 'bruce@email.com'),
(3, 'Camily', 'Hong', 'NON_ACTIVE', '2024-01-02', 'camily@email.com'),
(4, 'Darren', 'Tan', 'ACTIVE', '2025-11-08', 'darren@email.com'),
(5, 'Elisa', 'Alya', 'NON_ACTIVE', '2025-09-10', 'elisa@email.com'),
(6, 'Farah', 'Safiya', 'NON_ACTIVE', '2025-10-02', 'farah@email.com'),
(7, 'Gamuda', 'Yusof', 'ACTIVE', '2025-11-07', 'gamu@email.com'),
(8, 'Hello', 'Kitty', 'NON_ACTIVE', '2025-08-15', 'hello@email.com'),
(9, 'Isaac', 'Lau', 'ACTIVE', '2025-11-08', 'isaac@email.com'),
(10, 'Jolin', 'Tsai', 'NON_ACTIVE', '2025-07-20', 'jolin@email.com');

INSERT INTO maintenance (room_id, issue_desc, severity, status, reported_on, resolved_on)
VALUES
(1, 'AC not working', 'MEDIUM', 'OPEN', '2025-11-05', NULL),
(2, 'Plug problem', 'LOW', 'RESOLVED', '2025-10-22', '2025-10-23'),
(3, 'Fan broken', 'HIGH', 'RESOLVED', '2024-01-02', '2024-01-02'),
(4, 'Heater not working', 'MEDIUM', 'OPEN', '2025-11-09', NULL),
(5, 'Light not bright', 'LOW', 'RESOLVED', '2025-09-12', '2025-09-14'),
(6, 'Water leakage', 'HIGH', 'RESOLVED', '2025-10-03', '2025-10-03'),
(7, 'Door handle loose', 'LOW', 'OPEN', '2025-11-07', NULL),
(8, 'Window cracked', 'MEDIUM', 'RESOLVED', '2025-08-15', '2025-08-16'),
(9, 'Aircon dripping', 'MEDIUM', 'OPEN', '2025-11-08', NULL),
(10, 'Curtain stain', 'LOW', 'OPEN', '2025-07-20', '2025-07-23');


INSERT INTO payments (student_id, amount, paid_on, method, note)
VALUES
(1, 500.00, '2025-11-01', 'CASH', 'Single'),
(2, 800.00, '2025-10-22', 'CARD', 'Double Rent'),
(3, 600.00, '2024-01-05', 'FPX', 'Standard Room Rent'),
(4, 1500.00, '2025-11-08', 'TNG', 'Family'),
(5, 900.00, '2025-09-10', 'FPX', NULL),
(6, 1000.00, '2025-10-05', 'CARD', 'Triple'),
(7, 1200.00, '2025-11-07', 'CASH', 'Premium'),
(8, 1500.00, '2025-08-20', 'TNG', 'Family'),
(9, 1800.00, '2025-11-08', 'FPX', 'Suite '),
(10, 2500.00, '2025-11-09', 'CARD', 'Deluxe');

-- Task 1 Question 5
ALTER TABLE students
ADD CONSTRAINT uq_email UNIQUE (email);

CREATE TABLE test (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    note VARCHAR(100)
);

DROP TABLE IF EXISTS test;

-- Task 2 Question 2
SET SQL_SAFE_UPDATES = 0;

UPDATE rooms r
LEFT JOIN students s ON r.room_id = s.room_id
SET r.is_occupied = 
    CASE 
        WHEN s.status = 'ACTIVE' THEN TRUE
        ELSE FALSE
    END;

DELETE FROM maintenance
WHERE status = 'RESOLVED' AND reported_on < (CURDATE() - INTERVAL 60 DAY);

SET SQL_SAFE_UPDATES = 1;

-- Task 2 Question 3
SELECT * 
FROM room_types
WHERE rent BETWEEN 400 AND 800;

SELECT * 
FROM students
WHERE fname LIKE 'A%';

SELECT * 
FROM payments
WHERE method IN ('FPX', 'CARD');

SELECT * 
FROM room_types
WHERE (rent >= 1000 AND deposit >= 500) OR capacity >=3;

-- Task 2 Question 4
-- Find total number of students
SELECT COUNT(student_id) AS num_of_stud
FROM students;

-- Find the average rental fee for all room types
SELECT AVG(rent) AS average_rent
FROM room_types;

-- Combine the first name and last name, then calculate the length
SELECT 
    CONCAT(fname, ' ', lname) AS full_name,
    LENGTH(CONCAT(fname, lname)) AS name_length
FROM students;

-- Task 3 Question 1
CREATE OR REPLACE VIEW v_room_status AS
SELECT 
    r.room_no,
    rt.type_name,
    rt.rent,
    r.floor_no,
    rt.capacity,
    COUNT(s.student_id) AS n_occupants,
    SUM(CASE WHEN m.status = 'OPEN' THEN 1 ELSE 0 END) AS pending_issues,
    CASE WHEN COUNT(s.student_id) = 0 THEN 1 ELSE 0 END AS is_vacant
FROM rooms r
JOIN room_types rt ON r.type_id = rt.type_id
LEFT JOIN students s ON r.room_id = s.room_id AND s.status = 'ACTIVE'
LEFT JOIN maintenance m ON r.room_id = m.room_id
GROUP BY r.room_no, rt.type_name, rt.rent, r.floor_no, rt.capacity;

-- Query the view
SELECT * FROM v_room_status;

-- Task 3 Question 2(a)
SELECT rt.type_name, COUNT(s.student_id) AS total_students
FROM room_types rt
JOIN rooms r ON rt.type_id = r.type_id
LEFT JOIN students s ON r.room_id = s.room_id AND s.status = 'ACTIVE'
GROUP BY rt.type_name;

-- Task 3 Question 2(b)
SELECT rt.type_name,
       ROUND(AVG(rt.rent), 2) AS avg_rent,
       ROUND(SUM(rt.deposit), 2) AS total_deposit
FROM room_types rt
JOIN rooms r ON rt.type_id = r.type_id
LEFT JOIN students s ON r.room_id = s.room_id
GROUP BY rt.type_name;


-- Task 3 Question 2(c)
SELECT 
	YEAR(p.paid_on) AS year,
	MONTH(p.paid_on) AS month,
	ROUND(SUM(p.amount),2) AS total_payment
FROM payments p
GROUP BY YEAR(p.paid_on), MONTH(p.paid_on)
ORDER BY year, month;

-- Task 3 Question2(d)
SELECT 
	r.floor_no, COUNT(m.maint_id) AS open_issues
FROM maintenance m
JOIN rooms r ON m.room_id = r.room_id
WHERE m.status = 'OPEN'
GROUP BY r.floor_no
HAVING COUNT(m.maint_id) > 2;

-- Task 3 Question 3
SELECT
	-- Use CONCAT to combine type + floor
    CONCAT(rt.type_name, ' - Floor ', r.floor_no) AS room_label,  
    r.room_no,
    -- Uppercase type
    UPPER(rt.type_name) AS type_upper,
    -- Lowercase type
    LOWER(rt.type_name) AS type_lower,   
    -- Round rent
    ROUND(rt.rent, 2) AS rent,          
    -- Rent category
    CASE                                                         
        WHEN rt.rent < 500 THEN 'LOW'
        WHEN rt.rent BETWEEN 500 AND 1000 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS rent_category,
	-- Number of active students
    COUNT(s.student_id) AS n_occupants,  
    -- Open maintenance
    SUM(CASE WHEN m.status = 'OPEN' THEN 1 ELSE 0 END) AS pending_issues,  
    -- Vacant?
    CASE WHEN COUNT(s.student_id) = 0 THEN 1 ELSE 0 END AS is_vacant,  
    -- Total deposits
    ROUND(SUM(rt.deposit), 2) AS total_deposit                       
FROM rooms r
JOIN room_types rt ON r.type_id = rt.type_id
LEFT JOIN students s ON r.room_id = s.room_id AND s.status = 'ACTIVE'
LEFT JOIN maintenance m ON r.room_id = m.room_id
GROUP BY r.room_no, rt.type_name, rt.rent, r.floor_no
ORDER BY rt.type_name, r.floor_no;


