--SQL Advance Case Study

create database db_SQLCaseStudies

--Q1--BEGIN . List all the states in which we have customers who have bought cellphones from 2005 till today.
select [State] from FACT_TRANSACTIONS t 
inner join DIM_LOCATION l on t.IDLocation=l.IDLocation
where year(date)>=2005
group by [State]

--Q1--END



--Q2--BEGIN.  What state in the US is buying the most 'Samsung' cell phones?
 select top 1 l.[State] from DIM_MODEL mo 
inner join DIM_MANUFACTURER	ma on mo.IDManufacturer=ma.IDManufacturer 
inner join FACT_TRANSACTIONS t on t.IDModel=mo.IDModel
inner join DIM_LOCATION l on l.IDLocation=t.IDLocation
where Manufacturer_Name='samsung' and Country='us'
group by l.[State]

--Q2--END



--Q3--BEGIN. Show the number of transactions for each model per zip code per state.   
select count(f.IDModel)[number of transactions],zipcode,[state] ,model_name from FACT_TRANSACTIONS f 
inner join DIM_LOCATION l on f.IDLocation=l.IDLocation 
inner join DIM_MODEL m on f.IDModel=m.IDModel
group by ZipCode,[State],m.Model_Name

--Q3--END


--Q4--BEGIN. Show the cheapest cellphone (Output should contain the price)
select  top 1 model_name,unit_price from DIM_MODEL
order by Unit_price asc

--Q4--END



--Q5--BEGIN. Find out the average price for each model in the top5 manufacturers interms of sales quantity and order by average price.

select top 5  m.Model_Name,sum(f.Quantity) [Sales Quantity], ma.Manufacturer_Name ,avg(f.totalprice)[Average Price]from FACT_TRANSACTIONS f 
inner join DIM_MODEL m on f.IDModel=m.IDModel
inner join DIM_MANUFACTURER ma on m.IDManufacturer=ma.IDManufacturer
group by ma.Manufacturer_Name,m.Model_Name
order by sum(f.Quantity) desc

--Q5--END



--Q6--BEGIN6. List the names of the customers and the average amount spent in 2009,where the average is higher than 500
select IDCustomer,avg(totalprice)[Average Amount] from FACT_TRANSACTIONS
where year(date)=2009 
group by idcustomer
having avg(totalprice)>500

--Q6--END

	
--Q7--BEGIN  7. List if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008, 2009 and 2010
create view V1 as
	(Select top 5  model_name from DIM_MODEL m inner join FACT_TRANSACTIONS t on m.IDModel=t.IDModel
	where year([date])  = 2008  
	group by model_name,year([date])
	order by year([date]),sum(Quantity ) desc)


create view	V2 as 
            
    (Select top 5  model_name from DIM_MODEL m inner join FACT_TRANSACTIONS t on m.IDModel=t.IDModel
	where year([date])  = 2009  
	group by model_name,year([date])
	order by year([date]),sum(Quantity ) desc)

create view V3 as
    (Select top 5  model_name from DIM_MODEL m inner join FACT_TRANSACTIONS t on m.IDModel=t.IDModel
	where year([date])  = 2010  
	group by model_name,year([date])
	order by year([date]),sum(Quantity ) desc)

select * from V1
intersect
select * from V2
intersect
select * from V3

--Q7--END	

--Q8--BEGIN. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
create view v4 as(
		select Manufacturer_Name, year(date)[Year]from FACT_TRANSACTIONS f inner join DIM_MODEL m on f.IDModel=m.IDModel
		inner join DIM_MANUFACTURER ma on m.IDManufacturer=ma.IDManufacturer
		where year(date)=2009
		group by f.IDModel,year(date),ma.Manufacturer_Name
		order by sum(totalprice) desc
		offset 1 row
		fetch next 1 row only
		)

create view v5 as(
		select Manufacturer_Name, year(date)[Year]from FACT_TRANSACTIONS f inner join DIM_MODEL m on f.IDModel=m.IDModel
		inner join DIM_MANUFACTURER ma on m.IDManufacturer=ma.IDManufacturer
		where year(date)=2010
		group by f.IDModel,year(date),ma.Manufacturer_Name
		order by sum(totalprice) desc
		offset 1 row
		fetch next 1 row only
		)

select * from v4
union
select * from v5

---2nd top idmodel in 2009
select idmodel,sum(totalprice) from FACT_TRANSACTIONS
where year(date)=2009
group by IDModel
order by sum(totalprice) desc

--Q8--END


--Q9--BEGIN9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.

select distinct Manufacturer_Name from DIM_MANUFACTURER t1 
inner join DIM_MODEL t2 on t1.IDManufacturer=t2.IDManufacturer
inner join FACT_TRANSACTIONS t3 on t2.IDModel=t3.IDModel
where year(date) =2010

except

select distinct  Manufacturer_Name from DIM_MANUFACTURER t1 
inner join DIM_MODEL t2 on t1.IDManufacturer=t2.IDManufacturer
inner join FACT_TRANSACTIONS t3 on t2.IDModel=t3.IDModel
where year(date) =2009 

--Q9--END


--Q10--BEGIN . Find top 100 customers and their average spend, average quantity by each year.
     -- Also find the percentage of change in their spend.
create view v6 as
 (Select top 100 F.IDCustomer, Customer_Name from DIM_CUSTOMER C inner join FACT_TRANSACTIONS F on C.IDCustomer=F.IDCustomer
 group by F.IDCustomer,Customer_Name
 order by sum(TotalPrice) desc)
   
 create view v8 as
 (Select Customer_Name,avg(TotalPrice)[Average spend],avg(Quantity)[Average quantity], sum(TotalPrice)[Total Spend],
 lag(sum (TotalPrice)) over(Partition by v6.Customer_Name order by year(date))[lag]from FACT_TRANSACTIONS F inner join v6
 on F.IDCustomer=v6.IDCustomer
 Group by v6.Customer_Name,year([date]))

 Select v6.Customer_Name, [Average spend],[Average quantity],([Total Spend] - [lag])*100/[lag]
 [Percent change of spend] from v6 inner join v8 on   v6.Customer_Name=v8.Customer_Name  

--Q10--END
	