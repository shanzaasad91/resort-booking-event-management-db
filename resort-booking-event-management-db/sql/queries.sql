-- ============================================
-- Sample Analytical Queries
-- Run these after executing schema.sql
-- ============================================

-- 1. All confirmed bookings with customer info
SELECT b.booking_id, c.first_name || ' ' || c.last_name AS customer_name,
       b.start_date, b.end_date, b.total_amount, b.booking_status
FROM Booking b
JOIN Customer c ON b.customer_id = c.customer_id
WHERE b.booking_status = 'Confirmed'
ORDER BY b.start_date;

-- 2. Total revenue by payment method
SELECT payment_method, SUM(amount_paid) AS total_revenue
FROM Payment
WHERE payment_status IN ('Paid', 'Completed')
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 3. Room occupancy count
SELECT r.room_type, COUNT(b.booking_id) AS times_booked
FROM Room r
LEFT JOIN Booking b ON r.room_id = b.room_id
GROUP BY r.room_type
ORDER BY times_booked DESC;

-- 4. Customers with pending payments
SELECT customer_name, booking_id, total_amount, paid_amount, balance_due
FROM vw_booking_summary
WHERE payment_status = 'Partial Paid';

-- 5. Average rating per event
SELECT e.event_name, ROUND(AVG(f.rating), 2) AS avg_rating, 
       COUNT(f.feedback_id) AS reviews
FROM Event e 
JOIN Feedback f ON e.event_id = f.event_id
GROUP BY e.event_name 
ORDER BY avg_rating DESC;

-- 6. Event staffing overview
SELECT * FROM vw_event_staffing;

-- 7. Revenue report
SELECT * FROM vw_revenue_report;

-- 8. Staff with roles and salaries
SELECT s.first_name || ' ' || s.last_name AS staff_name, 
       r.role_name, s.salary
FROM Staff s 
JOIN Role r ON s.role_name = r.role_name
ORDER BY s.salary DESC;

-- 9. Customers by income range
SELECT income_range, COUNT(*) AS customer_count
FROM Customer 
GROUP BY income_range 
ORDER BY customer_count DESC;

-- 10. Top 5 highest-paying customers
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       SUM(p.amount_paid) AS total_paid
FROM Customer c
JOIN Booking b ON c.customer_id = b.customer_id
JOIN Payment p ON b.booking_id = p.booking_id
WHERE p.payment_status IN ('Paid', 'Completed')
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_paid DESC 
LIMIT 5;