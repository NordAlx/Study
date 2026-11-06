-- Меняет таблицу public.payment: выполнить самостоятельно на учебной копии базы.
-- Маркер не позволяет этому скрипту повторно добавить те же 20 000 строк.
CREATE SCHEMA IF NOT EXISTS rbd;
CREATE TABLE IF NOT EXISTS rbd.generation_runs(
    run_name text PRIMARY KEY,created_at timestamptz NOT NULL DEFAULT current_timestamp,
    inserted_rows integer NOT NULL
);
BEGIN;
DO $block$
DECLARE methods integer[]; i integer;
BEGIN
    IF EXISTS(SELECT 1 FROM rbd.generation_runs WHERE run_name='practice7_payments') THEN
        RAISE NOTICE 'Генерация практики 7 уже выполнена; новые строки не добавлены';
        RETURN;
    END IF;
    SELECT array_agg(id_payment_method ORDER BY id_payment_method) INTO methods FROM public.payment_method;
    IF methods IS NULL THEN RAISE EXCEPTION 'Сначала заполните payment_method'; END IF;
    FOR i IN 1..20000 LOOP
        INSERT INTO public.payment(id_payment_method,amount,status,id_discount)
        VALUES(methods[1+(i-1)%array_length(methods,1)],100+(i*37)%5000,
            CASE WHEN i%100=0 THEN 'Оплата произведена'
                 WHEN i%20=0 THEN 'Ошибка оплаты' ELSE 'Ожидает оплаты' END,NULL);
    END LOOP;
    INSERT INTO rbd.generation_runs(run_name,inserted_rows) VALUES('practice7_payments',20000);
END;
$block$;
COMMIT;
ANALYZE public.payment;
SELECT count(*) AS all_payments FROM public.payment;
SELECT * FROM rbd.generation_runs WHERE run_name='practice7_payments';
