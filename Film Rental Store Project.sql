/* Send email campaign for customers of Store 2 */
SELECT  first_name, 
	last_name, 
	email
FROM customer
WHERE store_id = 2;

/* Number of movies with rental rate of 0.99 */
SELECT COUNT(*)
FROM film
WHERE rental_rate = 0.99;

/* We want to see rental rate and how many movies are in each rental rate category*/
SELECT  rental_rate, 
	COUNT(*) as total_number_of_movies 
FROM film
GROUP BY rental_rate
ORDER BY rental_rate;

/* Which rating do we have the most films in?*/
SELECT rating, 
       COUNT(*) AS total_number_of_movies
FROM film
GROUP BY 1
ORDER BY 2 DESC;

/* Which rating is most prevalent in each store? */
SELECT s.store_id, f.rating, 
       COUNT(*) OVER (ORDER BY COUNT(*) DESC) AS total_number_of_movies
FROM store AS s
INNER JOIN inventory AS i ON s.store_id = i.store_id
INNER JOIN film AS f ON f.film_id = f.film_id
GROUP BY 1,2
ORDER BY 1,3 DESC;

/* List of films by: Film Name, Category, Language */
SELECT f.title, 
       c.name,  
       l.name
FROM film AS f, 
	 film_category AS fc, 
     category AS c,
     language AS l
WHERE f.film_id = fc.film_id
AND fc.category_id = c.category_id;

/* How many times each movie has been rented out? */
SELECT f.film_id, 
       f.title, 
       COUNT(*) AS total_number_of_movies 
FROM rental as r 
INNER JOIN inventory as i ON r.inventory_id = i.inventory_id
INNER JOIN film as f ON i.film_id = f.film_id
GROUP BY f.film_id
ORDER BY 3 DESC;

/* Revenue per Movie */
SELECT f.film_id, 
       f.title, 
       SUM(p.amount) AS revenue_per_movie
FROM payment AS p,
	 rental AS r,
     inventory AS i,
     film AS f
WHERE p.rental_id = r.rental_id
AND r.inventory_id = i.inventory_id
AND i.film_id = f.film_id
GROUP BY 1
ORDER BY 3 DESC;

/* Most Spending Customer so that we can send him/her rewards or debate points*/
SELECT c.customer_id, 
       c.first_name, 
       c.last_name, 
       SUM(p.amount) AS total_spending
FROM customer AS c 
JOIN payment AS p 
WHERE c.customer_id = p.customer_id
GROUP BY 1 
ORDER BY 4 DESC;

/* What Store has historically brought the most revenue */
SELECT s.store_id, 
       SUM(p.amount) AS total_revenue
FROM store AS s
JOIN staff AS ss ON s.store_id = ss.store_id
JOIN payment AS p on ss.staff_id = p.staff_id
GROUP BY 1
ORDER BY 2 DESC;

/* How many rentals we have for each month and compute running total */
WITH month_total AS 
(
	SELECT LEFT(rental_date, 7) AS month, 
    COUNT(*) AS no_rentals
	FROM rental
	GROUP BY 1 
	ORDER BY 1
)
SELECT month, 
       no_rentals AS total_number_of_rentals,
       SUM(no_rentals) OVER (ORDER BY month) AS moving_total
FROM month_total
GROUP BY 1 
ORDER BY 1;

/* Rentals per Month (such Jan => How much, etc)*/
SELECT MONTHNAME(rental_date) AS month, 
       COUNT(*) AS total_number_of_rentals
FROM rental
GROUP BY 1 
ORDER BY 2 DESC;

/* Which date first movie was rented out ? */
SELECT MIN(rental_date)
FROM rental;

/* Which date last movie was rented out ? */
SELECT MAX(rental_date)
FROM rental;

/* For each movie, when was the first time and last time it was rented out? */
SELECT f.film_id, 
       f.title, 
       MIN(r.rental_date) AS first_rented_date, 
       MAX(r.rental_date) AS last_rented_date
FROM film AS f
INNER JOIN inventory as i 
ON f.film_id = i.film_id
INNER JOIN rental AS r 
ON i.inventory_id = r.inventory_id
GROUP BY 1;

/* Last Rental Date of every Customer */
SELECT c.customer_id, 
       c.first_name, 
       c.last_name, 
       MAX(r.rental_date) AS last_rented_date
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
GROUP BY 1;

/* Revenue Per Month */
SELECT LEFT(payment_date,7) AS month, 
       SUM(amount) AS revenue_per_month
FROM payment
GROUP BY 1;

/* How many rentals and distinct customers per month*/
SELECT LEFT(rental_date,7) AS month, 
       COUNT(rental_id) AS total_rentals,
       COUNT(DISTINCT(customer_id)) AS number_of_unique_customers, 
       COUNT(rental_id)/COUNT(DISTINCT(customer_id)) AS average_number_of_rentals_per_customer
FROM rental
GROUP BY 1;

/*Number of Distinct Film Rented Each Month */
SELECT LEFT(r.rental_date,7) AS month, 
       i.film_id, f.title, 
       COUNT(i.film_id) AS total_number_of_rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1,2,3
ORDER BY 2,3,1;

/* Number of Rentals in Comedy , Sports and Family */
SELECT c.name, 
       COUNT(c.name) AS number_of_rentals
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
WHERE c.name IN ("Comedy", "Sports", "Family")
GROUP BY 1;

/* Customers who rented movies more than 3 tiems */
SELECT c.customer_id, 
       CONCAT(c.first_name, " ", c.last_name) AS full_name, 
       COUNT(*) AS total_rentals
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 1
HAVING COUNT(c.customer_id) >= 3
ORDER BY 1;

/*How much revenue has one single store made over PG13 and R rated films*/
SELECT s.store_id, 
       f.rating, SUM(p.amount) AS total_revenue
FROM store s 
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
JOIN film f ON f.film_id = i.film_id
WHERE f.rating IN ("PG-13", "R")
GROUP BY 1,2
ORDER BY 1;

/* Create table Rewarded Users: users who have rented at least 30 times and stile active*/
/* Active User  where active = 1*/
DROP TEMPORARY TABLE IF EXISTS tbl_rewarded_users;
CREATE TEMPORARY TABLE tbl_rewarded_users (
	SELECT r.customer_id, COUNT(*) AS total_rentals
	FROM rental r
	JOIN customer AS c ON r.customer_id = c.customer_id
	WHERE c.active = 1
	GROUP BY 1
	HAVING COUNT(r.customer_id) >= 30);

SELECT *
FROM tbl_rewarded_users;

/* All Rewarded Users with email */
SELECT ru.customer_id, 
       CONCAT(c.first_name, " ", c.last_name) AS full_name, c.email
FROM tbl_rewarded_users as ru
LEFT JOIN customer AS c ON ru.customer_id = c.customer_id;
