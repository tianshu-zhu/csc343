---Query 2
set search_path to quizschema;

DROP VIEW IF EXISTS question_with_hint,question_without_hint CASCADE; 

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
