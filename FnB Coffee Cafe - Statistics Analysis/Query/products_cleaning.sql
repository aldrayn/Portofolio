-- Cleaning Table Products

GO
CREATE OR ALTER VIEW cl_products AS
select 
	product_id,
	product_name,
	category,

	-- Ada beberapa harga beli lebih besar dari harga jual (kemungkinan tertukar)
	CASE 
		WHEN cost_price > selling_price THEN selling_price
		ELSE cost_price
	END AS cost_price,
	CASE 
		WHEN cost_price > selling_price THEN cost_price
		ELSE selling_price
	END AS selling_price,

	-- Normalisasi format tanggal
	FORMAT(launch_date, 'dd-MM-yyyy') as launch_date,

	-- Normalisasi Penulisan
	UPPER(LEFT(status, 1)) + SUBSTRING(lower(status), 2) as status

from products;


