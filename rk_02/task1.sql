drop table if exists rk_02.prescription cascade;
drop table if exists rk_02.depemp cascade;
drop table if exists rk_02.employee cascade;
drop table if exists rk_02.departure cascade;
drop table if exists rk_02.medicaments;

create table rk_02.employee
(
    EmpId  int generated always as identity primary key,
    post   varchar(20),
    FIO    varchar(30),
    salary int
);

create table rk_02.departure
(
    DepId        int generated always as identity primary key,
    name         varchar(20),
    phone_number varchar(11),
    manger       int references rk_02.employee (EmpId)
);

create table rk_02.depemp
(
    DID int references rk_02.departure (DepId),
    EID int references rk_02.employee (EmpId) unique
);

create table rk_02.medicaments
(
    MedId       int generated always as identity primary key,
    name        varchar(20),
    instruction varchar(100),
    price       int
);

create table rk_02.prescription
(
    EID int references rk_02.employee (EmpId),
    MID int references rk_02.medicaments (MedId)
);

insert into employee (post, FIO, salary)
values ('a1', 'fio1', 1000),
       ('a2', 'fio2', 2000),
       ('a3', 'fio3', 3000),
       ('a4', 'fio4', 4000),
       ('a5', 'fio5', 5000);

insert into departure (name, phone_number, manger)
values ('d1', 'phone1', 1),
       ('d2', 'phone2', 2),
       ('d3', 'phone3', 3),
       ('d4', 'phone4', 4),
       ('d5', 'phone5', 5);

insert into depemp
values (1, 5),
       (2, 4),
       (3, 3),
       (4, 2),
       (5, 1);

insert into medicaments (name, instruction, price)
values ('n1', 'instruction1', 1),
       ('n2', 'instruction2', 2),
       ('n3', 'instruction3', 3),
       ('n4', 'instruction4', 4),
       ('n5', 'instruction5', 5);

insert into prescription
values (1, 5),
       (2, 4),
       (3, 3),
       (4, 2),
       (5, 1);

select name,
       case
           when price < 4 then 'free'
           else 'paid'
           end as insurance
from medicaments;

select name, worker_num
from departure d
         join (select DID, row_number() over (partition by DID) as worker_num
               from depemp) de on d.DepId = de.DID;

select e.FIO, sum(mp.price) as sum
from (medicaments m join prescription p on m.medid = p.MID) mp
         join employee e on mp.EID = e.EmpId
group by e.FIO
having sum(mp.price) > 2;

create or replace procedure index_info(scheme name, tb name)
as
$$
declare
    r record;
BEGIN
    for r in select indexname
             from pg_indexes
             where scheme = schemaname
               and tb = tablename
        loop
            raise notice '%', r;
        end loop;
end
$$
    language plpgsql;

create or replace procedure tst(out a int )
as
$$
BEGIN
    a = 1;
end
$$
    language plpgsql;

call index_info('rk_02', 'employee');

call tst(0);

select *
from information_schema.triggers;