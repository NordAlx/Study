CREATE SCHEMA IF NOT EXISTS rbd;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
-- Задание 1. Только учебные пароли из примера, не реальные пароли пользователя.
CREATE TABLE rbd.system_roles(id_role integer PRIMARY KEY,name varchar(100) NOT NULL UNIQUE);
CREATE TABLE rbd.system_users(
    id_user integer PRIMARY KEY,login varchar(100) NOT NULL UNIQUE,
    id_role integer NOT NULL REFERENCES rbd.system_roles(id_role),
    raw_password text NOT NULL,password_hash bytea NOT NULL
);
INSERT INTO rbd.system_roles VALUES(1,'Администратор'),(2,'Оператор'),(3,'Менеджер');
INSERT INTO rbd.system_users VALUES
(1,'poliektov',1,'DemoOnly_123',public.digest('DemoOnly_123','sha256')),
(2,'operator',2,'DemoOperator_456',public.digest('DemoOperator_456','sha256')),
(3,'manager',3,'DemoManager_789',public.digest('DemoManager_789','sha256'));
-- Q01. Успешная и неуспешная проверки в одном результате.
SELECT u.login,v.entered_password,
(u.password_hash=public.digest(v.entered_password,'sha256')) AS password_matches
FROM rbd.system_users u CROSS JOIN
(VALUES('DemoOnly_123'),('WrongDemoPassword')) AS v(entered_password)
WHERE u.login='poliektov';
-- Задание 2. RANGE по дате. PK включает ключ секционирования.
CREATE TABLE rbd.event_log(
    id_event bigint GENERATED ALWAYS AS IDENTITY,
    event_date date NOT NULL,event_type text NOT NULL,payload jsonb NOT NULL,
    PRIMARY KEY(event_date,id_event)
) PARTITION BY RANGE(event_date);
CREATE TABLE rbd.event_log_2024_h2 PARTITION OF rbd.event_log
FOR VALUES FROM('2024-07-01') TO('2025-01-01');
CREATE TABLE rbd.event_log_2025_h1 PARTITION OF rbd.event_log
FOR VALUES FROM('2025-01-01') TO('2025-07-01');
CREATE TABLE rbd.event_log_default PARTITION OF rbd.event_log DEFAULT;
-- Верхняя граница диапазона исключается; DEFAULT принимает любые остальные даты.
SELECT relid::regclass AS partition,isleaf FROM pg_partition_tree('rbd.event_log');
