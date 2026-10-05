    Resort Booking & Event Management Database
    PostgreSQL 16 Schema + Sample Data
    Run this file first to set up the database
-- ============================================================
-- RESORT BOOKING & EVENT MANAGEMENT DATABASE
-- PostgreSQL Implementation with Advanced Features
-- ============================================================
-- Includes: Schema, Sample Data, Views, Functions, Triggers,
--           Stored Procedures, Indexes, and Analytical Queries
-- ============================================================

-- ============================================================
-- SECTION 1: CLEANUP (Drop existing objects in reverse order)
-- ============================================================

DROP TRIGGER IF EXISTS trg_check_booking_dates ON Booking;
DROP TRIGGER IF EXISTS trg_validate_event_hours ON Event;
DROP TRIGGER IF EXISTS trg_prevent_double_booking ON Booking;
DROP TRIGGER IF EXISTS trg_auto_update_room_status ON Booking;

DROP FUNCTION IF EXISTS check_booking_dates() CASCADE;
DROP FUNCTION IF EXISTS validate_event_hours() CASCADE;
DROP FUNCTION IF EXISTS prevent_double_booking() CASCADE;
DROP FUNCTION IF EXISTS auto_update_room_status() CASCADE;
DROP FUNCTION IF EXISTS calculate_refund(INT) CASCADE;

DROP PROCEDURE IF EXISTS make_booking(INT, INT, DATE, DATE, DECIMAL) CASCADE;
DROP PROCEDURE IF EXISTS cancel_booking(INT, VARCHAR) CASCADE;

DROP VIEW IF EXISTS vw_booking_summary CASCADE;
DROP VIEW IF EXISTS vw_event_staffing CASCADE;
DROP VIEW IF EXISTS vw_revenue_report CASCADE;

DROP TABLE IF EXISTS Feedback CASCADE;
DROP TABLE IF EXISTS Outdoor_Service CASCADE;
DROP TABLE IF EXISTS Event_Staff CASCADE;
DROP TABLE IF EXISTS Cancellation CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Event CASCADE;
DROP TABLE IF EXISTS Weather CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Role CASCADE;
DROP TABLE IF EXISTS Room CASCADE;
DROP TABLE IF EXISTS Rate CASCADE;
DROP TABLE IF EXISTS Car CASCADE;
DROP TABLE IF EXISTS Income_Range CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Payment_Status CASCADE;
DROP TABLE IF EXISTS Booking_Status CASCADE;

-- ============================================================
-- SECTION 2: LOOKUP TABLES
-- ============================================================

CREATE TABLE Payment_Status (
    payment_status VARCHAR(20) PRIMARY KEY,
    account_balance_effect VARCHAR(20) NOT NULL
);

INSERT INTO Payment_Status VALUES
('Paid', 'Increase'),
('Pending', 'None'),
('Refunded', 'Decrease'),
('Failed', 'None'),
('Cancelled', 'None'),
('Partial Paid', 'Increase'),
('Partial Refund', 'Decrease'),
('Completed', 'Increase');

CREATE TABLE Booking_Status (
    booking_status VARCHAR(20) PRIMARY KEY,
    associated_email_flag VARCHAR(50) NOT NULL
);

INSERT INTO Booking_Status VALUES
('Confirmed', 'Send Confirmation'),
('Pending', 'None'),
('Cancelled', 'Send Cancellation'),
('Completed', 'Send Receipt'),
('Checked-In', 'None'),
('Checked-Out', 'Send Feedback'),
('No-Show', 'None');

CREATE TABLE Income_Range (
    income_label VARCHAR(30) PRIMARY KEY,
    description VARCHAR(100)
);

INSERT INTO Income_Range VALUES
('Below 50k', 'Low income bracket'),
('50k-100k', 'Middle income bracket'),
('100k-200k', 'Upper middle income'),
('200k-500k', 'High income bracket'),
('Above 500k', 'Premium income bracket');

CREATE TABLE Role (
    role_name VARCHAR(50) PRIMARY KEY,
    description VARCHAR(200)
);

INSERT INTO Role VALUES
('Manager', 'Oversees resort operations'),
('Receptionist', 'Handles bookings and check-ins'),
('Chef', 'Manages kitchen and catering'),
('Housekeeping', 'Maintains room cleanliness'),
('Event Coordinator', 'Plans and manages events'),
('Security', 'Ensures safety and security'),
('Driver', 'Handles car rentals and transport'),
('Accountant', 'Manages payments and refunds');

-- ============================================================
-- SECTION 3: MAIN ENTITIES
-- ============================================================

CREATE TABLE Car (
    car_id SERIAL PRIMARY KEY,
    car_type VARCHAR(20) CHECK (car_type IN ('Economy', 'Standard', 'Luxury')),
    registration_no VARCHAR(20) UNIQUE,
    status VARCHAR(20) DEFAULT 'Available' 
        CHECK (status IN ('Available', 'Rented', 'Maintenance')),
    rental_charges DECIMAL(10,2)
);

INSERT INTO Car (car_type, registration_no, status, rental_charges) VALUES
('Economy', 'ABC-123', 'Available', 3000),
('Standard', 'DEF-456', 'Available', 5000),
('Luxury', 'GHI-789', 'Available', 12000),
('Economy', 'JKL-012', 'Rented', 3000),
('Standard', 'MNO-345', 'Available', 5000),
('Luxury', 'PQR-678', 'Available', 12000),
('Economy', 'STU-901', 'Available', 3000),
('Standard', 'VWX-234', 'Rented', 5000),
('Luxury', 'YZA-567', 'Available', 12000),
('Economy', 'BCD-890', 'Available', 3000);

CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(200),
    date_of_birth DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    nationality VARCHAR(50),
    income_range VARCHAR(30),
    car_id INT,
    FOREIGN KEY (income_range) REFERENCES Income_Range(income_label),
    FOREIGN KEY (car_id) REFERENCES Car(car_id)
);

INSERT INTO Customer (first_name, last_name, email, phone, address, date_of_birth, gender, nationality, income_range) VALUES
('Ali', 'Khan', 'ali@email.com', '0301-1234567', 'House 1, Street 2, Islamabad', '1990-05-15', 'M', 'Pakistani', '50k-100k'),
('Sara', 'Ahmed', 'sara@email.com', '0302-2345678', 'House 3, Street 4, Lahore', '1992-08-20', 'F', 'Pakistani', '100k-200k'),
('Ahmed', 'Raza', 'ahmed@email.com', '0303-3456789', 'House 5, Street 6, Karachi', '1988-03-10', 'M', 'Pakistani', '200k-500k'),
('Ayesha', 'Malik', 'ayesha@email.com', '0304-4567890', 'House 7, Street 8, Rawalpindi', '1995-11-25', 'F', 'Pakistani', '50k-100k'),
('Usman', 'Tariq', 'usman@email.com', '0305-5678901', 'House 9, Street 10, Peshawar', '1985-07-05', 'M', 'Pakistani', 'Above 500k'),
('Hina', 'Shah', 'hina@email.com', '0306-6789012', 'House 11, Street 12, Multan', '1993-02-14', 'F', 'Pakistani', '100k-200k'),
('Bilal', 'Hussain', 'bilal@email.com', '0307-7890123', 'House 13, Street 14, Quetta', '1991-09-30', 'M', 'Pakistani', '50k-100k'),
('Zara', 'Sheikh', 'zara@email.com', '0308-8901234', 'House 15, Street 16, Faisalabad', '1994-12-12', 'F', 'Pakistani', '100k-200k'),
('Hamza', 'Iqbal', 'hamza@email.com', '0309-9012345', 'House 17, Street 18, Sialkot', '1989-06-18', 'M', 'Pakistani', '200k-500k'),
('Iqra', 'Nawaz', 'iqra@email.com', '0310-0123456', 'House 19, Street 20, Hyderabad', '1996-04-22', 'F', 'Pakistani', 'Below 50k');

CREATE TABLE Rate (
    rate_id SERIAL PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    day_type VARCHAR(20) CHECK (day_type IN ('Weekday', 'Weekend', 'Holiday')),
    effective_date DATE DEFAULT CURRENT_DATE,
    valid_date DATE
);

INSERT INTO Rate (amount, day_type, valid_date) VALUES
(5000, 'Weekday', '2025-12-31'),
(7000, 'Weekend', '2025-12-31'),
(9000, 'Holiday', '2025-12-31'),
(8000, 'Weekday', '2025-12-31'),
(10000, 'Weekend', '2025-12-31'),
(12000, 'Holiday', '2025-12-31'),
(15000, 'Weekday', '2025-12-31'),
(18000, 'Weekend', '2025-12-31'),
(22000, 'Holiday', '2025-12-31'),
(3500, 'Weekday', '2025-12-31');

CREATE TABLE Room (
    room_id SERIAL PRIMARY KEY,
    room_type VARCHAR(30) NOT NULL,
    room_capacity INT NOT NULL CHECK (room_capacity > 0),
    availability_status VARCHAR(20) DEFAULT 'Available',
    base_price DECIMAL(10,2),
    rate_id INT,
    FOREIGN KEY (rate_id) REFERENCES Rate(rate_id)
);

INSERT INTO Room (room_type, room_capacity, availability_status, base_price, rate_id) VALUES
('Single', 1, 'Available', 5000, 1),
('Double', 2, 'Available', 8000, 2),
('Suite', 4, 'Available', 15000, 3),
('Deluxe', 3, 'Available', 12000, 4),
('Executive', 2, 'Available', 10000, 5),
('Family', 5, 'Available', 18000, 6),
('Presidential', 6, 'Available', 35000, 7),
('Economy', 1, 'Available', 3500, 8),
('Luxury', 4, 'Available', 25000, 9),
('Penthouse', 4, 'Available', 40000, 10);

CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10,2),
    role_name VARCHAR(50),
    FOREIGN KEY (role_name) REFERENCES Role(role_name)
);

INSERT INTO Staff (first_name, last_name, email, phone, hire_date, salary, role_name) VALUES
('Imran', 'Khan', 'imran@resort.com', '0321-1111111', '2020-01-15', 150000, 'Manager'),
('Fatima', 'Ali', 'fatima@resort.com', '0322-2222222', '2021-03-20', 60000, 'Receptionist'),
('Bilal', 'Chef', 'bilal.chef@resort.com', '0323-3333333', '2019-06-10', 90000, 'Chef'),
('Ayesha', 'Clean', 'ayesha.clean@resort.com', '0324-4444444', '2022-02-05', 35000, 'Housekeeping'),
('Omar', 'Event', 'omar.event@resort.com', '0325-5555555', '2020-09-12', 80000, 'Event Coordinator'),
('Sana', 'Secure', 'sana.secure@resort.com', '0326-6666666', '2021-11-01', 45000, 'Security'),
('Tariq', 'Drive', 'tariq.drive@resort.com', '0327-7777777', '2018-04-18', 40000, 'Driver'),
('Nadia', 'Account', 'nadia.account@resort.com', '0328-8888888', '2019-08-25', 100000, 'Accountant'),
('Kamran', 'Front', 'kamran@resort.com', '0329-9999999', '2022-05-30', 55000, 'Receptionist'),
('Sadia', 'Cook', 'sadia.cook@resort.com', '0330-0000000', '2021-07-14', 50000, 'Chef');

CREATE TABLE Weather (
    weather_id SERIAL PRIMARY KEY,
    condition VARCHAR(50),
    temperature DECIMAL(5,2),
    stability VARCHAR(20)
);

INSERT INTO Weather (condition, temperature, stability) VALUES
('Sunny', 28.5, 'Stable'),
('Cloudy', 22.0, 'Stable'),
('Rainy', 18.5, 'Unstable'),
('Windy', 20.0, 'Moderate'),
('Stormy', 15.0, 'Unstable'),
('Clear', 30.0, 'Stable'),
('Overcast', 19.5, 'Stable'),
('Foggy', 12.0, 'Moderate'),
('Humid', 32.0, 'Moderate'),
('Pleasant', 25.0, 'Stable');

CREATE TABLE Event (
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATE,
    start_time TIME,
    end_time TIME,
    weather_id INT,
    FOREIGN KEY (weather_id) REFERENCES Weather(weather_id)
);

INSERT INTO Event (event_name, event_date, start_time, end_time, weather_id) VALUES
('Wedding', '2025-12-01', '14:00:00', '22:00:00', 1),
('Conference', '2025-12-02', '09:00:00', '17:00:00', 2),
('Concert', '2025-12-03', '19:00:00', '22:00:00', 6),
('Corporate Meeting', '2025-12-04', '10:00:00', '16:00:00', 7),
('Birthday Party', '2025-12-05', '15:00:00', '21:00:00', 1),
('Seminar', '2025-12-06', '09:00:00', '15:00:00', 2),
('Exhibition', '2025-12-07', '11:00:00', '20:00:00', 10),
('Workshop', '2025-12-08', '10:00:00', '18:00:00', 5),
('Dinner Gala', '2025-12-09', '19:00:00', '22:00:00', 6),
('Product Launch', '2025-12-10', '11:00:00', '19:00:00', 1);

CREATE TABLE Event_Staff (
    event_id INT,
    staff_id INT,
    PRIMARY KEY (event_id, staff_id),
    FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE CASCADE
);

INSERT INTO Event_Staff VALUES
(1, 1), (1, 5), (1, 6),
(2, 2), (2, 5),
(3, 1), (3, 5), (3, 6), (3, 7),
(4, 2), (4, 5),
(5, 1), (5, 5),
(6, 2), (6, 5),
(7, 1), (7, 5),
(8, 5), (8, 6),
(9, 1), (9, 3), (9, 5),
(10, 2), (10, 5);

CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    room_id INT,
    booking_date DATE DEFAULT CURRENT_DATE,
    booking_time TIME DEFAULT CURRENT_TIME,
    num_adults INT DEFAULT 1,
    num_children INT DEFAULT 0,
    total_amount DECIMAL(10,2),
    booking_status VARCHAR(20),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    FOREIGN KEY (booking_status) REFERENCES Booking_Status(booking_status),
    CHECK (end_date > start_date)
);

INSERT INTO Booking (customer_id, room_id, num_adults, num_children, total_amount, booking_status, start_date, end_date) VALUES
(1, 1, 2, 0, 15000, 'Confirmed', '2025-12-01', '2025-12-04'),
(2, 2, 2, 1, 24000, 'Pending', '2025-12-02', '2025-12-05'),
(3, 3, 2, 2, 45000, 'Confirmed', '2025-12-03', '2025-12-06'),
(4, 4, 1, 0, 12000, 'Cancelled', '2025-12-04', '2025-12-06'),
(5, 5, 2, 0, 20000, 'Confirmed', '2025-12-05', '2025-12-08'),
(6, 6, 2, 3, 54000, 'Confirmed', '2025-12-06', '2025-12-09'),
(7, 7, 2, 0, 70000, 'Pending', '2025-12-07', '2025-12-10'),
(8, 8, 1, 0, 7000, 'Confirmed', '2025-12-08', '2025-12-10'),
(9, 9, 2, 2, 75000, 'Confirmed', '2025-12-09', '2025-12-12'),
(10, 10, 2, 0, 80000, 'Confirmed', '2025-12-10', '2025-12-13');

CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL,
    amount_paid DECIMAL(10,2),
    payment_method VARCHAR(20) CHECK (payment_method IN ('Cash', 'Card', 'Bank Transfer', 'Online')),
    payment_status VARCHAR(20),
    payment_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (payment_status) REFERENCES Payment_Status(payment_status)
);

INSERT INTO Payment (booking_id, amount_paid, payment_method, payment_status) VALUES
(1, 15000, 'Card', 'Paid'),
(2, 5000, 'Cash', 'Partial Paid'),
(3, 45000, 'Bank Transfer', 'Paid'),
(4, 12000, 'Card', 'Refunded'),
(5, 20000, 'Online', 'Paid'),
(6, 54000, 'Card', 'Paid'),
(7, 10000, 'Cash', 'Partial Paid'),
(8, 7000, 'Online', 'Paid'),
(9, 75000, 'Card', 'Paid'),
(10, 80000, 'Bank Transfer', 'Paid');

CREATE TABLE Cancellation (
    cancellation_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL,
    cancellation_date DATE DEFAULT CURRENT_DATE,
    reason VARCHAR(200),
    refund_amount DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

INSERT INTO Cancellation (booking_id, reason, refund_amount) VALUES
(4, 'Change of plans', 9600.00);

CREATE TABLE Outdoor_Service (
    service_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL,
    service_name VARCHAR(100),
    description VARCHAR(300),
    FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE
);

INSERT INTO Outdoor_Service (event_id, service_name, description) VALUES
(1, 'Fireworks', 'Evening fireworks display'),
(1, 'Boating', 'Lake boating for guests'),
(3, 'Stage Lighting', 'Outdoor concert lighting'),
(5, 'Outdoor Catering', 'BBQ and live cooking'),
(7, 'Outdoor Exhibit', 'Open-air exhibition setup');

CREATE TABLE Feedback (
    feedback_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    event_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments VARCHAR(500),
    feedback_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (event_id) REFERENCES Event(event_id)
);

INSERT INTO Feedback (customer_id, event_id, rating, comments) VALUES
(1, 1, 5, 'Amazing wedding setup!'),
(2, 2, 4, 'Good conference facilities'),
(3, 3, 5, 'Concert was fantastic'),
(4, 4, 3, 'Meeting room was okay'),
(5, 5, 5, 'Best birthday party ever'),
(6, 6, 4, 'Seminar was informative'),
(7, 7, 4, 'Nice exhibition'),
(8, 8, 3, 'Workshop could be better'),
(9, 9, 5, 'Gala dinner was excellent'),
(10, 10, 4, 'Product launch went well');

-- ============================================================
-- SECTION 4: INDEXES (Performance Optimization)
-- ============================================================

CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(booking_status);
CREATE INDEX idx_customer_email ON Customer(email);
CREATE INDEX idx_customer_income ON Customer(income_range);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_booking ON Payment(booking_id);
CREATE INDEX idx_event_date ON Event(event_date);
CREATE INDEX idx_room_type ON Room(room_type);
CREATE INDEX idx_staff_role ON Staff(role_name);

-- ============================================================
-- SECTION 5: VIEWS (Reusable Reports)
-- ============================================================

-- View 1: Complete booking summary
CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT 
    b.booking_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email AS customer_email,
    r.room_type,
    b.start_date,
    b.end_date,
    (b.end_date - b.start_date) AS nights,
    b.total_amount,
    COALESCE(p.amount_paid, 0) AS paid_amount,
    b.total_amount - COALESCE(p.amount_paid, 0) AS balance_due,
    b.booking_status,
    p.payment_status
FROM Booking b
JOIN Customer c ON b.customer_id = c.customer_id
LEFT JOIN Room r ON b.room_id = r.room_id
LEFT JOIN Payment p ON b.booking_id = p.booking_id;

-- View 2: Event staffing overview
CREATE OR REPLACE VIEW vw_event_staffing AS
SELECT 
    e.event_id,
    e.event_name,
    e.event_date,
    e.start_time,
    e.end_time,
    COUNT(es.staff_id) AS total_staff,
    STRING_AGG(s.first_name || ' ' || s.last_name, ', ') AS staff_names
FROM Event e
LEFT JOIN Event_Staff es ON e.event_id = es.event_id
LEFT JOIN Staff s ON es.staff_id = s.staff_id
GROUP BY e.event_id, e.event_name, e.event_date, e.start_time, e.end_time;

-- View 3: Revenue report by payment method
CREATE OR REPLACE VIEW vw_revenue_report AS
SELECT 
    p.payment_method,
    p.payment_status,
    COUNT(p.payment_id) AS transaction_count,
    SUM(p.amount_paid) AS total_amount
FROM Payment p
GROUP BY p.payment_method, p.payment_status
ORDER BY total_amount DESC;

-- ============================================================
-- SECTION 6: FUNCTIONS
-- ============================================================

-- Function 1: Calculate refund for a booking (80% if >72 hours before)
CREATE OR REPLACE FUNCTION calculate_refund(p_booking_id INT)
RETURNS DECIMAL AS $$
DECLARE
    v_start_date DATE;
    v_amount DECIMAL;
    v_days INT;
BEGIN
    SELECT start_date, total_amount 
    INTO v_start_date, v_amount
    FROM Booking 
    WHERE booking_id = p_booking_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking ID % not found', p_booking_id;
    END IF;
    
    v_days := v_start_date - CURRENT_DATE;
    
    IF v_days > 3 THEN
        RETURN ROUND(v_amount * 0.80, 2);
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Get total revenue for a date range
CREATE OR REPLACE FUNCTION get_revenue(p_start DATE, p_end DATE)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(amount_paid), 0)
    INTO v_total
    FROM Payment
    WHERE payment_date BETWEEN p_start AND p_end
      AND payment_status IN ('Paid', 'Completed');
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Function 3: Check if a room is available for given dates
CREATE OR REPLACE FUNCTION is_room_available(
    p_room_id INT, 
    p_start DATE, 
    p_end DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Booking
    WHERE room_id = p_room_id
      AND booking_status NOT IN ('Cancelled', 'No-Show')
      AND (p_start, p_end) OVERLAPS (start_date, end_date);
    
    RETURN v_count = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SECTION 7: TRIGGERS
-- ============================================================

-- Trigger 1: Validate booking dates (end > start)
CREATE OR REPLACE FUNCTION check_booking_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_date <= NEW.start_date THEN
        RAISE EXCEPTION 'End date must be after start date';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_booking_dates
BEFORE INSERT OR UPDATE ON Booking
FOR EACH ROW
EXECUTE FUNCTION check_booking_dates();

-- Trigger 2: Validate event hours (9 AM - 10 PM)
CREATE OR REPLACE FUNCTION validate_event_hours()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.start_time < '09:00:00' OR NEW.end_time > '22:00:00' THEN
        RAISE EXCEPTION 'Events must be between 9:00 AM and 10:00 PM';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_event_hours
BEFORE INSERT OR UPDATE ON Event
FOR EACH ROW
EXECUTE FUNCTION validate_event_hours();

-- Trigger 3: Prevent double booking
CREATE OR REPLACE FUNCTION prevent_double_booking()
RETURNS TRIGGER AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Booking
    WHERE room_id = NEW.room_id
      AND booking_id != COALESCE(NEW.booking_id, -1)
      AND booking_status NOT IN ('Cancelled', 'No-Show')
      AND (NEW.start_date, NEW.end_date) OVERLAPS (start_date, end_date);
    
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Room % is already booked for these dates', NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT OR UPDATE ON Booking
FOR EACH ROW
EXECUTE FUNCTION prevent_double_booking();

-- Trigger 4: Auto-update room status when booking changes
CREATE OR REPLACE FUNCTION auto_update_room_status()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.booking_status = 'Confirmed' THEN
        UPDATE Room SET availability_status = 'Booked'
        WHERE room_id = NEW.room_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.booking_status = 'Cancelled' THEN
        UPDATE Room SET availability_status = 'Available'
        WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_update_room_status
AFTER INSERT OR UPDATE ON Booking
FOR EACH ROW
EXECUTE FUNCTION auto_update_room_status();

-- ============================================================
-- SECTION 8: STORED PROCEDURES
-- ============================================================

-- Procedure 1: Make a new booking
CREATE OR REPLACE PROCEDURE make_booking(
    p_customer_id INT,
    p_room_id INT,
    p_start_date DATE,
    p_end_date DATE,
    p_amount DECIMAL
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT is_room_available(p_room_id, p_start_date, p_end_date) THEN
        RAISE EXCEPTION 'Room % is not available for the selected dates', p_room_id;
    END IF;
    
    INSERT INTO Booking (
        customer_id, room_id, start_date, end_date,
        total_amount, booking_status
    )
    VALUES (
        p_customer_id, p_room_id, p_start_date, p_end_date,
        p_amount, 'Pending'
    );
    
    RAISE NOTICE 'Booking created successfully for customer %', p_customer_id;
END;
$$;

-- Procedure 2: Cancel a booking with auto-refund
CREATE OR REPLACE PROCEDURE cancel_booking(
    p_booking_id INT,
    p_reason VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    v_refund DECIMAL;
BEGIN
    v_refund := calculate_refund(p_booking_id);
    
    UPDATE Booking 
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;
    
    INSERT INTO Cancellation (booking_id, reason, refund_amount)
    VALUES (p_booking_id, p_reason, v_refund);
    
    RAISE NOTICE 'Booking % cancelled. Refund: Rs. %', p_booking_id, v_refund;
END;
$$;

-- ============================================================
-- SECTION 9: SAMPLE ANALYTICAL QUERIES
-- ============================================================

-- Query 1: All confirmed bookings with customer info
-- SELECT * FROM vw_booking_summary WHERE booking_status = 'Confirmed';

-- Query 2: Total revenue by payment method
-- SELECT * FROM vw_revenue_report;

-- Query 3: Event staffing overview
-- SELECT * FROM vw_event_staffing;

-- Query 4: Customers with pending payments
-- SELECT customer_name, booking_id, total_amount, paid_amount, balance_due
-- FROM vw_booking_summary
-- WHERE payment_status = 'Partial Paid';

-- Query 5: Average rating per event
-- SELECT e.event_name, ROUND(AVG(f.rating), 2) AS avg_rating, COUNT(f.feedback_id) AS reviews
-- FROM Event e JOIN Feedback f ON e.event_id = f.event_id
-- GROUP BY e.event_name ORDER BY avg_rating DESC;

-- Query 6: Room occupancy count
-- SELECT r.room_type, COUNT(b.booking_id) AS times_booked
-- FROM Room r LEFT JOIN Booking b ON r.room_id = b.room_id
-- GROUP BY r.room_type ORDER BY times_booked DESC;

-- Query 7: Staff with roles and salaries
-- SELECT s.first_name || ' ' || s.last_name AS staff_name, r.role_name, s.salary
-- FROM Staff s JOIN Role r ON s.role_name = r.role_name
-- ORDER BY s.salary DESC;

-- Query 8: Refund eligibility check
-- SELECT b.booking_id, c.first_name, b.start_date,
--        (b.start_date - CURRENT_DATE) AS days_until_event,
--        CASE WHEN (b.start_date - CURRENT_DATE) > 3 
--             THEN 'Eligible for 80% refund' 
--             ELSE 'Not eligible' END AS refund_status
-- FROM Booking b JOIN Customer c ON b.customer_id = c.customer_id
-- WHERE b.booking_status = 'Cancelled';

-- Query 9: Customers by income range
-- SELECT income_range, COUNT(*) AS customer_count
-- FROM Customer GROUP BY income_range ORDER BY customer_count DESC;

-- Query 10: Top 5 highest-paying customers
-- SELECT c.first_name || ' ' || c.last_name AS customer_name,
--        SUM(p.amount_paid) AS total_paid
-- FROM Customer c
-- JOIN Booking b ON c.customer_id = b.customer_id
-- JOIN Payment p ON b.booking_id = p.booking_id
-- WHERE p.payment_status IN ('Paid', 'Completed')
-- GROUP BY c.customer_id, c.first_name, c.last_name
-- ORDER BY total_paid DESC LIMIT 5;

-- ============================================================
-- SECTION 10: TEST THE ADVANCED FEATURES
-- ============================================================

-- Test 1: View the booking summary
SELECT * FROM vw_booking_summary;

-- Test 2: Calculate refund for booking 4
SELECT calculate_refund(4) AS refund_for_booking_4;

-- Test 3: Check room availability
SELECT is_room_available(1, '2025-12-01', '2025-12-04') AS room_1_available;

-- Test 4: Revenue report
SELECT * FROM vw_revenue_report;

-- Test 5: Make a new booking via procedure
-- CALL make_booking(1, 5, '2025-12-20', '2025-12-25', 50000);

-- Test 6: Cancel a booking via procedure
-- CALL cancel_booking(7, 'Customer request');

-- Test 7: View event staffing
SELECT * FROM vw_event_staffing;

COMMIT;

-- ============================================================
-- ✅ END OF SCRIPT
-- ============================================================