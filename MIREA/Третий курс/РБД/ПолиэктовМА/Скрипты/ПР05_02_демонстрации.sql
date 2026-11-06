-- Выполнять блоками. Все учебные изменения ниже откатываются.
-- Q01. Проверка модифицируемого представления.
SELECT * FROM rbd.v_paid_payments ORDER BY id_payment;
-- Q02. INSERT и DELETE через представление. Отрицательный ID — только учебный маркер.
BEGIN;
INSERT INTO rbd.v_paid_payments(id_payment,id_payment_method,amount,status)
SELECT -5001,min(id_payment_method),500,'Оплата произведена' FROM public.payment_method
RETURNING *;
SELECT * FROM public.payment WHERE id_payment=-5001;
DELETE FROM rbd.v_paid_payments WHERE id_payment=-5001 RETURNING *;
SELECT * FROM public.payment WHERE id_payment=-5001;
ROLLBACK;
-- Q03. Сводка по сотрудникам.
SELECT * FROM rbd.v_employee_revenue ORDER BY id_employee;
-- Q04. Фильтрация аналитического представления.
SELECT * FROM rbd.v_employee_revenue WHERE average_cost>700 ORDER BY average_cost DESC;
-- Q05. Снимок материализованного представления до изменения.
SELECT * FROM rbd.mv_client_spending ORDER BY id_client;
-- Q06. Изменение источника, старый снимок, REFRESH, новый снимок.
BEGIN;
UPDATE public.rental_session SET session_cost=GREATEST(session_cost-10,0)
WHERE id_rental_session=(SELECT min(id_rental_session) FROM public.rental_session);
SELECT c.id_client,sum(rs.session_cost) AS current_total
FROM public.client c JOIN public.rental_session rs USING(id_client)
GROUP BY c.id_client ORDER BY c.id_client;
SELECT * FROM rbd.mv_client_spending ORDER BY id_client;
REFRESH MATERIALIZED VIEW rbd.mv_client_spending;
SELECT * FROM rbd.mv_client_spending ORDER BY id_client;
ROLLBACK;
-- Q07. Вызов скалярной функции в SELECT.
SELECT id_employee,name,rbd.employee_revenue(id_employee) AS paid_revenue
FROM public.employee ORDER BY id_employee;
-- Q08. Успешный и неудачный вызовы процедуры: сначала проверьте карту 1.
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
BEGIN;
CALL rbd.spend_bonus(1,50,NULL);
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
SELECT * FROM rbd.bonus_redemption ORDER BY id_redemption;
CALL rbd.spend_bonus(1,2000000000,NULL);
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
SELECT * FROM rbd.bonus_redemption ORDER BY id_redemption;
ROLLBACK;
