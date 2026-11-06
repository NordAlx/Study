-- Выполнить владельцем БД. Роли группы NOLOGIN не являются паролями пользователей.
BEGIN;
CREATE ROLE crm_reader NOLOGIN;
CREATE ROLE crm_sales NOLOGIN;
CREATE ROLE crm_approver NOLOGIN;
CREATE ROLE crm_admin NOLOGIN;
-- DCL-01: закрыть общий доступ к схеме.
REVOKE ALL ON SCHEMA crm FROM PUBLIC;
-- DCL-02: запретить общий вызов служебных функций.
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA crm FROM PUBLIC;
-- DCL-03: разрешить обращение к объектам схемы.
GRANT USAGE ON SCHEMA crm TO crm_reader, crm_sales, crm_approver, crm_admin;
-- DCL-04: читатель видит только представление сумм, без персональных данных.
GRANT SELECT ON crm.v_offer_amount TO crm_reader;
-- DCL-05: менеджеру дать чтение предметных таблиц.
GRANT SELECT ON crm.client, crm.contact, crm.deal, crm.app_user, crm.product,
  crm.offer, crm.offer_line, crm.approval, crm.contract, crm.service_order,
  crm.status_event, crm.activity, crm.v_offer_amount TO crm_sales;
-- DCL-06: менеджер добавляет и изменяет документы продажи.
GRANT INSERT, UPDATE ON crm.client, crm.contact, crm.deal, crm.offer,
  crm.offer_line, crm.contract, crm.service_order, crm.activity TO crm_sales;
-- DCL-07: согласующему нужны версии КП и назначенные роли для проверки триггера.
GRANT SELECT ON crm.offer, crm.offer_line, crm.approval, crm.app_user, crm.user_role TO crm_approver;
-- DCL-08: согласующий записывает решение.
GRANT INSERT ON crm.approval TO crm_approver;
-- DCL-09: администратор ведёт справочники, не получает право согласования.
GRANT SELECT, INSERT, UPDATE ON crm.product, crm.app_user, crm.app_role, crm.user_role TO crm_admin;
-- DCL-10: администратор может читать аудит.
GRANT SELECT ON crm.audit_event TO crm_admin;
-- DCL-11: прикладные роли не изменяют и не удаляют аудит.
REVOKE UPDATE, DELETE, TRUNCATE ON crm.audit_event FROM crm_sales, crm_approver, crm_admin, crm_reader;
COMMIT;
-- Права относятся к таблицам. Ограничение конкретными сделками, проверка текущего
-- пользователя и переходов статусов выполняются сервисным слоем; RLS здесь не включена.
-- Владелец/суперпользователь сохраняет административные права и не применяется в приложении.
