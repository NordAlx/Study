-- Q01. Явный курсор: построчный вывод бонусных карт в журнал сообщений.
DO $block$
DECLARE card_cursor CURSOR FOR
    SELECT lc.id_loyalty_card,c.name,lc.points FROM public.loyalty_card lc
    JOIN public.client c USING(id_client) ORDER BY lc.id_loyalty_card;
    row_data record;
BEGIN
    OPEN card_cursor;
    LOOP
        FETCH card_cursor INTO row_data;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Карта %, клиент %, баллы %',row_data.id_loyalty_card,row_data.name,row_data.points;
    END LOOP;
    CLOSE card_cursor;
END;
$block$;
-- Q02. Неявный курсор FOR ... IN: результат возвращается как таблица.
CREATE OR REPLACE FUNCTION rbd.employee_activity()
RETURNS TABLE(employee_id integer,employee_name text,session_count bigint)
LANGUAGE plpgsql AS $fn$
DECLARE row_data record;
BEGIN
    FOR row_data IN
        SELECT e.id_employee,e.name,count(rs.id_rental_session) AS sessions
        FROM public.employee e LEFT JOIN public.rental_session rs USING(id_employee)
        GROUP BY e.id_employee,e.name ORDER BY e.id_employee
    LOOP
        employee_id:=row_data.id_employee;
        employee_name:=row_data.name;
        session_count:=row_data.sessions;
        RETURN NEXT;
    END LOOP;
END;
$fn$;
SELECT * FROM rbd.employee_activity();
