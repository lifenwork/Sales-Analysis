USE FashionDB
Go

SELECT *
FROM products_fd;

CREATE VIEW productfd_view AS
select Product_ID, Category, Sub_Category, Description_EN, 
       ISNULL(Color, 'Unknown') AS Color,
       Production_Cost,
       case 
           when Sub_Category = 'Accessories' And Sizes is null then 'N/A'
           when Sizes is Null then 'Unknown'
           else Sizes
        end as Cleaned_Sizes,
       Case
           when Sizes like '%S%' Or Sizes like '%36%' or Sizes like '%P%' then 1 else 0 
        end as Small,
        Case
           when Sizes like '%M%' Or Sizes like '%38%' then 1 else 0 
        end as Medium,
        Case
           when Sizes like '%L%' Or Sizes like '%40%' or Sizes like '%G%' then 1 else 0 
        end as Large,
        Case
           when Sizes like '%XL%' Or Sizes like '%42%' or Sizes like '%GG%' then 1 else 0 
        end as XL, 
        Case
           when Sizes like '%XXL%' Or Sizes like '%44%' then 1 else 0 
        end as XXL,
        Case
           when Sizes like '%XXXL%' Or Sizes like '%46%' then 1 else 0 
        end as XXXL,
        Case
           when Sizes like '%XXXXL%' Or Sizes like '%48%' then 1 else 0 
        end as XXXXL
From products_fd 

select *
from productfd_view

Create VIEW product_KPIs AS
select 
      count(Product_ID) as ProductCount,
      Round(Sum(Production_Cost), 2) as TotalProductionCost,
      Round(AVG(Production_Cost), 2) as AvgProductionCost
From productfd_view;

select *
from product_KPIs

Create view top_expensive_product as 
select top 5 Product_Id, Description_EN, Production_Cost
From productfd_view
ORDER BY Production_Cost DESC;

select *
from top_expensive_product;

Create view product_by_category AS  -- add %age
select Category, 
       Round(Sum(Production_Cost),2) as TotalProductionCost,
       Round(Avg(Production_Cost),2) as AvgProductioncCost,
       Count(Product_ID) as ProductCount,
       Round(COUNT(Product_ID) * 100.0 / (SELECT COUNT(*) FROM productfd_view),2) as CategoryShare,
       MIN(Production_Cost) AS MinProductionCost,
       MAX(Production_Cost) AS MaxProductionCost,
       Round(sum(Small) * 100.0 / COUNT(*),2) AS PctSmall,
       Round(sum(Medium)  * 100.0 / COUNT(*),2) AS PctMedium,
       Round(sum(Large) * 100.0 / COUNT(*),2) AS PctLarge,
       Round(sum(XL) * 100.0 / COUNT(*),2) AS PctXL,
       Round(SUM(XXL) * 100.0 / COUNT(*),2) AS PctXXL,
       Round(SUM(XXXL) * 100.0 / COUNT(*),2) AS PctXXXL,
       Round(SUM(XXXXL) * 100.0 / COUNT(*),2) AS PctXXXXL,
       Round(SUM(CASE WHEN Small = 0 AND Medium = 0 AND Large = 0 
                  AND XL = 0 AND XXL = 0 AND XXXL = 0 AND XXXXL = 0 
             THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS PctNoSize
From productfd_view
GROUP by Category;

select *
from product_by_category;

Create view product_by_cat AS  -- add %age
select Category, Sub_Category, 
       Round(Sum(Production_Cost),2) as TotalProductionCost,
       Round(Avg(Production_Cost),2) as AvgProductioncCost,
       Count(Product_ID) as ProductCount,
       Round(COUNT(Product_ID) * 100.0 / (SELECT COUNT(*) FROM productfd_view),2) as CategoryShare,
       MIN(Production_Cost) AS MinProductionCost,
       MAX(Production_Cost) AS MaxProductionCost,
       Round(sum(Small) * 100.0 / COUNT(*),2) AS PctSmall,
       Round(sum(Medium)  * 100.0 / COUNT(*),2) AS PctMedium,
       Round(sum(Large) * 100.0 / COUNT(*),2) AS PctLarge,
       Round(sum(XL) * 100.0 / COUNT(*),2) AS PctXL,
       Round(SUM(XXL) * 100.0 / COUNT(*),2) AS PctXXL,
       Round(SUM(XXXL) * 100.0 / COUNT(*),2) AS PctXXXL,
       Round(SUM(XXXXL) * 100.0 / COUNT(*),2) AS PctXXXXL,
       Round(SUM(CASE WHEN Small = 0 AND Medium = 0 AND Large = 0 
                  AND XL = 0 AND XXL = 0 AND XXXL = 0 AND XXXXL = 0 
             THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS PctNoSize
From productfd_view
GROUP by Category, Sub_Category;

select *
from product_by_cat;

CREATE view sizes_available_sum AS
select 
      sum(Small) as Small,
      sum(Medium) as Medium,
      sum(Large) as Large,
      sum(XL) as XL,
      sum(XXL) as XXL,
      sum(XXXL) as XXXL,
      sum(XXXXL) as XXXXL,
      sum(case when Small = 0 and Medium = 0 and Large = 0 and XL = 0 and XXL=0
      and XXXL = 0 and XXXXL = 0 then 1 else 0 end) as NoSize
From productfd_view

select *
from sizes_available_sum;

CREATE view sizes_available_percentage AS
select 
       Round(sum(Small) * 100.0 / COUNT(*),2) AS PctSmall,
       Round(sum(Medium)  * 100.0 / COUNT(*),2) AS PctMedium,
       Round(sum(Large) * 100.0 / COUNT(*),2) AS PctLarge,
       Round(sum(XL) * 100.0 / COUNT(*),2) AS PctXL,
       Round(SUM(XXL) * 100.0 / COUNT(*),2) AS PctXXL,
       Round(SUM(XXXL) * 100.0 / COUNT(*),2) AS PctXXXL,
       Round(SUM(XXXXL) * 100.0 / COUNT(*),2) AS PctXXXXL,
       Round(SUM(CASE WHEN Small = 0 AND Medium = 0 AND Large = 0 
                  AND XL = 0 AND XXL = 0 AND XXXL = 0 AND XXXXL = 0 
             THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS PctNoSize
From productfd_view

select *
from sizes_available_percentage;

