-- 1. Инструкция SELECT, использующая предикат сравнения.
SELECT name, releaseyear
FROM model
WHERE releaseyear > 2010;

-- 2. Инструкция SELECT, использующая предикат BETWEEN
SELECT name, revenue
FROM brand
WHERE revenue BETWEEN 500 AND 1000;

-- 3. Инструкция SELECT, использующая предикат LIKE.
SELECT name, workernumber, country
FROM factory
WHERE country LIKE '%stan';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
SELECT name, cost, brand
FROM model
WHERE brand IN (SELECT brandid
                FROM brand
                WHERE country = 'Australia');

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
SELECT engineid
FROM engines
WHERE EXISTS(
              SELECT releaseyear, engine
              FROM model
              WHERE releaseyear > 2012
                AND engine = engines.engineid
          );

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
select engineid, volume, torque, hp, cylindersnumber
from engines
where volume > all (select volume
                    from engines
                    where cylindersnumber = 4);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях
select cylindersnumber, avg(volume / cylindersnumber) as avgVolumeOnCylinder
from engines
group by cylindersnumber;

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
select engineid,
       (select avg(cost)
        from model as m
        where m.engine = e.engineid)
from engines as e;

-- 9. Инструкция SELECT, использующая простое выражение CASE.
select b.name,
       m.name,
       case releaseyear
           when 2018 then 'new'
           when 2017 then 'last_year'
           else 'old'
           end as isNew
from model m
         join brand b on b.brandid = m.brand;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
select name,
       country,
       case
           when workernumber < 100 then 'small'
           when workernumber < 500 then 'middle'
           else 'huge'
           end as size
from factory;

-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
drop table if exists ModelFactory;
select m.name as mname, f.name as factory, f.country, m.releaseyear
into temp ModelFactory
from model m
         join factory f on m.brand = f.brand;
Select *
from ModelFactory;

-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
select name, maxc
from brand b
         join (select brand, max(cost) as maxc
               from model
               group by brand
               order by maxc desc) m on b.brandid = m.brand;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
select name, vin, cost
from model
where engine in (select engineid
                 from engines
                 where factory in (select factoryid
                                   from factory
                                   where country = 'Estonia'));

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
select cylindersnumber, avg(volume) as AvgVlume, max(volume) as MaxVolume
from engines
group by cylindersnumber;

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
select country, avg(salesperyear) as avgsales
from dealer
group by country
having avg(salesperyear) > (select avg(salesperyear)
                            from dealer);

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
insert into dealer (name, country, salesperyear, sellersnumber, extracharge)
VALUES ('aaa', 'rus', 1000, 20, 20);

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
insert into contract(brand, dealer, modelsperyear, duration, cost, startdate)
select bc.brand, bc.dealer, 2000, 10, 100000, to_date('07 10 2022', 'DD MM YYYY')
from (brand b join contract c on b.brandid = c.brand) bc
         join dealer d on bc.dealer = d.dealerid
where bc.country = d.country;

-- 18. Простая инструкция UPDATE.
update brand
set revenue = revenue * 2
where country = 'Cuba';

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
update brand
set revenue = (select avg(revenue)
               from brand
               where country = 'Cuba')
where country = 'Cuba';

-- 20. Простая инструкция DELETE.
delete
from contract
where duration = 0;

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
delete
from model m
where engine in (select engineid
                 from engines e
                 where m.engine = e.engineid
                   and volume < 100);

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
with fact(brid, workernum) as (select brand, sum(workernumber)
                               from factory
                               group by brand)
select b.name, f.workernum
from brand b
         join fact f on b.brandid = f.brid;

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
drop table if exists empl;

CREATE temp TABLE empl
(
    empid INT GENERATED ALWAYS AS IDENTITY,
    name  varchar(15),
    m_id  int
);

insert into empl (name, m_id)
values ('ivan', null),
       ('gora', 1),
       ('saha', 1),
       ('tania', 2),
       ('lena', 2),
       ('boba', 3),
       ('biba', 4);

with recursive otv_level(id, name, m_id, level) as
                   (select empid, name, m_id, 0
                    from empl
                    where m_id isnull
                    union all
                    select e.empid, e.name, e.m_id, otv.level + 1
                    from empl e
                             inner join otv_level otv on otv.id = e.m_id)
select *
from otv_level;

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()

select country,
       min(extracharge) over (partition by country) as minextra,
       avg(extracharge) over (partition by country) as avgextra,
       max(extracharge) over (partition by country) as maxextra,
       row_number() over (partition by country)     as num
from dealer;

-- 25. Оконные фнкции для устранения дублей
select country, minextra, avgextra, maxextra
from (select country,
             min(extracharge) over (partition by country) as minextra,
             avg(extracharge) over (partition by country) as avgextra,
             max(extracharge) over (partition by country) as maxextra,
             row_number() over (partition by country)     as num
      from dealer) as d
where num = 1;

-- Защита
-- Все имена диллеров, у которых контракт с определённым брендом
select bc.name
from (brand b join contract c on b.brandid = c.brand) bc
         join dealer d on bc.dealer = d.dealerid
group by bc.name
having count(*) = (select bc.name
                   from (brand b join contract c on b.brandid = c.brand) bc
                            join dealer d on bc.dealer = d.dealerid);

select d.dealerid, d.name, bc.name
from (brand b join contract c on b.brandid = c.brand) bc
         join dealer d on bc.dealer = d.dealerid
where bc.name = 'harness viral infrastructures';

-- доп

drop table if exists table1;
drop table if exists table2;

create temp table table1
(
    tb1ID      int,
    var        varchar,
    valid_from date,
    valid_to   date
);

create temp table table2
(
    tb2ID      int,
    var        varchar,
    valid_from date,
    valid_to   date
);

insert into table1
values (1, 'A', to_date('01 09 2018', 'DD MM YYYY'), to_date('15 09 2018', 'DD MM YYYY')),
       (1, 'B', to_date('16 09 2018', 'DD MM YYYY'), to_date('31 12 5999', 'DD MM YYYY'));

insert into table2
values (1, 'A', to_date('01 09 2018', 'DD MM YYYY'), to_date('18 09 2018', 'DD MM YYYY')),
       (1, 'B', to_date('19 09 2018', 'DD MM YYYY'), to_date('31 12 5999', 'DD MM YYYY'));

select *
from table1;

select *
from table2;

select tb1.tb1ID as id,
       tb1.var as var1,
       tb2.var as var2,
       case
           when tb1.valid_from > tb2.valid_from
               then tb1.valid_from
           else tb2.valid_from end
               as valid_from,
       case
           when tb1.valid_to < tb2.valid_to
               then tb1.valid_to
           else tb2.valid_to end
               as valid_to
from table1 tb1
         join table2 tb2
              on tb1.tb1ID = tb2.tb2ID
                  and tb1.valid_to > tb2.valid_from
                  and tb1.valid_from < tb2.valid_to;




