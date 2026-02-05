USE urban_life;

# 이벤트가 없는 도시
SELECT city_name
FROM cities
WHERE city_id NOT IN (
    SELECT DISTINCT city_id FROM city_events
);

# 소비 로그는 있으나 이동 로그가 없는 도시
SELECT DISTINCT c.city_name
FROM consumption_logs cl
JOIN cities c ON cl.city_id = c.city_id
WHERE cl.city_id NOT IN (
    SELECT DISTINCT city_id FROM mobility_logs
);
 
# 비 내리는 날 소비 기록이 없는 날
SELECT
    c.city_name,
    CASE
        WHEN cl.city_id IS NULL THEN 'No Consumption'
        ELSE 'Has Consumption'
    END AS consumption_status
FROM weather_logs w
LEFT JOIN consumption_logs cl
       ON w.city_id = cl.city_id
      AND w.base_date = cl.base_date
JOIN cities c ON c.city_id = w.city_id
WHERE w.weather_type = 'Rain';


# 평균 기온보다 더운 날이 있던 도시
SELECT DISTINCT c.city_name
FROM weather_logs w
JOIN cities c ON w.city_id = c.city_id
WHERE w.temperature >
      (SELECT AVG(temperature) FROM weather_logs);

# 시간대별 이동량
SELECT
    c.city_name,
    CASE
        WHEN m.hour BETWEEN 7 AND 9 THEN 'Morning'
        WHEN m.hour BETWEEN 17 AND 19 THEN 'Evening'
        ELSE 'Other'
    END AS time_slot,
    SUM(m.movement_count) AS total_movement
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.city_name, time_slot;


# 날씨별 강수 여부 플래그
SELECT
    city_id,
    base_date,
    CASE
        WHEN precipitation > 0 THEN 'Rainy'
        ELSE 'Dry'
    END AS rain_flag
FROM weather_logs;

# 고소비 / 저소비 도시 
SELECT
    c.city_name,
    SUM(cl.spend_amount) AS total_spend,
    CASE
        WHEN SUM(cl.spend_amount) >= 100000000 THEN 'High'
        ELSE 'Low'
    END AS spend_level
FROM consumption_logs cl
JOIN cities c ON cl.city_id = c.city_id
GROUP BY c.city_name;

# 교통수단별 이동 비중
SELECT
    transport_type,
    SUM(movement_count) AS total_movement
FROM mobility_logs
GROUP BY transport_type;

# 도시별 이동량 순위
SELECT
    c.city_name,
    SUM(m.movement_count) AS total_movement,
    RANK() OVER (ORDER BY SUM(m.movement_count) DESC) AS movement_rank
FROM mobility_logs m
JOIN cities c 
ON m.city_id = c.city_id
GROUP BY c.city_name;

# 도시별 소비 순위
SELECT
    city_id,
    SUM(spend_amount) AS total_spend,
    DENSE_RANK() OVER (ORDER BY SUM(spend_amount) DESC) AS spend_rank
FROM consumption_logs
GROUP BY city_id;

/*교통수단별 도시 랭킹 */
SELECT
    city_id,
    transport_type,
    SUM(movement_count) AS total_movement,
    RANK() OVER (PARTITION BY transport_type 
				ORDER BY SUM(movement_count) DESC) AS rank_in_type
FROM mobility_logs
GROUP BY city_id, transport_type;

/* 도시 내 소비 카테고리 순위 */
SELECT
    city_id,
    category,
    SUM(spend_amount) AS total_spend,
    RANK() OVER (PARTITION BY city_id 
				ORDER BY SUM(spend_amount) DESC) AS category_rank
FROM consumption_logs
GROUP BY city_id, category;

/*이벤트 예상 방문자 누적 합계*/
SELECT
    event_date,
    expected_visitors,
    SUM(expected_visitors) OVER (ORDER BY event_date) AS cumulative_visitors
FROM city_events;

# [Data Validation] 이동량이 0 이하인 이상치 확인
SELECT *
FROM mobility_logs
WHERE movement_count <= 0;

# 인구 대비 이동량 비율
SELECT
    c.city_name,
    SUM(m.movement_count) / c.population AS movement_per_capita
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.city_name, c.population;

# 평균 기온이 가장 높은 도시
SELECT city_id, AVG(temperature) AS avg_temp
FROM weather_logs
GROUP BY city_id
ORDER BY avg_temp DESC
LIMIT 1;

# 소비 트랜잭션당 평균 금액이 가장 높은 도시
SELECT
    city_id,
    SUM(spend_amount) / SUM(transaction_count) AS avg_tx_amount
FROM consumption_logs
GROUP BY city_id
ORDER BY avg_tx_amount DESC
LIMIT 1;

# 이벤트 날짜와 가장 가까운 소비 기록
SELECT
    c.city_name,
    e.event_date,
    cl.base_date,
    ABS(DATEDIFF(e.event_date, cl.base_date)) AS day_diff
FROM city_events e
JOIN consumption_logs cl
    ON e.city_id = cl.city_id
JOIN cities c
    ON e.city_id = c.city_id
WHERE ABS(DATEDIFF(e.event_date, cl.base_date)) =
      (
          SELECT MIN(ABS(DATEDIFF(e.event_date, cl2.base_date)))
          FROM consumption_logs cl2
          WHERE cl2.city_id = e.city_id
      );

# 도시별 로그 테이블 보유 여부 체크
SELECT
    c.city_name,
    COUNT(DISTINCT m.city_id) AS has_mobility,
    COUNT(DISTINCT cl.city_id) AS has_consumption
FROM cities c
LEFT JOIN mobility_logs m ON c.city_id = m.city_id
LEFT JOIN consumption_logs cl ON c.city_id = cl.city_id
GROUP BY c.city_name;

# 지역별 평균 인구
SELECT region, AVG(population) AS avg_population
FROM cities
GROUP BY region;

# 가장 다양한 여가 활동을 가진 도시
SELECT city_id, COUNT(DISTINCT activity_type) AS activity_types
FROM leisure_logs
GROUP BY city_id
ORDER BY activity_types DESC
LIMIT 1;

# 교통수단별 전체 이동량 비율
SELECT
    transport_type,
    SUM(movement_count) /
    (SELECT SUM(movement_count) FROM mobility_logs) AS movement_ratio
FROM mobility_logs
GROUP BY transport_type;

# 도시별 평균 시간당 이동량
SELECT
    city_id,
    AVG(movement_count) AS avg_hourly_movement
FROM mobility_logs
GROUP BY city_id;

# 날씨 × 이동량 영향 분석
SELECT
    w.weather_type,
    AVG(m.movement_count) AS avg_movement
FROM weather_logs w
JOIN mobility_logs m
  ON w.city_id = m.city_id
 AND w.base_date = m.base_date
GROUP BY w.weather_type;

