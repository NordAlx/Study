-- Q01. Три первых ранга стоимости сеансов для каждого сотрудника.
WITH ranked AS(
SELECT id_employee,id_rental_session,session_cost,
RANK() OVER(PARTITION BY id_employee ORDER BY session_cost DESC) AS session_rank
FROM public.rental_session)
SELECT * FROM ranked WHERE session_rank<=3 ORDER BY id_employee,session_rank,id_rental_session;
-- При одинаковых суммах на границе в результат могут попасть несколько сеансов.
-- Q02. Сумма по месяцам и нарастающий итог по каждому тарифу.
WITH monthly AS(
SELECT rs.id_tarif,date_trunc('month',d.date)::date AS month,sum(rs.session_cost) AS total
FROM public.rental_session rs JOIN public.document d USING(id_document)
GROUP BY rs.id_tarif,date_trunc('month',d.date)::date)
SELECT id_tarif,month,total,SUM(total) OVER(PARTITION BY id_tarif ORDER BY month
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_total
FROM monthly ORDER BY id_tarif,month;
-- Q03. LAG: сравнение месяцев; календарь сохраняет отсутствующие месяцы.
WITH calendar AS(SELECT generate_series(DATE '2025-01-01',DATE '2025-12-01',INTERVAL '1 month')::date AS month),
monthly AS(SELECT date_trunc('month',d.date)::date AS month,sum(rs.session_cost) AS total
FROM public.rental_session rs JOIN public.document d USING(id_document)
WHERE d.date>=DATE '2025-01-01' AND d.date<DATE '2026-01-01' GROUP BY 1),
filled AS(SELECT c.month,coalesce(m.total,0) AS total FROM calendar c LEFT JOIN monthly m USING(month)),
compared AS(SELECT month,total,LAG(total) OVER(ORDER BY month) AS previous_total FROM filled)
SELECT month,total,previous_total,total-previous_total AS difference
FROM compared WHERE previous_total IS NOT NULL ORDER BY month;
-- Q04. Сводная таблица: стоимость сеансов по сотрудникам и кварталам 2025.
SELECT e.id_employee,e.name,
COALESCE(SUM(CASE WHEN EXTRACT(QUARTER FROM d.date)=1 THEN rs.session_cost ELSE 0 END),0) AS q1,
COALESCE(SUM(CASE WHEN EXTRACT(QUARTER FROM d.date)=2 THEN rs.session_cost ELSE 0 END),0) AS q2,
COALESCE(SUM(CASE WHEN EXTRACT(QUARTER FROM d.date)=3 THEN rs.session_cost ELSE 0 END),0) AS q3,
COALESCE(SUM(CASE WHEN EXTRACT(QUARTER FROM d.date)=4 THEN rs.session_cost ELSE 0 END),0) AS q4
FROM public.employee e LEFT JOIN public.rental_session rs USING(id_employee)
LEFT JOIN public.document d ON d.id_document=rs.id_document
AND d.date>=DATE '2025-01-01' AND d.date<DATE '2026-01-01'
GROUP BY e.id_employee,e.name ORDER BY e.id_employee;
-- Q05. Та же сводная таблица через crosstab(source_sql,category_sql).
-- Для всех сотрудников создаются четыре категории, включая нулевые суммы.
SELECT e.id_employee,e.name,ct.q1,ct.q2,ct.q3,ct.q4
FROM public.crosstab(
$src$
WITH totals AS(
SELECT rs.id_employee,EXTRACT(QUARTER FROM d.date)::integer AS quarter,sum(rs.session_cost)::numeric AS total
FROM public.rental_session rs JOIN public.document d USING(id_document)
WHERE d.date>=DATE '2025-01-01' AND d.date<DATE '2026-01-01' GROUP BY 1,2)
SELECT e.id_employee,q.quarter,COALESCE(t.total,0)::numeric
FROM public.employee e CROSS JOIN generate_series(1,4) AS q(quarter)
LEFT JOIN totals t ON t.id_employee=e.id_employee AND t.quarter=q.quarter
ORDER BY e.id_employee,q.quarter
$src$,
$cat$SELECT generate_series(1,4)$cat$
) AS ct(id_employee integer,q1 numeric,q2 numeric,q3 numeric,q4 numeric)
JOIN public.employee e USING(id_employee) ORDER BY e.id_employee;
