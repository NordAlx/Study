-- Выполнять по операторам. Успешная вставка откатывается.
BEGIN;
INSERT INTO public.tarif(id_tarif,name,price) VALUES(-1001,'Учебный положительный тариф',100);
SELECT * FROM public.tarif WHERE id_tarif=-1001;
ROLLBACK;
-- Ожидаемая ошибка CHECK (price>=0). Выполнить отдельно.
BEGIN;
INSERT INTO public.tarif(id_tarif,name,price) VALUES(-1002,'Учебный отрицательный тариф',-100);
-- После ошибки обязательно выполнить эту команду отдельно.
ROLLBACK;
