-- Pengkategorian Harga Barang
SELECT 
	ProductID,
	ProductName, 
	Price,
	CASE
		WHEN Price < 50 THEN 'Low'
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
		ELSE 'High'
	END As PriceCategory
FROM dbo.products;

--
SELECT
	c.CustomerID,
	c.CustomerName, 
	c.Email,
	c.Gender,
	c.Age,
	g.City,
	g.Country

From
	dbo.customers as c
LEFT JOIN
	dbo.geography as g
ON c.GeographyID = g.GeographyID;

-- Membersihkan spasi ganda pada Customer Review
select
	ReviewID,
	CustomerID,
	ProductID,
	ReviewDate,
	Rating,
	ReviewText,
	REPLACE(ReviewText, '  ', ' ') as 'Cleaned Review Text'
from dbo.customer_reviews ;

--
select
	EngagementID,
	ContentID,
	CampaignID,
	ProductID,

	-- Mapping Data
	UPPER(REPLACE(ContentType, 'SOCIALMEDIA', 'Social Media')) as ContentType,

		-- Misal lebih dari 1 :
		--
		-- Cara 1 - Nested Replace
		-- UPPER(
		--		REPLACE(
		--			REPLACE(ContentType, 'SOCIALMEDIA', 'Social Media'),
		--			'Video Blog',
		--			'Vlog'
		--		) AS ContentType
		--
		-- Cara 2 - CASE WHEN
		-- UPPER(
		--		CASE 
		--			WHEN ContentType = 'SOCIALMEDIA', 'Social Media'
		--          WHEN ContentType = 'Video Blog', 'Vlog'
		--			ELSE ContentType
		--		END
		--		) AS ContentType

	LEFT(ViewsClicksCombined, CHARINDEX('-',ViewsClicksCombined)-1) as Views,
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) as Clicks,
	Likes
	
from dbo.engagement_data;

-- Cek Duplikat
with DuplicateRecords as (
		SELECT
			JourneyID,
			CustomerID, 
			ProductID,
			VisitDate,
			Stage,
			Action,
			Duration,
			--
			ROW_NUMBER() OVER (
				PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
				ORDER BY JourneyID
				) as row_num

		FROM dbo.customer_journey
	)

SELECT *
FROM DuplicateRecords
WHERE row_num > 1;

--
select
	JourneyID,
	CustomerID, 
	ProductID,
	VisitDate,
	Stage,
	Action,
	COALESCE(Duration, avg_date_duration) as Duration

from (
		select
			JourneyID,
			CustomerID, 
			ProductID,
			VisitDate,
			UPPER(Stage) as Stage,
			Action, 
			Duration,

			-- Rata-rata Durasi per hari
			AVG(Duration) OVER (
								Partition BY VisitDate
			) as avg_date_duration,

			-- Nomor
			ROW_NUMBER() OVER (
							   Partition BY JourneyID, CustomerID, ProductID, VisitDate, UPPER(Stage), Action, Duration
							   Order BY JourneyID
			) as row_num

		from dbo.customer_journey

		) as subq

	where row_num = 1