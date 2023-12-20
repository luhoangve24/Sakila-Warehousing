SELECT b.payment_id, COUNT(b.rental_id) as rental
FROM rental AS a RIGHT JOIN payment AS b ON a.rental_id = b.rental_id
GROUP BY b.payment_id
ORDER BY rental DESC;

SELECT * FROM customer;
SELECT * FROM rental;
---
SELECT * FROM inventory;
SELECT inventory_in_stock(9);

SELECT b.film_id, COUNT(b.film_id) as Qty
FROM inventory as a JOIN film as b ON a.film_id = b.film_id
GROUP BY b.film_id;

SELECT * FROM store;
SELECT * FROM staff;
---
SELECT p.amount as 'Tổng tiền', r.rental_date as 'Ngày mượn' ,r.return_date as 'Ngày trả', p.payment_date as 'Trả tiền vào', f.title, f.rental_duration, f.rental_rate, f.replacement_cost
FROM payment as p, rental as r, inventory as i, film as f
WHERE p.rental_id = r.rental_id AND r.inventory_id = i.inventory_id AND i.film_id = f.film_id;

SELECT * FROM sakila.category;

-- Denormalize film
SELECT f.film_id, f.title, f.description, f.release_year, l.name, f.rental_duration, f.rental_rate, f.length, f.replacement_cost, f.rating, c.name,
	CASE
	WHEN FIND_IN_SET('Deleted Scenes', special_features) > 0 THEN 't'
    ELSE 'f'
    END AS 'Deleted Scenes Col',
    CASE
	WHEN FIND_IN_SET('Behind the Scenes', special_features) > 0 THEN 't'
    ELSE 'f'
    END AS 'Behind the Scenes Col',
    CASE
	WHEN FIND_IN_SET('Commentaries', special_features) > 0 THEN 't'
    ELSE 'f'
    END AS 'Commentaries Col',
    CASE
    WHEN FIND_IN_SET('Trailers', special_features) > 0 THEN 't'
    ELSE 'f'
	END AS 'Trailers Col'
FROM film as f
    join language as l on f.language_id = l.language_id
    join film_category as fc on f.film_id = fc.film_id
    join category as c on fc.category_id = c.category_id;

SELECT film_id, COUNT(film_id) FROM film_category GROUP BY film_id;

SELECT * FROM film_text;
-- SELECT MAX(YEAR(payment_date)), MIN(YEAR(payment_date)) FROM sakila.payment;

select * from sakila.store;
select * from sakila.customer;

-- Testing Set
SELECT title, special_features,
	CASE
	WHEN FIND_IN_SET('Deleted Scenes', special_features) > 0 THEN 'Deleted Scenes'
    ELSE null
    END AS 'Deleted Scenes Col',
    CASE
	WHEN FIND_IN_SET('Behind the Scenes', special_features) > 0 THEN 'Behind the Scenes'
    ELSE null
    END AS 'Behind the Scenes Col',
    CASE
	WHEN FIND_IN_SET('Commentaries', special_features) > 0 THEN 'Commentaries'
    ELSE null
    END AS 'Commentaries'
FROM film;

-- Denormalize Store
SELECT s.store_id, a.address, a.district, a.postal_code, a.phone, c.city, ct.country, s.manager_staff_id, st.first_name, st.last_name
FROM store as s join address as a on s.address_id = a.address_id
	join city as c on a.city_id = c.city_id
    join country as ct on c.country_id = ct.country_id
    join staff as st on s.manager_staff_id = st.staff_id;
    
SELECT * FROM address;
select * from sakila.film;
-- Denormalize Customer
SELECT c.customer_id, c.first_name,c.last_name, c.email, c.active, c.create_date, a.address, a.district, a.postal_code, a.phone, ct.city, ctr.country
FROM customer as c join address as a on c.address_id = a.address_id
	join city as ct on a.city_id = ct.city_id
    join country as ctr on ct.country_id = ctr.country_id;
-- TRUNCATE TABLE customer_dim;
SELECT * FROM customer_dim;

-- Denormalize Staff
SELECT s.staff_id, s.first_name, s.last_name, 
	s.email, s.store_id, s.active, st.manager_staff_id
FROM staff as s join store as st on s.store_id = st.store_id or s.staff_id = st.manager_staff_id;

SELECT * FROM store_dim;

-- Denormalize Facts Sales
SELECT r.rental_id, r.customer_id, r.staff_id, i.film_id, r.rental_date, r.return_date, p.amount, p.payment_date
FROM rental as r join payment as p on r.rental_id = p.rental_id
join inventory as i on r.inventory_id = i.inventory_id
join film as f on f.film_id = i.film_id;

SELECT r.rental_id,s.staff_id,count(r.rental_id)
FROM staff as s join rental as r on r.staff_id = s.staff_id
GROUP BY r.rental_id, s.staff_id;
/*
rental_id,
---
customer_id, 
staff_id,
rental_date, 
return_date,
payment_date, 
amount
rental_rate
rental_duration*/

SELECT * FROM 
	fact_sales2 as fs JOIN date_dim as dd
    ON fs.payment_date_key = dd.Date_Key
    WHERE Holiday_Flag = 't';
    
SELECT rental_rate FROM film_dim GROUP BY rental_rate;