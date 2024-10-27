/*
1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

*/

use netflix_db;
show tables;
desc netflix;
select * from netflix;


/*
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';


LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/

-- 1. Count the number of Movies vs TV Shows
 SELECT type,count(*) FROM netflix group by type;

-- 2. Find the most common rating for movies and TV shows
select type,rating,ranks
from(
SELECT type,rating,count(* )num_of_ratings ,rank() over(partition by type order by count(*)desc) ranks
FROM netflix group by type,rating  order by type,num_of_ratings desc  
) as t1
where ranks =1;

-- 3. List all movies released in a specific year (e.g., 2020)

 SELECT * FROM netflix where release_year=2020 and type="Movie";
 
-- 4. Find the top 5 countries with the most content on Netflix

 SELECT country,count(*) counts FROM netflix group by country  order by counts desc;
 
   SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1) as new_country,
    COUNT(show_id) as total_content
FROM netflix
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;
-- --------------------------------
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 
    UNION ALL SELECT 4 UNION ALL SELECT 5 -- Adjust based on max commas in `country`
) n ON LENGTH(country) - LENGTH(REPLACE(country, ',', '')) >= n.n - 1
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * FROM netflix where type="Movie" and duration=(
SELECT 
    max(convert(REPLACE(duration, 'min', '') , UNSIGNED))
FROM netflix);


-- 6. Find content added in the last 5 years

 alter table netflix 
 modify column  date_added DATE;
 
select * from netflix where date_added>= curdate()-interval 5 year order by date_added desc ;

 select * from netflix  ;
 
 -- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
 
 select * from netflix where director like '%ajiv Chilaka%';
 
--  8. List all TV shows with more than 5 seasons

 select show_id,type,title,convert(substr(duration,1,1),UNSIGNED) num_seasons from netflix  
 where duration like "%Seaso%"  
 Having num_seasons>5;
 
 SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 
    UNION ALL SELECT 4 UNION ALL SELECT 5 -- Adjust based on max genres per row
) n ON LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', '')) >= n.n - 1
GROUP BY genre;

 
--  9. Count the number of content items in each genre

SELECT show_id,title,listed_in,
    LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))+1 AS count_of_genre
FROM netflix; 

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
    country,
    year (date_added) years,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, 2
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries

select * from netflix where  type='Movie' and listed_in like '%Documentaries%';

-- 12. Find all content without a director
select  *  from netflix where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select  *  from netflix 
where casts like '%Salman Khan%' 
and release_year >= year (curdate()-interval 10 year) ;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(n.casts, ',', numbers.n), ',', -1)) AS actor,
  COUNT(*) AS actor_count
FROM netflix n
JOIN (
  SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 
  UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 
  UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 
  UNION ALL SELECT 10  UNION ALL SELECT 11  UNION ALL SELECT 12  UNION ALL SELECT 13
) numbers
  ON CHAR_LENGTH(n.casts) - CHAR_LENGTH(REPLACE(n.casts, ',', '')) >= numbers.n - 1
WHERE n.country = 'India'
GROUP BY actor
ORDER BY actor_count DESC
LIMIT 10;


-- using RECURSIVE 
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 50
)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(n.casts, ',', numbers.n), ',', -1)) AS actor,
    COUNT(*) AS actor_count
FROM netflix n
JOIN numbers 
  ON CHAR_LENGTH(n.casts) - CHAR_LENGTH(REPLACE(n.casts, ',', '')) >= numbers.n - 1
WHERE n.country = 'India'
GROUP BY actor
ORDER BY actor_count DESC
LIMIT 10;



/*
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

*/

with good_bad as(
select *,
case   
	when description like '%kill%'  or
	description like '%violence%' then 'bad' else 'good' end counts
from netflix )
select counts,count(*)
from good_bad
group by counts;