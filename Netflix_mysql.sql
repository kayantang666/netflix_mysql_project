-- Import Dataset
USE netflix;

-- Understand Data Structure --
-- 1. View whole dataset
SELECT * FROM netflix;

-- 2. Total rows of the dataset (8807 rows)
SELECT
	COUNT(*) as total_row
FROM netflix;

-- 3. Types of Netflix content that we are analyzing (Movie vs. TV Show)
SELECT
	DISTINCT type
FROM netflix;


-- 15 Business Questions to extract insights -- 
-- 1. Compare the number of movies (6131 movies) and TV shows (2676 TV shows) in the dataset
SELECT
	type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- 2. Show the most frequent maturity ratings for movies and TV shows -- TV-MA
SELECT
	type,
    rating
FROM
(	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2
) as t1
WHERE
	ranking = 1;

-- 3. List all movies released in year 2021
SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2021;

-- 4. List the top 5 countries with the highest number of movies and TV shows on Netflix 
SELECT
	SUBSTRING_INDEX(country, ',', 1) AS new_country,
    COUNT(show_id) as total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Find the movie with the longest duration
SELECT 
    title,
    duration,
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS minutes
FROM netflix
WHERE type = 'Movie'
     AND duration IS NOT NULL
ORDER BY minutes DESC
LIMIT 1;

-- 6. Show content added to Netflix within the past 5 years
SELECT * 
FROM netflix
WHERE STR_TO_DATE(date_added, '%d-%b-%Y') >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR)
AND date_added IS NOT NULL;

-- 7. Find all the movies and TV shows that are produced by director 'Chris Buck'
SELECT * FROM netflix
WHERE director LIKE '%Chris Buck%';

-- 8. Identify TV shows with over 3 seasons
SELECT * 
FROM netflix
WHERE 
    type = 'TV Show'
    AND 
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 3;
    
-- 9. Break down the content by genre with counts
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
JOIN 
    (SELECT 1 AS n 
     UNION ALL SELECT 2 
     UNION ALL SELECT 3 
     UNION ALL SELECT 4 
     UNION ALL SELECT 5) n
ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n.n - 1
GROUP BY 1;

-- 10. Show United State's top 5 most content years on Netflix, ranked by average releases
SELECT
	YEAR(STR_TO_DATE(date_added, '%d-%b-%Y')) AS year,
    COUNT(*) AS total_content,
    ROUND(COUNT(*) * 100 /(SELECT COUNT(*) FROM netflix WHERE country LIKE "%United States%")
    ,2) as avg_content_per_year
FROM netflix
WHERE country LIKE "%United States%"
GROUP BY 1
ORDER BY 
    avg_content_per_year DESC
LIMIT 5;

-- 11. List all documentary movies
SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%documentaries%';

-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

-- 13. List all movies that the actor 'Sourav Chakraborty' starred in last 10 years
SELECT * FROM netflix
WHERE cast LIKE '%Sourav Chakraborty%'
	AND release_year > YEAR(CURRENT_DATE()) - 10
    AND type = 'Movie';

-- 14. List top 10 actors who appeared most often in United States movies
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1)) AS actors,
    COUNT(show_id) AS total_content
FROM netflix
JOIN 
    (SELECT 1 AS n 
     UNION ALL SELECT 2 
     UNION ALL SELECT 3 
     UNION ALL SELECT 4 
     UNION ALL SELECT 5) n
ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) >= n.n - 1
WHERE country LIKE '%United States%' AND cast IS NOT NULL AND type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize content as 'Violent Content' if descriptions contain 'kill' or 'violence', and the rest as 'Non-violent Content', and count items in each category
WITH new_table
AS
(
SELECT *,
	CASE
    WHEN
		description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Violent Content'
        ELSE 'Non-violent Content'
	END category
FROM netflix
)
SELECT
	category,
    COUNT(*) as total_content
FROM new_table
GROUP BY 1;
