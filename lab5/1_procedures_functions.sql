-- Временно отключаем архитектурную защиту базы данных
ALTER EVENT TRIGGER trg_event_prevent_ddl DISABLE;


-- Пункт 2b. Процедура для вставки данных в таблицу (INSERT)
CREATE OR REPLACE PROCEDURE public.add_product(
    p_name character varying,
    p_price numeric,
    p_stock integer
)
LANGUAGE SQL
AS $$
    INSERT INTO public.products (product_name, price, in_stock)
    VALUES (p_name, p_price, p_stock);
$$;

CALL public.add_product('Серверный шкаф', 45000.00, 5);
SELECT * FROM public.products ORDER BY id DESC LIMIT 5;

-- Пункт 2a. Процедура для изменения данных таблицы (UPDATE)
CREATE OR REPLACE PROCEDURE public.update_product_price(
    p_id integer,
    new_price numeric
)
LANGUAGE SQL
AS $$
    UPDATE public.products
    SET price = new_price
    WHERE id = p_id;
$$;

CALL public.update_product_price(999, 42000.00);
SELECT * FROM public.products WHERE id = 999;


-- Пункт 2c. Скалярная арифметическая функция
CREATE OR REPLACE FUNCTION public.get_avg_product_price()
RETURNS numeric
LANGUAGE SQL
AS $$
    SELECT ROUND(AVG(price), 2) FROM public.products;
$$;

SELECT public.get_avg_product_price() AS "Средняя цена по складу";

-- Пункт 2d. Табличная функция поиска по названию компании
CREATE OR REPLACE FUNCTION public.search_customer_by_company(p_company varchar)
RETURNS TABLE (
    customer_id int,
    company_name varchar,
    contact_name varchar,
    phone varchar
)
LANGUAGE SQL
AS $$
    SELECT id, company_name, first_name || ' ' || last_name, phone
    FROM public.customers
    WHERE company_name ILIKE '%' || p_company || '%';
$$;

SELECT * FROM public.search_customer_by_company('a');

-- Пункт 2e. Функция для поиска товаров по диапазону цен
CREATE OR REPLACE FUNCTION public.search_products_by_price_range(
    min_price numeric,
    max_price numeric
)
RETURNS TABLE (
    "Название товара" varchar,
    "Цена" numeric
)
LANGUAGE SQL
AS $$
    SELECT product_name, price
    FROM public.products
    WHERE price BETWEEN min_price AND max_price
    ORDER BY price ASC;
$$;

SELECT * FROM public.search_products_by_price_range(10000.00, 50000.00);

-- Пункт 2f. Функция для поиска заказов по диапазону дат
CREATE OR REPLACE FUNCTION public.search_orders_by_date_range(
    start_date date,
    end_date date
)
RETURNS TABLE (
    "Номер заказа" int,
    "ID Клиента" int,
    "Дата заказа" date
)
LANGUAGE SQL
AS $$
    SELECT id, customer_id, order_date
    FROM public.orders
    WHERE order_date BETWEEN start_date AND end_date
    ORDER BY order_date DESC;
$$;

SELECT * FROM public.search_orders_by_date_range('2023-11-01', '2023-12-31');

-- Вариант 11-15. Задача 1: Клиенты без заказов
CREATE OR REPLACE FUNCTION public.variant_customers_no_orders()
RETURNS TABLE (
    customer_id int,
    company_name varchar,
    first_name varchar,
    last_name varchar
)
LANGUAGE SQL
AS $$
    SELECT
        c.id,
        c.company_name,
        c.first_name,
        c.last_name
    FROM
        public.customers c
    WHERE NOT EXISTS (
        SELECT 1
        FROM public.orders o
        WHERE o.customer_id = c.id
    );
$$;

INSERT INTO public.customers (company_name, last_name, first_name, address, city, index_code, phone, email)
VALUES ('Test', 'No', 'Orders', 'ул. Тестовая 5', 'Москва', 111111, '+79000000000', 'test@mail.ru');
SELECT * FROM public.variant_customers_no_orders();


-- Вариант 11-15. Задача 2: ТОП-5 товаров в заданном городе
CREATE OR REPLACE FUNCTION public.variant_top5_products_by_city(p_city varchar)
RETURNS TABLE (
    product_name varchar,
    total_quantity bigint
)
LANGUAGE SQL
AS $$
    SELECT
        p.product_name,
        SUM(i.quantity) AS total_quantity
    FROM
        public.products p
    JOIN public.items i ON p.id = i.product_id
    JOIN public.orders o ON i.order_id = o.id
    JOIN public.customers c ON o.customer_id = c.id
    WHERE
        c.city = p_city
    GROUP BY
        p.id, p.product_name
    ORDER BY
        total_quantity DESC
    LIMIT 5;
$$;

SELECT * FROM public.variant_top5_products_by_city('Москва');


-- Немедленно включаем защиту обратно!
ALTER EVENT TRIGGER trg_event_prevent_ddl ENABLE;
