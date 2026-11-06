-- Требуется rbd.bonus_redemption из практики 5 и карта 1 с >=50 баллами.
-- Бизнес-операция: уменьшить баллы и создать связанную запись списания.
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
BEGIN;
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1 FOR UPDATE;
DO $check$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM public.loyalty_card WHERE id_loyalty_card=1 AND points>=50) THEN
        RAISE EXCEPTION 'Карта 1 отсутствует либо баллов недостаточно';
    END IF;
END;
$check$;
UPDATE public.loyalty_card SET points=points-50 WHERE id_loyalty_card=1;
INSERT INTO rbd.bonus_redemption(id_loyalty_card,spent_points) VALUES(1,50);
COMMIT;
SELECT * FROM public.loyalty_card WHERE id_loyalty_card=1;
SELECT * FROM rbd.bonus_redemption WHERE id_loyalty_card=1 ORDER BY id_redemption;
