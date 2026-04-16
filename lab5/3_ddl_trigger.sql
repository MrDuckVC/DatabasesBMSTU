-- Временно отключаем архитектурную защиту базы данных
ALTER EVENT TRIGGER trg_event_prevent_ddl DISABLE;

-- Пункт 8. Создание функции для обработки DDL-событий
CREATE OR REPLACE FUNCTION public.trg_func_prevent_ddl()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Переменная tg_tag автоматически содержит имя вызванной команды (например, 'DROP TABLE')
    RAISE EXCEPTION 'Архитектурная защита: выполнение DDL-команды "%" строго запрещено!', tg_tag;
END;
$$;

-- Создание событийного триггера на уровне базы данных
DROP EVENT TRIGGER IF EXISTS trg_event_prevent_ddl;
CREATE EVENT TRIGGER trg_event_prevent_ddl
ON ddl_command_start
EXECUTE FUNCTION public.trg_func_prevent_ddl();


CREATE TABLE public.test_ddl_block (
    id serial PRIMARY KEY,
    val text
);

ALTER TABLE public.products ADD COLUMN test_column integer;

DROP TABLE public.products;

-- Немедленно включаем защиту обратно!
ALTER EVENT TRIGGER trg_event_prevent_ddl ENABLE;
