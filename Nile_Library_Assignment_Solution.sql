-- Nile Library Management System
-- Oracle SQL Assignment
-- Note: Run the provided Nile_Library_Inserts.txt INSERT statements under Step 2.
-- Then execute this file in order.

-- Step 1: Create the four tables
CREATE TABLE categories (
    category_id NUMBER,
    category_name VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_categories PRIMARY KEY (category_id)
);

CREATE TABLE members (
    member_id NUMBER,
    full_name VARCHAR2(150) NOT NULL,
    email VARCHAR2(200),
    phone VARCHAR2(30),
    city VARCHAR2(100),
    joined_on DATE DEFAULT SYSDATE,
    points NUMBER DEFAULT 0,
    CONSTRAINT pk_members PRIMARY KEY (member_id)
);

CREATE TABLE books (
    book_id NUMBER,
    title VARCHAR2(200) NOT NULL,
    author VARCHAR2(150),
    category_id NUMBER,
    price NUMBER(8,2),
    copies_available NUMBER,
    published_year NUMBER,
    CONSTRAINT pk_books PRIMARY KEY (book_id),
    CONSTRAINT fk_books_categories FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE loans (
    loan_id NUMBER,
    member_id NUMBER,
    book_id NUMBER,
    loaned_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT pk_loans PRIMARY KEY (loan_id),
    CONSTRAINT fk_loans_members FOREIGN KEY (member_id)
        REFERENCES members(member_id),
    CONSTRAINT fk_loans_books FOREIGN KEY (book_id)
        REFERENCES books(book_id)
);

-- Step 2: Insert the supplied assignment data
INSERT INTO categories VALUES (1, 'Technology');
INSERT INTO categories VALUES (2, 'Fiction');
INSERT INTO categories VALUES (3, 'History');

INSERT INTO members VALUES (1, 'Ahmed Hassan', 'ahmed.hassan@mail.com',
    '01012345678', 'Cairo', ADD_MONTHS(SYSDATE, -14), 250);
INSERT INTO members VALUES (2, 'Mona Ali', 'mona.ali@mail.com',
    '01123456789', 'Cairo', ADD_MONTHS(SYSDATE, -9), 120);
INSERT INTO members VALUES (3, 'Youssef Samir', 'youssef@gmail.com',
    '01234567890', 'Giza', ADD_MONTHS(SYSDATE, -3), 0);
INSERT INTO members VALUES (4, 'Amira Tarek', 'amira@mail.com',
    '01098765432', 'Alexandria', ADD_MONTHS(SYSDATE, -20), 80);
INSERT INTO members VALUES (5, 'Karim Nabil', 'karim@gmail.com', NULL,
    'Cairo', ADD_MONTHS(SYSDATE, -7), 150);
INSERT INTO members VALUES (6, 'Sara Mahmoud', 'sara@mail.com',
    '01155551234', 'Giza', ADD_MONTHS(SYSDATE, -2), 400);
INSERT INTO members VALUES (7, 'Omar Fathy', 'omar@yahoo.com',
    '01277778888', 'Cairo', ADD_MONTHS(SYSDATE, -12), 95);
INSERT INTO members VALUES (8, 'Laila Adel', 'laila@mail.com',
    '01066669999', 'Mansoura', ADD_MONTHS(SYSDATE, -1), 30);

INSERT INTO books VALUES (1, 'Algorithms Made Simple', 'Omar Salem', 1,
    450.00, 5, 2020);
INSERT INTO books VALUES (2, 'Ancient Egypt', 'Hana Mostafa', 3, 320.00,
    3, 2018);
INSERT INTO books VALUES (3, 'Pocket SQL Guide', 'Nadia Fouad', 1,
    85.00, 12, 2022);
INSERT INTO books VALUES (4, 'Spring Boot in Action', 'Tarek Hegazy', 1,
    500.00, 4, 2023);
INSERT INTO books VALUES (5, 'Complete Oracle Reference', 'Mina Gerges',
    1, 1250.00, 2, 2021);
INSERT INTO books VALUES (6, 'The Desert Night', 'Laila Hamdy', 2,
    150.00, 0, 2015);
INSERT INTO books VALUES (7, 'Egyptian History', 'Hana Mostafa', 3,
    280.00, 6, 2019);
INSERT INTO books VALUES (8, 'City of Lights', NULL, 2, 199.99, 7, 2017);
INSERT INTO books VALUES (9, 'Clean Code Basics', 'Youssef Anwar', 1,
    600.00, 8, 2020);
INSERT INTO books VALUES (10, 'The Last Pharaoh', 'Amr Zaki', 3,
    100.00, 1, 2016);

INSERT INTO loans (loan_id, member_id, book_id) VALUES (1, 1, 1);
INSERT INTO loans (loan_id, member_id, book_id) VALUES (2, 2, 3);
INSERT INTO loans (loan_id, member_id, book_id) VALUES (3, 3, 2);
INSERT INTO loans (loan_id, member_id, book_id) VALUES (4, 1, 4);
INSERT INTO loans (loan_id, member_id, book_id) VALUES (5, 6, 5);
INSERT INTO loans (loan_id, member_id, book_id) VALUES (6, 7, 9);

-- Step 3: Commit, then add ISBN and returned_at columns
COMMIT;

ALTER TABLE books ADD (isbn VARCHAR2(20));
ALTER TABLE loans ADD (returned_at TIMESTAMP);

-- Step 4: Return one loan; increase Fiction book prices by 10%; save changes
UPDATE loans
SET status = 'RETURNED',
    returned_at = SYSTIMESTAMP
WHERE loan_id = 1; -- Return loan 1 (Ahmed Hassan borrowing book 1)

UPDATE books
SET price = price * 1.10
WHERE category_id = (
    SELECT category_id
    FROM categories
    WHERE category_name = 'Fiction'
);

COMMIT;

-- Step 5: Simulate an accidental delete, inspect, then undo it
DELETE FROM books;

-- Check the table before rollback (this should show zero rows before rollback)
SELECT * FROM books;

ROLLBACK;

-- Prove the rows are back
SELECT * FROM books;

-- TRUNCATE is DDL in Oracle and causes an implicit COMMIT; therefore this
-- DELETE/ROLLBACK recovery technique cannot undo TRUNCATE.

-- Step 6: Delete one member who has never borrowed a book; rename LOANS
DELETE FROM members
WHERE member_id = 4; -- Amira Tarek has never borrowed a book

ALTER TABLE loans RENAME TO book_loans;
COMMIT;

-- Step 7: Show all member data
SELECT * FROM members;

-- Step 8: Show only title, author, and price with requested headings
SELECT title AS "Book Title",
       author AS "Author",
       price AS "Price"
FROM books;

-- Step 9: Show each member city once
SELECT DISTINCT city
FROM members;

-- Step 10: Show book prices including 14% VAT, rounded to 2 decimal places
SELECT title,
       ROUND(price * 1.14, 2) AS price_including_vat
FROM books;

-- Step 11: Members who live in Cairo
SELECT *
FROM members
WHERE city = 'Cairo';

-- Rewrite with lowercase. In Oracle, ordinary string comparisons are
-- case-sensitive, so 'cairo' does not match 'Cairo' unless case is normalized.
SELECT *
FROM members
WHERE city = 'cairo';

-- Step 12: Books priced above 300 and available in the library
SELECT *
FROM books
WHERE price > 300
  AND copies_available > 0;

-- Step 13: Books priced from 100 to 500 inclusive
-- BETWEEN includes both boundaries, so a book priced exactly 500 is included.
SELECT *
FROM books
WHERE price BETWEEN 100 AND 500;

-- Step 14: Members from Cairo, Giza, or Alexandria (two ways)
SELECT *
FROM members
WHERE city IN ('Cairo', 'Giza', 'Alexandria');

SELECT *
FROM members
WHERE city = 'Cairo'
   OR city = 'Giza'
   OR city = 'Alexandria';

-- IN is cleaner and shorter for checking several values.

-- Step 15: Titles starting with A and titles ending with y
SELECT *
FROM books
WHERE title LIKE 'A%';

SELECT *
FROM books
WHERE title LIKE '%y';

-- Step 16: Members with no phone number
SELECT *
FROM members
WHERE phone IS NULL;

-- phone = NULL does not work because NULL represents an unknown/missing value;
-- use IS NULL (or IS NOT NULL) to test for it.

-- Step 17: Most expensive books first; ties sorted by title alphabetically
SELECT *
FROM books
ORDER BY price DESC, title ASC;

-- Step 18: Contact sheet for Cairo/Giza members with a phone number,
-- highest points first, using understandable column names
SELECT full_name AS "Member Name",
       phone AS "Phone Number",
       city AS "City",
       points AS "Reward Points"
FROM members
WHERE city IN ('Cairo', 'Giza')
  AND phone IS NOT NULL
ORDER BY points DESC;

-- Step 19: Greeting line; uppercase name and length; email part before @
SELECT full_name || ' — ' || city AS greeting_line,
       UPPER(full_name) AS uppercase_name,
       LENGTH(full_name) AS name_length,
       SUBSTR(email, 1, INSTR(email, '@') - 1) AS email_username
FROM members;

-- Step 20: Joined more than 6 months ago and have fewer than 200 points
SELECT *
FROM members
WHERE joined_on < ADD_MONTHS(SYSDATE, -6)
  AND points < 200;

-- Step 21: Predict row counts in comments, then run each query.
-- Query A returns 5 rows: all 4 Cairo members plus Sara from Giza (400 points).
-- AND has precedence, so this means city='Cairo' OR (city='Giza' AND points>=100).
SELECT *
FROM members
WHERE city = 'Cairo' OR city = 'Giza' AND points >= 100;

-- Query B returns 4 rows: Ahmed, Mona, Karim, and Sara (Cairo/Giza and points >= 100).
SELECT *
FROM members
WHERE (city = 'Cairo' OR city = 'Giza') AND points >= 100;

-- Query C returns 0 rows because BETWEEN 500 AND 100 has its lower bound above its upper bound.
SELECT *
FROM books
WHERE price BETWEEN 500 AND 100;

-- Query D raises ORA-00904 (invalid identifier), because a SELECT-list
-- alias generally cannot be referenced in the WHERE clause at the same query level.
SELECT title, price * 1.14 AS price_vat
FROM books
WHERE price_vat > 500;

-- Corrected version of Query D, if you want to run a working version:
SELECT title, price * 1.14 AS price_vat
FROM books
WHERE price * 1.14 > 500;
