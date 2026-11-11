#단건 1개만
insert into riders(rider_id, name, phone,vehicle,district,hired_at,is_active)
values (default, '김준일','010-9988-1976','오토바이','부산진구',curdate(),1);

insert into riders(name, phone,vehicle,district,hired_at,is_active)
values ( '김준일','010-9988-1976','오토바이','부산진구',curdate(),1);
# 순서를 바꾸거나 제외시키거나 할때 적어서 위치를 잡아준다.
insert into riders
values (default, '김준일','010-9988-1976','오토바이','부산진구',curdate(),1);


#다 건(여러건)
insert into riders
values
    (default, '김준일','010-9988-1976','오토바이','부산진구',curdate(),1),
 (default, '김준ㅇ','010-9988-1976','오토바이','부산진구',curdate(),1),
 (default, '김준2','010-9988-1976','오토바이','부산진구',curdate(),1);

CREATE TABLE rider_settlements (
                                   settlement_id   INT       NOT NULL AUTO_INCREMENT,
                                   rider_id        INT       NOT NULL,
                                   settle_month    CHAR(7)   NOT NULL,
                                   delivery_count  INT       NOT NULL DEFAULT 0,
                                   amount          INT       NOT NULL DEFAULT 0,
                                   is_paid         BOOLEAN   NOT NULL DEFAULT FALSE,
                                   paid_at         DATETIME      NULL,
                                   CONSTRAINT pk_rider_settlements PRIMARY KEY (settlement_id),
                                   CONSTRAINT fk_settlements_rider FOREIGN KEY (rider_id) REFERENCES riders (rider_id),
                                   CONSTRAINT uq_settlements_month UNIQUE (rider_id, settle_month),
                                   CONSTRAINT ck_settlements_month CHECK (settle_month REGEXP '^[0-9]{4}-(0[1-9]|1[0-2])$'),
                                   CONSTRAINT ck_settlements_count CHECK (delivery_count >= 0),
                                   CONSTRAINT ck_settlements_amount CHECK (amount >= 0),
                                   CONSTRAINT ck_settlements_paid CHECK (
                                       (is_paid = TRUE AND paid_at IS NOT NULL)
                                           OR (is_paid = FALSE AND paid_at IS NULL))
);
#insert select - 인설트한 결과를 셀렉트 한다 제약 - 컬럼을 다만들어야한다.
insert into rider_settlements(rider_id, settle_month, delivery_count, amount)
select
    rider_id,
    date_format(delivered_at, '%Y-%m') as settle_month,
    count(*) as delivety_count,
    sum(delivery_fee) as amount
from
    orders
where
    delivered_at is not null
group by
    rider_id,
    date_format(delivered_at, '%Y-%m');

select
    *
from rider_settlements;

update
    rider_settlements rs
    left outer join riders r
    on r.rider_id = rs.rider_id
set
    is_paid = true,
    paid_at = concat(settle_month, '-10')
where
    r.is_active = 1;

update
    rider_settlements
set
    paid_at = null,
    is_paid = false
where
    settle_month = '2026-01';

select @@autocommit;
set autocommit  = 0;

start transaction; #이후 실행된건 transaction 내부

insert into riders
values (default,'김준사','010-1234-5278','오토바이','부산진구', curdate(),1);

select * from riders;

rollback;

commit;

start transaction;

insert into orders(customer_id, restaurant_id, status, payment_method, delivery_fee, discount_amount, request_note, ordered_at)
values (1,1,'접수', '간편결제',2500,5000,'문 앞에 두고 벨 눌러주세요', '2026-06-30 19:05:00');

set @order_id = last_insert_ID(); #몇번의 ID가 auto라 인서트 죈기 모름 찾아서

insert into order_items(order_id, menu_id, quantity, unit_price)
select @order_id, menu_id, case menu_id when 1 then 2 else 1 end, price
from menus
where menu_id in (1,4);
# 그 order ID로 insert함 quantity는 ( menu id가 1일떄 2 아니면 1 ) 1번메뉴와 4번메뉴가 포함되면 가져와라
update customer_coupons
set used_order_id = @order_id
where customer_id = 1 and coupon_id = 3 and used_order_id is null;

select @order_id as new_order_id, row_count() as coupon_rows_updated;

create table daily_salse (
    sales_date date not null primary key,
    orders int not null,
    food_sales int not null
);

insert into daily_salse(sales_date, orders, food_sales)
select  date_format(ordered_at, '%Y-%m-%d'),
        count(order_id),
        sum(m.price)
from
    orders od left outer join menus m
    on m.restaurant_id = od.restaurant_id
where
    status = '배달완료'
    and
    delivered_at >= '2026-06-24'
    and
    delivered_at < '2026-07-01'
group by
    date_format(ordered_at, '%Y-%m-%d');

insert into daily_salse
select
    date(ordered_at) as sales_date,
    count(distinct od.order_id) as orders,
    sum(oi.quantity * oi.unit_price) as food_salse
from
    orders od
    inner join order_items oi
        on oi.order_id = od.order_id
where
    date_format(ordered_at, '%Y-%m') = '2026-06'
    and
    ordered_at >= date_sub(LAST_DAY(ordered_at), interval 6 day)
    and
    date(ordered_at) <= last_day(ordered_at)
    and
    status = '배달완료'
group by
    date(ordered_at);

select
    *
from
    daily_salse;

start transaction;

update
    customers cu
    inner join (select
                    customer_id,
                    count(*)
                from orders
                where date_format(ordered_at, '%y-%m') = '2026-06'
                and status = '배달완료'
                group by
                    customer_id
                having
                    count(*) >=4) od
        on od.customer_id = cu.customer_id
set
    cu.grade = '실버'
where
    cu.grade = '일반';

#배달건수 4건

select
    name,
    grade
from
    customers
where
    grade = '실버'
order by
    customer_id;

start transaction;
update
    coupons
set
    is_active = false
where
    coupon_id > 0;
rollback ;

select *from coupons;