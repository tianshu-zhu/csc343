---Query5
set search_path to quizschema;
DROP VIEW IF EXISTS question_in_quiz,chosen_student,answered_correct,answered_wrong.not,pre_output CASCADE; 

-----Find all the question and their relavent data(correct answer) in the quiz----- 

CREATE VIEW question_in_quiz AS(
SELECT question_id,correct_answer
FROM question_quiz,question
WHERE question_quiz.quiz_id = 'Pr1-220310' AND question.id = question_quiz.question_id 
);

-----Find all the student in the desired class------

CREATE VIEW chosen_student AS(
SELECT id
FROM student JOIN student_class ON student.id = student_class.student_id
WHERE class_id IN (
SELECT id 
FROM class 
WHERE Grade = 8 AND room = 'room 120' AND teacher = 'Mr Higgins'
)
);

--- A combination of the previous queries, some edge case in each query is ignored since they all go into the not answered case----

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

--- But this time the question with a 0 in one of the entries will be treated with NULL rather than 0 
----This is for simplicity of query. A simple way to put 0 is to put the pre_output into a table and update its NULL to 0


CREATE VIEW pre_output AS 
SELECT * 
FROM not_answered NATURAL FULL JOIN answered_correct NATURAL FULL JOIN answered_wrong;

SELECT * 
FROM pre_output;