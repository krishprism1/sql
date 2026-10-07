sudo -u postgres psql
\l
CREATE DATABASE performance_lab;
\l
\c performance_lab

CREATE USER performance_user WITH PASSWORD 'performance_password';
GRANT ALL PRIVILEGES ON DATABASE performance_lab TO performance_user;

\c performance_lab

GRANT ALL ON SCHEMA public TO performance_user;
GRANT ALL ON ALL TABLES IN SCHEMA public TO performance_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO performance_user;

DATABASE_URL="postgresql://performance_user:performance_password@localhost:5432/performance_lab"


CREATE ROLE ashu WITH LOGIN PASSWORD '1234';

CREATE DATABASE test;
GRANT ALL PRIVILEGES ON DATABASE test TO ashu;


ALTER DATABASE test OWNER TO ashu;

GRANT ALL ON DATABASE test TO ashu;

GRANT ALL ON SCHEMA public TO ashu;

ALTER SCHEMA public OWNER TO ashu;


SELECT current_user;
\c test
\c postgres

sudo -u postgres psql
psql -U ashu -d test

DROP DATABASE test;
 
# create table
CREATE TABLE person (
    id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(7),
    date_of_birth DATE
);

\d
\d person

\i /home/ashu/Documents/db/postgres/faang/department.sql
# create table with constraints
CREATE TABLE person (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(7) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(150)
);

\dt

# insert into table person
test=# INSERT INTO person(first_name, last_name, gender, date_of_birth)
test-# VALUES ('Anne', 'Smith', 'FEMALE', date '1988-01-09);
INSERT 0 1

INSERT INTO person (
    first_name,
    last_name,
    gender,
    date_of_birth,
    country_of_birth
)INSERT INTO person (
    first_name,
    last_name,
    gender,
    date_of_birth,
    country_of_birth
)
VALUES (
    'Ashutosh',
    'Maurya',
    'MALE',
    DATE '1997-06-07',
    'India'
);
VALUES (
    'Ashutosh',
    'Maurya',
    'MALE',
    DATE '1997-06-07',
    'India'
);


INSERT INTO person (
    first_name,
    last_name,
    gender,
    date_of_birth
)
VALUES (
    'Anne',
    'Smith',
    'FEMALE',
    DATE '1988-01-09'
);

# select from table
- SELECT * FROM person;
- SELECT first_name, last_name FROM person;
- SELECT * FROM person ORDER BY country_of_birth; //by default ASC
- SELECT * FROM person ORDER BY id DESC
- SELECT * FROM person ORDER BY country_of_birth DESC;

- SELECT * FROM person ORDER BY email, country_of_birth;

- SELECT DISTINCT country_of_birth FROM person ORDER BY country_of_birth;


# where clause
- SELECT * FROM person WHERE gender = 'Female';
- SELECT * FROM person WHERE gender = 'Female' AND country_of_birth = 'Poland';
- SELECT * FROM person WHERE gender = 'Female' AND (country_of_birth = 'Poland' OR country_of_birth = 'China);
- SELECT * FROM person WHERE gender = 'Female' AND (country_of_birth = 'Poland' OR country_of_birth = 'China') AND last_name = 'Bodle';

# comparison operator
- SELECT 1 = 1; // true
- SELECT 1 <= 2; // true
- SELECT 1 < 2; // false
- SELECT 1 <> 1; //false

# limit, offset & fetch
- SELECT * FROM person LIMIT 10;
- SELECT * FROM person OFFSET 5 LIMIT 10;

same this using fetch keyword
- SELECT * FROM person OFFSET 5 FETCH FIRST 5 ROW ONLY;

- SELECT * FROM person OFFSET 5 FETCH FIRST 1 ROW ONLY;
- SELECT * FROM person OFFSET 5 FETCH FIRST ROW ONLY;

# in
- SELECT * FROM person WHERE country_of_birth = 'Poland' OR country_of_birth= 'China' OR country_of_birth = 'France';

same thing can do using in keyword
- SELECT * FROM person WHERE country_of_birth IN ('China', 'Poland', 'France);
- SELECT * FROM person WHERE country_of_birth IN ('China', 'Poland', 'France') ORDER BY country_of_birth;

# between
- SELECT * FROM person WHERE date_of_birth BETWEEN '2025-09-02' AND '2025-11-02';

# like & ilike
- SELECT * FROM person WHERE email LIKE '%.com';
- SELECT * FROM person WHERE email LIKE '%bloomberg.com';
- SELECT * FROM person WHERE email LIKE '%google.%';
- SELECT * FROM person WHERE email LIKE '___%';

- SELECT * FROM person WHERE country_of_birth LIKE 'P%'; //case senstive
- SELECT * FROM person WHERE country_of_birth ILIKE 'p%';

# group by
- SELECT country_of_birth, COUNT(*) FROM person GROUP BY country_of_birth;
- SELECT country_of_birth, COUNT(*) FROM person GROUP BY country_of_birth ORDER BY country_of_birth;

# group by having
- SELECT country_of_birth, COUNT(*) FROM person GROUP BY country_of_birth HAVING COUNT(*) >10  ORDER BY country_of_birth;


# calculate min, max, average & sum
- SELECT MAX(price) FROM car;
- SELECT MIN(price) FROM car;
- SELECT AVG(price) FROM car;
- SELECT ROUND(AVG(price)) FROM car;
- SELECT name, MIN(price) FROM car GROUP BY name;
- SELECT name, model, MIN(price) FROM car GROUP BY name, model;

- SELECT SUM(price) FROM car;
- SELECT name, SUM(price) FROM car GROUP BY name;

# basic arithmetic operators
- SELECT 10+2;
- SELECT 10-2;
- SELECT 10*2;
- SELECT 10/2;
- SELECT 10^2;
- SELECT FACTORIAL(5);
- SELECT 10 % 3;

# arithmetic operators round
- SELECT id, name, model, price, price * .10 FROM car;
- SELECT id, name, model, price, ROUND(price * .10) FROM car;
- SELECT id, name, model, price, ROUND(price * .10), ROUND(price - (price * .10))  FROM car;
- SELECT id, name, model, price, ROUND(price * .10), ROUND(price - (price * .10), 2)  FROM car;

# alias
- SELECT id, name, model, price AS original_price, ROUND(price * .10) AS ten_percent, ROUND(price - (price * .10),2) AS discount_after_10_percent  FROM car;

# coalesce - handle null values
each output 1
- SELECT COALESCE(1);
- SELECT COALESCE(1) AS number;
- SELECT COALESCE(null, 1) AS number;
- SELECT COALESCE(null,null, null, 1) AS number;
- SELECT COALESCE(null,null, null, 1, 10) AS number;

- SELECT COALESCE(email, 'Email not provided') FROM person;

# nullif - takle division by zero
- SELECT 10/0;
- SELECT NULLIF(10, 10); // null
- SELECT NULLIF(10, 1); // 10

- SELECT 10 / NULLIF(2, 1); // 5
- SELECT COALESCE(10 / NULLIF(0, 0),0);

# timestamps and dates
- SELECT NOW(); // 2026-04-15 13:50:32.063593+05:30
- SELECT NOW()::DATE; // 2026-04-15
-  SELECT NOW()::TIME; // 13:51:36.418508

# adding and subtracting with dates
- SELECT NOW() - INTERVAL '1 YEAR';
- SELECT NOW() + INTERVAL '10 YEAR';
- SELECT NOW() + INTERVAL '10 MONTHS';
- SELECT NOW()::DATE + INTERVAL '10 MONTHS';
- SELECT (NOW() + INTERVAL '10 MONTHS')::DATE;

# extracting fields
- SELECT EXTRACT(YEAR FROM NOW()); //2026
- SELECT EXTRACT( DAY FROM NOW());
- SELECT EXTRACT(DOW FROM NOW());
- SELECT EXTRACT(CENTURY FROM NOW());

# age function
- SELECT first_name, last_name, gender, country_of_birth, date_of_birth, AGE(NOW(), date_of_birth) AS age from person;

# adding constraints
- ALTER TABLE person ADD CONSTRAINT unique_email_address UNIQUE (email);
- ALTER TABLE person DROP CONSTRAINT unique_email_address;
- ALTER TABLE person ADD UNIQUE (email);

# check constraint
it allow add constraint based on boolean condition
- ALTER TABLE person ADD CONSTRAINT gender_constraint CHECK (gender='Male' OR gender='Female' OR gender = 'Agender');

# delete records
- DELETE FROM person;
- DELETE * FROM person WHERE id = 925;
- DELETE FROM person WHERE gender = 'Agender';

# update records
- UPDATE person SET email = 'jolynn@gmail.com' WHERE id = 24;
- UPDATE person SET first_name = 'Jolyn', last_name = 'Redwine' WHERE id = 24;

# on conflict do nothing
column should be unique constraint

- insert into person (id,first_name, last_name, email, gender, date_of_birth, country_of_birth) values (916,'Jolynn', 'Redwin', null, 'Female', '2026-01-15', 'Indonesia') ON CONFLICT (id) DO NOTHING;
INSERT 0 0



# upsert

- insert into person (first_name, last_name, email, gender, date_of_birth, country_of_birth) values ('Jolynn', 'Redwin', 'joly@gmail.com', 'Female', '2026-01-15', 'Indonesia') ON CONFLICT (email) DO UPDATE SET email= EXCLUDED.email;


# foreign keys, joins & relationship

# inner join
take common from both table

\x
Expanded display is on.

- SELECT * FROM person JOIN car ON person.car_id = car.id;
- SELECT person.first_name, car.make, car.model, car.price FROM person JOIN car ON person.car_id = car.id;

# left join