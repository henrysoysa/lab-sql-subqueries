/*
Write SQL queries to perform the following tasks using the Sakila database:

Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
List all films whose length is longer than the average length of all the films in the Sakila database.
Use a subquery to display all actors who appear in the film "Alone Trip".
Bonus:

Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

*/

use sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT COUNT(film_id) as number_of_inventory_copies 
FROM sakila.inventory
WHERE film_id IN (
	SELECT film_id
	FROM sakila.film
	WHERE title = 'Hunchback Impossible');


-- List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title, length 
FROM sakila.film
WHERE length > 
(
SELECT AVG(length) as average_duration
FROM sakila.film
);

-- Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT first_name, last_name
FROM sakila.actor
WHERE actor_id IN
(SELECT actor_id FROM sakila.film_actor
WHERE film_id IN( -- gets actor_id's present in film_actor from alone trip
SELECT film_id
FROM sakila.film
WHERE title = 'Alone Trip' -- Gets string of film_id for alone trip
));

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT title
FROM sakila.film
WHERE film_id IN(
	SELECT film_id
	FROM sakila.film_category
	WHERE category_id IN(
		SELECT category_id 
		FROM sakila.category 
		WHERE name = 'Family'
	)
);

-- Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT first_name, last_name, email
FROM sakila.customer
WHERE address_id IN
( SELECT address_id FROM (
	SELECT a.address_id, co.country
	FROM sakila.address a
	JOIN sakila.city c 
	ON a.city_id = c.city_id
	JOIN sakila.country co 
	ON c.country_id = co.country_id
	WHERE co.country = 'Canada'
) as address_country
);


-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.


SELECT title 
FROM sakila.film
WHERE film_id IN
(
	SELECT film_id 
	FROM sakila.film_actor
	WHERE actor_id = (
		SELECT actor_id
		FROM sakila.film_actor
		GROUP BY actor_id
		ORDER BY COUNT(film_id) DESC
		LIMIT 1
					  )
);

-- Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.


SELECT rental_id FROM sakila.payment
WHERE customer_id = (
	SELECT customer_id
	FROM sakila.payment
	GROUP BY customer_id
	ORDER BY SUM(amount) DESC
	LIMIT 1
	)
;


SELECT title
FROM sakila.film
WHERE film_id IN(
	SELECT DISTINCT(film_id) -- gets unique film_ids in case of re-rentals
	FROM sakila.inventory
	WHERE inventory_id IN (
		SELECT inventory_id FROM sakila.rental
		WHERE customer_id = (
			SELECT customer_id
			FROM sakila.payment
			GROUP BY customer_id
			ORDER BY SUM(amount) DESC
			LIMIT 1
			)
	)
)
;

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.

SELECT SUM(amount) as total_amount, customer_id
FROM sakila.payment
GROUP BY customer_id
HAVING total_amount > (
	SELECT ROUND(AVG(total_amount),2) AS average_total_spent
	FROM (
		SELECT SUM(amount) as total_amount, customer_id
		FROM sakila.payment
		GROUP BY customer_id
		) as customer_a
	)
ORDER BY total_amount ASC;
