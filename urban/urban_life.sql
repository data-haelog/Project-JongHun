CREATE DATABASE IF NOT EXISTS urban_life
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE urban_life;


/* =========================
   1. cities
========================= */
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    population INT NOT NULL,
    region VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/* =========================
   2. mobility_logs
========================= */
CREATE TABLE mobility_logs (
    mobility_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    base_date DATE NOT NULL,
    hour TINYINT NOT NULL,
    transport_type VARCHAR(20) NOT NULL,
    movement_count INT NOT NULL,
    CONSTRAINT chk_hour CHECK (hour BETWEEN 0 AND 23),
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    INDEX idx_mobility_city_date (city_id, base_date)
);


/* =========================
   3. consumption_logs
========================= */
CREATE TABLE consumption_logs (
    consumption_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    base_date DATE NOT NULL,
    category VARCHAR(30) NOT NULL,
    spend_amount DECIMAL(12,2) NOT NULL,
    transaction_count INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    INDEX idx_consumption_city_date (city_id, base_date)
);


/* =========================
   4. weather_logs
========================= */
CREATE TABLE weather_logs (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    base_date DATE NOT NULL,
    temperature DECIMAL(4,1),
    weather_type VARCHAR(20),
    precipitation DECIMAL(5,1),
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    INDEX idx_weather_city_date (city_id, base_date)
);


/* =========================
   5. city_events
========================= */
CREATE TABLE city_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    expected_visitors INT,
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    INDEX idx_event_city_date (city_id, event_date)
);


/* =========================
   6. leisure_logs
========================= */
CREATE TABLE leisure_logs (
    leisure_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT NOT NULL,
    base_date DATE NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    participant_count INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    INDEX idx_leisure_city_date (city_id, base_date)
);


INSERT INTO cities (city_name, population, region) VALUES
('Seoul',   9500000, 'Capital Area'),
('Incheon', 3000000, 'Capital Area'),
('Busan',   3300000, 'Yeongnam'),
('Daegu',   2400000, 'Yeongnam'),
('Gwangju', 1500000, 'Honam'),
('Daejeon', 1450000, 'Chungcheong'),
('Ulsan',   1100000, 'Yeongnam');

INSERT INTO mobility_logs
(city_id, base_date, hour, transport_type, movement_count) VALUES
-- Seoul
(1, '2024-06-01', 8,  'Subway', 420000),
(1, '2024-06-01', 18, 'Bus',    310000),
-- Incheon 
(2, '2024-06-01', 7,  'Subway', 180000),
(2, '2024-06-01', 18, 'Car',    210000),
-- Busan
(3, '2024-06-01', 8,  'Bus',    160000),
(3, '2024-06-01', 18, 'Subway', 140000),
-- Daegu
(4, '2024-06-01', 8,  'Car',    120000),
-- Gwangju
(5, '2024-06-01', 18, 'Bus',     90000);

INSERT INTO consumption_logs
(city_id, base_date, category, spend_amount, transaction_count) VALUES
-- Seoul
(1, '2024-06-01', 'Food',      125000000.00, 520000),
(1, '2024-06-01', 'Shopping',  210000000.00, 310000),
-- Incheon
(2, '2024-06-01', 'Food',       42000000.00, 190000),
(2, '2024-06-01', 'Transport',  18000000.00, 160000),
-- Busan
(3, '2024-06-01', 'Food',       51000000.00, 230000),
(3, '2024-06-01', 'Leisure',    38000000.00, 150000),
-- Daejeon
(6, '2024-06-01', 'Education',  22000000.00,  90000);

INSERT INTO weather_logs
(city_id, base_date, temperature, weather_type, precipitation) VALUES
(1, '2024-06-01', 26.5, 'Clear', 0.0),
(2, '2024-06-01', 24.8, 'Cloudy', 0.0),
(3, '2024-06-01', 27.1, 'Clear', 0.0),
(4, '2024-06-01', 28.0, 'Clear', 0.0),
(5, '2024-06-01', 25.2, 'Rain', 12.4),
(6, '2024-06-01', 26.0, 'Cloudy', 0.0),
(7, '2024-06-01', 29.3, 'Clear', 0.0);

INSERT INTO city_events
(city_id, event_date, event_type, expected_visitors) VALUES
(1, '2024-06-05', 'Tech Expo',        120000),
(2, '2024-06-10', 'Port Festival',     80000),
(3, '2024-06-15', 'Beach Festival',   150000),
(4, '2024-06-20', 'Music Festival',    70000),
(5, '2024-06-25', 'Art Biennale',      60000),
(6, '2024-06-18', 'Startup Meetup',    40000);

INSERT INTO leisure_logs
(city_id, base_date, activity_type, participant_count) VALUES
-- Seoul
(1, '2024-06-01', 'Gym',        180000),
(1, '2024-06-01', 'Cinema',     220000),
-- Incheon
(2, '2024-06-01', 'Cinema',      90000),
(2, '2024-06-01', 'Seaside Walk',110000),
-- Busan
(3, '2024-06-01', 'Beach',      200000),
-- Gwangju
(5, '2024-06-01', 'Exhibition',  50000),
-- Ulsan
(7, '2024-06-01', 'Hiking',      45000);
