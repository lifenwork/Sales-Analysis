USE FashionDB
Go

select * 
from discounts_fd;

create view discountsfd_view as 
select [Start], [End], Discont as Discount, [Description], Category, Sub_Category
From discounts_fd;

select * 
from discountsfd_view;

create view cat_wise_discount as 
select 
       case when Category is null then 'All' else Category end as Category,
       case when Sub_Category is null then 'All' else Sub_Category end as Sub_Category,
       Sum(Discount) as Discount,
       AVG(Discount) AS AvgDiscount,
       COUNT(*) AS DiscountCount
From discountsfd_view
Group by Category, Sub_Category;

select *
from cat_wise_discount;