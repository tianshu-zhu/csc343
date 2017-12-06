drop schema if exists quizschema cascade;
create schema quizschema;
set search_path to quizschema;

drop table if exists student, class, student_class, quiz, question, question_quiz, student_answer, hint cascade;


create table student(
    id varchar(20) primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null
);


create table class(
    id int primary key,
    teacher varchar(40) not null,
    grade int not null,
    room varchar(20) not null
);


create table student_class(
    student_id varchar(20) references student(id) not null, 
    class_id int references class(id) not null,
    primary key (student_id, class_id)
);


create table quiz(
    id varchar(20) primary key,
    class_id int references class(id) not null,
    title varchar(40) not null,
    show_hint boolean not null,
    due timestamp not null
);


create type q_type as enum('True-False', 'Multiple-choice', 'Numeric');


create table question(
    id int primary key,
    question_type q_type not null,
    question_text text not null,
    correct_answer text not null
);


create table question_quiz(
    quiz_id varchar(20) references quiz(id) not null,
    question_id int references question(id) not null,
    weight int not null,
    primary key (quiz_id, question_id)
);


create table student_answer(
    student_id varchar(20) references student(id) not null,
    question_id int references question(id) not null,
    response text not null,
    primary key (student_id, question_id)
);


create table hint(
    question_id int references question(id) not null,
    wrong_answer text not null,
    hint text
);