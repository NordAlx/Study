-- Выполнять ПО ОПЕРАТОРАМ: отрицательное списание специально вызывает CHECK-ошибку.
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
SELECT count(*) FROM rbd.bonus_redemption WHERE id_loyalty_card=1;
BEGIN;
UPDATE public.loyalty_card SET points=points-10 WHERE id_loyalty_card=1;
INSERT INTO rbd.bonus_redemption(id_loyalty_card,spent_points) VALUES(1,-10);
-- После ожидаемой ошибки обязательно выполнить отдельно.
ROLLBACK;
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
SELECT count(*) FROM rbd.bonus_redemption WHERE id_loyalty_card=1;
