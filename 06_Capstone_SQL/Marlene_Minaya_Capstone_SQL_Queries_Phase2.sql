/* =====================================================================
Marlene Minaya: Capstone
======================================================================= */

/*===================================================================== 
PHASE 1: SQL Script to Load Data: Successful Load
- I had to adjust the slash direction when locating the 'Uploads' folder
- Moved all of the related CSV files in there
- Ran the script and all tables are present 
====================================================================== */ 

/* ======================================================
PHASE 2: Data Quality Investigation & Analytical Queries 
Below I am exploring the tables to get familiar with their 
content, datatypes, and primary and foreign keys 
======================================================== */

/* ==================
1. Database Structure 
=================== */
use capstonevlb;
show tables from capstonevlb;

/* ====================================
2. Tables’ Structure/Column Information 
===================================== */
describe branches;
-- Location_ID PRIMARY
-- State_Code FOREIGN
-- Region_ID

describe budget_categories;
-- Category_ID PRIMARY

select *
from budget_categories;

describe budgets;
-- Budget_ID PRI
-- Cost_Center_Code FOREIGN
-- Category_ID FOREIGN

describe cost_centers;
-- Cost_Center_Code PRI
-- Branch_ID FOREIGN

describe customers;
-- Customer_ID PRI
-- Cust_State FOREIGN 

select *
from customers;
-- credit_card_no_customer_id needs to be trimmed duplicate info

describe departments;
-- Department_ID PRI

describe employees;
-- Employee_ID PRI
-- Department_ID FOREIGN
-- Home_Office FOREIGN

select *
from employees;

describe expenditures;
-- Expense_ID PRI
-- Cost_Center_Code FOREIGN
-- Department_ID FOREIGN
-- Requester_Employee_ID FOREIGN

select *
from expenditures;
-- Description needs to be trimmed -- duplicate vendor info

describe loan_applications;
-- Application_ID PRI
-- Customer_ID FOREIGN

select *
from loan_applications;
-- credit_history 0/1 
-- 1 normally indicates TRUE 0 indicates FALSE

describe region_states;
-- State_code PRI
-- Region_ID FOREIGN

select *
from region_states;

describe regions;
-- Region_ID PRI

describe transactions;
-- Transaction_ID PRI
-- Customer_ID FOREIGN

select *
from transactions;
-- credit_card_no__customer_id needs to be trimmed, redundant customer_id info

/* ======================================
 3. How many budget categories are there?
 ====================================== */

select *
from budget_categories;

select Distinct(category_name) as Category, category_group 
from budget_categories
order by category ASC;
-- I want the see the Distinct Categories to count them individually next

select distinct(category_name)
from budget_categories;

select count(distinct(category_name)) 
from budget_categories;
-- Nested the distinct values into a count function
-- There are 21 budget categories named

select distinct(category_group)
from budget_categories;
-- I want to see the Distinct category groups

select count(distinct(category_group))
from budget_categories;
-- Nested the distinct values into a count function
-- There are 8 category groups

/* ==================================================
Do you see any natural division in the categories?
How many are branch based?  
How many are corporate wide?
==================================================== */

select distinct(category_name)
from budget_categories
where category_group = "Corporate Overhead (HQ ONLY)";
-- Using the WHERE clause I'm able to filter which category names to return if the category group matches 

select count(distinct(category_name)) as corporate_count
from budget_categories
where category_group = "Corporate Overhead (HQ ONLY)";
-- There are 9 Categories within the Corporate Overhead group
-- Possibly indicates that a large amount of funds are alloted here

select distinct(category_name)
from budget_categories
where category_group <> "Corporate Overhead (HQ ONLY)";
-- Using the WHERE clause I'm able to filter which category names to return if the category group does NOT match

select count(distinct(category_name)) as noncorporate_count
from budget_categories
where category_group <> "Corporate Overhead (HQ ONLY)";
-- There are 12 Categories that are Branch-Based 

/* ================================ 
4. How many cost centers are there?
================================= */

select count(cost_center_code)
from cost_centers;

select count(distinct(cost_center_code)) as cost_center_count 
from cost_centers;
-- Testing to see if there was a difference using distinct here
-- There are 43 cost centers

/* ============================================================================ 
How are the following related: cost_centers, branches, budgets, and departments
============================================================================= */
/* ====================================================================
Budgets connects to Cost_Centers through cost_center_code
Cost_Centers connects to Branches through branch_id = location_id
Branches connects to Departments through department_manager_employee_id
====================================================================== */

/*============================================================================
 5. List all customer transactions over $1,000 and show the transaction ID, 
 customer ID, customer Name, amount, transaction date, and merchant category
 =========================================================================== */
 
select t.transaction_id, 
	     t.customer_id, 
         concat(c.first_name,' ',c.last_name) as customer_name, 
         t.transaction_amount, 
         concat(t.month,'/',t.day,'/',t.year) as transaction_date,
         -- needed to create a date column by merging these 3 columns
         merchant_category
from transactions t
join customers c 
-- for every transaction I want to see the customer
	on t.customer_id = c.customer_id
-- joined using the matching keys     
where transaction_amount > 1000
-- filters out transactions with amounts less than 1000
order by transaction_date ASC;

/* ================================================================
6. Find the top 10 highest expenditures by amount. Show expense ID, 
vendor, amount, and fiscal year 
================================================================= */

select expense_id, 
	   vendor, 
       amount, 
       fiscal_year
from expenditures  
order by amount desc
-- to return the highest values at the top
limit 10;   

/* ==============================================
7. Calculate the total customer transaction amount 
and transaction count for each merchant category    
=============================================== */

select merchant_category, 
	   sum(transaction_amount) as total_customer_transactions, 
       count(transaction_id) as number_of_transactions
from transactions 
group by merchant_category
-- creates buckets for the total_sales and number_of_transactions
order by total_customer_transactions desc;

/* ==========================================================================================
8. Calculate the average expenditure amount per branch and the number of expenses per branch  
Sort the results from highest to lowest average expenditure  
Output should include BranchID, BranchName, Number of Expenses, Average Expense Amount
============================================================================================ */

select branch_id, 
	   concat(br.region_id,'-',br.zip_code) as branch_name, 
-- I figured that a branch could be named using their region_id and zip code
       count(expense_id) as number_of_expenses, 
       round(avg(amount), 2) as average_expense_amount
-- applied the round function to have a cleaner output       
from expenditures e
join branches br
	on e.branch_id = br.location_id
-- For every expense I want to see the associated branch information    
group by branch_id
order by average_expense_amount desc;

/* ==========================================================================
9. List Expenditure vendors that have more than 5 expenses and a total spend 
greater than $25,000. Show vendor, number of expenses, and total spend.
=========================================================================== */

select vendor, 
	   count(expense_id) as number_of_expenses, 
       sum(amount) as total_spend
from expenditures 
group by vendor
-- grouped by vendor because I want the number of expenses and total spend for each
having number_of_expenses > 5 AND total_spend > 25000 
-- filters for having greater than 5 expenses and also having a greater total spend of 25k  
order by total_spend desc;

/* ==================================================================
10. List all departments whose 2025 total spending exceeds $100,000. 
Output should include:  Department_ID, Fiscal Year, Total spending
=================================================================== */

select department_id, 
	   fiscal_year, 
       sum(amount) as total_spending
from expenditures
where fiscal_year = 2025
-- filters specifically to show only expenses from 2025
group by department_id
having total_spending > 100000
-- filtering the aggregate values in total_spending to show only greater than 100k
order by total_spending desc;

/* =============================
11. How many states per region? 
=============================== */

select r.region_id, 
	   r.region_name, 
       count(rs.state_code) as number_of_states
-- counting the occurance of each state
from regions r
left join region_states rs
	on r.region_id = rs.region_id
-- Used a left join to show all regions, even those without states    
group by r.region_id;    
-- creates the bucket for number_of_states per region

/* ==============================
12. How many branches per region?    
================================ */

select r.region_id, 
	   r.region_name, 
       count(location_id) as number_of_branches
-- counting the occurance of a branch
from regions r
left join branches br
	on r.region_id = br.region_id
-- for each region I want to see the associated branches 
group by r.region_id;

/* ============================================
13. How many branches are in the same state as 
their region's hub city? 
============================================= */
	
select *
from regions
order by region_id;
-- state code from branches matches the right 2 from hub_city

select right(hub_city,2) as hub_state
from regions;
-- extracting the state from the hub_city column

select r.region_id, 
	   r.hub_city, 
       count(br.location_id) as number_of_branches_in_state
from regions r
join branches br
	on r.region_id = br.region_id
where br.state_code = right(r.hub_city,2)
-- filters where state code matches the final 2 values in hub_city
group by r.region_id;

/* ===============================================
14. What is the total expenditure per department?
================================================= */

select d.department_id, 
	   d.dept_name,
       sum(e.amount) as total_expenditure
from departments d
join expenditures e
	on d.department_id = e.department_id
group by d.department_id
order by d.department_id asc;


/* =============================================
15. Top 5 employees with the longest employment 
and which branch they work at
=============================================== */

select e.employee_id, 
	   e.full_name,
       concat(br.region_id,'-',br.zip_code) as branch_name,
-- created branch_name by concatenating the region_id and zip_code as an identifier
       str_to_date(e.hire_date, '%m/%d/%Y') as hire_date
-- str_to_date helps transform hire_date from string to a valid date to sort with later
from employees e
join branches br
	on e.home_office = br.location_id
order by hire_date asc
-- want to show the earliest hire dates first to show who has been employed the longest
limit 5;
-- limits results to show top 5

describe employees;
-- hire_date was not sorting properly 
-- used describe to check the hire_date datatype
-- it is varchar but should be date

/* ======================================================
16. How many customers per region? Sort from the highest 
number to the lowest number
======================================================= */

select rs.region_id, 
	   count(customer_id) as number_of_customers
from region_states rs
join customers c
	on rs.state_code = c.cust_state
group by rs.region_id
order by number_of_customers desc;

/* ===================================================================
17. Compare the total number of loan applications and the total number 
of approved applications between applicants with good credit history 
and those with no credit history.
==================================================================== */

-- trying to find the value for each condition
select count(application_id) total_applications_good_credit	   
from loan_applications
where credit_history = 1;

select count(application_id) total_approved_good_credit
from loan_applications
where credit_history = 1 and application_status = 'Y';

select count(application_id) total_applications_no_credit
from loan_applications
where credit_history = 0;

select count(application_id) total_approved_no_credit
from loan_applications
where credit_history = 0 and application_status = 'Y';
-- can use each query as a subquery to be a column but that would possibly slow the query as a whole
-- too bulky for a single query

select 
    count(case when credit_history = 1 then application_id end) as total_applications_good_credit,
    count(case when credit_history = 1 and application_status = 'Y' then application_id end) as total_approved_good_credit,
    count(case when credit_history = 0 then application_id end) as total_applications_no_credit,
    count(case when credit_history = 0 and application_status = 'Y' then application_id end) as total_approved_no_credit
-- using a CASE statement here helps to evaluate different conditions in a condensed way
-- each time the case ends its a single column in this query
-- the COUNT function counts the application_id for each condition I specified
from loan_applications;

/* ================================================================================
18. Classify each Customer transaction into a size band using a CASE statement:
Small: < $50
Medium: $50- $499.99
Large: ≥ $500
================================================================================= */

select transaction_id, 
	   (case when transaction_amount >= 500 then 'large'
        when transaction_amount >= 50 then 'medium'
        when transaction_amount < 50 then 'small'
       end) as transaction_size
-- when the sum of transaction_amount is greater than 500 return 'large', and so on
from transactions;

/* ================
Additional Queries
================== */

/* ===========================================================
 1. Subquery
 Which customers have higher than average transaction amounts
 =========================================================== */
 
 select avg(transaction_amount) as avg_transaction_amount
 from transactions;
-- finds the average transaction amount to compare against

select t.customer_id, t.transaction_amount
from transactions t
where t.transaction_amount > (select avg(transaction_amount) as avg_transaction_amount
 from transactions)
 order by transaction_amount desc; 
-- Returns the customer_id and transaction_amount for those with transaction amounts greater than the average

/* ========================================================================
2. Group by & Having
In October, what types of transactions did customers make over 550 times 
and spent more than $1,350,000 on?
 ======================================================================= */

select transaction_type, 
	   count(transaction_id) as number_of_transactions,
       sum(transaction_amount) as total_spend
from transactions
where month = 10
-- want to see transactions from october
group by transaction_type
having number_of_transactions > 550 and total_spend > 1350000
order by total_spend asc;

/* ==========================================================================
3. Group by & Having
In 2025 which categories had annual budgets over $2,000,000?
=========================================================================== */

select b.fiscal_year,
	   bc.category_name,
       sum(b.annual_budget) as annual_budget
from budget_categories bc
join budgets b
	on bc.category_id = b.category_id
where b.fiscal_year = 2025
group by bc.category_name
having annual_budget > 2000000
order by annual_budget desc;

/* ==============================================
4. Subquery
Which branches don't have assigned cost_centers?
=============================================== */

select location_id
from branches
where location_id NOT IN (select branch_id
				          from cost_centers);
-- NOT IN checks that location_id is not found in the subquery for branch_id in cost_centers 
-- Returned a null value, indicating all branches have an assigned cost_center
                       
select location_id
from branches
where location_id IN (select branch_id
				          from cost_centers);
                          
/* =============================================================================
5. CASE Statement
How often is fraud happening in each month? If there's more than 200 occurrences 
it needs to be flagged as 'High Fraudulent Activity', otherwise its 'Standard'
=============================================================================== */                          
                          
select month, 
	   count(transaction_id) as number_of_transactions,
	   (case when (count(transaction_id)) > 200 then 'High Fraudulent Activity' else 'Standard' end) as Fraud_Alert
from transactions
where fraudulent = 1
group by month
order by month asc;




