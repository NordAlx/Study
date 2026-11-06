-- Только для новой пустой базы с таблицами из ПР01_01.

-- Не запускать поверх уже заполненной базы.

BEGIN;

INSERT INTO public.position (id_position, name) VALUES
(1, 'Администратор'),
(2, 'Уборщик'),
(3, 'Системный администратор'),
(4, 'Менеджер клуба'),
(5, 'Стажёр');

INSERT INTO public.client (id_client, name, number, email) VALUES
(1, 'Виктор Сергеевич', '+79000000001', 'client1@example.test'),
(2, 'Сергей Викторович', '+79000000002', 'client2@example.test'),
(3, 'Семён Андреевич', '+79000000003', 'client3@example.test'),
(4, 'Алёна Дмитриевна', '+79000000004', 'client4@example.test'),
(5, 'Полиэктов Максим Александрович', '+79000000005', 'client5@example.test'),
(6, 'Анна Игоревна', '+79000000006', 'client6@example.test'),
(7, 'Илья Владимирович', '+79000000007', NULL);

INSERT INTO public.loyalty_level (id_loyalty_level, name) VALUES
(1, 'Новичок'),
(2, 'Бронзовый'),
(3, 'Серебряный'),
(4, 'Золотой'),
(5, 'Платиновый');

INSERT INTO public.rating (id_rating, rating) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO public.gaming_hall (id_gaming_hall, name) VALUES
(1, 'Компьютерный зал'),
(2, 'VR-зона'),
(3, 'Зал с приставками'),
(4, 'VIP-зал'),
(5, 'Турнирный зал');

INSERT INTO public.doc_type (id_doc_type, name) VALUES
(1, 'Отчёт о сеансе'),
(2, 'Смета'),
(3, 'Отчёт о работе'),
(4, 'Чек'),
(5, 'Трудовой договор');

INSERT INTO public.tarif (id_tarif, name, price) VALUES
(1, 'Почасовой', 100),
(2, 'Утренний', 500),
(3, 'Дневной', 700),
(4, 'Ночной', 300),
(5, 'Безлимитный', 1000);

INSERT INTO public.payment_method (id_payment_method, name) VALUES
(1, 'СБП'),
(2, 'Банковская карта'),
(3, 'Наличные'),
(4, 'Подарочный сертификат'),
(5, 'Бонусные баллы');

INSERT INTO public.discount (id_discount, name, amount) VALUES
(1, 'Первое посещение', 15),
(2, 'Промокод', 10),
(3, 'Праздничная', 30),
(4, 'Постоянный клиент', 5),
(5, 'День рождения', 40);

INSERT INTO public.employee (id_employee, name, id_position, number, date_of_employment, end_date_of_contract) VALUES
(1, 'Виктор Сергеевич', 1, '+79100000001', '2023-09-01', '2027-08-31'),
(2, 'Игорь Николаевич', 2, '+79100000002', '2023-09-01', '2027-08-31'),
(3, 'Олег Петрович', 3, '+79100000003', '2023-09-01', '2027-08-31'),
(4, 'Мария Андреевна', 4, '+79100000004', '2023-09-01', '2027-08-31'),
(5, 'Алексей Максимович', 5, '+79100000005', '2023-09-01', '2027-08-31'),
(6, 'Анна Игоревна', 1, '+79100000006', '2023-09-01', '2027-08-31'),
(7, 'Дмитрий Ильич', 2, '+79100000007', '2023-09-01', '2027-08-31');

INSERT INTO public.gaming_spot (id_gaming_spot, name, id_gaming_hall) VALUES
(1, 'Место 1', 1),
(2, 'Место 2', 1),
(3, 'Место 3', 1),
(4, 'Место 4', 1),
(5, 'Место 1', 2),
(6, 'Место 2', 2),
(7, 'Место 3', 2),
(8, 'Место 4', 2),
(9, 'Место 1', 3),
(10, 'Место 2', 3),
(11, 'Место 3', 3),
(12, 'Место 4', 3),
(13, 'Место 1', 4),
(14, 'Место 2', 4),
(15, 'Место 3', 4),
(16, 'Место 4', 4),
(17, 'Место 1', 5),
(18, 'Место 2', 5),
(19, 'Место 3', 5),
(20, 'Место 4', 5);

INSERT INTO public.loyalty_card (id_loyalty_card, points, id_loyalty_level, id_client) VALUES
(1, 400, 1, 1),
(2, 500, 2, 2),
(3, 600, 3, 3),
(4, 700, 4, 4),
(5, 800, 5, 5),
(6, 900, 1, 6),
(7, 1000, 2, 7);

INSERT INTO public.review (id_review, id_client, content, id_rating) VALUES
(1, 1, 'Отличный клуб и удобные кресла', 5),
(2, 2, 'Хороший компьютерный зал', 4),
(3, 3, 'Нужна замена гарнитуры', 3),
(4, 4, 'Понравилась VR-зона', 5),
(5, 5, 'Быстрая помощь администратора', 5),
(6, 6, 'Удобное расположение', 4),
(7, 7, 'Мало свободных мест вечером', 2);

INSERT INTO public.document (id_document, id_doc_type, doc_name, content, id_employee, date) VALUES
(1, 1, 'Отчёт о сеансе 1', 'Учёт аренды игрового места', 1, '2025-01-10'),
(2, 1, 'Отчёт о сеансе 2', 'Учёт аренды игрового места', 2, '2025-02-10'),
(3, 1, 'Отчёт о сеансе 3', 'Учёт аренды игрового места', 3, '2025-03-10'),
(4, 1, 'Отчёт о сеансе 4', 'Учёт аренды игрового места', 4, '2025-04-10'),
(5, 1, 'Отчёт о сеансе 5', 'Учёт аренды игрового места', 5, '2025-05-10'),
(6, 1, 'Отчёт о сеансе 6', 'Учёт аренды игрового места', 1, '2025-06-10'),
(7, 1, 'Отчёт о сеансе 7', 'Учёт аренды игрового места', 2, '2025-07-10'),
(8, 1, 'Отчёт о сеансе 8', 'Учёт аренды игрового места', 3, '2025-08-10'),
(9, 1, 'Отчёт о сеансе 9', 'Учёт аренды игрового места', 4, '2025-09-10'),
(10, 1, 'Отчёт о сеансе 10', 'Учёт аренды игрового места', 5, '2025-10-10'),
(11, 1, 'Отчёт о сеансе 11', 'Учёт аренды игрового места', 1, '2025-11-10'),
(12, 1, 'Отчёт о сеансе 12', 'Учёт аренды игрового места', 2, '2025-12-10'),
(13, 1, 'Отчёт о сеансе 13', 'Учёт аренды игрового места', 3, '2025-01-11'),
(14, 1, 'Отчёт о сеансе 14', 'Учёт аренды игрового места', 4, '2025-02-11'),
(15, 1, 'Отчёт о сеансе 15', 'Учёт аренды игрового места', 5, '2025-03-11'),
(16, 1, 'Отчёт о сеансе 16', 'Учёт аренды игрового места', 1, '2025-04-11'),
(17, 1, 'Отчёт о сеансе 17', 'Учёт аренды игрового места', 2, '2025-05-11'),
(18, 1, 'Отчёт о сеансе 18', 'Учёт аренды игрового места', 3, '2025-06-11'),
(19, 1, 'Отчёт о сеансе 19', 'Учёт аренды игрового места', 4, '2025-07-11'),
(20, 1, 'Отчёт о сеансе 20', 'Учёт аренды игрового места', 5, '2025-08-11'),
(21, 1, 'Отчёт о сеансе 21', 'Учёт аренды игрового места', 1, '2025-09-11'),
(22, 1, 'Отчёт о сеансе 22', 'Учёт аренды игрового места', 2, '2025-10-11'),
(23, 1, 'Отчёт о сеансе 23', 'Учёт аренды игрового места', 3, '2025-11-11'),
(24, 1, 'Отчёт о сеансе 24', 'Учёт аренды игрового места', 4, '2025-12-11');

INSERT INTO public.payment (id_payment, id_payment_method, amount, status, id_discount) VALUES
(1, 1, 337, 'Оплата произведена', NULL),
(2, 2, 474, 'Оплата произведена', NULL),
(3, 3, 611, 'Оплата произведена', 1),
(4, 4, 748, 'Оплата произведена', NULL),
(5, 5, 885, 'Оплата произведена', NULL),
(6, 1, 1022, 'Оплата произведена', 1),
(7, 2, 1159, 'Оплата произведена', NULL),
(8, 3, 1296, 'Оплата произведена', NULL),
(9, 4, 233, 'Оплата произведена', 1),
(10, 5, 370, 'Оплата произведена', NULL),
(11, 1, 507, 'Оплата произведена', NULL),
(12, 2, 644, 'Оплата произведена', 1),
(13, 3, 781, 'Оплата произведена', NULL),
(14, 4, 918, 'Оплата произведена', NULL),
(15, 5, 1055, 'Оплата произведена', 1),
(16, 1, 1192, 'Оплата произведена', NULL),
(17, 2, 1329, 'Оплата произведена', NULL),
(18, 3, 266, 'Оплата произведена', 1),
(19, 4, 403, 'Оплата произведена', NULL),
(20, 5, 540, 'Оплата произведена', NULL),
(21, 1, 677, 'Оплата произведена', 1),
(22, 2, 814, 'Ожидает оплаты', NULL),
(23, 3, 951, 'Ожидает оплаты', NULL),
(24, 4, 1088, 'Ожидает оплаты', 1);

INSERT INTO public.rental_session (id_rental_session, id_client, id_gaming_spot, id_employee, id_tarif, id_document, id_payment, status, session_cost) VALUES
(1, 1, 1, 1, 1, 1, 1, 'Завершён', 337),
(2, 2, 2, 2, 2, 2, 2, 'Завершён', 474),
(3, 3, 3, 3, 3, 3, 3, 'Завершён', 611),
(4, 4, 4, 4, 4, 4, 4, 'Завершён', 748),
(5, 5, 5, 5, 5, 5, 5, 'Завершён', 885),
(6, 1, 6, 1, 1, 6, 6, 'Завершён', 1022),
(7, 2, 7, 2, 2, 7, 7, 'Завершён', 1159),
(8, 3, 8, 3, 3, 8, 8, 'Завершён', 1296),
(9, 4, 9, 4, 4, 9, 9, 'Завершён', 233),
(10, 5, 10, 5, 5, 10, 10, 'Завершён', 370),
(11, 1, 11, 1, 1, 11, 11, 'Завершён', 507),
(12, 2, 12, 2, 2, 12, 12, 'Завершён', 644),
(13, 3, 13, 3, 3, 13, 13, 'Завершён', 781),
(14, 4, 14, 4, 4, 14, 14, 'Завершён', 918),
(15, 5, 15, 5, 5, 15, 15, 'Завершён', 1055),
(16, 1, 16, 1, 1, 16, 16, 'Завершён', 1192),
(17, 2, 17, 2, 2, 17, 17, 'Завершён', 1329),
(18, 3, 18, 3, 3, 18, 18, 'Завершён', 266),
(19, 4, 19, 4, 4, 19, 19, 'Активен', 403),
(20, 5, 20, 5, 5, 20, 20, 'Активен', 540),
(21, 1, 1, 1, 1, 21, 21, 'Активен', 677),
(22, 2, 2, 2, 2, 22, 22, 'Отменён', 814),
(23, 3, 3, 3, 3, 23, 23, 'Отменён', 951),
(24, 4, 4, 4, 4, 24, 24, 'Отменён', 1088);

SELECT setval(pg_get_serial_sequence('public.position','id_position'),(SELECT max(id_position) FROM public.position),true);

SELECT setval(pg_get_serial_sequence('public.client','id_client'),(SELECT max(id_client) FROM public.client),true);

SELECT setval(pg_get_serial_sequence('public.loyalty_level','id_loyalty_level'),(SELECT max(id_loyalty_level) FROM public.loyalty_level),true);

SELECT setval(pg_get_serial_sequence('public.rating','id_rating'),(SELECT max(id_rating) FROM public.rating),true);

SELECT setval(pg_get_serial_sequence('public.gaming_hall','id_gaming_hall'),(SELECT max(id_gaming_hall) FROM public.gaming_hall),true);

SELECT setval(pg_get_serial_sequence('public.doc_type','id_doc_type'),(SELECT max(id_doc_type) FROM public.doc_type),true);

SELECT setval(pg_get_serial_sequence('public.tarif','id_tarif'),(SELECT max(id_tarif) FROM public.tarif),true);

SELECT setval(pg_get_serial_sequence('public.payment_method','id_payment_method'),(SELECT max(id_payment_method) FROM public.payment_method),true);

SELECT setval(pg_get_serial_sequence('public.discount','id_discount'),(SELECT max(id_discount) FROM public.discount),true);

SELECT setval(pg_get_serial_sequence('public.employee','id_employee'),(SELECT max(id_employee) FROM public.employee),true);

SELECT setval(pg_get_serial_sequence('public.gaming_spot','id_gaming_spot'),(SELECT max(id_gaming_spot) FROM public.gaming_spot),true);

SELECT setval(pg_get_serial_sequence('public.loyalty_card','id_loyalty_card'),(SELECT max(id_loyalty_card) FROM public.loyalty_card),true);

SELECT setval(pg_get_serial_sequence('public.review','id_review'),(SELECT max(id_review) FROM public.review),true);

SELECT setval(pg_get_serial_sequence('public.document','id_document'),(SELECT max(id_document) FROM public.document),true);

SELECT setval(pg_get_serial_sequence('public.payment','id_payment'),(SELECT max(id_payment) FROM public.payment),true);

SELECT setval(pg_get_serial_sequence('public.rental_session','id_rental_session'),(SELECT max(id_rental_session) FROM public.rental_session),true);

COMMIT;
