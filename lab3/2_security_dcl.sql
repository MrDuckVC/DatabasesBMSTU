-- Пункт 10. Создание группы (роли без права входа, но с системными правами)
CREATE ROLE "Test_creator" WITH
    NOLOGIN
    CREATEDB
    CREATEROLE;

-- Пункт 11. Создание пользователя (роли с правом входа)
CREATE ROLE user1 WITH
    LOGIN
    PASSWORD 'qwerty12345';

-- Пункт 12. Наследование системных привилегий
GRANT "Test_creator" TO user1;


-- Явно переключаем контекст на группу-владельца системного атрибута CREATEDB
SET ROLE "Test_creator";

-- Пункт 13. Успешное создание базы данных
CREATE DATABASE test_security_db;

-- Возвращаем контекст исходному пользователю (user1)
RESET ROLE;


-- Пункт 14. Создание изолированных групп
CREATE ROLE read_only_role;
CREATE ROLE read_write_role;

-- Выдача прав на базовую таблицу products
GRANT SELECT ON TABLE public.products TO read_only_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.products TO read_write_role;

-- Пункт 15. Назначение роли пользователю user1
GRANT read_write_role TO user1;

-- Пункт 16. Отзыв прав на вставку данных у группы read_write_role
REVOKE INSERT ON TABLE public.products FROM read_write_role;
