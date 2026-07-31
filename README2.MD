SELECT * FROM pg_extension WHERE extname = 'pg_stat_statements';
SELECT * FROM pg_available_extensions WHERE name = 'pg_stat_statements';
CREATE EXTENSION pg_stat_statements;

