* 📋 Project Overview

This project analyzes a large-scale retail dataset (6.4M+ sales transactions) from a global fashion brand.
It focuses on data cleaning, transformation, and KPI generation using SQL, with interactive visualization and insights built in Power BI.

** 🎯 Objectives
	•	To perform data transformation and aggregation using SQL views for optimized performance.
	•	To build dynamic dashboards in Power BI showcasing key retail metrics and business insights.
	•	To derive actionable patterns in sales, discounts, and customer behavior across multiple countries.

** ⚙️ Technologies Used
	•	Docker – to host Microsoft SQL Server in an isolated containerized environment.
	•	Azure Data Studio – for SQL querying, transformation, and view creation.
	•	Power BI – for visualization, DAX-based calculations, and dashboard creation.
	•	Kaggle Dataset: Global Fashion Retail Sales.

** 🧱 SQL Highlights
	•	Created 15+ optimized views for modular data transformation.
	•	Designed KPIs for:
	•	Customer demographics (age, gender, location)
	•	Product performance (category, subcategory, size, production cost)
	•	Store and employee performance
	•	Discount impact on sales and profit trends
	•	Handled multi-currency conversion, profit computation, and monthly trend analysis.

** 📊 Power BI Dashboard
	•	Pages include:
	•	Sales Overview – Gross, Net, and Return metrics by region and time.
	•	Customer Analysis – Demographics, gender split, and country trends.
	•	Product Insights – Category-wise profit and size availability.
	•	Discount Impact – Comparison of discounted vs. non-discounted sales.
	•	Monthly Mix – Top employees, products, and customers per month.
	•	Integrated DAX measures for MoM growth, return rate, and discount percentage.

** 💡 Key Insights
	•	Majority of sales occurred in European countries, led by Germany and the UK.
	•	Discount periods significantly increased sales volume but slightly reduced margins.
	•	Medium and large sizes accounted for nearly 88% of product sales.
	•	The return rate averaged around 6%, varying seasonally with discount campaigns.
	•	Top 5 employees and products contributed disproportionately to total revenue.

** 🚀 How to Use
	1.	Clone this repository.
	2.	Run the SQL scripts in Azure Data Studio or any SQL-compatible IDE.
	3.	Open the Power BI file (.pbix) and connect it to your SQL Server instance.
	4.	Refresh visuals to explore the live data model.
