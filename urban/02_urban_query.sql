USE urban_life;

# 도시별 총 인구수 
SELECT city_name, population
FROM cities;

# 지역별 도시 수 
SELECT region, COUNT(*) AS city_count
FROM cities
GROUP BY region;

# 수도권 도시 목록 
SELECT city_name
FROM cities
WHERE region = 'Capital Area';

# 도시별 총 이동량과 순위
SELECT
    c.city_name,
    SUM(m.movement_count) AS total_movement,
    RANK() OVER (ORDER BY SUM(m.movement_count) DESC) AS movement_rank
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.city_name;

# 이동량이 30만 이상인 도시
SELECT
    c.city_name,
    SUM(m.movement_count) AS total_movement
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.city_name
HAVING SUM(m.movement_count) >= 300000;

# 출근 시간대 이동량 
SELECT
    c.city_name,
    SUM(m.movement_count) AS morning_movement
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
WHERE m.hour BETWEEN 7 AND 9
GROUP BY c.city_name;

# 교통수단별 이동 비중
SELECT
    transport_type,
    SUM(movement_count) AS total_movement,
    SUM(movement_count) /
        SUM(SUM(movement_count)) OVER () AS movement_ratio
FROM mobility_logs
GROUP BY transport_type;

# 도시별 총 소비 금액 
SELECT
    c.city_name,
    SUM(cl.spend_amount) AS total_spend
FROM consumption_logs cl
JOIN cities c ON cl.city_id = c.city_id
GROUP BY c.city_name;

# 소비 카테고리별 평균 결제 금액 
SELECT category,
       AVG(spend_amount / transaction_count) AS avg_spend_per_tx
FROM consumption_logs
GROUP BY category;

# 하루 소비액이 가장 높은 도시
SELECT
    c.city_name,
    SUM(cl.spend_amount) AS total_spend
FROM consumption_logs cl
JOIN cities c ON cl.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_spend DESC
LIMIT 1;

# 날씨 유형별 평균 기온
SELECT weather_type, AVG(temperature) AS avg_temp
FROM weather_logs
GROUP BY weather_type;

# 비 오는 날의 도시목록
SELECT c.city_name
FROM weather_logs w
JOIN cities c ON w.city_id = c.city_id
WHERE w.weather_type = 'Rain';

# 이벤트 기준으로 한 도시별 누적 방문자 수
SELECT
    c.city_name,
    e.event_date,
    e.expected_visitors,
    SUM(e.expected_visitors)
        OVER (
            PARTITION BY c.city_name
            ORDER BY e.event_date
        ) AS cumulative_visitors
FROM city_events e
JOIN cities c ON e.city_id = c.city_id;

# 방문 예상 인원 10만 이상 이벤트
SELECT event_type, expected_visitors
FROM city_events
WHERE expected_visitors >= 100000;

# 도시별 여가 활동 참여 인원 총 수 
SELECT
    c.city_name,
    SUM(l.participant_count) AS total_participants
FROM leisure_logs l
JOIN cities c ON l.city_id = c.city_id
GROUP BY c.city_name;

# 수도권 vs 비수도권 이동량 비교
SELECT
    c.region,
    SUM(m.movement_count) AS total_movement
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.region;

# 도시별 1인당 소비 금액
SELECT
    c.city_name,
    SUM(cons.spend_amount) / c.population AS spend_per_capita
FROM consumption_logs cons
JOIN cities c ON cons.city_id = c.city_id
GROUP BY c.city_name, c.population;

# 도시별 기준 하루 총 이동량
SELECT c.city_name, SUM(m.movement_count) AS total_movement
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.city_name;

# 도시별 평균 시간당 이동량 
SELECT c.city_name,
       AVG(m.movement_count) AS avg_hourly_movement
FROM mobility_logs m
JOIN cities c ON m.city_id = c.city_id
GROUP BY c.city_name;

# 평균 이동량보다 이동량이 많은 도시
SELECT
    c.city_name,
    SUM(m.movement_count) AS total_movement
FROM mobility_logs m
JOIN cities c 
ON m.city_id = c.city_id
GROUP BY c.city_name
HAVING SUM(m.movement_count) >
       (
           SELECT AVG(city_total)
           FROM (
               SELECT SUM(movement_count) AS city_total
               FROM mobility_logs
               GROUP BY city_id
           ) t
       );

# 전체 평균 소비 금액보다 소비가 높은 도시
SELECT
    c.city_name,
    SUM(cl.spend_amount) AS total_spend
FROM consumption_logs cl
JOIN cities c ON cl.city_id = c.city_id
GROUP BY c.city_name
HAVING SUM(cl.spend_amount) >
       (
           SELECT AVG(city_spend)
           FROM (
               SELECT SUM(spend_amount) AS city_spend
               FROM consumption_logs
               GROUP BY city_id
           ) t
       );

# 가장 인구가 많은 도시
SELECT city_name, population
FROM cities
WHERE population = (SELECT MAX(population) FROM cities);

# 여가 참여 인원이 가장 많은 도시
SELECT
    c.city_name,
    SUM(l.participant_count) AS total_participants
FROM leisure_logs l
JOIN cities c ON l.city_id = c.city_id
GROUP BY c.city_name
ORDER BY total_participants DESC
LIMIT 1;

