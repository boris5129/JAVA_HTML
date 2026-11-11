create table customer_details(
    customer_detail_id int auto_increment primary key ,
    customer_id int not null,
    gender varchar(10) null,
    hobby varchar(100) null
);

insert into customers
select
    null,
    '김준일',
    '010-2841-5123',
    'min123.kim@gmail.com',
    '1994-03-12',
    '부산진구',
    '부산광역시 부산진구 전포동 서전로 23, 302호',
    'VIP',
    1,
    now()
from customers where customer_id = 1;

insert into customer_details
    values (null, last_insert_id(), null,null);

delimiter $$
create trigger trg_customers_insert_after
after insert on customers
for each row
begin
    insert into customer_details
    values (null, new.customer_id, null,null);
end $$
delimiter ;

select
    *
from
    customer_details
