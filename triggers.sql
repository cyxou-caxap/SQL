--создание таблицы для хранения старых данных
DROP TABLE IF EXISTS back_up_owner;
CREATE TABLE back_up_owner
(
back_id serial PRIMARY KEY,
owner_id_old int,
owner_name_old varchar(40) NULL,
owner_surname_old varchar(40) NULL,
owner_patronymic_old varchar(40) DEFAULT NULL,
refresh_time time,
refresh_date date
);

--вставка до
DROP FUNCTION IF EXISTS insert_inf_fun() CASCADE;

CREATE OR REPLACE FUNCTION insert_inf_fun() RETURNS TRIGGER AS 
$$
BEGIN
IF NEW.owner_patronymic IS NULL
THEN NEW.owner_patronymic := 'The owner has no patronymic';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER insert_inf
BEFORE INSERT ON owner
FOR EACH ROW
EXECUTE PROCEDURE insert_inf_fun();

INSERT INTO owner (owner_id, owner_name, owner_surname)
VALUES (6, 'Максимов', 'Максим');
SELECT * FROM owner;

--обновление до
DROP FUNCTION IF EXISTS back_up_fun() CASCADE;

CREATE OR REPLACE FUNCTION back_up_fun() RETURNS TRIGGER AS 
$$
BEGIN
INSERT INTO back_up_owner (owner_id_old, owner_name_old, owner_surname_old, 
owner_patronymic_old, refresh_time, refresh_date)
VALUES(OLD.owner_id, OLD.owner_name, OLD.owner_surname, OLD.owner_patronymic,
	   (SELECT CURRENT_TIME), (SELECT CURRENT_DATE));
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER back_up_update 
BEFORE UPDATE ON owner
FOR EACH ROW
EXECUTE PROCEDURE back_up_fun();

UPDATE owner SET owner_name = 'Катя' WHERE owner_name = 'Юля';
SELECT * FROM owner;
SELECT * FROM back_up_owner;

--каскадное удаление до
DROP FUNCTION IF EXISTS cascade_delete_fun() CASCADE;

CREATE OR REPLACE FUNCTION cascade_delete_fun() RETURNS 
TRIGGER AS $$
BEGIN
DELETE FROM car_owner WHERE car_owner.fk_owner = OLD.owner_id;
RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER cascade_delete
BEFORE DELETE ON owner
FOR EACH ROW
EXECUTE PROCEDURE cascade_delete_fun();

DELETE FROM owner WHERE owner_id = 2;
SELECT * FROM owner;
SELECT * FROM car_owner;

--вставка после
DROP FUNCTION IF EXISTS ins_parking() CASCADE;

CREATE OR REPLACE FUNCTION ins_parking() RETURNS 
TRIGGER AS $$
BEGIN
UPDATE street SET parking_count = parking_count + 1 WHERE street_id = 
NEW.fk_street;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER count_parking_ins 
AFTER INSERT ON parking
FOR EACH ROW
EXECUTE PROCEDURE ins_parking();

INSERT INTO parking 
VALUES
(7,'Парковка 7','11:30:00',4,2,2);
SELECT * FROM parking;
SELECT * FROM street;

--обновление после
DROP FUNCTION IF EXISTS upd_parking() CASCADE;

CREATE OR REPLACE FUNCTION upd_parking() RETURNS 
TRIGGER AS $$
BEGIN
UPDATE street SET parking_count = parking_count + 1 WHERE street_id = 
NEW.fk_street;
UPDATE street SET parking_count = parking_count - 1 WHERE street_id = 
OLD.fk_street;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER count_parking_upd 
AFTER UPDATE ON parking
FOR EACH ROW
EXECUTE PROCEDURE upd_parking();

UPDATE parking SET fk_street = 2 where address = 49;
SELECT * FROM parking;
SELECT * FROM street;

--удаление после
DROP FUNCTION IF EXISTS del_parking_to_street() CASCADE;

CREATE OR REPLACE FUNCTION del_parking_to_street() RETURNS 
TRIGGER AS $$
BEGIN
UPDATE street SET parking_count = parking_count - 1 WHERE street_id = 
OLD.fk_street;
RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER count_parking_del 
AFTER DELETE ON parking
FOR EACH ROW
EXECUTE PROCEDURE del_parking_to_street();

DELETE FROM parking WHERE parking_id = 2;
SELECT * FROM street;
SELECT * FROM parking;