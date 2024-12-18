DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);




select * from [netflix_db].[dbo].[data_of_netflix]

--1. Count the Number of Movies vs TV Shows
select type, count(*) as shows
from netflix_db.dbo.data_of_netflix
group by type

--. Find the Most Common Rating for Movies and TV Shows

with netflix_data AS(
      SELECT type, 
		     rating,
			 COUNT(*) AS counts,
			 RANK() OVER(PARTITION BY type order by COUNT(*)DESC ) as ranking
			 FROM [netflix_db].[dbo].[data_of_netflix]
              GROUP BY type,rating
) 
select type,rating 
from netflix_data 
where ranking = 1



               


 SELECT type,
        rating
from 
 (select type,
		 rating,
		COUNT(*)as counts,
        RANK() OVER(PARTITION BY type order by count(*) DESC) as ranking 
        from [netflix_db].[dbo].[data_of_netflix]
         group by type,rating   
	) AS t2
	where ranking = 1

--3. List All Movies Released in a Specific Year (e.g., 2020)
select *
 from [netflix_db].[dbo].[data_of_netflix]
 where release_year = 2020

 --4. Find the Top 5 Countries with the Most Content on Netflix
 Select TOP 5 *
 from
  (select Value as country,count(show_id) as counts
 from [netflix_db].[dbo].[data_of_netflix]
 CROSS APPLY STRING_SPLIT(country,',')
 group by value
 ) as t2
 where country IS NOT NULL
 ORDER BY counts DESC 

--5. Identify the Longest Movie
SELECT * from [netflix_db].[dbo].[data_of_netflix]
where type = 'Movie'
AND duration = (select max(duration) from [netflix_db].[dbo].[data_of_netflix])

--6. Find Content Added in the Last 5 Years
select * from [netflix_db].[dbo].[data_of_netflix]
where CONVERT(date,date_added,101) >= DATEADD(year,-5, GETDATE())

--Find All Movies/TV Shows by Director 'Rajiv Chilaka

select *from [netflix_db].[dbo].[data_of_netflix]
where director LIKE'%Rajiv chilaka%'

--8. List All TV Shows with More Than 5 Seasons

select * from [netflix_db].[dbo].[data_of_netflix]
where type = 'TV Show'
AND 
CAST(SUBSTRING(duration,1,CHARINDEX(' ',duration)-1) AS INT) > 5

--. Count the Number of Content Items in Each Genre
SELECT value as listed_in, count(*) as total
FROM [netflix_db].[dbo].[data_of_netflix] 
CROSS APPLY STRING_SPLIT(listed_in,',')
group by value

--10.Find each year and the average numbers of content release in India on netflix.
select YEAR(CONVERT(date, date_added,101)) as years,
        count(*) as yealy_content,
		ROUND(
		     cast(count(*) as numeric)/
			 cast((select count(*) 
			 from netflix_db.dbo.data_of_netflix 
			 where country = 'India')as numeric)*100
		     ,2) AS AVG_CONTENT_YEAR
from [netflix_db].[dbo].[data_of_netflix] 
where country = 'India'
group by YEAR(CONVERT(date, date_added,101))

--11. List All Movies that are Documentaries
select * from [netflix_db].[dbo].[data_of_netflix]
where listed_in LIKE '%Documentaries%'

--12. Find All Content Without a Director
select * from [netflix_db].[dbo].[data_of_netflix]
where director IS NOT NULL

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * FROM [netflix_db].[dbo].[data_of_netflix]
WHERE cast LIKE '%Salman khan%' 
 AND
 release_year > YEAR(DATEADD(year,-10,getdate()))

 --14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT TOP 10 value as cast, count(*) as number_of_movies
from [netflix_db].[dbo].[data_of_netflix]
CROSS APPLY string_split(cast,',')
WHERE country LIKE '%India'
group by value 
order by 2 DESC

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
with new_table
AS 
(
select *,
     CASE
	    WHEN description LIKE '%kill%' OR description LIKE '%violence%'
		THEN 'Bad_content'
		ELSE 'Good_content'
		END Category
 from [netflix_db].[dbo].[data_of_netflix]
 ) 
 SELECT category, 
         count(*) as contents
		 from new_table
		 group by Category