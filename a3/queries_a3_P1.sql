--- Query 1

SELECT first_name||last_name as full_name, id
FROM student;

---Query 2

CREATE VIEW question_with_hint
AS(SELECT id,question_text,count(hint) as hint_count
FROM question JOIN hint ON question.id=hint.question_id
GROUP BY id);

CREATE VIEW question_without_hint 
AS( 
SELECT id,question_text, NULL as hint_count
FROM question 
WHERE question_type='True-False'
);


SELECT * FROM question_without_hint UNION DISTINCT SELECT * FROM question_with_hint;
--SELECT * 
--FROM question_with_hint,question_without_hint;

---Query 3

CREATE VIEW question_in_quiz AS(
SELECT question_id,weight,correct_answer
FROM question_quiz,question
WHERE question_quiz.quiz_id = 'Pr1-220310' AND question.id = question_quiz.question_id 
);

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

SELECT id,last_name, 0 as sum 
FROM chosen_student 
WHERE chosen_student.id NOT IN (
SELECT id FROM student_answered
) 
UNION DISTINCT
SELECT * FROM student_answered;

---Query4

CREATE VIEW question_in_quiz AS(
SELECT question_id,question_text
FROM question_quiz,question
WHERE question_quiz.quiz_id = 'Pr1-220310' AND question.id = question_quiz.question_id 
);


CREATE VIEW chosen_student AS(
SELECT id
FROM student JOIN student_class ON student.id = student_class.student_id
WHERE class_id IN (
SELECT id 
FROM class 
WHERE Grade = 8 AND room = 'room 120' AND teacher = 'Mr Higgins')
);

SELECT id,question_in_quiz.question_id,question_text
FROM chosen_student cs1,question_in_quiz
WHERE 
question_in_quiz.question_id NOT IN (
SELECT question_id
FROM student_answer 
WHERE cs1.id=student_id
)
OR cs1.id NOT IN (
SELECT student_id
FROM student_answer
);

---Query5

CREATE VIEW question_in_quiz AS(
SELECT question_id,correct_answer
FROM question_quiz,question
WHERE question_quiz.quiz_id = 'Pr1-220310' AND question.id = question_quiz.question_id 
);

CREATE VIEW chosen_student AS(
SELECT id
FROM student JOIN student_class ON student.id = student_class.student_id
WHERE class_id IN (
SELECT id 
FROM class 
WHERE Grade = 8 AND room = 'room 120' AND teacher = 'Mr Higgins'
)
);

CREATE VIEW answered_correct AS
(
SELECT count(id) AS num_correct_answered,question_in_quiz.question_id
FROM chosen_student,question_in_quiz,student_answer
WHERE chosen_student.id = student_answer.student_id 
AND student_answer.question_id = question_in_quiz.question_id
AND student_answer.response = question_in_quiz.correct_answer
GROUP BY question_in_quiz.question_id
)
;

CREATE VIEW answered_wrong AS
(
SELECT count(id) AS num_wrong_answered,question_in_quiz.question_id
FROM chosen_student,question_in_quiz,student_answer
WHERE chosen_student.id = student_answer.student_id 
AND student_answer.question_id = question_in_quiz.question_id
AND student_answer.response <> question_in_quiz.correct_answer
GROUP BY question_in_quiz.question_id
)
;

CREATE VIEW not_answered AS(

SELECT count(id) AS num_not_answered,question_in_quiz.question_id

FROM chosen_student cs1,question_in_quiz

WHERE

question_in_quiz.question_id NOT IN (
SELECT question_id
FROM student_answer 
WHERE cs1.id=student_id
)

OR 

cs1.id NOT IN (
SELECT id
FROM student_answer
)

GROUP BY question_in_quiz.question_id
);

CREATE VIEW pre_output AS 
SELECT * 
FROM not_answered NATURAL FULL JOIN answered_correct NATURAL FULL JOIN answered_wrong;

SELECT * 
FROM pre_output;




