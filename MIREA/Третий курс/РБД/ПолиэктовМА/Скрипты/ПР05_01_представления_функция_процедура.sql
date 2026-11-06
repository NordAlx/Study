CREATE SCHEMA IF NOT EXISTS rbd;
-- Задание 1. Простое автоматически модифицируемое представление.
CREATE OR REPLACE VIEW rbd.v_paid_payments AS
SELECT id_payment,id_payment_method,amount,status,id_discount
FROM public.payment WHERE status='Оплата произведена' WITH LOCAL CHECK OPTION;
-- Задание 3. Агрегатное представление по сотрудникам, автоматически немодифицируемое.
CREATE OR REPLACE VIEW rbd.v_employee_revenue AS
SELECT e.id_employee,e.name,count(rs.id_rental_session) AS sessions,
COALESCE(sum(rs.session_cost),0)::numeric AS total_cost,avg(rs.session_cost)::numeric AS average_cost
FROM public.employee e LEFT JOIN public.rental_session rs USING(id_employee)
GROUP BY e.id_employee,e.name;
-- Задание 5. Материализованные расходы клиентов.
CREATE MATERIALIZED VIEW rbd.mv_client_spending AS
SELECT c.id_client,c.name,COALESCE(sum(rs.session_cost),0)::numeric AS total_cost
FROM public.client c LEFT JOIN public.rental_session rs USING(id_client)
GROUP BY c.id_client,c.name;
-- Задание 6. Скалярная функция: сумма оплат завершенных сеансов сотрудника.
CREATE OR REPLACE FUNCTION rbd.employee_revenue(p_employee integer)
RETURNS numeric LANGUAGE sql STABLE AS $fn$
SELECT COALESCE(sum(p.amount),0)::numeric
FROM public.rental_session rs JOIN public.payment p USING(id_payment)
WHERE rs.id_employee=p_employee AND rs.status IN('Завершён','Завершен')
AND p.status='Оплата произведена';
$fn$;
-- Задание 7. Связанная таблица списания бонусов.
CREATE TABLE rbd.bonus_redemption(
    id_redemption bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_loyalty_card integer NOT NULL REFERENCES public.loyalty_card(id_loyalty_card),
    spent_points integer NOT NULL CHECK(spent_points>0),
    redemption_date timestamptz NOT NULL DEFAULT current_timestamp
);
-- Блокировка FOR UPDATE не позволяет двум операциям одновременно потратить одни баллы.
-- OUT возвращает понятный статус; неудачный вызов не меняет строки.
CREATE OR REPLACE PROCEDURE rbd.spend_bonus(
    IN p_card integer, IN p_points integer, OUT result text)
LANGUAGE plpgsql AS $proc$
DECLARE current_points integer;
BEGIN
    IF p_points IS NULL OR p_points<=0 THEN
        result:='ОШИБКА: число баллов должно быть положительным';
        RAISE NOTICE '%',result; RETURN;
    END IF;
    SELECT points INTO current_points FROM public.loyalty_card
    WHERE id_loyalty_card=p_card FOR UPDATE;
    IF NOT FOUND THEN
        result:='ОШИБКА: карта не найдена'; RAISE NOTICE '%',result; RETURN;
    END IF;
    IF current_points<p_points THEN
        result:='ОШИБКА: недостаточно бонусных баллов'; RAISE NOTICE '%',result; RETURN;
    END IF;
    UPDATE public.loyalty_card SET points=points-p_points WHERE id_loyalty_card=p_card;
    INSERT INTO rbd.bonus_redemption(id_loyalty_card,spent_points) VALUES(p_card,p_points);
    result:='УСПЕХ: списано '||p_points||' баллов';
END;
$proc$;
