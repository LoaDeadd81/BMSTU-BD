-- Волков Г.В. ИУ7-51Б
-- Вариант 3

-- Задание №1

drop table if exists employee cascade;
drop table if exists schedule cascade;
drop table if exists post;
drop table if exists shift;

create table if not exists post
(
    PID    int generated always as identity primary key,
    name   varchar(10),
    adress varchar(30)
);

create table if not exists employee
(
    EID        int generated always as identity primary key,
    FIO        varchar(30),
    birth_yaer int,
    experience int,
    phone      varchar(11),
    PostID     int references post (PID)
);

create table if not exists shift
(
    SID        int generated always as identity primary key,
    day        date,
    work_from  time,
    work_until time
);

create table if not exists schedule
(
    EmpId   int references employee (EID),
    ShiftId int references shift (SID)
);

insert into post(name, adress)
VALUES ('A', 'weadas'),
       ('B', 'weadas'),
       ('C', 'weadas'),
       ('D', 'weadas'),
       ('E', 'weadas'),
       ('F', 'weadas'),
       ('G', 'weadas'),
       ('H', 'weadas'),
       ('X', 'weadas'),
       ('Z', 'weadas');

insert into employee(FIO, birth_yaer, experience, phone, PostID)
values ('FIO1', 1990, 10, '11', 1),
       ('FIO2', 1991, 9, '12', 2),
       ('FIO3', 1992, 8, '13', 3),
       ('FIO4', 1993, 7, '14', 4),
       ('FIO5', 1994, 6, '15', 5),
       ('FIO6', 1995, 5, '16', 1),
       ('FIO7', 1996, 4, '17', 2),
       ('FIO8', 1997, 3, '18', 3),
       ('FIO9', 1998, 2, '19', 4),
       ('FIO10', 2000, 1, '10', 5);

insert into shift(day, work_from, work_until)
VALUES ('1/2/2020'::date, '12:00'::time, '00:00'::time),
       ('2/2/2020'::date, '12:00'::time, '00:00'::time),
       ('3/2/2020'::date, '12:00'::time, '00:00'::time),
       ('4/2/2020'::date, '12:00'::time, '00:00'::time),
       ('5/2/2020'::date, '12:00'::time, '00:00'::time),
       ('1/2/2020'::date, '00:00'::time, '12:00'::time),
       ('2/2/2020'::date, '00:00'::time, '12:00'::time),
       ('3/2/2020'::date, '00:00'::time, '12:00'::time),
       ('4/2/2020'::date, '00:00'::time, '12:00'::time),
       ('5/2/2020'::date, '00:00'::time, '12:00'::time);

insert into schedule(EmpId, ShiftId)
values (1, 10),
       (2, 9),
       (3, 8),
       (4, 7),
       (5, 6),
       (6, 5),
       (7, 4),
       (8, 3),
       (9, 2),
       (10, 1);


-- Задание №2

-- 1) Выводит имя работник и вид его смены(дневная, ночная)

select FIO,
       case
           when work_from >= '12:00'::time then 'daytime'
           else 'night' end as shift_type
from (employee e join schedule s on e.EID = s.EmpId) es
         join shift s on es.ShiftId = s.SID;

-- 2) Поставить на смену 5 самого опытного охраника

update schedule
set EmpId = (select EID
             from employee
             where experience = (select max(experience)
                                 from employee))
where ShiftId = 5;

select *
from schedule;

-- 3) Посты со средним стажем работников болле 5

select name, avg(experience)
from employee e
         join post p on p.PID = e.PostID
group by name
having avg(experience) > 5;

-- Задание №3

select *
from pg_trigger;

create or replace function fn() returns trigger as
$$
begin
    raise notice 'hello';
end;
$$
    language plpgsql;

create trigger ddl_trigger
    after insert
    on employee
    for each row
execute procedure fn();

select *
from pg_trigger;

create or replace procedure delete_ddl_triggers(out num int) as
$$
declare
    r record;
begin
    num = 0;
    for r in (select * from pg_trigger where tgtype = 5)
        loop
            execute 'drop trigger ' || r.tgname || ' on ' || r.tgrelid::regclass;
            num = num + 1;
        end loop;
end;
$$
    language plpgsql;

select * from pg_trigger where tgtype = 5;

call delete_ddl_triggers(0);

select *
from pg_trigger;

