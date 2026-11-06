-- Q01. Поисковый CASE: три WHEN и ELSE.
SELECT name,price,CASE WHEN price<300 THEN 'Бюджетный'
WHEN price<600 THEN 'Стандартный' WHEN price<900 THEN 'Расширенный'
ELSE 'Премиальный' END AS category FROM public.tarif ORDER BY price;
-- Q02. CASE внутри SUM: условная агрегация для каждого клиента.
SELECT id_client,SUM(CASE WHEN session_cost>=700 THEN 1 ELSE 0 END) AS expensive,
SUM(CASE WHEN session_cost<700 THEN 1 ELSE 0 END) AS inexpensive
FROM public.rental_session GROUP BY id_client ORDER BY id_client;
-- Q03. Скалярный подзапрос: тарифы дороже среднего.
SELECT * FROM public.tarif WHERE price>(SELECT avg(price) FROM public.tarif);
-- Q04. IN: сеансы с документами за первое полугодие 2025 года.
SELECT * FROM public.rental_session WHERE id_document IN
(SELECT id_document FROM public.document WHERE date>=DATE '2025-01-01' AND date<DATE '2025-07-01');
-- Q05. EXISTS: клиенты, оставившие отзыв со словом «клуб».
SELECT c.id_client,c.name FROM public.client c WHERE EXISTS
(SELECT 1 FROM public.review r WHERE r.id_client=c.id_client AND r.content ILIKE '%клуб%');
-- Q06. Та же задача через JOIN; DISTINCT устраняет повтор клиента.
SELECT DISTINCT c.id_client,c.name FROM public.client c
JOIN public.review r USING(id_client) WHERE r.content ILIKE '%клуб%';
-- Q07. Та же задача через обычное CTE.
WITH matching_clients AS(SELECT DISTINCT id_client FROM public.review WHERE content ILIKE '%клуб%')
SELECT c.id_client,c.name FROM public.client c JOIN matching_clients m USING(id_client);
-- Q08. Рекурсивный обход иерархии с уровнем и защитой от цикла.
WITH RECURSIVE tree AS(
SELECT id_category,name,parent_id,1 AS depth,ARRAY[id_category] AS path
FROM rbd.categories WHERE parent_id IS NULL
UNION ALL
SELECT c.id_category,c.name,c.parent_id,t.depth+1,t.path||c.id_category
FROM rbd.categories c JOIN tree t ON c.parent_id=t.id_category
WHERE NOT c.id_category=ANY(t.path)
)
SELECT id_category,name,parent_id,depth FROM tree ORDER BY path;
