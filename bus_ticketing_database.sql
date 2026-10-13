CREATE DATABASE bus_database; 
USE bus_database;

CREATE TABLE buses (
    bus_id SERIAL PRIMARY KEY,
    bus_number VARCHAR(20) UNIQUE,
    plate_number VARCHAR(20) UNIQUE,
    bus_type VARCHAR(30),
    brand VARCHAR(50),
    model VARCHAR(50),
    seating_capacity INT,
    status VARCHAR(20)
);

CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_code VARCHAR(20) UNIQUE,
    origin VARCHAR(100),
    destination VARCHAR(100),
    distance DECIMAL(10,2),
    estimated_duration VARCHAR(50),
    fare DECIMAL(10,2),
    status VARCHAR(20)
);

CREATE TABLE schedules (
    schedule_id SERIAL PRIMARY KEY,
    bus_id INT REFERENCES buses(bus_id),
    route_id INT REFERENCES routes(route_id),
    departure_date DATE,
    departure_time TIME,
    arrival_time TIME,
    available_seats INT,
    schedule_status VARCHAR(20)
);

CREATE TABLE passengers (
    passenger_id SERIAL PRIMARY KEY,
    passenger_number VARCHAR(20) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    contact_number VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255),
    status VARCHAR(20)
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    booking_number VARCHAR(30) UNIQUE,
    passenger_id INT REFERENCES passengers(passenger_id),
    schedule_id INT REFERENCES schedules(schedule_id),
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    seat_number VARCHAR(10),
    fare DECIMAL(10,2),
    booking_status VARCHAR(20)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount_due DECIMAL(10,2),
    amount_paid DECIMAL(10,2),
    change_amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20)
);

CREATE TABLE tickets (
    ticket_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id),
    ticket_number VARCHAR(30) UNIQUE,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    seat_number VARCHAR(10),
    ticket_status VARCHAR(20)
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(30),
    status VARCHAR(20)
);

ALTER TABLE bookings
ADD CONSTRAINT unique_schedule_seat
UNIQUE (schedule_id, seat_number);