drop schema if exists a3_schema cascade;
create schema a3_schema;
set search_path to a3_schema;


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


insert into question (id, question_type, question_text, correct_answer) values
    (782, 'Multiple-choice', 
    'To pledge your loyalty to the Sovereign, Queen Elizabeth II',
    'What do you promise when you take the oath of citizenship?'),
    (566, 'True-False', 'The Prime Minister, Justin Trudeau, is Canadas Head of State.', 'False'),
    (601, 'Numeric', 'During the "Quiet Revolution," Quebec experienced rapid change. In what decade did this occur? (Enter the year that began the decade, e.g., 1840.', '1960'),
    (625, 'Multiple-choice', 'What is the Underground Railroad?', 
    'A network used by slaves who escaped the United States into Canada'),
    (790, 'Multiple-choice', 'During the War of 1812 the Americans burned down the Parliament Buildings in York (now Toronto). What did the British and Canadians do in return?', 'They burned down the White House in Washington D.C.');  
    
    
    
insert into hint (question_id, wrong_answer, hint) values
    (782, 'To pledge your allegiance to the flag and fulfill the duties of a Canadian', 'Think regally'),
    (782, 'To pledge your loyalty to Canada from sea to sea', null),
    (601, '1800-1900', 'The Quiet Revolution happened during the 20th Century.'),
    (601, '2000-2010', 'The Quiet Revolution happened some time ago.'),
    (601, '2020-3000', 'The Quiet Revolution has already happened!'),
    (625, 'The first railway to cross Canada', 'The Underground Railroad was generally south to north, not east-west.'),
    (625, 'The CPRs secret railway line', 'The Underground Railroad was secret, but it had nothing to do with trains.'),
    (625, 'The TTC subway system', 'The TTC is relatively recent; the Underground Railroad was 
    in operation over 100 years ago.'),
    (790, 'They attacked American merchant ships', null),
    (790, 'They expanded their defence system, including Fort York', null),
    (790, 'They captured Niagara Falls', null);    

    
    
insert into class (id, grade, room, teacher) values
    (1, 8, 'room 120', 'Mr Higgins'),
    (2, 5, 'room 366', 'Miss Nyers');


insert into quiz (id, title, show_hint, class_id, due) values
    ('Pr1-220310', 'Citizenship Test Practise Questions', 'True', 1,  (TIMESTAMP '2017-10-01 13:30:00'));


insert into question_quiz (quiz_id, question_id, weight) values
    ('Pr1-220310', 601, 2),
    ('Pr1-220310', 566, 1),
    ('Pr1-220310', 790, 3),
    ('Pr1-220310', 625, 2);


insert into student (id, first_name, last_name) values
    ('0998801234', 'Lena', 'Headey'),
    ('0010784522', 'Peter', 'Dinklage'),
    ('0997733991', 'Emilia', 'Clarke'),
    ('5555555555', 'Kit', 'Harrington'),
    ('1111111111', 'Sophie', 'Turner'),
    ('2222222222', 'Maisie', 'Williams');


insert into student_answer (student_id, question_id, response) values
    ('0998801234', 601, 1950),
    ('0998801234', 566, 'False'),
    ('0998801234', 790, 'They expanded their defence system, including Fort York'),
    ('0998801234', 625, 'A network used by slaves who escaped the United States into Canada'),
    ('0010784522', 601, 1960),
    ('0010784522', 566, 'False'),
    ('0010784522', 790, 'They burned down the White House in Washington D.C.'),
    ('0010784522', 625, 'A network used by slaves who escaped the United States into Canada'),
    ('0997733991', 601, 1960),
    ('0997733991', 566, 'True'),
    ('0997733991', 790, 'They burned down the White House in Washington D.C.'),
    ('0997733991', 625, 'The CPRs secret railway line'),
    ('5555555555', 566, 'False'),
    ('5555555555', 790, 'They captured Niagara Falls');


insert into student_class (student_id, class_id) values
    ('0998801234', 1),
    ('0010784522', 1),
    ('0997733991', 1),
    ('5555555555', 1),
    ('1111111111', 1),
    ('2222222222', 2);