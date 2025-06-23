-- 1. List the movie titles along with their IMDb ratings and meta scores.
select m.title,r.imdb_rating,r.meta_score from movies m join ratings r on m.movie_id = r.movie_id;

-- 2. Find all movies along with their genre names.
select m.title,g.genre_name 
from movies m join moviegenres mg 
on mg.movie_id=m.movie_id 
join genres g 
on mg.genre_id=g.genre_id;


-- 3. List the top 10 movies (by IMDb rating) along with their directors names.
select m.title,p.name,r.imdb_rating from movies m join moviedirectors md
on 
	md.movie_id = m.movie_id
join 
	ratings r
on
	r.movie_id=m.movie_id
join
	people p 
on
	p.person_id = md.person_id
order by r.imdb_rating desc  limit 10;

-- ✅4. Find all movies in the "Drama" genre along with their year of release and IMDb rating.
select m.title,m.release_year,r.imdb_rating,g.genre_name
from movies m 
join 
	moviegenres mg
on 
	mg.movie_id = m.movie_id
join 
	ratings r 
on
	r.movie_id = m.movie_id	
join
	genres g
on
	g.genre_id = mg.genre_id
where g.genre_name = 'Drama'

-- 5. List movies that have more than one genre associated with them. Show title and number of genres.
select m.title, count(mg.genre_id) as no_of_genre,array_agg(g.genre_name) as genre from movies m 
join moviegenres mg
on m.movie_id = mg.movie_id
join genres g
on mg.genre_id =g.genre_id
Group by m.title 
having count(mg.genre_id)  >1 

-- 6. Get the names of all actors who starred in movies released before the year 2000.
select p.name , m.release_year from people p 
join moviestars ms 
on ms.person_id = p.person_id
join movies m 
on m.movie_id = ms.movie_id
where m.release_year < 2000;

-- 7. Find all movies that were directed by someone who also acted in the same movie. List title and person's name.
select m.title,p.name from movies m 
join moviedirectors md
on md.movie_id = m.movie_id
join moviestars ms 
on ms.person_id = md.person_id and ms.movie_id = m.movie_id
join people p 
on p.person_id = md.person_id

-- 8. List each genre and the average IMDb rating of movies in that genre.
select g.genre_name,avg(r.imdb_rating) from ratings r 
join moviegenres mg
on r.movie_id = mg.movie_id
join genres g
on g.genre_id = mg.genre_id
Group by g.genre_name

-- 9. Find the movie(s) with the highest number of stars (actors). List title and number of stars.
with movie_star_count as (
	select m.title,count(ms.person_id) as no_of_actors 
	from movies m 
	join moviestars ms 
	on m.movie_id = ms.movie_id
	group by m.title
),
max_count as(
	select max(no_of_actors) as max_movie from movie_star_count
)
select msc.title,msc.no_of_actors from movie_star_count msc join max_count mc on mc.max_movie = msc.no_of_actors

-- 10. List all directors along with the count of movies they directed that have an IMDb rating above 8.5.
select p.name,count(r.imdb_rating),string_agg(m.title,', ') from people p 
join moviedirectors md
on md.person_id = p.person_id
join ratings r
on md.movie_id = r.movie_id
join movies m
on m.movie_id = md.movie_id
where r.imdb_rating > 8.5 
group by p.name  

-- joins Question

-- 1. List the top 3 genres with the highest average IMDb rating.
select g.genre_name,count(r.imdb_rating) 
from ratings r 
join moviegenres mg 
on mg.movie_id = r.movie_id
join genres g 
on g.genre_id = mg.genre_id
group by g.genre_name 
order by count(r.imdb_rating) desc limit 3

-- 2. For each actor, list their name along with the number of movies they have starred in and their average movie rating (IMDb).
select p.name as actors_name,count(m.movie_id) as no_of_movies,avg(r.imdb_rating) as ratings 
from movies m 
join ratings r 
on r.movie_id = m.movie_id
join moviestars ms
on ms.movie_id = r.movie_id
join people p
on p.person_id = ms.person_id
group by p.name
-- 3. Find all movies that have the same director and at least one of the same stars as another movie. List both movies and the shared person's name.
-- 4. Rank all movies within each genre based on IMDb rating (highest first). Show genre, title, rating, and rank.
select m.title, r.imdb_rating, g.genre_name, Rank() over (Partition by g.genre_name order by r.imdb_rating desc)
from movies m 
join ratings r 
on r.movie_id = m.movie_id
join moviegenres mg
on m.movie_id = mg.movie_id
join genres g
on g.genre_id = mg.genre_id
ORDER BY 
    g.genre_name, rank;

-- 5. Find directors who have directed movies across at least 3 different genres.
select p.name, count(distinct mg.genre_id) from  movies m 
join moviedirectors md
on md.movie_id = m.movie_id
join people p
on p.person_id = md.person_id
join moviegenres mg
on mg.movie_id = m.movie_id
group by p.name 
having count(distinct mg.genre_id) >=3

-- 6. For each year, find the movie with the highest IMDb rating. Show title, year, and rating.
with year_max_rating as (
	select m.release_year,max(r.imdb_rating) as max_year
	from movies m
	join ratings r
	on m.movie_id = r.movie_id
	group by m.release_year
)
Select m.title,m.release_year,r.imdb_rating
from movies m 
join ratings r 
on m.movie_id = r.movie_id
join year_max_rating y
on y.max_year = r.imdb_rating and y.release_year = m.release_year
order by m.release_year

-- 7. List all actors who have only starred in movies rated above 8.5.
with movie_above_rating as(
	select m.title,m.movie_id, r.imdb_rating as rating
	from movies m 
	join ratings r 
	on m.movie_id = r.movie_id
	where r.imdb_rating > 8.5
)
select p.name,m.title,r.imdb_rating from ratings r
join movies m
on r.movie_id = m.movie_id
join moviestars ms
on m.movie_id = ms.movie_id
join people p
on p.person_id = ms.person_id
join movie_above_rating mar
on mar.movie_id = ms.movie_id

-- 8. Find the most frequently cast actor-director pair (i.e., actor and director who worked together the most times).
select md.person_id as dn,ms.person_id as sn,count(*) as movie_count from moviestars ms
join moviedirectors md on md.movie_id = ms.movie_id
group by md.person_id,ms.person_id
order by count(*) desc  

-- 9. List all movies where the difference between IMDb rating and Meta score is more than 20.
select m.title,(r.imdb_rating*10) - r.meta_score as difference from movies m
join ratings r on r.movie_id = m.movie_id
where (r.imdb_rating*10) - r.meta_score >20
order by (r.imdb_rating*10) - r.meta_score desc


-- 10. For each genre, list the most prolific actor (the one who starred in the most movies in that genre).
with tem as(select g.genre_name,p.name as actors,count(distinct m.movie_id) as movie_count,
	Rank() over(Partition by g.genre_name order by count(distinct m.movie_id) desc) as rnk
	from movies m join moviestars ms on ms.movie_id = m.movie_id
	join moviegenres mg on mg.movie_id = m.movie_id
	join people p on p.person_id = ms.person_id
	join genres g on mg.genre_id = g.genre_id
	group by g.genre_name,p.name
)
select genre_name,actors,movie_count from tem where rnk =1 order by genre_name