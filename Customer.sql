USE FashionDB;
GO

SELECT *
FROM customers_fd;

Drop view customersfd_view_age
-- Age View
CREATE VIEW customersfd_view_age As
SELECT Customer_ID, Name, Gender, Date_Of_Birth, Country, City,
    DATEDIFF(YEAR, Date_Of_Birth, GETDATE())
    - CASE
         WHEN (MONTH(Date_Of_Birth) > MONTH(GETDATE()))
             OR (MONTH(Date_Of_Birth) = MONTH(GETDATE()) AND DAY(Date_Of_Birth) > DAY(GETDATE()))
        THEN 1 else 0
    END as Age
FROM customers_fd;

SELECT Top 10 *
From customersfd_view_age;

select MAX(Age), MIN(Age), Avg(Age)
from customersfd_view_age;

-- Age category view
CREATE VIEW customers_ageC As
SELECT Customer_ID, Age,
    case 
           when Age between 0 and 18 then 'Teen' 
           when Age between 19 and 25 then 'Young Adult' 
           when Age between 26 and 35 then 'Adult' 
           when Age between 36 and 50 then 'Middle Age'
           else 'Senior'
    end as AgeCategory
FROM customersfd_view_age;

select distinct Gender
from customers_fd;

SELECT *
FROM customers_fd
WHERE Gender IS NULL;

-- Gender View
CREATE VIEW customerfd_gender AS
select Customer_ID,
        Case 
             when Gender='M' then 'Male'
             when Gender='F' then 'Female'
             when Gender='D' then 'Diverse'
             else 'Unknown'
        END as Gender
from customers_fd;

select distinct City
from customers_fd

SELECT COUNT(DISTINCT City) AS DistinctCityCount
FROM customers_fd;

select distinct Country
from customers_fd

SELECT COUNT(DISTINCT Country) AS DistinctCountryCount
FROM customers_fd;

-- Final View
CREATE VIEW customersfd_view AS
SELECT a.Customer_ID, a.Name, g.Gender, a.Age, r.AgeCategory, a.City, a.Country 
FROM customersfd_view_age a
JOIN customerfd_gender g on a.Customer_ID = g.Customer_ID
Join customers_ageC r on a.Customer_ID = r.Customer_ID;

SELECT *
FROM customersfd_view;


-- KPI View 
CREATE VIEW customer_KPIs AS
SELECT 
      COUNT(Case when Gender = 'Male' then 1 End) AS MaleCount,
      count(case when Gender = 'Female' then 1 end) as FemaleCount,
      count(case when Gender = 'Diverse' then 1 end) as DiverseCount,
      ROUND(COUNT(Case when Gender = 'Male' then 1 End) * 100.0 / COUNT(*), 2) AS MalePct,
      ROUND(COUNT(Case when Gender = 'Female' then 1 End) * 100.0 / COUNT(*), 2) AS FemalePct,
      ROUND(COUNT(Case when Gender = 'Diverse' then 1 End) * 100.0 / COUNT(*), 2) AS DiversePct,
      Count(distinct Country) as CountryCount,
      Count(distinct City) as CityCount,
      Count(Customer_ID) as CustomerCount,
      MAX(Age) as MaxAge,
      Min(Age) as MinAge, 
      AVG(Age) as AvgAge
FROM customersfd_view

Select *
from customer_KPIs



