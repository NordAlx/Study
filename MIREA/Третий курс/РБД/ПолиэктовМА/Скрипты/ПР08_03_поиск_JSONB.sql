-- Q01. -> извлекает JSON-объект, ->> — его текстовое поле; затем приводим к numeric.
SELECT id_event,event_date,payload FROM rbd.event_log
WHERE event_type='rental_completed' AND (payload->'rental'->>'amount')::numeric>800
ORDER BY id_event LIMIT 100;
-- Q02. Вхождение точного фрагмента JSON, числовое значение 5.
SELECT id_event,event_date,payload FROM rbd.event_log
WHERE payload @> '{"rental":{"duration_hours":5}}'::jsonb
ORDER BY id_event LIMIT 100;
-- Q03. Сумма стоимости и средняя продолжительность завершенных сеансов.
SELECT sum((payload->'rental'->>'amount')::numeric) AS total_amount,
avg((payload->'rental'->>'duration_hours')::numeric) AS average_hours
FROM rbd.event_log WHERE event_type='rental_completed';
