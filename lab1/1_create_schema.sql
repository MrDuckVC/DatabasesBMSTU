-- =============================================================
-- ЛАБОРАТОРНАЯ РАБОТА №1. Создание схемы базы данных
-- Файл: 1_create_schema.sql
-- Описание: Скрипт создания таблиц, типов данных и ограничений
-- =============================================================

-- 0. Очистка (для возможности повторного запуска скрипта)
DROP TABLE IF EXISTS public.items;
DROP TABLE IF EXISTS public.orders;
DROP TABLE IF EXISTS public.products;
DROP TABLE IF EXISTS public.customers;
DROP TYPE IF EXISTS order_status_type;

-- 1. Создание пользовательского типа данных (UDDT)
-- Необходим для поля status в таблице Orders (вместо Check constraint)
CREATE TYPE order_status_type AS ENUM ('C', 'P', 'A');

-- =============================================================
-- 2. СОЗДАНИЕ ТАБЛИЦ (Пункт 3 задания)
-- =============================================================

-- Таблица Customers (Клиенты)
CREATE TABLE public.customers
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    company_name character varying(127),
    last_name character varying(63) NOT NULL,
    first_name character varying(63) NOT NULL,
    address character varying(255),
    city character varying(63),
    index_code character varying(31),
    phone character varying(15),
    email character varying(255),

    -- Первичный ключ
    CONSTRAINT customers_pkey PRIMARY KEY (id),

    -- ПУНКТ 5 ЗАДАНИЯ: Ограничение на уникальность по двум столбцам
    CONSTRAINT uq_customers_name UNIQUE (last_name, first_name)
);

-- Таблица Products (Товары)
CREATE TABLE public.products
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    product_name character varying(127) NOT NULL,

    -- Используем numeric для денег (разумный выбор вместо money)
    price numeric(12, 2),
    in_stock integer,
    reorder boolean,
    description text,

    CONSTRAINT products_pkey PRIMARY KEY (id),

    -- Требование схемы: Название продукта должно быть уникальным
    CONSTRAINT uq_product_name UNIQUE (product_name),

    -- ПУНКТ 6 ЗАДАНИЯ: Проверочные ограничения (Check Constraints)
    -- Цена и количество не могут быть отрицательными
    CONSTRAINT chk_products_price_positive CHECK (price >= 0),
    CONSTRAINT chk_products_stock_positive CHECK (in_stock >= 0)
);

-- Таблица Orders (Заказы)
CREATE TABLE public.orders
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    customer_id integer NOT NULL,

    -- ПУНКТ 7 ЗАДАНИЯ: Значение по умолчанию (текущая дата)
    order_date date NOT NULL DEFAULT CURRENT_DATE,

    ship_date date,
    paid_date date,

    -- Используем созданный ранее ENUM ('C', 'P', 'A')
    status order_status_type,

    CONSTRAINT orders_pkey PRIMARY KEY (id),

    -- ПУНКТ 6 ЗАДАНИЯ: Проверка данных для даты
    -- Дата отправки не может быть раньше даты заказа
    CONSTRAINT chk_ship_date_valid CHECK (ship_date >= order_date)
);

-- Таблица Items (Позиции заказа)
CREATE TABLE public.items
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    total numeric(12, 2),

    CONSTRAINT items_pkey PRIMARY KEY (id),

    -- ПУНКТ 6 ЗАДАНИЯ: Проверка числовых полей
    CONSTRAINT chk_items_quantity_positive CHECK (quantity >= 0),
    CONSTRAINT chk_items_total_positive CHECK (total >= 0)
);

-- =============================================================
-- 3. СОЗДАНИЕ СВЯЗЕЙ (ПУНКТ 4 ЗАДАНИЯ: ALTER TABLE)
-- Мы специально добавляем внешние ключи отдельными командами,
-- чтобы выполнить требование "Изменить таблицу с помощью ALTER TABLE"
-- =============================================================

-- Связь Orders -> Customers
ALTER TABLE public.orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
    REFERENCES public.customers (id)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

-- Связь Items -> Orders
ALTER TABLE public.items
    ADD CONSTRAINT fk_items_orders FOREIGN KEY (order_id)
    REFERENCES public.orders (id)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

-- Связь Items -> Products
ALTER TABLE public.items
    ADD CONSTRAINT fk_items_products FOREIGN KEY (product_id)
    REFERENCES public.products (id)
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

-- Вывод сообщения об успехе (опционально)
DO $$
BEGIN
    RAISE NOTICE 'Схема базы данных успешно создана!';
END$$;
