-- PostgreSQL 18. Учебная схема, не действующая БД компании.
-- Запускать в отдельной пустой БД от владельца с правом CREATE ROLE.
BEGIN;
CREATE SCHEMA crm;

CREATE TABLE crm.app_user (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  login varchar(80) NOT NULL UNIQUE,
  full_name varchar(160) NOT NULL,
  active boolean NOT NULL DEFAULT true
);

CREATE TABLE crm.app_role (
  code varchar(30) NOT NULL PRIMARY KEY,
  name varchar(80) NOT NULL UNIQUE
);

CREATE TABLE crm.user_role (
  user_id uuid NOT NULL REFERENCES crm.app_user(id) ON DELETE RESTRICT,
  role_code varchar(30) NOT NULL REFERENCES crm.app_role(code) ON DELETE RESTRICT,
  PRIMARY KEY (user_id, role_code)
);

CREATE TABLE crm.client (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  inn varchar(10) NOT NULL UNIQUE CHECK (inn ~ '^[0-9]{10}$'),
  name varchar(200) NOT NULL,
  active boolean NOT NULL DEFAULT true
);

CREATE TABLE crm.contact (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid NOT NULL REFERENCES crm.client(id) ON DELETE RESTRICT,
  full_name varchar(160) NOT NULL,
  email varchar(160),
  phone varchar(30),
  CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

CREATE TABLE crm.deal (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid NOT NULL REFERENCES crm.client(id) ON DELETE RESTRICT,
  owner_id uuid NOT NULL REFERENCES crm.app_user(id) ON DELETE RESTRICT,
  title varchar(200) NOT NULL,
  stage varchar(20) NOT NULL CHECK (stage IN ('new','qualification','proposal','contract','won','lost')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  next_action_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0)
);

CREATE TABLE crm.product (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  code varchar(30) NOT NULL UNIQUE,
  name varchar(160) NOT NULL,
  active boolean NOT NULL DEFAULT true
);

CREATE TABLE crm.offer (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id uuid NOT NULL REFERENCES crm.deal(id) ON DELETE RESTRICT,
  author_id uuid NOT NULL REFERENCES crm.app_user(id) ON DELETE RESTRICT,
  version_no integer NOT NULL CHECK (version_no > 0),
  status varchar(20) NOT NULL CHECK (status IN ('draft','review','approved','rejected')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (deal_id, version_no)
);

CREATE TABLE crm.offer_line (
  offer_id uuid NOT NULL REFERENCES crm.offer(id) ON DELETE RESTRICT,
  line_no smallint NOT NULL CHECK (line_no > 0),
  product_id uuid NOT NULL REFERENCES crm.product(id) ON DELETE RESTRICT,
  quantity numeric(12,3) NOT NULL CHECK (quantity > 0),
  unit_price numeric(14,2) NOT NULL CHECK (unit_price >= 0),
  discount_pct numeric(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
  currency char(3) NOT NULL CHECK (currency IN ('RUB','USD','EUR')),
  billing_period varchar(12) NOT NULL CHECK (billing_period IN ('once','month')),
  PRIMARY KEY (offer_id, line_no)
);

CREATE TABLE crm.approval (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES crm.offer(id) ON DELETE RESTRICT,
  approver_id uuid NOT NULL REFERENCES crm.app_user(id) ON DELETE RESTRICT,
  decision varchar(12) NOT NULL CHECK (decision IN ('approved','rejected')),
  note text,
  decided_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (offer_id, approver_id)
);

CREATE TABLE crm.contract (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES crm.offer(id) ON DELETE RESTRICT,
  number varchar(60) NOT NULL UNIQUE,
  signed_at date,
  file_ref varchar(240),
  status varchar(12) NOT NULL CHECK (status IN ('draft','signed')),
  CHECK (status <> 'signed' OR (signed_at IS NOT NULL AND file_ref IS NOT NULL))
);

CREATE TABLE crm.service_order (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES crm.contract(id) ON DELETE RESTRICT,
  request_key uuid NOT NULL UNIQUE,
  external_ref varchar(80) UNIQUE,
  status varchar(16) NOT NULL CHECK (status IN ('created','sent','in_progress','completed','failed')),
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (updated_at >= created_at)
);

CREATE TABLE crm.status_event (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES crm.service_order(id) ON DELETE RESTRICT,
  external_event_id varchar(100) NOT NULL UNIQUE,
  status varchar(16) NOT NULL CHECK (status IN ('sent','in_progress','completed','failed')),
  received_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE crm.activity (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id uuid NOT NULL REFERENCES crm.deal(id) ON DELETE RESTRICT,
  author_id uuid NOT NULL REFERENCES crm.app_user(id) ON DELETE RESTRICT,
  channel varchar(12) NOT NULL CHECK (channel IN ('call','email','meeting')),
  result text NOT NULL,
  performed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  next_due_at timestamptz
);

CREATE TABLE crm.audit_event (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid NOT NULL REFERENCES crm.app_user(id) ON DELETE RESTRICT,
  object_type varchar(30) NOT NULL,
  object_id uuid NOT NULL,
  action varchar(40) NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  details jsonb NOT NULL DEFAULT '{}'::jsonb
);

ALTER TABLE crm.deal ADD CONSTRAINT ck_deal_title CHECK (length(btrim(title)) > 0);

CREATE INDEX ix_deal_owner_stage ON crm.deal(owner_id, stage);

CREATE INDEX ix_offer_deal ON crm.offer(deal_id);

CREATE INDEX ix_activity_deal_time ON crm.activity(deal_id, performed_at DESC);

CREATE INDEX ix_order_contract ON crm.service_order(contract_id);

CREATE INDEX ix_contact_client ON crm.contact(client_id);

CREATE INDEX ix_line_product ON crm.offer_line(product_id);

CREATE VIEW crm.v_offer_amount AS SELECT offer_id, currency, billing_period, round(sum(quantity * unit_price * (1 - discount_pct/100)),2) AS amount FROM crm.offer_line GROUP BY offer_id,currency,billing_period;

CREATE FUNCTION crm.check_approval() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.approver_id = (SELECT author_id FROM crm.offer WHERE id=NEW.offer_id) THEN
    RAISE EXCEPTION 'Автор не может согласовать собственное КП' USING ERRCODE='23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM crm.user_role WHERE user_id=NEW.approver_id AND role_code='approver') THEN
    RAISE EXCEPTION 'Пользователю не назначена роль согласующего' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_approval BEFORE INSERT OR UPDATE ON crm.approval FOR EACH ROW EXECUTE FUNCTION crm.check_approval();

CREATE FUNCTION crm.check_contract() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM crm.offer WHERE id=NEW.offer_id AND status='approved')
     OR NOT EXISTS (SELECT 1 FROM crm.approval WHERE offer_id=NEW.offer_id AND decision='approved')
     OR EXISTS (SELECT 1 FROM crm.approval WHERE offer_id=NEW.offer_id AND decision='rejected') THEN
    RAISE EXCEPTION 'Договор требует согласованного КП без отказов' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_contract BEFORE INSERT OR UPDATE ON crm.contract FOR EACH ROW EXECUTE FUNCTION crm.check_contract();

CREATE FUNCTION crm.check_order() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM crm.contract WHERE id=NEW.contract_id AND status='signed') THEN
    RAISE EXCEPTION 'Заказ требует подписанного договора' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_order BEFORE INSERT OR UPDATE ON crm.service_order FOR EACH ROW EXECUTE FUNCTION crm.check_order();

COMMIT;