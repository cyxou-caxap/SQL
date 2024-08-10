DROP TABLE IF EXISTS car_parking;
DROP TABLE IF EXISTS parking;
DROP TABLE IF EXISTS street;
DROP TABLE IF EXISTS district;
DROP TABLE IF EXISTS car_owner;
DROP TABLE IF EXISTS owner;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS brand;
DROP TABLE IF EXISTS car_in_repair;

CREATE TABLE brand
(
	brand_id int PRIMARY KEY,
	brand_name varchar(20) UNIQUE
);

CREATE TABLE car
(
	car_id int PRIMARY KEY,
	reg_num varchar(10) NOT NULL,
	fk_brand integer NOT NULL,
	FOREIGN KEY(fk_brand) REFERENCES brand(brand_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE owner
(
	owner_id int PRIMARY KEY,
	owner_name varchar(40) NULL,
	owner_surname varchar(40) NULL,
	owner_patronymic varchar(40) DEFAULT NULL
);

CREATE TABLE car_owner
(
	car_owner_id int PRIMARY KEY,
	fk_car integer NOT NULL,
	fk_owner integer NOT NULL,
	FOREIGN KEY(fk_car) REFERENCES car(car_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(fk_owner) REFERENCES owner(owner_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE street
(
	street_id int PRIMARY KEY,
	street_name varchar(40)UNIQUE NULL
);

CREATE TABLE district
(
	district_id int PRIMARY KEY,
	district_name varchar(40)UNIQUE NULL
);

CREATE TABLE parking
(
	parking_id int PRIMARY KEY,
	opening time NULL,
	address int NULL,
	fk_street integer NOT NULL,
	fk_district integer NOT NULL,
	FOREIGN KEY(fk_street) REFERENCES street(street_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY(fk_district) REFERENCES district(district_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE car_parking
(
	car_parking_id int PRIMARY KEY,
	arrival timestamp without time zone NULL,
	parking_space varchar(5) NULL,
	departure timestamp without time zone NULL,
	fk_car integer NOT NULL,
	fk_parking integer NOT NULL,
	FOREIGN KEY(fk_car) REFERENCES car(car_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(fk_parking) REFERENCES parking(parking_id) ON DELETE CASCADE ON UPDATE CASCADE
);

/*
--Скрипт изменения структуры таблиц

INSERT INTO brand VALUES (1,'Hyundai'), (2,'Ford'); --Добавить элемент
SELECT * FROM brand; --Вывести таблицу

ALTER TABLE super_car_parking rename to car_parking; --вернуть прежнее название таблицы
SELECT * FROM car_parking; --Вывести таблицу

ALTER TABLE car_parking ADD parking_name TIMESTAMP; --Добавить столбец parking_name
ALTER TABLE car_parking DROP COLUMN car_parking_id; --Удалить столбец car_parking_id
ALTER TABLE car_parking ADD PRIMARY KEY(parking_name); --Сделать столбец "название парковки" первичным ключом
ALTER TABLE car_parking rename to super_car_parking; --переименовать таблицу
SELECT * FROM super_car_parking; --Вывести таблицу

*/