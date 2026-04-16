with 
	data_with_roi as (
		select 
		mc.*,
		ROUND((mc.Revenue - mc.Spend) / NULLIF(mc.Spend, 0), 5) AS ROI
		from marketing_campaign mc
	)
	, 
	campaign_region_summary as (
		select 
			Region,  
			SUM(Spend) as TotalSpend,
			SUM(Revenue) as TotalRevenue,
			AVG(ROI) as AverageROI
		from data_with_roi
		group by Region
	)
	,
	campaign_type_summary as (
		select 
			CampaignName,
			case 
				when 
					CampaignName 
					in ('Social Media Ads', 
						'Email Marketing', 
						'Search Engine Ads',
						'Influencer Marketing',
						'Content Marketing') then 'Digital'
				else 'Traditional'
				end as CampaignType, 
			AVG(Spend) As AverageSpend,
			AVG(ROI) as AverageROI,
			count(CampaignName) as TotalCampaign
		from data_with_roi
		group by CampaignName, 
				 case
					when 
						CampaignName 
						in ('Social Media Ads', 
							'Email Marketing', 
							'Search Engine Ads',
							'Influencer Marketing',
							'Content Marketing') then 'Digital'
					else 'Traditional'
					end
	)
	
	select * into marketing_campaign_performance from data_with_roi
	select * into marketing_campaign_details from campaign_type_summary
	select * into region_performance from campaign_region_summary