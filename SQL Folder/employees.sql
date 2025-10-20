USE FashionDB
GO

SELECT *
FROM employees_fd;

CREATE VIEW employeesfd_view AS
SELECT Employee_ID, Store_ID, Name, [Position]
FROM employees_fd;

SELECT *
FROM employeesfd_view;

CREATE VIEW employees_KPIs AS
SELECT 
      COUNT(Employee_ID) as TotalEmployees,
      COUNT(Distinct Position) as DistinctPositions,
      Count(Distinct Store_ID) as DistinctStores
From employeesfd_view;

SELECT *
FROM employees_KPIs;

Create view employees_per_position as
select 
      Position,
      count(Employee_ID) as EmployeeCount
From employeesfd_view
GROUP BY Position;

SELECT *
FROM employees_per_position;