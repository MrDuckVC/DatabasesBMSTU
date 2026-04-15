-- Подготовка данных: Внедрение дубликатов для тестирования ранжирующих функций
INSERT INTO public.products (product_name, price, in_stock)
VALUES
('Смартфон X10 Lite', 45000.00, 10),
('Планшет Mini 2', 25000.00, 5);

-- Пункт 4a. Оконные функции ранжирования
SELECT
    product_name AS "Название товара",
    price AS "Цена",
    ROW_NUMBER() OVER (ORDER BY price DESC) AS "ROW_NUMBER",
    RANK()       OVER (ORDER BY price DESC) AS "RANK",
    DENSE_RANK() OVER (ORDER BY price DESC) AS "DENSE_RANK"
FROM
    public.products;

-- Пункт 4b. Запрос с накопленными итогами (SUM, MAX)
SELECT
    product_name AS "Название товара",
    price AS "Цена",
    SUM(price) OVER (ORDER BY price ASC) AS "Накопленная сумма",
    MAX(price) OVER () AS "Абсолютный максимум БД"
FROM
    public.products;

-- Пункт 4c. Оконная функция с секционированием (PARTITION BY)
SELECT
    order_id AS "Номер заказа",
    product_id AS "Номер товара",
    quantity AS "Количество",
    total AS "Сумма по позиции",
    SUM(total) OVER (PARTITION BY order_id) AS "Общая сумма всего заказа"
FROM
    public.items
ORDER BY
    order_id;

-- Пункт 4d. Оконные функции смещения (LAG, LEAD)
SELECT
    id AS "Номер заказа",
    customer_id AS "ID Клиента",
    order_date AS "Дата текущего заказа",
    LAG(order_date)  OVER (PARTITION BY customer_id ORDER BY order_date) AS "Дата предыдущего заказа",
    LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS "Дата следующего заказа"
FROM
    public.orders
ORDER BY
    customer_id,
    order_date;
