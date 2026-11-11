use hanip_delivery04; #해주면 스키마 바뀐다.현재는 완료
select *
from
    customers;

select *
from menus;


select
    count(*) as menu_conut, # *
    min(price) as min_price,
    max(price) as max_price,
    sum(price) as total_price,
    avg(price) as avg_price
from
    menus;

select
    count(*) as customers,              # 열을 넣으면 널 뺴고
    count(email) as with_email,
    count(birth_date) as with_birth,
    count(distinct district) as districts    #중복제거 후 해라 널 허용x
from
    customers;

select
    count(*) as orders,
    sum(delivery_fee) as fee_sum,   # null 하나라도 있으면 null
    ifnull(sum(delivery_fee), 0 ) as fee_sum_dafe
from
    orders
where restaurant_id = 15;

select distinct
    category,
    district
from
    restaurants
order by
    category;
# 위 아래가 같다 distinct  group by
# 구분 기준 - 단순 중복제거는 distinct 중간에 집계함수(sum 등) group by
select
    category,
    district
from
    restaurants
group by
    category,
    district
order by
    category;

select
    category,
    count(*) as restaurant_count,
    max(delivery_fee) as max_delivery_fee
from
    restaurants
group by category;

select
    date_format(ordered_at, '%Y-%m') as order_month,
    count(*) as order_count
from
    orders
group by
    order_month;    #이거 mysql 이라서 가능 정상적인 문법아님.
    #date_formate(order_at, '%Y-%m')  이게 정상문법

# [             이런구조 (이게 Map 하나)
#     {
#  여기가 key date_format(ordered_ay, '%Y-%m'): 2026-01 count 3
#         [
#   value     {oder},
#             {oder},
#             {oder},
# ], date_format(ordered_ay, '%Y-%m'):  2026-02 count 4
#         [
#             {oder},
#             {oder},
#             {oder},
#             {oder},
# ]
#     }
# ]

select
    restaurant_id,
    sum(price) as total_price
from
    menus
group by
    restaurant_id
having      #group 함수 쓴 결과에 조건을 주고싶을떄
    sum(price) > 50000;

select
    order_id,       #현재는 오더아이디를 알수없다
    count(*) as item_lines,
    sum(quantity) as total_quantity,
    sum(quantity * unit_price) as food_amount
from order_items
group by order_id
order by food_amount desc, order_id;

select
    ifnull(payment_method, '합계') as patment_method,
    count(*) as delivered_orders,
    sum(delivery_fee) as fee_sum
from orders
where status = '배달완료'
group by payment_method with rollup;
# with rollup - 기본적으로 맨마지막행에 하나의 전체 집계를 내주는 함수
# with rollup - group by와 같이 사용가능한경우도 있고 불가능한경우도 있다.

select
   *
from
    (select
        payment_method,
        count(*) as delivered_orders,
        sum(delivery_fee) as fee_sum
    from
      orders
where
    status = '배달완료'
group by
    payment_method
order by
    fee_sum desc) as group_orders

union all

select
    '합계',
    count(*) as delivered_orders,
    sum(delivery_fee) as fee_sum
from
    orders
where
    status = '배달완료';

#1번
select
    count(name) as menu_count,
    min(price) as min_pirce,
    max(price) as max_price,
    round(avg(price)) as avg_price
from
    menus;

#2번
select
    category,
    count(category) as restaurant_count
from
    restaurants
group by
    category
order by
    restaurant_count desc,
    category;

#3번
select
    rating,
    count(*) as review_count,
    count(case when content is null then 1 end) as rating_only
   # sum(case when content is null then 1 else 0 end) as rating_only 가능
   # count(if(content is null, 1, null)) as rating_only
from
    reviews
group by
    rating
order by
    rating desc;

#4번
select
    round(avg(rating), 2) as avg_rating,
    count(*) as review_count,
    round
    (count(*) / (select count(*) from orders where status = '배달완료')*100,1)
        as review_rate
from
    reviews;

#5번
select
    grade,
    count(*) as members,
    count(if(marketing_agreed = 1, 1, null)) as members,
    count(email) as with_emil
    from
    customers
group by
    grade
order by
    grade;

#6번
select
    payment_method,
    count(*) as deliveryed_orders,
    ROUND(avg(discount_amount),0)as avg_discount,
    count(if(discount_amount != 0, 1, null)) as discounted_orders
from
    orders
where
    status = '배달완료'
group by
    payment_method
order by
    count(status = '배달완료') desc;

#7번
select
    hour(ordered_at) as order_hour,
    count(*)as delivered_orders   # *은 where을 끝난 전체
from
    orders
where
    status = '배달완료'
group by
    hour(ordered_at)
order by
    delivered_orders desc
limit 5;

#8번
select
    customer_id,
    count(*)as order_count,
    min(date(ordered_at)) as frist_order,
    max(date(ordered_at)) as last_order
from
    orders
where
    status = '배달완료'
group by
    customer_id
having
    count(*) >= 30
order by
    count(*) desc;

#9번
select
    order_id,
    count(menu_id) as item_line,
    sum(quantity * unit_price) as food_amount
from
    order_items
group by
    order_id
order by
    food_amount desc,
    order_id
limit 5;

#10
select
    unit_price,
    SUM(quantity) AS sold_quantity,
    SUM(unit_price * quantity) AS sales_amount
from
    order_items
where
    menu_id = 1
group by
    unit_price
order by
    unit_price;

#11번
select
    rider_id,
    count(*) as deliveries,
    round(avg(timestampdiff(minute, ordered_at, delivered_at)), 1) as avg_minutes,
    count(case when timestampdiff(minute, ordered_at, delivered_at) > 60 then 1 end) as late_count,
    round
    (count(case when
    timestampdiff(minute, ordered_at, delivered_at) > 60 then 1 end) / count(*) * 100 , 1) as late_rate
from
    orders
where
    status = '배달완료'
group by
    rider_id
order by
    deliveries desc;

#12
select
    date_format(ordered_at, '%Y-%m') as order_month,
    count(if(payment_method = '카드', 1, null)) as card,
    count(if(payment_method = '간편결제', 1, null))as easy_pay,
    count(if(payment_method = '계좌이체', 1, null))as transfer,
    count(if(payment_method = '현장결제', 1, null))as on_site,
    count(payment_method) as total
from
    orders
where
    status = '배달완료'
group by
    date_format(ordered_at, '%Y-%m');

