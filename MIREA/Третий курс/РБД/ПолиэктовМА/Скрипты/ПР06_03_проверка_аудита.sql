-- Успех: увеличить оплату связанного сеанса и увидеть запись аудита.
BEGIN;
UPDATE public.payment SET amount=amount+10
WHERE id_payment=(SELECT id_payment FROM public.rental_session WHERE id_rental_session=1)
RETURNING *;
SELECT * FROM rbd.payment_audit ORDER BY id_audit;
ROLLBACK;
-- Ошибка триггера: сумма 0 не покрывает завершенный сеанс с положительной стоимостью.
BEGIN;
UPDATE public.payment SET amount=0
WHERE id_payment=(SELECT id_payment FROM public.rental_session WHERE id_rental_session=1);
ROLLBACK;
SELECT * FROM rbd.payment_audit ORDER BY id_audit;
