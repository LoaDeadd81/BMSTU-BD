-- 1. Инструкция SELECT, использующая предикат сравнения.
SELECT name, releaseyear FROM model
WHERE releaseyear > 2010;

-- 2. Инструкция SELECT, использующая предикат BETWEEN
SELECT name, revenue FROM brand
WHERE revenue BETWEEN 500 AND 1000;

-- 3. Инструкция SELECT, использующая предикат LIKE.
SELECT name, workernumber, country FROM factory
WHERE country LIKE '%stan';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
SELECT name, cost, brand FROM model
WHERE brand IN (
        SELECT brandid FROM brand
        WHERE country = 'Australia'
    );

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
SELECT engineid FROM engines
WHERE EXISTS(
    SELECT releaseyear, engine FROM model
    WHERE releaseyear > 2012 AND engine = engines.engineid
          )

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.