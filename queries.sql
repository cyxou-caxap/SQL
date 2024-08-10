--а. все парковки, расположенные на улицах, в названии которых есть слово «Малая», но на него название не заканчивается 
--пунк а
SELECT parking_id, street.street_name 
FROM parking, street 
WHERE parking.fk_street =street.street_id AND street_name ILIKE '%малая%_';

---б. владелец машины, у которого несколько машин разных марок 
--пункт б
Select distinct o.owner_name from owner o
inner join car_owner co on o.owner_id = co.fk_owner
inner join car c on co.fk_car = c.car_id
inner join car_owner co2 on o.owner_id = co2.fk_owner
inner join car c2 on co2.fk_car = c2.car_id
where c.fk_brand > c2.fk_brand

--в. улица, на которой нет парковок 
--пункт в
SELECT street.street_name AS street_without_parking
FROM street
LEFT JOIN parking ON street.street_id = parking.fk_street
WHERE parking.fk_street IS NULL; 

--г. парковка, открывающаяся позже всех 
--пункт г
SELECT *
FROM parking
WHERE opening = (SELECT MAX(opening) FROM parking);

SELECT *
FROM parking
WHERE opening >= ALL (SELECT opening FROM parking WHERE opening  IS NOT NULL);

--д. владелец машины, останавливавшийся на парковках, количество которых больше среднего
--пункт д
SELECT DISTINCT o.owner_id, o.owner_name
FROM owner o
JOIN car_owner oc ON o.owner_id = oc.fk_owner
JOIN car c ON oc.fk_car = c.car_id
JOIN car_parking cp ON c.car_id = cp.fk_car
JOIN parking p ON cp.fk_parking = p.parking_id
GROUP BY o.owner_id, o.owner_name
HAVING COUNT(DISTINCT p.parking_id) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(DISTINCT p.parking_id) as cnt
        FROM owner oo
        JOIN car_owner ooc ON oo.owner_id = ooc.fk_owner
        JOIN car cc ON ooc.fk_car = cc.car_id
        JOIN car_parking car_p ON cc.car_id = car_p.fk_car
        JOIN parking p ON car_p.fk_parking = p.parking_id
        GROUP BY oo.owner_id
    ) AS parking_counts
);

--е. машина, которая стояла на всех парковках Центрального района 
--пункт e через агрегатную функцию
SELECT c.*
FROM car c
JOIN car_parking cp ON c.car_id = cp.fk_car
JOIN parking p ON cp.fk_parking = p.parking_id
JOIN district ON p.fk_district = district.district_id
WHERE district_name = 'Центральный'
GROUP BY c.car_id
HAVING COUNT(DISTINCT p.parking_id) = (
    SELECT COUNT(DISTINCT pd.parking_id)
    FROM parking pd
	JOIN district ON pd.fk_district = district.district_id
	WHERE district_name = 'Центральный'
);
--Делимое - машина
--Делитель - парковки центрального района

--пункт e через 2 NOT EXISTS
SELECT DISTINCT c.*
FROM car c
WHERE NOT EXISTS (
    SELECT 1
    FROM parking pd
	JOIN district ON pd.fk_district = district.district_id
	WHERE district_name = 'Центральный'
    AND NOT EXISTS (
        SELECT 1
        FROM car_parking cpd
        WHERE cpd.fk_car = c.car_id 
        AND cpd.fk_parking = pd.parking_id
    )
);

--ж. владелец, не парковавшийся на Вознесенском проспекте, но парковавшийся в Московском районе 
--пункт ж через NOT IN
SELECT o.owner_id, o.owner_name FROM owner o
JOIN car_owner oc ON o.owner_id = oc.fk_owner
JOIN car c ON oc.fk_car = c.car_id
JOIN car_parking cp ON c.car_id = cp.fk_car
JOIN parking p ON cp.fk_parking = p.parking_id
JOIN district d ON p.fk_district = d.district_id
WHERE d.district_name = 'Московский'
AND o.owner_id NOT IN (
    SELECT owner_id FROM owner
    JOIN car_owner oc ON owner_id = oc.fk_owner
	JOIN car c ON oc.fk_car = c.car_id
	JOIN car_parking cp ON c.car_id = cp.fk_car
	JOIN parking p ON cp.fk_parking = p.parking_id
    JOIN street s ON p.fk_street = s.street_id
    WHERE s.street_name = 'Вознесенский проспект'
);

--пункт ж через EXCEPT
SELECT o.owner_id, o.owner_name FROM owner o
JOIN car_owner oc ON o.owner_id = oc.fk_owner
JOIN car c ON oc.fk_car = c.car_id
JOIN car_parking cp ON c.car_id = cp.fk_car
JOIN parking p ON cp.fk_parking = p.parking_id
JOIN district d ON p.fk_district = d.district_id
WHERE d.district_name = 'Московский'

EXCEPT

SELECT o.owner_id, o.owner_name FROM owner o
JOIN car_owner oc ON o.owner_id = oc.fk_owner
JOIN car c ON oc.fk_car = c.car_id
JOIN car_parking cp ON c.car_id = cp.fk_car
JOIN parking p ON cp.fk_parking = p.parking_id
JOIN street s ON p.fk_street = s.street_id
WHERE s.street_name = 'Вознесенский проспект';

--пункт ж через LEFT JOIN
SELECT o.owner_id, o.owner_name FROM owner o
JOIN car_owner oc ON o.owner_id = oc.fk_owner
JOIN car c ON oc.fk_car = c.car_id
JOIN car_parking cp ON c.car_id = cp.fk_car
JOIN parking p ON cp.fk_parking = p.parking_id
JOIN street s ON p.fk_street = s.street_id
JOIN district d ON p.fk_district = d.district_id
LEFT JOIN (
    SELECT o.owner_id FROM owner o
    JOIN car_owner oc ON oc.fk_owner = o.owner_id 
	JOIN car c ON c.car_id = oc.fk_car
	JOIN car_parking cp ON cp.fk_car = c.car_id 
	JOIN parking p ON p.parking_id = cp.fk_parking 
	JOIN street s ON s.street_id = p.fk_street
	JOIN district d ON d.district_id = p.fk_district 
    WHERE s.street_name = 'Вознесенский проспект'
) AS q ON o.owner_id = q.owner_id
WHERE d.district_name = 'Московский' AND q.owner_id IS NULL;
