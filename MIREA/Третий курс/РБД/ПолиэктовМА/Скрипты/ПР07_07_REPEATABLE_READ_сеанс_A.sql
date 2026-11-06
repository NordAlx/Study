-- Подключение A; предыдущая транзакция должна быть завершена.
-- Шаг A1.
SELECT pg_backend_pid();
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- Шаг A2: после первого SELECT выполнить скрипт сеанса B и его COMMIT.
SELECT points FROM public.loyalty_card WHERE id_loyalty_card=1;
-- Шаг A3: внутри этой транзакции виден прежний снимок.
SELECT points FROM public.loyalty_card WHERE id_loyalty_card=1;
COMMIT;
-- После завершения транзакции становится видно новое значение.
SELECT points FROM public.loyalty_card WHERE id_loyalty_card=1;
