-- Ch07에서 설계한 쿠폰 테이블 (최종본) + 6월 말 발급 데이터
-- Ch08부터 모든 챕터의 setup.sql에 포함됩니다.

CREATE TABLE coupons (
    coupon_id        INT          NOT NULL AUTO_INCREMENT  COMMENT '쿠폰 번호',
    code             VARCHAR(20)  NOT NULL                 COMMENT '쿠폰 코드',
    name             VARCHAR(50)  NOT NULL                 COMMENT '쿠폰 이름',
    discount_type    VARCHAR(10)  NOT NULL                 COMMENT '정액 / 정률',
    discount_value   INT          NOT NULL                 COMMENT '정액: 원, 정률: %',
    max_discount     INT              NULL                 COMMENT '정률 쿠폰 최대 할인액(원)',
    min_order_amount INT          NOT NULL DEFAULT 0       COMMENT '최소 주문 금액(원)',
    valid_days       INT          NOT NULL DEFAULT 30      COMMENT '지급 후 유효 일수',
    is_active        BOOLEAN      NOT NULL DEFAULT TRUE    COMMENT '발급 가능 여부',
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_coupons PRIMARY KEY (coupon_id),
    CONSTRAINT uq_coupons_code UNIQUE (code),
    CONSTRAINT ck_coupons_type CHECK (discount_type IN ('정액', '정률')),
    CONSTRAINT ck_coupons_value CHECK (
        (discount_type = '정액' AND discount_value > 0)
        OR (discount_type = '정률' AND discount_value BETWEEN 1 AND 50)),
    CONSTRAINT ck_coupons_max CHECK (max_discount IS NULL OR max_discount > 0),
    CONSTRAINT ck_coupons_min CHECK (min_order_amount >= 0),
    CONSTRAINT ck_coupons_days CHECK (valid_days > 0)
) COMMENT '쿠폰 종류';

CREATE TABLE customer_coupons (
    customer_coupon_id INT       NOT NULL AUTO_INCREMENT,
    customer_id        INT       NOT NULL,
    coupon_id          INT       NOT NULL,
    issued_at          DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at         DATETIME  NOT NULL,
    used_order_id      INT           NULL                  COMMENT '사용한 주문 (미사용 NULL)',
    CONSTRAINT pk_customer_coupons PRIMARY KEY (customer_coupon_id),
    CONSTRAINT fk_cc_customer FOREIGN KEY (customer_id)   REFERENCES customers (customer_id),
    CONSTRAINT fk_cc_coupon   FOREIGN KEY (coupon_id)     REFERENCES coupons (coupon_id),
    CONSTRAINT fk_cc_order    FOREIGN KEY (used_order_id) REFERENCES orders (order_id),
    CONSTRAINT uq_cc_customer_coupon UNIQUE (customer_id, coupon_id),
    CONSTRAINT uq_cc_used_order UNIQUE (used_order_id),
    CONSTRAINT ck_cc_period CHECK (expires_at > issued_at)
) COMMENT '고객 보유 쿠폰';

INSERT INTO coupons (coupon_id, code, name, discount_type, discount_value, max_discount, min_order_amount, valid_days, created_at) VALUES
    (1, 'WELCOME3000', '첫 주문 3,000원 할인', '정액', 3000, NULL, 15000, 30, '2026-06-25 10:00:00'),
    (2, 'WEEKEND15',   '주말 15% 할인',         '정률', 15,   5000, 20000, 7,  '2026-06-25 10:00:00'),
    (3, 'VIP5000',     'VIP 5,000원 할인',      '정액', 5000, NULL, 25000, 60, '2026-06-25 10:00:00'),
    (4, 'SORRY2000',   '불편 보상 2,000원',     '정액', 2000, NULL, 0,     30, '2026-06-25 10:00:00');

INSERT INTO customer_coupons (customer_id, coupon_id, issued_at, expires_at) VALUES
    (30, 1, '2026-06-28 16:30:00', '2026-07-28 16:30:00'),
    (28, 1, '2026-06-29 09:00:00', '2026-07-29 09:00:00'),
    (29, 1, '2026-06-29 09:00:00', '2026-07-29 09:00:00'),
    (1,  3, '2026-06-30 09:00:00', '2026-08-29 09:00:00'),
    (2,  3, '2026-06-30 09:00:00', '2026-08-29 09:00:00'),
    (3,  3, '2026-06-30 09:00:00', '2026-08-29 09:00:00'),
    (5,  2, '2026-06-27 00:00:00', '2026-07-04 00:00:00'),
    (6,  2, '2026-06-27 00:00:00', '2026-07-04 00:00:00');

SELECT 'coupons' AS table_name, COUNT(*) AS row_count FROM coupons
UNION ALL SELECT 'customer_coupons', COUNT(*) FROM customer_coupons;
