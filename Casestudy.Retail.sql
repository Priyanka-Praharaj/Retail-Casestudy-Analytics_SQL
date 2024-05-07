CREATE DATABASE Retail_Cs1

--Data preparation and understanding
select* from[dbo].[Customer]
select* from[dbo].[prod_cat_info]
select* from[dbo].[Transactions]


--1)
SELECT COUNT(*) as CNT from[dbo].[Customer]

UNION

SELECT COUNT(*) as CNT from[dbo].[prod_cat_info]

UNION

SELECT COUNT(*) as CNT from[dbo].[Transactions]

--2)
SELECT COUNT(DISTINCT (TRANSACTION_ID)) AS TOTAL_TRANSACTION FROM [dbo].[Transactions]
WHERE QTY<0

--3)
SELECT CONVERT(DATE,TRAN_DATE,105) AS TRAN_DATES FROM [dbo].[Transactions]
--4)
SELECT DATEDIFF(YEAR,MIN(CONVERT(DATE,TRAN_DATE,105)),MAX(CONVERT(DATE,TRAN_DATE,105))) AS DIFF_YEARS,
       DATEDIFF(MONTH,MIN(CONVERT(DATE,TRAN_DATE,105)),MAX(CONVERT(DATE,TRAN_DATE,105))) AS DIFF_MONTHS,
       DATEDIFF(DAY,MIN(CONVERT(DATE,TRAN_DATE,105)),MAX(CONVERT(DATE,TRAN_DATE,105))) AS DIFF_DAYS 
FROM Transactions

--5)
SELECT PROD_CAT ,PROD_SUBCAT FROM[dbo].[prod_cat_info]
WHERE PROD_SUBCAT ='DIY'




--DATA ANALYSIS
select TOP 3* from[dbo].[Customer]
select TOP 3* from[dbo].[prod_cat_info]
select * from[dbo].[Transactions]

--1)
SELECT TOP 1 STORE_TYPE,COUNT(*) AS CNT FROM Transactions
GROUP BY STORE_TYPE
ORDER BY COUNT(*) DESC

--2)
SELECT GENDER, COUNT(*) AS CNT FROM [dbo].[Customer]
WHERE GENDER IS NOT NULL
GROUP BY GENDER

 --3)
 SELECT TOP 1 CITY_CODE , COUNT(*) AS CNT FROM Customer
 WHERE city_code IS NOT NULL
 GROUP BY CITY_CODE 
 ORDER BY CNT DESC

 --4)
 SELECT PROD_CAT,PROD_SUBCAT FROM prod_cat_info
 WHERE PROD_CAT ='BOOKS'

 --5)
 SELECT PROD_CAT_CODE, Max(QTY) AS MAX_PROD FROM Transactions
 GROUP BY PROD_CAT_CODE

 --6)
 select SUM(CAST(TOTAL_AMT AS FLOAT)) AS NET_REVENUE FROM [dbo].[prod_cat_info] AS T1
 JOIN [dbo].[Transactions] AS T2 
 ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_sub_cat_code=T2.prod_subcat_code
 WHERE prod_cat='BOOKS' OR prod_cat='ELECTRONICS'

 --7)
 SELECT COUNT(*) AS TOT_CUST FROM(
 SELECT CUST_ID, COUNT(DISTINCT(TRANSACTION_ID)) AS CNT_TRANS FROM Transactions
 WHERE QTY>0
 GROUP BY CUST_ID
 HAVING COUNT(DISTINCT(TRANSACTION_ID))>10
 ) AS A

 --8)

 select SUM(CAST(TOTAL_AMT AS FLOAT)) AS COMBINED_REVENUE FROM [dbo].[prod_cat_info] AS T1
 JOIN [dbo].[Transactions] AS T2 
 ON T1.prod_cat_code=T2.prod_cat_code AND T1.prod_sub_cat_code=T2.prod_subcat_code
 WHERE prod_cat IN ('CLOTHING','ELECTRONICS') AND STORE_TYPE='FLAGSHIP STORE' AND QTY>0

 --9)
 SELECT PROD_SUBCAT, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE FROM Customer AS T1
 JOIN Transactions AS T2
 ON T1.customer_Id=T2.CUST_ID
 JOIN prod_cat_info AS T3
 ON T2.PROD_CAT_CODE=T3.prod_cat_code AND T2.PROD_SUBCAT_CODE=T3.prod_sub_cat_code
 WHERE GENDER='M' AND prod_cat='ELECTRONICS'
 GROUP BY prod_subcat

 --10)
 SELECT A.prod_subcat, PERCENTAGE_SALES,PERCENTAGE_RETURN FROM(
 SELECT TOP 5 prod_subcat,(SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) as TOT_SALES  FROM Transactions WHERE QTY>0)) AS PERCENTAGE_SALES
 from Transactions as t1
 JOIN prod_cat_info AS T2
ON T2.PROD_CAT_CODE=T1.prod_cat_code AND T1.PROD_SUBCAT_CODE=T2.prod_sub_cat_code
 WHERE QTY>0
 group by prod_subcat
 ORDER BY PERCENTAGE_sales DESC
 ) AS A
 JOIN
 (SELECT prod_subcat,(SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) as TOT_SALES  FROM Transactions WHERE QTY<0)) AS PERCENTAGE_RETURN
 from Transactions as t1
 JOIN prod_cat_info AS T2
ON T2.PROD_CAT_CODE=T1.prod_cat_code AND T1.PROD_SUBCAT_CODE=T2.prod_sub_cat_code
 WHERE QTY<0
 group by prod_subcat) AS B
 ON A.prod_subcat=B.prod_subcat

 --11)
 SELECT * FROM (
 SELECT* FROM (
 SELECT cust_id,DATEDIFF(YEAR,DOB,MAX_DATE) AS AGE,REVENUE FROM (
 SELECT CUST_ID,DOB,MAX(CONVERT(DATE,TRAN_DATE,105)) AS MAX_DATE,SUM(CAST(TOTAL_AMT AS FLOAT))AS REVENUE FROM Customer AS T1
 JOIN Transactions AS T2
 ON T1.customer_Id=T2.cust_id
 WHERE QTY>0
 GROUP BY CUST_ID,DOB
 ) AS A
    ) AS B
	WHERE AGE BETWEEN 25 AND 35
	) AS C
	JOIN (

	--LAST 30DAYS OF TRANSACTION
	SELECT CUST_ID, CONVERT(DATE,TRAN_DATE,105) AS TRAN_DATE
	FROM Transactions
	GROUP BY CUST_ID,CONVERT(DATE,TRAN_DATE,105)
	HAVING CONVERT(DATE,TRAN_DATE,105)>=(SELECT DATEADD(DAY,-30,MAX(CONVERT(DATE,TRAN_DATE,105))) AS CUTOFF_DATE FROM Transactions)

 ) AS D 
 ON C.CUST_ID=D.CUST_ID


 --12)
 select top 1 prod_cat_code ,sum(returns) as tot_returns from (
 SELECT  prod_cat_code, CONVERT(DATE,TRAN_DATE,105) AS TRAN_DATE,sum(convert(int,qty)) AS Returns
	FROM Transactions
	WHERE Qty<0
	GROUP BY prod_cat_code,CONVERT(DATE,TRAN_DATE,105)
	HAVING CONVERT(DATE,TRAN_DATE,105) >=( SELECT DATEADD(MONTH, -3,MAX(CONVERT(DATE,TRAN_DATE,105))) AS CUTOFF_DATE FROM Transactions)
	) as A
	group by prod_cat_code
	order by tot_returns


--13)
select store_type,sum(cast(total_amt as float)) as revenue ,sum(convert(int,qty)) as quantity
from Transactions
where qty>0
group by Store_type
order by revenue desc,quantity desc

--14)
select prod_cat_code,avg(cast(total_amt as float)) as avg_revenue from Transactions
where qty>0
group by prod_cat_code
having avg(cast(total_amt as float)) >= (select avg(cast(total_amt as float)) from Transactions  where qty>0)

--15)
select prod_subcat_code,sum(cast(total_amt as float)) as revenue, avg(cast(total_amt as float)) as avg_revenue
from Transactions
where qty>0 and prod_cat_code in (select top 5 prod_cat_code from Transactions
                                  where qty> 0
                                  group by prod_cat_code
                                  order by sum(convert(int,qty)) desc  )
group by prod_subcat_code









