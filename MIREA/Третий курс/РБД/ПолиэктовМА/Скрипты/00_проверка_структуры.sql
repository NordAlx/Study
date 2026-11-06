-- Только чтение. Запустить перед практиками в выбранной базе.
SELECT current_database(), current_user, version();
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema='public' AND table_name IN
('position','employee','client','loyalty_level','loyalty_card','rating','review',
 'gaming_hall','gaming_spot','doc_type','document','tarif','payment_method',
 'discount','payment','rental_session')
ORDER BY table_name, ordinal_position;
SELECT 'client' AS table_name, count(*) AS rows FROM public.client
UNION ALL SELECT 'employee',count(*) FROM public.employee
UNION ALL SELECT 'document',count(*) FROM public.document
UNION ALL SELECT 'payment',count(*) FROM public.payment
UNION ALL SELECT 'rental_session',count(*) FROM public.rental_session;
-- Используемые в практике 4 даты берутся из document.date через id_document.
SELECT e.id_employee,e.name,count(rs.id_rental_session) AS sessions
FROM public.employee e LEFT JOIN public.rental_session rs USING(id_employee)
GROUP BY e.id_employee,e.name ORDER BY e.id_employee;
SELECT date_trunc('month',d.date)::date AS month,count(*) AS sessions
FROM public.rental_session rs JOIN public.document d USING(id_document)
GROUP BY 1 ORDER BY 1;
