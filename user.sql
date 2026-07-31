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


-- add a constraint
ALTER TABLE person ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE person ADD CONSTRAINT positive_salary CHECK (salary > 0);

ALTER TABLE person DROP CONSTRAINT gender_check;

-- set remove not null
ALTER TABLE person ALTER COLUMN gender SET NOT NULL;

-- add new column
ALTER TABLE person ADD COLUMN phone VARCHAR(10);

-- drop column
ALTER TABLE person DROP COLUMN phone;

-- rename a column
ALTER TABLE person RENAME COLUMN name TO first_name;


-- order by
SELECT * FROM person ORDER BY salary DESC;

-- limit offset fetch
SELECT * FROM person OFFSET 5 LIMIT 10;
SELECT * FROM person OFFSET 5 FETCH FIRST 10 ROW ONLY;

-- where clause
SELECT * FROM person WHERE gender = 'Male' AND id = 10;

-- having
SELECT department, AVG(salary) 
FROM employees
WHERE status = 'Active'
GROUP BY department
HAVING AVG(salary) > 5000;

-- db.collection.aggregate([
--   { $match: {} },      // WHERE
--   { $group: {} },      // GROUP BY
--   { $match: {} },      // HAVING
--   { $sort: {} },       // ORDER BY
--   { $limit: 10 }       // LIMIT
-- ])

SELECT * FROM person p
JOIN car c 
ON p.car_id = c.id