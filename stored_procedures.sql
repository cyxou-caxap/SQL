--вставка с пополнением справочников
DROP PROCEDURE ins_car(namebrand varchar(20), numreg varchar(10));
CREATE PROCEDURE ins_car(namebrand varchar(20), numreg varchar(10)) AS $$
DECLARE brand_id_new int;
DECLARE car_id_new int;
BEGIN
IF EXISTS (SELECT * FROM brand WHERE brand_name = namebrand)
	THEN SELECT brand_id INTO brand_id_new FROM brand WHERE brand_name = namebrand;
	ELSE BEGIN
	brand_id_new := (SELECT coalesce(MAX(brand_id)+1, 0) FROM brand);
	INSERT INTO brand(brand_id, brand_name)
	VALUES (brand_id_new, namebrand);
	END;
END IF;
car_id_new:=(SELECT coalesce(MAX(car_id)+1, 0) FROM car);
IF NOT EXISTS (SELECT * FROM car WHERE  reg_num= numreg)
THEN INSERT INTO car(car_id, reg_num, fk_brand)
VALUES(car_id_new, numreg, brand_id_new);
END IF;
END;
$$ LANGUAGE plpgsql;

CALL ins_car('Honda', 'ш674еу');
CALL ins_car('Tesla', 'о840нн');
select * from car;
select * from brand;

--удаление с очисткой справочников
DROP PROCEDURE del_car_clear_br(car_id_del int);
CREATE PROCEDURE del_car_clear_br(car_id_del int) AS $$
DECLARE fk_brand_del int;
BEGIN
SELECT fk_brand INTO fk_brand_del FROM car WHERE car_id = car_id_del;
DELETE FROM car WHERE car_id = car_id_del;
IF NOT EXISTS(SELECT * FROM car WHERE fk_brand = fk_brand_del)
THEN DELETE FROM brand WHERE brand_id = fk_brand_del;
END IF;
END;
$$ LANGUAGE plpgsql;

CALL del_car_clear_br(2);
CALL del_car_clear_br(3);
select * from car;
select * from brand;

--каскадное удаление
DROP PROCEDURE del_brand_cascade(brand_id_del int);
CREATE PROCEDURE del_brand_cascade(brand_id_del int) AS $$
BEGIN
	DELETE FROM car_parking 
	WHERE fk_car IN (SELECT car_id FROM car WHERE fk_brand=brand_id_del);
	
	DELETE FROM car_owner 
	WHERE fk_car IN (SELECT car_id FROM car WHERE fk_brand=brand_id_del);
	
	DELETE FROM car WHERE fk_brand=brand_id_del;
	
	DELETE FROM brand WHERE brand_id=brand_id_del;
END;
$$ LANGUAGE plpgsql;

CALL del_brand_cascade(2);
select * from car;
select * from car_owner;
select * from car_parking;
select * from brand;

--вычисление и возврат значения агрегатной функции
DROP PROCEDURE count_brand_out(OUT count_brand int);
CREATE OR REPLACE PROCEDURE count_brand_out(OUT count_brand int) AS $$
BEGIN
SELECT COALESCE(COUNT(brand_id), 0) INTO count_brand FROM brand;
END;
$$ LANGUAGE plpgsql;

CALL count_brand_out(null);

DROP FUNCTION count_brand_out_fun(OUT count_brand int);
CREATE OR REPLACE FUNCTION count_brand_out_fun(OUT count_brand int) AS $$
BEGIN
SELECT COALESCE(COUNT(brand_id), 0) INTO count_brand FROM brand;
END;
$$ LANGUAGE plpgsql;

SELECT count_brand_out_fun();

--формирование статистики во временной таблице
DROP FUNCTION cas_statistics();
CREATE OR REPLACE FUNCTION cas_statistics() 
RETURNS TABLE(id_c INT, o_count INT, parking_count INT, street_count INT, district_count INT) AS $$
BEGIN
  -- Создаем временную таблицу для хранения статистики
  CREATE TEMPORARY TABLE stat_table
  (id_stat serial PRIMARY KEY,
   id_car INT,
   owner_count INT,
   parking_count INT,
   street_count INT,
   district_count INT   
  );

  -- Заполняем временную таблицу статистикой владельцев
  INSERT INTO stat_table (id_car, owner_count)
  SELECT
    car.car_id,
    COUNT(DISTINCT car_owner.fk_owner) AS owner_count
  FROM
    car
  LEFT JOIN
    car_owner ON car.car_id = car_owner.fk_car
  GROUP BY
    car.car_id;
	
 -- Обновляем временную таблицу для учета парковок
  UPDATE stat_table
  SET
    parking_count = COALESCE(subquery.parking_count, 0)
  FROM (
    SELECT
      car.car_id AS sub_car_id,
      COUNT(DISTINCT car_parking.fk_parking) AS parking_count
    FROM
      car
    LEFT JOIN
      car_parking ON car.car_id = car_parking.fk_car
    GROUP BY
      sub_car_id
  ) AS subquery
  WHERE
    stat_table.id_car = subquery.sub_car_id;
	
  -- Обновляем временную таблицу для учета улиц
  UPDATE stat_table
  SET
   street_count = COALESCE(subquery.streets_count, 0)
  FROM (
    SELECT
      car.car_id AS sub_car_id,
      COUNT(DISTINCT street.street_id) AS streets_count
    FROM
      car
    LEFT JOIN
      car_parking ON car.car_id = car_parking.fk_car
    LEFT JOIN
      parking ON car_parking.fk_parking = parking.parking_id
    LEFT JOIN
      street ON parking.fk_street = street.street_id
    GROUP BY
      sub_car_id
  ) AS subquery
  WHERE
    stat_table.id_car = subquery.sub_car_id;

  -- Обновляем временную таблицу для учета районов
  UPDATE stat_table
  SET
    district_count = COALESCE(subquery.district_count, 0)
  FROM (
    SELECT
      car.car_id AS sub_car_id,
      COUNT(DISTINCT district.district_id) AS district_count
    FROM
      car
    LEFT JOIN
      car_parking ON car.car_id = car_parking.fk_car
    LEFT JOIN
      parking ON car_parking.fk_parking = parking.parking_id
    LEFT JOIN
      district ON parking.fk_district = district.district_id
    GROUP BY
      sub_car_id
  ) AS subquery
  WHERE
    stat_table.id_car = subquery.sub_car_id;

  -- Возвращаем результаты
  RETURN QUERY SELECT id_car, owner_count, stat_table.parking_count, stat_table.street_count, stat_table.district_count FROM stat_table;

  -- Очищаем временную таблицу
  DROP TABLE IF EXISTS stat_table;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM cas_statistics();
