#Query_1
select count(distinct(ps.work_id)) from product_size as ps
inner join work as w
on ps.work_id = w.work_id
where w.museum_id is null;

#Query_2
select count(distinct(m.museum_id)) from museum as m
left join work as w
on m.museum_id = w.museum_id
where w.work_id is null;

#Query_3
select count(work_id) from product_size
where sale_price > regular_price;

#Query_4
select count(work_id) from product_size
where sale_price < (regular_price*0.5);

#Query_5
select * from canvas_size as cs
where size_id = (select size_id from product_size where sale_price = (select max(sale_price) from product_size));

select cs.label as canva,ps.sale_price from canvas_size as cs
inner join product_size as ps
on cs.size_id = ps.size_id
order by ps.sale_price desc
limit 1;

select cs.label as canva, ps.sale_price from (select *,rank() over(order by sale_price desc) as rank_order from product_size) as ps
inner join canvas_size as cs
on ps.size_id = cs.size_id
where ps.rank_order = 1;

#Query_6

#deleting duplicate records from product_size
alter table product_size add column temp int auto_increment unique key;
delete from product_size
where temp not in (
				select min(temp) from product_size
                group by work_id,size_id,sale_price,regular_price
                having count(*) > 1);
alter table product_size drop column temp;

#deleting duplicate records from subjcet
                 
alter table subjcet add column temp int auto_increment unique key;
delete from subject
where temp not in (
				select min(temp) from subject
                group by work_id,subject
                having count(*) > 1);
alter table subject drop column temp;

#deleting duplicate records from image_link

alter table image_link add column temp int auto_increment unique key;
delete from image_link
where temp not in (
				select min(temp) from image_link
                group by work_id,url,thumbnail_large_url,thumbnail_small_url
                having count(*) > 1);
alter table image_link drop column temp;


#Query_7
select * from museum
where left(city,1) in ("0","1","2","3","4","5","6","7","8","9");

#Query_8
#Query_9
SELECT subject,count(*) as no_of_paintings FROM paintings.subject
group by subject
order by count(*) desc
limit 10;
#Query_10
with x as (select museum_id from museum_hours 
where day = "Sunday" or day = "Monday"
group by museum_id
having count(*) = 2)
select m.name as museum_name,m.city from museum as m
join x on x.museum_id = m.museum_id;
#Query_11
SELECT museum_id,count(*) as Working_days_in_week FROM paintings.museum_hours
group by museum_id
having count(*) = 7;
#Query_12
with x as (select museum_id,count(*) as no_of_paintings from work
group by museum_id
order by count(*) desc
limit 5)

select m.*,no_of_paintings from museum as m
join x on x.museum_id = m.museum_id;
#Query_13
with x as (select artist_id,count(*) as no_of_paintings from work
group by artist_id
order by count(*) desc
limit 5)
select a.*,no_of_paintings from artist as a
join x on x.artist_id = a.artist_id;
#Query_14
SELECT label, ranking, no_of_paintings
FROM (
  SELECT cs.size_id, cs.label, COUNT(*) AS no_of_paintings,
         DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
  FROM work w
  JOIN product_size ps ON ps.work_id = w.work_id
  JOIN canvas_size cs ON cs.size_id = ps.size_id
  GROUP BY cs.size_id, cs.label
) AS x
WHERE x.ranking <= 3;
#Query_15
select m.name,m.state, mh.day, mh.open-mh.close as long_e
from museum_hours mh
JOIN museum m
ON mh.museum_id = m.museum_id
order by mh.open - mh.close desc
limit 1
;
#Query_16
select m.name as museum_name,m.city,m.country,w.style as painting_style from museum as m
join work as w on w.museum_id = m.museum_id
join 
(select style from work
where style != ""
group by style 
order by count(*) desc
limit 3) as ts on w.style = ts.style;
#Query_17
with x as (select w.artist_id,count(m.country) as c from work as w
inner join museum as m on w.museum_id = w.museum_id
group by w.artist_id
having count(*) > 1)
select a.full_name as artist_name,x.c as no_of_countries
from artist as a
inner join x on x.artist_id = a.artist_id
order by no_of_countries desc;
#Query_18
with x as (select country,count(*),rank() over(order by count(*) desc) as rank_order
from museum group by country),
y as (select city,count(*),rank() over(order by count(*) desc) as rank_order
from museum group by city)
SELECT GROUP_CONCAT(DISTINCT x.country SEPARATOR ', '), 
       GROUP_CONCAT(y.city SEPARATOR ', ')
FROM x 
CROSS JOIN y 
WHERE country.rank_order = 1 AND city.rank_order = 1;
#Query_19
with x as(
select distinct(m.name) as museum_name,m.city as museum_city,a.full_name as artist_name,
ps.sale_price,w.style as painting_style,ps.size_id from product_size as ps
inner join work as w on ps.work_id = w.work_id
inner join museum as m on m.museum_id = w.museum_id
inner join artist as a on a.artist_id = w.artist_id
where ps.sale_price = (select max(sale_price) from product_size) or 
sale_price = (select min(sale_price) from product_size))

select x.*,cs.label as canvas_lable from x
inner join canvas_size as cs on x.size_id = cs.size_id
order by x.sale_price;

#Query_20
with x as (
select m.country,count(*) as no_of_paintings, dense_rank() over(order by count(*)) as rank_order from museum as m
inner join work as w
on m.museum_id = w.museum_id
group by m.country)
select x.country,x.no_of_paintings from x
where rank_order = 5;
#Query_21
(select style,"Most Popular" as Popularity from work
where style != ""
group by style 
order by count(*) desc
limit 3)
union
(select style,"Leat Popular" as popularity from work
where style != ""
group by style 
order by count(*) 
limit 3);

#Query_22
with x as (
	select w.artist_id,count(w.artist_id) as c from museum as m
	inner join work as w
	on m.museum_id = w.museum_id
	where m.country != 'USA'
    group by w.artist_id)

select a.artist_id,a.full_name as artist_name,a.nationality as artist_nationality,x.c as number_of_paintings from artist as a
inner join x
on a.artist_id = x.artist_id
order by x.c desc;
 
