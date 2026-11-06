-- Выполнять ПО БЛОКАМ: получить и сохранить ДО, затем создать индекс и получить ПОСЛЕ.
-- Условия каждого запроса до и после полностью совпадают.
-- Q01. Перед сравнением проверить существующие индексы.
SELECT indexname,indexdef FROM pg_indexes WHERE schemaname='public' AND tablename='payment';
ANALYZE public.payment;
-- Сценарий 1. B-Tree по сумме.
-- Q02. ДО.
EXPLAIN(ANALYZE,BUFFERS) SELECT * FROM public.payment WHERE amount>=5000;
-- Q03. Создание индекса.
CREATE INDEX rbd_idx_payment_amount ON public.payment(amount);
ANALYZE public.payment;
-- Q04. ПОСЛЕ: тот же запрос.
EXPLAIN(ANALYZE,BUFFERS) SELECT * FROM public.payment WHERE amount>=5000;
-- Сценарий 2. Индекс по выражению LOWER(status).
-- Q05. ДО.
EXPLAIN(ANALYZE,BUFFERS) SELECT * FROM public.payment WHERE lower(status)='ошибка оплаты';
-- Q06. Создание индекса по выражению.
CREATE INDEX rbd_idx_payment_lower_status ON public.payment(lower(status));
ANALYZE public.payment;
-- Q07. ПОСЛЕ: тот же запрос.
EXPLAIN(ANALYZE,BUFFERS) SELECT * FROM public.payment WHERE lower(status)='ошибка оплаты';
-- Сценарий 3. Частичный индекс только для успешно проведенных оплат.
-- Q08. ДО. Уже созданный B-Tree может использоваться: зафиксировать фактический план.
EXPLAIN(ANALYZE,BUFFERS) SELECT * FROM public.payment
WHERE status='Оплата произведена' AND amount>=4000;
-- Q09. Создание частичного индекса.
CREATE INDEX rbd_idx_payment_paid_partial ON public.payment(amount)
WHERE status='Оплата произведена';
ANALYZE public.payment;
-- Q10. ПОСЛЕ: тот же запрос.
EXPLAIN(ANALYZE,BUFFERS) SELECT * FROM public.payment
WHERE status='Оплата произведена' AND amount>=4000;
-- Не подменять условия ДО/ПОСЛЕ и не отключать enable_seqscan ради результата.
