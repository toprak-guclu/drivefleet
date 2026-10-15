CREATE DATABASE IF NOT EXISTS drivefleet
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE drivefleet;

-- 1. BRANCHES

CREATE TABLE branches (
    id         INT NOT NULL AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    city       VARCHAR(100) NOT NULL,
    address    VARCHAR(255),
    phone      VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT INTO branches (id, name, city, address, phone) VALUES
    (1, 'Istanbul Branch', 'Istanbul', 'Atatürk Cad. No:1, Şişli', '+90 212 111 00 01'),
    (2, 'Izmir Branch', 'Izmir', 'Kordon Blv. No:5, Alsancak', '+90 232 222 00 02'),
    (3, 'Ankara Branch', 'Ankara', 'Kızılay Mah. No:12, Çankaya', '+90 312 333 00 03'),
    (4, 'Antalya Branch', 'Antalya', 'Lara Cad. No:8, Muratpaşa', '+90 242 444 00 04');


-- 2. USERS

CREATE TABLE users (
    id            INT NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(150) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    license_no    VARCHAR(30) UNIQUE,
    role          ENUM('customer','admin') NOT NULL DEFAULT 'customer',
    avg_rating    DECIMAL(3,2),
    total_rentals INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CHECK (avg_rating IS NULL OR avg_rating BETWEEN 1.00 AND 5.00),
    CHECK (total_rentals >= 0)
) ENGINE=InnoDB;

INSERT INTO users
    (id, full_name, email, phone, license_no, role, avg_rating, total_rentals)
VALUES
    (1, 'Ahmet Engin', 'ahmet@email.com', '+90 532 111 22 33', 'B-001234', 'customer', 4.50, 7),
    (2, 'Selin Yildiz', 'selin@email.com', '+90 544 222 33 44', 'B-002345', 'customer', 4.00, 3),
    (3, 'Murat Oz', 'murat@email.com', '+90 555 333 44 55', 'B-003456', 'customer', 3.80, 12),
    (4, 'Nilufer Kara', 'nilufer@email.com', '+90 533 444 55 66', 'B-004567', 'customer', 4.80, 5),
    (5, 'Admin User', 'admin@drivefleet.com', '+90 212 000 00 00', 'A-000001', 'admin', NULL, 0),
    (6, 'Deniz Arslan', 'deniz@email.com', '+90 532 555 10 11', 'B-005678', 'customer', 4.70, 4),
    (7, 'Ece Demir', 'ece@email.com', '+90 533 555 10 12', 'B-006789', 'customer', 4.20, 6),
    (8, 'Baran Aydin', 'baran@email.com', '+90 534 555 10 13', 'B-007890', 'customer', 4.10, 2),
    (9, 'Cemre Sahin', 'cemre@email.com', '+90 535 555 10 14', 'B-008901', 'customer', 4.90, 8),
    (10, 'Kerem Yilmaz', 'kerem@email.com', '+90 536 555 10 15', 'B-009012', 'customer', 3.90, 5),
    (11, 'Derya Aksoy', 'derya@email.com', '+90 537 555 10 16', 'B-010123', 'customer', 4.40, 7),
    (12, 'Emre Kaplan', 'emre@email.com', '+90 538 555 10 17', 'B-011234', 'customer', 4.60, 3),
    (13, 'Cansu Eren', 'cansu@email.com', '+90 539 555 10 18', 'B-012345', 'customer', 4.00, 4),
    (14, 'Mert Polat', 'mert@email.com', '+90 541 555 10 19', 'B-013456', 'customer', 3.70, 2),
    (15, 'Zeynep Celik', 'zeynep@email.com', '+90 542 555 10 20', 'B-014567', 'customer', 4.80, 9);

-- 3. CATEGORIES
-- Vehicle CATEGORIES: Sedan, SUV, Electric

CREATE TABLE categories (
    id   INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,

    PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT INTO categories (id, name) VALUES
    (1, 'Economy'),
    (2, 'Sedan'),
    (3, 'SUV'),
    (4, 'Luxury'),
    (5, 'Electric'),
    (6, 'Family'),
    (7, 'Sports'),
    (8, 'Classic'),
    (9, 'Performance'),
    (10, 'Compact'),
    (11, 'Diesel'),
    (12, 'Hybrid'),
    (13, 'Convertible');

-- 4. FEATURES
-- Vehicle features: Bluetooth, Navigation etc.

CREATE TABLE features (
    id   INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,

    PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT INTO features (id, name) VALUES
    (1, 'Bluetooth'),
    (2, 'Navigation'),
    (3, 'Backup Camera'),
    (4, 'Heated Seats'),
    (5, 'Cruise Control'),
    (6, 'Child Seat Support'),
    (7, 'Apple CarPlay'),
    (8, 'Parking Sensors'),
    (9, 'Leather Seats'),
    (10, 'Sunroof'),
    (11, 'Premium Sound'),
    (12, 'AWD'),
    (13, 'Performance Package'),
    (14, 'Diesel Efficiency'),
    (15, 'Lane Assist'),
    (16, 'Adaptive Cruise');

-- 5. INSURANCES
-- Rental insurance packages

CREATE TABLE insurances (
    id                   INT NOT NULL AUTO_INCREMENT,
    name                 VARCHAR(50) NOT NULL,
    daily_price           DECIMAL(10,2) NOT NULL,
    coverage_description  TEXT,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CHECK (daily_price >= 0)
) ENGINE=InnoDB;

INSERT INTO insurances
    (id, name, daily_price, coverage_description)
VALUES
    (1, 'Basic', 0.00, 'Standard insurance package with basic damage coverage.'),
    (2, 'Full', 120.00, 'Covers most accident damages with reduced customer liability.'),
    (3, 'Premium', 220.00, 'Includes full damage protection, theft protection and roadside assistance.');

-- 6. VEHICLES

CREATE TABLE vehicles (
    id           INT NOT NULL AUTO_INCREMENT,
    brand        VARCHAR(50) NOT NULL,
    model        VARCHAR(50) NOT NULL,
    year         YEAR NOT NULL,
    plate        VARCHAR(20) NOT NULL UNIQUE,
    fuel_type    ENUM('Gasoline','Diesel','Electric','Hybrid') NOT NULL DEFAULT 'Gasoline',
    transmission ENUM('Automatic','Manual') NOT NULL DEFAULT 'Automatic',
    daily_rate   DECIMAL(10,2) NOT NULL,
    mileage      INT NOT NULL DEFAULT 0,
    status       ENUM('AVAILABLE','RENTED','OUT_OF_SERVICE') NOT NULL DEFAULT 'AVAILABLE',
    branch_id    INT NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    FOREIGN KEY (branch_id) REFERENCES branches(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (daily_rate > 0),
    CHECK (mileage >= 0),

    INDEX idx_vehicle_status (status),
    INDEX idx_vehicle_branch (branch_id),
    INDEX idx_vehicle_fuel (fuel_type),
    INDEX idx_vehicle_price (daily_rate)
) ENGINE=InnoDB;

INSERT INTO vehicles
    (id, brand, model, year, plate, fuel_type, transmission, daily_rate, mileage, status, branch_id)
VALUES
    (1, 'Toyota', 'Corolla', 2022, '34 ABC 1234', 'Gasoline', 'Automatic', 250.00, 28400, 'AVAILABLE', 1),
    (2, 'BMW', '320i', 2023, '35 DEF 5678', 'Gasoline', 'Automatic', 680.00, 12300, 'RENTED', 2),
    (3, 'Renault', 'Clio', 2021, '06 GHI 9012', 'Diesel', 'Manual', 180.00, 44200, 'AVAILABLE', 3),
    (4, 'Volvo', 'XC60', 2023, '07 JKL 3456', 'Hybrid', 'Automatic', 420.00, 8900, 'OUT_OF_SERVICE', 4),
    (5, 'Tesla', 'Model 3', 2024, '34 MNO 7890', 'Electric', 'Automatic', 750.00, 5100, 'RENTED', 1),
    (6, 'Honda', 'Civic', 2022, '35 PQR 2341', 'Gasoline', 'Manual', 220.00, 31000, 'AVAILABLE', 2),
    (7, 'Hyundai', 'Tucson', 2023, '06 STU 5672', 'Diesel', 'Automatic', 340.00, 16700, 'AVAILABLE', 3),
    (8, 'Mercedes', 'C180', 2022, '34 VWX 8903', 'Gasoline', 'Automatic', 580.00, 22000, 'RENTED', 1),
    (9, 'Ford', 'Focus', 2021, '35 YZA 1234', 'Diesel', 'Manual', 200.00, 51200, 'AVAILABLE', 4),
    (10, 'Peugeot', '3008', 2023, '06 BCD 4565', 'Hybrid', 'Automatic', 390.00, 9800, 'OUT_OF_SERVICE', 2),
    (11, 'Dodge', 'Viper Gen 2', 2001, '34 VPR 2001', 'Gasoline', 'Manual', 4500.00, 38500, 'AVAILABLE', 1),
    (12, 'BMW', '645Ci', 2005, '35 BMW 0645', 'Gasoline', 'Automatic', 2400.00, 92000, 'AVAILABLE', 2),
    (13, 'Volkswagen', 'Touareg V10 TDI', 2007, '06 TDI 1010', 'Diesel', 'Automatic', 2200.00, 148000, 'RENTED', 3),
    (14, 'Cadillac', 'XLR', 2006, '07 XLR 2006', 'Gasoline', 'Automatic', 3100.00, 76000, 'AVAILABLE', 4),
    (15, 'Audi', 'Q7 V12 TDI', 2010, '34 Q7V 1212', 'Diesel', 'Automatic', 5200.00, 135000, 'OUT_OF_SERVICE', 1),
    (16, 'Mercedes', 'C63 AMG W204', 2012, '35 C63 2012', 'Gasoline', 'Automatic', 3600.00, 88000, 'RENTED', 2),
    (17, 'Ferrari', 'F355', 1998, '34 F355 98', 'Gasoline', 'Manual', 12500.00, 42000, 'AVAILABLE', 1),
    (18, 'Audi', 'RS6 V10 TFSI', 2009, '06 RS6 1010', 'Gasoline', 'Automatic', 5400.00, 97000, 'RENTED', 3),
    (19, 'Volkswagen', 'Golf R32', 2008, '35 R32 2008', 'Gasoline', 'Manual', 2100.00, 112000, 'AVAILABLE', 2),
    (20, 'Dodge', 'Charger 6.4', 2016, '07 DOD 0640', 'Gasoline', 'Automatic', 3800.00, 65000, 'AVAILABLE', 4),
    (21, 'BMW', 'M760Li', 2018, '34 M760 18', 'Gasoline', 'Automatic', 7600.00, 54000, 'RENTED', 1),
    (22, 'Jaguar', 'XKR', 2011, '07 XKR 2011', 'Gasoline', 'Automatic', 3900.00, 81000, 'AVAILABLE', 4),
    (23, 'Toyota', 'Yaris GR', 2021, '35 YGR 2021', 'Gasoline', 'Manual', 1800.00, 27000, 'RENTED', 2),
    (24, 'Fiat', 'Egea Cross Hybrid', 2023, '06 EGH 2023', 'Hybrid', 'Automatic', 750.00, 19000, 'AVAILABLE', 3),
    (25, 'Ford', 'Focus 1.5 EcoBlue', 2021, '07 FOC 150', 'Diesel', 'Manual', 700.00, 68000, 'AVAILABLE', 4),
    (26, 'Opel', 'Corsa 1.2', 2022, '06 CRS 120', 'Gasoline', 'Manual', 600.00, 36000, 'AVAILABLE', 3),
    (27, 'Audi', 'A3 35 TFSI', 2024, '34 A3T 2024', 'Gasoline', 'Automatic', 1250.00, 8000, 'AVAILABLE', 1),
    (28, 'Volkswagen', 'Polo 1.0', 2023, '35 POL 100', 'Gasoline', 'Manual', 650.00, 22000, 'AVAILABLE', 2),
    (29, 'Renault', 'Megane 1.5 dCi', 2018, '06 MGN 150', 'Diesel', 'Manual', 620.00, 89000, 'RENTED', 3),
    (30, 'Citroen', 'C4 1.6 e-HDi', 2015, '07 C4D 160', 'Diesel', 'Manual', 580.00, 128000, 'OUT_OF_SERVICE', 4);

-- 7. VEHICLE_CATEGORIES

CREATE TABLE vehicle_categories (
    vehicle_id  INT NOT NULL,
    category_id INT NOT NULL,

    PRIMARY KEY (vehicle_id, category_id),

    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (category_id) REFERENCES categories(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO vehicle_categories (vehicle_id, category_id) VALUES
    (1, 2), (1, 1),
    (2, 2), (2, 4),
    (3, 1),
    (4, 3), (4, 6),
    (5, 5), (5, 4),
    (6, 2),
    (7, 3), (7, 6),
    (8, 2), (8, 4),
    (9, 1),
    (10, 3), (10, 6),
    (11, 7), (11, 8), (11, 9),
    (12, 4), (12, 7),
    (13, 3), (13, 6), (13, 11),
    (14, 4), (14, 7), (14, 13),
    (15, 3), (15, 4), (15, 6), (15, 11),
    (16, 2), (16, 4), (16, 9),
    (17, 7), (17, 8), (17, 9), (17, 4),
    (18, 6), (18, 4), (18, 9),
    (19, 10), (19, 9),
    (20, 2), (20, 9),
    (21, 2), (21, 4),
    (22, 4), (22, 7), (22, 13),
    (23, 10), (23, 9),
    (24, 1), (24, 6), (24, 12),
    (25, 1), (25, 10), (25, 11),
    (26, 1), (26, 10),
    (27, 10), (27, 4),
    (28, 1), (28, 10),
    (29, 1), (29, 6), (29, 11),
    (30, 1), (30, 6), (30, 11);

-- 8. VEHICLE_FEATURES

CREATE TABLE vehicle_features (
    vehicle_id INT NOT NULL,
    feature_id INT NOT NULL,

    PRIMARY KEY (vehicle_id, feature_id),

    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (feature_id) REFERENCES features(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO vehicle_features (vehicle_id, feature_id) VALUES
    (1, 1), (1, 5), (1, 8),
    (2, 1), (2, 2), (2, 3), (2, 7), (2, 8),
    (3, 1), (3, 5),
    (4, 1), (4, 2), (4, 3), (4, 4), (4, 8),
    (5, 1), (5, 2), (5, 3), (5, 4), (5, 7), (5, 8),
    (6, 1), (6, 5), (6, 7),
    (7, 1), (7, 2), (7, 3), (7, 6), (7, 8),
    (8, 1), (8, 2), (8, 3), (8, 4), (8, 7), (8, 8),
    (9, 1), (9, 5),
    (10, 1), (10, 2), (10, 3), (10, 6), (10, 8),
    (11, 5), (11, 9), (11, 11), (11, 13),
    (12, 1), (12, 2), (12, 4), (12, 9), (12, 10), (12, 11),
    (13, 1), (13, 2), (13, 6), (13, 8), (13, 14), (13, 16),
    (14, 1), (14, 2), (14, 4), (14, 9), (14, 11),
    (15, 1), (15, 2), (15, 3), (15, 6), (15, 8), (15, 12), (15, 14),
    (16, 1), (16, 2), (16, 3), (16, 4), (16, 9), (16, 11), (16, 13),
    (17, 5), (17, 9), (17, 11), (17, 13),
    (18, 1), (18, 2), (18, 3), (18, 4), (18, 8), (18, 12), (18, 13),
    (19, 1), (19, 5), (19, 9), (19, 13),
    (20, 1), (20, 2), (20, 3), (20, 5), (20, 8), (20, 13),
    (21, 1), (21, 2), (21, 3), (21, 4), (21, 9), (21, 11), (21, 16),
    (22, 1), (22, 2), (22, 4), (22, 9), (22, 10), (22, 11),
    (23, 1), (23, 5), (23, 8), (23, 13),
    (24, 1), (24, 3), (24, 6), (24, 7), (24, 8), (24, 15),
    (25, 1), (25, 5), (25, 7), (25, 14),
    (26, 1), (26, 5), (26, 7),
    (27, 1), (27, 2), (27, 3), (27, 7), (27, 8), (27, 15),
    (28, 1), (28, 5), (28, 7), (28, 8),
    (29, 1), (29, 5), (29, 7), (29, 14),
    (30, 1), (30, 5), (30, 6), (30, 14);

-- 9. RENTALS

CREATE TABLE rentals (
    id               INT NOT NULL AUTO_INCREMENT,
    user_id          INT NOT NULL,
    vehicle_id       INT NOT NULL,
    pickup_branch_id INT NOT NULL,
    return_branch_id INT NOT NULL,
    insurance_id     INT,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    total_amount     DECIMAL(10,2) NOT NULL,
    status           ENUM('PENDING','ACTIVE','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    notes            TEXT,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (pickup_branch_id) REFERENCES branches(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (return_branch_id) REFERENCES branches(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (insurance_id) REFERENCES insurances(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CHECK (end_date >= start_date),
    CHECK (total_amount >= 0),

    INDEX idx_rental_user (user_id),
    INDEX idx_rental_vehicle (vehicle_id),
    INDEX idx_rental_status (status),
    INDEX idx_rental_insurance (insurance_id)
) ENGINE=InnoDB;

INSERT INTO rentals
    (id, user_id, vehicle_id, pickup_branch_id, return_branch_id, insurance_id, start_date, end_date, total_amount, status)
VALUES
    (1048, 1, 1, 2, 2, 2, '2026-05-02', '2026-05-07', 1250.00, 'ACTIVE'),
    (1047, 2, 2, 1, 3, 3, '2026-05-01', '2026-05-06', 3400.00, 'PENDING'),
    (1046, 3, 9, 3, 3, 1, '2026-04-28', '2026-05-02', 890.00, 'COMPLETED'),
    (1045, 4, 6, 4, 4, 2, '2026-04-25', '2026-04-28', 1050.00, 'COMPLETED'),
    (1044, 3, 4, 1, 1, 3, '2026-04-29', '2026-05-01', 2100.00, 'CANCELLED'),
    (1049, 6, 13, 3, 3, 2, '2026-05-04', '2026-05-08', 13200.00, 'ACTIVE'),
    (1050, 7, 11, 1, 4, 3, '2026-04-10', '2026-04-12', 13500.00, 'COMPLETED'),
    (1051, 8, 16, 2, 2, 2, '2026-05-03', '2026-05-06', 14640.00, 'ACTIVE'),
    (1052, 9, 17, 1, 1, 3, '2026-05-15', '2026-05-16', 25440.00, 'PENDING'),
    (1053, 10, 18, 3, 1, 3, '2026-05-01', '2026-05-04', 22480.00, 'ACTIVE'),
    (1054, 11, 19, 2, 2, 1, '2026-04-18', '2026-04-20', 6300.00, 'COMPLETED'),
    (1055, 12, 20, 4, 4, 2, '2026-05-06', '2026-05-09', 15680.00, 'PENDING'),
    (1056, 13, 21, 1, 2, 3, '2026-05-02', '2026-05-05', 31280.00, 'ACTIVE'),
    (1057, 14, 22, 4, 4, 2, '2026-04-21', '2026-04-23', 11700.00, 'COMPLETED'),
    (1058, 15, 23, 2, 3, 1, '2026-05-01', '2026-05-04', 7200.00, 'ACTIVE'),
    (1059, 6, 24, 3, 3, 1, '2026-04-14', '2026-04-17', 3000.00, 'COMPLETED'),
    (1060, 7, 25, 4, 1, 2, '2026-05-05', '2026-05-10', 4920.00, 'PENDING'),
    (1061, 9, 27, 1, 1, 2, '2026-04-27', '2026-04-29', 3990.00, 'COMPLETED'),
    (1062, 10, 28, 2, 2, 1, '2026-05-03', '2026-05-05', 1950.00, 'COMPLETED'),
    (1063, 11, 29, 3, 4, 2, '2026-05-02', '2026-05-07', 4440.00, 'ACTIVE');

-- 10. PAYMENTS

CREATE TABLE payments (
    id         INT NOT NULL AUTO_INCREMENT,
    rental_id  INT NOT NULL,
    amount     DECIMAL(10,2) NOT NULL,
    method     ENUM('Credit Card','Cash','Bank Transfer') NOT NULL,
    status     ENUM('Completed','Pending','Refunded') NOT NULL DEFAULT 'Pending',
    paid_at    TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    FOREIGN KEY (rental_id) REFERENCES rentals(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CHECK (amount >= 0),

    INDEX idx_payment_rental (rental_id),
    INDEX idx_payment_status (status),
    INDEX idx_payment_method (method)
) ENGINE=InnoDB;

INSERT INTO payments
    (id, rental_id, amount, method, status, paid_at)
VALUES
    (501, 1048, 1250.00, 'Credit Card', 'Completed', '2026-05-02 10:15:00'),
    (500, 1045, 720.00, 'Cash', 'Completed', '2026-04-30 14:30:00'),
    (499, 1046, 890.00, 'Bank Transfer', 'Pending', NULL),
    (498, 1044, 2100.00, 'Credit Card', 'Refunded', '2026-04-29 09:00:00'),
    (502, 1049, 13200.00, 'Credit Card', 'Completed', '2026-05-04 09:45:00'),
    (503, 1050, 13500.00, 'Credit Card', 'Completed', '2026-04-10 11:20:00'),
    (504, 1051, 14640.00, 'Bank Transfer', 'Pending', NULL),
    (505, 1052, 5000.00, 'Credit Card', 'Pending', NULL),
    (506, 1053, 22480.00, 'Credit Card', 'Completed', '2026-05-01 12:05:00'),
    (507, 1054, 6300.00, 'Cash', 'Completed', '2026-04-18 16:00:00'),
    (508, 1055, 4000.00, 'Bank Transfer', 'Pending', NULL),
    (509, 1056, 31280.00, 'Credit Card', 'Completed', '2026-05-02 17:30:00'),
    (510, 1057, 11700.00, 'Cash', 'Completed', '2026-04-21 10:10:00'),
    (511, 1058, 7200.00, 'Credit Card', 'Completed', '2026-05-01 08:55:00'),
    (512, 1059, 3000.00, 'Bank Transfer', 'Completed', '2026-04-14 13:25:00'),
    (513, 1060, 4920.00, 'Credit Card', 'Pending', NULL),
    (514, 1061, 3990.00, 'Cash', 'Completed', '2026-04-27 15:15:00'),
    (515, 1062, 1950.00, 'Cash', 'Completed', '2026-05-03 19:40:00'),
    (516, 1063, 4440.00, 'Credit Card', 'Completed', '2026-05-02 09:10:00');

-- 11. MAINTENANCE RECORDS
-- Service records

CREATE TABLE maintenance_records (
    id           INT NOT NULL AUTO_INCREMENT,
    vehicle_id   INT NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    description  TEXT,
    cost         DECIMAL(10,2) NOT NULL DEFAULT 0,
    service_date DATE NOT NULL,
    status       ENUM('PLANNED','IN_PROGRESS','COMPLETED') NOT NULL DEFAULT 'PLANNED',
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CHECK (cost >= 0),

    INDEX idx_maintenance_vehicle (vehicle_id),
    INDEX idx_maintenance_status (status),
    INDEX idx_maintenance_date (service_date)
) ENGINE=InnoDB;

INSERT INTO maintenance_records
    (id, vehicle_id, service_type, description, cost, service_date, status)
VALUES
    (1, 4, 'Hybrid System Check', 'Hybrid battery warning light inspection.', 3500.00, '2026-05-01', 'IN_PROGRESS'),
    (2, 10, 'Body Repair', 'Front bumper and parking sensor repair.', 2800.00, '2026-04-29', 'PLANNED'),
    (3, 3, 'Oil Change', 'Standard oil and filter replacement.', 750.00, '2026-04-15', 'COMPLETED'),
    (4, 8, 'Brake Inspection', 'Brake pad and disc inspection.', 1250.00, '2026-04-20', 'COMPLETED'),
    (5, 15, 'Diesel Injection Service', 'V12 TDI injector and fuel rail inspection.', 9200.00, '2026-05-03', 'IN_PROGRESS'),
    (6, 30, 'Turbo and EGR Service', 'Diesel turbo pressure loss and EGR cleaning.', 3100.00, '2026-05-02', 'PLANNED'),
    (7, 17, 'Classic Inspection', 'Ferrari F355 belt and cooling system inspection.', 7800.00, '2026-04-22', 'COMPLETED'),
    (8, 19, 'Haldex Service', 'Golf R32 AWD Haldex oil and filter service.', 1600.00, '2026-04-26', 'COMPLETED'),
    (9, 23, 'Performance Brake Check', 'Yaris GR brake pad and tire inspection.', 1400.00, '2026-04-30', 'COMPLETED');

-- DASHBOARD VIEWS
-- For front end display

-- Vehicles dashboard

CREATE OR REPLACE VIEW v_dashboard_vehicles AS
SELECT
    v.id,
    v.brand,
    v.model,
    v.year,
    v.plate,
    v.fuel_type AS fuel,
    v.transmission AS trans,
    v.daily_rate AS price,
    v.mileage AS km,
    b.city AS branch,
    b.name AS branch_name,
    v.status,

    GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS categories,
    GROUP_CONCAT(DISTINCT f.name ORDER BY f.name SEPARATOR ', ') AS features

FROM vehicles v
JOIN branches b ON b.id = v.branch_id

LEFT JOIN vehicle_categories vc ON vc.vehicle_id = v.id
LEFT JOIN categories c ON c.id = vc.category_id

LEFT JOIN vehicle_features vf ON vf.vehicle_id = v.id
LEFT JOIN features f ON f.id = vf.feature_id

GROUP BY
    v.id,
    v.brand,
    v.model,
    v.year,
    v.plate,
    v.fuel_type,
    v.transmission,
    v.daily_rate,
    v.mileage,
    b.city,
    b.name,
    v.status;

-- Customers dashboard

CREATE OR REPLACE VIEW v_dashboard_customers AS
SELECT
    u.id,
    u.full_name AS customer,
    u.email,
    u.phone,
    u.license_no,
    CASE
        WHEN u.role = 'customer' THEN 'Customer'
        WHEN u.role = 'admin' THEN 'Admin'
        ELSE u.role
    END AS role,
    u.total_rentals,
    u.avg_rating
FROM users u;

-- Rentals dashboard

CREATE OR REPLACE VIEW v_dashboard_rentals AS
SELECT
    r.id AS rental_id,
    u.full_name AS customer,
    CONCAT(v.brand, ' ', v.model) AS vehicle,
    b1.city AS pickup,
    b2.city AS return_location,
    i.name AS insurance_type,
    i.daily_price AS insurance_daily_price,
    r.start_date,
    r.end_date,
    CONCAT(
        DATE_FORMAT(r.start_date, '%b %e'),
        '–',
        DATE_FORMAT(r.end_date, '%b %e')
    ) AS date_range,
    r.total_amount AS total,
    r.status
FROM rentals r
JOIN users u ON u.id = r.user_id
JOIN vehicles v ON v.id = r.vehicle_id
JOIN branches b1 ON b1.id = r.pickup_branch_id
JOIN branches b2 ON b2.id = r.return_branch_id
LEFT JOIN insurances i ON i.id = r.insurance_id;

-- Payments dashboard

CREATE OR REPLACE VIEW v_dashboard_payments AS
SELECT
    p.id AS payment_id,
    p.rental_id,
    p.amount,
    p.paid_at AS payment_date,
    p.method,
    p.status
FROM payments p;

-- Payment summary cards

CREATE OR REPLACE VIEW v_dashboard_payment_summary AS
SELECT
    COALESCE(SUM(CASE
        WHEN status = 'Completed'
         AND paid_at IS NOT NULL
         AND MONTH(paid_at) = MONTH(CURRENT_DATE())
         AND YEAR(paid_at) = YEAR(CURRENT_DATE())
        THEN amount ELSE 0 END), 0) AS monthly_revenue,

    COALESCE(SUM(CASE
        WHEN status = 'Completed'
         AND method = 'Credit Card'
        THEN amount ELSE 0 END), 0) AS credit_card_total,

    COALESCE(SUM(CASE
        WHEN status = 'Completed'
         AND method = 'Cash'
        THEN amount ELSE 0 END), 0) AS cash_total,

    COALESCE(SUM(CASE
        WHEN status = 'Completed'
         AND method = 'Bank Transfer'
        THEN amount ELSE 0 END), 0) AS bank_transfer_total
FROM payments;

-- Rental summary cards

CREATE OR REPLACE VIEW v_dashboard_rental_summary AS
SELECT
    COUNT(*) AS total,
    COALESCE(SUM(status = 'ACTIVE'), 0) AS active,
    COALESCE(SUM(status = 'PENDING'), 0) AS pending,
    COALESCE(SUM(status = 'COMPLETED'), 0) AS completed,
    COALESCE(SUM(status = 'CANCELLED'), 0) AS cancelled
FROM rentals;

-- Branch filter view

CREATE OR REPLACE VIEW v_dashboard_branches AS
SELECT
    id,
    name,
    city
FROM branches
ORDER BY city, name;

-- COMPLEX JOIN VIEWS

-- ------------------------------------------------------------
-- 1. Vehicle full details
-- Vehicle details + branch + categories + features
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_vehicle_full_details AS
SELECT
    v.id AS vehicle_id,
    CONCAT(v.brand, ' ', v.model) AS vehicle,
    v.year,
    v.plate,
    v.fuel_type,
    v.transmission,
    v.daily_rate,
    v.mileage,
    v.status,
    b.city AS branch_city,
    b.name AS branch_name,

    GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS categories,
    GROUP_CONCAT(DISTINCT f.name ORDER BY f.name SEPARATOR ', ') AS features

FROM vehicles v
JOIN branches b ON b.id = v.branch_id

LEFT JOIN vehicle_categories vc ON vc.vehicle_id = v.id
LEFT JOIN categories c ON c.id = vc.category_id

LEFT JOIN vehicle_features vf ON vf.vehicle_id = v.id
LEFT JOIN features f ON f.id = vf.feature_id

GROUP BY
    v.id,
    v.brand,
    v.model,
    v.year,
    v.plate,
    v.fuel_type,
    v.transmission,
    v.daily_rate,
    v.mileage,
    v.status,
    b.city,
    b.name;

-- ------------------------------------------------------------
-- 2. Vehicle category-feature report
-- Vehicle category + branch + available features report
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_vehicle_category_feature_report AS
SELECT
    b.city AS branch,
    c.name AS category,
    COUNT(DISTINCT v.id) AS vehicle_count,
    GROUP_CONCAT(DISTINCT CONCAT(v.brand, ' ', v.model) ORDER BY v.brand SEPARATOR ', ') AS vehicles,
    GROUP_CONCAT(DISTINCT f.name ORDER BY f.name SEPARATOR ', ') AS available_features
FROM vehicles v
JOIN branches b ON b.id = v.branch_id

JOIN vehicle_categories vc ON vc.vehicle_id = v.id
JOIN categories c ON c.id = vc.category_id

LEFT JOIN vehicle_features vf ON vf.vehicle_id = v.id
LEFT JOIN features f ON f.id = vf.feature_id

GROUP BY
    b.city,
    c.name;

-- ------------------------------------------------------------
-- 3. Maintenance dashboard
-- Service records + vehicle details + branch
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_maintenance_dashboard AS
SELECT
    mr.id AS maintenance_id,
    CONCAT(v.brand, ' ', v.model) AS vehicle,
    v.plate,
    v.status AS vehicle_status,
    b.city AS branch,
    b.name AS branch_name,
    mr.service_type,
    mr.description,
    mr.cost,
    mr.service_date,
    mr.status AS maintenance_status
FROM maintenance_records mr
JOIN vehicles v ON v.id = mr.vehicle_id
JOIN branches b ON b.id = v.branch_id;

-- ------------------------------------------------------------
-- 4. Out of service vehicle report
-- Shows the service reason for OUT_OF_SERVICE vehicles.
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_out_of_service_vehicle_report AS
SELECT
    v.id AS vehicle_id,
    CONCAT(v.brand, ' ', v.model) AS vehicle,
    v.plate,
    b.city AS branch,
    v.status AS vehicle_status,

    mr.service_type,
    mr.description,
    mr.cost,
    mr.service_date,
    mr.status AS maintenance_status,

    MAX(r.end_date) AS last_rental_end_date

FROM vehicles v
JOIN branches b ON b.id = v.branch_id

LEFT JOIN maintenance_records mr ON mr.vehicle_id = v.id
LEFT JOIN rentals r ON r.vehicle_id = v.id

WHERE v.status = 'OUT_OF_SERVICE'

GROUP BY
    v.id,
    v.brand,
    v.model,
    v.plate,
    b.city,
    v.status,
    mr.service_type,
    mr.description,
    mr.cost,
    mr.service_date,
    mr.status;

-- ------------------------------------------------------------
-- 5. Rental insurance report
-- Rental details + customer + vehicle + insurance
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_rental_insurance_report AS
SELECT
    r.id AS rental_id,
    u.full_name AS customer,
    CONCAT(v.brand, ' ', v.model) AS vehicle,
    v.plate,

    pickup.city AS pickup_city,
    return_b.city AS return_city,

    i.name AS insurance_type,
    i.daily_price AS insurance_daily_price,
    i.coverage_description,

    DATEDIFF(r.end_date, r.start_date) + 1 AS rental_days,
    r.total_amount,
    r.status

FROM rentals r
JOIN users u ON u.id = r.user_id
JOIN vehicles v ON v.id = r.vehicle_id

JOIN branches pickup ON pickup.id = r.pickup_branch_id
JOIN branches return_b ON return_b.id = r.return_branch_id

LEFT JOIN insurances i ON i.id = r.insurance_id;

-- ------------------------------------------------------------
-- 6. Complex rental payment insurance report
-- Rental + customer + vehicle + insurance + payment
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_complex_rental_payment_insurance_report AS
SELECT
    r.id AS rental_id,
    u.full_name AS customer,
    CONCAT(v.brand, ' ', v.model) AS vehicle,
    v.plate,

    i.name AS insurance_type,
    i.daily_price AS insurance_daily_price,

    DATEDIFF(r.end_date, r.start_date) + 1 AS rental_days,

    r.total_amount AS rental_total,
    COALESCE(SUM(p.amount), 0) AS paid_amount,

    CASE
        WHEN COALESCE(SUM(p.amount), 0) >= r.total_amount THEN 'Fully Paid'
        WHEN COALESCE(SUM(p.amount), 0) = 0 THEN 'Not Paid'
        ELSE 'Partially Paid'
    END AS payment_result,

    r.status AS rental_status

FROM rentals r
JOIN users u ON u.id = r.user_id
JOIN vehicles v ON v.id = r.vehicle_id

LEFT JOIN insurances i ON i.id = r.insurance_id
LEFT JOIN payments p ON p.rental_id = r.id
    AND p.status = 'Completed'

GROUP BY
    r.id,
    u.full_name,
    v.brand,
    v.model,
    v.plate,
    i.name,
    i.daily_price,
    r.start_date,
    r.end_date,
    r.total_amount,
    r.status;

-- ------------------------------------------------------------
-- 7. Insurance usage report
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_insurance_usage_report AS
SELECT
    i.id AS insurance_id,
    i.name AS insurance_type,
    i.daily_price,

    COUNT(r.id) AS rental_count,

    COALESCE(SUM(
        (DATEDIFF(r.end_date, r.start_date) + 1) * i.daily_price
    ), 0) AS estimated_insurance_revenue

FROM insurances i
LEFT JOIN rentals r ON r.insurance_id = i.id

GROUP BY
    i.id,
    i.name,
    i.daily_price;

-- ------------------------------------------------------------
-- 8. Fleet summary
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_fleet_summary AS
SELECT
    b.city,
    COUNT(v.id) AS total_vehicles,
    COALESCE(SUM(v.status = 'AVAILABLE'), 0) AS available,
    COALESCE(SUM(v.status = 'RENTED'), 0) AS rented,
    COALESCE(SUM(v.status = 'OUT_OF_SERVICE'), 0) AS out_of_service,
    ROUND(
        COALESCE(SUM(v.status = 'RENTED'), 0) / COUNT(v.id) * 100,
        1
    ) AS rented_rate_percent
FROM vehicles v
JOIN branches b ON b.id = v.branch_id
GROUP BY
    b.id,
    b.city;

-- ------------------------------------------------------------
-- 9. Monthly revenue
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT
    DATE_FORMAT(p.paid_at, '%Y-%m') AS month,
    p.method,
    SUM(p.amount) AS total_revenue,
    COUNT(*) AS transaction_count
FROM payments p
WHERE p.status = 'Completed'
  AND p.paid_at IS NOT NULL
GROUP BY
    DATE_FORMAT(p.paid_at, '%Y-%m'),
    p.method
ORDER BY
    month DESC,
    total_revenue DESC;

-- ============================================================
-- ADMIN PANEL VIEWS
-- These views are optional helpers for the Admin Panel.
-- The actual Add / Update / Delete operations still use the real tables:
-- vehicles and users.
-- ============================================================

CREATE OR REPLACE VIEW v_admin_vehicle_management AS
SELECT
    v.id,
    v.brand,
    v.model,
    v.year,
    v.plate,
    v.fuel_type,
    v.transmission,
    v.daily_rate,
    v.mileage,
    v.status,
    v.branch_id,
    b.city AS branch_city,
    b.name AS branch_name,
    COUNT(DISTINCT r.id) AS rental_record_count
FROM vehicles v
JOIN branches b ON b.id = v.branch_id
LEFT JOIN rentals r ON r.vehicle_id = v.id
GROUP BY
    v.id,
    v.brand,
    v.model,
    v.year,
    v.plate,
    v.fuel_type,
    v.transmission,
    v.daily_rate,
    v.mileage,
    v.status,
    v.branch_id,
    b.city,
    b.name;

CREATE OR REPLACE VIEW v_admin_customer_management AS
SELECT
    u.id,
    u.full_name,
    u.email,
    u.phone,
    u.license_no,
    u.role,
    u.avg_rating,
    u.total_rentals,
    COUNT(DISTINCT r.id) AS rental_record_count
FROM users u
LEFT JOIN rentals r ON r.user_id = u.id
GROUP BY
    u.id,
    u.full_name,
    u.email,
    u.phone,
    u.license_no,
    u.role,
    u.avg_rating,
    u.total_rentals;

-- Quick check queries for admin panel
-- SELECT * FROM v_admin_vehicle_management;
-- SELECT * FROM v_admin_customer_management;

-- ============================================================
-- INITIAL DATA SYNCHRONIZATION
-- The seed data above is inserted before the triggers exist, so this block
-- applies the same rules once to the sample records. It runs BEFORE the
-- triggers are created: otherwise the rental triggers would try to update
-- `vehicles` while this statement reads it (MySQL error 1442).
-- ============================================================

-- Recalculate rental totals for existing sample rentals.
UPDATE rentals r
JOIN vehicles v ON v.id = r.vehicle_id
LEFT JOIN insurances i ON i.id = r.insurance_id
SET r.total_amount = ROUND(
    (v.daily_rate + COALESCE(i.daily_price, 0)) * GREATEST(1, DATEDIFF(r.end_date, r.start_date)),
    2
);

-- Recalculate total rental count for existing customers.
UPDATE users u
SET u.total_rentals = (
    SELECT COUNT(*)
    FROM rentals r
    WHERE r.user_id = u.id
);

-- Set vehicles without active rentals or open maintenance to AVAILABLE.
UPDATE vehicles v
SET v.status = 'AVAILABLE'
WHERE NOT EXISTS (
    SELECT 1
    FROM rentals r
    WHERE r.vehicle_id = v.id
      AND r.status IN ('PENDING', 'ACTIVE')
)
AND NOT EXISTS (
    SELECT 1
    FROM maintenance_records m
    WHERE m.vehicle_id = v.id
      AND m.status IN ('PLANNED', 'IN_PROGRESS')
);

-- Set vehicles with active or pending rentals to RENTED, unless maintenance is open.
UPDATE vehicles v
SET v.status = 'RENTED'
WHERE EXISTS (
    SELECT 1
    FROM rentals r
    WHERE r.vehicle_id = v.id
      AND r.status IN ('PENDING', 'ACTIVE')
)
AND NOT EXISTS (
    SELECT 1
    FROM maintenance_records m
    WHERE m.vehicle_id = v.id
      AND m.status IN ('PLANNED', 'IN_PROGRESS')
);

-- Open maintenance has the highest priority and makes the vehicle OUT_OF_SERVICE.
UPDATE vehicles v
SET v.status = 'OUT_OF_SERVICE'
WHERE EXISTS (
    SELECT 1
    FROM maintenance_records m
    WHERE m.vehicle_id = v.id
      AND m.status IN ('PLANNED', 'IN_PROGRESS')
);

-- ============================================================
-- BUSINESS RULE TRIGGERS
-- These triggers automate important database rules used by the dashboard.
-- They help the UI stay consistent without requiring manual status or price updates.
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- Trigger 1: Prevent double booking on insert
-- This trigger blocks a new rental if the same vehicle is already booked
-- in an overlapping date range with PENDING or ACTIVE status.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_prevent_double_booking_insert$$
CREATE TRIGGER trg_prevent_double_booking_insert
BEFORE INSERT ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status IN ('PENDING', 'ACTIVE') AND EXISTS (
        SELECT 1
        FROM rentals r
        WHERE r.vehicle_id = NEW.vehicle_id
          AND r.status IN ('PENDING', 'ACTIVE')
          AND r.start_date < NEW.end_date
          AND r.end_date > NEW.start_date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This vehicle is already booked for the selected date range.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 2: Prevent double booking on update
-- This trigger performs the same overlap check when an existing rental
-- is edited and its vehicle, date range, or status changes.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_prevent_double_booking_update$$
CREATE TRIGGER trg_prevent_double_booking_update
BEFORE UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status IN ('PENDING', 'ACTIVE') AND EXISTS (
        SELECT 1
        FROM rentals r
        WHERE r.id <> OLD.id
          AND r.vehicle_id = NEW.vehicle_id
          AND r.status IN ('PENDING', 'ACTIVE')
          AND r.start_date < NEW.end_date
          AND r.end_date > NEW.start_date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This vehicle is already booked for the selected date range.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 3: Calculate rental total on insert
-- This trigger calculates total_amount automatically from vehicle daily rate,
-- insurance daily price, and rental day count.
-- Formula: (vehicle daily_rate + insurance daily_price) * rental days.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_calculate_rental_total_insert$$
CREATE TRIGGER trg_calculate_rental_total_insert
BEFORE INSERT ON rentals
FOR EACH ROW
BEGIN
    DECLARE v_daily_rate DECIMAL(10,2) DEFAULT 0;
    DECLARE v_insurance_daily_price DECIMAL(10,2) DEFAULT 0;
    DECLARE v_days INT DEFAULT 1;

    SELECT COALESCE(daily_rate, 0)
    INTO v_daily_rate
    FROM vehicles
    WHERE id = NEW.vehicle_id;

    SET v_insurance_daily_price = COALESCE((
        SELECT daily_price
        FROM insurances
        WHERE id = NEW.insurance_id
        LIMIT 1
    ), 0);

    SET v_days = GREATEST(1, DATEDIFF(NEW.end_date, NEW.start_date));

    SET NEW.total_amount = ROUND((v_daily_rate + v_insurance_daily_price) * v_days, 2);
END$$

-- ------------------------------------------------------------
-- Trigger 4: Recalculate rental total on update
-- If the vehicle, insurance package, or rental dates change,
-- the database recalculates total_amount automatically.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_calculate_rental_total_update$$
CREATE TRIGGER trg_calculate_rental_total_update
BEFORE UPDATE ON rentals
FOR EACH ROW
BEGIN
    DECLARE v_daily_rate DECIMAL(10,2) DEFAULT 0;
    DECLARE v_insurance_daily_price DECIMAL(10,2) DEFAULT 0;
    DECLARE v_days INT DEFAULT 1;

    IF NEW.vehicle_id <> OLD.vehicle_id
       OR NOT (NEW.insurance_id <=> OLD.insurance_id)
       OR NEW.start_date <> OLD.start_date
       OR NEW.end_date <> OLD.end_date THEN

        SELECT COALESCE(daily_rate, 0)
        INTO v_daily_rate
        FROM vehicles
        WHERE id = NEW.vehicle_id;

        SET v_insurance_daily_price = COALESCE((
            SELECT daily_price
            FROM insurances
            WHERE id = NEW.insurance_id
            LIMIT 1
        ), 0);

        SET v_days = GREATEST(1, DATEDIFF(NEW.end_date, NEW.start_date));

        SET NEW.total_amount = ROUND((v_daily_rate + v_insurance_daily_price) * v_days, 2);
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 5: Update vehicle status after rental insert
-- When a rental becomes PENDING or ACTIVE, the vehicle is marked as RENTED.
-- OUT_OF_SERVICE vehicles are not overwritten by rental status.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vehicle_status_after_rental_insert$$
CREATE TRIGGER trg_vehicle_status_after_rental_insert
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status IN ('PENDING', 'ACTIVE') THEN
        UPDATE vehicles
        SET status = 'RENTED'
        WHERE id = NEW.vehicle_id
          AND status <> 'OUT_OF_SERVICE';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 6: Update vehicle status after rental update
-- ACTIVE/PENDING rentals keep the vehicle RENTED.
-- COMPLETED/CANCELLED rentals release the vehicle if there is no other
-- active booking and no unfinished maintenance record.
-- If the rental is moved to a different vehicle, the old vehicle is released too.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vehicle_status_after_rental_update$$
CREATE TRIGGER trg_vehicle_status_after_rental_update
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status IN ('PENDING', 'ACTIVE') THEN
        UPDATE vehicles
        SET status = 'RENTED'
        WHERE id = NEW.vehicle_id
          AND status <> 'OUT_OF_SERVICE';
    END IF;

    IF NEW.status IN ('COMPLETED', 'CANCELLED') THEN
        IF NOT EXISTS (
            SELECT 1
            FROM rentals r
            WHERE r.vehicle_id = NEW.vehicle_id
              AND r.status IN ('PENDING', 'ACTIVE')
              AND r.id <> NEW.id
        ) AND NOT EXISTS (
            SELECT 1
            FROM maintenance_records m
            WHERE m.vehicle_id = NEW.vehicle_id
              AND m.status IN ('PLANNED', 'IN_PROGRESS')
        ) THEN
            UPDATE vehicles
            SET status = 'AVAILABLE'
            WHERE id = NEW.vehicle_id;
        END IF;
    END IF;

    -- If the rental was moved to another vehicle, release the previous one
    -- when it has no other active/pending rental and no unfinished maintenance.
    IF NEW.vehicle_id <> OLD.vehicle_id AND NOT EXISTS (
        SELECT 1
        FROM rentals r
        WHERE r.vehicle_id = OLD.vehicle_id
          AND r.status IN ('PENDING', 'ACTIVE')
    ) AND NOT EXISTS (
        SELECT 1
        FROM maintenance_records m
        WHERE m.vehicle_id = OLD.vehicle_id
          AND m.status IN ('PLANNED', 'IN_PROGRESS')
    ) THEN
        UPDATE vehicles
        SET status = 'AVAILABLE'
        WHERE id = OLD.vehicle_id;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 7: Update vehicle status after rental delete
-- If a rental is removed, the vehicle becomes AVAILABLE only when
-- it has no other active/pending rental and no unfinished maintenance.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vehicle_status_after_rental_delete$$
CREATE TRIGGER trg_vehicle_status_after_rental_delete
AFTER DELETE ON rentals
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM rentals r
        WHERE r.vehicle_id = OLD.vehicle_id
          AND r.status IN ('PENDING', 'ACTIVE')
    ) AND NOT EXISTS (
        SELECT 1
        FROM maintenance_records m
        WHERE m.vehicle_id = OLD.vehicle_id
          AND m.status IN ('PLANNED', 'IN_PROGRESS')
    ) THEN
        UPDATE vehicles
        SET status = 'AVAILABLE'
        WHERE id = OLD.vehicle_id;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 8: Maintenance insert controls vehicle availability
-- A planned or in-progress maintenance record immediately marks
-- the related vehicle as OUT_OF_SERVICE in the Vehicle Fleet UI.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vehicle_status_after_maintenance_insert$$
CREATE TRIGGER trg_vehicle_status_after_maintenance_insert
AFTER INSERT ON maintenance_records
FOR EACH ROW
BEGIN
    IF NEW.status IN ('PLANNED', 'IN_PROGRESS') THEN
        UPDATE vehicles
        SET status = 'OUT_OF_SERVICE'
        WHERE id = NEW.vehicle_id;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 9: Maintenance update controls vehicle availability
-- If maintenance is completed, the vehicle can return to AVAILABLE,
-- but only if it has no active/pending rental and no other open maintenance.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vehicle_status_after_maintenance_update$$
CREATE TRIGGER trg_vehicle_status_after_maintenance_update
AFTER UPDATE ON maintenance_records
FOR EACH ROW
BEGIN
    IF NEW.status IN ('PLANNED', 'IN_PROGRESS') THEN
        UPDATE vehicles
        SET status = 'OUT_OF_SERVICE'
        WHERE id = NEW.vehicle_id;
    END IF;

    IF NEW.status = 'COMPLETED' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM maintenance_records m
            WHERE m.vehicle_id = NEW.vehicle_id
              AND m.status IN ('PLANNED', 'IN_PROGRESS')
              AND m.id <> NEW.id
        ) AND NOT EXISTS (
            SELECT 1
            FROM rentals r
            WHERE r.vehicle_id = NEW.vehicle_id
              AND r.status IN ('PENDING', 'ACTIVE')
        ) THEN
            UPDATE vehicles
            SET status = 'AVAILABLE'
            WHERE id = NEW.vehicle_id;
        END IF;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 10: Maintenance delete controls vehicle availability
-- If an unfinished maintenance record is deleted, the vehicle can return
-- to AVAILABLE only when no other unfinished maintenance or active rental exists.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_vehicle_status_after_maintenance_delete$$
CREATE TRIGGER trg_vehicle_status_after_maintenance_delete
AFTER DELETE ON maintenance_records
FOR EACH ROW
BEGIN
    IF OLD.status IN ('PLANNED', 'IN_PROGRESS') THEN
        IF NOT EXISTS (
            SELECT 1
            FROM maintenance_records m
            WHERE m.vehicle_id = OLD.vehicle_id
              AND m.status IN ('PLANNED', 'IN_PROGRESS')
        ) AND NOT EXISTS (
            SELECT 1
            FROM rentals r
            WHERE r.vehicle_id = OLD.vehicle_id
              AND r.status IN ('PENDING', 'ACTIVE')
        ) THEN
            UPDATE vehicles
            SET status = 'AVAILABLE'
            WHERE id = OLD.vehicle_id;
        END IF;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 11: Update customer rental count after insert
-- The Customers page uses total_rentals, so this trigger keeps it updated
-- whenever a new rental is created.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_customer_total_rentals_after_insert$$
CREATE TRIGGER trg_customer_total_rentals_after_insert
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_rentals = (
        SELECT COUNT(*)
        FROM rentals
        WHERE user_id = NEW.user_id
    )
    WHERE id = NEW.user_id;
END$$

-- ------------------------------------------------------------
-- Trigger 12: Update customer rental count after update
-- If a rental is moved from one customer to another, both customer records
-- are recalculated so the Customers table remains accurate.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_customer_total_rentals_after_update$$
CREATE TRIGGER trg_customer_total_rentals_after_update
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_rentals = (
        SELECT COUNT(*)
        FROM rentals
        WHERE user_id = NEW.user_id
    )
    WHERE id = NEW.user_id;

    IF OLD.user_id <> NEW.user_id THEN
        UPDATE users
        SET total_rentals = (
            SELECT COUNT(*)
            FROM rentals
            WHERE user_id = OLD.user_id
        )
        WHERE id = OLD.user_id;
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 13: Update customer rental count after delete
-- If a rental is deleted directly from the database, the related customer's
-- total_rentals value is recalculated automatically.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_customer_total_rentals_after_delete$$
CREATE TRIGGER trg_customer_total_rentals_after_delete
AFTER DELETE ON rentals
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_rentals = (
        SELECT COUNT(*)
        FROM rentals
        WHERE user_id = OLD.user_id
    )
    WHERE id = OLD.user_id;
END$$

DELIMITER ;

-- ============================================================
-- TRIGGER CHECK QUERIES
-- These optional checks help verify the trigger-related UI effects.
-- ============================================================

-- SELECT id, full_name, total_rentals FROM users ORDER BY id;
-- SELECT id, brand, model, plate, status FROM vehicles ORDER BY id;
-- SELECT id, user_id, vehicle_id, start_date, end_date, total_amount, status FROM rentals ORDER BY id;
