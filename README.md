# 📘 SQL Complete Notes & Practice Guide

> Personal reference for PostgreSQL — covers everything from basics to interview-level topics.
> Each section has syntax, examples, and gotchas to remember.

---

## 📌 Table of Contents

1. [DDL — Table Structure](#1-ddl--table-structure)
2. [DML — Insert / Update / Delete](#2-dml--insert--update--delete)
3. [SELECT & Filtering](#3-select--filtering)
4. [Aggregation & Grouping](#4-aggregation--grouping)
5. [Arithmetic & Expressions](#5-arithmetic--expressions)
6. [NULL Handling](#6-null-handling)
7. [Dates & Timestamps](#7-dates--timestamps)
8. [Joins & Relationships](#8-joins--relationships)
9. [Subqueries & CTEs](#9-subqueries--ctes)
10. [Window Functions](#10-window-functions)
11. [CASE WHEN](#11-case-when)
12. [Set Operations](#12-set-operations)
13. [String Functions](#13-string-functions)
14. [Indexes & Performance](#14-indexes--performance)
15. [Transactions](#15-transactions)
16. [Views](#16-views)
17. [Stored Functions & Procedures](#17-stored-functions--procedures)
18. [Triggers](#18-triggers)
19. [User & Access Management](#19-user--access-management)
20. [PostgreSQL Specific](#20-postgresql-specific)

---

## 1. DDL — Table Structure

### CREATE TABLE

```sql
CREATE TABLE person (
    id             BIGSERIAL NOT NULL PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    gender         VARCHAR(7) NOT NULL,
    date_of_birth  DATE NOT NULL,
    email          VARCHAR(150)
);
```

**Key data types:**

| Type | Use for |
|------|---------|
| `BIGSERIAL` | Auto-incrementing primary key |
| `VARCHAR(n)` | Variable-length string |
| `TEXT` | Unlimited string |
| `INT` / `BIGINT` | Integers |
| `NUMERIC(p,s)` | Exact decimal (money, prices) |
| `BOOLEAN` | true / false |
| `DATE` | Date only |
| `TIMESTAMP` | Date + time |
| `UUID` | Universally unique identifier |

> ⚠️ Use `NUMERIC` not `FLOAT` for money — FLOAT has rounding errors.

---

### CREATE TABLE with Constraints

```sql
CREATE TABLE person (
    id      BIGSERIAL NOT NULL PRIMARY KEY,
    gender  VARCHAR(10) NOT NULL,
    email   VARCHAR(150) UNIQUE,
    salary  NUMERIC(10,2),
    status  VARCHAR(10),

    CONSTRAINT gender_check   CHECK (gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT positive_salary CHECK (salary > 0),
    CONSTRAINT status_check   CHECK (status IN ('Active', 'Inactive'))
);
```

**Constraint types:**

| Constraint | Purpose |
|------------|---------|
| `NOT NULL` | Column must have a value |
| `UNIQUE` | No duplicate values |
| `PRIMARY KEY` | NOT NULL + UNIQUE, identifies each row |
| `CHECK (condition)` | Custom boolean rule |
| `REFERENCES` | Foreign key — links to another table |
| `DEFAULT value` | Fallback when no value is provided |

---

### ALTER TABLE

```sql
-- Add a constraint
ALTER TABLE person ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE person ADD CONSTRAINT age_check CHECK (age >= 18);

-- Drop a constraint
ALTER TABLE person DROP CONSTRAINT unique_email;

-- Set / remove NOT NULL
ALTER TABLE person ALTER COLUMN first_name SET NOT NULL;
ALTER TABLE person ALTER COLUMN first_name DROP NOT NULL;

-- Add a column
ALTER TABLE person ADD COLUMN phone VARCHAR(15);

-- Drop a column
ALTER TABLE person DROP COLUMN phone;

-- Rename a column
ALTER TABLE person RENAME COLUMN fname TO first_name;
```

> 💡 Name your constraints explicitly — error messages become readable and dropping them is easy.

---

### DROP TABLE / DROP DATABASE

```sql
DROP TABLE person;                     -- Error if table has dependents
DROP TABLE person CASCADE;             -- Also drops dependent FK constraints/views
DROP TABLE IF EXISTS person;           -- No error if table doesn't exist
DROP TABLE employees, departments;     -- Drop multiple at once

DROP DATABASE mydb;                    -- Must NOT be connected to it
DROP DATABASE IF EXISTS mydb;          -- Safe version
```

**Compare DELETE vs TRUNCATE vs DROP:**

| Command | Removes Data | Removes Structure | Resets Serial |
|---------|:---:|:---:|:---:|
| `DELETE FROM` | ✅ | ❌ | ❌ |
| `TRUNCATE` | ✅ | ❌ | ✅ |
| `DROP TABLE` | ✅ | ✅ | ✅ |

---

## 2. DML — Insert / Update / Delete

### INSERT

```sql
-- Single row
INSERT INTO person (first_name, last_name, gender, date_of_birth)
VALUES ('Ashutosh', 'Maurya', 'Male', DATE '1997-06-07');

-- Multiple rows
INSERT INTO person (first_name, last_name, gender, date_of_birth)
VALUES
    ('Anne',  'Smith', 'Female', '1988-01-09'),
    ('Rohan', 'Mehta', 'Male',   '1995-03-15');

-- From another table
INSERT INTO archive_person
SELECT * FROM person WHERE date_of_birth < '2000-01-01';
```

---

### ON CONFLICT DO NOTHING (Skip duplicates)

```sql
INSERT INTO person (id, first_name, email)
VALUES (1, 'Ashutosh', 'ash@gmail.com')
ON CONFLICT (id) DO NOTHING;
-- INSERT 0 0 → skipped silently
-- INSERT 0 1 → inserted successfully
```

> The column in `ON CONFLICT (col)` must have a UNIQUE or PRIMARY KEY constraint.

---

### UPSERT — ON CONFLICT DO UPDATE

```sql
INSERT INTO products (sku, name, price, stock)
VALUES ('SKU001', 'Mouse', 599.00, 50)
ON CONFLICT (sku) DO UPDATE
    SET price        = EXCLUDED.price,
        stock        = EXCLUDED.stock,
        last_updated = NOW();
```

**`EXCLUDED` keyword:**

| Reference | Meaning |
|-----------|---------|
| `EXCLUDED.price` | The value you tried to INSERT (incoming) |
| `products.price` | The value currently in the table (existing) |

```sql
-- Increment instead of replace
ON CONFLICT (sku) DO UPDATE
    SET stock = products.stock + EXCLUDED.stock;

-- Only update if new value is higher
ON CONFLICT (sku) DO UPDATE
    SET price = GREATEST(products.price, EXCLUDED.price);
```

---

### UPDATE

```sql
UPDATE person SET email = 'ash@gmail.com' WHERE id = 1;

UPDATE person
SET first_name = 'Ashutosh',
    last_name  = 'Maurya'
WHERE id = 1;

-- Update using another table's value
UPDATE products p
SET price = s.new_price
FROM supplier_feed s
WHERE p.sku = s.sku;
```

---

### DELETE

```sql
DELETE FROM person WHERE id = 1;
DELETE FROM person WHERE gender = 'Agender';
DELETE FROM person;   -- Deletes ALL rows (table structure remains)
```

---

## 3. SELECT & Filtering

### Basic SELECT

```sql
SELECT * FROM person;
SELECT first_name, last_name FROM person;
SELECT DISTINCT country_of_birth FROM person;
```

---

### ORDER BY

```sql
SELECT * FROM person ORDER BY country_of_birth;         -- ASC by default
SELECT * FROM person ORDER BY country_of_birth DESC;
SELECT * FROM person ORDER BY last_name ASC, first_name ASC;
SELECT * FROM person ORDER BY email, country_of_birth;
```

---

### LIMIT, OFFSET, FETCH

```sql
SELECT * FROM person LIMIT 10;
SELECT * FROM person OFFSET 5 LIMIT 10;

-- SQL standard way (same result)
SELECT * FROM person OFFSET 5 FETCH FIRST 10 ROWS ONLY;
SELECT * FROM person FETCH FIRST ROW ONLY;
```

---

### WHERE Clause

```sql
SELECT * FROM person WHERE gender = 'Female';
SELECT * FROM person WHERE gender = 'Female' AND country_of_birth = 'India';
SELECT * FROM person WHERE gender = 'Female' AND (country_of_birth = 'India' OR country_of_birth = 'Poland');

-- Comparison operators
-- =   equal
-- <>  not equal (also !=)
-- >   greater than
-- <   less than
-- >=  greater than or equal
-- <=  less than or equal
SELECT 1 = 1;    -- true
SELECT 1 <> 1;   -- false
SELECT 1 < 2;    -- true
```

---

### IN

```sql
-- Without IN (verbose)
SELECT * FROM person
WHERE country_of_birth = 'India'
   OR country_of_birth = 'Poland'
   OR country_of_birth = 'China';

-- With IN (clean)
SELECT * FROM person
WHERE country_of_birth IN ('India', 'Poland', 'China')
ORDER BY country_of_birth;
```

---

### BETWEEN

```sql
SELECT * FROM person WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31';
SELECT * FROM car    WHERE price BETWEEN 10000 AND 50000;
```

> `BETWEEN` is **inclusive** on both ends.

---

### LIKE & ILIKE

```sql
SELECT * FROM person WHERE email LIKE '%.com';         -- ends with .com
SELECT * FROM person WHERE email LIKE '%@gmail.%';     -- gmail addresses
SELECT * FROM person WHERE email LIKE '___%';          -- at least 3 chars

SELECT * FROM person WHERE country_of_birth LIKE  'P%';   -- case-sensitive
SELECT * FROM person WHERE country_of_birth ILIKE 'p%';   -- case-insensitive (PostgreSQL)
```

**Pattern characters:**

| Symbol | Meaning |
|--------|---------|
| `%` | Any sequence of characters (including none) |
| `_` | Exactly one character |

---

## 4. Aggregation & Grouping

### Aggregate Functions

```sql
SELECT COUNT(*)        FROM orders;           -- total rows
SELECT COUNT(email)    FROM person;           -- non-NULL emails only
SELECT SUM(price)      FROM car;
SELECT MIN(price)      FROM car;
SELECT MAX(price)      FROM car;
SELECT AVG(price)      FROM car;
SELECT ROUND(AVG(price), 2) FROM car;         -- rounded to 2 decimal places
```

---

### GROUP BY

```sql
SELECT country_of_birth, COUNT(*)
FROM person
GROUP BY country_of_birth
ORDER BY country_of_birth;

SELECT make, model, MIN(price), MAX(price)
FROM car
GROUP BY make, model;
```

> Every column in SELECT that is NOT an aggregate must appear in GROUP BY.

---

### HAVING

```sql
-- Filter AFTER grouping (like WHERE but for aggregates)
SELECT country_of_birth, COUNT(*)
FROM person
GROUP BY country_of_birth
HAVING COUNT(*) > 10
ORDER BY country_of_birth;

-- WHERE vs HAVING
SELECT department, AVG(salary)
FROM employees
WHERE status = 'Active'           -- filters rows BEFORE grouping
GROUP BY department
HAVING AVG(salary) > 50000;       -- filters groups AFTER grouping
```

---

## 5. Arithmetic & Expressions

```sql
SELECT 10 + 2;
SELECT 10 - 2;
SELECT 10 * 2;
SELECT 10 / 2;
SELECT 10 ^ 2;       -- power (100)
SELECT 10 % 3;       -- modulo (1)
SELECT FACTORIAL(5); -- 120

-- Column arithmetic
SELECT id, name, price,
       ROUND(price * 0.10, 2)              AS ten_percent,
       ROUND(price - (price * 0.10), 2)    AS after_discount
FROM car;
```

### AS Alias

```sql
SELECT
    first_name AS "First Name",
    last_name  AS "Last Name",
    ROUND(price * 0.10, 2) AS discount_amount
FROM car;
```

---

## 6. NULL Handling

### IS NULL / IS NOT NULL

```sql
SELECT * FROM person WHERE email IS NULL;
SELECT * FROM person WHERE email IS NOT NULL;
```

---

### COALESCE — Return first non-NULL value

```sql
SELECT COALESCE(null, null, 1, 10);          -- returns 1
SELECT COALESCE(email, 'not provided')        -- fallback for NULL email
FROM person;
```

---

### NULLIF — Return NULL if two values match (prevents ÷ 0)

```sql
SELECT NULLIF(10, 10);    -- NULL  (values match)
SELECT NULLIF(10, 1);     -- 10    (values differ)

-- Prevent division by zero
SELECT COALESCE(10 / NULLIF(0, 0), 0);    -- returns 0 instead of error
```

---

## 7. Dates & Timestamps

```sql
SELECT NOW();            -- 2026-04-15 13:50:32.063593+05:30
SELECT NOW()::DATE;      -- 2026-04-15
SELECT NOW()::TIME;      -- 13:50:32.063593
SELECT CURRENT_DATE;     -- 2026-04-15
SELECT CURRENT_TIME;     -- 13:50:32+05:30
```

### Interval Arithmetic

```sql
SELECT NOW() - INTERVAL '1 YEAR';
SELECT NOW() + INTERVAL '10 MONTHS';
SELECT NOW() + INTERVAL '3 DAYS';
SELECT (NOW() + INTERVAL '10 MONTHS')::DATE;    -- cast to date only
```

### EXTRACT

```sql
SELECT EXTRACT(YEAR    FROM NOW());   -- 2026
SELECT EXTRACT(MONTH   FROM NOW());
SELECT EXTRACT(DAY     FROM NOW());
SELECT EXTRACT(DOW     FROM NOW());   -- day of week (0=Sunday)
SELECT EXTRACT(CENTURY FROM NOW());
```

### AGE Function

```sql
SELECT
    first_name,
    date_of_birth,
    AGE(NOW(), date_of_birth) AS age
FROM person;
-- Returns: 28 years 9 mons 15 days
```

---

## 8. Joins & Relationships

### Setup Example

```sql
CREATE TABLE departments (
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    id            BIGSERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    department_id INT REFERENCES departments(id)
);
```

---

### INNER JOIN — Only matching rows

```sql
SELECT e.name, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id;
-- Returns only employees who have a matching department
```

---

### LEFT JOIN — All left rows + matching right

```sql
SELECT e.name, d.name AS department
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
-- Returns ALL employees; department is NULL if no match
```

---

### RIGHT JOIN — All right rows + matching left

```sql
SELECT e.name, d.name AS department
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.id;
-- Returns ALL departments; employee is NULL if no match
```

---

### FULL OUTER JOIN — All rows from both tables

```sql
SELECT e.name, d.name AS department
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.id;
-- Returns everything; NULLs where there's no match on either side
```

---

### SELF JOIN — Table joined with itself

```sql
-- Find employees and their managers (both in same table)
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

---

### CROSS JOIN — Every combination

```sql
SELECT a.color, b.size
FROM colors a
CROSS JOIN sizes b;
-- Returns cartesian product (every color × every size)
```

---

### Join Summary

| Join Type | Returns |
|-----------|---------|
| `INNER JOIN` | Only rows with matches in BOTH tables |
| `LEFT JOIN` | All left rows; NULL for non-matching right |
| `RIGHT JOIN` | All right rows; NULL for non-matching left |
| `FULL OUTER JOIN` | All rows from both; NULL where no match |
| `CROSS JOIN` | Every possible combination |
| `SELF JOIN` | Rows from a table joined to itself |

---

## 9. Subqueries & CTEs

### Subquery in WHERE

```sql
-- Find employees who earn more than the average salary
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### Subquery in FROM (Derived Table)

```sql
SELECT dept, avg_salary
FROM (
    SELECT department AS dept, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) AS dept_averages
WHERE avg_salary > 60000;
```

### Subquery in SELECT

```sql
SELECT
    name,
    salary,
    (SELECT AVG(salary) FROM employees) AS company_avg
FROM employees;
```

---

### EXISTS / NOT EXISTS

```sql
-- Departments that have at least one employee
SELECT name FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.id
);

-- Departments with NO employees
SELECT name FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.id
);
```

---

### CTE — WITH … AS (Common Table Expression)
A CTE (Common Table Expression) is a temporary named result set that exists only for the duration of a single SQL query.

```sql
-- Basic CTE
WITH high_earners AS (
    SELECT name, salary, department
    FROM employees
    WHERE salary > 80000
)
SELECT * FROM high_earners ORDER BY salary DESC;

-- Multiple CTEs
WITH
    dept_totals AS (
        SELECT department_id, SUM(salary) AS total
        FROM employees
        GROUP BY department_id
    ),
    dept_avg AS (
        SELECT department_id, AVG(salary) AS average
        FROM employees
        GROUP BY department_id
    )
SELECT d.name, t.total, a.average
FROM departments d
JOIN dept_totals t ON d.id = t.department_id
JOIN dept_avg    a ON d.id = a.department_id;
```

### Recursive CTE — Hierarchical data (org charts, trees)

```sql
WITH RECURSIVE org_chart AS (
    -- Base case: top-level employees (no manager)
    SELECT id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: employees under each manager
    SELECT e.id, e.name, e.manager_id, o.level + 1
    FROM employees e
    JOIN org_chart o ON e.manager_id = o.id
)
SELECT * FROM org_chart ORDER BY level;
```

---

## 10. Window Functions

> Window functions compute values across a set of rows **without collapsing them** like GROUP BY does.

```sql
-- Syntax
function_name() OVER (
    PARTITION BY column   -- divide rows into groups
    ORDER BY column       -- order within each group
)
```

---

### ROW_NUMBER, RANK, DENSE_RANK

```sql
SELECT
    name,
    department,
    salary,
    ROW_NUMBER()  OVER (PARTITION BY department ORDER BY salary DESC) AS row_num,
    RANK()        OVER (PARTITION BY department ORDER BY salary DESC) AS rank,
    DENSE_RANK()  OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank
FROM employees;
```

**Difference between RANK and DENSE_RANK:**

| Name | Salary | RANK | DENSE_RANK |
|------|--------|------|------------|
| A | 90000 | 1 | 1 |
| B | 90000 | 1 | 1 |
| C | 80000 | 3 | 2 ← no gap |
| D | 70000 | 4 | 3 |

---

### LAG & LEAD — Access previous/next row

```sql
SELECT
    order_date,
    amount,
    LAG(amount)  OVER (ORDER BY order_date) AS previous_amount,
    LEAD(amount) OVER (ORDER BY order_date) AS next_amount,
    amount - LAG(amount) OVER (ORDER BY order_date) AS change
FROM orders;
```

---

### SUM / AVG OVER — Running totals

```sql
-- Running total
SELECT
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM orders;

-- Sum per partition (without collapsing)
SELECT
    name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department) AS dept_total
FROM employees;
```

---

### NTILE — Divide into buckets

```sql
-- Split employees into 4 salary quartiles
SELECT name, salary,
    NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;
```

---

## 11. CASE WHEN

```sql
-- Simple conditional
SELECT
    name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'Senior'
        WHEN salary >= 60000  THEN 'Mid'
        ELSE 'Junior'
    END AS level
FROM employees;

-- In aggregation
SELECT
    COUNT(*) AS total,
    COUNT(CASE WHEN gender = 'Male'   THEN 1 END) AS males,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS females
FROM person;

-- In ORDER BY
SELECT name, status
FROM orders
ORDER BY
    CASE status
        WHEN 'Urgent'  THEN 1
        WHEN 'Normal'  THEN 2
        ELSE 3
    END;
```

---

## 12. Set Operations

```sql
-- UNION — combine results, remove duplicates
SELECT name FROM employees_2023
UNION
SELECT name FROM employees_2024;

-- UNION ALL — combine results, keep duplicates (faster)
SELECT name FROM employees_2023
UNION ALL
SELECT name FROM employees_2024;

-- INTERSECT — only rows that appear in BOTH
SELECT name FROM employees_2023
INTERSECT
SELECT name FROM employees_2024;

-- EXCEPT — rows in first query but NOT in second
SELECT name FROM employees_2023
EXCEPT
SELECT name FROM employees_2024;
```

> All set operations require the same number of columns and compatible data types.

---

## 13. String Functions

```sql
SELECT UPPER('ashutosh');                        -- ASHUTOSH
SELECT LOWER('ASHUTOSH');                        -- ashutosh
SELECT LENGTH('Ashutosh');                       -- 8
SELECT TRIM('  hello  ');                        -- 'hello'
SELECT LTRIM('  hello');                         -- 'hello'
SELECT RTRIM('hello  ');                         -- 'hello'
SELECT CONCAT('Ash', ' ', 'Maurya');             -- Ash Maurya
SELECT 'Ash' || ' ' || 'Maurya';                -- Ash Maurya (PostgreSQL shorthand)
SELECT SUBSTRING('Ashutosh' FROM 1 FOR 3);       -- Ash
SELECT REPLACE('Hello World', 'World', 'SQL');   -- Hello SQL
SELECT POSITION('tosh' IN 'Ashutosh');           -- 5
SELECT LEFT('Ashutosh', 3);                      -- Ash
SELECT RIGHT('Ashutosh', 3);                     -- osh
SELECT LPAD('5', 3, '0');                        -- 005
SELECT RPAD('5', 3, '0');                        -- 500
SELECT SPLIT_PART('a,b,c', ',', 2);              -- b
SELECT REVERSE('hello');                         -- olleh
SELECT INITCAP('ashutosh maurya');               -- Ashutosh Maurya
```

---

## 14. Indexes & Performance

### CREATE INDEX

```sql
-- Single column index
CREATE INDEX idx_person_email ON person(email);

-- Composite index (multi-column)
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Unique index
CREATE UNIQUE INDEX idx_unique_phone ON person(phone);

-- Partial index (only index active records)
CREATE INDEX idx_active_employees ON employees(id) WHERE status = 'Active';

-- Drop index
DROP INDEX idx_person_email;
```

> Indexes speed up reads but slow down writes. Add indexes on columns used in WHERE, JOIN, and ORDER BY.

---

### EXPLAIN & EXPLAIN ANALYZE

```sql
-- Show the query plan (estimated cost)
EXPLAIN
SELECT * FROM person WHERE email = 'ash@gmail.com';

-- Show actual execution time
EXPLAIN ANALYZE
SELECT * FROM person WHERE email = 'ash@gmail.com';
```

**Key things to look for:**
- `Seq Scan` → full table scan (slow on large tables — add an index)
- `Index Scan` → using an index (fast)
- `cost=0.00..8.27` → estimated startup..total cost
- `rows=` → estimated number of rows returned

---

## 15. Transactions

```sql
-- Basic transaction
BEGIN;
    UPDATE accounts SET balance = balance - 500 WHERE id = 1;
    UPDATE accounts SET balance = balance + 500 WHERE id = 2;
COMMIT;    -- save both changes permanently

-- Rollback if something goes wrong
BEGIN;
    DELETE FROM orders WHERE id = 999;
ROLLBACK;  -- undo the delete
```

### SAVEPOINT — Partial rollback

```sql
BEGIN;
    INSERT INTO orders (product, amount) VALUES ('Laptop', 999);
    SAVEPOINT after_insert;

    UPDATE inventory SET stock = stock - 1 WHERE product = 'Laptop';
    -- something went wrong with the update

ROLLBACK TO after_insert;   -- undo just the UPDATE
COMMIT;                     -- keep the INSERT
```

> Without a transaction, every statement auto-commits. Wrap related changes in `BEGIN...COMMIT`.

---

## 16. Views

```sql
-- Create a view
CREATE VIEW active_employees AS
SELECT id, name, department, salary
FROM employees
WHERE status = 'Active';

-- Query a view like a table
SELECT * FROM active_employees;
SELECT * FROM active_employees WHERE department = 'Engineering';

-- Replace/update a view
CREATE OR REPLACE VIEW active_employees AS
SELECT id, name, department, salary, email
FROM employees
WHERE status = 'Active';

-- Drop a view
DROP VIEW active_employees;
DROP VIEW IF EXISTS active_employees;
```

> Views are saved queries — they don't store data. Every time you query a view, it runs the underlying SELECT.

---

## 17. Stored Functions & Procedures

### Function (returns a value)

```sql
CREATE OR REPLACE FUNCTION get_full_name(p_id INT)
RETURNS VARCHAR AS $$
DECLARE
    full_name VARCHAR;
BEGIN
    SELECT first_name || ' ' || last_name
    INTO full_name
    FROM person
    WHERE id = p_id;

    RETURN full_name;
END;
$$ LANGUAGE plpgsql;

-- Call it
SELECT get_full_name(1);
```

---

### Procedure (no return value)

```sql
CREATE OR REPLACE PROCEDURE update_salary(
    p_id     INT,
    p_amount NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE employees
    SET salary = salary + p_amount
    WHERE id = p_id;
    COMMIT;
END;
$$;

-- Call it
CALL update_salary(1, 5000);
```

---

## 18. Triggers

```sql
-- Step 1: Create the trigger function
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO salary_audit (employee_id, old_salary, new_salary, changed_at)
        VALUES (OLD.id, OLD.salary, NEW.salary, NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Attach the trigger to the table
CREATE TRIGGER salary_change_trigger
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_salary_change();

-- Drop a trigger
DROP TRIGGER salary_change_trigger ON employees;
```

**Trigger timing options:**

| Option | When it fires |
|--------|--------------|
| `BEFORE` | Before the row is changed |
| `AFTER` | After the row is changed |
| `INSTEAD OF` | Used on views |
| `FOR EACH ROW` | Fires once per affected row |
| `FOR EACH STATEMENT` | Fires once per SQL statement |

---

## 19. User & Access Management

```sql
-- Create role/user
CREATE ROLE ashu WITH LOGIN PASSWORD '1234';
CREATE USER ashu WITH PASSWORD '1234';   -- same as above

-- Create database
CREATE DATABASE mydb;

-- Grant access
GRANT ALL PRIVILEGES ON DATABASE mydb TO ashu;
GRANT SELECT, INSERT ON person TO ashu;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ashu;

-- Revoke access
REVOKE INSERT ON person FROM ashu;

-- Connect to a database (psql)
\c mydb
\c postgres

-- Drop user
DROP ROLE ashu;
```

---

## 20. PostgreSQL Specific

### Useful psql Commands

```sql
\l            -- list all databases
\c dbname     -- connect to database
\dt           -- list tables
\d tablename  -- describe table (columns, types, constraints)
\d+ tablename -- detailed description including indexes
\di           -- list indexes
\df           -- list functions
\du           -- list users/roles
\i file.sql   -- run SQL file
\x            -- toggle expanded display (useful for wide rows)
\q            -- quit psql
```

---

### System Catalog Queries

```sql
-- View all constraints on a table
SELECT conname AS constraint_name,
       contype AS type,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'person'::regclass;

-- View all indexes on a table
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'person';

-- View active connections
SELECT pid, usename, datname, state, query
FROM pg_stat_activity;

-- Kill a connection
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'mydb' AND pid <> pg_backend_pid();
```

---

### JSONB (PostgreSQL JSON support)

```sql
CREATE TABLE users (
    id   BIGSERIAL PRIMARY KEY,
    data JSONB
);

INSERT INTO users (data)
VALUES ('{"name": "Ashutosh", "skills": ["SQL", "Python"], "age": 28}');

-- Query JSONB fields
SELECT data->>'name'       FROM users;    -- text
SELECT data->'skills'      FROM users;    -- JSON
SELECT data->'skills'->0   FROM users;    -- first skill

-- Filter by JSONB value
SELECT * FROM users WHERE data->>'name' = 'Ashutosh';

-- JSONB contains operator
SELECT * FROM users WHERE data @> '{"age": 28}';
```

---

## 🔑 Interview Cheat Sheet

### Most Asked Topics

| Topic | Key Points |
|-------|-----------|
| Joins | Know all 5 types; explain with examples |
| Window functions | `ROW_NUMBER`, `RANK`, `LAG/LEAD`, `PARTITION BY` |
| CTEs | Cleaner than nested subqueries; use for readability |
| GROUP BY vs HAVING | WHERE filters rows, HAVING filters groups |
| TRUNCATE vs DELETE | TRUNCATE is faster, resets serial, can't rollback in some DBs |
| Index | Speeds up reads, slows down writes; use on WHERE/JOIN/ORDER columns |
| Transaction | ACID — Atomicity, Consistency, Isolation, Durability |
| COALESCE | First non-NULL value |
| NULLIF | Returns NULL if two values are equal |
| UPSERT | `ON CONFLICT DO UPDATE` with `EXCLUDED` keyword |

---

### Common Interview Patterns

```sql
-- 1. find duplicate record in table
SELECT c1, c2, COUNT(*) FROM orders GROUP BY c1, c2 HAVING COUNT(*) > 1;

-- 2. retrieve the second highest salary of the employee
SELECT MAX(salary) AS highestSalary FROM employee WHERE salary < (SELECT MAX(salary) FROM employee);

-- 3. retrieve third highest salary of employee
SELECT salary FROM employee ORDER BY salary DESC FROM employee LIMIT 3 OFFSET 2;

-- using dense rank
SELECT salary FROM (
    SELECT salary DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk FROM employee
) t
WHERE rnk = 3;

-- 4. calculate total revenue per product
SELECT product_id, SUM(quanity*price) AS totalRevenue FROM sales GROUP BY product_id;

-- 5. get top 3 highest paid employee
SELECT TOP 3 * FROM employee ORDER BY salary;

-- 6. find customer who purchage product but never returned
SELECT DISTINCT c.customer_id FROM customer
JOIN order o
ON c.customer_id = o.custormer_id
WHERE c.customer_id NOT IN (SELECT * FROM return);


-- 7. show the count of orders per each customer
SELECT customer_id, COUNT(*) AS totalCount FROM orders GROUP BY customer_id;

-- 8. retrieve all employees who joined in 2023
SELECT * FROM employees WHERE YEAR(hired_date) = 2023;

-- 9. calculate the average order value per customer
SELECT customer_id, AVG(amount) AS averageValue FROM order GROUP BY customer_id;

-- 10. get the latest order placed by each customer
SELECT customer_id, MAX(date) FROM order GROUP BY customer_id;

-- 11. reverse gender in table
UPDATE employees
SET gender = CASE
    WHEN gender = 'Male' THEN 'Female'
    WHEN gender = 'Female' THEN 'Male'
END;

-- 12. Self join - find Employees Whose Salary Is Greater Than Their Manager's
SELECT
    e.name AS employee,
    e.salary AS employee_salary,
    m.name AS manager,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.id
WHERE e.salary > m.salary;

```

---

*Built with ❤️ for interview prep. Practice every concept, run the queries yourself.*
