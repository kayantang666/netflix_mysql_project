# Netflix Movies and TV Shows Data Analysis using MySQL

![Netflix_Logo](https://github.com/kayantang666/netflix_mysql_project/blob/main/netflix_logo.png)

## Overview
This project performs an in-depth business analysis of the Netflix dataset using MySQL. By querying and exploring the dataset, the goal is to highlight important patterns in Netflix’s content strategy and provide actionable insights. The analysis answers targeted business questions about audience preferences, production trends, and catalog distribution. This README outlines the project’s goals, key queries, results, and overall conclusions.

## Objectives
- Content Type Distribution – Compare the proportion of movies vs. TV shows.
- Ratings Analysis – Identify the most frequent content ratings across categories.
- Release Trend - Analyze content trends by year, country, and duration.
- Content Theme - Identify trends and group content based on themes or keywords.

## Dataset
The data for this project is from the Kaggle dataset:
- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
   show_id      VARCHAR(5) NOT NULL PRIMARY KEY
  ,type         VARCHAR(7) NOT NULL
  ,title        VARCHAR(104) NOT NULL
  ,director     VARCHAR(208)
  ,cast         VARCHAR(771)
  ,country      VARCHAR(123)
  ,date_added   VARCHAR(19)
  ,release_year INTEGER  NOT NULL
  ,rating       VARCHAR(8)
  ,duration     VARCHAR(10)
  ,listed_in    VARCHAR(79) NOT NULL
  ,description  VARCHAR(250) NOT NULL
);
```
## 15 Business Questions to extract insights

### 1. Compare the number of movies (6131 movies) and TV shows (2676 TV shows) in the dataset
```sql
SELECT
	type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type;
```

### 2. Show the most frequent maturity ratings for movies and TV shows -- TV-MA
```sql
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
```

