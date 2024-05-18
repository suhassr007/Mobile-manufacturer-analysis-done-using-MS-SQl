--SQL Advanced mobile manufacturer analysis.

--Q1--BEGIN

  select l.state, f.date from[dbo].[FACT_TRANSACTIONS] f
  inner join[dbo].[DIM_LOCATION] l on l.IDLocation = f.IDLocation
  inner join[dbo].[DIM_MODEL] m on m.IDModel = f.IDmodel
  where date between '01-01-2005' and getdate()

--Q1--END

--Q2--BEGIN

  select top 1 L.state,sum(f.[Quantity])as most_price from[dbo].[DIM_LOCATION] L
  inner join[dbo].[FACT_TRANSACTIONS] f on f.IDLocation = L.IDLocation
  inner join[dbo].[DIM_MODEL] m on m. IDmodel = f.IDmodel
  inner join[dbo].[DIM_MANUFACTURER] dm on dm.IDmanufacturer = m.IDmanufacturer
  where manufacturer_name='Samsung'
  group by L.state

--Q2--END

--Q3--BEGIN  

  select[IDModel],L.[state],L.[Zipcode],count(concat(f.[IDCustomer],[IDModel]))
  as no_transaction from[dbo].[FACT_TRANSACTIONS] f 
  inner join[dbo].[DIM_LOCATION] L on F.[IDLocation]=L.IDLocation
  inner join[dbo].[DIM_CUSTOMER] c on F.IDCustomer=c.IDCustomer
  group by [IDModel],L.[State] , L.Zipcode 

--Q3--END

--Q4--BEGIN

  Select top 1 idmodel ,model_name,unit_price from[dbo].[DIM_MODEL]
  group by idmodel,model_name,unit_price order by unit_price asc

--Q4--END

--Q5--BEGIN 
  
  select [Model_Name], avg ([Unit_price]) as average_price from[dbo].[DIM_MODEL] d
  inner join[dbo].[DIM_MANUFACTURER] dm on dm.IDManufacturer = d. IDManufacturer
  where [Manufacturer_Name] in (select top 5 [Manufacturer_Name] from[dbo].[FACT_TRANSACTIONS] f
  inner join[dbo].[DIM_MODEL] d on f.IDModel=d.IDModel
  inner join[dbo].[DIM_MANUFACTURER] dm on d.IDManufacturer = dm.IDManufacturer
  group by [Manufacturer_Name] order by sum(quantity) desc)
  group by [Model_Name]
  order by avg ([Unit_price]) desc;

--Q5--END

--Q6--BEGIN
  Select customer_name,avg(totalprice)  as Avg_Amount from[dbo].[DIM_CUSTOMER] c
  inner join[dbo].[FACT_TRANSACTIONS] t on t . IDCustomer = c. IDCustomer
  inner join[dbo].[DIM_DATE] d on d.Date = t .Date
  where Year = '2009'
  group by customer_name having avg (totalprice)>500

--Q6--END
	
--Q7--BEGIN 
  
  select [IDModel] from (select [IDModel],year(date) as order_year,rank()
  over(partition by year(date) order by sum([Quantity]) desc) as quantity_rank
  from [dbo].[FACT_TRANSACTIONS]
  where year(date) in ('2008','2009','2010')
  group by [IDModel],year(date)) temp
  where quantity_rank<=5
  group by [IDModel]
  having count(distinct order_year)=3;

--Q7--END	
--Q8--BEGIN

  with rank as (select [Manufacturer_Name] , [YEAR] , sum (Quantity) as Total_Qty,
  row_number () over (partition by [YEAR] order by sum(Quantity) desc) as rank
  from[dbo].[DIM_MANUFACTURER] dm
  inner join[dbo].[DIM_MODEL] m on m.[IDManufacturer]=dm.[IDManufacturer]
  inner join[dbo].[FACT_TRANSACTIONS] f on f. [IDModel] = m.[IDModel]
  inner join[dbo].[DIM_DATE] d on d. [DATE] = F.[DATE]
  Where [YEAR] in ('2009','2010') group by [Manufacturer_Name],[YEAR])
  select [Manufacturer_Name], [YEAR], Total_Qty from rank where rank = 2

--Q8--END

--Q9--BEGIN
	
  Select distinct [Manufacturer_Name] from[dbo].[DIM_MANUFACTURER] dm
  inner join[dbo].[DIM_MODEL] m on m.IDManufacturer = dm.IDManufacturer
  inner join[dbo].[FACT_TRANSACTIONS] f on f .IDModel = m.IDModel
  Where YEAR (date)=2010 and dm.Manufacturer_Name not in
  (select[Manufacturer_Name] from[dbo].[DIM_MANUFACTURER] dm
  inner join[dbo].[DIM_MODEL] m on m.IDManufacturer = dm.IDManufacturer
  inner join[dbo].[FACT_TRANSACTIONS] f on f.IDModel = m.IDModel
  Where year (date)=2009)

--Q9--END

--Q10--BEGIN
	
  select top 100 [IDCustomer],year(date) as years ,avg([TotalPrice]) as avg_spend,avg([Quantity]) as avg_quantity,
  (avg([TotalPrice])-lag(avg([TotalPrice])) over(partition by [IDCustomer] order by year(date)))/ nullif(lag(avg([TotalPrice]))
  over (partition by  [IDCustomer] order by year(date)),0)*100 as per_spend
  from [dbo].[FACT_TRANSACTIONS] t
  where [IDCustomer] in
  (select [IDCustomer] from (select top 10 [IDCustomer],sum([TotalPrice]) as total_spend
  from [dbo].[FACT_TRANSACTIONS]
  group by [IDCustomer]
  order by sum([TotalPrice]) desc)a)
  group by [IDCustomer],year(date)
                                                                              
--Q10--END



	
