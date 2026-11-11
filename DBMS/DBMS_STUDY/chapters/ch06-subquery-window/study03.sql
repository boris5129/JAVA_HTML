use hanip_delivery06;

#표 여러 컬럼 여러행
select
    menu_id,
    name as menu_name
from
    menus;

select
    *
from
    (select menu_id, name as menu_name from menus) m       #select을 from에 쓴거 m이 테이블명
where
    menu_name like '%국밥';

select
    *
from
    (select
         *
        from
             (select  * from menus) m) m2; #from절에 select을 쓸땐 항상 as 를 단다 안달면 오류

#목록     하나의 컬럼에 여러행
select
    menu_id
from
    menus;

select
    *
from
    order_items
where
    menu_id in (select menu_id from menus where menus.menu_id mod 2 = 0); # mod 는 나머지를 구하는것
#menu_id 가 값안에 포함되면 출력하라 (여기선 짝수가 메뉴아이디에 포함되면)

#스칼라 쿼리 - 값 하나, 반복이 된다. 주의점 : select 될떄마다 select이 한번더 잘못쓰면 성능이 떨어진다
select
    menu_id,
    name,
    (select name from restaurants where restaurants.restaurant_id = menus.restaurant_id)
from
    menus
where
    restaurant_id = (select restaurant_id from restaurants where name = '장전동든든김밥');

#null이 포함된 목록을 서브쿼리로 사용했을 때
select
    rider_id
from
    orders
where
    ordered_at >= '2026-06-30';

select
    *
from
    riders
where
    rider_id not in (select
                         rider_id
                     from
                         orders
                     where
                         ordered_at >= '2026-06-30' and rider_id is not null);
#목록에 null 이 들어가면 싹다 null(모든행이 빠짐) not in인 경우 null제거 처리 해줘야함
#not을하면 포함하지 않으면 가져와라 여기에 null때문에 조건(null이 포함되면안된다)이 부정
#in 은 괜찮다(포함되니 니깐)

#exists
select
    rd.name
from
    riders rd #1이 나온애 들에서 찾는다 현재는 not이있어서 존재안하는애들
where
    not exists(
        select 1 #이 조건이 맞으면 1
        from orders o
        where o.rider_id = rd.rider_id  #바깥행 참조
        and o.ordered_at >= '2026-06-30' #반복돌때 이거먼저 돈다
    ); #조건이 맞으면 1(존재여부 라이더 id에 1이 존재하는지)

select
    *
from
    restaurants rt
    left outer join (
        select
            od.restaurant_id,
            date_format(ordered_at, '%Y-%m') as order_month,
            round(avg(quantity * unit_price), 0) as avg_price
        from
            orders od
                left outer join order_items oi
                                on oi.order_id = od.order_id
        group by
            od.restaurant_id,
            date_format(ordered_at, '%Y-%m')
        order by
            od.restaurant_id,
            order_month) ap
        on ap.restaurant_id = rt.restaurant_id;

with ap_cte as (
                select od.restaurant_id,
                       date_format(ordered_at, '%Y-%m')     as order_month,
                       round(avg(quantity * unit_price), 0) as avg_price
                from orders od
                         left outer join order_items oi
                                         on oi.order_id = od.order_id
                group by od.restaurant_id,
                         date_format(ordered_at, '%Y-%m')
                order by od.restaurant_id,
                         order_month)

select
    *
from
    restaurants rt
    left outer join ap_cte ap on ap.restaurant_id = rt.restaurant_id;

#union all 중복제거 엎이 밑으로 늘어난다
#제일 위에 행에 as 를 작성가능하다
with day_of_week_kor as (
select 1 as day_id, '일' as kor_name
union all
select 2, '월'
union all
select 3, '화'
union all
select 4, '수'
union all
select 5, '목'
union all
select 6, '금'
union all
select 7, '토'
)

select
    order_id,
    ordered_at,
    dowk.kor_name
from
    orders od
    left outer join day_of_week_kor dowk on dowk.day_id = dayofweek(od.ordered_at);

# 카테고리 별로 판매 총 수량 이 높은 가게 순위
#판매총수량을 구해야해
select
    category,
    rank() over(partition by r.category order by ifnull(sum(oi.quantity),0) desc) as restaurants_rank,
    r.restaurant_id,
    r.name as restaurants_name,
    ifnull(sum(oi.quantity),0) as total_quantity
from
    restaurants r
    left outer join orders od
        on od.restaurant_id = r.restaurant_id
    left outer join order_items oi
        on oi.order_id = od.order_id
group by category, r.restaurant_id;

select
    date_format(ordered_at, '%Y-%m') as order_month,
    sum(ifnull(delivery_fee,0)) as delivery_fee_sum,
    sum(sum(ifnull(delivery_fee,0))) over(order by date_format(ordered_at, '%Y-%m')) as cumulative_fee
from
    orders
group by
    date_format(ordered_at, '%Y-%m');

#1
select
    restaurant_id,
    name as name,
    price
from
    menus
where
    price =
    (select max(price)
     from menus);

#2 ?
select
    rt.restaurant_id,
    rt.name
from
    restaurants rt
where
   exists(select
              1
          from
              orders od
          inner join
              reviews re
          on
              re.review_id = od.order_id
          where
              od.restaurant_id = rt.restaurant_id
          );

#3
select
    order_id,
    ordered_at,
    (select name
     from customers ct
     where
        ct.customer_id = od.customer_id)
        as customer_name,
    status
from
    orders od
where
    ordered_at = (
    select
        max(ordered_at)
    from
        orders
    );

#4
select
    count(review_id),
    sum(ifnull(status = '배달완료', 0))
        as delivered_order,
    round
    (count(review_id)/sum(ifnull(status = '배달완료', 0))
         *100, 1)
        as review_rate
from
    orders o
    left join reviews re
    on re.order_id = o.order_id;
#4-1
with delivered_orders_count as (
    select count(*)
    from orders
    where
        status = '배달완료')
select
    count(*) as reivews_count,
    (select * from delivered_orders_count) as delivered_orders,
    round
    (count(*) / (select * from delivered_orders_count) * 100 ,1)
    as review_rate
from
    reviews;

#5
select
    name as name,
    joined_at as joined_at
from
    customers
where
    date (joined_at) < '2026-06-01'
    and
    not exists(
        select
            1
        from
            orders
        where
            orders.customer_id =
            customers.customer_id
        and
            date_format(ordered_at, '%Y-%m') = '2026-06')
order by
    joined_at;

#6 ?
select
    r.name,
    r.category,
    r.min_order_amount,
    round(avg(s.min_order_amount),0)
    as category_avg
from
    restaurants r
    left outer join
        restaurants s
    on s.category = r.category
group by
    name, category, min_order_amount
having
    avg(s.min_order_amount)
    < r.min_order_amount
order by
    category;

#6-1
select
    rt.name,
    rt.category,
    rt.min_order_amount,
    rt2.category_avg
from
    restaurants rt
    inner join
        (
        select category,
               round(avg(min_order_amount)) as category_avg,0
        from
            restaurants
        group by
            category) rt2
        on
        rt2.category = rt.category
        and
        rt2.category_avg < rt.min_order_amount
order by
    rt.category;

#7
select
    order_id,

    (select sum(unit_price * quantity)
     from order_items oi
     where oi.order_id = od.order_id) as food_amount,

    delivery_fee,

    discount_amount,

    (select sum(unit_price * quantity)
     from order_items oi
     where oi.order_id = od.order_id)
        + delivery_fee
        - discount_amount as paid_amount
from
    orders od
where
    status = '배달완료'
order by
    paid_amount desc,
    order_id
limit 5;

#8
select
    name,
    date_format((select max(ordered_at)
                 from orders),'%Y-%m-%d') as last_order_date,
    datediff(
            '2026-06-30' ,
            date_format((select max(ordered_at) from orders),'%Y-%m-%d')) as days_since_last
from
    customers
group by
    name
order by
    days_since_last desc;

#12
with order_month_cte as (
    select
        distinct
        rn.restaurant_id,
        rn.name,
        date_format(ordered_at, '%Y-%m')
        as order_month
    from orders od,
         (select
              restaurant_id,
              name
          from restaurants
          where name
            in ('대연동크런치치킨', '서면야식치킨')) rn
    order by
        restaurant_id
)
select
   omc.order_month,
   omc.name as restuarant_name,
   ifnull(sum(oi2.food_sales),0) as food_salse
from
    order_month_cte omc
    left outer join (
    select
        oi.order_id,
        od.restaurant_id,
        date_format(ordered_at, '%Y-%m') as order_month,
        sum(quantity * unit_price) as food_sales
    from
        order_items oi
        inner join orders od
            on od.order_id = oi.order_id
    group by
        order_id,
        od.restaurant_id,
        date_format(ordered_at, '%Y-%m')) oi2
        on oi2.restaurant_id = omc.restaurant_id
        and oi2.order_month = omc.order_month
group by
    omc.order_month,
    omc.name;

#11
select
    category,
    category_rank,
    restaurant_name,
    food_sales
from
(select
    rt.category,
    row_number() over(partition by rt.category
        order by (select
                      sum(quantity * unit_price)
                  from
                      order_items oi
                          inner join orders od on od.order_id = oi.order_id
                          and od.restaurant_id = rt.restaurant_id
                          and od.status = '배달완료'
        ) desc) as category_rank,
    rt.name as restaurant_name,
    (select
         sum(quantity * unit_price)
     from
         order_items oi
             inner join orders od on od.order_id = oi.order_id
             and od.restaurant_id = rt.restaurant_id
             and od.status = '배달완료'
    ) as food_sales
from
    restaurants rt
order by
    category) rank_top_2
where
    category_rank < 3
and food_sales is not null;

#10
select
    name,
    (select
         min(od.ordered_at)
     from
         orders od
     where od.customer_id = c.customer_id
     ) as first_ordered_at,
    (select
         rt.name
     from
         restaurants rt
             left outer join orders od
            on od.restaurant_id = rt.restaurant_id
     where
         od.customer_id = c.customer_id
     and od.ordered_at = first_ordered_at
         ) as restaurant_name
from
    customers c
where
    (select
         min(od.ordered_at)
     from
         orders od
     where od.customer_id = c.customer_id
    ) is not null;

#10-1
select
    ct.name as customer_name,
    ordered_at as first_ordered_at,
    rt.name as restaurant_name
from
(select
    customer_id,
    row_number()
            over (
            partition by customer_id
            order by ordered_at) as order_num,
     ordered_at,
     restaurant_id
from
    orders) odn
inner join customers ct on ct.customer_id = odn.customer_id
inner join restaurants rt on rt.restaurant_id = odn.restaurant_id

where
    order_num = 1
order by
    odn.customer_id;