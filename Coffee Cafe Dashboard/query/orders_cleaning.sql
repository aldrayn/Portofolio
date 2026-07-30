-- Cleaning Table Orders
GO
CREATE OR ALTER VIEW cl_orders AS
WITH
    orders_cleaning AS (
        SELECT
            o.order_id,
            o.customer_id,
            o.branch_name,
            o.cashier_name,
            o.order_date,
            o.order_time,
            CASE 
                WHEN payment_method IN ('Kartu Debit', 'Debit') THEN 'Debit Card'
                WHEN payment_method = 'Kartu Kredit' THEN 'Credit Card'
                WHEN payment_method = 'Tunai' THEN 'Cash'
                WHEN lower(payment_method) IN ('ovo', 'shopeepay', 'gopay', 'qr code', 'qris') THEN 'E-Wallet'
                ELSE (
                        SELECT STRING_AGG(UPPER(LEFT(value, 1)) + SUBSTRING(lower(value), 2), ' ')
                        FROM string_split(o.payment_method, ' ', 1)
                    )
            END AS payment_method,
            REPLACE(
                REPLACE(
                    COALESCE(o.promotion, '-'), '-', 'Tanpa Promo'), 
                    'NONE', 'Tanpa Promo'
                ) promotion,
            (
                SELECT
                    SUM(quantity * unit_price)
                    FROM cl_order_details cod
                    WHERE cod.order_id = o.order_id
            ) subtotal,
            o.tax,
            o.tax_rate
        FROM orders o
        WHERE EXISTS(
            SELECT 1 FROM cl_order_details cod2
            WHERE cod2.order_id = o.order_id
        )
    ),

    orders_engineering AS (
        select 
            oc2.*,
            ROW_NUMBER() OVER(PARTITION BY oc2.customer_id ORDER BY oc2.order_date) AS CustomerOrderNumber,
	        ROW_NUMBER() OVER(PARTITION BY oc2.customer_id, oc2.branch_name ORDER BY oc2.order_date) AS OrderInBranchNumber 
        from orders_cleaning oc2
    )

SELECT *
FROM orders_engineering

