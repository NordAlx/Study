-- Демонстрация выполняется в транзакции и затем откатывается.
BEGIN;
-- Q01. Массовое добавление ключа только событиям завершения сеанса.
UPDATE rbd.event_log SET payload=payload||'{"currency":"RUB"}'::jsonb
WHERE event_type='rental_completed';
-- Q02. Проверка: количество строк с ключом равно количеству завершений.
SELECT count(*) FILTER(WHERE event_type='rental_completed') AS rentals,
count(*) FILTER(WHERE payload ? 'currency') AS with_currency FROM rbd.event_log;
-- Q03. Значение в одной выбранной записи до изменения.
SELECT * FROM rbd.event_log WHERE (event_date,id_event)=
(SELECT event_date,id_event FROM rbd.event_log WHERE event_type='rental_completed' ORDER BY id_event LIMIT 1);
-- Q04. Изменение вложенного поля ровно у этой записи.
UPDATE rbd.event_log SET payload=jsonb_set(payload,'{rental,duration_hours}','6'::jsonb,false)
WHERE (event_date,id_event)=
(SELECT event_date,id_event FROM rbd.event_log WHERE event_type='rental_completed' ORDER BY id_event LIMIT 1)
RETURNING id_event,event_date,payload;
ROLLBACK;
