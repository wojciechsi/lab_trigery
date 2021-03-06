--PODSTAWY BAZ DANYCH
--temat: triggery
--sprawozdanie z laboratorium
--autorzy: Maciej Bolesta, Wojciech Siudy, sekcja 7
--prowadzący zajęcia: dr inż. Małgorzata Bach
--data: 8 czerwca 2022

--3.1
CREATE TABLE Osoby (imie varchar(15), nazwisko varchar(15), PESEL varchar(11), data_ur timestamp);

--3.2
CREATE TABLE Pracownicy (nr_prac integer, nr_zesp integer, pensja real) INHERITS (Osoby);

--3.3
INSERT INTO Osoby (imie, nazwisko, PESEL, data_ur)
VALUES ('Jan', 'Nowak', '11111111111', '1988-01-01');
INSERT INTO Osoby (imie, nazwisko, PESEL, data_ur)
VALUES ('Adam', 'Kowalski', '22222222222', '1989-10-01');
INSERT INTO Osoby (imie, nazwisko, PESEL, data_ur)
VALUES ('Anna', 'Krol', '33333333333', '1990-10-15');

--3.4
INSERT INTO Pracownicy (imie, nazwisko, PESEL, data_ur, nr_prac, nr_zesp, pensja)
VALUES ('Tomasz', 'Wicek', '44444444444', '1978-12-12', '1', '10', '2500');
INSERT INTO Pracownicy (imie, nazwisko, PESEL, data_ur, nr_prac, nr_zesp, pensja)
VALUES ('Maria', 'Bialek', '55555555555', '1980-12-12', '2', '10', '2000');

--3.5
SELECT * FROM pg_tables
WHERE tablename = 'osoby' or tablename = 'pracownicy';

--3.6
SELECT pa.attname, pt.typname
FROM pg_class pc, pg_attribute pa, pg_type pt
WHERE pc.relname='osoby' AND pc.oid =pa.attrelid AND pt.oid = pa.atttypid;

--3.7
SELECT tableoid FROM Pracownicy;

--3.8
SELECT tableoid FROM Osoby;
--tabela pracownicy zwróciła tyle rekordów, co pracowników
--z kolei tabela osoby tyle, ile pracowników i osób razem wziętych
--wartości tableoid świadczy o tym, z jakiej tebeli pojawił się rekord
--(w wyświetlanym wyniku różnią się)

--3.9
SELECT tableoid, * FROM Osoby;
--potwierdziło się, jednak wyświetlają się jedynie kolumny tabeli Osoby

--3.10
SELECT tableoid, * FROM ONLY Osoby;
--w tym przypadku wynikiem są tylko Osoby niebędące pracownikami

--3.11
DELETE FROM pracownicy WHERE imie = 'Maria';

--3.12
SELECT * FROM pracownicy;
SELECT * FROM osoby;
--udało się usunąć z obu tabel

--3.13
INSERT INTO pracownicy (imie, nazwisko, PESEL, data_ur, nr_prac, nr_zesp, pensja)
VALUES ('Witold', 'Wrembel', '88888888888', '02-02-1977', '2', '10', '1950');
INSERT INTO pracownicy (imie, nazwisko, PESEL, data_ur, nr_prac, nr_zesp, pensja)
VALUES ('Kamila', 'Bialek', '99999999999', '12-12-1983', '3', '20', '2000');

--3.14
SELECT tableoid FROM Pracownicy;
--początkowo pracowników było dwoje, usunęliśmy jedną, po czym dodaliśmy dwoje, zatem
--wartości jest tyle, ile rekordów - 3, zaś id tabeli pozostaje bez zmian

--3.15
create table premie (nr_prac integer, premia_kwartalna integer[]);

--3.16
insert into premie values (1, '{100,150,200,250}');

--3.17
Select * from premie;
select premia_kwartalna[1] from premie;

--3.18
CREATE TABLE wypozyczenia (nr_prac integer, autor_tytul text[][]);

--3.19
INSERT INTO wypozyczenia VALUES
(1, '{{"Tolkien", "Hobbit", "Iskry", 1980}, {"Dickens", "Klub Pickwicka", "MG", 1989}, {"Stone",
"Pasja zycia", "ZYSK I S-KA", 1999}}');
INSERT INTO wypozyczenia VALUES (2, '{{"Pascal", "Przewodnik", "lonely planet", 2010},
{"Archer", "Co do grosza", "REBIS Sp. z o.o.", 1999}}');

--3.20
SELECT * FROM wypozyczenia;
--pokazało wszystkie

SELECT nr_prac, autor_tytul[1][1] FROM wypozyczenia;
--pokazało autorów pierwszej wypożyczonej książki każdego pracownika

SELECT nr_prac, autor_tytul[1:3][1] FROM wypozyczenia;
--pokazało autorów od pierwszej do trzeciej wypożyczonej pozycji

SELECT nr_prac, autor_tytul[1:3][1:3] FROM wypozyczenia;
--pokazało pierwsze trzy wartości trzech pierwszych wypożyczeń

SELECT nr_prac, autor_tytul[1:3][2] FROM wypozyczenia;
--pierwsze dwa atrybuty trzech wypożyczeń

SELECT nr_prac, autor_tytul[2][2] FROM wypozyczenia;
--drugi atrybut (tytuł) drugiego wypożyczenia każdego pracownika

SELECT nr_prac, autor_tytul[2][1] FROM wypozyczenia;
--pierwszy atrybut (autor) drugiego wypożyczenia każdego pracownika

--3.21
CREATE FUNCTION dane (integer) RETURNS text
AS 'select nazwisko from Pracownicy where nr_prac = $1'
LANGUAGE 'sql';

--3.22
select dane(1) as nazwisko;
--funkcja działa poprawnie

--3.23
CREATE TYPE complex AS (i text, n text, p text);
CREATE FUNCTION dane2 (integer) RETURNS complex
AS 'select imie, nazwisko, PESEL from Pracownicy where nr_prac = $1'
LANGUAGE 'sql';
select dane2(2);
--funkcja działa poprawnie

--3.24
CREATE FUNCTION dane3 () RETURNS setof complex
AS 'select imie, nazwisko, PESEL from Pracownicy'
LANGUAGE 'sql';
select dane3();
--funkcja działa poprawnie

--3.25
CREATE FUNCTION tytuly (integer) RETURNS setof text[]
AS 'SELECT autor_tytul[1:100][2:2]FROM wypozyczenia WHERE nr_prac = $1'
LANGUAGE 'sql';
select tytuly(1);
--funkcja działa poprawnie (trzeba niestety określić maksymalną ilość wypożyczeń)

--3.26
CREATE OR REPLACE FUNCTION concat (text, text) RETURNS text AS
$$
    --DECLARE --mogłoby być
    BEGIN
    RETURN $1||$2;
    END;
$$
LANGUAGE 'plpgsql';

--3.27
SELECT concat('bazy ', 'danych');
--funkcja działa poprawnie

--3.28
CREATE OR REPLACE FUNCTION extra_money (integer) RETURNS real AS
$$
DECLARE zm real;
BEGIN
SELECT 1.25 * pensja INTO zm FROM pracownicy WHERE nr_prac = $1;
RETURN zm;
END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM pracownicy;
UPDATE pracownicy SET pensja = extra_money(1) WHERE nr_prac = 1;
SELECT * FROM pracownicy;
--pracownik o numerze 1 dostał podwyżkę

--3.29
ALTER TABLE Osoby ADD COLUMN prefix_tel TEXT;
ALTER TABLE Osoby ADD COLUMN tel TEXT;
UPDATE Osoby SET prefix_tel = '0-16' WHERE imie = 'Witold';
UPDATE Osoby SET tel = '7654321' WHERE imie = 'Witold';
UPDATE Osoby SET prefix_tel = '0' WHERE imie = 'Kamila';
UPDATE Osoby SET tel = '500010203' WHERE imie = 'Kamila';

SELECT * FROM osoby;
--oba numery dodano poprawnie

--3.30
CREATE OR REPLACE FUNCTION merge_fields(t_row pracownicy) RETURNS text AS
$$
BEGIN
RETURN t_row.imie || ' ' || t_row.nazwisko || ' ' || t_row.prefix_tel || t_row.tel;
END;
$$
LANGUAGE plpgsql;

SELECT merge_fields(t.*) FROM pracownicy t;
--funkcja podała poprawnie złączone dane

--3.31
CREATE OR REPLACE FUNCTION merge_fields(t_row osoby) RETURNS text AS
$$
BEGIN
RETURN t_row.prefix_tel || t_row.tel;
END;
$$
LANGUAGE plpgsql;

SELECT merge_fields(t.*) FROM osoby t ;
--ponownie poprawnie połączone dane

--3.32
CREATE RULE regula1
AS ON UPDATE TO Pracownicy
WHERE NEW.pensja <> OLD.pensja
DO INSTEAD NOTHING;

--3.33
SELECT * FROM pracownicy;
UPDATE pracownicy SET nr_zesp = 30 WHERE nr_zesp = 20;
SELECT * FROM pracownicy;
UPDATE pracownicy SET pensja = 2000 WHERE imie = 'Witold';
SELECT * FROM pracownicy;
--reguła działała poprawnie

DROP RULE regula1 ON pracownicy;

--3.34
CREATE RULE regula2
AS ON INSERT TO pracownicy
WHERE nr_prac <= 0
DO INSTEAD NOTHING;

INSERT INTO pracownicy (nr_prac) VALUES (-5);
SELECT * FROM pracownicy;
--reguła działa poprawnie

--3.35
CREATE VIEW osob_view AS SELECT imie, nazwisko, PESEL FROM osoby WHERE
imie='Witold ';

CREATE RULE reg2 AS ON INSERT TO osob_view DO INSTEAD INSERT INTO osoby
(imie, nazwisko, PESEL) VALUES (NEW.imie,NEW.nazwisko, NEW.PESEL);

--3.36
ALTER TABLE Premie ADD COLUMN last_updated timestamptz;

--3.37
CREATE OR REPLACE FUNCTION upd() RETURNS trigger AS
$$
BEGIN
NEW.last_updated = now();
RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER last_upd
BEFORE insert OR update ON Premie
FOR EACH ROW
EXECUTE PROCEDURE upd();

--3.38
SELECT * FROM Premie;
INSERT INTO Premie VALUES (2, '{300,150,100,150}');
SELECT * FROM Premie;
--udało się zaobserwować pojawienie się wartości informującej o ostatniej edycji

--3.39
CREATE TABLE towary(id integer, nazwa text, cena_netto double precision);

INSERT INTO towary VALUES (1, 'kabel', 50);
INSERT INTO towary VALUES (2, 'laptop', 940);
INSERT INTO towary VALUES (3, 'monitor', 600);

--3.40
CREATE OR REPLACE FUNCTION podatek_vat (double precision) RETURNS double precision AS
$$
DECLARE zm double precision;
BEGIN
SELECT 0.23 * $1 INTO zm;
RETURN zm;
END;
$$
LANGUAGE 'plpgsql';

SELECT id, nazwa, cena_netto, podatek_vat(cena_netto), cena_netto + podatek_vat(cena_netto) as cena_brutto
FROM towary;
--skutecznie opodatkowano towary

--3.41
CREATE TABLE towary2(id integer, nazwa text, cena double precision, cena_vat double precision, cena_brutto double precision);


CREATE OR REPLACE FUNCTION opodatkuj() RETURNS TRIGGER AS
$$
    BEGIN
    NEW.cena_vat = podatek_vat(NEW.cena);
    NEW.cena_brutto = NEW.cena_vat + NEW.cena;
    RETURN NEW;
    END;
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER opodatkujTowary2
BEFORE insert OR update ON towary2
FOR EACH ROW
EXECUTE PROCEDURE opodatkuj();

--3.42
INSERT INTO towary2 VALUES (1, 'zasilacz', 100);
SELECT * FROM towary2;
UPDATE towary2 SET cena = 120 WHERE nazwa = 'zasilacz';
SELECT * FROM towary2;
--Vat oraz cena brutto były dodawane zarówno przy insert, jak i update
