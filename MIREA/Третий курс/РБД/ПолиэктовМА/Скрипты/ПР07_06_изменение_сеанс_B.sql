-- Отдельное подключение B. PID должен отличаться от PID подключения A.
SELECT pg_backend_pid();
-- Выполнить после первого SELECT в подключении A.
BEGIN;
UPDATE public.loyalty_card SET points=points+100 WHERE id_loyalty_card=1 RETURNING points;
COMMIT;
-- Теперь вернуться в A и выполнить второй SELECT.
