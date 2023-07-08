drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

//-------------------------------------------------------------------------------------------------------------------------------------------------------//
drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');
//-----------------------------------------------------------------------------------------------------------------------------------------------------//

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

//--------------------------------------------------------------------------------------------------------------------------------------------------//


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer);

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

-//------------------------------------------------------------------------------------------------------------------------------------------------//

---1.Datasets used 

select * from goldusers_signup
select * from users
select * from sales
select * from product

---2. what is total amount each customer spent on zomato ?

select s.userid,sum(price)[total_amnt] from sales s 
inner join product p
on s.product_id=p.product_id
group by s.userid

---3.How many days has each customer visited zomato?
select s.userid, count(distinct s.created_date)[total_days] from sales s
group by s.userid


---4.what was the first product purchased by each customer?
select * from 
(select *,
DENSE_RANK() over (partition by userid order by created_date) RN
from sales) T
where RN=1


---5.what is most purchased item on menu & how many times was it purchased by all customers ?
select top 1 product_id,count(product_id)[count] from sales
group by product_id
order by count(product_id) desc


---6.which item was most popular for each customer?
select * from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id)cnt from sales
group by userid, product_id)a)b
where rnk=1


---7.which item was purchased first by customer after they become a member ?
select * from
(select *, rank() over(partition by userid order by created_date) rnk from
(select s.userid ,s.created_date,s.product_id,g.gold_signup_date from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date>gold_signup_date)c)d where rnk=1

---8. which item was purchased just before the customer became a member?
select * from
(select *, rank() over(partition by userid order by created_date desc) rnk from 
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date<gold_signup_date)k)h where rnk=1

---9. Rank all transaction of the customers
select *,rank() over(partition by userid order by created_date desc)rnk from sales

---10. what is total orders and amount spent for each member before they become a member?

select userid,count(created_date),sum(price)
from
(select k.*,p.price from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s inner join goldusers_signup g on s.userid=g.userid 
and created_date<gold_signup_date)k 
inner join product p on p.product_id=k.product_id)e
group by userid


