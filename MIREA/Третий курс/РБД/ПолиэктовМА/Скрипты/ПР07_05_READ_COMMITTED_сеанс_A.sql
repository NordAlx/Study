-- Отдельное подключение A. Не запускать файл целиком.
-- Шаг A1: проверить PID и начать транзакцию.
SELECT pg_backend_pid();
BEGIN ISOLATION LEVEL READ COMMITTED;
-- Шаг A2: запомнить первый результат, затем выполнить шаг B в другом подключении.
SELECT points FROM public.loyalty_card WHERE id_loyalty_card=1;
-- Шаг A3: выполнить только ПОСЛЕ COMMIT подключения B.
SELECT points FROM public.loyalty_card WHERE id_loyalty_card=1;
COMMIT;
