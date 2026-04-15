-- 1. Экспорт данных из таблицы во внутреннюю директорию контейнера СУБД
COPY public.products TO '/home/products_export.csv' DELIMITER ',' CSV HEADER;

BEGIN TRAN;

    -- Усечение таблицы товаров и каскадное удаление зависимых строк в items
    TRUNCATE TABLE public.products CASCADE;

    -- 2. Импорт данных из файла обратно в таблицу
    COPY public.products FROM '/home/products_export.csv' DELIMITER ',' CSV HEADER;

-- Откат транзакции для возврата БД к исходному согласованному состоянию
ROLLBACK;
