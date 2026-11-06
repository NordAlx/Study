-- ВАЖНО: выполнять по операторам Ctrl+Enter, включая ROLLBACK после ожидаемой ошибки.
-- Успешная операция: завершение при достаточной оплате.
BEGIN;
UPDATE public.rental_session rs SET status='Завершён',session_cost=p.amount
FROM public.payment p WHERE rs.id_rental_session=1 AND p.id_payment=rs.id_payment
AND p.status='Оплата произведена' RETURNING rs.*;
ROLLBACK;
-- Неудачная операция: стоимость выше связанной оплаты. Ожидается ошибка триггера.
BEGIN;
UPDATE public.rental_session rs SET status='Завершён',session_cost=p.amount+1
FROM public.payment p WHERE rs.id_rental_session=1 AND p.id_payment=rs.id_payment;
ROLLBACK;
SELECT * FROM public.rental_session WHERE id_rental_session=1;
