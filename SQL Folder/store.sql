USE FashionDB
GO

select distinct Country
from stores_fd;

CREATE view storesfd_view AS
select Store_ID, Country, City, Number_of_Employees, ZIP_Code, Latitude, Longitude
From stores_fd;

select *
from storesfd_view;