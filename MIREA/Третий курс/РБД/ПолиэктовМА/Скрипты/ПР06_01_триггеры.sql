CREATE SCHEMA IF NOT EXISTS rbd;
CREATE TABLE rbd.payment_audit(
    id_audit bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_payment integer NOT NULL,
    old_amount numeric(10,2),new_amount numeric(10,2),
    old_status text,new_status text,
    changed_at timestamptz NOT NULL DEFAULT current_timestamp,
    changed_by text NOT NULL DEFAULT current_user
);
-- Правило 1. Завершить сеанс можно только при достаточной успешной оплате.
-- BEFORE INSERT/UPDATE: межтабличная проверка, невыполнимая обычным CHECK.
CREATE OR REPLACE FUNCTION rbd.check_session_payment() RETURNS trigger
LANGUAGE plpgsql AS $fn$
DECLARE payment_status text; payment_amount numeric;
BEGIN
    IF NEW.status IN('Завершён','Завершен') THEN
        SELECT status,amount INTO payment_status,payment_amount
        FROM public.payment WHERE id_payment=NEW.id_payment FOR UPDATE;
        IF NOT FOUND OR payment_status<>'Оплата произведена' OR payment_amount<NEW.session_cost THEN
            RAISE EXCEPTION 'Нельзя завершить сеанс: оплата не выполнена или ее сумма недостаточна';
        END IF;
    END IF;
    RETURN NEW;
END;
$fn$;
CREATE TRIGGER trg_session_payment BEFORE INSERT OR UPDATE ON public.rental_session
FOR EACH ROW EXECUTE FUNCTION rbd.check_session_payment();
-- Правило 2. Изменения суммы и статуса оплаты фиксируются в аудите.
-- AFTER UPDATE также не допускает отмены оплаты уже завершенного сеанса.
CREATE OR REPLACE FUNCTION rbd.audit_payment_update() RETURNS trigger
LANGUAGE plpgsql AS $fn$
BEGIN
    IF EXISTS(SELECT 1 FROM public.rental_session rs
        WHERE rs.id_payment=NEW.id_payment AND rs.status IN('Завершён','Завершен')
        AND (NEW.status<>'Оплата произведена' OR NEW.amount<rs.session_cost)) THEN
        RAISE EXCEPTION 'Изменение оплаты нарушает условия завершенного сеанса';
    END IF;
    IF ROW(OLD.amount,OLD.status) IS DISTINCT FROM ROW(NEW.amount,NEW.status) THEN
        INSERT INTO rbd.payment_audit(id_payment,old_amount,new_amount,old_status,new_status)
        VALUES(NEW.id_payment,OLD.amount,NEW.amount,OLD.status,NEW.status);
    END IF;
    RETURN NEW;
END;
$fn$;
CREATE TRIGGER trg_payment_audit AFTER UPDATE OF amount,status ON public.payment
FOR EACH ROW EXECUTE FUNCTION rbd.audit_payment_update();
-- Правило 3. Успешные платежи сохраняются даже при отсутствии связанных сеансов.
-- BEFORE DELETE: запрет удаления финансового факта, не сводящийся к внешнему ключу.
CREATE OR REPLACE FUNCTION rbd.protect_paid_payment() RETURNS trigger
LANGUAGE plpgsql AS $fn$
BEGIN
    IF OLD.status='Оплата произведена' THEN
        RAISE EXCEPTION 'Удаление успешно проведенной оплаты запрещено';
    END IF;
    RETURN OLD;
END;
$fn$;
CREATE TRIGGER trg_protect_paid_payment BEFORE DELETE ON public.payment
FOR EACH ROW EXECUTE FUNCTION rbd.protect_paid_payment();
