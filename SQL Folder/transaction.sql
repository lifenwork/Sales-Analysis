USE FashionDB
GO

select top 10 *
from transaction_fd;

CREATE TABLE currency_rate (
    Country VARCHAR(25),
    CurrencyCode VARCHAR(10),
    RateToUSD DECIMAL(18,6),   -- how much 1 unit of that currency equals in USD
);

INSERT into currency_rate (Country, CurrencyCode, RateToUSD)
VALUES
('United States', 'USD', 1.00),
('China', 'CNY', 0.14),
('Germany', 'EUR', 1.10),
('United Kingdom', 'GBP', 1.28);

select *
from currency_rate;

CREATE View transactionfd_view AS
SELECT
      t.InvoiceID,
      t.Line,
      t.CustomerID,
      t.ProductID,
      ISNULL(t.Size, 'N/A') as Size,
      t.UnitPrice * r.RateToUSD as UnitPriceUSD,
      p.Production_Cost as CostPerUnit,
      t.Quantity,
      t.Quantity * p.Production_Cost as ProductionCost,
      t.Date,
      t.Discount,
      t.LineTotal * r.RateToUSD as LineTotalUSD,
      t.StoreID,
      t.EmployeeID,
      t.TransactionType,
      t.PaymentMethod,
      t.InvoiceTotal * r.RateToUSD as InvoiceTotalUSD
From transaction_fd t
Join currency_rate r 
on t.Currency = r.CurrencyCode
join productfd_view p 
on t.ProductID = p.Product_ID

select *
from transactionfd_view;

create view sales_KPI AS
select 
      sum(case when TransactionType = 'Sale' then LineTotalUSD else 0 end) as GrossSalesUSD,
      ABS(Sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as TotalReturnsUSD,
      avg(case when TransactionType = 'Sale' then LineTotalUSD end) as AvgSalesUSD,
      ABS(avg(case when TransactionType = 'Return' then LineTotalUSD end)) as AvgReturnsUSD,
      abs(sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) * 100 /
      nullif(sum(case when TransactionType = 'Sale' then LineTotalUSD end), 0) as ReturnRatePercent,
      sum(case when TransactionType = 'Sale' then LineTotalUSD else 0 end) +
      (Sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as NetSalesUSD,
      Count(InvoiceID) as TotalTransactions,
      Sum(case when TransactionType = 'Sale' then 1 else 0 end) as TotalSalesMade,
      Sum(case when TransactionType = 'Return' then 1 else 0 end) as TotalReturnsMade
From transactionfd_view;

select *
from sales_KPI;

create view year_wise_sale as 
select 
      YEAR(Date) as YEAR,
      count(Distinct InvoiceID) as TotalTransactions,
      sum(case when TransactionType = 'Sale' then LineTotalUSD else  0 end) as GrossSalesUSD,
      Sum(case when TransactionType = 'Sale' then Quantity * ProductionCost else 0 end) as TotalProductionCost,
      Abs(sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as TotalReturnsUSD,
      sum(case when TransactionType = 'Sale' then 1 else 0 end) as TotalSalesMade,
      Sum(case when TransactionType = 'Return' then 1 else 0 end) as TotalReturnsMade,
      sum(case when TransactionType = 'Sale' then LineTotalUSD else 0 end) +
      (Sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as NetSalesUSD,
      abs(Sum(case when TransactionType = 'Return' then LineTotalUSD end)) * 100 /
      Nullif(Sum(case when TransactionType = 'Sale' then LineTotalUSD end), 0) as ReturnRatePercent,
      avg(case when TransactionType = 'Sale' then LineTotalUSD end) as AvgSalesUSD,
      ABS(avg(case when TransactionType = 'Return' then LineTotalUSD end)) as AvgReturnsUSD
From transactionfd_view
group by Year([Date]);

select *
from year_wise_sale;

create view store_wise_sale as 
select 
      t.StoreID,
      s.Country,
      s.City,
      count(Distinct InvoiceID) as TotalTransactions,
      sum(case when TransactionType = 'Sale' then LineTotalUSD else  0 end) as GrossSalesUSD,
      Abs(sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as TotalReturnsUSD,
      sum(case when TransactionType = 'Sale' then 1 else 0 end) as TotalSalesMade,
      Sum(case when TransactionType = 'Return' then 1 else 0 end) as TotalReturnsMade,
      sum(case when TransactionType = 'Sale' then LineTotalUSD else 0 end) +
      (Sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as NetSalesUSD,
      abs(Sum(case when TransactionType = 'Return' then LineTotalUSD end)) * 100 /
      Nullif(Sum(case when TransactionType = 'Sale' then LineTotalUSD end), 0) as ReturnRatePercent,
      avg(case when TransactionType = 'Sale' then LineTotalUSD end) as AvgSalesUSD,
      ABS(avg(case when TransactionType = 'Return' then LineTotalUSD end)) as AvgReturnsUSD
From transactionfd_view t
join storesfd_view s
on t.StoreID = s.Store_ID
group by t.StoreID, s.Country, s.City;

select top 5 *
from store_wise_sale
order by NetSalesUSD DESC;

CREATE VIEW product_cat_sales AS
SELECT
    t.ProductID,
    p.Category,
    p.Sub_Category,
    SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 END) AS GrossSalesUSD,
    ABS(SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end)) AS TotalReturnsUSD,
    SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 end) +
    SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end) AS NetSalesUSD,
    sum(CASE WHEN TransactionType = 'Sale' THEN Quantity else 0 end) as GrossQuantitySold,
    sum(CASE WHEN TransactionType = 'Return' THEN Quantity else 0 end) as QuantityReturned, 
    Sum(case when TransactionType = 'Sale' then Quantity
             when TransactionType = 'Return' then -Quantity else 0 end) as NetQuantitySold,
    (SUM(CASE WHEN TransactionType = 'Return' THEN Quantity ELSE 0 END) * 100.0) /
     NULLIF(SUM(CASE WHEN TransactionType = 'Sale' THEN Quantity ELSE 0 END),0) AS ReturnRateQuantityPercent,
     AVG(CASE WHEN TransactionType = 'Sale' THEN LineTotalUSD END) AS AvgSaleValue
FROM transactionfd_view t
Join productfd_view p
on t.ProductID = p.Product_ID
GROUP BY p.Category, p.Sub_Category, t.ProductID

select *
from product_cat_sales;

Create view employee_sales as 
SELECT
      t.EmployeeID,
      e.Name,
      s.Store_ID,
      SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 END) AS GrossSalesUSD,
      ABS(SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end)) AS TotalReturnsUSD,
      SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 end) +
      SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end) AS NetSalesUSD,
      sum(CASE WHEN TransactionType = 'Sale' THEN Quantity else 0 end) as GrossQuantitySold,
      sum(CASE WHEN TransactionType = 'Return' THEN Quantity else 0 end) as QuantityReturned, 
      Sum(case when TransactionType = 'Sale' then Quantity
             when TransactionType = 'Return' then -Quantity else 0 end) as NetQuantitySold,
      (SUM(CASE WHEN TransactionType = 'Return' THEN Quantity ELSE 0 END) * 100.0) /
      NULLIF(SUM(CASE WHEN TransactionType = 'Sale' THEN Quantity ELSE 0 END),0) AS ReturnRateQuantityPercent,
      AVG(CASE WHEN TransactionType = 'Sale' THEN LineTotalUSD END) AS AvgSaleValue
from transactionfd_view t
join employeesfd_view e
on t.EmployeeID = e.Employee_ID
join storesfd_view s
on t.StoreID = s.Store_ID
group by t.EmployeeID, e.Name, s.Store_ID;

select top 10 *
from employee_sales
order by NetSalesUSD DESC;

Create view customer_wise_sales as 
SELECT
      t.CustomerID,
      c.Name,
      c.Country,
      SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 END) AS GrossSpentUSD,
      ABS(SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end)) AS TotalReturnsUSD,
      SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 end) +
      SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end) AS NetSpentUSD,
      sum(CASE WHEN TransactionType = 'Sale' THEN Quantity else 0 end) as GrossQuantityBought,
      sum(CASE WHEN TransactionType = 'Return' THEN Quantity else 0 end) as QuantityReturned, 
      Sum(case when TransactionType = 'Sale' then Quantity
             when TransactionType = 'Return' then -Quantity else 0 end) as NetQuantityBought,
      (SUM(CASE WHEN TransactionType = 'Return' THEN Quantity ELSE 0 END) * 100.0) /
      NULLIF(SUM(CASE WHEN TransactionType = 'Sale' THEN Quantity ELSE 0 END),0) AS ReturnRateQuantityPercent,
      AVG(CASE WHEN TransactionType = 'Sale' THEN LineTotalUSD END) AS AvgSpentValue
from transactionfd_view t
join customersfd_view c
on t.CustomerID = c.Customer_ID
group by t.CustomerID, c.Name, c.Country, Year(Date), DATENAME(Month, [Date]);
drop view customer_wise_sales

select *
from customer_wise_sales
order by NetSpentUSD DESC

create view discount_effect_on_sales as 
select 
      YEAR(Date) as Year,
      Datename(MONTH, Date) as Month,
      MONTH(Date) AS SalesMonthNumber,
      sum(case when Discount <> 0 and TransactionType = 'Sale' then LineTotalUSD else 0 end) as GrossDiscountedSalesUSD,
      sum(case when Discount <> 0 and TransactionType = 'Sale' then LineTotalUSD else 0 end) +
      sum(case when Discount <> 0 and TransactionType = 'Return' then LineTotalUSD else 0 end) as NetDiscountSalesUSD,
      count(case when Discount <> 0 Then 1 end) as SalesCountOnDiscount,
      SUM(CASE WHEN Discount <> 0 AND TransactionType = 'Sale' 
             THEN (UnitPriceUSD * Quantity - LineTotalUSD) ELSE 0 END) AS TotalDiscountAmount,
      Avg(case when Discount <> 0 and TransactionType = 'Sale'
            then (UnitPriceUSD * Quantity - LineTotalUSD) Else 0 end) as AvgDiscountAmount,
      Avg(case when Discount <> 0 and TransactionType = 'Sale'
            then ((UnitPriceUSD * Quantity - LineTotalUSD) / (UnitPriceUSD * Quantity)) *100 Else 0 end) as AvgDiscountPercent,
      Max(case when Discount <> 0 and TransactionType = 'Sale'
            then (UnitPriceUSD * Quantity) - LineTotalUSD Else 0 end) as MaxDiscountAmount,
      Cast(sum(case when Discount <> 0 and TransactionType = 'Sale' then 1 else 0 end) * 100.0 /
            Nullif(sum(case when TransactionType = 'Sale' then 1 else 0 end), 0) as decimal(10,2)) as DiscountedSalesPercentage
From transactionfd_view
group by Year(Date), Datename(MONTH, Date), MONTH(Date)
HAVING SUM(CASE WHEN Discount <> 0 THEN 1 ELSE 0 END) > 0;

SELECT *
from discount_effect_on_sales;
drop view monthly_sales
create view monthly_sales as 
select 
      YEAR(Date) as YEAR,
      Datename(MONTH, Date) as Month,
      MONTH(Date) AS SalesMonthNumber,
      Sum(case when TransactionType = 'Sale' then LineTotalUSD else 0 end) as GrossTotalUSD,
      abs(Sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end)) as TotalReturnUSD,
      Sum(case when TransactionType = 'Sale' then LineTotalUSD else 0 end) +
      Sum(case when TransactionType = 'Return' then LineTotalUSD else 0 end) as NetSaleUSD,
      Count(Distinct InvoiceID) as TotalTransactions,
      sum(case when TransactionType = 'Return' then Quantity else 0 end) as QuantityReturned,
      sum(case when TransactionType = 'Sale' then Quantity 
      when TransactionType = 'Return' then -Quantity else 0 end) as NetQuantitySold,
      sum(case when TransactionType='Sale' then LineTotalUSD
      when TransactionType='Return' then LineTotalUSD else 0 end) -
      SUM(CASE WHEN TransactionType = 'Sale'
           THEN LineTotalUSD - (ProductionCost * Quantity)
           WHEN TransactionType = 'Return'
           THEN LineTotalUSD ELSE 0 END) AS ProfitUSD,
      case 
          when sum(case when Discount<>0 then 1 else 0 end) > 0 then 1 
          else 0 end as DiscountMonth
from transactionfd_view
Group by YEAR(Date), Datename(MONTH, Date), MONTH(Date);

select *
from monthly_sales
order by [YEAR], [Month]

create view monthly_mix_product as 
select 
      YEAR(Date) as YEAR,
      Datename(MONTH, Date) as Month,
      MONTH(Date) AS SalesMonthNumber,
      t.ProductID,
      p.Category,
      p.Sub_Category,
      Sum(case when TransactionType = 'Sale' then Quantity
             when TransactionType = 'Return' then -Quantity else 0 end) as NetQuantitySold,
      SUM(CASE WHEN TransactionType = 'Sale'
         THEN LineTotalUSD - (ProductionCost * Quantity)
         WHEN TransactionType = 'Return'
         THEN LineTotalUSD 
         ELSE 0 END) AS ProfitUSD
From transactionfd_view t
join productfd_view p on t.ProductID = p.Product_ID
group by YEAR(Date), Datename(MONTH, Date), MONTH(Date), ProductID, Category, Sub_Category;

select * 
from monthly_mix_product

create view monthly_mix_customer as 
select 
      YEAR(Date) as YEAR,
      Datename(MONTH, Date) as Month,
      MONTH(Date) AS SalesMonthNumber,
      t.CustomerID,
      c.Name,
      SUM(CASE when TransactionType = 'Sale' THEN LineTotalUSD ELSE 0 end) +
      SUM(CASE when TransactionType = 'Return' THEN LineTotalUSD ELSE 0 end) AS NetSpentUSD
From transactionfd_view t
join customersfd_view c on t.CustomerID = c.Customer_ID
group by YEAR(Date), Datename(MONTH, Date), MONTH(Date), CustomerID, Name;

select * 
from monthly_mix_customer
order by NetSpentUSD DESC

create view monthly_mix_employee as 
select 
      YEAR(Date) as YEAR,
      Datename(MONTH, Date) as Month,
      MONTH(Date) AS SalesMonthNumber,
      t.EmployeeID,
      e.Name,
      t.StoreID,
      Sum(case when TransactionType = 'Sale' then Quantity
            when TransactionType = 'Return' then -Quantity else 0 end) as NetQuantitySold
From transactionfd_view t
join employeesfd_view e 
on t.EmployeeID = e.Employee_ID
join storesfd_view s 
on t.StoreID = s.Store_ID
group by YEAR(Date), Datename(MONTH, Date), MONTH(Date), EmployeeID, Name, StoreID;

select * 
from monthly_mix_employee
order by NetQuantitySold DESC