--- Query 1
set search_path to quizschema;

SELECT first_name||last_name as full_name, id
FROM student;
