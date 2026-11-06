-- PostgreSQL 18. Учебная проектная модель. UTF8.

-- Запускать в отдельной пустой учебной БД, не в рабочей системе.

BEGIN;

CREATE SCHEMA rop;

SET search_path TO rop, public;

CREATE TABLE department (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
);

COMMENT ON TABLE department IS 'Подразделение';

COMMENT ON COLUMN department.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN department.name IS 'Название подразделения';

CREATE TABLE role (
    code VARCHAR(16) PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
);

COMMENT ON TABLE role IS 'Роль';

COMMENT ON COLUMN role.code IS 'Код роли';

COMMENT ON COLUMN role.name IS 'Название роли';

CREATE TABLE employee (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sso_subject VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    department_id BIGINT NOT NULL REFERENCES department(id) ON DELETE RESTRICT,
    role_code VARCHAR(16) NOT NULL REFERENCES role(code),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE employee IS 'Сотрудник';

COMMENT ON COLUMN employee.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN employee.sso_subject IS 'Стабильный sub внешнего IdP';

COMMENT ON COLUMN employee.display_name IS 'Отображаемое имя';

COMMENT ON COLUMN employee.department_id IS 'Подразделение';

COMMENT ON COLUMN employee.role_code IS 'Одна прикладная роль сотрудника';

COMMENT ON COLUMN employee.is_active IS 'Допуск к входу';

COMMENT ON COLUMN employee.created_at IS 'Момент создания';

CREATE TABLE client (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(14) NOT NULL UNIQUE CHECK (code ~ '^CL-[0-9]{4}-[0-9]{6}$'),
    legal_name VARCHAR(250) NOT NULL,
    inn VARCHAR(10) NOT NULL UNIQUE CHECK (inn ~ '^[0-9]{10}$'),
    manager_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE client IS 'Юридическое лицо';

COMMENT ON COLUMN client.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN client.code IS 'Уникальный пользовательский код';

COMMENT ON COLUMN client.legal_name IS 'Наименование юридического лица';

COMMENT ON COLUMN client.inn IS 'ИНН юридического лица; контрольная сумма проверяется приложением';

COMMENT ON COLUMN client.manager_id IS 'Закреплённый менеджер';

COMMENT ON COLUMN client.created_at IS 'Момент создания';

CREATE TABLE contact (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id BIGINT NOT NULL REFERENCES client(id) ON DELETE RESTRICT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(254),
    phone VARCHAR(32),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

COMMENT ON TABLE contact IS 'Контактное лицо';

COMMENT ON COLUMN contact.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN contact.client_id IS 'Организация контакта';

COMMENT ON COLUMN contact.full_name IS 'Имя контактного лица';

COMMENT ON COLUMN contact.email IS 'Электронная почта, если предоставлена';

COMMENT ON COLUMN contact.phone IS 'Телефон, если предоставлен';

COMMENT ON COLUMN contact.created_at IS 'Момент создания';

CREATE TABLE deal_status (
    code VARCHAR(16) PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
);

COMMENT ON TABLE deal_status IS 'Стадия сделки';

COMMENT ON COLUMN deal_status.code IS 'Машинный код';

COMMENT ON COLUMN deal_status.name IS 'Название';

CREATE TABLE request_type (
    code VARCHAR(16) PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
);

COMMENT ON TABLE request_type IS 'Тип заявки';

COMMENT ON COLUMN request_type.code IS 'Машинный код';

COMMENT ON COLUMN request_type.name IS 'Название';

CREATE TABLE request_status (
    code VARCHAR(16) PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE
);

COMMENT ON TABLE request_status IS 'Статус заявки';

COMMENT ON COLUMN request_status.code IS 'Машинный код';

COMMENT ON COLUMN request_status.name IS 'Название';

CREATE TABLE deal (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(14) NOT NULL UNIQUE CHECK (code ~ '^DL-[0-9]{4}-[0-9]{6}$'),
    client_id BIGINT NOT NULL REFERENCES client(id) ON DELETE RESTRICT,
    owner_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    status_code VARCHAR(16) NOT NULL DEFAULT 'NEW' REFERENCES deal_status(code),
    opened_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMPTZ,
    loss_reason VARCHAR(500),
    CHECK ((status_code IN ('WON','LOST')) = (closed_at IS NOT NULL)),
    CHECK (closed_at IS NULL OR closed_at >= opened_at),
    CHECK (status_code <> 'LOST' OR length(trim(loss_reason)) > 0 AND loss_reason IS NOT NULL)
);

COMMENT ON TABLE deal IS 'Сделка';

COMMENT ON COLUMN deal.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN deal.code IS 'Уникальный пользовательский код';

COMMENT ON COLUMN deal.client_id IS 'Клиент';

COMMENT ON COLUMN deal.owner_id IS 'Ответственный менеджер';

COMMENT ON COLUMN deal.title IS 'Суть обращения';

COMMENT ON COLUMN deal.status_code IS 'Стадия сделки';

COMMENT ON COLUMN deal.opened_at IS 'Момент регистрации обращения';

COMMENT ON COLUMN deal.closed_at IS 'Момент закрытия, только для WON/LOST';

COMMENT ON COLUMN deal.loss_reason IS 'Обязательна при LOST';

CREATE TABLE product (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    unit VARCHAR(30) NOT NULL,
    monthly_price NUMERIC(14,2) NOT NULL CHECK (monthly_price >= 0),
    one_time_price NUMERIC(14,2) NOT NULL CHECK (one_time_price >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE product IS 'Продукт каталога';

COMMENT ON COLUMN product.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN product.code IS 'Код продукта';

COMMENT ON COLUMN product.name IS 'Учебное наименование услуги';

COMMENT ON COLUMN product.unit IS 'Единица количества';

COMMENT ON COLUMN product.monthly_price IS 'Цена за единицу в месяц';

COMMENT ON COLUMN product.one_time_price IS 'Разовая цена за единицу';

COMMENT ON COLUMN product.is_active IS 'Доступность в каталоге';

CREATE TABLE offer (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(14) NOT NULL UNIQUE CHECK (code ~ '^OF-[0-9]{4}-[0-9]{6}$'),
    deal_id BIGINT NOT NULL REFERENCES deal(id) ON DELETE RESTRICT,
    version INTEGER NOT NULL CHECK (version > 0),
    status_code VARCHAR(16) NOT NULL DEFAULT 'DRAFT' CHECK (status_code IN ('DRAFT','SUBMITTED','APPROVED','REJECTED')),
    created_by BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (deal_id, version),
    UNIQUE (id, deal_id)
);

COMMENT ON TABLE offer IS 'Версия предложения';

COMMENT ON COLUMN offer.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN offer.code IS 'Уникальный пользовательский код';

COMMENT ON COLUMN offer.deal_id IS 'Сделка';

COMMENT ON COLUMN offer.version IS 'Номер версии в сделке';

COMMENT ON COLUMN offer.status_code IS 'Состояние согласования';

COMMENT ON COLUMN offer.created_by IS 'Автор версии';

COMMENT ON COLUMN offer.created_at IS 'Момент создания';

CREATE TABLE offer_line (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    offer_id BIGINT NOT NULL REFERENCES offer(id) ON DELETE RESTRICT,
    product_id BIGINT NOT NULL REFERENCES product(id) ON DELETE RESTRICT,
    quantity NUMERIC(12,3) NOT NULL CHECK (quantity > 0),
    monthly_price NUMERIC(14,2) NOT NULL CHECK (monthly_price >= 0),
    one_time_price NUMERIC(14,2) NOT NULL CHECK (one_time_price >= 0),
    discount NUMERIC(5,4) NOT NULL DEFAULT 0 CHECK (discount BETWEEN 0 AND 1),
    monthly_amount NUMERIC(20,2) GENERATED ALWAYS AS (round(quantity * monthly_price * (1-discount),2)) STORED,
    one_time_amount NUMERIC(20,2) GENERATED ALWAYS AS (round(quantity * one_time_price,2)) STORED
);

COMMENT ON TABLE offer_line IS 'Позиция предложения';

COMMENT ON COLUMN offer_line.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN offer_line.offer_id IS 'Версия предложения';

COMMENT ON COLUMN offer_line.product_id IS 'Продукт';

COMMENT ON COLUMN offer_line.quantity IS 'Количество единиц';

COMMENT ON COLUMN offer_line.monthly_price IS 'Снимок абонентской цены за единицу';

COMMENT ON COLUMN offer_line.one_time_price IS 'Снимок разовой цены за единицу';

COMMENT ON COLUMN offer_line.discount IS 'Скидка только на абонентскую часть';

COMMENT ON COLUMN offer_line.monthly_amount IS 'Расчёт строки за месяц';

COMMENT ON COLUMN offer_line.one_time_amount IS 'Разовая сумма строки';

CREATE TABLE approval (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    offer_id BIGINT NOT NULL UNIQUE REFERENCES offer(id),
    approver_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    decision VARCHAR(16) NOT NULL CHECK (decision IN ('APPROVED','REJECTED')),
    comment VARCHAR(1000),
    decided_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE approval IS 'Решение согласования';

COMMENT ON COLUMN approval.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN approval.offer_id IS 'Одна резолюция на версию';

COMMENT ON COLUMN approval.approver_id IS 'Руководитель, не автор';

COMMENT ON COLUMN approval.decision IS 'Решение';

COMMENT ON COLUMN approval.comment IS 'Пояснение';

COMMENT ON COLUMN approval.decided_at IS 'Момент решения';

CREATE TABLE contract (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(14) NOT NULL UNIQUE CHECK (code ~ '^CT-[0-9]{4}-[0-9]{6}$'),
    deal_id BIGINT NOT NULL REFERENCES deal(id) ON DELETE RESTRICT,
    offer_id BIGINT NOT NULL UNIQUE,
    external_number VARCHAR(100) NOT NULL,
    document_ref VARCHAR(500) NOT NULL,
    signed_on DATE NOT NULL,
    starts_on DATE NOT NULL,
    ends_on DATE NOT NULL,
    status_code VARCHAR(16) NOT NULL DEFAULT 'ACTIVE' CHECK (status_code IN ('ACTIVE','EXPIRED','TERMINATED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offer_id,deal_id) REFERENCES offer(id,deal_id) ON DELETE RESTRICT,
    CHECK (ends_on >= starts_on)
);

COMMENT ON TABLE contract IS 'Договор';

COMMENT ON COLUMN contract.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN contract.code IS 'Уникальный пользовательский код';

COMMENT ON COLUMN contract.deal_id IS 'Сделка';

COMMENT ON COLUMN contract.offer_id IS 'Согласованное предложение той же сделки';

COMMENT ON COLUMN contract.external_number IS 'Номер подписанного документа';

COMMENT ON COLUMN contract.document_ref IS 'Внутренняя ссылка на файл, не произвольный URL';

COMMENT ON COLUMN contract.signed_on IS 'Дата подписания вне ИС';

COMMENT ON COLUMN contract.starts_on IS 'Начало действия';

COMMENT ON COLUMN contract.ends_on IS 'Текущий конец действия';

COMMENT ON COLUMN contract.status_code IS 'Состояние договора';

COMMENT ON COLUMN contract.created_at IS 'Момент создания';

CREATE TABLE contract_service (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contract(id) ON DELETE RESTRICT,
    product_id BIGINT NOT NULL REFERENCES product(id) ON DELETE RESTRICT,
    service_label VARCHAR(120) NOT NULL,
    quantity NUMERIC(12,3) NOT NULL CHECK (quantity > 0),
    monthly_unit_price NUMERIC(14,2) NOT NULL CHECK (monthly_unit_price >= 0),
    valid_from TIMESTAMPTZ NOT NULL,
    valid_to TIMESTAMPTZ,
    CHECK (valid_to IS NULL OR valid_to > valid_from)
);

COMMENT ON TABLE contract_service IS 'Версия услуги договора';

COMMENT ON COLUMN contract_service.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN contract_service.contract_id IS 'Договор';

COMMENT ON COLUMN contract_service.product_id IS 'Продукт';

COMMENT ON COLUMN contract_service.service_label IS 'Площадка или обозначение услуги';

COMMENT ON COLUMN contract_service.quantity IS 'Количество единиц';

COMMENT ON COLUMN contract_service.monthly_unit_price IS 'Согласованная цена за единицу после скидки';

COMMENT ON COLUMN contract_service.valid_from IS 'Начало интервала условий';

COMMENT ON COLUMN contract_service.valid_to IS 'Исключённая правая граница; NULL для текущих условий';

CREATE TABLE service_request (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(14) NOT NULL UNIQUE CHECK (code ~ '^RQ-[0-9]{4}-[0-9]{6}$'),
    contract_id BIGINT NOT NULL REFERENCES contract(id) ON DELETE RESTRICT,
    type_code VARCHAR(16) NOT NULL REFERENCES request_type(code),
    status_code VARCHAR(16) NOT NULL DEFAULT 'NEW' REFERENCES request_status(code),
    owner_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    assignee_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    details TEXT NOT NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    target_at TIMESTAMPTZ NOT NULL,
    closed_at TIMESTAMPTZ,
    external_ref VARCHAR(120) UNIQUE,
    CHECK (target_at >= requested_at),
    CHECK (closed_at IS NULL OR closed_at >= requested_at),
    CHECK ((status_code IN ('DONE','FAILED','CANCELLED')) = (closed_at IS NOT NULL))
);

COMMENT ON TABLE service_request IS 'Заявка сопровождения';

COMMENT ON COLUMN service_request.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN service_request.code IS 'Уникальный пользовательский код';

COMMENT ON COLUMN service_request.contract_id IS 'Договор';

COMMENT ON COLUMN service_request.type_code IS 'CONNECT либо CHANGE';

COMMENT ON COLUMN service_request.status_code IS 'Статус исполнения';

COMMENT ON COLUMN service_request.owner_id IS 'Менеджер заявки';

COMMENT ON COLUMN service_request.assignee_id IS 'Назначенный технический специалист';

COMMENT ON COLUMN service_request.details IS 'Потребность, условия и подписанное основание изменения';

COMMENT ON COLUMN service_request.requested_at IS 'Момент регистрации';

COMMENT ON COLUMN service_request.target_at IS 'Плановый срок исполнения';

COMMENT ON COLUMN service_request.closed_at IS 'Момент терминального состояния';

COMMENT ON COLUMN service_request.external_ref IS 'Идентификатор внешней операции';

CREATE TABLE renewal (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contract(id) ON DELETE RESTRICT,
    previous_end DATE NOT NULL,
    new_end DATE,
    decision VARCHAR(16) NOT NULL DEFAULT 'PENDING' CHECK (decision IN ('PENDING','ACCEPTED','DECLINED')),
    decided_at TIMESTAMPTZ,
    document_ref VARCHAR(500),
    owner_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (contract_id,previous_end),
    CHECK (decision <> 'ACCEPTED' OR (new_end IS NOT NULL AND new_end > previous_end AND document_ref IS NOT NULL)),
    CHECK ((decision <> 'PENDING') = (decided_at IS NOT NULL))
);

COMMENT ON TABLE renewal IS 'Решение о продлении';

COMMENT ON COLUMN renewal.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN renewal.contract_id IS 'Договор';

COMMENT ON COLUMN renewal.previous_end IS 'Прежний конец действия, основа выборки показателя';

COMMENT ON COLUMN renewal.new_end IS 'Предлагаемый новый конец';

COMMENT ON COLUMN renewal.decision IS 'Решение клиента по подписанному основанию';

COMMENT ON COLUMN renewal.decided_at IS 'Момент принятия решения';

COMMENT ON COLUMN renewal.document_ref IS 'Основание принятого продления';

COMMENT ON COLUMN renewal.owner_id IS 'Ответственный менеджер';

COMMENT ON COLUMN renewal.created_at IS 'Момент создания';

CREATE TABLE integration_job (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id BIGINT NOT NULL REFERENCES service_request(id) ON DELETE RESTRICT,
    idempotency_key UUID NOT NULL UNIQUE,
    operation_code VARCHAR(16) NOT NULL CHECK (operation_code IN ('CONNECT','CHANGE')),
    status_code VARCHAR(16) NOT NULL DEFAULT 'PENDING' CHECK (status_code IN ('PENDING','PROCESSING','RETRY','DONE','ERROR')),
    attempts SMALLINT NOT NULL DEFAULT 0 CHECK (attempts BETWEEN 0 AND 5),
    next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_error VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (request_id,operation_code)
);

COMMENT ON TABLE integration_job IS 'Устойчивая очередь обмена';

COMMENT ON COLUMN integration_job.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN integration_job.request_id IS 'Исходная заявка';

COMMENT ON COLUMN integration_job.idempotency_key IS 'Генерируется приложением один раз на операцию';

COMMENT ON COLUMN integration_job.operation_code IS 'Смысл внешней операции';

COMMENT ON COLUMN integration_job.status_code IS 'Состояние доставки';

COMMENT ON COLUMN integration_job.attempts IS 'Число выполненных попыток';

COMMENT ON COLUMN integration_job.next_attempt_at IS 'Ближайшая разрешённая попытка';

COMMENT ON COLUMN integration_job.last_error IS 'Санитизированное описание ошибки';

COMMENT ON COLUMN integration_job.created_at IS 'Момент создания';

CREATE TABLE notification_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_id BIGINT NOT NULL REFERENCES contract(id) ON DELETE RESTRICT,
    recipient_id BIGINT NOT NULL REFERENCES employee(id) ON DELETE RESTRICT,
    due_on DATE NOT NULL,
    event_key VARCHAR(40) NOT NULL DEFAULT 'RENEWAL_30_DAYS',
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (contract_id,recipient_id,due_on,event_key)
);

COMMENT ON TABLE notification_log IS 'Журнал напоминаний';

COMMENT ON COLUMN notification_log.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN notification_log.contract_id IS 'Договор';

COMMENT ON COLUMN notification_log.recipient_id IS 'Получатель';

COMMENT ON COLUMN notification_log.due_on IS 'Срок договора, к которому относится напоминание';

COMMENT ON COLUMN notification_log.event_key IS 'Тип уведомления';

COMMENT ON COLUMN notification_log.sent_at IS 'Момент подтверждения почтовым шлюзом';

COMMENT ON COLUMN notification_log.created_at IS 'Момент создания';

CREATE TABLE audit_event (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_id BIGINT REFERENCES employee(id) ON DELETE RESTRICT,
    entity_type VARCHAR(40) NOT NULL,
    entity_id BIGINT,
    action VARCHAR(50) NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details JSONB NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE audit_event IS 'Журнал аудита';

COMMENT ON COLUMN audit_event.id IS 'Первичный внутренний ключ';

COMMENT ON COLUMN audit_event.actor_id IS 'Автор, NULL для фонового процесса';

COMMENT ON COLUMN audit_event.entity_type IS 'Тип бизнес-объекта';

COMMENT ON COLUMN audit_event.entity_id IS 'Ключ объекта; полиморфная ссылка без FK';

COMMENT ON COLUMN audit_event.action IS 'Действие и результат';

COMMENT ON COLUMN audit_event.occurred_at IS 'Время события';

COMMENT ON COLUMN audit_event.details IS 'Технические сведения без токенов и лишних персональных данных';

INSERT INTO role(code,name) VALUES ('MANAGER','Менеджер корпоративных продаж'),('HEAD','Руководитель'),('TECH','Технический специалист'),('ADMIN','Администратор');

INSERT INTO deal_status(code,name) VALUES ('NEW','Новое обращение'),('QUALIFIED','Квалифицировано'),('PROPOSAL','Предложение'),('CONTRACT','Договор подписан'),('WON','Успешно подключено'),('LOST','Проиграно');

INSERT INTO request_type(code,name) VALUES ('CONNECT','Подключение'),('CHANGE','Изменение услуг');

INSERT INTO request_status(code,name) VALUES ('NEW','Новая'),('READY','Готова к отправке'),('SENT','Отправлена, исход уточняется'),('IN_PROGRESS','Принята в работу'),('DONE','Выполнена'),('FAILED','Отказ'),('CANCELLED','Отменена до отправки');


-- Атомарная выдача человекочитаемых кодов. Это служебная таблица реализации,
-- а не новая предметная сущность логической модели.
CREATE TABLE code_counter (
    prefix VARCHAR(2) NOT NULL CHECK (prefix IN ('CL','DL','OF','CT','RQ')),
    year_number INTEGER NOT NULL CHECK (year_number BETWEEN 2000 AND 9999),
    last_value INTEGER NOT NULL CHECK (last_value BETWEEN 1 AND 999999),
    PRIMARY KEY(prefix, year_number)
);
CREATE FUNCTION next_business_code(p_prefix VARCHAR(2), p_year INTEGER)
RETURNS VARCHAR(14) LANGUAGE plpgsql AS $$
DECLARE n INTEGER;
BEGIN
    INSERT INTO code_counter(prefix,year_number,last_value) VALUES(p_prefix,p_year,1)
    ON CONFLICT(prefix,year_number) DO UPDATE
      SET last_value = code_counter.last_value+1
    RETURNING last_value INTO n;
    RETURN p_prefix||'-'||p_year::TEXT||'-'||lpad(n::TEXT,6,'0');
END $$;

CREATE INDEX ix_client_manager ON client(manager_id);
CREATE INDEX ix_contact_client ON contact(client_id);
CREATE INDEX ix_deal_client ON deal(client_id);
CREATE INDEX ix_deal_closed ON deal(closed_at) WHERE closed_at IS NOT NULL;
CREATE INDEX ix_deal_owner_stage ON deal(owner_id,status_code);
CREATE INDEX ix_contract_end ON contract(ends_on) WHERE status_code='ACTIVE';
CREATE INDEX ix_offer_line_offer ON offer_line(offer_id);
CREATE INDEX ix_service_contract ON contract_service(contract_id,product_id,valid_from);
CREATE INDEX ix_request_assigned ON service_request(assignee_id,status_code,target_at);
CREATE INDEX ix_request_contract ON service_request(contract_id);
CREATE INDEX ix_request_closed ON service_request(closed_at) WHERE type_code='CONNECT';
CREATE INDEX ix_job_pending ON integration_job(next_attempt_at)
  WHERE status_code IN ('PENDING','RETRY');
CREATE INDEX ix_audit_object ON audit_event(entity_type,entity_id,occurred_at);

-- Триггер согласования проверяет автора, роль и подразделение, блокирует версию.
CREATE FUNCTION validate_approval() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE o offer; author_department BIGINT; reviewer employee;
BEGIN
    SELECT * INTO o FROM offer WHERE id=NEW.offer_id FOR UPDATE;
    IF o.id IS NULL OR o.status_code <> 'SUBMITTED' THEN
      RAISE EXCEPTION 'Only submitted offers may be approved';
    END IF;
    SELECT department_id INTO author_department FROM employee WHERE id=o.created_by;
    SELECT * INTO reviewer FROM employee WHERE id=NEW.approver_id;
    IF reviewer.id=o.created_by OR reviewer.role_code<>'HEAD' OR NOT reviewer.is_active
       OR reviewer.department_id<>author_department THEN
      RAISE EXCEPTION 'Reviewer is not permitted';
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER tr_validate_approval BEFORE INSERT ON approval
FOR EACH ROW EXECUTE FUNCTION validate_approval();
CREATE FUNCTION apply_approval() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    UPDATE offer SET status_code=NEW.decision WHERE id=NEW.offer_id;
    RETURN NEW;
END $$;
CREATE TRIGGER tr_apply_approval AFTER INSERT ON approval
FOR EACH ROW EXECUTE FUNCTION apply_approval();

CREATE FUNCTION protect_offer_line() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE offer_status VARCHAR(16); oid BIGINT;
BEGIN
    IF TG_OP='DELETE' THEN oid=OLD.offer_id; ELSE oid=NEW.offer_id; END IF;
    IF TG_OP='UPDATE' AND NEW.offer_id<>OLD.offer_id THEN
      RAISE EXCEPTION 'Moving offer lines is prohibited';
    END IF;
    SELECT status_code INTO offer_status FROM offer WHERE id=oid FOR UPDATE;
    IF offer_status<>'DRAFT' THEN RAISE EXCEPTION 'Submitted offer is immutable'; END IF;
    IF TG_OP='DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END $$;
CREATE TRIGGER tr_offer_line_immutable BEFORE INSERT OR UPDATE OR DELETE ON offer_line
FOR EACH ROW EXECUTE FUNCTION protect_offer_line();

CREATE FUNCTION validate_contract() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE s VARCHAR(16);
BEGIN
    SELECT status_code INTO s FROM offer WHERE id=NEW.offer_id FOR UPDATE;
    IF s<>'APPROVED' THEN RAISE EXCEPTION 'Approved offer required'; END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER tr_contract_offer BEFORE INSERT OR UPDATE OF offer_id ON contract
FOR EACH ROW EXECUTE FUNCTION validate_contract();

CREATE FUNCTION reject_audit_mutation() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'Audit and approval history is append-only'; END $$;
CREATE TRIGGER tr_audit_append_only BEFORE UPDATE OR DELETE ON audit_event
FOR EACH ROW EXECUTE FUNCTION reject_audit_mutation();
CREATE TRIGGER tr_approval_append_only BEFORE UPDATE OR DELETE ON approval
FOR EACH ROW EXECUTE FUNCTION reject_audit_mutation();

-- Применение продления производится в одной транзакции под блокировкой договора.
CREATE FUNCTION apply_renewal() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE current_end DATE;
BEGIN
    IF TG_OP='UPDATE' AND OLD.decision<>'PENDING' THEN
      RAISE EXCEPTION 'Final renewal decision is immutable';
    END IF;
    IF NEW.decision='ACCEPTED' THEN
      SELECT ends_on INTO current_end FROM contract WHERE id=NEW.contract_id FOR UPDATE;
      IF current_end<>NEW.previous_end THEN RAISE EXCEPTION 'Stale renewal baseline'; END IF;
      UPDATE contract SET ends_on=NEW.new_end,status_code='ACTIVE' WHERE id=NEW.contract_id;
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER tr_apply_renewal BEFORE INSERT OR UPDATE ON renewal
FOR EACH ROW EXECUTE FUNCTION apply_renewal();


COMMIT;