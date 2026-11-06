-- Q01. INNER JOIN: количество сеансов у клиентов, которые посещали клуб.
SELECT c.id_client,c.name,count(rs.id_rental_session) AS sessions
FROM public.client c INNER JOIN public.rental_session rs USING(id_client)
GROUP BY c.id_client,c.name ORDER BY c.id_client;
-- Q02. LEFT JOIN: все клиенты, включая тех, у кого нет сеансов.
SELECT c.id_client,c.name,count(rs.id_rental_session) AS sessions
FROM public.client c LEFT JOIN public.rental_session rs USING(id_client)
GROUP BY c.id_client,c.name ORDER BY c.id_client;
-- Q03. RIGHT JOIN + IS NULL: количество клиентов без сеансов.
SELECT count(*) AS clients_without_sessions
FROM public.rental_session rs RIGHT JOIN public.client c USING(id_client)
WHERE rs.id_rental_session IS NULL;
-- Q04. FULL JOIN: статистика связанных и несвязанных строк.
SELECT count(rs.id_rental_session) FILTER(WHERE c.id_client IS NOT NULL) AS linked_sessions,
count(*) FILTER(WHERE rs.id_rental_session IS NULL) AS clients_without_sessions,
count(*) FILTER(WHERE c.id_client IS NULL) AS sessions_without_client
FROM public.client c FULL JOIN public.rental_session rs USING(id_client);
-- Внешний ключ гарантирует, что sessions_without_client = 0.
-- Q05. CROSS JOIN: все комбинации игровых залов и тарифов.
SELECT gh.name AS hall,t.name AS tarif,t.price FROM public.gaming_hall gh
CROSS JOIN public.tarif t ORDER BY gh.id_gaming_hall,t.id_tarif;
-- Q06. UNION: общий список имен клиентов и сотрудников без дубликатов.
SELECT name FROM public.client UNION SELECT name FROM public.employee ORDER BY name;
-- Q07. INTERSECT: имена, встречающиеся в обеих таблицах.
SELECT name FROM public.client INTERSECT SELECT name FROM public.employee ORDER BY name;
-- Q08. EXCEPT: имена клиентов, отсутствующие среди сотрудников.
SELECT name FROM public.client EXCEPT SELECT name FROM public.employee ORDER BY name;
