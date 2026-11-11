"""Ch11 트리거 — 슬라이드 정의 (교안 chapters/ch11-trigger/README.md 기준)

슬라이드의 SQL은 위에서부터 같은 접속에서 순서대로 실행된다(교안과 같은 순서).
"""

HISTORY_TABLE = """CREATE TABLE menu_price_history (
    history_id  INT      NOT NULL AUTO_INCREMENT,
    menu_id     INT      NOT NULL,
    old_price   INT      NOT NULL,
    new_price   INT      NOT NULL,
    changed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_menu_price_history      PRIMARY KEY (history_id),
    CONSTRAINT fk_menu_price_history_menu FOREIGN KEY (menu_id) REFERENCES menus (menu_id)
);"""

PRICE_TRG = """DELIMITER $$
CREATE TRIGGER trg_menus_price_history
AFTER UPDATE ON menus
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO menu_price_history (menu_id, old_price, new_price)
        VALUES (NEW.menu_id, OLD.price, NEW.price);
    END IF;
END $$
DELIMITER ;"""

FILL_TRG = """DELIMITER $$
CREATE TRIGGER trg_order_items_fill_price
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    IF NEW.unit_price IS NULL OR NEW.unit_price = 0 THEN
        SET NEW.unit_price = (SELECT price FROM menus WHERE menu_id = NEW.menu_id);
    END IF;
END $$
DELIMITER ;"""

STATUS_SETUP = """CREATE TABLE order_status_logs (
    log_id       INT          NOT NULL AUTO_INCREMENT,
    order_id     INT          NOT NULL,
    from_status  VARCHAR(10)  NOT NULL,
    to_status    VARCHAR(10)  NOT NULL,
    changed_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_order_status_logs       PRIMARY KEY (log_id),
    CONSTRAINT fk_order_status_logs_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
);"""

STATUS_CHECK = """DELIMITER $$
CREATE TRIGGER trg_orders_status_check
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status IN ('배달완료', '취소') AND NEW.status <> OLD.status THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '배달완료 또는 취소된 주문은 상태를 바꿀 수 없습니다.';
    END IF;

    IF NEW.status = '배달완료' AND NEW.delivered_at IS NULL THEN
        SET NEW.delivered_at = NOW();
    END IF;
END $$
DELIMITER ;"""

STATUS_LOG = """DELIMITER $$
CREATE TRIGGER trg_orders_status_log
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO order_status_logs (order_id, from_status, to_status)
        VALUES (NEW.order_id, OLD.status, NEW.status);
    END IF;
END $$
DELIMITER ;"""

STATS_ALTER = """ALTER TABLE restaurants
    ADD COLUMN review_count INT NOT NULL DEFAULT 0,
    ADD COLUMN rating_sum   INT NOT NULL DEFAULT 0;

UPDATE restaurants r
JOIN (
    SELECT o.restaurant_id, COUNT(*) AS cnt, SUM(rv.rating) AS total
    FROM reviews rv JOIN orders o ON rv.order_id = o.order_id
    GROUP BY o.restaurant_id
) t ON r.restaurant_id = t.restaurant_id
SET r.review_count = t.cnt, r.rating_sum = t.total
WHERE r.restaurant_id > 0;   -- 안전 모드: 키 열 조건

SELECT restaurant_id, name, review_count, rating_sum,
    ROUND(rating_sum / NULLIF(review_count, 0), 2) AS avg_rating
FROM restaurants WHERE restaurant_id IN (1, 15);"""

STATS_TRG = """DELIMITER $$
CREATE TRIGGER trg_reviews_stats_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    DECLARE v_restaurant_id INT;
    SELECT restaurant_id INTO v_restaurant_id FROM orders WHERE order_id = NEW.order_id;

    UPDATE restaurants
    SET review_count = review_count + 1, rating_sum = rating_sum + NEW.rating
    WHERE restaurant_id = v_restaurant_id;
END $$

CREATE TRIGGER trg_reviews_stats_delete
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
    DECLARE v_restaurant_id INT;
    SELECT restaurant_id INTO v_restaurant_id FROM orders WHERE order_id = OLD.order_id;

    UPDATE restaurants
    SET review_count = review_count - 1, rating_sum = rating_sum - OLD.rating
    WHERE restaurant_id = v_restaurant_id;
END $$
DELIMITER ;"""

STATS_Q = "SELECT restaurant_id, review_count, rating_sum,\n    ROUND(rating_sum / review_count, 2) AS avg_rating\nFROM restaurants WHERE restaurant_id = 1;"

SOLD_OUT_TRG = """DELIMITER $$
CREATE TRIGGER trg_order_items_check_sold_out
BEFORE INSERT ON order_items
FOR EACH ROW
FOLLOWS trg_order_items_fill_price
BEGIN
    IF (SELECT is_sold_out FROM menus WHERE menu_id = NEW.menu_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '품절된 메뉴는 주문할 수 없습니다.';
    END IF;
END $$
DELIMITER ;"""


def box(x, y, text, w=2.65, h=0.8, dark=False, size=16):
    return {"kind": "box", "x": x, "y": y, "w": w, "h": h, "text": text, "size": size, "align": "center", "dark": dark}


DECK = {
    "title": "Ch11. 트리거",
    "footer": "Ch11 · 트리거 — 데이터가 바뀌면 자동으로",
    "org": "Korea IT Academy Busan · 강사 김준일",
    "sections": [
        {"title": "시작", "slides": [
            {"type": "cover", "label": "MySQL · CHAPTER 11 · PART 4 서버 프로그래밍",
             "title": "트리거", "sub": "데이터가 바뀌면 자동으로 · 오늘의 DB hanip_delivery11"},
            {"type": "request", "label": "오늘의 요청", "title": "누가 어떤 경로로 바꾸든 자동으로",
             "from": "운영팀 박 팀장 · 정산팀 정 대리",
             "text": "① 메뉴 가격 **변경 기록**  ② 주문 상태 **이력** + 완료된 주문이 '접수'로 돌아가는 버그 **차단**\n③ 가게 테이블에 **리뷰 수 · 평점 저장** (절대 어긋나면 안 됨)  ④ **품절 메뉴** 주문을 DB에서도 차단",
             "note": "개발자들에게 쿼리마다 챙기라고 하면 꼭 누군가 빠뜨립니다 → **트리거**"},
            {"type": "agenda", "label": "목차", "title": "오늘 배울 것", "items": [
                ["트리거 · DELIMITER", "이벤트 · 시점 · FOR EACH ROW · NEW와 OLD"],
                ["AFTER · BEFORE", "기록할 거면 AFTER, 막거나 고칠 거면 BEFORE"],
                ["SIGNAL", "업무 규칙을 에러로 막기"],
                ["반정규화 동기화", "가게 리뷰 수 · 별점 합계 자동 유지"],
                ["트리거와 트랜잭션", "같은 트랜잭션 · 문장 단위 원자성 · ROLLBACK은 여는 쪽 책임"],
            ]},
        ]},
        {"title": "트리거", "slides": [
            {"type": "section", "label": "01", "title": "트리거란", "sub": "문이 열리면 저절로 켜지는 센서등"},
            {"type": "table", "label": "01 · 트리거", "title": "INSERT · UPDATE · DELETE 때 자동 실행되는 SQL",
             "headers": ["구성", "선택지", "뜻"],
             "rows": [["**이벤트**", "`INSERT` · `UPDATE` · `DELETE`", "무엇이 일어났을 때"],
                      ["**시점**", "`BEFORE` · `AFTER`", "테이블에 반영되기 전 / 후"],
                      ["**단위**", "`FOR EACH ROW`", "바뀐 **행마다** 한 번씩 (MySQL은 행 단위만)"]],
             "colW": [2.2, 4.6, 5.23], "rowH": 0.75, "boldFirst": False,
             "caption": "앱, Workbench, 다른 프로시저 — **누가 바꾸든** 반드시 실행됩니다."},
            {"type": "table", "label": "01 · NEW와 OLD", "title": "바뀌는 행을 보는 두 개의 가상 행",
             "headers": ["이벤트", "OLD (바뀌기 전)", "NEW (바뀐 후)"],
             "rows": [["INSERT", "없음", "새로 들어올 행"],
                      ["UPDATE", "수정 전 값", "수정 후 값"],
                      ["DELETE", "지워질 행", "없음"]],
             "colW": [2.6, 4.7, 4.73], "rowH": 0.75, "boldFirst": True,
             "caption": "`OLD.price <> NEW.price` — \"가격이 실제로 바뀌었나\"를 이렇게 판단합니다."},
            {"type": "code", "label": "02 · 첫 트리거", "title": "기록을 담을 이력 테이블",
             "sql": HISTORY_TABLE, "layout": "stack", "codeSize": 16,
             "caption": "운영팀 요청 ① — 언제, 얼마에서 얼마로."},
            {"type": "code", "label": "02 · DELIMITER", "title": "본문 안의 ; 를 지키는 법",
             "run": False, "codeSize": 18,
             "sql": "DELIMITER $$          -- 지금부터 문장 끝은 $$\nCREATE TRIGGER …\nBEGIN\n    문장1;            -- 이 ; 들은 본문의 일부로 서버에 전달\n    문장2;\nEND $$                -- 여기서 CREATE TRIGGER 한 문장이 끝\nDELIMITER ;           -- 다시 ; 로",
             "caption": "`DELIMITER`는 SQL이 아니라 **Workbench에게 하는 지시**. 줄 끝에 `;`를 붙이지 않고, 끝나면 반드시 `DELIMITER ;`로 되돌립니다."},
            {"type": "code", "label": "02 · CREATE TRIGGER", "title": "가격이 바뀌면 이력을 남긴다",
             "sql": PRICE_TRG, "layout": "stack", "codeSize": 18,
             "caption": "이름 규칙 `trg_테이블_역할`. `IF OLD.price <> NEW.price` — 설명만 고친 경우는 기록하지 않습니다."},
            {"type": "code", "label": "02 · 확인", "title": "UPDATE에는 이력 이야기가 한 줄도 없는데",
             "sql": "UPDATE menus SET price = 10500 WHERE menu_id = 1;\nUPDATE menus SET description = '토렴한 순대국밥' WHERE menu_id = 2;\n\nSELECT history_id, menu_id, old_price, new_price\nFROM menu_price_history;",
             "layout": "stack", "codeSize": 18,
             "caption": "돼지국밥만 기록, 설명만 바꾼 순대국밥은 기록 안 됨. `changed_at`은 **실제 실행 시각**이라 생략."},
            {"type": "code", "label": "02 · FOR EACH ROW", "title": "한 문장으로 4행을 바꾸면",
             "sql": "UPDATE menus SET price = price + 500 WHERE restaurant_id = 3;\n\nSELECT menu_id, old_price, new_price\nFROM menu_price_history\nWHERE history_id > 1\nORDER BY menu_id;",
             "layout": "stack", "codeSize": 18,
             "caption": "UPDATE 한 문장에 이력 4행 — 트리거는 **행마다** 실행됩니다."},
        ]},
        {"title": "BEFORE", "slides": [
            {"type": "section", "label": "03", "title": "BEFORE 트리거", "sub": "들어가기 전에 값을 고친다"},
            {"type": "code", "label": "03 · SET NEW", "title": "단가가 비어 있으면 현재 가격으로",
             "sql": FILL_TRG, "layout": "stack", "codeSize": 16,
             "caption": "`SET NEW.열 = 값`으로 **들어갈 값을 바꾸는 것**은 BEFORE만. MySQL은 BEFORE 트리거 **후에** NOT NULL을 검사하므로 NULL을 보내도 통과합니다."},
            {"type": "code", "label": "03 · SET NEW", "title": "AFTER에서는 이미 늦었다",
             "sql": "DELIMITER $$\nCREATE TRIGGER trg_bad_after\nAFTER INSERT ON order_items\nFOR EACH ROW\nBEGIN\n    SET NEW.unit_price = 0;\nEND $$\nDELIMITER ;",
             "error": True, "layout": "stack", "codeSize": 17},
            {"type": "table", "label": "03 · BEFORE vs AFTER", "title": "막을 거면 BEFORE, 기록할 거면 AFTER",
             "headers": ["시점", "할 수 있는 것", "대표 용도"],
             "rows": [["`BEFORE`", "`NEW` 값 바꾸기, `SIGNAL`로 막기", "값 보정 · 기본값 채우기 · **검증**"],
                      ["`AFTER`", "다른 테이블에 기록 · 갱신", "**이력(감사 로그)** · 집계 동기화"]],
             "colW": [2.0, 5.0, 5.03], "rowH": 0.85, "boldFirst": False,
             "caption": "막을 일을 AFTER에서 하면 이미 바뀐 뒤라 의미가 없습니다."},
        ]},
        {"title": "SIGNAL", "slides": [
            {"type": "section", "label": "04", "title": "SIGNAL", "sub": "업무 규칙을 에러로 막는다"},
            {"type": "code", "label": "04 · 상태 이력", "title": "상태 이력 테이블",
             "sql": STATUS_SETUP, "layout": "stack", "codeSize": 16,
             "caption": "운영팀 요청 ② — 트리거 두 개로: **검증은 BEFORE, 기록은 AFTER**."},
            {"type": "code", "label": "04 · SIGNAL", "title": "검증 — 완료·취소된 주문은 바꿀 수 없다",
             "sql": STATUS_CHECK, "layout": "stack", "codeSize": 14,
             "caption": "`SIGNAL SQLSTATE '45000'` = 에러를 **직접 일으킨다**(사용자 정의 예외). 배달완료 시각은 BEFORE에서 자동으로."},
            {"type": "code", "label": "04 · 상태 이력", "title": "기록 — 상태가 바뀌면 남긴다",
             "sql": STATUS_LOG, "layout": "stack", "codeSize": 18},
            {"type": "code", "label": "04 · 정상 흐름", "title": "563번 주문을 끝까지",
             "sql": "UPDATE orders SET status = '조리중' WHERE order_id = 563;\nUPDATE orders SET status = '배달중', rider_id = 2 WHERE order_id = 563;\nUPDATE orders SET status = '배달완료' WHERE order_id = 563;\n\nSELECT log_id, order_id, from_status, to_status FROM order_status_logs;",
             "layout": "stack", "codeSize": 17,
             "caption": "UPDATE 세 번, 이력 세 줄. `delivered_at`은 아무도 넣지 않았지만 BEFORE 트리거가 채웠습니다."},
            {"type": "code", "label": "04 · 규칙 위반", "title": "배달완료 주문을 '접수'로 되돌리면",
             "sql": "UPDATE orders SET status = '접수' WHERE order_id = 563;", "error": True, "layout": "stack", "codeSize": 20,
             "caption": "**1644** = SIGNAL로 일으킨 에러. UPDATE도, AFTER 트리거도 실행되지 않았습니다. CHECK는 한 행의 현재 값만 — **이전 값(OLD)·다른 테이블**에 따른 규칙은 트리거의 몫."},
        ]},
        {"title": "동기화", "slides": [
            {"type": "section", "label": "05", "title": "반정규화 동기화", "sub": "Ch09의 \"감시\"를 자동으로"},
            {"type": "code", "label": "05 · 가게 평점", "title": "평균이 아니라 개수와 합계를 저장",
             "sql": STATS_ALTER.split("\n\nSELECT")[0], "layout": "stack", "codeSize": 14,
             "caption": "평균은 리뷰 하나마다 다시 계산하기 까다롭지만, **개수 + 합계**는 더하기·빼기만으로 정확합니다."},
            {"type": "code", "label": "05 · 가게 평점", "title": "초기값 확인",
             "sql": "SELECT" + STATS_ALTER.split("\n\nSELECT")[1], "layout": "stack", "codeSize": 18},
            {"type": "code", "label": "05 · 동기화 트리거", "title": "리뷰가 생기면 +1, 별점 더하기",
             "sql": STATS_TRG.split("\n\nCREATE TRIGGER trg_reviews_stats_delete")[0] + "\nDELIMITER ;", "layout": "stack", "codeSize": 14,
             "caption": "리뷰에는 가게 번호가 없으므로 **변수**(`DECLARE` · `SELECT … INTO`)에 찾아 담습니다 — Ch12에서 자세히."},
            {"type": "code", "label": "05 · 동기화 트리거", "title": "리뷰가 지워지면 −1, 별점 빼기",
             "sql": "DELIMITER $$\nCREATE TRIGGER trg_reviews_stats_delete" + STATS_TRG.split("CREATE TRIGGER trg_reviews_stats_delete")[1], "layout": "stack", "codeSize": 14,
             "caption": "INSERT는 `NEW`, DELETE는 `OLD`. 별점 **수정**(UPDATE)은 실습 8번에서 완성합니다."},
            {"type": "compare", "label": "05 · 확인", "title": "리뷰 추가 → 삭제",
             "left": {"tag": "549번 주문에 5점 리뷰", "good": True, "codeSize": 12,
                      "sql": "INSERT INTO reviews (order_id, rating,\n    content, created_at)\nVALUES (549, 5, '국물이 진해요',\n    '2026-06-30 18:58:00');\n" + STATS_Q},
             "right": {"tag": "신고로 삭제", "good": True, "codeSize": 12,
                       "sql": "DELETE FROM reviews WHERE order_id = 549;\n" + STATS_Q},
             "caption": "24 → 25 → 24. 감시 쿼리(Ch09)로 전체 가게를 검증하면 **불일치 0건**."},
        ]},
        {"title": "트랜잭션", "slides": [
            {"type": "section", "label": "06", "title": "트리거와 트랜잭션", "sub": "오늘의 핵심"},
            {"type": "compare", "label": "06 · 같은 트랜잭션", "title": "ROLLBACK하면 트리거가 한 일도 사라진다",
             "left": {"tag": "트랜잭션 안에서", "good": True, "codeSize": 13,
                      "sql": "START TRANSACTION;\nUPDATE menus SET price = 11000\nWHERE menu_id = 2;\n\nSELECT\n (SELECT price FROM menus\n  WHERE menu_id = 2) AS price_in_tx,\n (SELECT COUNT(*)\n  FROM menu_price_history) AS history_in_tx;"},
             "right": {"tag": "ROLLBACK 후", "good": True, "codeSize": 13,
                       "sql": "ROLLBACK;\n\nSELECT\n (SELECT price FROM menus\n  WHERE menu_id = 2) AS price_now,\n (SELECT COUNT(*)\n  FROM menu_price_history) AS history_now;"},
             "caption": "트리거의 INSERT는 UPDATE와 **같은 트랜잭션**. \"가격은 그대로인데 이력만 남는\" 일은 없습니다 — ACID의 **원자성**."},
            {"type": "code", "label": "06 · 품절 차단", "title": "운영팀 요청 ④ — 품절 메뉴는 못 들어온다",
             "sql": SOLD_OUT_TRG, "layout": "stack", "codeSize": 15,
             "caption": "같은 시점(BEFORE INSERT)에 트리거가 둘이면 `FOLLOWS`로 순서 지정: 단가 채우기 → 품절 검사."},
            {"type": "code", "label": "06 · 문장 단위 원자성", "title": "세 줄 중 두 번째가 품절이면?",
             "sql": "UPDATE menus SET is_sold_out = TRUE WHERE menu_id = 2;   -- 순대국밥 재료 소진\n\nINSERT INTO order_items (order_id, menu_id, quantity, unit_price) VALUES\n    (562, 4, 1, 0),\n    (562, 2, 1, 0),\n    (562, 5, 1, 0);",
             "error": True, "layout": "stack", "codeSize": 16,
             "caption": "첫 줄은 통과했지만 **한 줄도 들어가지 않습니다.** 한 문장은 그 자체로 원자적 — 중간에 실패하면 그 문장이 바꾼 것은 전부 취소."},
            {"type": "code", "label": "06 · 주문 트랜잭션", "title": "주문 머리와 첫 메뉴는 들어갔는데…",
             "sql": "START TRANSACTION;\nINSERT INTO orders (customer_id, restaurant_id, status, payment_method, delivery_fee, ordered_at)\nVALUES (4, 5, '접수', '카드', 3000, '2026-06-30 19:05:00');\nSET @order_id = LAST_INSERT_ID();\n\nINSERT INTO order_items (order_id, menu_id, quantity, unit_price) VALUES (@order_id, 21, 1, 0);\n\nSELECT order_id, menu_id, quantity, unit_price FROM order_items WHERE order_id = @order_id;",
             "layout": "stack", "codeSize": 13,
             "caption": "최수아 님 · 남천동마라공방. 단가 `0`을 보냈지만 트리거가 13,000원으로 채웠습니다."},
            {"type": "code", "label": "06 · 주문 트랜잭션", "title": "품절된 마라 볶음면 추가",
             "sql": "INSERT INTO order_items (order_id, menu_id, quantity, unit_price) VALUES (@order_id, 24, 1, 0);",
             "error": True, "layout": "stack", "codeSize": 17,
             "caption": "⚠ Ch08 복습: **에러가 나도 자동 ROLLBACK이 아닙니다.** 주문 머리와 마라탕은 아직 트랜잭션 안에 남아 있습니다."},
            {"type": "code", "label": "06 · 주문 트랜잭션", "title": "트랜잭션을 연 쪽이 정리한다",
             "sql": "ROLLBACK;\n\nSELECT COUNT(*) AS orders_total,\n    (SELECT COUNT(*) FROM order_items WHERE order_id = @order_id) AS items_of_failed_order\nFROM orders;",
             "layout": "stack", "codeSize": 17,
             "caption": "트리거의 `SIGNAL`은 **그 문장 하나**를 실패시킬 뿐. 전체를 되돌릴지는 **앱 · 프로시저**가 결정 → 그 판단을 DB에 넣는 법이 Ch12."},
            {"type": "table", "label": "06 · 금지", "title": "트리거 안에서 하면 안 되는 것",
             "headers": ["금지", "에러", "이유"],
             "rows": [["`COMMIT` · `ROLLBACK` · `START TRANSACTION`", "1422", "바깥 트랜잭션의 일부라 혼자 확정 불가"],
                      ["`CREATE` · `ALTER` · `DROP` 등 DDL", "1422", "DDL은 암묵적 COMMIT"],
                      ["트리거가 걸린 **그 테이블** 수정", "1442", "무한 반복 위험 → 같은 행은 BEFORE의 `SET NEW`"],
                      ["결과를 돌려주는 `SELECT`", "1415", "받을 사람이 없음. `SELECT … INTO 변수`는 가능"]],
             "colW": [4.8, 1.3, 5.93], "rowH": 0.7, "boldFirst": False, "size": 14},
        ]},
        {"title": "관리 · 판단", "slides": [
            {"type": "code", "label": "07 · 관리", "title": "지금 DB의 트리거",
             "sql": "SELECT trigger_name AS trigger_name, event_object_table AS table_name,\n    action_timing AS timing, event_manipulation AS event\nFROM information_schema.triggers\nWHERE trigger_schema = DATABASE()\nORDER BY table_name, event, timing, action_order;",
             "layout": "stack", "codeSize": 14, "resSize": 11, "limit": 7,
             "caption": "`SHOW TRIGGERS` · `SHOW CREATE TRIGGER 이름` · `DROP TRIGGER IF EXISTS 이름` — 수정 명령은 없음(삭제 후 재생성)."},
            {"type": "table", "label": "08 · 판단", "title": "트리거는 보이지 않는 코드다",
             "headers": ["쓰기 좋은 곳", "피해야 할 곳"],
             "rows": [["**감사 로그 · 변경 이력**", "복잡한 업무 흐름 (결제 → 포인트 → 알림) → 앱 · 프로시저"],
                      ["**반정규화 값 동기화**", "외부 시스템 호출 (메일 · 푸시)"],
                      ["**마지막 방어선 검증**", "트리거가 트리거를 부르는 긴 연쇄"],
                      ["기본값 · 보정", "대량 작업이 잦은 테이블 (행마다 실행)"]],
             "colW": [5.0, 7.03], "rowH": 0.68, "boldFirst": False,
             "caption": "`UPDATE menus …` 한 줄이 다른 테이블 세 곳을 바꿔도 쿼리만 봐서는 모릅니다 → **문서화 필수**."},
        ]},
        {"title": "마무리", "slides": [
            {"type": "table", "label": "오늘의 요청 해결", "title": "트리거 6개",
             "headers": ["요청", "트리거", "동작"],
             "rows": [["① 가격 기록", "`trg_menus_price_history` (AFTER UPDATE)", "가격이 바뀐 행마다 이력"],
                      ["② 상태 이력", "`trg_orders_status_log` (AFTER UPDATE)", "상태가 바뀔 때마다 기록"],
                      ["② 잘못된 변경 차단", "`trg_orders_status_check` (BEFORE UPDATE)", "1644 · 완료 시각 자동"],
                      ["③ 가게 평점", "`trg_reviews_stats_insert` / `_delete`", "리뷰 수 · 합계 자동 유지"],
                      ["④ 품절 차단", "`trg_order_items_check_sold_out`", "1644 → 앱이 ROLLBACK"],
                      ["(덤) 단가 입력", "`trg_order_items_fill_price` (BEFORE INSERT)", "단가 0 · NULL이면 현재가"]],
             "colW": [2.6, 5.6, 3.83], "rowH": 0.58, "boldFirst": False, "size": 13},
            {"type": "practice", "label": "실습", "title": "practice.md — 자동으로 기록하고, 막고, 맞추기",
             "items": ["등급 변경 이력 ★", "리뷰 내용 정리 ★", "가격 급락 방지 ★★", "트리거도 ROLLBACK된다 ★★", "기사 배달 건수 ★★",
                       "쿠폰 보호 ★★", "취소하면 쿠폰 복구 ★★★", "리뷰 통계 완성판 ★★★", "통계 검증 ★★", "트리거 목록 ★"],
             "caption": "**순서대로.** 트리거를 고칠 땐 `DROP TRIGGER IF EXISTS` 후 다시 생성. 막히면 `DELIMITER ;`부터 확인."},
            {"type": "closing", "label": "다음 시간 · Ch12 저장 프로시저와 함수", "title": "CALL 주문하기(…)",
             "from": "개발팀 한 팀장",
             "text": "에러가 나면 ROLLBACK하는 코드를 앱마다 **네 번** 써야 해요. 주문 접수 로직을 DB에 **하나로** 저장하고, 실패하면 알아서 되돌리고 **이유도 기록**해 주세요. 그리고 매달 1일 **전 고객 등급 재산정**도요.",
             "teaser": "변수 · 조건문 · 반복문 · 커서 · 예외 처리 · 트랜잭션 — 저장 프로시저, Ch12."},
        ]},
    ],
}
