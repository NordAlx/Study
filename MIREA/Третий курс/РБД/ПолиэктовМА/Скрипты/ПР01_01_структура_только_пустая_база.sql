-- База «Киберклуб» по практическим работам 6 и 7.
-- Выполнить один раз в новой базе cyberclub, затем 02_insert_data.sql.
-- Для полного скрипта в DBeaver: Alt+X; при ошибке остановить выполнение.
-- Имена столбцов соответствуют практике 7.
BEGIN;
SET LOCAL search_path TO public;

-- Справочники
CREATE TABLE position (
    id_position serial PRIMARY KEY,
    name varchar(100) NOT NULL
);

CREATE TABLE client (
    id_client serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    number varchar(20),
    email varchar(254)
);

CREATE TABLE loyalty_level (
    id_loyalty_level serial PRIMARY KEY,
    name varchar(100) NOT NULL
);

CREATE TABLE rating (
    id_rating serial PRIMARY KEY,
    rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE gaming_hall (
    id_gaming_hall serial PRIMARY KEY,
    name varchar(100) NOT NULL
);

CREATE TABLE doc_type (
    id_doc_type serial PRIMARY KEY,
    name varchar(100) NOT NULL
);

CREATE TABLE tarif (
    id_tarif serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    price numeric(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE payment_method (
    id_payment_method serial PRIMARY KEY,
    name varchar(100) NOT NULL
);

CREATE TABLE discount (
    id_discount serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    -- Процент скидки: 15 означает 15%, без знака % в значении.
    amount numeric(5,2) NOT NULL CHECK (amount BETWEEN 0 AND 100)
);

-- Таблицы, зависящие от справочников
CREATE TABLE employee (
    id_employee serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    id_position integer NOT NULL,
    number varchar(20) NOT NULL,
    date_of_employment date NOT NULL,
    end_date_of_contract date NOT NULL,
    CONSTRAINT employee_dates_check
        CHECK (end_date_of_contract >= date_of_employment)
);

CREATE TABLE gaming_spot (
    id_gaming_spot serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    id_gaming_hall integer NOT NULL
);

CREATE TABLE loyalty_card (
    id_loyalty_card serial PRIMARY KEY,
    points integer NOT NULL DEFAULT 0 CHECK (points >= 0),
    id_loyalty_level integer NOT NULL,
    id_client integer NOT NULL,
    -- Одному клиенту соответствует не более одной карты.
    CONSTRAINT loyalty_card_client_unique UNIQUE (id_client)
);

CREATE TABLE review (
    id_review serial PRIMARY KEY,
    id_client integer NOT NULL,
    content text NOT NULL,
    id_rating integer NOT NULL
);

CREATE TABLE document (
    id_document serial PRIMARY KEY,
    id_doc_type integer NOT NULL,
    doc_name varchar(200) NOT NULL,
    content text NOT NULL,
    id_employee integer NOT NULL,
    date date NOT NULL
);

CREATE TABLE payment (
    id_payment serial PRIMARY KEY,
    id_payment_method integer NOT NULL,
    amount numeric(10,2) NOT NULL CHECK (amount >= 0),
    status varchar(50) NOT NULL,
    -- NULL означает, что скидка не применялась.
    id_discount integer
);

CREATE TABLE rental_session (
    id_rental_session serial PRIMARY KEY,
    id_client integer NOT NULL,
    id_gaming_spot integer NOT NULL,
    id_employee integer NOT NULL,
    id_tarif integer NOT NULL,
    id_document integer NOT NULL,
    id_payment integer NOT NULL,
    status varchar(50) NOT NULL,
    session_cost numeric(10,2) NOT NULL CHECK (session_cost >= 0)
);

-- Связи из практической работы 7 (16 внешних ключей)
ALTER TABLE employee ADD CONSTRAINT employee_id_position_fk
    FOREIGN KEY (id_position) REFERENCES position (id_position);
ALTER TABLE gaming_spot ADD CONSTRAINT gaming_spot_id_gaming_hall_fk
    FOREIGN KEY (id_gaming_hall) REFERENCES gaming_hall (id_gaming_hall);
ALTER TABLE loyalty_card ADD CONSTRAINT loyalty_card_id_client_fk
    FOREIGN KEY (id_client) REFERENCES client (id_client);
ALTER TABLE loyalty_card ADD CONSTRAINT loyalty_card_id_loyalty_level_fk
    FOREIGN KEY (id_loyalty_level) REFERENCES loyalty_level (id_loyalty_level);
ALTER TABLE review ADD CONSTRAINT review_id_client_fk
    FOREIGN KEY (id_client) REFERENCES client (id_client);
ALTER TABLE review ADD CONSTRAINT review_id_rating_fk
    FOREIGN KEY (id_rating) REFERENCES rating (id_rating);
ALTER TABLE document ADD CONSTRAINT document_id_employee_fk
    FOREIGN KEY (id_employee) REFERENCES employee (id_employee);
ALTER TABLE document ADD CONSTRAINT document_id_doc_type_fk
    FOREIGN KEY (id_doc_type) REFERENCES doc_type (id_doc_type);
ALTER TABLE payment ADD CONSTRAINT payment_id_payment_method_fk
    FOREIGN KEY (id_payment_method) REFERENCES payment_method (id_payment_method);
ALTER TABLE payment ADD CONSTRAINT payment_id_discount_fk
    FOREIGN KEY (id_discount) REFERENCES discount (id_discount);
ALTER TABLE rental_session ADD CONSTRAINT rental_session_id_client_fk
    FOREIGN KEY (id_client) REFERENCES client (id_client);
ALTER TABLE rental_session ADD CONSTRAINT rental_session_id_gaming_spot_fk
    FOREIGN KEY (id_gaming_spot) REFERENCES gaming_spot (id_gaming_spot);
ALTER TABLE rental_session ADD CONSTRAINT rental_session_id_employee_fk
    FOREIGN KEY (id_employee) REFERENCES employee (id_employee);
ALTER TABLE rental_session ADD CONSTRAINT rental_session_id_tarif_fk
    FOREIGN KEY (id_tarif) REFERENCES tarif (id_tarif);
ALTER TABLE rental_session ADD CONSTRAINT rental_session_id_document_fk
    FOREIGN KEY (id_document) REFERENCES document (id_document);
ALTER TABLE rental_session ADD CONSTRAINT rental_session_id_payment_fk
    FOREIGN KEY (id_payment) REFERENCES payment (id_payment);

COMMIT;
