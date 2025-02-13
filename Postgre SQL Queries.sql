select * from walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	 payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT 
	COUNT(DISTINCT branch) 
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method



-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category


SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1



-- Q.3 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.


SELECT 
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- Q.4 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1



--Q.5 Determine the most common payment method for each Branch. 

WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1


-- 
-- Q.6 Identify 5 branch with highest decrese ratio in 
-- revevenue compare between 2023 and 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

-- Q.7 Top 5 Gross_sales and Quantity
SELECT 
    branch,
    SUM(total) AS total_sales,
    SUM(quantity) AS total_quantity_sold
FROM 
    walmart
GROUP BY 
    branch
ORDER BY 
    total_sales DESC
LIMIT 5;
-- Q.8 Profit By Month
SELECT 
    TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Month') AS month,
    EXTRACT(MONTH FROM TO_DATE(date, 'DD/MM/YY')) AS month_number,
    SUM(total * profit_margin) AS total_profit
FROM 
    walmart
GROUP BY 
    month, month_number
ORDER BY 
    month_number;

-- Q.9 Quantity of Items sold by each category
SELECT 
    category,
    SUM(quantity) AS total_items_sold
FROM 
    walmart
GROUP BY 
    category
ORDER BY 
    total_items_sold DESC;







