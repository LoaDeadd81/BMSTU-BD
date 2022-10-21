set datestyle to DMY;

COPY dealer(name, country, salesperyear, sellersnumber, extracharge)    FROM '/docker-entrypoint-initdb.d/csv/dealers.csv' DELIMITER ';' CSV;
COPY brand(name, country, founder, foundationyear, revenue)    FROM '/docker-entrypoint-initdb.d/csv/brands.csv' DELIMITER ';' CSV;
COPY contract(brand, dealer, modelsperyear, duration, cost, startdate)    FROM '/docker-entrypoint-initdb.d/csv/contracts.csv' DELIMITER ';' CSV;
COPY factory(name, country, modelsperyear, workernumber, brand)   FROM '/docker-entrypoint-initdb.d/csv/factories.csv' DELIMITER ';' CSV;
COPY engines(hp, torque, volume, cylindersnumber, cyclesnumber, fuel, factory)  FROM '/docker-entrypoint-initdb.d/csv/engines.csv' DELIMITER ';' CSV;
COPY model(name, vin, cost, maxspeed, acceleration, releaseyear, gearsnumber, engine, brand)    FROM '/docker-entrypoint-initdb.d/csv/model.csv' DELIMITER ';' CSV;
