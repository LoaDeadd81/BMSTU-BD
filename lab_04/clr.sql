CREATE LANGUAGE plpython3u;

-- 1) Определяемую пользователем скалярную функцию CLR
create or replace function get_max_car_price_clr(brand_country varchar)
    returns integer as
$$
    res = plpy.execute(f"\
    select max(m.cost)\
    from model m join brand b on b.brandid = m.brand \
    where b.country = '{brand_country}' ;\
    ")

    return res[0]['max']
$$ language plpython3u;

select get_max_car_price_clr('Albania');

-- 2) Пользовательскую агрегатную функцию CLR


create or replace function get_avg_volume()
    returns float4 as
$$
    res = plpy.execute(f"\
    select cylindersnumber as cn, sum(volume) as s, count(*) as c\
    from engines \
    group by cylindersnumber; \
    ")

    return sum(map(lambda x: x['s'] / (x['cn'] * x['c']), res)) / len(res)
$$ language plpython3u;

select get_avg_volume();

-- 3) Определяемую пользователем табличную функцию CLR

create or replace function sales_between(s int, e int)
    returns table
            (
                name         varchar,
                country      varchar,
                salesperyear int
            )
as
$$
    res = plpy.execute(f"\
    select name, country, salesperyear \
    from dealer \
    where salesperyear between {s} and {e}; \
    ")

    return res
$$ language plpython3u;

select *
from sales_between(1000, 1010);

-- 4) Хранимую процедуру CLR

drop table if exists logs;
create temp table logs
(
    logid          INT GENERATED ALWAYS AS IDENTITY,
    operation      varchar(30),
    dt             timestamp,
    BrandID        INT,
    NAME           varchar(100),
    Country        VARCHAR(10),
    Founder        VARCHAR(30),
    FoundationYear INT,
    Revenue        INT
);

create or replace procedure restore_brands() as
$$
    res = plpy.execute(f"\
    select * \
    from logs \
    ")

    insert_plan = plpy.prepare(" \
    insert into brand(name, country, founder, foundationyear, revenue) \
    values ($1, $2, $3, $4, $5); \
    ", ['varchar', 'varchar', 'varchar', 'int', 'int'])

    delete_plan = plpy.prepare(" \
    delete \
    from logs \
    where logid = $1; \
    ", ['int'])

    for rec in res:
        plpy.execute(insert_plan, [rec['name'], rec['country'], rec['founder'], rec['foundationyear'], rec['revenue']])
        plpy.execute(delete_plan, [rec['logid']])

$$ language plpython3u;

call restore_brands();

-- 5) Триггер CLR

create or replace function brands_bucket()
    returns trigger as
$$
    from datetime import datetime

    insert_plan = plpy.prepare(" \
        insert into logs(operation, dt, BrandID, NAME, Country, Founder, FoundationYear, Revenue) \
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8); \
    ", ['varchar', 'timestamp', 'int', 'varchar', 'varchar', 'varchar', 'int', 'int'])

    if TD["event"] == 'DELETE':
        plpy.execute(insert_plan,
                     ['DELETE', datetime.now(), TD["old"]["brandid"], TD["old"]["name"], TD["old"]["country"],
                      TD["old"]["founder"], TD["old"]["foundationyear"], TD["old"]["revenue"]])
$$ language plpython3u;

create trigger b_bucket
    after delete
    on brand
    for each row
execute procedure brands_bucket();

insert into brand(name)
values ('test1');

delete
from brand
where name = 'test1';

select *
from logs;

-- 6) Определяемый пользователем тип данных CLR

drop type if exists model_sale_data;

create type model_sale_data as
(
    NAME        varchar(100),
    VIN         VARCHAR(17),
    Cost        INT,
    ReleaseYear INT
);

create or replace function get_sale_data()
    returns setof model_sale_data as
$$
    res = plpy.execute(" \
    select name, vin, cost, releaseyear \
    from model; \
    ")

    return res
$$ language plpython3u;

select * from get_sale_data();

drop view if exists CView;

create view CView as
select *
from contract;

create or replace function c_d_clr()
    returns trigger as
$$
    insert_plan = plpy.prepare(" \
        update CView \
        set duration = 0 \
        where contractid = $1  \
        ", ['int'])

    if TD["event"] == 'DELETE':
        plpy.execute(insert_plan, [TD["old"]["contractid"]])
$$ language plpython3u;

create trigger d_clr
    instead of delete
    on CView
    for each row
execute procedure c_d_clr();

select *
from CView
where contractid = 102;

delete
from CView
where contractid = 102;

select *
from CView
where contractid = 102;

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

create or replace trigger c_del
    instead of delete
    on CView
    for each row
execute procedure del_contracts();

