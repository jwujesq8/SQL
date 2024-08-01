DROP TABLE IF EXISTS Regiony_Mapa
CREATE TABLE Regiony_Mapa
(id int IDENTITY(1,1),
 nazwa_wersja VARCHAR(100),
 nazwa_poprawna VARCHAR(100)
)

INSERT INTO Regiony_Mapa (nazwa_wersja, nazwa_poprawna) VALUES
('Others', 'Pozostale'),
('Poludnie', 'Poludnie'),
('Zachod', 'Zachod'),
('Po�udnie', 'Poludnie'),
('Zach�d',  'Zachod')

UPDATE frania200507_copy
    SET region = rm.nazwa_poprawna
FROM frania200507_copy f JOIN Regiony_Mapa rm
    ON f.region = rm.nazwa_wersja 