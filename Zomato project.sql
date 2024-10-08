
-- creating "goldusers_signup" table and inserting values

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'2017-09-22'), (3,'2017-04-21');

-- creating "users" table and inserting values

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'), 
(2,'2015-01-15'), 
(3,'2014-04-11'); 


-- creating "sales" table and inserting values

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-18',2),
(3,'2019-12-18',1), 
(2,' 2019-12-18',3), 
(1,'2019-10-23',2), 
(1,'2018-03-19',3), 
(3,'2016-12-20',2), 
(1,'2016-11-09',1), 
(1,'2016-05-20',3), 
(2,'2017-09-24',1), 
(1,'2017-03-11',2), 
(1,'2016-03-11',1), 
(3,'2016-11-10',1), 
(3,'2017-12-07',2), 
(3,'2016-12-15',2), 
(2,'2017-11-08',2), 
(2,'2018-09-10',3); 


-- creating "product" table and inserting values

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

-- Reviewing tables

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1 ---- what is total amount each customer spent on zomato ?
	Select userid,sum(price) as Total_Spent from
      (Select a.userid,b.product_id,c.price from Users a
        inner join Sales b on a.userid=b.userid
          inner join product c on b.product_id=c.product_id)
            group by userid;

2 ---- How many days has each customer visited zomato?
select userid,count(Distinct created_date) as Visited_time from sales
	  group by userid
   		order by userid;      

3 --- what was the first product purchased by each customer?
with first_purchase as
  (select userid,min(created_date) as first_purchase_date from sales
    Group by userid)
    Select a.userid,b.first_purchase_date,a.product_id from sales a
     inner join first_purchase b on a.userid=b.userid and a.created_date=b.first_purchase_date
      order by userid;

4 -- what is most purchased item on menu & how many times was it purchased by all customers ?
select product_id,cnt as time_of_purchased from
(select a.product_id,cnt,row_number() over(order by cnt desc) as rank  from 
 (select product_id,count(*) cnt from sales
       group by product_id)a)where rank='1';

5 ---- which item was most popular for each customer?
 select userid,product_id,cnt as time_of_purchased from 
   (select userid,product_id,cnt,row_number() over(partition by userid order by cnt desc) as rank from
      (select userid,product_id,count(product_id) as cnt from sales
        group by userid,product_id))where rank='1';


6 --- which item was purchased first by customer after they become a member ?
Select userid,product_id,created_date,gold_signup_date from
(select a.userid,a.product_id,a.created_date,b.gold_signup_date,
	row_number() Over(partition by a.userid order by created_date asc)as rank from sales a
     inner join goldusers_signup b on a.userid=b.userid
       where a.created_date>b.gold_signup_date
        )where rank='1';

7 --- which item was purchased just before customer became a member?
Select userid,product_id,created_date,gold_signup_date from
  (select a.userid,a.product_id,a.created_date,b.gold_signup_date,
	row_number() Over(partition by a.userid order by created_date Desc)as rank from sales a
     inner join goldusers_signup b on a.userid=b.userid
       where a.created_date<b.gold_signup_date) where rank='1';

8 ---- what is total orders and amount spent for each member before they become a member ?
Select userid,sum(price) from
	(select a.userid,a.product_id,a.created_date,b.gold_signup_date,c.price from sales a
     inner join goldusers_signup b on a.userid=b.userid
	Left join product c on a.product_id=c.product_id
       where a.created_date<b.gold_signup_date)group by userid;

9 --- rnk all transaction of the customers
     select a.*,rank() over(partition by userid order by created_date) as rank from sales a;

10 --- rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na
select a.userid,a.product_id,a.created_date,b.gold_signup_date,
	Rank() over(partition by a.userid order by created_date) as rank from sales a
        inner join goldusers_signup b on a.userid=b.userid
        where created_date>=gold_signup_date;








