#1     ~11
select
    ca2.name as main_category,
    count(distinct od.order_id) as orders,
    sum(quantity) as quantity,
    sum(quantity * unit_price) as sales
from
    products pro
    left outer join categories ca
        on ca.category_id = pro.category_id
    inner join categories ca2
        on ca.parent_id = ca2.category_id
    left outer join order_items oi
        on oi.product_id = pro.product_id
    left outer join orders od
        on od.order_id = oi.order_id
where
    status = '배송완료'
group by
    ca2.category_id
order by
    sales desc;
#2
select
    region,
    count(member_id) as members,
    sum(exists(select 1
        from orders o
        where
            status = '배송완료'
        and
            o.member_id = m.member_id
            ))as buyers,
    round(sum(exists(select 1
               from orders o
               where
                   status = '배송완료'
                 and
                   o.member_id = m.member_id
    )) / count(member_id) * 100,1 )as conversion_rate
from
    members m
group by
    region
order by
    conversion_rate desc,
    region;

#3
select
    distinct brand,
    count(distinct review_id),
    round(avg(rating),2) as avg_rating,
    round(sum(if(rating = 1 or rating = 2,1,0))* 100 /count(distinct review_id),1)as low_rating_pct
from
    reviews re
    left outer join products pro
    on pro.product_id = re.product_id
group by brand
having
    count(distinct review_id) >= 10
order by
    avg_rating,
    brand;

#4
select
    date_format(ordered_at, '%Y-%m') as ym,
    count(if(payment_method = '카드',1,null)) as card,
    count(if(payment_method = '간편결제',1,null)) as easy_pay,
    count(if(payment_method = '계좌이체',1,null)) as bank_teansfer,
    count(payment_method)as total
from
    orders
where
    status != '취소'
    and
    status != '반품'
group by date_format(ordered_at, '%Y-%m')
order by
    ym;

#6
select
    m.name as name,
    count(if(o.order_id,1,null)) as orders,
    date_format(min(ordered_at),'%Y-%m-%d')as frist_order,
    date_format(max(ordered_at),'%Y-%m-%d')as last_order,
    round(avg((select sum(oi.unit_price * oi.quantity)
    from order_items oi
    where oi.order_id = o.order_id
    and m.member_id = o.member_id)),0) as avg_amount
from
    members m left outer join
        orders o
            on o.member_id = m.member_id

where
   status = '배송완료'
group by
    name
having
    count(o.order_id) >= 10
order by
    orders desc,
    avg_amount desc;

select
    ca.name as category,
    pro.name as name,
    pro.price as price,
    round(avg((
        select avg(pro.price * oi.quantity)
        from order_items oi
        where oi.product_id = ca.parent_id
        )))as category_avg
from
    categories ca
    left outer join products pro
    on pro.category_id = ca.category_id
group by
    ca.name,
    pro.name,
    pro.price;

#8
select
    m.name as name,
    pro.name as product_name,
    pro.price as price,
    date_format(wi.added_at, '%Y-%m-%d') as added_at
from
    products pro left outer join
        wishlists wi
    on wi.product_id = pro.product_id
    left outer join members m
        on m.member_id = wi.member_id
    left outer join orders od
        on od.member_id = m.member_id
where
    pro.is_active = 1
    and
    od.status = '배송완료'
    and
    wi.member_id = od.member_id
    and
    od.member_id = wi.member_id
group by
    m.name,
    pro.name,
    pro.price,
    wi.added_at
order by
    added_at,
    m.name
limit 10;


#11
select
    rk.name as product_name,
    m2.name as member_name,
    m2.region as refion,
    sum(if(od2.order_id,1,0)) as time
from
(select
    pro.name as name,
    rank() over (
        order by count(od.order_id) desc) as ranked
from
    products pro
    left join order_items oi
        on oi.product_id = pro.product_id
    left join orders od
        on od.order_id = oi.order_id
group by
    name) rk left outer join products pro2
    on pro2.name = rk.name
    left join categories cat
        on cat.category_id = pro2.category_id
    left join order_items oi2
        on oi2.product_id = pro2.product_id
    left join orders od2
        on od2.order_id = oi2.order_id
    left join members m2
        on m2.member_id = od2.member_id
where
    od2.status = '배송완료'
    and rk.ranked = 1
group by
    rk.name ,
    m2.name ,
    m2.region
order by
    time desc,
    member_name;
#11
select
    product_name,
    mb.name,
    mb.region,
    count(od.order_id) as times
from(
select
    rank() over (order by sum(oi.quantity) desc) as rk_num,
    oi.product_id,
    pd.name as product_name,
    sum(oi.quantity) as total
from
    orders od
    inner join order_items oi
        on oi.order_id = od.order_id
    and status = '배송완료'
    inner join products pd
        on pd.product_id = oi.product_id
group by
    oi.product_id,
    pd.name) as pr
    left outer join order_items oi
    on oi.product_id = pr.product_id
    inner join orders od
    on od.order_id = oi.order_id and od.status = '배송완료'
    left outer join  members mb
    on mb.member_id = od.member_id
where
    rk_num = 1
group by
    product_name,
    mb.name,
    mb.member_id,
    mb.region
order by times desc;

#10
select
    cat.name as category,
    pro.name as name,
    pro.brand as brand,
    pro.price as price
from
    (select ca.category_id,
            ca.name,
            pro2.product_id,
            rank() over (partition by ca.category_id
                order by pro2.price desc) as rk
     from categories ca
         inner join
          products pro2
          on pro2.category_id = ca.category_id
     where parent_id is not null
     ) cat
        left outer join
    products pro
    on pro.product_id = cat.product_id
where
    rk = 1
order by
    cat.category_id;

#10
select
    category,
    name,
    brand,
    price
from
    (
select
    rank() over (partition by ct.category_id
        order by pd.price desc) as rank_num,
    ct.category_id,
    ct.name as category,
    pd.name as name,
    pd.brand as brand,
    pd.price as price
from
    categories ct
    left outer join products pd
    on pd.category_id = ct.category_id
where
    ct.parent_id is not null) as category
where
    rank_num = 1
order by
    category_id;


#9
select
    od.order_id as order_id,
    m.member_id as member_name,
    date_format(od.ordered_at, '%Y-%m-%d') as ordered_at,
    sum()as amount
from
    orders od
    left outer join members m
    on m.member_id = od.order_id;

#14
select
    order_seq,
    order_id,
    ordered_at,
    amount,
    running_total,
    if(row_number() over (partition by running_total_group order by ordered_at) = 1
        and running_total_group = 1, 'VIP 달성',null)as vip_reached
from (select row_number() over (order by od.order_id)                                  as order_seq,
             od.order_id                                                               as order_id,
             date_format(od.ordered_at, '%Y-%m-%d')                                    as ordered_at,
             sum((oi.unit_price * oi.quantity) + od.shipping_fee - od.coupon_discount) as amount,
             sum(sum((oi.unit_price * oi.quantity) + od.shipping_fee - od.coupon_discount))
                 over (order by od.order_id)                                           as running_total,
             sum(sum((oi.unit_price * oi.quantity) + od.shipping_fee - od.coupon_discount))
                 over (order by od.order_id) > 500000                                  as running_total_group
      from orders od
               inner join order_items oi
                          on oi.order_id = od.order_id
                              and od.status = '배송완료'
                              and od.member_id = 1
      group by od.order_id,
               date(od.ordered_at)) as result;

#15
select
    pct.name as first_main_category,
    count(foi.member_id) as members,
    round(count(*) / sum(count(*)) over() *100,1)as pct
from(
select
    od.member_id,
    min(oi.order_item_id) as first_order_item_id
from
    orders od
    inner join order_items oi
    on oi.order_id = od.order_id and status = '배송완료'
group by
    od.member_id) foi
    left outer join order_items oi
    on oi.order_item_id = foi.first_order_item_id
    left outer join  products pd
        on pd.product_id = oi.product_id
    left outer join categories ct
        on ct.category_id = pd.category_id
    left outer join  categories pct
        on pct.category_id = ct.parent_id
group by
    pct.category_id,
    pct.name
order by
    pct.category_id;

#17

select
    concat(year(joined_at),'-Q', quarter(joined_at)) as join_quarter,
    count(sum.joined_at),
    count(sum.withdrawn_at)
from
(select
    joined_at,
    null as withdrawn_at
from
    members
union
select
    joined_at,
    withdrawn_at
from
    withdrawn_members) as sum
group by
    concat(year(joined_at),'-Q', quarter(joined_at))
order by
    concat(year(joined_at),'-Q', quarter(joined_at))

#19

select
   count(*),
   count(*)
   total3.in_both
from
(select
     member_id,
     product_id
from
    wishlists
union all
select
    member_id,
    product_id
from
    carts
) as total
cross join
(select
     member_id,
     product_id
 from
     wishlists
 union
 select
     member_id,
     product_id
 from
     carts) as total2
cross join
(select
     count(*) as in_both
from
    wishlists  w
inner join carts c
    on c.member_id =w.member_id
    ) as total3;

#20
select
    me.region as refion,
    count(me.region) as orders
from
    orders od
    left outer join members me
    on me.member_id = od.member_id
           and od.status = '배송완료'
group by me.region
