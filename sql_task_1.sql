--1.Display the number of films in each category, sorted in descending order.
SELECT c.name, COUNT(film_id) AS number_of_films
FROM film_category
    JOIN category c USING(category_id)
GROUP BY c.name
ORDER BY COUNT(film_category.film_id) DESC;

--2.Display the top 10 actors whose films were rented the most, sorted in descending order.
SELECT a.first_name, a.last_name, COUNT(r.rental_id) AS number_of_rentals
FROM actor a
    JOIN film_actor fa USING(actor_id)
    JOIN inventory i USING(film_id)
    JOIN rental r USING(inventory_id)
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY number_of_rentals DESC
LIMIT 10;

--3.Display the category of films that generated the highest revenue.
WITH category_revenue AS (
    SELECT c.name, SUM(p.amount) AS revenue
                          FROM category c
                                   JOIN film_category fc USING (category_id)
                                   JOIN inventory i USING (film_id)
                                   JOIN rental r USING (inventory_id)
                                   JOIN payment p USING (rental_id)
                          GROUP BY c.name
                          )
            --created CTE for calculating revenue per category,
            --then ranked all categories by revenue in order to consider cases
            --when two+ categories have the same highest revenue
SELECT name, revenue
FROM (
        SELECT name,
               revenue,
               DENSE_RANK() OVER (ORDER BY revenue DESC) AS ranking
        FROM category_revenue
     ) AS ranked
WHERE ranking = 1;

--4. Display the titles of films not present in the inventory. Write the query without using the IN operator.
SELECT f.title
FROM film f
    LEFT JOIN inventory i USING (film_id)
WHERE i.film_id IS NULL;

--5. Display the top 3 actors who appeared the most in films within the "Children" category.
--If multiple actors have the same count, include all.
WITH actor_appearances AS (
    SELECT a.first_name, a.last_name, COUNT(fc.film_id) AS appearances
    FROM actor a
             JOIN film_actor fa USING (actor_id)
             JOIN film f USING (film_id)
             JOIN film_category fc USING (film_id)
             JOIN category c USING (category_id)
    WHERE c.name = 'Children'
    GROUP BY a.actor_id
)
SELECT first_name, last_name, appearances
FROM (
         SELECT first_name,
                last_name,
                appearances,
                DENSE_RANK() OVER (ORDER BY appearances DESC) AS ranking
         FROM actor_appearances
     ) AS ranked
WHERE ranking <= 3;

--6. Display cities with the count of active and inactive customers (active = 1).
--Sort by the count of inactive customers in descending order.
SELECT ci.city,
       SUM(CASE WHEN c.active = 1 THEN 1 ELSE 0 END) AS active_customers,
       SUM(CASE WHEN c.active = 0 THEN 1 ELSE 0 END) AS inactive_customers
FROM customer c
    JOIN address a USING (address_id)
    JOIN city ci USING (city_id)
GROUP BY ci.city
ORDER BY inactive_customers DESC;

--7. Display the film category with the highest total rental hours in cities where customer.address_id belongs to that city
-- and starts with the letter "a". Do the same for cities containing the symbol "-". Write this in a single query.
(
WITH category_revenue AS (SELECT cat.name,
                                  ROUND(SUM(EXTRACT(EPOCH FROM (r.return_date - r.rental_date) / 3600)),
                                        2) AS total_rental_hours
                           FROM category cat
                                    JOIN film_category fc ON cat.category_id = fc.category_id
                                    JOIN film f ON fc.film_id = f.film_id
                                    JOIN inventory i ON f.film_id = i.film_id
                                    JOIN rental r ON i.inventory_id = r.inventory_id
                                    JOIN customer cust ON r.customer_id = cust.customer_id
                                    JOIN address a ON cust.address_id = a.address_id
                                    JOIN city c ON a.city_id = c.city_id
                           WHERE city LIKE '%-%'
                           GROUP BY cat.category_id, cat.name)
 SELECT name,
        total_rental_hours
 FROM (SELECT *,
              DENSE_RANK() OVER (ORDER BY total_rental_hours DESC) AS ranking
       FROM category_revenue) AS ranked
 WHERE ranking = 1
 )

UNION ALL

(
    WITH category_revenue AS (SELECT cat.name,
                                     ROUND(SUM(EXTRACT(EPOCH FROM (r.return_date - r.rental_date) / 3600)),
                                           2) AS total_rental_hours
                              FROM category cat
                                       JOIN film_category fc ON cat.category_id = fc.category_id
                                       JOIN film f ON fc.film_id = f.film_id
                                       JOIN inventory i ON f.film_id = i.film_id
                                       JOIN rental r ON i.inventory_id = r.inventory_id
                                       JOIN customer cust ON r.customer_id = cust.customer_id
                                       JOIN address a ON cust.address_id = a.address_id
                                       JOIN city c ON a.city_id = c.city_id
                              WHERE city LIKE 'a%'
                              GROUP BY cat.category_id, cat.name)
    SELECT name,
           total_rental_hours
    FROM (SELECT *,
                 DENSE_RANK() OVER (ORDER BY total_rental_hours DESC) AS ranking
          FROM category_revenue) AS ranked
    WHERE ranking = 1
);
