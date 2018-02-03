##############################
######## Sungwon Byun ########
##############################

USE sakila;

DESCRIBE actor;

###### 1
#1a
SELECT `first_name`,`last_name`
FROM actor;

#1b
SELECT concat(first_name,' ',last_name) AS `Actor Name`
FROM actor;

###### 2
#2a
SELECT *
FROM actor
WHERE first_name = 'Joe';

#2b
SELECT *
FROM actor
WHERE last_name LIKE '%gen%';

#2c
SELECT *
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name,first_name;

#2d
SELECT country_id,country
FROM country 
WHERE country IN ('Afghanistan','Bangladesh','China');

###### 3
#3a
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50) NOT NULL;

#3b
ALTER TABLE actor
CHANGE COLUMN middle_name middle_name BLOB NOT NULL;

#3c
ALTER TABLE actor
DROP COLUMN middle_name;

###### 4
#4a
SELECT last_name,COUNT(actor_id) AS actor_count FROM actor actor_counts GROUP BY last_name ;

#4b
SELECT *
FROM (SELECT last_name,COUNT(actor_id) AS actor_count FROM actor GROUP BY last_name) AS actor_counts
WHERE actor_count > 1;

#4c
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#4d actor_id for harpo williams = 172
UPDATE actor
SET first_name = IF(first_name='HARPO','GROUCHO','MUCHO GROUCHO')
WHERE actor_id = 172;

###### 5
#5a
SHOW CREATE TABLE address;


###### 6
#6a
SELECT s.`first_name`,s.`last_name`,a.`address` FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

#6b
SELECT su.first_name,su.last_name,SUM(p.amount) FROM staff AS su
LEFT JOIN payment AS p
ON su.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY first_name;

#6c
SELECT f.title,COUNT(fa.actor_id) AS actor_count
FROM film f
RIGHT JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.title;

#6d
SELECT COUNT(film_id) AS number_of_copies
FROM inventory
WHERE film_id = (
	SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
);

#6e
SELECT c.first_name,c.last_name,SUM(p.amount) AS total_paid
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY first_name;

###### 7
#7a
SELECT title,language_id
FROM film
WHERE title LIKE 'K%' OR title LIKE'Q%' AND language_id 
IN(
	SELECT language_id
	FROM language
	WHERE name='English'
    );
    
    
#7b
SELECT *
FROM actor
WHERE actor_id
IN(
	SELECT actor_id
	FROM film_actor 
	WHERE film_id
	IN(
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
	)
);


#7c
SELECT customer.first_name,customer.last_name,customer.email
FROM customer
JOIN (
	SELECT address_id
	FROM address a
	JOIN (
		SELECT ci.city_id
		FROM country co
		JOIN city ci
		ON co.country_id = ci.country_id
		WHERE co.country = 'Canada'
	) AS cityID
	ON cityID.city_id = a.city_id
) AS addressID
ON addressID.address_id = customer.address_id; 


#7d
SELECT f.title
FROM film AS f
JOIN (
	SELECT fid.film_id
	FROM film_category AS fid
	JOIN (
		SELECT category_id
		FROM category
		WHERE name='Family'
	) AS cid
	ON cid.category_id = fid.category_id
) AS filmIDs
ON filmIDs.film_id = f.film_id;


#7e
SELECT film.title,f_id.count
FROM film
JOIN (
	SELECT i.film_id,SUM(i_id.count) AS count
	FROM inventory i
	JOIN(
		SELECT inventory_id,COUNT(rental_id) AS Count
		FROM rental
		GROUP BY inventory_id
	) as i_id
	ON i_id.inventory_id = i.inventory_id
	GROUP BY film_id
) AS f_id
ON film.film_id= f_id.film_id
ORDER BY count DESC;
#7f
SELECT store_id,sum(amount)
FROM inventory i
JOIN (
	SELECT inventory_id,SUM(amount) as amount
	FROM rental
	JOIN (
		SELECT rental_id,amount
		FROM payment
	) AS r_id
	ON rental.rental_id = r_id.rental_id
	GROUP BY rental.inventory_id
) AS i_id
ON i_id.inventory_id = i.inventory_id
GROUP BY store_id;


#7g
SELECT coid.store_id,coid.city,co.country
FROM country co
JOIN (
	SELECT cid.store_id,c.city,c.country_id
	FROM city c
	JOIN (
		SELECT aid.store_id, a.city_id
		FROM address a
		JOIN (
			SELECT store_id,address_id
			FROM store
		) AS aid
		ON a.address_id = aid.address_id
	) AS cid
	ON cid.city_id = c.city_id
) AS coid
ON coid.country_id = co.country_id;


#7h
SELECT cat.name AS Genre, SUM(c_id.amount) AS Total
FROM category cat
JOIN (
	SELECT f.category_id, SUM(f_id.amount) AS amount
	FROM film_category as f
	JOIN (
		SELECT i.film_id, SUM(i_id.amount) AS amount
		FROM inventory i
		JOIN (
			SELECT inventory_id,SUM(amount) AS amount
			FROM rental
			JOIN (
				SELECT rental_id,amount
				FROM payment
			) AS r_id
			ON rental.rental_id = r_id.rental_id
			GROUP BY rental.inventory_id
		) AS i_id
		ON i_id.inventory_id = i.inventory_id
		GROUP BY film_id
	) AS f_id
	ON f_id.film_id = f.film_id
	GROUP BY category_id
) AS c_id
ON c_id.category_id = cat.category_id
GROUP BY name
ORDER BY Total DESC LIMIT 5;


###### 8
#8a
CREATE OR REPLACE VIEW Top_5_Grossing_Categories AS
SELECT *
FROM (
SELECT cat.name AS Genre, SUM(c_id.amount) AS Total
FROM category cat
JOIN (
	SELECT f.category_id, SUM(f_id.amount) AS amount
	FROM film_category as f
	JOIN (
		SELECT i.film_id, SUM(i_id.amount) AS amount
		FROM inventory i
		JOIN (
			SELECT inventory_id,SUM(amount) AS amount
			FROM rental
			JOIN (
				SELECT rental_id,amount
				FROM payment
			) AS r_id
			ON rental.rental_id = r_id.rental_id
			GROUP BY rental.inventory_id
		) AS i_id
		ON i_id.inventory_id = i.inventory_id
		GROUP BY film_id
	) AS f_id
	ON f_id.film_id = f.film_id
	GROUP BY category_id
) AS c_id
ON c_id.category_id = cat.category_id 
GROUP BY name 
ORDER BY Total DESC LIMIT 5 
) AS top_5;

#8b
SHOW CREATE VIEW Top_5_Grossing_Categories;


#8c
DROP VIEW Top_5_Grossing_Categories;
