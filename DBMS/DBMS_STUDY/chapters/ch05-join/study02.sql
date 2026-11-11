#join
select * from restaurants;
select * from orders;

select
    *
from
    orders, restaurants
where
    restaurants.restaurant_id = orders.restaurant_id
order by
    orders.order_id;
# where에서 id같은거만 해서 불필요한 join을 날린다.
# 모든 경우의 수를 다 돌고 where로 걸러낸다 반복2회
select
    *
from
    orders o inner join restaurants r
    on
        r.restaurant_id = o.restaurant_id
order by
    o.order_id;
# join 하면 on 조건을 줄수있다.
# 합칠떄 조건검사를 해서 필요없는거 join을 안함 반복 1회
# order에 res 를 붙인다
# 기준(order)(order에 res를 붙이니깐)이 오른쪽
# on바로뒤는 on 바로 앞테이블 작성

#inner join 은 조건이 false면 버려진다.

select
    *
from
    orders o
    left join order_items oi on oi.order_id = o.order_id
    left join menus mn on mn.menu_id = oi.menu_id
    left join reviews rv on rv.order_id = o.order_id
    left join customers ct on ct.customer_id = o.customer_id
    left join restaurants rt on rt.restaurant_id = o.restaurant_id
    left join riders rd on rd.rider_id = o.rider_id
where
    ct.name = '윤지아';

select
    count(*)
from
    orders o
    left outer join reviews rv on rv.order_id = o.order_id
where
    rv.review_id is null; #리뷰 안달린건
    # inner join reviews rv on rv.order_id = o.order_id;
    # 리뷰가 달린것만 나온다.
    # 그냥 join 은 inner left는 outer 이게 풀네임

select
    o.order_id,
    o.status,
    rd.name as rider_name
from
    orders o
left join
        riders rd
on rd.rider_id = o.rider_id
where
    o.ordered_at >= '2026-06-30'
order by
    o.order_id;

select
    o.order_id,
    count(distinct o.order_id),
    rt.name,
    #count(o.order_id)
    #이때 메뉴에따라 적용된거라 중복제거 해줘야한다
    sum(oi.quantity * oi.unit_price)
from
    orders o
    inner join restaurants rt
        on rt.restaurant_id = o.restaurant_id
    inner join order_items oi
        on oi.order_id = o.order_id
group by
    o.order_id,
    rt.name;
# rt.name 안해도 동일한 결과지만
# 상호명이 같고 ID 가 다를수있어서 써줘야한다
# 2개(이름+id)를 조합해서 key로 쓴다
# group에 집계함수빼고 다써줘야 명확하게 그룹이 된다

#self join
# inner 든 left outer 든 자기 table 한번더 참조
# cross join 모든 경우의수 다나오는거
# 쉼표찍고 다하거나,
# left join 을 하는데 1=1 로 true 를 만들어 사용

#1
select
    r.name as restaurant_name,
    m.name as manu_name,
    price
from
    menus m join restaurants r
        on r.restaurant_id = m.restaurant_id
where
    category = '치킨'
order by
    m.restaurant_id,
    price desc;

#2
select
    r.name as rider_name,
    vehicle,
    count(status = '배달완료') as deliveries
from
    riders r
        join  orders o
            on o.rider_id = r.rider_id
where
    status = '배달완료'
group by
    r.name,
    vehicle
order by
    deliveries desc;

#3
select
    review_id,
    rating,
    rt.name as restaurant_name,
    c.name as customer_name,
    content
from
    reviews rv
        join orders o
            on o.order_id = rv.order_id
        join restaurants rt
            on rt.restaurant_id = o.restaurant_id
        join customers c
            on c.customer_id = o.customer_id
where
    rating <= 2
order by
    ordered_at desc;

#4
select
    order_id,
    status,
    c.name as customer_name,
    rt.name as restaurant_name,
    ri.name as rider_name
from orders o
        left join restaurants rt
            on rt.restaurant_id = o.restaurant_id
        left join riders ri
             on ri.rider_id = o.rider_id
        left join customers c
             on c.customer_id = o.customer_id
where
    status = '조리중'
    or status = '배달중'
    or status = '접수';

#5
select
    rt.name as restarant_name,
    round(avg(rating), 2) as avg_rating,
    count(content) as review_count
from
    restaurants rt
        left join orders o
            on o.restaurant_id = rt.restaurant_id
    left join reviews re
        on re.order_id = o.order_id
group by
    rt.name
having
    count(re.review_id) >= 10
order by
    avg_rating desc;

#6
select
    rt.name as restaurant_name,
    m.name as menu_name,
    sum(oi.quantity) as sold_quantity
from
    menus m
    left join order_items oi
        on oi.menu_id = m.menu_id
    left join restaurants rt
        on rt.restaurant_id = m.restaurant_id
group by
    rt.name, m.name
order by
    sold_quantity desc
limit 5;

#7
select
    category,
    count(distinct o.order_id) as delivered_orders,
    sum(unit_price * quantity) as food_sales
from
    orders o
    left join restaurants rt
        on rt.restaurant_id = o.restaurant_id
    left join order_items oi
        on oi.order_id = o.order_id
where
    status = '배달완료'
group by
    category
order by
    food_sales desc;

#8
select
    m.menu_id,
    m.name as menu_name,
    r.name as restaurant_name
from
    menus m
    left join order_items oi
        on oi.menu_id = m.menu_id
    left join restaurants r
        on r.restaurant_id = m.restaurant_id
where
    order_id is null
order by
    menu_id;

#9
select
    c.name as customer_name,
    grade,
    count(o.order_id) as delivered_orders
from
    customers c
    left join orders o
        on o.customer_id = c.customer_id
    and
    status = '배달완료'
group by
    c.name, grade, c.customer_id
order by
    delivered_orders,
    c.customer_id;

#10
select
    r.name as rider_name,
    hired_at,
    count(order_id) as deliveries,
    max(delivered_at) as last_delivered_at
from
    riders r
    left join orders o
        on o.rider_id = r.rider_id
where
    is_active = 0
group by
    r.name, hired_at;

#11 ?
select
    m.name as menu_name,
    oi.unit_price,
    m.price as current_price,
    sum(oi.quantity) as sold_quantity
    #sum은 값을 count는 행의 갯수
from
    order_items oi
    inner join menus m
        on m.menu_id = oi.menu_id
        and oi.unit_price != m.price
    inner join orders o
        on o.order_id = oi.order_id
    and o.status = '배달완료'
group by
    m.name,
    unit_price,
    m.price,
    oi.menu_id
order by
    oi.menu_id;

#12
select
    count(order_id) as delivered_orders,
    sum(c.district != r.district) as cross_district,
    round((sum(c.district != r.district)*100)/count(order_id),1) as cross_rate
from
    orders o
    left join customers c
        on c.customer_id = o.customer_id
    left join restaurants r
        on r.restaurant_id = o.restaurant_id
where
    status = '배달완료'
having
    count(order_id);

#13 ?
select
    r.name as restaurant_name,
    count(o.order_id) as delivered_order,
    count(re.review_id) as reviewed,
    round(
        count(re.order_id) /
        count(o.order_id) * 100, 1
    )as review_rate
from
    restaurants r
    inner join  orders o
        on o.restaurant_id = r.restaurant_id
        and o.status = '배달완료'
    left join reviews re
        on re.order_id = o.order_id
group by
    r.restaurant_id,
    r.name
order by
    review_rate desc;

#14
select
    date_format(o.ordered_at, '%Y-%m') as order_month,
    sum(if(r.category = '한식', oi.unit_price * oi.quantity, 0)) as korean,
    sum(if(r.category = '중식', oi.unit_price * oi.quantity, 0)) as chinese,
    sum(if(r.category = '치킨', oi.unit_price * oi.quantity, 0)) as chicken,
    sum(if(r.category = '피자', oi.unit_price * oi.quantity, 0)) as pizza,
    sum(oi.quantity * oi.unit_price) as all_category
from
    orders o
    inner join order_items oi
        on oi.order_id = o.order_id
        and  status = '배달완료'
    left join restaurants r
        on r.restaurant_id = o.restaurant_id
group by
    date_format(o.ordered_at, '%Y-%m');