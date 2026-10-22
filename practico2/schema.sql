DROP DATABASE IF EXISTS world;
CREATE DATABASE world;
USE world;
CREATE TABLE city(
    ID int,
    Name varchar(255),
    CountryCode varchar(255),
    District varchar(255),
    Population int,
    PRIMARY KEY(ID)
);
CREATE TABLE countrylanguage(
    CountryCode varchar(255),
    Language varchar(255) NOT NULL,
    IsOfficial varchar(255),
    Percentage decimal(5, 2),
    PRIMARY KEY(CountryCode, Language)
);
CREATE TABLE country(
    Code varchar(255),
    Name varchar(255),
    Continent varchar(255),
    Region varchar(255),
    SurfaceArea int,
    IndepYear int,
    Population int,
    LifeExpectancy int,
    GNP int,
    GNPOld int,
    LocalName varchar(255),
    GovernmentForm varchar(255),
    HeadOfState varchar(255),
    Capital int,
    Code2 varchar(255),
    PRIMARY KEY(Code)
);

ALTER TABLE city ADD FOREIGN KEY (CountryCode) REFERENCES country(Code);
ALTER TABLE countrylanguage ADD FOREIGN KEY (CountryCode) REFERENCES country(Code);
ALTER TABLE countrylanguage ADD CHECK (Percentage >= 0 AND Percentage <= 100);


CREATE TABLE continent(
	Name varchar(255),
	SurffaceArea int,
	PercentTotalMass decimal(5, 2),
	MostPopulousCity int,
    PRIMARY KEY(Name)
);
ALTER TABLE continent ADD CHECK (PercentTotalMass >= 0 AND PercentTotalMass <= 100);

ALTER TABLE continent ADD FOREIGN KEY (MostPopulousCity) REFERENCES city(ID);

INSERT INTO `continent` VALUES ("Africa", 30370000, 20.4, NULL);
INSERT INTO `continent` VALUES ("Antarctica", 14000000, 9.2, NULL);
INSERT INTO `continent` VALUES ("Asia", 44579000, 29.5, NULL);
INSERT INTO `continent` VALUES ("Europe", 10180000, 6.8, NULL);
INSERT INTO `continent` VALUES ("North America", 24709000, 16.5, NULL);
INSERT INTO `continent` VALUES ("Oceania", 8600000, 5.9, NULL);
INSERT INTO `continent` VALUES ("South America", 17840000, 12.0, NULL);

ALTER TABLE country ADD FOREIGN KEY (Continent) REFERENCES continent(Name);