--
-- PostgreSQL database dump
--

\restrict 1lpCAUUuG4JljdsrRzv2vzZrY42wiEXKoxUl9DyBaxtVYglNcsOHxQ7s4WtwcLq

-- Dumped from database version 17.8 (Debian 17.8-1.pgdg13+1)
-- Dumped by pg_dump version 17.7

-- Started on 2026-02-15 15:30:23 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 859 (class 1247 OID 32788)
-- Name: order_status_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status_type AS ENUM (
    'Cancelled',
    'Processed',
    'Adopted'
);


ALTER TYPE public.order_status_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 32770)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    company_name character varying(127),
    last_name character varying(63) NOT NULL,
    first_name character varying(63) NOT NULL,
    address character varying(255),
    city character varying(63),
    index_code character varying(31),
    phone character varying(15),
    email character varying(255)
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.id IS 'Уникальный идентификатор клиента.';


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.company_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.company_name IS 'Название фирмы.';


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.last_name IS 'Фамилия клиента.';


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.first_name IS 'Имя клиента.';


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.address IS 'Адрес клиента.';


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.city; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.city IS 'Город проживания.';


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.index_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.index_code IS 'Почтовый индекс.';


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.phone IS 'Телефон.';


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN customers.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.customers.email IS 'Электронная почта.';


--
-- TOC entry 217 (class 1259 OID 32769)
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.customers ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 32824)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    total numeric(12,2),
    CONSTRAINT chk_items_quantity_positive CHECK ((quantity >= 0)),
    CONSTRAINT chk_items_total_positive CHECK ((total >= (0)::numeric))
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN items.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.items.id IS 'Уникальный идентификатор.';


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN items.order_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.items.order_id IS 'Ссылка на таблицу orders.';


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN items.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.items.product_id IS 'Ссылка на таблицу products.';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN items.quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.items.quantity IS 'Количество единиц товара в этом заказе.';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN items.total; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.items.total IS 'Общая стоимость позиции.';


--
-- TOC entry 223 (class 1259 OID 32823)
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.items ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 32796)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    ship_date date,
    paid_date date,
    status public.order_status_type,
    CONSTRAINT chk_ship_date_valid CHECK ((ship_date >= order_date))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN orders.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.id IS 'Уникальный идентификатор заказа.';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN orders.customer_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.customer_id IS 'Ссылка на таблицу customers.';


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN orders.order_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.order_date IS 'Дата оформления заказа.';


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN orders.ship_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.ship_date IS 'Дата отправки заказа.';


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN orders.paid_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.paid_date IS 'Дата оплаты заказа.';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN orders.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.status IS 'Статус заказа.';


--
-- TOC entry 221 (class 1259 OID 32795)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.orders ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 32780)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    product_name character varying(127) NOT NULL,
    price numeric(12,2),
    in_stock integer,
    reorder boolean,
    description text
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN products.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.products.id IS 'Уникальный идентификатор продукта.';


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN products.product_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.products.product_name IS 'Название товара.';


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN products.price; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.products.price IS 'Цена товара.';


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN products.in_stock; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.products.in_stock IS 'Количество товара на складе.';


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN products.reorder; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.products.reorder IS 'Флаг необходимости дозаказа.';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN products.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.products.description IS 'Текстовое описание товара.';


--
-- TOC entry 219 (class 1259 OID 32779)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.products ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3459 (class 0 OID 32770)
-- Dependencies: 218
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, company_name, last_name, first_name, address, city, index_code, phone, email) FROM stdin;
1	TechSolutions	Иванов	Иван	ул. Ленина, 10	Москва	101000	+79001112233	ivanov@techsol.ru
2	Zarya LLC	Петров	Петр	пр. Мира, 5	Москва	129090	+79002223344	petrov@zarya.com
3	IP Sidorov	Сидоров	Алексей	ул. Пушкина, 15	Санкт-Петербург	190000	+79003334455	alex@sidorov.net
4	Global Trade	Смирнова	Елена	Невский пр., 100	Санкт-Петербург	191000	+79004445566	elena@global.ru
5	\N	Кузнецов	Дмитрий	ул. Баумана, 42	Казань	420000	+79005556677	dimakuz@mail.ru
6	SoftDev	Попова	Мария	ул. Гагарина, 1	Новосибирск	630000	+79006667788	maria@softdev.io
7	\N	Соколов	Олег	ул. Советская, 12	Екатеринбург	620000	+79007778899	oleg.sokol@yandex.ru
8	Retail Group	Михайлов	Сергей	ул. Кирова, 8	Нижний Новгород	603000	+79008889900	sergey@retail.org
9	Consulting Plus	Новикова	Анна	ул. Лесная, 3	Москва	115000	+79009990011	anna@consult.ru
10	\N	Федоров	Павел	ул. Садовая, 20	Ростов-на-Дону	344000	+79000001122	pavel.fed@gmail.com
11	Logistics Co	Морозова	Татьяна	ул. Портовая, 56	Владивосток	690000	+79001110022	tanya@logistics.ru
12	\N	Волков	Николай	ул. Звездная, 7	Самара	443000	+79002220033	volkov.n@mail.ru
\.


--
-- TOC entry 3465 (class 0 OID 32824)
-- Dependencies: 224
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, order_id, product_id, quantity, total) FROM stdin;
1	1	1	1	85000.00
2	2	2	2	3000.00
3	2	3	1	4500.00
4	3	4	2	44000.00
5	4	5	1	12000.00
6	5	6	1	45000.00
7	5	8	1	3000.00
8	6	9	3	7500.00
9	7	10	1	5500.00
10	8	11	4	16000.00
11	10	12	10	8000.00
12	11	1	2	170000.00
13	11	2	2	3000.00
14	12	7	1	25000.00
\.


--
-- TOC entry 3463 (class 0 OID 32796)
-- Dependencies: 222
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, customer_id, order_date, ship_date, paid_date, status) FROM stdin;
1	1	2023-10-01	2023-10-02	2023-10-01	Adopted
2	2	2023-10-05	2023-10-06	2023-10-05	Adopted
3	3	2023-10-10	\N	\N	Processed
4	1	2023-10-15	2023-10-16	2023-10-15	Adopted
5	4	2023-10-20	2023-10-20	\N	Cancelled
6	5	2023-11-01	2023-11-03	2023-11-01	Adopted
7	6	2023-11-05	\N	2023-11-05	Processed
8	7	2023-11-10	2023-11-12	2023-11-10	Adopted
9	2	2023-11-15	\N	\N	Cancelled
10	8	2023-11-20	2023-11-21	2023-11-20	Adopted
11	9	2023-12-01	2023-12-05	2023-12-01	Adopted
12	10	2023-12-05	\N	\N	Processed
13	11	2023-12-10	2023-12-11	2023-12-10	Adopted
14	12	2023-12-15	\N	\N	Cancelled
\.


--
-- TOC entry 3461 (class 0 OID 32780)
-- Dependencies: 220
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, product_name, price, in_stock, reorder, description) FROM stdin;
1	Ноутбук Pro 15	85000.00	10	f	Мощный ноутбук для работы
2	Мышь беспроводная	1500.00	50	f	Оптическая мышь, черная
3	Клавиатура механическая	4500.00	20	f	RGB подсветка, синие свитчи
4	Монитор 27 дюймов	22000.00	5	t	IPS матрица, 144Hz
5	Принтер лазерный	12000.00	8	f	Черно-белая печать
6	Смартфон X10	45000.00	15	f	128GB памяти, камера 48MP
7	Планшет Mini	25000.00	0	t	Компактный планшет 8 дюймов
8	Наушники Bluetooth	3000.00	30	f	Шумоподавление, 20ч работы
9	Веб-камера HD	2500.00	12	f	1080p с микрофоном
10	Роутер Wi-Fi 6	5500.00	7	t	Высокоскоростной роутер
11	Жесткий диск 1TB	4000.00	25	f	HDD 7200rpm
12	Флешка 64GB	800.00	100	f	USB 3.0
\.


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 217
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 12, true);


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 223
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 14, true);


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 221
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 14, true);


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 219
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 12, true);


--
-- TOC entry 3293 (class 2606 OID 32844)
-- Name: products chk_product_in_stock_positive; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.products
    ADD CONSTRAINT chk_product_in_stock_positive CHECK ((in_stock >= 0)) NOT VALID;


--
-- TOC entry 3294 (class 2606 OID 32843)
-- Name: products chk_product_price_positive; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.products
    ADD CONSTRAINT chk_product_price_positive CHECK ((price >= (0)::numeric)) NOT VALID;


--
-- TOC entry 3299 (class 2606 OID 32776)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- TOC entry 3309 (class 2606 OID 32830)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 3307 (class 2606 OID 32822)
-- Name: orders orders_pkey ; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_pkey " PRIMARY KEY (id);


--
-- TOC entry 3303 (class 2606 OID 32786)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 3301 (class 2606 OID 32778)
-- Name: customers uq_customers; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT uq_customers UNIQUE (last_name, first_name);


--
-- TOC entry 3305 (class 2606 OID 32842)
-- Name: products uq_product_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT uq_product_name UNIQUE (product_name);


--
-- TOC entry 3311 (class 2606 OID 32836)
-- Name: items fk_items_orders; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_orders FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- TOC entry 3312 (class 2606 OID 32831)
-- Name: items fk_items_products; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_items_products FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 3310 (class 2606 OID 32803)
-- Name: orders fk_orders_customers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES public.customers(id);


-- Completed on 2026-02-15 15:30:23 UTC

--
-- PostgreSQL database dump complete
--

\unrestrict 1lpCAUUuG4JljdsrRzv2vzZrY42wiEXKoxUl9DyBaxtVYglNcsOHxQ7s4WtwcLq

