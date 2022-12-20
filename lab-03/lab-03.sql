CREATE OR REPLACE FUNCTION Musicians_Age(Birth_year INT, Death_year INT) RETURNS INT AS
$$
BEGIN
    IF Death_year IS NULL
        THEN RETURN (2022 - Birth_year);
    ELSE
        RETURN (Death_year - Birth_year);
    END IF;
END;
$$ LANGUAGE plpgsql;
----------Подставляемая табличная функция----------
CREATE OR REPLACE FUNCTION Musician_name_and_age() RETURNS TABLE(musician_name VARCHAR(32), musician_age INT) AS $$
BEGIN
    RETURN QUERY (SELECT musicians.musician_name, Musicians_Age(musician_born, musician_died) AS musician_age
    FROM musicians);
END
$$ LANGUAGE plpgsql;
---- Вызов функции
SELECT *
FROM Musician_name_and_age() LIMIT 10;
-----------Многооператорная табличная функция---------
CREATE OR REPLACE FUNCTION Musicians_and_bands() RETURNS TABLE(info VARCHAR(32)) AS $$
BEGIN
    RETURN QUERY (SELECT musicians.musician_name FROM musicians UNION SELECT title FROM bands);
END
$$ LANGUAGE plpgsql;
SELECT *
FROM Musicians_and_bands() LIMIT 10;
----Рекурсивная функия------
CREATE OR REPLACE FUNCTION get_binary_data() RETURNS TABLE(musician_name character varying, musician_id integer) AS $$
BEGIN
    RETURN QUERY (
        WITH RECURSIVE c(n) AS (
            VALUES(2)
            UNION ALL
            SELECT n*n FROM c WHERE n < 100)
        SELECT musicians.musician_name, musicians.musician_id
        FROM musicians
        WHERE musicians.musician_id IN (SELECT n FROM c));
END
$$ LANGUAGE plpgsql;
SELECT *
FROM get_binary_data();
-----Хранимая процедура------
CREATE OR REPLACE PROCEDURE insert_data_in_release(cur_id integer, cur_title character varying, cur_release_year integer, cur_kind character varying) LANGUAGE 'sql' AS $$
    INSERT INTO release VALUES (cur_id, cur_title, cur_release_year, cur_kind);
$$;
--CALL insert_data_in_release(53, 'Bloody Garden', 1999, 'album');
----Рекурсивная хранимая процедура-----
CREATE OR REPLACE PROCEDURE proc(INOUT integer) AS $$
DECLARE a INT;
BEGIN
    a:= $1+1;
    IF $1<10 THEN RAISE NOTICE 'a=%', $1; CALL proc(a);
    ELSE RETURN;
    END IF;
    $1:=a;
END;
$$ LANGUAGE 'plpgsql';
--CALL proc(5);
-----Хранимая процедура с курсором-----
CREATE OR REPLACE PROCEDURE proc_with_cursor() AS $$
DECLARE
    rec record;
    curs CURSOR (curkind VARCHAR(32)) FOR SELECT * FROM instruments WHERE instruments.kind = curkind;
BEGIN
    OPEN curs('bass');
    LOOP
      FETCH curs INTO rec;
      EXIT WHEN NOT FOUND;
      IF rec.manufacturer LIKE '%War%' THEN 
         RAISE NOTICE 'Model - %', rec.model;
      END IF;
   END LOOP;
   CLOSE curs;
END;
$$ LANGUAGE 'plpgsql';
--CALL proc_with_cursor();
-----Хранимая процедура доступа к метаданным----
CREATE OR REPLACE PROCEDURE table_info() AS $$
DECLARE
    rec record;
    curs CURSOR (curtable VARCHAR(32)) FOR SELECT column_name, column_default, data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = curtable;
BEGIN
    OPEN curs('release');
    LOOP
      FETCH curs INTO rec;
      EXIT WHEN NOT FOUND;
      RAISE NOTICE 'Column name - %', rec.column_name;
   END LOOP;
   CLOSE curs;
END;
$$ LANGUAGE 'plpgsql';
--CALL table_info();
-----Триггер BEFORE-----
CREATE OR REPLACE FUNCTION trigger_before_upd() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.musician_born != OLD.musician_born)
    THEN RAISE NOTICE 'You cannot modify musician_born!';
    END IF;
    RETURN NEW;
END 
$$ LANGUAGE 'plpgsql';
/*CREATE TRIGGER trigg BEFORE UPDATE ON musicians
FOR EACH ROW EXECUTE PROCEDURE trigger_before_upd();
UPDATE musicians SET musician_born = 1999 WHERE musician_id = 1;*/
-----Триггер INSTEAD OF-----
CREATE OR REPLACE VIEW releases_in_1968 AS
 SELECT release.id, release.title, release.release_year, release.kind
 FROM release
 WHERE release.release_year = 1968;

CREATE OR REPLACE FUNCTION trigger_instead_of_ins() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Releases_in_1968 WHERE Releases_in_1968.title = NEW.title)>0
    THEN RAISE NOTICE 'This title already exists!';
    END IF;
    RETURN NEW;
END 
$$ LANGUAGE 'plpgsql';
/*CREATE TRIGGER trigger_insert INSTEAD OF INSERT ON releases_in_1968
FOR EACH ROW EXECUTE FUNCTION trigger_instead_of_ins();*/
INSERT INTO Releases_in_1968 VALUES (67,'Bloody Town',1968,'single');
