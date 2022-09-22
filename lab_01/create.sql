CREATE TABLE IF NOT EXISTS Engines
(
    EngineID        INT GENERATED ALWAYS AS IDENTITY,
    HP              INT,
    Torque          INT,
    Volume          INT,
    CylindersNumber INT,
    CyclesNumber    INT,
    Fuel            INT
);

CREATE TABLE IF NOT EXISTS Model
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

CREATE TABLE IF NOT EXISTS Factory
(
    FactoryID     INT GENERATED ALWAYS AS IDENTITY,
    NAME          varchar(100),
    Country       VARCHAR(10),
    ModelsPerYear INT,
    WorkerNumber  INT,
    Brand         INT NOT NULL
);

CREATE TABLE IF NOT EXISTS Dealer
(
    DealerID      INT GENERATED ALWAYS AS IDENTITY,
    NAME          varchar(100),
    Country       VARCHAR(10),
    SalesPerYear  INT,
    SellersNumber INT,
    ExtraCharge   INT
);

CREATE TABLE IF NOT EXISTS Brand
(
    BrandID        INT GENERATED ALWAYS AS IDENTITY,
    NAME           varchar(100),
    Country        VARCHAR(10),
    Founder        VARCHAR(30),
    FoundationYear INT,
    Revenue        INT
);

CREATE TABLE IF NOT EXISTS Contract
(
    ContractID    INT GENERATED ALWAYS AS IDENTITY,
    Brand         INT NOT NULL,
    Dealer        INT NOT NULL,
    ModelsPerYear INT,
    Duration      INT,
    Cost          INT,
    StartDate     DATE
);

set datestyle to DMY