--TASK 1 (Display information on the number of sold hoods (subgroup) in 2006, by region, with summaries by all dimensions)
WITH CTE_Frania AS
    (SELECT Dim_Products.Product, Dim_Regions.Region,  Sales_hist.Quantity, Dim_Time.year, Dim_Products.Subgroup
     FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id)
SELECT Product, Region, SUM(Quantity)
FROM CTE_Frania
WHERE year = 2006
    AND Subgroup = 'hoods'
GROUP BY CUBE(Region, Product);



--TASK 2 (Display the result of TASK 1 using CTE, GROUP by CUBE, PIVOT)
WITH CTE_Frania AS
    (SELECT Dim_Regions.Region, Dim_Products.Product, Sales_hist.Quantity, Dim_Time.year, Dim_Products.Subgroup
     FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id)
SELECT *
FROM (SELECT COALESCE(Product, 'hoods total') as Product, COALESCE(Region, 'regions total') as Region,  SUM(Quantity) as [Quantity]
    FROM CTE_Frania
    WHERE year = 2006 AND Subgroup = 'hoods'
    GROUP BY CUBE(Region, Product)) as p
pivot (SUM(Quantity) for Product in([hoods telescopic] , [hoods furniture], [hoods chimney], [hoods universal], [hoods total])) as pivot_2


--TASK 3 (Determine the degree of implementation of the plan (percentage) in each region (only 2007, January-April, in total)
WITH CTE_Frania_Hist AS
    (SELECT SUM(Sales_hist.Quantity) as [Quantity_hist], Dim_Regions.Region
     FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id
     WHERE Dim_Time.year=2007 and Dim_Time.Month>=1 and Dim_Time.Month<=4
     GROUP BY Dim_Regions.Region),
CTE_Frania_Plan AS
    (SELECT SUM(Sales_plan.Quantity) as [Quantity_plan], Dim_Regions.Region
     FROM Sales_plan
         JOIN Dim_Products ON Sales_plan.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_plan.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_plan.IdRegion = Dim_Regions.Id
     WHERE Dim_Time.year=2007 and Dim_Time.Month>=1 and Dim_Time.Month<=4
     GROUP BY Dim_Regions.Region)
SELECT *
FROM (SELECT h.Region as [region], h.Quantity_hist , p.Quantity_plan, CAST((1.0 *H.Quantity_hist /P.Quantity_plan)*100 AS DECIMAL(6,2)) as [realization%]
    from CTE_Frania_Hist h left outer join CTE_Frania_Plan p on h.Region=p.Region) as pl;


--TASK 4 (Set together the value of the current turnover from sales of individual hoods with this value from the previous quarter, for the year 2006). Add a column that records the change from the previous quarter
SELECT Dim_Products.Product, Dim_Time.Quarterly, SUM(Turnover) as [Turnover current Quarterly], LAG(SUM(Turnover)) OVER (PARTITION BY Dim_Products.Product ORDER BY Dim_Time.Quarterly) as [Turnover prev Quarterly],
    CASE when SUM(Turnover)>=LAG(SUM(Turnover)) OVER (PARTITION BY Dim_Products.Product ORDER BY Dim_Time.Quarterly) then 'growth'
         when SUM(Turnover)<LAG(SUM(Turnover)) OVER (PARTITION BY Dim_Products.Product ORDER BY Dim_Time.Quarterly) then 'decline'
         else '-'
    END as [zmiana]
     FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id
     WHERE Dim_Time.year=2006 and Dim_Products.Subgroup='hoods'
     group by Dim_Time.Quarterly, Dim_Products.Product;
      


--TASK 5 (Determine the sum of the number of chimney hoods sold, increasing by months, for the year 2006)
SELECT Dim_Products.Product, Dim_Time.Month, SUM(Quantity) as [Quantity current Month], SUM(SUM(Quantity)) OVER (ORDER BY Dim_Time.Month) as [sum prev months]
     FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id
     WHERE Dim_Time.year=2006 and Dim_Products.Product='hoods chimney'
     group by Dim_Time.Month, Dim_Products.Product;



--TASK 6 (For each Hood set its sales (turnover) with sales in the whole subgroup-hoods-and the whole group-BI in 2006 and calculate the percentage of the participation)
SELECT Dim_Products.Product as [Product],
    SUM(Sales_hist.Turnover) as [Turnover Product],
    CAST((1.0 *SUM(Sales_hist.Turnover) / (SUM(SUM(Sales_hist.Turnover)) OVER (PARTITION BY Dim_Products.Subgroup)) )*100 AS DECIMAL(6,2)) as [participation in the subgroup hoods %],
    CAST((1.0 *SUM(Sales_hist.Turnover) / (
        select SUM(SUM(Sales_hist.Turnover)) OVER () as [Group_Turnover] FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id
        WHERE Dim_Time.year=2006 and Dim_Products.Group='BI' 
        group by Dim_Products.Group
    ))*100 AS DECIMAL(6,2)) as [udzial w BI %]
    FROM Sales_hist
         JOIN Dim_Products ON Sales_hist.IdProduct = Dim_Products.id
         JOIN Dim_Time ON Sales_hist.IdTime = Dim_Time.id
         JOIN Dim_Regions ON Sales_hist.IdRegion = Dim_Regions.Id
     WHERE Dim_Time.year=2006 and Dim_Products.Subgroup='hoods' 
     group by Dim_Products.Product, Dim_Products.Subgroup, Dim_Products.Group
