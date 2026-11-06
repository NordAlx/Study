-- Успех: неподтвержденный платеж без связей можно удалить.
BEGIN;
INSERT INTO public.payment(id_payment,id_payment_method,amount,status)
SELECT -6001,min(id_payment_method),100,'Ожидает оплаты' FROM public.payment_method;
DELETE FROM public.payment WHERE id_payment=-6001 RETURNING *;
ROLLBACK;
-- Ошибка триггера: успешно проведенный платеж без связей удалять нельзя.
BEGIN;
INSERT INTO public.payment(id_payment,id_payment_method,amount,status)
SELECT -6002,min(id_payment_method),100,'Оплата произведена' FROM public.payment_method;
DELETE FROM public.payment WHERE id_payment=-6002;
ROLLBACK;
