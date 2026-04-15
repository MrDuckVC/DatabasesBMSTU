-- Пункт 2. Создать любое простое представление.
-- Создаем виртуальный прайс-лист, скрывая технические поля базовой таблицы.
CREATE VIEW v_price_list AS
SELECT
    prname,
    prprice
FROM
    public.products;

-- Запросить с помощью него данные.
SELECT * FROM v_price_list;


-- Пункт 3. Проверить соответствие данных прямым запросом.
SELECT
    prname,
    prprice
FROM
    public.products;


-- Пункт 4. Изменение представления с помощью ALTER VIEW.
-- Меняем метаданные: добавляем русскоязычные псевдонимы.
ALTER VIEW v_price_list RENAME COLUMN prname TO "Название";
ALTER VIEW v_price_list RENAME COLUMN prprice TO "Цена";

-- Проверочный запрос.
SELECT * FROM v_price_list;


-- Пункт 5. Изменение запроса представления.
-- Добавляем фильтрацию (WHERE) без удаления самого объекта.
CREATE OR REPLACE VIEW v_price_list AS
SELECT
    prname AS "Название",
    prprice AS "Цена"
FROM
    public.products
WHERE
    instock > 0;

-- Проверочный запрос.
SELECT * FROM v_price_list;


-- Пункт 6. Вставить данные с помощью представления.
-- Используем уникальное имя во избежание нарушения ограничения UNIQUE.
INSERT INTO v_price_list ("Название", "Цена")
VALUES ('Новый монитор 27 дюймов', 15000.00);


-- Пункт 7. Создать представление с опцией WITH CHECK OPTION.
-- Шаг А. Переопределение представления с ограничением целостности.
CREATE OR REPLACE VIEW v_price_list AS
SELECT
    prname AS "Название",
    prprice AS "Цена"
FROM
    public.products
WHERE
    prprice > 0
WITH CHECK OPTION;

-- Шаг Б. Проверка работы (попытка вставить товар с отрицательной ценой).
INSERT INTO v_price_list ("Название", "Цена")
VALUES ('Клавиатура механическая', -500.00);


-- Пункт 8. Удалить представление.
-- Удаляет только виртуальную таблицу, базовые данные в products остаются.
DROP VIEW v_price_list;


-- Пункт 9. Создание сложного представления на выборку из двух таблиц (JOIN)
CREATE VIEW v_order_details AS
SELECT
    o.order_id AS "Номер заказа",
    o.order_date AS "Дата заказа",
    c.last_name AS "Фамилия клиента",
    o.status AS "Статус"
FROM
    public.orders o
JOIN
    public.customers c ON o.customer_id = c.customer_id;

-- Контрольный запрос для проверки работоспособности сложного представления
SELECT * FROM v_order_details;
