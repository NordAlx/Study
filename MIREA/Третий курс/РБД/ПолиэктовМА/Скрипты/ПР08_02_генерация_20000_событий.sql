-- Задание 3. Генерация именно на PL/pgSQL, по одному событию в итерации.
BEGIN;
DO $block$
DECLARE i integer; day date; event_name text; event_payload jsonb;
BEGIN
    IF EXISTS(SELECT 1 FROM rbd.event_log) THEN
        RAISE EXCEPTION 'event_log уже заполнена: повторная генерация отменена';
    END IF;
    FOR i IN 1..20000 LOOP
        day:=DATE '2024-07-01'+((i-1)%730);
        IF i%2=0 THEN
            event_name:='rental_completed';
            event_payload:=jsonb_build_object('rental',jsonb_build_object(
                'amount',100+(i*13)%1400,'duration_hours',1+i%6),
                'client_number',1+i%5,'gaming_spot_number',1+i%20);
        ELSE
            event_name:='user_login';
            event_payload:=jsonb_build_object('login','client_'||(1+i%5),
                'success',i%7<>0,'device','club_pc_'||(1+i%20));
        END IF;
        INSERT INTO rbd.event_log(event_date,event_type,payload) VALUES(day,event_name,event_payload);
    END LOOP;
END;
$block$;
COMMIT;
-- Q01. Всего должно быть ровно 20 000 событий.
SELECT count(*) AS total_events FROM rbd.event_log;
-- Q02. Физическое распределение по секциям; все три должны содержать строки.
SELECT tableoid::regclass AS physical_partition,count(*) AS events,min(event_date),max(event_date)
FROM rbd.event_log GROUP BY tableoid ORDER BY tableoid::regclass::text;
-- Q03. Два типа событий имеют разные структуры JSON.
SELECT * FROM rbd.event_log WHERE event_type='rental_completed' ORDER BY id_event LIMIT 5;
SELECT * FROM rbd.event_log WHERE event_type='user_login' ORDER BY id_event LIMIT 5;
