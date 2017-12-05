drop schema if exists quizschema cascade;
create schema quizschema;
set search_path to quizschema;


create table students(
    id INT primary key,
    --student id
    firstName varchar(10) not null,
    --student first name
    lastName varchar(10) not null
    --student last name
);

create table enroll(
	student_id int REFERENCES student(id) not null,
	class_id int REFERENCES class(id) not null
);

create table class(
	id int primary key,
	room_id int not null,
	--which romm the class has e.g., “room 366”
	grade int not null,
	--which grade the class is e.g., “grade 5”
	teacher VARCHAR(20) not null,
);

-- create table room(
-- 	id int primary key,
-- 	teacher varchar(20) not null,
-- 	class_id int REFERENCES class(id),
-- );
-- A room can have two classes in it (for example, if we have a grade 2-3 split class), 
-- but never more than one teacher.

create table question(
	id int primary key,
	type question_type not null,
	text varchar(100) not null
);

CREATE TYPE question_type AS ENUM(
	'true-false', 'multiple choice', 'numeric');

create table TFquestion(
	TF_id int REFERENCES question(id),
	questionAnswer varchar(1) not null
);

create table multquestion(
	mul_id int REFERENCES question(id),
	-- at leaset two
	answer varchar(10) not null
);

create table options(
	question_id int REFERENCES multquestion(id),
	option_content varchar(50) not null
);

create table multihint(
	multihint_id int primary key,
	question_id int REFERENCES multiquestion(mul_id),
	hint_content varchar(50) not null
);

create table numquestion(
	num_id REFERENCES question(id),
	questionAnswer int not null
);

create table numhint(
	numhint_id int primary key,
	question_id int REFERENCES numquestion(num_id),
	lowerbound int not null,
	upperbound int not null
);

create table quiz(
	id int primary key,
	title varchar(50) not null,
	duedate DATE not null,
	duetime TIME not null,
	hashint boolean not null,
	class_id int REFERENCES class(id)
);


create table choosequestion(
	question_id int REFERENCES question(id),
	quiz_id int REFERENCES quiz(id),
	question_weight int not null,
);


create table answer(
	student_id int REFERENCES student(id) not null,
	question_id int REFERENCES question(id) not null,
	quiz_id int REFERENCES quiz(id) not null,
	student_answer varchar(50) not null
);


-- Only a student in the class that was assigned a quiz can answer questions on that quiz.
create table assign(
	student_id int REFERENCES student(id) not null,
	quiz_id int REFERENCES quiz(id) not null
);


create table response(
	student_id int REFERENCES student(id) not null,
	quiz_id int REFERENCES quiz(id) not null
);











