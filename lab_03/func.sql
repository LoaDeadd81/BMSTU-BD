-- ################# Функции #################
-- Скалярную функцию

create or replace function get_max_car_price(brand_country VARCHAR(10))
    returns int as
$$
select max(m.cost)
from model m
         join brand b on b.brandid = m.brand
where b.country = brand_country
$$ language sql;

select get_max_car_price('Albania');

-- Подставляемую табличную функцию

create or replace function get_dealers(brand_id int)
    returns table
            (
                DealerID int,
                name     varchar(100)
            )
as
$$
select d.dealerid, d.name
from (select brandid, dealer
      from brand b
               join contract c on b.brandid = c.brand
      where brandid = brand_id) bc
         join dealer d on bc.dealer = d.dealerid
$$
    language sql;

select *
from get_dealers(2);

-- Многооператорную табличную функцию

create or replace function get_eng(fuel_num int, cylinder_num int)
    returns table
            (
                EngineID        INT,
                HP              INT,
                Torque          INT,
                Volume          INT,
                CylindersNumber INT,
                CyclesNumber    INT,
                Fuel            INT,
                Factory         INT
            )
as
$$
begin
    return query
        select *
        from engines
        where engines.hp = fuel_num;
    return query
        select *
        from engines
        where engines.volume = cylinder_num;
    return;
end
$$
    language plpgsql;

select *
from get_eng(92, 2);

-- • Рекурсивную функцию или функцию с рекурсивным ОТВ

create or replace function get_factories(start_id int, end_id int) returns int as
$$
declare
    wn int;
BEGIN
    if start_id > end_id then
        return 0;
    end if;

    select workernumber
    into wn
    from factory
    where factoryid = start_id;

    return wn + get_factories(start_id + 1, end_id);
END
$$ language plpgsql;

select get_factories(10, 20) as wn;

-- ################# Процедуры #################

-- Хранимую процедуру без параметров или с параметрами

create or replace procedure inflation(country_name varchar(10)) as
$$
BEGIN
    update model
    set cost = cost * 2
    where brand in (select brandid
                    from (brand b join contract c on b.brandid = c.brand) bc
                             join dealer d on bc.dealer = d.dealerid
                    where d.country = country_name);
END
$$ language plpgsql;


select *
from model
where brand in (select brandid
                from (brand b join contract c on b.brandid = c.brand) bc
                         join dealer d on bc.dealer = d.dealerid
                where d.country = 'Bahamas');
call inflation('Bahamas');
select *
from model
where brand in (select brandid
                from (brand b join contract c on b.brandid = c.brand) bc
                         join dealer d on bc.dealer = d.dealerid
                where d.country = 'Bahamas');


-- Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ

create or replace procedure avg_speed(sid int, eid int, sum int = 0, num int = 0) as
$$
declare
    speed int;
BEGIN
    if sid > eid and num != 0 then
        raise notice 'Avg speed: %', sum::real / num::real;
        return;
    end if;

    select maxspeed
    into speed
    from model
    where modelid = sid;

    call avg_speed(sid + 1, eid, sum + speed, num + 1);
END
$$ language plpgsql;

call avg_speed(100, 200);


-- Хранимую процедуру доступа к метаданным
create or replace procedure tables() as
$$
declare
    t record;
BEGIN
    for t in select ist.table_catalog   db,
                    ist.table_schema as sheme,
                    ist.table_name   as tb,
                    column_name,
                    data_type        as type
             from information_schema.tables ist
                      join information_schema.columns isc on ist.table_name = isc.table_name
             where ist.table_schema = 'public'
        loop
            raise notice 'Table info %', t;
        end loop;
END
$$ language plpgsql;

call tables();

-- ################# Триггеры #################

-- Триггер AFTER

drop table if exists logs;

create temp table logs
(
    logid          INT GENERATED ALWAYS AS IDENTITY,
    operation      varchar(30),
    dt             timestamp with time zone,
    BrandID        INT,
    NAME           varchar(100),
    Country        VARCHAR(10),
    Founder        VARCHAR(30),
    FoundationYear INT,
    Revenue        INT
);

create or replace function brand_logs() returns trigger as
$$
begin
    if tg_op = 'INSERT' then
        insert into logs(operation, dt, BrandID, NAME, Country, Founder, FoundationYear, Revenue)
        VALUES (tg_op, now(), new.brandid, new.name, new.country, new.founder, new.foundationyear, new.revenue);
        return new;
    elsif tg_op = 'UPDATE' then
        insert into logs(operation, dt, BrandID, NAME, Country, Founder, FoundationYear, Revenue)
        VALUES ('Before ' || tg_op, now(), old.brandid, old.name, old.country, old.founder, old.foundationyear,
                old.revenue);
        insert into logs(operation, dt, BrandID, NAME, Country, Founder, FoundationYear, Revenue)
        VALUES ('After ' || tg_op, now(), new.brandid, new.name, new.country, new.founder, new.foundationyear,
                new.revenue);
        return new;
    elsif tg_op = 'DELETE' then
        insert into logs(operation, dt, BrandID, NAME, Country, Founder, FoundationYear, Revenue)
        VALUES (tg_op, now(), old.brandid, old.name, old.country, old.founder, old.foundationyear, old.revenue);
        return old;
    end if;
end;
$$ language plpgsql;

drop trigger if exists b_logs on brand;

create trigger b_logs
    after insert or update or delete
    on brand
    for each row
execute procedure brand_logs();

insert into brand(name)
values ('test1');

update brand
set foundationyear = 2010
where name = 'test1';

delete
from brand
where name = 'test1';

select *
from logs;

-- Триггер INSTEAD OF

drop view if exists CView;

create view CView as
select *
from contract;

create or replace function del_contracts() returns trigger as
$$
begin
    if tg_op = 'DELETE' then
        update CView
        set duration = 0
        where contractid = old.contractid;
        return old;
    end if;
    return null;
end;
$$ language plpgsql;

drop trigger if exists c_del on CView;

create or replace trigger c_del
    instead of delete
    on CView
    for each row
execute procedure del_contracts();

select *
from CView
where contractid = 100;

delete
from CView
where contractid = 100;

select *
from CView
where contractid = 100;


-- def

-- Хранимую процедуру с курсором

create or replace procedure contract_by_duration(dur int) as
$$
declare
    cur cursor (d int) for select contractid, cost
                           from contract
                           where duration = d;
begin
    for rec in cur(dur)
        loop
            raise notice '%', rec;
        end loop;
end
$$ language plpgsql;

call contract_by_duration(2);

create or replace procedure def(dur int) as
$$
DECLARE
    r record;
BEGIN
    for r in (select contractid, cost from contract where duration = dur)
        loop
            raise notice '%', r;
        end loop;
END
$$ language plpgsql;

call def(2);

drop table if exists Champs;
create table if not exists Champs
(
    Brand int references brand (brandid),
    plaxe int,
    racing_series varchar
);


