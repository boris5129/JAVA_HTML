drop table if exists coupons_draft;
#DDL - create 는 DDL 문법 data 구조와 정의
create table coupons_draft
(
    coupon_id       int null,
    code            varchar(20) null,
    name            varchar(50) null,
    discount_amount int
);
insert into coupons_draft(coupon_id, code, name, discount_amount) values
    (1, 'welcome3000','첫 주문 3,000원 할인', 3000),
    (1,'welcome3000', null, -5000),
    (null, null, '이름만 있는 쿠폰', null);
select
    *
from
    coupons_draft;

create table coupons(
    coupon_id           int         not null auto_increment,
    code                varchar(20) not null,
    name                varchar(50) not null,
    discount_type       varchar(10) not null,
    discount_value      int         not null,
    min_order_amount    int         not null default 0,
    valid_days          int         not null default 30,
    is_active           boolean     not null default true,
    created_at          datetime    not null default current_timestamp,
    constraint pk_coupons primary key (coupon_id),
    constraint uq_coupons_code unique (code),
    constraint ck_coupons_type check (discount_type in ('정액','정률')),
    constraint ck_coupons_value check ( (discount_type = '정액' and discount_value > 0)
        or (discount_type = '정률' and discount_value between 1 and 50)),
    constraint ck_coupons_min check (min_order_amount >= 0),
    constraint ck_coupons_days check (valid_days > 0)
);

create table customer_coupons(
    customer_coupon_id  int         not null auto_increment,
    customer_id         int         not null,
    coupon_id           int         not null,
    issued_at           datetime    not null default current_timestamp,
    expires_at          datetime    not null,
    used_order_id       int         null,
    constraint pk_customer_coupons primary Key (customer_coupon_id),
    constraint fk_cc_customer foreign key (customer_id) references customers(customer_id),
    constraint fk_cc_coupon foreign key (coupon_id) references coupons(coupon_id),
    constraint fk_cc_order foreign key (used_order_id) references orders(order_id),
    constraint uq_cc_customer_coupon unique(customer_id, coupon_id),
    constraint uq_cc_used_order unique(used_order_id),
    constraint ck_cc_period check (expires_at > issued_at)
);
#1
select
    column_name,
    data_type
from
    information_schema.COLUMNS
where
    table_schema = DATABASE() and
    table_name = 'orders'
and is_nullable = 'YES'
order by
    ordinal_position;
#2
select
    constraint_name
from
    information_schema.table_constraints
where
    table_schema = DATABASE()
    and
    CONSTRAINT_TYPE = 'CHECK'
    and
    table_name = 'orders';
#3
# 1. varchar 중간에 - 있음   varchar(12)
# 2. DECIMAL % 율
# 3. text 글이 김
# 4. DECIMAL 소수점으로 표시하기 좋음
# 5. datetime 시간나야함
# 6. boolean (tinyint) yes or no

#4
create table notices(
    notice_id       int not null auto_increment,
    title           varchar(100) not null,
    content         text not null,
    is_pinned       boolean not null default false,
    published_at    datetime not null default current_timestamp,
    constraint pk_notice_id primary key (notice_id)
);
insert into notices(title, content, is_pinned, published_at)
values ('"7월 정산일 안내"', '"7월 정산은 10일에 진행됩니다."',true, '2026-07-10');
insert into notices(title, content, is_pinned, published_at)
values ('"배달팁 정책 변경"','"8월부터 5만원 이상 무료 배달 기준이 4만원으로 바뀝니다."',
        false, '2026-08-01');
select
    notice_id,
    title,
    is_pinned
from
    notices;



#5
create table restaurant_holidays(
    holiday_id int not null auto_increment,
    restaurant_id int not null,
    holiday_date date not null,
    reason varchar(50) null default '사유 없음',
    constraint pk_holiday_id primary key (holiday_id),
    constraint fk_restaurant_id foreign key (restaurant_id) references restaurants(restaurant_id)
);
insert into restaurant_holidays(restaurant_id, holiday_date,reason)
values (1,'2026-07-15','내부수리');
insert into restaurant_holidays(restaurant_id, holiday_date,reason)
values (6,'2026-07-15',null);
insert into restaurant_holidays(restaurant_id, holiday_date,reason)
values (1,'2026-07-16','내부수리');

select
    rh.holiday_date,
    rt.name,
    rh.reason
from
    restaurant_holidays rh left outer join
    restaurants rt on rt.restaurant_id = rh.restaurant_id;

#6
-- (가)
INSERT INTO
    restaurant_holidays (restaurant_id, holiday_date)
VALUES (6, '2026-07-16');
-- (나)
INSERT INTO
    restaurant_holidays (restaurant_id, holiday_date)
VALUES (1, '2026-07-15');
-- (다) x 99번 없음
INSERT INTO
    restaurant_holidays (restaurant_id, holiday_date)
VALUES (99, '2026-07-20');
-- (라) x 필수 date 가 없음
INSERT INTO
    restaurant_holidays (restaurant_id, reason)
VALUES (2, '명절');

create table menu_options(
    option_id int not null auto_increment,
    menu_id int not null,
    option_name varchar(50) not null,
    option_price int null default 0,
    constraint pk_option_id primary key (option_id),
    constraint fk_menu_id foreign key (menu_id)
        references menus(menu_id)
        on delete cascade,
    constraint ck_option_price check (option_price >= 0),
    constraint uq_options_name unique (option_name)
);
insert into
menu_options
values (null,35,'곱빼기', '1000');
insert into
    menu_options
values (null,35,'계란 프라이', '1500');
insert into
    menu_options
values (null,35,'면추가없음', '00');
select
    m.name,
    option_name,
    option_price + m.price as price_with_option
from
    menu_options mo left outer join
        menus m on m.menu_id = mo.menu_id;

#8
create table rider_settlements(
    settlements_id int not null auto_increment,
    rider_id int not null,
    settlements_name varchar(255) not null,
    settlements_paid tinyint(1) not null default 0 check (settlements_paid in (1, 0)),
    settlements_month varchar(10) not null
        check (settlements_month
                   REGEXP ('^[0-9]{4}-(0[1-9]|1[0-2])$') ),
    settlements_count int not null default 0 check ( settlements_count >= 0 ),
    settlements_amount int not null default 0 check ( settlements_amount >= 0 ),
    constraint pk_settlements_id primary key (settlements_id),
    constraint fk_rider_id
        foreign key (rider_id)
            references riders(rider_id),
    constraint uq_settlements_month unique (rider_id, settlements_month)

 );
desc rider_settlements;



