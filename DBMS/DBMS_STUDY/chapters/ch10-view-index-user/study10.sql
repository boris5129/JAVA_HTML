
create view v_names as
select
    od.order_id,
    od.customer_id,
    ct.name as customer_name,
    od.restaurant_id,
    rt.name as restaurant_name,
    od.rider_id,
    rd.name as rider_name
from
    orders od
    left join order_items oi
    on oi.order_id = od.order_id
    left join customers ct
    on ct.customer_id = od.customer_id
    left join restaurants rt
    on rt.restaurant_id = od.restaurant_id
    left join riders rd
    on rd.rider_id = od.rider_id;

select
    *
from
    v_names;

create index idx_restaurant_name on restaurants(name); # 뒤에꺼에 인덱스 생성하겠다

explain select
    *
from
    restaurants
where
    name = '하단버거스탠드';

explain
select
    *
from
    restaurants
where
    name like '%버거%';

explain
select
    *
from
    orders
where
    restaurant_id = 10;

create index inx_ordered_at on orders(ordered_at);

explain
select
    *
from
    orders
where
    ordered_at < '2026-01-04';

create user 'user1'@'localhost' identified by '1q2w3e4r!';
create user 'user1'@'%' identified by '1q2w3e4r!';

select * from mysql.user;

grant select on `hanip_delivery10`.* to 'user1'@'%';
revoke select on `hanip_delivery10`.* from 'user1'@'%';

show grants for 'user1'@'%';
select
    *
from
    customers;
insert into customers
values (null,'김준일','010-1236-5467','asd@asd.asd','1994-0-07','부산진구','부산광역시 진구 동평로', '실버',1,now())

