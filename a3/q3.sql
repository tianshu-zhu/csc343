---Query 3
set search_path to quizschema;

DROP VIEW IF EXISTS question_in_quiz,chosen_student,student_answered CASCADE; 


---Find all the question ID in the quiz we desired

CREATE VIEW question_in_quiz AS(
SELECT question_id,weight,correct_answer
FROM question_quiz,question
WHERE question_quiz.quiz_id = 'Pr1-220310' AND question.id = question_quiz.question_id 
);

--- Find all the student we desired

CREATE VIEW chosen_student AS(
SELECT id,last_name
FROM student JOIN student_class ON student.id = student_class.student_id
WHERE class_id IN (
SELECT id 
FROM class 
WHERE (grade = 8 AND class.room = 'room 120' AND class.teacher = 'Mr Higgins'))
);

CREATE VIEW student_answered AS 
SELECT id,last_name,sum(weight) as sum
FROM chosen_student,question_in_quiz,student_answer
WHERE chosen_student.id = student_answer.student_id 
AND student_answer.question_id = question_in_quiz.question_id
AND student_answer.response = question_in_quiz.correct_answer
GROUP BY id,last_name
;

---The first select is to find those that does not answer any questions----

SELECT id,last_name, 0 as sum 
FROM chosen_student 
WHERE chosen_student.id NOT IN (
SELECT id FROM student_answered
) 
UNION DISTINCT
SELECT * FROM student_answered;
