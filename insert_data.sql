INSERT INTO street 
VALUES
(1,'Морская малая'),
(2,'Малая кировская'),
(3,'Красная'),
(4,'Вознесенский проспект'),
(5,'Кантемирова'),
(6,'Лиговский проспект'),
(7,'Большая Конюшенная');

INSERT INTO district 
VALUES
(1,'Адмиралтейский'),
(2,'Московский'),
(3,'Василеостровский'),
(4,'Выборгский'),
(5,'Центральный');

INSERT INTO parking 
VALUES
(1,'10:30:00',4,2,2),
(2,'9:30:00',12,1,5),
(3,'8:00:00',356,3,3),
(4,'11:10:00',49,4,4),
(5,'7:00:00',8,5,5);

INSERT INTO brand 
VALUES
(1, 'BMW'),
(2, 'Honda'),
(3, 'Volkswagen'),
(4, 'Ford'),
(5, 'Hyundai');

INSERT INTO car 
VALUES
(1, 'ш674еу', 2),
(2, 'г123цу', 1),
(3, 'з908дл', 2),
(4, 'и236еп', 3),
(5, 'ф825мр', 5);

INSERT INTO owner 
VALUES
(1, 'Иван', 'Петров', 'Васильевич'),
(2, 'Кирилл', 'Пупкин', 'Иванович'),
(3, 'Юля', 'Иванова', 'Аркадьевна'),
(4, 'Полина', 'Курносова', 'Геннадьевна'),
(5, 'Анастасия', 'Мёрфи', 'Дмитриевна');

INSERT INTO car_owner 
VALUES
(1,'1','2'),
(2,'3','2'),
(3,'2','1'),
(4,'4','5'),
(5,'5','1');

INSERT INTO car_parking 
VALUES
(1, '2023-10-18 08:15:30', 'A1', '2023-10-18 15:45:10', 3, 4),
(2, '2023-10-18 10:30:20', 'B2', '2023-10-18 16:20:45', 1, 5),
(3, '2023-10-18 12:45:15', 'C3', '2023-10-18 18:55:30', 2, 1),
(4, '2023-10-18 14:20:50', 'D4', '2023-10-18 20:10:25', 5, 3),
(5, '2023-10-18 16:55:05', 'E5', '2023-10-18 22:35:15', 1, 2),
(6, '2023-10-18 17:55:05', 'W5', '2023-10-18 19:35:15', 1, 1);

/*
--Примеры использования операторов update, delete и merge

--обновление данных
UPDATE brand
SET brand_name = 'Ferari'
WHERE brand_id = 4;
SELECT * FROM brand; --Вывести таблицу

--удаление данных
DELETE FROM brand
WHERE brand_name = 'Ferari';
SELECT * FROM brand; --Вывести таблицу

--merge
CREATE TABLE car_in_repair
(
	car_id int PRIMARY KEY,
	reg_num varchar(10) NOT NULL,
	fk_brand integer NOT NULL,
	cause_of_failure varchar(20) NOT NULL
);

INSERT INTO car_in_repair 
VALUES
(1, 'ш674еу', 2,'авария'),
(2, 'г123цу', 3,'фары'),
(3, 'ф123на', 1,'двигатель'),
(6, 'г419ва', 3,'шины'),
(8, 'з600мп', 5,'повреждение зеркал');
MERGE INTO car as trg
USING car_in_repair as src
ON src.car_id = trg.car_id
WHEN MATCHED THEN
  UPDATE SET reg_num = src.reg_num, fk_brand = src.fk_brand
WHEN NOT MATCHED THEN
  INSERT (car_id, reg_num, fk_brand)
  VALUES (src.car_id, src.reg_num, src.fk_brand);
  SELECT * FROM car; --Вывести таблицу

*/