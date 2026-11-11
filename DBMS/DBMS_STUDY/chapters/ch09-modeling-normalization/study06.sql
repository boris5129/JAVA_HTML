select
    *
from
    ex_rider_sheet;
create table ex_rider_sheet_2(
    rider_id int primary key auto_increment,
    rider_name varchar(20) not null,
    phone varchar(20) not null,
    zone varchar(20) not null
);

insert into ex_rider_sheet_2
values
    (default, '곽태호', '010-3105-2205', '해운대'),
    (default, '곽태호', '010-3105-2205', '송정'),
    (default, '노지환', '010-3102-2202', '서면'),
    (default, '노지환', '010-3102-2202', '부전');

insert into ex_rider_sheet_2
select
    0,
    rider_name,
    phone,
    substring_index(substring_index(ers.zones, ', ', seq.n), ', ', -1) as zone
from                                                #seq의 n을 잘라라
    ex_rider_sheet ers
    inner join(select 1 as n            # n은 1 2 3 4 5
               union all select 2       #행을 몇개 할건가 이다
               union all select 3
               union all select 4
               union all select 5) seq
    on seq.n <= (char_length(ers.zones) - char_length(replace(ers.zones, ', ', '')))/2 + 1
;

select
    *
from
    ex_rider_sheet_2;
create table ex_riders(
    rider_id int primary key auto_increment,
    name varchar(20) not null,
    phone varchar(20) not null
);
create table ex_riding_zones(
    riding_zone_id int primary key auto_increment,
    rider_id int not null,
    zone_id int not null
);

create table ex_zones(
    zone_id int primary key not null,
    name varchar(20) not null
);

select
    *
from
    ex_coupon_sheet;

create table ex_coupons(
    coupon_id int primary key not null auto_increment,
    coupon_code varchar(20) not null,
    coupon_name varchar(20) not null,
    discount_amount int not null
);

create table ex_coupon_customers(
    customer_id int primary key auto_increment not null ,
    customer_phone varchar(20) not null,
    customer_name varchar(20) not null
);

create table ex_customer_coupons(
    customer_coupon_id int primary key auto_increment not null ,
    customer_id int not null,
    coupon_id int not null,
    used_at datetime null
);

show tables;

insert into ex_coupon_customers
select
    distinct
    null,
    customer_phone,
    customer_name
from
    ex_coupon_sheet;

insert into ex_coupons
select
    distinct
    null,
    coupon_code,
    coupon_name,
    discount_amount
from
    ex_coupon_sheet;

insert into ex_customer_coupons
select
    distinct
    null,
    ec.customer_id,
    e.coupon_id,
    ecs.used_at
from
    ex_coupon_sheet ecs
    left outer join ex_coupon_customers ec
    on ecs.customer_name = ec.customer_name
           and ec.customer_phone = ecs.customer_phone
    left outer join ex_coupons e
    on e.coupon_code = ecs.coupon_code;

select * from ex_coupon_sheet;
select * from ex_coupon_customers;
select * from ex_coupons;

select * from ex_coupon_sheet;

SELECT
    coupon_code,
    COUNT(*)
FROM ex_coupons
GROUP BY coupon_code;

#도서관 도서(표지) 출판사 카테고리

CREATE TABLE books (
                       book_id INT AUTO_INCREMENT PRIMARY KEY,
                       book_type VARCHAR(20) NOT NULL,
                       isbn VARCHAR(20) NULL,
                       name TEXT NOT NULL,
                       author_name VARCHAR(255) NULL,
                       publisher_id INT NULL,
                       poster_url TEXT NULL
);

create table libraries(
    libraries_id int auto_increment primary key not null,
    name varchar(50) not null,
    site_url text null
);
create table publishers(
    publishers_id int auto_increment primary key not null,
    name varchar(50) null
);
create table categories(
    categories_id int auto_increment primary key not null,
    name varchar(20) not null
);
create table registration_books(
    registration_books int auto_increment primary key not null,
    libraries_id int not null,
    book_id int not null,
    categories_id int not null
);

insert into publishers
select
    distinct
    null,
    출판사
from
    book_flat
where
    출판사 is not null
order by 출판사;

select
    *from
         categories;
insert into categories
select
    distinct
    null,
    카테고리
from
    book_flat
order by
    카테고리;
insert into libraries
select
    distinct
    null,
    도서관명,
    `도서관홈페이지 주소`
from
    book_flat;
select *from libraries;

insert into books
select
    distinct
    null,
    `형식(전자책)`,
    국제표준도서번호,
    도서명,
    저자명,
    pb.publishers_id,
    표지주소
from
    book_flat bf
    left outer join publishers pb
    on pb.name = bf.출판사;

truncate table registration_books;
insert into registration_books
select
    null,
    libraries_id,
    book_id,
    categories_id
from
    book_flat bf
    left outer join libraries lb
    on lb.name = bf.도서관명
    left outer join books bk
    on bk.name = bf.도서명
           and ifnull(bk.author_name,'') = ifnull(bf.저자명,'')
            and ifnull(bk.isbn,'') = ifnull(bf.국제표준도서번호,'')
            and bk.poster_url = bf.표지주소
    inner join categories ca
    on ca.name = bf.카테고리;

select
    *
from
    registration_books rb
    left outer join  books bk
    on bk.book_id = rb.book_id;

select
    *
from
    subject_flat;

insert into majors(
select
    distinct
    null,
    개설학과코드
from
    subject_flat);

create table majors(
    major_id int auto_increment primary key ,
    name varchar(50) not null
);

insert into professors(
select
    distinct
    null,
    대표교원번호
from
    subject_flat
where
    대표교원번호 is not null);

truncate professors;

create table professors(
    professor_id int auto_increment primary key ,
    professor_code varchar(50) not null
);

insert into subjects(
select
    null,
    교과목코드,
    ifnull(교과목명, '교과목명없음'),
    mj.major_id
from
    subject_flat sf
    left join  majors mj on mj.name = sf.개설학과코드);

create table subjects(
    subject_id int auto_increment primary key,
    subject_code varchar(20) not null,
    name varchar(50) not null,
    major_id int null
);

create table courses(
    course_id int auto_increment primary key,
    year varchar(4) not null,
    semester varchar(10) not null,
    major_id int not null,
    subject_id int null,
    professor_id int null,
    class_div varchar(10) not null,
    credit int null,
    theory_hour int null,
    practice_hour int null
);
truncate courses;

insert into courses(
select
    distinct
    null,
    년도,
    학기구분,
    mj.major_id,
    subject_id,
    professor_id,
    반코드구분,
    학점,
    이론시간,
    실습시간
from
    subject_flat sf
    left join majors mj
        on mj.name = sf.개설학과코드
    left join subjects sj
    on sj.subject_code = sf.교과목코드
    and sj.major_id = mj.major_id
    left join professors pf
    on pf.professor_code = sf.대표교원번호);
#수가 너무많음 체크 필요
select
    count(*)
from
    courses