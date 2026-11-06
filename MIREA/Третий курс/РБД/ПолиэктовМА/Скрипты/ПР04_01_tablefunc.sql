-- Выполнить один раз при наличии прав CREATE на базу.
CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;
SELECT extname,extnamespace::regnamespace AS schema FROM pg_extension WHERE extname='tablefunc';
