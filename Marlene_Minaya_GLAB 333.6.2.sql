/* Marlene Minaya GLAB 333.6.2 Joins and Clauses - Banking Database */


/* =============================
PROBLEM STATEMENT 1
What products do we have and what
type of products are they?
================================*/
SELECT p.name as Product, 
	   pt.name as Type
FROM product p
INNER JOIN product_type pt
	ON p.product_type_cd = pt.product_type_cd;
/* JOINED USING PRODUCT TYPE CD WHICH IS THE PRIMARY 
KEY FOR PRODUCT_TYPE AND A FOREIGN KEY IN PRODUCT*/
DESCRIBE product;
DESCRIBE product_type;

/*==============================
PROBLEM STATEMENT 2
Where are each of our employees
based out of and what are their 
titles?
===============================*/
DESCRIBE branch;
-- PK is Branch_ID
DESCRIBE employee;
-- FK is Assigned_branch_ID
SELECT b.name, 
	   b.city, 
       e.last_name, 
       e.title
FROM branch b
INNER JOIN employee e
ON b.branch_id = e.assigned_branch_id;

/*===============================
PROBLEM STATEMENT 3
What are all of the active roles?
================================*/
SELECT DISTINCT(title)
-- Chooses unique values
FROM employee;

/*===============================
PROBLEM STATEMENT 4
Who does each employee report to?
================================*/
SELECT e.last_name AS Name, 
	   e.title AS Title, 
       m.last_name AS 'Boss Name', 
       m.title AS 'Boss Title'
FROM employee e
LEFT JOIN employee m
	ON e.superior_emp_id = m.emp_id;
/* superior_em_id is being compared against 
emp_id where they match up a result is returned */

/*==================================
PROBLEM STATEMENT 5
What is the available balance for each
Product and which customer holds the account?
======================================*/
DESCRIBE product_type;
DESCRIBE account;
DESCRIBE customer;
DESCRIBE individual;

SELECT p.name AS 'Product Name',
	  a.avail_balance AS 'Available Balance',
      i.last_name AS 'Customer'
FROM account a
INNER JOIN product p
	ON p.product_cd = a.product_cd
-- WANT TO SHOW ALL ACCOUNTS AND THEIR PRODUCTS
LEFT JOIN customer c
	ON a.cust_id = c.cust_id
-- WANT TO SHOW FOR EACH PRODUCT WHICH CUSTOMER HAS IT
LEFT JOIN individual i
	ON i.cust_id = c.cust_id;
-- WANT TO SHOW FOR EACH CUSTOMER WHAT THEIR LAST NAME IS
-- *NOTE* GET REALLY SPECIFIC ABOUT THE INFORMATION NEEDED AND THE ORDER

/*====================================
PROBLEM STATEMENT 6
For customers whose last name begins
with 'T', show their transaction details
======================================*/
SELECT ac.*, i.last_name
FROM acc_transaction ac
INNER JOIN account a 
	ON a.account_id = ac.account_id
INNER JOIN customer c
	ON c.cust_id = a.cust_id
INNER JOIN individual i
	ON i.cust_id = c.cust_id
WHERE i.last_name LIKE 'T%';
    
 

