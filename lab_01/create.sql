DROP TABLE IF EXISTS Contract CASCADE;
DROP TABLE IF EXISTS Model CASCADE;
DROP TABLE IF EXISTS Factory CASCADE;
DROP TABLE IF EXISTS Engines;
DROP TABLE IF EXISTS Dealer;
DROP TABLE IF EXISTS Brand;

CREATE TABLE Engines
(
    EngineID        INT GENERATED ALWAYS AS IDENTITY,
    HP              INT,
    Torque          INT,
    Volume          INT,
    CylindersNumber INT,
    CyclesNumber    INT,
    Fuel            INT,
    Factory         INT
);

CREATE TABLE Model
(
    ModelID      INT GENERATED ALWAYS AS IDENTITY,
    NAME         varchar(100),
    VIN          VARCHAR(17),
    Cost         INT,
    MaxSpeed     INT,
    Acceleration NUMERIC(4, 2),
    ReleaseYear  INT,
    GearsNumber  INT,
    Engine       INT NOT NULL,
    Brand        INT NOT NULL
);

CREATE TABLE Factory
(
    FactoryID     INT GENERATED ALWAYS AS IDENTITY,
    NAME          varchar(100),
    Country       VARCHAR(10),
    ModelsPerYear INT,
    WorkerNumber  INT,
    Brand         INT NOT NULL
);

CREATE TABLE Dealer
(
    DealerID      INT GENERATED ALWAYS AS IDENTITY,
    NAME          varchar(100),
    Country       VARCHAR(10),
    SalesPerYear  INT,
    SellersNumber INT,
    ExtraCharge   INT
);

CREATE TABLE Brand
(
    BrandID        INT GENERATED ALWAYS AS IDENTITY,
    NAME           varchar(100),
    Country        VARCHAR(10),
    Founder        VARCHAR(30),
    FoundationYear INT,
    Revenue        INT
);

CREATE TABLE Contract
(
    ContractID    INT GENERATED ALWAYS AS IDENTITY,
    Brand         INT NOT NULL,
    Dealer        INT NOT NULL,
    ModelsPerYear INT,
    Duration      INT,
    Cost          INT,
    StartDate     DATE
);