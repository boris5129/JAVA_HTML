-- @this-chapter-only  정규화 실습용 '엑셀 주문장' (Ch09 전용)
-- 한입배달 초창기, 정산팀이 DB 없이 엑셀 한 장으로 주문을 관리하던 시절의 모양을 재현합니다.
-- 6월 배달완료 주문으로 채웁니다.

-- ① 한 주문 = 한 행, 메뉴는 한 칸에 몰아 쓰기 (1NF 위반)
CREATE TABLE order_sheet (
    order_id         INT           NOT NULL  COMMENT '주문 번호',
    ordered_at       DATETIME      NOT NULL  COMMENT '주문 일시',
    customer_name    VARCHAR(20)   NOT NULL  COMMENT '고객 이름',
    customer_phone   CHAR(13)      NOT NULL  COMMENT '고객 전화',
    customer_grade   VARCHAR(10)   NOT NULL  COMMENT '고객 등급',
    restaurant_name  VARCHAR(50)   NOT NULL  COMMENT '가게 이름',
    restaurant_phone VARCHAR(13)       NULL  COMMENT '가게 전화',
    menu_list        VARCHAR(300)  NOT NULL  COMMENT '메뉴 (이름 수량, …)',
    delivery_fee     INT           NOT NULL  COMMENT '배달팁',
    CONSTRAINT pk_order_sheet PRIMARY KEY (order_id)
) COMMENT '엑셀 주문장 — 비정규형';

INSERT INTO order_sheet
SELECT o.order_id, o.ordered_at, c.name, c.phone, c.grade, r.name, r.phone,
    GROUP_CONCAT(CONCAT(m.name, ' ', oi.quantity) ORDER BY oi.menu_id SEPARATOR ', '),
    o.delivery_fee
FROM orders o
JOIN customers   c  ON o.customer_id   = c.customer_id
JOIN restaurants r  ON o.restaurant_id = r.restaurant_id
JOIN order_items oi ON o.order_id      = oi.order_id
JOIN menus       m  ON oi.menu_id      = m.menu_id
WHERE o.status = '배달완료' AND o.ordered_at >= '2026-06-01'
GROUP BY o.order_id;

-- ② 메뉴 한 줄 = 한 행 (1NF는 만족, 2NF 위반)
CREATE TABLE order_flat (
    order_id         INT           NOT NULL  COMMENT '주문 번호',
    menu_name        VARCHAR(50)   NOT NULL  COMMENT '메뉴 이름',
    ordered_at       DATETIME      NOT NULL  COMMENT '주문 일시',
    customer_name    VARCHAR(20)   NOT NULL  COMMENT '고객 이름',
    customer_phone   CHAR(13)      NOT NULL  COMMENT '고객 전화',
    customer_grade   VARCHAR(10)   NOT NULL  COMMENT '고객 등급',
    restaurant_name  VARCHAR(50)   NOT NULL  COMMENT '가게 이름',
    restaurant_phone VARCHAR(13)       NULL  COMMENT '가게 전화',
    quantity         INT           NOT NULL  COMMENT '수량',
    unit_price       INT           NOT NULL  COMMENT '단가',
    delivery_fee     INT           NOT NULL  COMMENT '배달팁',
    CONSTRAINT pk_order_flat PRIMARY KEY (order_id, menu_name)
) COMMENT '엑셀 주문장 — 메뉴별 행';

INSERT INTO order_flat
SELECT o.order_id, m.name, o.ordered_at, c.name, c.phone, c.grade, r.name, r.phone,
    oi.quantity, oi.unit_price, o.delivery_fee
FROM orders o
JOIN customers   c  ON o.customer_id   = c.customer_id
JOIN restaurants r  ON o.restaurant_id = r.restaurant_id
JOIN order_items oi ON o.order_id      = oi.order_id
JOIN menus       m  ON oi.menu_id      = m.menu_id
WHERE o.status = '배달완료' AND o.ordered_at >= '2026-06-01';

SELECT 'order_sheet' AS table_name, COUNT(*) AS row_count FROM order_sheet
UNION ALL SELECT 'order_flat', COUNT(*) FROM order_flat;
