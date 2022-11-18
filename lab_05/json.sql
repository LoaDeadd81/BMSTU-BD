-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
-- проверить все режимы конструкции FOR XML

select row_to_json(model) as m_json
from model;

select to_json(brand) as b_json
from brand;

select to_json(Factory) as f_json
from factory;

-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе

copy (
    select to_json(dealer)
    from dealer
    ) to '/docker-entrypoint-initdb.d/lab_05/dealer.json';


create temp table if not exists dc_import
(
    data json
);
copy dc_import from '/docker-entrypoint-initdb.d/lab_05/dealer.json';

select *
from dc_import;

drop table if exists dc;

CREATE temp TABLE dc
(
    DealerID      INT GENERATED ALWAYS AS IDENTITY,
    NAME          varchar(100),
    Country       VARCHAR(10),
    SalesPerYear  INT,
    SellersNumber INT,
    ExtraCharge   INT
);

insert into dc(name, country, salesperyear, sellersnumber, extracharge)
select NAME, Country, SalesPerYear, SellersNumber, ExtraCharge
from dc_import, json_populate_record(null::dc, data);


select *
from dc;


-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE

drop table if exists jsont;
create temp table jsont
(
    data json
);

-- insert into jsont(data)
-- select * from json_object('{a, b, c}', '{1,2,3} {4,5,6}');

insert into jsont (data)
values ('{
  "a": 1,
  "b": 2,
  "c": 3
}'::json),
       ('{
         "a": 4,
         "b": 5,
         "c": 6
       }'::json),
       ('{
         "a": 7,
         "b": 8,
         "c": 9
       }'::json);

select *
from jsont;

-- 4. Выполнить следующие действия:

-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа

drop table if exists d_id_name;

CREATE TABLE IF NOT EXISTS d_id_name
(
    DealerID INT,
    name     VARCHAR
);

select DealerID, name
from dc_import, json_populate_record(null::d_id_name, data);

select data -> 'dealerid' as id, data -> 'name' as name
from dc_import;

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа

drop table if exists car;
create table if not exists car
(
    data jsonb
);

select *
from car;

insert into car
values ('{
  "team": "RB",
  "car": {
    "name": "RB18",
    "engine": "RBPT"
  }
}'),
       ('{
         "team": "Ferrari",
         "car": {
           "name": "F1-75",
           "engine": "Ferrari"
         }
       }'),
       ('{
         "team": "McLaren",
         "car": {
           "name": "MCL36",
           "engine": "MB"
         }
       }'),
       ('{
         "team": "Williams",
         "car": {
           "name": "FW44",
           "engine": "MB"
         }
       }');

select data -> 'car' -> 'name' car_name
from car;


-- 3. Выполнить проверку существования узла или атрибута

CREATE OR REPLACE FUNCTION is_key(atribute text)
    RETURNS bool AS
$$
select data ? atribute
from car;
$$ LANGUAGE sql;

select is_key('car');


-- 4. Изменить XML/JSON докум

update car
set data = data || '{
  "team": "RedBull"
}'::jsonb
where data ->> 'team' = 'RB';

select *
from car;

-- 5. Разделить XML/JSON документ на несколько строк по узлам

drop table if exists car1;
create temp table if not exists car1
(
    data jsonb
);

insert into car1
values ('[
  {
    "team": "RB",
    "car": {
      "name": "RB18",
      "engine": "RBPT"
    }
  },
  {
    "team": "Ferrari",
    "car": {
      "name": "F1-75",
      "engine": "Ferrari"
    }
  },
  {
    "team": "McLaren",
    "car": {
      "name": "MCL36",
      "engine": "MB"
    }
  },
  {
    "team": "Williams",
    "car": {
      "name": "FW44",
      "engine": "MB"
    }
  }
]');


-- jsonb_array_elements - Разворачивает массив JSON в набор значений JSON.
SELECT jsonb_array_elements(data)
FROM car1;

