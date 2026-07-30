-- Cleaning Table Order Details

GO
CREATE OR ALTER VIEW cl_order_details AS
WITH 
	cleaned_order_details AS (
		select 
			od.detail_id, 
			od.order_id, 
			od.product_id,
			od.quantity,
			od.unit_price,
			od.discount_rate,
			od.line_total,
			ROW_NUMBER() OVER(PARTITION BY o.customer_id, od.product_id ORDER BY o.order_date) AS ProductOrderNumber
		from order_details od
		LEFT JOIN orders o on o.order_id = od.order_id
	)

select * from cleaned_order_details;
