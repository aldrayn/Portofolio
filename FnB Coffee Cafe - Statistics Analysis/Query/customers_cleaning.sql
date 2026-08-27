
-- Cleaning Table Customers

GO
CREATE OR ALTER VIEW cl_customers AS
WITH 
	normalization as (
		SELECT 
			customer_id,

			-- Normalisasi Penulisan Kapital
			TRIM(STRING_AGG(UPPER(LEFT(value, 1)) + lower(SUBSTRING(value, 2)), ' ' )) customer_name, 
			
			-- Penyeragaman Penulisan Istilah
			max( 
				CASE 
					WHEN UPPER(gender) = 'F' THEN 'Female'
					WHEN UPPER(gender) = 'M' THEN 'Male'
					ELSE gender
				END
			) gender,

			-- Normalisasi format tanggal
			max(
				FORMAT(birth_date, 'dd-MM-yyyy')
			) birth_date,
			
			-- Penyeragaman penulisan nomor telepon
			max(
		
				CASE 
					WHEN LEFT(REPLACE(phone, '-', ''), 2) = '62' THEN '0' + SUBSTRING(phone, 3)
					WHEN LEFT(REPLACE(phone, '-', ''), 3) = '+62' THEN '0' + SUBSTRING(phone, 4)
					ELSE REPLACE(phone, '-', '')
				END
		
			) phone,

			-- Pemberian keterangan pada email
			max(COALESCE(email, '-')) email,
			max(TRIM(city)) city,
			max(TRIM(province)) province,

			-- Normalisasi format tanggal
			max(
				FORMAT(join_date, 'dd-MM-yyyy')
			) join_date,
			
			--- Perbaikan kesalahan penulisan
			max(
				case 
					when lower(customer_segment) = 'membre' then 'member'
					when lower(customer_segment) = 'regular' then 'reguler'
					else lower(customer_segment)
				end
			)  customer_segment


		FROM customers
		CROSS APPLY string_split(customer_name, ' ', 1)
		GROUP BY customer_id
		)

select * from normalization;