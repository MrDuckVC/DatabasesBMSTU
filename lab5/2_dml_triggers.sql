-- Временно отключаем архитектурную защиту базы данных
ALTER EVENT TRIGGER trg_event_prevent_ddl DISABLE;


-- Пункт 4 и 6. Триггер каскадного удаления (DELETE + OLD)
CREATE OR REPLACE FUNCTION public.trg_func_cascade_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.items WHERE product_id = OLD.id;
    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER trg_before_delete_product
BEFORE DELETE ON public.products
FOR EACH ROW
EXECUTE FUNCTION public.trg_func_cascade_delete();

SELECT * FROM public.items WHERE product_id = 3;
DELETE FROM public.products WHERE id = 3;
SELECT * FROM public.items WHERE product_id = 3;
SELECT * FROM public.products WHERE id = 3;

-- Пункт 3 и 7. Триггер проверки вставляемых данных (INSERT + NEW)
CREATE OR REPLACE FUNCTION public.trg_func_check_insert_item()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.quantity <= 0 THEN
        RAISE EXCEPTION 'Инженерная ошибка: Количество товара (%) не может быть <= 0!', NEW.quantity;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_before_insert_item
BEFORE INSERT ON public.items
FOR EACH ROW
EXECUTE FUNCTION public.trg_func_check_insert_item();

INSERT INTO public.items (order_id, product_id, quantity, total)
VALUES (1, 1, 0, 1500.00);

-- Пункт 5. Триггер для контроля обновлений (UPDATE + NEW + OLD)
CREATE OR REPLACE FUNCTION public.trg_func_update_product()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.price < 0 THEN
        RAISE EXCEPTION 'Отказ транзакции: Цена не может быть отрицательной.';
    END IF;

    IF NEW.price > OLD.price * 2 THEN
        RAISE NOTICE 'Аудит: Цена товара ID % увеличена более чем в 2 раза (было %, стало %)',
                     NEW.id, OLD.price, NEW.price;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_before_update_product
BEFORE UPDATE ON public.products
FOR EACH ROW
EXECUTE FUNCTION public.trg_func_update_product();

UPDATE public.products
SET price = -500.00
WHERE id = 2;

UPDATE public.products
SET price = price * 3
WHERE id = 2;

-- Немедленно включаем защиту обратно!
ALTER EVENT TRIGGER trg_event_prevent_ddl ENABLE;
