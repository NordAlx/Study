-- Q01. Все столбцы таблицы клиентов.
SELECT * FROM public.client ORDER BY id_client;
-- Q02. Выбранные поля и псевдонимы.
SELECT name AS "Клиент", number AS "Телефон" FROM public.client;
-- Q03. Выражение: длительность трудового договора в днях.
SELECT name,end_date_of_contract-date_of_employment AS contract_days FROM public.employee;
-- Q04. Уникальные статусы сеансов.
SELECT DISTINCT status FROM public.rental_session ORDER BY status;
-- Q05. Простое условие, AND и OR с явными скобками.
SELECT * FROM public.rental_session
WHERE session_cost>=500 AND (status='Завершён' OR status='Завершен');
-- Q06. Диапазон с включенными границами.
SELECT name,price FROM public.tarif WHERE price BETWEEN 300 AND 700;
-- Q07. Вхождение в множество.
SELECT * FROM public.rental_session WHERE id_tarif IN(1,3,5);
-- Q08. Поиск по шаблону.
SELECT name FROM public.client WHERE name LIKE '%Максим%';
-- Q09. Отсутствующее значение.
SELECT * FROM public.payment WHERE id_discount IS NULL;
-- Q10. ORDER BY: стоимость по убыванию.
SELECT name,price FROM public.tarif ORDER BY price DESC,name ASC;
-- Q11. ORDER BY: две последовательные сортировки.
SELECT name,id_position FROM public.employee ORDER BY id_position ASC,name ASC;
-- Q12. GROUP BY: число сеансов каждого клиента.
SELECT id_client,count(*) AS sessions FROM public.rental_session GROUP BY id_client ORDER BY id_client;
-- Q13. GROUP BY: средняя, минимальная и максимальная стоимость по тарифам.
SELECT id_tarif,avg(session_cost) AS average_cost,min(session_cost) AS min_cost,
max(session_cost) AS max_cost FROM public.rental_session GROUP BY id_tarif ORDER BY id_tarif;
-- Q14. HAVING: клиенты с более чем тремя сеансами.
SELECT id_client,count(*) AS sessions FROM public.rental_session
GROUP BY id_client HAVING count(*)>3 ORDER BY id_client;
-- Q15. WHERE отбирает завершенные сеансы, HAVING фильтрует группы.
SELECT id_employee,avg(session_cost) AS average_cost FROM public.rental_session
WHERE status IN('Завершён','Завершен') GROUP BY id_employee
HAVING avg(session_cost)>500 ORDER BY id_employee;
