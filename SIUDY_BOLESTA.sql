--PODSTAWY BAZ DANYCH
--temat: triggery
--sprawozdanie z laboratorium
--autorzy: Maciej Bolesta, Wojciech Siudy, sekcja 7
--prowadzący zajęcia:
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
