"""연습문제용 쇼핑몰 DB '한입마켓(hanip_market)' 생성기

python3 tools/gen_drill_market.py  →  drills/shopping-mall/setup.sql

- 난수 시드 고정: 몇 번을 실행해도 같은 데이터
- 기준 시점: 2026-06-30 18:00 (주문 기간 2026-01-01 ~ 2026-06-30)
- 문제를 위해 일부러 심어 둔 패턴은 drills/shopping-mall/README.md '데이터 특징' 참고
"""
import random
from datetime import datetime, timedelta
from pathlib import Path

R = random.Random(2026)
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "drills" / "shopping-mall" / "setup.sql"
DB = "hanip_market"

# ---------------------------------------------------------------- 카테고리 (대분류 → 소분류)
CATEGORIES = [
    (1, "패션", None), (2, "디지털", None), (3, "식품", None), (4, "생활", None),
    (5, "상의", 1), (6, "하의", 1), (7, "신발", 1),
    (8, "노트북·태블릿", 2), (9, "음향기기", 2), (10, "주변기기", 2),
    (11, "신선식품", 3), (12, "간편식", 3), (13, "음료", 3),
    (14, "주방", 4), (15, "욕실", 4), (16, "수납", 4),
]

# ---------------------------------------------------------------- 상품 (소분류, 이름, 브랜드, 현재가, 재고, 판매중)
PRODUCTS = [
    (5, "오버핏 코튼 티셔츠", "모노핏", 19900, 120, 1),
    (5, "린넨 셔츠", "모노핏", 39900, 45, 1),
    (5, "후드 집업", "런웨이", 59000, 30, 1),
    (5, "기모 맨투맨", "런웨이", 35000, 0, 0),
    (6, "와이드 데님 팬츠", "런웨이", 49000, 60, 1),
    (6, "밴딩 슬랙스", "모노핏", 32900, 80, 1),
    (6, "카고 조거 팬츠", "런웨이", 42000, 25, 1),
    (7, "러닝화 에어", "스텝업", 89000, 40, 1),
    (7, "캔버스 스니커즈", "스텝업", 45000, 70, 1),
    (7, "슬리퍼 쿠션", "스텝업", 15900, 150, 1),
    (8, "울트라북 14", "픽셀랩", 1290000, 8, 1),
    (8, "태블릿 11 Wi-Fi", "픽셀랩", 549000, 15, 1),
    (8, "노트북 파우치 15", "키크래프트", 25000, 90, 1),
    (9, "무선 이어폰 프로", "사운드웨이브", 189000, 35, 1),
    (9, "블루투스 스피커 미니", "사운드웨이브", 59000, 50, 1),
    (9, "노이즈캔슬링 헤드폰", "사운드웨이브", 329000, 12, 1),
    (10, "무선 마우스", "키크래프트", 29000, 100, 1),
    (10, "기계식 키보드 텐키리스", "키크래프트", 119000, 30, 1),
    (10, "USB-C 멀티 허브", "픽셀랩", 45000, 60, 1),
    (10, "모니터 받침대", "키크래프트", 39000, 0, 0),
    (11, "제주 감귤 3kg", "그린팜", 18900, 200, 1),
    (11, "유기농 방울토마토 1kg", "그린팜", 12900, 150, 1),
    (11, "한우 불고기 500g", "그린팜", 32000, 40, 1),
    (11, "고당도 수박 1통", "그린팜", 24900, 0, 1),
    (12, "닭가슴살 스테이크 10팩", "바로쿡", 22900, 180, 1),
    (12, "냉동 볶음밥 6봉", "바로쿡", 15900, 220, 1),
    (12, "즉석 국밥 4팩", "바로쿡", 11900, 160, 1),
    (12, "단백질 쉐이크 12입", "바로쿡", 29900, 90, 1),
    (13, "탄산수 레몬 24병", "아침샘", 14900, 300, 1),
    (13, "콜드브루 원액 1L", "아침샘", 17900, 110, 1),
    (13, "보리차 티백 100입", "아침샘", 8900, 250, 1),
    (14, "스테인리스 프라이팬 28cm", "키친모아", 45900, 55, 1),
    (14, "실리콘 조리도구 5종", "키친모아", 19900, 140, 1),
    (14, "밀폐용기 10종 세트", "키친모아", 29900, 75, 1),
    (14, "에어프라이어 5.5L", "키친모아", 99000, 20, 1),
    (15, "호텔 수건 5매", "클린하우스", 24900, 130, 1),
    (15, "규조토 발매트", "클린하우스", 16900, 85, 1),
    (15, "샤워기 필터 3개입", "클린하우스", 12900, 0, 0),
    (16, "접이식 수납박스 3개", "박스업", 21900, 95, 1),
    (16, "옷걸이 50개", "박스업", 13900, 200, 1),
    (16, "이불 압축팩 4매", "박스업", 18900, 0, 1),
    (16, "틈새 수납장 4단", "박스업", 49900, 18, 1),
]
NEVER_SOLD = {4, 20, 38, 24}          # 한 번도 팔리지 않은 상품 (판매중지 3 + 품절 수박)
CANCEL_ONLY = 37                       # 주문은 됐지만 전부 취소·반품된 상품 (규조토 발매트)
PRICE_UP = {1: 17900, 21: 16900, 25: 19900, 29: 12900, 14: 179000}   # 4/1 가격 인상: 이전 판매가

LAST = ["김", "이", "박", "최", "정", "강", "조", "윤", "장", "임", "한", "오", "서", "신", "권", "황", "안", "송", "류", "홍"]
FIRST = ["민준", "서연", "도윤", "하은", "시우", "지유", "주원", "서아", "예준", "하린", "지호", "수아", "건우", "지아", "현우",
         "다은", "준서", "채원", "우진", "윤서", "선우", "예린", "연우", "소율", "정우", "지민", "승민", "유나", "태윤", "가온",
         "은호", "나연", "재원", "서윤", "민재", "아린", "도현", "하율", "이준", "세아"]
REGIONS = ["부산"] * 14 + ["서울"] * 10 + ["경기"] * 7 + ["경남"] * 5 + ["대구"] * 4 + ["광주"] * 2

START = datetime(2026, 1, 1)
SNAP = datetime(2026, 6, 30, 18, 0)


def q(v):
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, datetime):
        return "'" + v.strftime("%Y-%m-%d %H:%M:%S") + "'"
    return "'" + str(v).replace("'", "''") + "'"


def rows(table, cols, data):
    out = [f"INSERT INTO {table} ({', '.join(cols)}) VALUES"]
    out.append(",\n".join("    (" + ", ".join(q(v) for v in r) + ")" for r in data) + ";")
    return "\n".join(out)


def rand_time(day):
    # 점심(12~13시) · 저녁(20~23시)에 몰리는 쇼핑 패턴
    h = R.choices([9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
                  [2, 3, 4, 7, 6, 4, 4, 4, 4, 5, 6, 9, 11, 10, 6])[0]
    return day.replace(hour=h, minute=R.randrange(60), second=R.randrange(60))


# ---------------------------------------------------------------- 회원
members = []
names = R.sample([l + f for l in LAST for f in FIRST], 46)
for i in range(1, 41):
    name = names[i - 1]
    joined = datetime(2025, 1, 1) + timedelta(days=R.randrange(0, 350), hours=R.randrange(9, 23), minutes=R.randrange(60))
    if 31 <= i <= 35:                           # 올해 가입
        joined = datetime(2026, R.randint(2, 4), R.randint(1, 28), R.randrange(9, 23), R.randrange(60))
    if i in (38, 39, 40):                       # 6월 신규 가입 (주문 적음/없음)
        joined = datetime(2026, 6, R.randrange(5, 28), R.randrange(9, 23), R.randrange(60))
    members.append(dict(id=i, name=name, email=f"user{i:02d}@hanipmarket.kr", region=R.choice(REGIONS),
                        birth=R.choice(range(1975, 2006)), joined=joined))

# 주문 수 성향: 헤비 · 보통 · 라이트 · 없음
heavy = {1, 2, 3, 4, 5, 6}
none = {37, 39, 40}             # 주문 없는 회원
cancel_only = {36}              # 주문은 했지만 전부 취소
withdrawn = []
for k, i in enumerate(range(901, 907)):
    joined = datetime(2025, 1, 1) + timedelta(days=R.randrange(0, 420), hours=R.randrange(9, 23))
    withdrawn.append(dict(id=i, name=names[40 + k], email=f"bye{i}@hanipmarket.kr", region=R.choice(REGIONS),
                          joined=joined, withdrawn=joined + timedelta(days=R.randrange(30, 200))))

# ---------------------------------------------------------------- 주문
pid_info = {i + 1: p for i, p in enumerate(PRODUCTS)}
sellable = [pid for pid in pid_info if pid not in NEVER_SOLD]
by_main = {}
for pid, p in pid_info.items():
    main = next(c[2] for c in CATEGORIES if c[0] == p[0])
    by_main.setdefault(main, []).append(pid)
# 회원별 선호 대분류 (재구매 패턴)
pref = {m["id"]: R.choice([1, 2, 3, 4]) for m in members}
month_weight = {1: 1.0, 2: 0.72, 3: 1.05, 4: 1.15, 5: 1.35, 6: 1.25}   # 2월 설 연휴 하락, 5월 가정의 달 최고

orders, items = [], []
oid = 0
for m in members:
    if m["id"] in none:
        continue
    n = R.randint(15, 22) if m["id"] in heavy else (2 if m["id"] in cancel_only else R.randint(3, 10))
    if m["id"] == 38:
        n = 1
    first_day = max(START, m["joined"] + timedelta(days=1))
    span = (SNAP - first_day).days
    if span <= 0:
        continue
    days = []
    while len(days) < n:
        d = first_day + timedelta(days=R.randrange(span))
        if R.random() < month_weight[d.month] / 1.35:
            days.append(d)
    for d in sorted(days):
        oid += 1
        t = rand_time(d)
        if t > SNAP:
            t = SNAP - timedelta(hours=R.randint(1, 5))
        age = (SNAP - t).days
        if m["id"] in cancel_only:
            status = "취소"
        elif age <= 1:
            status = "결제완료"
        elif age <= 4:
            status = R.choice(["배송중", "배송중", "배송완료"])
        else:
            status = R.choices(["배송완료", "취소", "반품"], [86, 9, 5])[0]
        pay = R.choices(["카드", "간편결제", "계좌이체"], [50, 36, 14])[0]
        # 상품 담기
        k = R.choices([1, 2, 3], [55, 32, 13])[0]
        chosen = []
        while len(chosen) < k:
            pool = by_main[pref[m["id"]]] if R.random() < 0.6 else sellable
            pid = R.choice(pool)
            if pid in NEVER_SOLD or pid == CANCEL_ONLY or pid in chosen:
                continue
            if pid_info[pid][3] >= 300000 and R.random() > 0.12:   # 고가 디지털은 드물게
                continue
            chosen.append(pid)
        if status in ("취소", "반품") and R.random() < 0.35:
            chosen.append(CANCEL_ONLY)
        total = 0
        line = []
        for pid in chosen:
            p = pid_info[pid]
            main = next(c[2] for c in CATEGORIES if c[0] == p[0])
            qty = R.choices([1, 2, 3], [70, 22, 8] if main != 3 else [45, 35, 20])[0]
            if p[3] >= 300000:
                qty = 1
            price = PRICE_UP[pid] if pid in PRICE_UP and t < datetime(2026, 4, 1) else p[3]
            line.append((pid, qty, price))
            total += qty * price
        ship = 0 if total >= 30000 else 3000
        coupon = R.choice([2000, 3000, 5000]) if R.random() < 0.12 and total >= 20000 else 0
        orders.append(dict(id=oid, member=m["id"], at=t, status=status, pay=pay, ship=ship, coupon=coupon, total=total))
        for pid, qty, price in line:
            items.append((oid, pid, qty, price))

# ---------------------------------------------------------------- 리뷰 (배송완료 주문 상품의 일부)
brand_bias = {"런웨이": -0.9, "사운드웨이브": 0.3, "그린팜": 0.4, "바로쿡": -0.2}
reviews = []
seen = set()
order_map = {o["id"]: o for o in orders}
for (oid_, pid, qty, price) in items:
    o = order_map[oid_]
    if o["status"] != "배송완료" or (o["member"], pid) in seen or R.random() > 0.48:
        continue
    seen.add((o["member"], pid))
    brand = pid_info[pid][2]
    base = R.choices([5, 4, 3, 2, 1], [44, 33, 13, 6, 4])[0] + brand_bias.get(brand, 0)
    rating = max(1, min(5, round(base + R.uniform(-0.4, 0.4))))
    when = o["at"] + timedelta(days=R.randint(3, 12), hours=R.randint(0, 10))
    if when > SNAP:
        continue
    content = {5: ["정말 만족해요", "재구매 의사 있어요", "배송도 빠르고 좋아요", "가성비 최고"],
               4: ["괜찮아요", "생각보다 좋아요", "무난합니다"],
               3: ["보통이에요", "가격 생각하면 그럭저럭"],
               2: ["기대보다 별로예요", "사이즈가 안 맞아요"],
               1: ["품질이 너무 아쉬워요", "환불하고 싶어요"]}[rating]
    reviews.append((o["member"], pid, oid_, rating, R.choice(content), when))
reviews.sort(key=lambda r: r[5])

# ---------------------------------------------------------------- 찜 · 장바구니 (UNION 연습용)
wish, cart = set(), set()
wish_rows, cart_rows = [], []
for m in members:
    for _ in range(R.randint(0, 4)):
        pid = R.choice(list(pid_info))
        if (m["id"], pid) in wish:
            continue
        wish.add((m["id"], pid))
        wish_rows.append((m["id"], pid, max(m["joined"], START) + timedelta(days=R.randrange(1, 170), hours=R.randrange(24))))
    for _ in range(R.randint(0, 2)):
        pid = R.choice(list(wish_rows and [w[1] for w in wish_rows if w[0] == m["id"]] or list(pid_info))) if R.random() < 0.5 else R.choice(list(pid_info))
        if (m["id"], pid) in cart:
            continue
        cart.add((m["id"], pid))
        cart_rows.append((m["id"], pid, R.choice([1, 1, 1, 2, 3]), datetime(2026, 6, R.randint(1, 30), R.randrange(9, 24), R.randrange(60))))
wish_rows = [w if w[2] <= SNAP else (w[0], w[1], SNAP - timedelta(days=R.randint(1, 20), minutes=R.randrange(1, 600))) for w in wish_rows]
cart_rows = [c if c[3] <= SNAP else (c[0], c[1], c[2], SNAP - timedelta(hours=R.randint(1, 72), minutes=R.randrange(1, 60))) for c in cart_rows]
wish_rows.sort(key=lambda w: w[2])
cart_rows.sort(key=lambda c: c[3])

# ---------------------------------------------------------------- SQL 쓰기
SCHEMA = f"""-- =============================================================================
--  한입마켓(hanip_market) — 쇼핑몰 연습문제용 DB
--  사용법: Workbench에서 이 파일을 열고 전체 실행 (Ctrl+Shift+Enter)
--  다시 처음 상태로: 아래 DROP 줄의 주석(--)을 풀고 다시 전체 실행
--  기준 시점: 2026-06-30 18:00 · 주문 기간 2026-01-01 ~ 2026-06-30
-- =============================================================================
-- DROP DATABASE IF EXISTS {DB};
CREATE DATABASE {DB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE {DB};

CREATE TABLE categories (
    category_id  INT          NOT NULL                COMMENT '카테고리 번호',
    name         VARCHAR(30)  NOT NULL                COMMENT '카테고리 이름',
    parent_id    INT              NULL                COMMENT '상위(대분류) 번호 — 대분류는 NULL',
    CONSTRAINT pk_categories        PRIMARY KEY (category_id),
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories (category_id)
) COMMENT '상품 카테고리 (대분류 4 · 소분류 12)';

CREATE TABLE products (
    product_id   INT          NOT NULL AUTO_INCREMENT COMMENT '상품 번호',
    category_id  INT          NOT NULL                COMMENT '소분류 카테고리',
    name         VARCHAR(50)  NOT NULL                COMMENT '상품명',
    brand        VARCHAR(30)  NOT NULL                COMMENT '브랜드',
    price        INT          NOT NULL                COMMENT '현재 판매가',
    stock        INT          NOT NULL DEFAULT 0      COMMENT '재고',
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE   COMMENT '판매 중 여부',
    CONSTRAINT pk_products          PRIMARY KEY (product_id),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories (category_id),
    CONSTRAINT ck_products_price    CHECK (price > 0)
) COMMENT '상품';

CREATE TABLE members (
    member_id    INT          NOT NULL AUTO_INCREMENT COMMENT '회원 번호',
    name         VARCHAR(20)  NOT NULL                COMMENT '이름',
    email        VARCHAR(50)  NOT NULL                COMMENT '이메일',
    region       VARCHAR(10)  NOT NULL                COMMENT '지역',
    birth_year   INT          NOT NULL                COMMENT '출생 연도',
    joined_at    DATETIME     NOT NULL                COMMENT '가입 일시',
    CONSTRAINT pk_members       PRIMARY KEY (member_id),
    CONSTRAINT uq_members_email UNIQUE (email)
) COMMENT '현재 회원';

CREATE TABLE withdrawn_members (
    member_id    INT          NOT NULL                COMMENT '탈퇴 전 회원 번호',
    name         VARCHAR(20)  NOT NULL                COMMENT '이름',
    email        VARCHAR(50)  NOT NULL                COMMENT '이메일',
    region       VARCHAR(10)  NOT NULL                COMMENT '지역',
    joined_at    DATETIME     NOT NULL                COMMENT '가입 일시',
    withdrawn_at DATETIME     NOT NULL                COMMENT '탈퇴 일시',
    CONSTRAINT pk_withdrawn_members PRIMARY KEY (member_id)
) COMMENT '탈퇴 회원 보관 (현재 회원과 별도 테이블)';

CREATE TABLE orders (
    order_id        INT          NOT NULL AUTO_INCREMENT COMMENT '주문 번호',
    member_id       INT          NOT NULL                COMMENT '주문 회원',
    ordered_at      DATETIME     NOT NULL                COMMENT '주문 일시',
    status          VARCHAR(10)  NOT NULL                COMMENT '결제완료/배송중/배송완료/취소/반품',
    payment_method  VARCHAR(10)  NOT NULL                COMMENT '카드/간편결제/계좌이체',
    shipping_fee    INT          NOT NULL DEFAULT 0      COMMENT '배송비 (상품 합계 3만 원 이상 무료)',
    coupon_discount INT          NOT NULL DEFAULT 0      COMMENT '쿠폰 할인액',
    CONSTRAINT pk_orders        PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_member FOREIGN KEY (member_id) REFERENCES members (member_id),
    CONSTRAINT ck_orders_status CHECK (status IN ('결제완료', '배송중', '배송완료', '취소', '반품'))
) COMMENT '주문';

CREATE TABLE order_items (
    order_item_id INT NOT NULL AUTO_INCREMENT COMMENT '주문 상세 번호',
    order_id      INT NOT NULL                COMMENT '주문 번호',
    product_id    INT NOT NULL                COMMENT '상품 번호',
    quantity      INT NOT NULL                COMMENT '수량',
    unit_price    INT NOT NULL                COMMENT '주문 당시 단가',
    CONSTRAINT pk_order_items         PRIMARY KEY (order_item_id),
    CONSTRAINT fk_order_items_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT uq_order_items         UNIQUE (order_id, product_id)
) COMMENT '주문 상세';

CREATE TABLE reviews (
    review_id   INT          NOT NULL AUTO_INCREMENT COMMENT '리뷰 번호',
    member_id   INT          NOT NULL                COMMENT '작성 회원',
    product_id  INT          NOT NULL                COMMENT '상품',
    order_id    INT          NOT NULL                COMMENT '구매한 주문',
    rating      TINYINT      NOT NULL                COMMENT '별점 1~5',
    content     VARCHAR(200)     NULL                COMMENT '내용',
    created_at  DATETIME     NOT NULL                COMMENT '작성 일시',
    CONSTRAINT pk_reviews         PRIMARY KEY (review_id),
    CONSTRAINT fk_reviews_member  FOREIGN KEY (member_id)  REFERENCES members (member_id),
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_reviews_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id),
    CONSTRAINT ck_reviews_rating  CHECK (rating BETWEEN 1 AND 5)
) COMMENT '상품 리뷰';

CREATE TABLE wishlists (
    member_id   INT      NOT NULL COMMENT '회원',
    product_id  INT      NOT NULL COMMENT '상품',
    added_at    DATETIME NOT NULL COMMENT '찜한 일시',
    CONSTRAINT pk_wishlists         PRIMARY KEY (member_id, product_id),
    CONSTRAINT fk_wishlists_member  FOREIGN KEY (member_id)  REFERENCES members (member_id),
    CONSTRAINT fk_wishlists_product FOREIGN KEY (product_id) REFERENCES products (product_id)
) COMMENT '찜 목록';

CREATE TABLE carts (
    member_id   INT      NOT NULL COMMENT '회원',
    product_id  INT      NOT NULL COMMENT '상품',
    quantity    INT      NOT NULL COMMENT '수량',
    added_at    DATETIME NOT NULL COMMENT '담은 일시',
    CONSTRAINT pk_carts         PRIMARY KEY (member_id, product_id),
    CONSTRAINT fk_carts_member  FOREIGN KEY (member_id)  REFERENCES members (member_id),
    CONSTRAINT fk_carts_product FOREIGN KEY (product_id) REFERENCES products (product_id)
) COMMENT '장바구니 (현재 담겨 있는 상품)';
"""

parts = [SCHEMA, "-- ---------------------------------------------------------------- 데이터"]
parts.append(rows("categories", ["category_id", "name", "parent_id"], CATEGORIES))
parts.append(rows("products", ["product_id", "category_id", "name", "brand", "price", "stock", "is_active"],
                  [(i + 1,) + p for i, p in enumerate(PRODUCTS)]))
parts.append(rows("members", ["member_id", "name", "email", "region", "birth_year", "joined_at"],
                  [(m["id"], m["name"], m["email"], m["region"], m["birth"], m["joined"]) for m in members]))
parts.append(rows("withdrawn_members", ["member_id", "name", "email", "region", "joined_at", "withdrawn_at"],
                  [(w["id"], w["name"], w["email"], w["region"], w["joined"], w["withdrawn"]) for w in withdrawn]))
orders.sort(key=lambda o: o["at"])
remap = {o["id"]: i + 1 for i, o in enumerate(orders)}      # 주문 번호를 시간순으로
parts.append(rows("orders", ["order_id", "member_id", "ordered_at", "status", "payment_method", "shipping_fee", "coupon_discount"],
                  [(remap[o["id"]], o["member"], o["at"], o["status"], o["pay"], o["ship"], o["coupon"]) for o in orders]))
items_sorted = sorted(((remap[a], b, c, d) for (a, b, c, d) in items), key=lambda x: (x[0], x[1]))
parts.append(rows("order_items", ["order_id", "product_id", "quantity", "unit_price"], items_sorted))
parts.append(rows("reviews", ["member_id", "product_id", "order_id", "rating", "content", "created_at"],
                  [(a, b, remap[c], d, e, f) for (a, b, c, d, e, f) in reviews]))
parts.append(rows("wishlists", ["member_id", "product_id", "added_at"], wish_rows))
parts.append(rows("carts", ["member_id", "product_id", "quantity", "added_at"], cart_rows))
parts.append("""
-- ---------------------------------------------------------------- 확인
SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'members', COUNT(*) FROM members
UNION ALL SELECT 'withdrawn_members', COUNT(*) FROM withdrawn_members
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'wishlists', COUNT(*) FROM wishlists
UNION ALL SELECT 'carts', COUNT(*) FROM carts;
""")
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text("\n\n".join(parts), encoding="utf-8")
print("wrote", OUT.relative_to(ROOT), "orders", len(orders), "items", len(items), "reviews", len(reviews),
      "wish", len(wish_rows), "cart", len(cart_rows))
