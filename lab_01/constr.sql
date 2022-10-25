set datestyle to DMY;

ALTER TABLE dealer
    ADD CONSTRAINT PKDealerID PRIMARY KEY (dealerid),
    ADD CONSTRAINT checkSalesPerYear CHECK (salesperyear > 0),
    ADD CONSTRAINT checkSellersNumber CHECK (sellersnumber > 0),
    ADD CONSTRAINT checkExtraCharge CHECK (dealer.extracharge > 0);

ALTER TABLE brand
    ADD CONSTRAINT PKBrandID PRIMARY KEY (brandid),
    ADD CONSTRAINT checkFoundationYear CHECK (foundationyear > 1863 AND foundationyear < 2022),
    ADD CONSTRAINT checkRevenue CHECK (revenue > 0);

ALTER TABLE contract
    ADD CONSTRAINT PKContractID PRIMARY KEY (contractid),
    ADD CONSTRAINT FKBrandC FOREIGN KEY (brand) REFERENCES brand (brandid),
    ADD CONSTRAINT FKDealerC FOREIGN KEY (dealer) REFERENCES dealer (dealerid),
    ADD CONSTRAINT checkModelsPerYear CHECK (modelsperyear > 0),
    ADD CONSTRAINT checkDuration CHECK (duration > -1),
    ADD CONSTRAINT checkCost CHECK (cost > 0),
    ADD CONSTRAINT checkStartDate CHECK (startdate < '23/09/2022');

ALTER TABLE factory
    ADD CONSTRAINT PKFactoryID PRIMARY KEY (factoryid),
    ADD CONSTRAINT checkModelsPerYear CHECK (modelsperyear > 0),
    ADD CONSTRAINT checkWorkerNumber CHECK (WorkerNumber > 0),
    ADD CONSTRAINT FKBrandF FOREIGN KEY (brand) REFERENCES brand (brandid);

ALTER TABLE Engines
    ADD CONSTRAINT PKEngineID PRIMARY KEY (engineid),
    ADD CONSTRAINT checkHP CHECK (hp > 0),
    ADD CONSTRAINT checkTorque CHECK (torque > 0),
    ADD CONSTRAINT checkVolume CHECK (volume > 0),
    ADD CONSTRAINT checkCylindersNumber CHECK (cylindersnumber > 1 AND cylindersnumber < 5),
    ADD CONSTRAINT checkCyclesNumber CHECK (cyclesnumber IN (2, 4)),
    ADD CONSTRAINT checkFuel CHECK (fuel IN (80, 92, 95, 98)),
    ADD CONSTRAINT FKFactory FOREIGN KEY (factory) REFERENCES factory (factoryid);

ALTER TABLE model
    ADD CONSTRAINT PKModelId PRIMARY KEY (modelid),
    ADD CONSTRAINT checkCost CHECK (cost > 0),
    ADD CONSTRAINT checkMaxSpeed CHECK (maxspeed > 0),
    ADD CONSTRAINT checkAcceleration CHECK (acceleration > 0),
    ADD CONSTRAINT checkReleaseYear CHECK (releaseyear > 1884 AND releaseyear < 2022),
    ADD CONSTRAINT checkGearsNumber CHECK (gearsnumber > 0),
    ADD CONSTRAINT FKEngineM FOREIGN KEY (engine) REFERENCES engines (engineid),
    ADD CONSTRAINT FKBrandM FOREIGN KEY (brand) REFERENCES brand (brandid);


