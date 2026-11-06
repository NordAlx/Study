-- Новая учебная таблица, основные 16 таблиц не меняются.
CREATE SCHEMA IF NOT EXISTS rbd;
CREATE TABLE rbd.categories(
    id_category integer PRIMARY KEY,
    name varchar(100) NOT NULL,
    parent_id integer REFERENCES rbd.categories(id_category)
);
INSERT INTO rbd.categories VALUES
(1,'Услуги киберклуба',NULL),(2,'Игровые зоны',1),(3,'Дополнительные услуги',1),
(4,'Компьютерные места',2),(5,'VR-места',2),(6,'VIP-места',4),(7,'Проведение турниров',3);
SELECT * FROM rbd.categories ORDER BY id_category;
