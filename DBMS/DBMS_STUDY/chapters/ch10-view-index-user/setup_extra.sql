-- @this-chapter-only  인덱스 통계 갱신 (Ch10 전용)
-- 데이터를 막 넣은 직후에는 MySQL이 테이블 크기를 아직 모를 수 있습니다.
-- 통계를 갱신해 두어야 EXPLAIN의 rows 값이 실제와 맞습니다.
ANALYZE TABLE customers, restaurants, menus, riders, orders, order_items, reviews;
