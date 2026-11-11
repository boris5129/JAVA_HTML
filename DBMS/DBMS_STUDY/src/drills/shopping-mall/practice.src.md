# 한입마켓 연습문제 20 — JOIN · GROUP BY · 서브쿼리 · 윈도우 함수 · UNION

> 전제: 이 폴더의 `setup.sql` 실행 완료 · `USE hanip_market;`
> 범위: Ch04 집계 · Ch05 JOIN · Ch06 서브쿼리 · 윈도우 함수 + UNION
> 난이도: ★ 기초 · ★★ 응용 · ★★★ 도전 — 각 문제의 **기대 결과**와 내 결과를 비교하세요.
> 모든 문제는 조회만 합니다. 순서와 상관없이 풀어도 됩니다.

**이 문제집의 공통 약속**

| 용어 | 계산 |
|---|---|
| 매출(상품 매출) | `SUM(order_items.quantity * order_items.unit_price)` — **배송완료** 주문만 |
| 주문 금액(결제액) | 그 주문의 상품 매출 + `shipping_fee` − `coupon_discount` |
| 대분류 · 소분류 | 상품은 소분류에 속하고, 소분류의 `parent_id`가 대분류 |
| 날짜 범위 | `ordered_at >= '시작' AND ordered_at < '다음 시작'` (반열린 구간) |

---

## PART A. JOIN + GROUP BY

### 문제 1. 대분류별 매출 ★

> **MD팀** 대분류(패션 · 디지털 · 식품 · 생활)별로 배송완료 주문 건수, 판매 수량, 매출을 보여 주세요.
> 힌트: 상품 → 소분류 → 대분류. `categories`를 **두 번**(소분류 · 대분류) JOIN합니다.

- 열: `main_category`, `orders`, `quantity`, `sales`
- 순서: `sales` 내림차순

```sql answer
SELECT main.name AS main_category,
    COUNT(DISTINCT o.order_id)         AS orders,
    SUM(oi.quantity)                   AS quantity,
    SUM(oi.quantity * oi.unit_price)   AS sales
FROM orders o
JOIN order_items oi ON o.order_id     = oi.order_id
JOIN products p     ON oi.product_id  = p.product_id
JOIN categories sub  ON p.category_id = sub.category_id
JOIN categories main ON sub.parent_id = main.category_id
WHERE o.status = '배송완료'
GROUP BY main.category_id, main.name
ORDER BY sales DESC;
```

<!-- a:start -->
> **해설** 같은 테이블을 역할이 다른 두 별칭(`sub`, `main`)으로 JOIN하는 **셀프 조인**입니다. 주문 한 건에 대분류가 같은 상품이 여러 개면 행이 여러 개가 되므로 주문 건수는 `COUNT(DISTINCT o.order_id)`로 셉니다. `COUNT(*)`로 세면 "주문 상세 줄 수"가 나옵니다.
<!-- a:end -->

### 문제 2. 지역별 구매 전환율 ★★

> **마케팅팀** 지역별로 회원 수, **배송완료 주문이 한 번이라도 있는** 회원 수, 구매 전환율(%)을 구해 주세요.
> 주문이 없는 회원도 회원 수에는 들어가야 합니다.

- 열: `region`, `members`, `buyers`, `conversion_rate` (소수 첫째 자리)
- 순서: `conversion_rate` 내림차순 → `region`

```sql answer
SELECT m.region,
    COUNT(DISTINCT m.member_id) AS members,
    COUNT(DISTINCT o.member_id) AS buyers,
    ROUND(COUNT(DISTINCT o.member_id) / COUNT(DISTINCT m.member_id) * 100, 1) AS conversion_rate
FROM members m
LEFT JOIN orders o ON o.member_id = m.member_id AND o.status = '배송완료'
GROUP BY m.region
ORDER BY conversion_rate DESC, m.region;
```

<!-- a:start -->
> **해설** `o.status = '배송완료'` 조건을 **ON에** 둔 것이 핵심입니다. WHERE에 두면 주문이 없는 회원(o.status가 NULL)이 걸러져 LEFT JOIN이 INNER JOIN이 되고, 회원 수가 구매 회원 수와 같아져 전환율이 모두 100%가 됩니다(Ch05). `COUNT(DISTINCT o.member_id)`는 NULL을 세지 않으므로 구매 회원만 셉니다.
<!-- a:end -->

### 문제 3. 리뷰로 본 브랜드 품질 ★★

> **품질관리팀** 브랜드별 리뷰 수와 평균 별점을 구하되, **리뷰가 10개 이상**인 브랜드만, 평균 별점이 **낮은** 순으로 보여 주세요. 1~2점 리뷰 비율(%)도 함께.

- 열: `brand`, `reviews`, `avg_rating` (소수 둘째 자리), `low_rating_pct` (소수 첫째 자리)
- 순서: `avg_rating` 오름차순 → `brand`

```sql answer
SELECT p.brand,
    COUNT(*) AS reviews,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    ROUND(SUM(r.rating <= 2) / COUNT(*) * 100, 1) AS low_rating_pct
FROM reviews r
JOIN products p ON r.product_id = p.product_id
GROUP BY p.brand
HAVING COUNT(*) >= 10
ORDER BY avg_rating, p.brand;
```

<!-- a:start -->
> **해설** 집계 결과로 거르는 조건은 `HAVING`입니다. `SUM(r.rating <= 2)`는 MySQL에서 비교 결과가 1/0이라는 점을 이용한 개수 세기로, `SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END)`와 같습니다. 리뷰 수가 적은 브랜드는 평균이 크게 흔들리므로 최소 개수 조건을 거는 것이 실무 습관입니다.
<!-- a:end -->

### 문제 4. 월별 × 결제수단 피벗 ★★

> **재무팀** 2026년 월별로 결제수단별 **결제 건수**를 가로로 펼친 표가 필요합니다. 취소 · 반품 주문은 제외합니다.

- 열: `ym` (`'2026-01'` 형식), `card`, `easy_pay`, `bank_transfer`, `total`
- 순서: `ym`

```sql answer
SELECT DATE_FORMAT(ordered_at, '%Y-%m') AS ym,
    SUM(payment_method = '카드')     AS card,
    SUM(payment_method = '간편결제') AS easy_pay,
    SUM(payment_method = '계좌이체') AS bank_transfer,
    COUNT(*)                         AS total
FROM orders
WHERE status NOT IN ('취소', '반품')
GROUP BY ym
ORDER BY ym;
```

<!-- a:start -->
> **해설** 행으로 나오는 값(결제수단)을 열로 펼치는 것을 **피벗**이라 합니다. MySQL에는 PIVOT 문법이 없어서 조건부 집계(`SUM(조건)` 또는 `SUM(CASE …)`)로 만듭니다. 세 열의 합이 `total`과 같은지 확인해 보세요. 2월이 줄었다가 5월에 가장 많습니다(설 연휴 · 가정의 달).
<!-- a:end -->

### 문제 5. 팔리지 않은 상품 ★★

> **MD팀** 배송완료 기준 판매 수량이 **0인** 상품을 찾아 주세요. 한 번도 주문되지 않은 상품도, 주문은 됐지만 전부 취소 · 반품된 상품도 포함입니다.

- 열: `product_id`, `name`, `is_active`, `stock`, `ordered_qty` (상태와 관계없이 주문된 수량), `sold_qty` (배송완료 수량)
- 순서: `product_id`

```sql answer
SELECT p.product_id, p.name, p.is_active, p.stock,
    COALESCE(SUM(oi.quantity), 0) AS ordered_qty,
    COALESCE(SUM(CASE WHEN o.status = '배송완료' THEN oi.quantity END), 0) AS sold_qty
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o       ON o.order_id    = oi.order_id
GROUP BY p.product_id, p.name, p.is_active, p.stock
HAVING sold_qty = 0
ORDER BY p.product_id;
```

<!-- a:start -->
> **해설** `ordered_qty`가 0이면 한 번도 주문되지 않은 상품, 0보다 크면 주문은 됐지만 **전부 취소 · 반품**된 상품입니다. 흔한 오답은 `WHERE o.status = '배송완료'`를 붙이는 것 — 그러면 팔리지 않은 상품의 행 자체가 사라져 **결과가 0행**이 됩니다. "없는 것"을 찾을 때는 조건을 WHERE가 아니라 집계(CASE) 또는 ON에 둡니다. 서브쿼리로는 이렇게 씁니다.
>
> ```sql
> SELECT p.product_id, p.name FROM products p
> WHERE NOT EXISTS (SELECT 1 FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
>                   WHERE oi.product_id = p.product_id AND o.status = '배송완료');
> ```
<!-- a:end -->

### 문제 6. 단골 회원 요약 ★★★

> **CRM팀** 배송완료 주문이 **10회 이상**인 회원의 이름, 주문 수, 첫 주문일, 마지막 주문일, 평균 주문 금액(결제액)을 구해 주세요.
> 힌트: 주문 금액은 주문 단위로 먼저 계산(FROM절 서브쿼리)한 다음 회원 단위로 다시 묶습니다.

- 열: `name`, `orders`, `first_order`, `last_order` (날짜만), `avg_amount` (정수 반올림)
- 순서: `orders` 내림차순 → `avg_amount` 내림차순

```sql answer
SELECT m.name, COUNT(*) AS orders,
    DATE(MIN(t.ordered_at)) AS first_order,
    DATE(MAX(t.ordered_at)) AS last_order,
    ROUND(AVG(t.amount)) AS avg_amount
FROM (
    SELECT o.order_id, o.member_id, o.ordered_at,
        SUM(oi.quantity * oi.unit_price) + o.shipping_fee - o.coupon_discount AS amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = '배송완료'
    GROUP BY o.order_id, o.member_id, o.ordered_at, o.shipping_fee, o.coupon_discount
) t
JOIN members m ON t.member_id = m.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(*) >= 10
ORDER BY orders DESC, avg_amount DESC;
```

<!-- a:start -->
> **해설** 배송비 · 쿠폰은 **주문당 한 번**인데, 주문 상세와 JOIN한 상태에서 바로 회원별로 묶으면 상세 줄 수만큼 배송비가 중복으로 더해집니다. 그래서 주문 단위로 한 번 집계(안쪽)하고, 그 결과를 회원 단위로 다시 집계(바깥)하는 **2단계 집계**를 씁니다. 이 패턴은 실무 리포트에서 가장 자주 나옵니다.
<!-- a:end -->

---

## PART B. 서브쿼리

### 문제 7. 우리 카테고리 평균보다 비싼 상품 ★

> **MD팀** 판매 중인 상품 가운데 **자기 소분류의 평균 가격보다 비싼** 상품을 보여 주세요. (평균은 그 소분류의 판매 중 상품 기준)

- 열: `category`, `name`, `price`, `category_avg` (정수 반올림)
- 순서: `category_id` → `price` 내림차순

```sql answer
SELECT c.name AS category, p.name, p.price,
    (SELECT ROUND(AVG(p2.price)) FROM products p2
     WHERE p2.category_id = p.category_id AND p2.is_active) AS category_avg
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active
  AND p.price > (SELECT AVG(p2.price) FROM products p2
                 WHERE p2.category_id = p.category_id AND p2.is_active)
ORDER BY p.category_id, p.price DESC;
```

<!-- a:start -->
> **해설** 바깥 행의 `p.category_id`를 안쪽에서 참조하는 **상관 서브쿼리**입니다. 바깥 행이 바뀔 때마다 그 소분류의 평균을 다시 계산합니다. 같은 서브쿼리를 SELECT와 WHERE에 두 번 쓰는 것이 번거롭다면, 소분류별 평균을 FROM절 서브쿼리(또는 CTE)로 한 번 만들어 JOIN하는 방법도 있습니다.
<!-- a:end -->

### 문제 8. 찜만 하고 사지 않은 상품 ★★

> **마케팅팀** 회원이 **찜해 두고 아직 한 번도 산 적 없는**(배송완료 기준) 상품 목록을 주세요. 리마인드 쿠폰을 보낼 대상입니다. 판매 중인 상품만.

- 열: `member_name`, `product_name`, `price`, `added_at` (날짜만)
- 순서: `added_at` → `member_name`

```sql answer
SELECT m.name AS member_name, p.name AS product_name, p.price, DATE(w.added_at) AS added_at
FROM wishlists w
JOIN members m  ON w.member_id  = m.member_id
JOIN products p ON w.product_id = p.product_id
WHERE p.is_active
  AND NOT EXISTS (
        SELECT 1
        FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.member_id = w.member_id
          AND oi.product_id = w.product_id
          AND o.status = '배송완료')
ORDER BY w.added_at, m.name;
```

<!-- a:start -->
> **해설** "~한 적이 없다"는 `NOT EXISTS`가 가장 정확합니다. `NOT IN (서브쿼리)`로도 쓸 수 있지만, 서브쿼리 결과에 NULL이 하나라도 섞이면 전체가 거짓이 되는 함정이 있습니다(Ch06). 회원과 상품 **두 열**을 함께 비교해야 하므로 상관 서브쿼리가 자연스럽습니다.
<!-- a:end -->

### 문제 9. 평균의 두 배가 넘는 큰 주문 ★★

> **재무팀** 결제액이 **전체 배송완료 주문 평균 결제액의 2배 이상**인 주문을 찾아 주세요.

- 열: `order_id`, `member_name`, `ordered_at` (날짜만), `amount`
- 순서: `amount` 내림차순

```sql answer
WITH order_amounts AS (
    SELECT o.order_id, o.member_id, o.ordered_at,
        SUM(oi.quantity * oi.unit_price) + o.shipping_fee - o.coupon_discount AS amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = '배송완료'
    GROUP BY o.order_id, o.member_id, o.ordered_at, o.shipping_fee, o.coupon_discount
)
SELECT a.order_id, m.name AS member_name, DATE(a.ordered_at) AS ordered_at, a.amount
FROM order_amounts a
JOIN members m ON a.member_id = m.member_id
WHERE a.amount >= 2 * (SELECT AVG(amount) FROM order_amounts)
ORDER BY a.amount DESC;
```

<!-- a:start -->
> **해설** `WITH`(CTE)로 주문 금액표를 한 번 만들어 두고, 같은 표를 WHERE의 **스칼라 서브쿼리**에서 다시 써서 평균을 구했습니다. 평균을 미리 숫자로 구해 쿼리에 적어 넣으면 데이터가 바뀔 때마다 틀린 답이 됩니다. 결과를 보면 고가 디지털 상품이 들어 있거나 같은 상품을 여러 개 산 주문들입니다.
<!-- a:end -->

### 문제 10. 소분류별 최고가 상품 ★★

> **MD팀** 소분류마다 **가장 비싼** 상품을 보여 주세요. 같은 가격이 여럿이면 모두.

- 열: `category`, `name`, `brand`, `price`
- 순서: `category_id`

```sql answer
SELECT c.name AS category, p.name, p.brand, p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE (p.category_id, p.price) IN (
        SELECT category_id, MAX(price)
        FROM products
        GROUP BY category_id)
ORDER BY p.category_id;
```

<!-- a:start -->
> **해설** 두 열을 짝으로 비교하는 **다중 열 서브쿼리**입니다. `WHERE p.price IN (SELECT MAX(price) … GROUP BY category_id)`처럼 가격만 비교하면, 다른 소분류의 최고가와 우연히 같은 가격인 상품까지 잡히는 오답이 됩니다. 같은 문제를 윈도우 함수 `RANK() OVER (PARTITION BY category_id ORDER BY price DESC) = 1`로도 풀 수 있습니다(PART C).
<!-- a:end -->

### 문제 11. 베스트셀러를 산 회원 ★★★

> **CRM팀** 배송완료 기준 **판매 수량 1위 상품**(공동 1위면 모두)을 산 회원과, 그 상품을 몇 번 주문했는지 알려 주세요.

- 열: `product_name`, `member_name`, `region`, `times`
- 순서: `times` 내림차순 → `member_name`

```sql answer
SELECT p.name AS product_name, m.name AS member_name, m.region, COUNT(*) AS times
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN members m      ON o.member_id = m.member_id
JOIN products p     ON oi.product_id = p.product_id
WHERE o.status = '배송완료'
  AND oi.product_id IN (
        SELECT oi2.product_id
        FROM order_items oi2 JOIN orders o2 ON oi2.order_id = o2.order_id
        WHERE o2.status = '배송완료'
        GROUP BY oi2.product_id
        HAVING SUM(oi2.quantity) = (
            SELECT MAX(total_qty) FROM (
                SELECT SUM(oi3.quantity) AS total_qty
                FROM order_items oi3 JOIN orders o3 ON oi3.order_id = o3.order_id
                WHERE o3.status = '배송완료'
                GROUP BY oi3.product_id) best))
GROUP BY p.product_id, p.name, m.member_id, m.name, m.region
ORDER BY times DESC, member_name;
```

<!-- a:start -->
> **해설** 서브쿼리가 세 겹입니다. 안쪽부터 읽으세요: ① 상품별 판매 수량 → ② 그중 최댓값 → ③ 판매 수량이 그 최댓값과 같은 상품(공동 1위 대비) → 바깥: 그 상품을 산 회원. `ORDER BY … LIMIT 1`로 1위를 구하면 공동 1위를 놓칩니다. 너무 깊어진다 싶으면 CTE로 단계마다 이름을 붙이면 훨씬 읽기 쉬워집니다.
<!-- a:end -->

---

## PART C. 윈도우 함수

### 문제 12. 대분류 안 매출 TOP 2 ★★

> **MD팀** 대분류마다 매출 상위 **2개** 상품을 보여 주세요. 순위는 `RANK()`(공동 순위 허용).

- 열: `main_category`, `rnk`, `product_name`, `sales`
- 순서: `main_category` → `rnk` → `product_name`

```sql answer
WITH product_sales AS (
    SELECT main.name AS main_category, p.name AS product_name,
        SUM(oi.quantity * oi.unit_price) AS sales
    FROM orders o
    JOIN order_items oi  ON o.order_id     = oi.order_id
    JOIN products p      ON oi.product_id  = p.product_id
    JOIN categories sub  ON p.category_id  = sub.category_id
    JOIN categories main ON sub.parent_id  = main.category_id
    WHERE o.status = '배송완료'
    GROUP BY main.name, p.product_id, p.name
), ranked AS (
    SELECT main_category, product_name, sales,
        RANK() OVER (PARTITION BY main_category ORDER BY sales DESC) AS rnk
    FROM product_sales
)
SELECT main_category, rnk, product_name, sales
FROM ranked
WHERE rnk <= 2
ORDER BY main_category, rnk, product_name;
```

<!-- a:start -->
> **해설** "그룹마다 상위 N개"는 윈도우 함수의 대표 문제입니다. 윈도우 함수 결과는 WHERE에서 바로 쓸 수 없으므로(실행 순서상 SELECT 단계에서 계산됨) 한 번 감싼 뒤 바깥에서 거릅니다. `RANK`는 공동 순위 다음 번호를 건너뛰고(1, 1, 3), `DENSE_RANK`는 건너뛰지 않으며(1, 1, 2), `ROW_NUMBER`는 공동 순위가 없습니다.
<!-- a:end -->

### 문제 13. 전월 대비 매출 증감 ★★

> **경영지원팀** 월별 매출과 **전월 대비 증감액 · 증감률(%)**을 구해 주세요. 1월은 비교 대상이 없으므로 NULL.

- 열: `ym`, `sales`, `prev_sales`, `diff`, `growth_pct` (소수 첫째 자리)
- 순서: `ym`

```sql answer
WITH monthly AS (
    SELECT DATE_FORMAT(o.ordered_at, '%Y-%m') AS ym,
        SUM(oi.quantity * oi.unit_price) AS sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = '배송완료'
    GROUP BY ym
)
SELECT ym, sales,
    LAG(sales) OVER (ORDER BY ym) AS prev_sales,
    sales - LAG(sales) OVER (ORDER BY ym) AS diff,
    ROUND((sales - LAG(sales) OVER (ORDER BY ym)) / LAG(sales) OVER (ORDER BY ym) * 100, 1) AS growth_pct
FROM monthly
ORDER BY ym;
```

<!-- a:start -->
> **해설** `LAG(열)`은 정렬 기준으로 **바로 앞 행**의 값을 가져옵니다(`LEAD`는 다음 행). 6월이 크게 줄어든 것처럼 보이는 이유도 생각해 보세요: 기준 시점(6/30)에 아직 **결제완료 · 배송중**인 주문은 배송완료 매출에서 빠져 있습니다. 마감되지 않은 달을 그대로 비교하면 잘못된 결론을 냅니다. 같은 `OVER (ORDER BY ym)`를 여러 번 쓰는 것이 길다면 `WINDOW w AS (ORDER BY ym)`로 이름을 붙이고 `LAG(sales) OVER w`처럼 쓸 수 있습니다(MySQL 8).
<!-- a:end -->

### 문제 14. 누적 구매액과 VIP 도달 시점 ★★

> **CRM팀** 1번 회원(최서연 님)의 배송완료 주문을 시간순으로 나열하고, 주문마다 **결제액 · 누적 결제액 · 주문 순번**을 보여 주세요. 누적 50만 원을 처음 넘은 주문이 VIP 도달 시점입니다.

- 열: `order_seq`, `order_id`, `ordered_at` (날짜만), `amount`, `running_total`, `vip_reached` ('VIP 달성' 또는 NULL)
- 순서: `order_seq`

```sql answer limit=20
WITH amounts AS (
    SELECT o.order_id, o.ordered_at,
        SUM(oi.quantity * oi.unit_price) + o.shipping_fee - o.coupon_discount AS amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = '배송완료' AND o.member_id = 1
    GROUP BY o.order_id, o.ordered_at, o.shipping_fee, o.coupon_discount
), running AS (
    SELECT ROW_NUMBER() OVER (ORDER BY ordered_at) AS order_seq,
        order_id, ordered_at, amount,
        SUM(amount) OVER (ORDER BY ordered_at) AS running_total
    FROM amounts
)
SELECT order_seq, order_id, DATE(ordered_at) AS ordered_at, amount, running_total,
    CASE WHEN running_total >= 500000 AND running_total - amount < 500000 THEN 'VIP 달성' END AS vip_reached
FROM running
ORDER BY order_seq;
```

<!-- a:start -->
> **해설** `SUM(…) OVER (ORDER BY …)`는 **처음부터 현재 행까지**의 합(누적 합)입니다. "처음 넘은 행"은 `누적 ≥ 기준 AND 직전 누적(= 누적 − 이번 금액) < 기준`으로 찾습니다. `LAG(running_total)`로 직전 누적을 가져와도 됩니다.
<!-- a:end -->

### 문제 15. 첫 구매는 어떤 카테고리였나 ★★★

> **마케팅팀** 회원마다 **첫 배송완료 주문의 첫 상품**(주문 상세 번호가 가장 작은 것)이 어느 대분류였는지 구하고, 대분류별 회원 수를 세어 주세요. 신규 회원 유입 상품군을 보려는 것입니다.

- 열: `first_main_category`, `members`, `pct` (전체 대비 %, 소수 첫째 자리)
- 순서: `members` 내림차순 → `first_main_category`

```sql answer
WITH firsts AS (
    SELECT o.member_id, main.name AS main_category,
        ROW_NUMBER() OVER (PARTITION BY o.member_id ORDER BY o.ordered_at, oi.order_item_id) AS rn
    FROM orders o
    JOIN order_items oi  ON o.order_id     = oi.order_id
    JOIN products p      ON oi.product_id  = p.product_id
    JOIN categories sub  ON p.category_id  = sub.category_id
    JOIN categories main ON sub.parent_id  = main.category_id
    WHERE o.status = '배송완료'
)
SELECT main_category AS first_main_category, COUNT(*) AS members,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 1) AS pct
FROM firsts
WHERE rn = 1
GROUP BY main_category
ORDER BY members DESC, first_main_category;
```

<!-- a:start -->
> **해설** `ROW_NUMBER() OVER (PARTITION BY 회원 ORDER BY 시간)` = 1 은 "회원별 첫 번째"를 뽑는 정석입니다. 마지막 줄의 `SUM(COUNT(*)) OVER ()`는 **집계 결과 위에 다시 윈도우 함수**를 쓴 것으로, GROUP BY로 묶인 행들의 전체 합계를 구해 비율을 냅니다(`OVER ()` = 전체를 하나의 창으로).
<!-- a:end -->

### 문제 16. 가격대 4구간 ★★

> **MD팀** 전체 상품을 가격순으로 **4구간**(NTILE)으로 나누고, 구간마다 상품 수 · 최저가 · 최고가 · 그 구간 상품의 배송완료 판매 수량 합계를 보여 주세요.

- 열: `price_band` (1 = 가장 저렴), `products`, `min_price`, `max_price`, `sold_qty`
- 순서: `price_band`

```sql answer
WITH banded AS (
    SELECT product_id, price,
        NTILE(4) OVER (ORDER BY price, product_id) AS price_band
    FROM products
), sold AS (
    SELECT oi.product_id, SUM(oi.quantity) AS qty
    FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = '배송완료'
    GROUP BY oi.product_id
)
SELECT b.price_band, COUNT(*) AS products,
    MIN(b.price) AS min_price, MAX(b.price) AS max_price,
    COALESCE(SUM(s.qty), 0) AS sold_qty
FROM banded b
LEFT JOIN sold s ON b.product_id = s.product_id
GROUP BY b.price_band
ORDER BY b.price_band;
```

<!-- a:start -->
> **해설** `NTILE(n)`은 정렬된 행을 n개 그룹으로 최대한 고르게 나눕니다(나머지가 있으면 앞 그룹이 하나씩 더 큼). 같은 가격의 상품이 구간 경계에서 갈리지 않도록 정렬 기준에 `product_id`를 더해 결과를 고정했습니다. 판매량을 상품별로 먼저 집계(`sold`)한 뒤 붙여야 판매가 없는 상품도 구간에 남습니다.
<!-- a:end -->

---

## PART D. UNION

### 문제 17. 탈퇴 회원까지 포함한 분기별 가입자 ★

> **경영지원팀** 회원은 현재 회원(`members`)과 탈퇴 회원(`withdrawn_members`) 두 테이블에 나뉘어 있습니다. 둘을 합쳐 **분기별 가입자 수**를 구하고, 그중 탈퇴한 사람이 몇 명인지도 보여 주세요.

- 열: `join_quarter` (`'2025-Q1'` 형식), `joined`, `withdrawn`
- 순서: `join_quarter`

```sql answer
SELECT CONCAT(YEAR(joined_at), '-Q', QUARTER(joined_at)) AS join_quarter,
    COUNT(*) AS joined,
    SUM(is_withdrawn) AS withdrawn
FROM (
    SELECT joined_at, 0 AS is_withdrawn FROM members
    UNION ALL
    SELECT joined_at, 1 FROM withdrawn_members
) all_members
GROUP BY join_quarter
ORDER BY join_quarter;
```

<!-- a:start -->
> **해설** `UNION ALL`로 두 테이블을 세로로 이어 붙인 뒤 그 결과를 묶었습니다. 어느 테이블에서 왔는지 표시하는 **상수 열**(`0`, `1`)을 붙이는 것이 요령입니다. 열 이름은 첫 번째 SELECT의 것을 따르므로 두 번째 SELECT의 `1`에는 별칭이 없어도 됩니다. 중복을 지우는 `UNION`을 쓰면 같은 분기에 가입한 사람들이 하나로 합쳐질 위험이 있습니다 — 여기서는 반드시 `UNION ALL`.
<!-- a:end -->

### 문제 18. 회원 활동 타임라인 ★★

> **CS팀** 33번 회원(장서연 님)의 **6월** 활동을 하나의 타임라인으로 보여 주세요: 주문(상태 포함), 리뷰(별점 포함), 찜, 장바구니 담기.

- 열: `activity_at`, `activity`, `detail`
- `activity`: '주문' · '리뷰' · '찜' · '장바구니' / `detail`: 주문은 `'주문 #번호 (상태)'`, 리뷰는 `'상품명 ★별점'`, 찜과 장바구니는 상품명
- 순서: `activity_at`

```sql answer
SELECT ordered_at AS activity_at, '주문' AS activity,
    CONCAT('주문 #', order_id, ' (', status, ')') AS detail
FROM orders
WHERE member_id = 33 AND ordered_at >= '2026-06-01'
UNION ALL
SELECT r.created_at, '리뷰', CONCAT(p.name, ' ★', r.rating)
FROM reviews r JOIN products p ON r.product_id = p.product_id
WHERE r.member_id = 33 AND r.created_at >= '2026-06-01'
UNION ALL
SELECT w.added_at, '찜', p.name
FROM wishlists w JOIN products p ON w.product_id = p.product_id
WHERE w.member_id = 33 AND w.added_at >= '2026-06-01'
UNION ALL
SELECT c.added_at, '장바구니', p.name
FROM carts c JOIN products p ON c.product_id = p.product_id
WHERE c.member_id = 33 AND c.added_at >= '2026-06-01'
ORDER BY activity_at;
```

<!-- a:start -->
> **해설** 구조가 전혀 다른 네 테이블도 **열 개수와 의미만 맞추면** 하나로 이을 수 있습니다. `ORDER BY`는 UNION 전체에 한 번만, **맨 마지막에** 쓰고, 열 이름은 첫 번째 SELECT의 별칭(`activity_at`)을 씁니다. 각 SELECT에 따로 정렬을 쓰려면 괄호로 감싸야 하고, 그래도 전체 순서는 보장되지 않습니다.
<!-- a:end -->

### 문제 19. 관심 상품 — UNION vs UNION ALL ★★

> **데이터팀** 찜 또는 장바구니에 들어 있는 **(회원, 상품) 쌍**을 세려고 합니다. 다음 세 숫자를 한 번에 보여 주세요.
> ① 두 목록을 그대로 이어 붙인 행 수 ② 중복을 제거한 관심 쌍 수 ③ 찜과 장바구니 **둘 다**에 있는 쌍 수

- 열: `union_all_rows`, `union_rows`, `in_both`

```sql answer
SELECT
    (SELECT COUNT(*) FROM (
        SELECT member_id, product_id FROM wishlists
        UNION ALL
        SELECT member_id, product_id FROM carts) a) AS union_all_rows,
    (SELECT COUNT(*) FROM (
        SELECT member_id, product_id FROM wishlists
        UNION
        SELECT member_id, product_id FROM carts) u) AS union_rows,
    (SELECT COUNT(*) FROM wishlists w
     WHERE EXISTS (SELECT 1 FROM carts c
                   WHERE c.member_id = w.member_id AND c.product_id = w.product_id)) AS in_both;
```

<!-- a:start -->
> **해설** `union_all_rows − union_rows = in_both`가 성립하는지 확인해 보세요. 둘 다에 있는 쌍이 `UNION ALL`에서는 두 번, `UNION`에서는 한 번 세어지기 때문입니다. `UNION`은 중복 제거를 위해 정렬·비교 작업이 추가되므로, 중복이 없다고 확신하거나 중복도 세어야 할 때는 `UNION ALL`이 빠릅니다. MySQL 8.0.31부터는 ③을 `INTERSECT`로도 구할 수 있습니다.
<!-- a:end -->

### 문제 20. 지역별 매출 리포트 + 합계 행 ★★★

> **경영지원팀** 회원 지역별 배송완료 **결제액 합계 · 주문 수 · 객단가 · 매출 비중(%)**을 구하고, 맨 아래에 **'합계'** 행을 붙여 주세요. 합계 행은 항상 마지막이어야 합니다.

- 열: `region`, `orders`, `revenue`, `avg_order`, `share_pct` (소수 첫째 자리; 합계 행은 100.0)
- 순서: 지역 행은 `revenue` 내림차순, 합계 행은 맨 마지막

```sql answer
WITH order_amounts AS (
    SELECT o.order_id, m.region,
        SUM(oi.quantity * oi.unit_price) + o.shipping_fee - o.coupon_discount AS amount
    FROM orders o
    JOIN order_items oi ON o.order_id  = oi.order_id
    JOIN members m      ON o.member_id = m.member_id
    WHERE o.status = '배송완료'
    GROUP BY o.order_id, m.region, o.shipping_fee, o.coupon_discount
), by_region AS (
    SELECT region, COUNT(*) AS orders, SUM(amount) AS revenue
    FROM order_amounts
    GROUP BY region
)
SELECT region, orders, revenue, avg_order, share_pct
FROM (
    SELECT 1 AS sort_key, region, orders, revenue,
        ROUND(revenue / orders) AS avg_order,
        ROUND(revenue / SUM(revenue) OVER () * 100, 1) AS share_pct
    FROM by_region
    UNION ALL
    SELECT 2, '합계', SUM(orders), SUM(revenue), ROUND(SUM(revenue) / SUM(orders)), 100.0
    FROM by_region
) report
ORDER BY sort_key, revenue DESC;
```

<!-- a:start -->
> **해설** 이 문제집의 종합편입니다: 2단계 집계(CTE) + 윈도우 함수(비중) + UNION ALL(합계 행). 합계 행을 마지막에 두기 위해 **정렬용 열**(`sort_key`)을 붙이고 바깥에서 정렬한 뒤, 최종 SELECT에서는 빼 버렸습니다. MySQL의 `GROUP BY region WITH ROLLUP`도 합계 행을 만들어 주지만, 합계 행의 지역이 NULL로 나오고 비중 같은 계산을 붙이기 어려워 리포트에서는 UNION ALL 방식이 더 자유롭습니다.
<!-- a:end -->
