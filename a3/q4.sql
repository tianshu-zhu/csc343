---Query4

DROP VIEW IF EXISTS question_in_quiz,chosen_student CASCADE; 

set search_path to quizschema;

---Find all question id and related data(in this case the text)-----

CREATE VIEW question_in_quiz AS(
SELECT question_id,question_text
FROM question_quiz,question
WHERE question_quiz.quiz_id = 'Pr1-220310' AND question.id = question_quiz.question_id 
);


-----Find all student and their related data(non in this case) ----

CREATE VIEW chosen_student AS(
SELECT id
FROM student JOIN student_class ON student.id = student_class.student_id
WHERE class_id IN (
SELECT id 
FROM class 
WHERE Grade = 8 AND room = 'room 120' AND teacher = 'Mr Higgins')
);


---The first arguement under WHERE clause finds those student that answered some question but not the one at current row----
---The argumetn after OR clause is to find those that does not answer any question, which will not appear in the student_answered relation----

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
