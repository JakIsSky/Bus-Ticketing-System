-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: bus_database
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `booking_number` varchar(30) NOT NULL,
  `passenger_id` int NOT NULL,
  `schedule_id` int NOT NULL,
  `booking_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `seat_number` varchar(10) NOT NULL,
  `passenger_type` varchar(20) NOT NULL DEFAULT 'Regular',
  `fare` decimal(10,2) NOT NULL,
  `booking_status` varchar(20) NOT NULL DEFAULT 'Pending',
  `active_seat` varchar(10) GENERATED ALWAYS AS (if((`booking_status` = _utf8mb4'Cancelled'),NULL,`seat_number`)) STORED,
  `active_passenger` int GENERATED ALWAYS AS (if((`booking_status` = _utf8mb4'Cancelled'),NULL,`passenger_id`)) STORED,
  PRIMARY KEY (`booking_id`),
  UNIQUE KEY `booking_number` (`booking_number`),
  UNIQUE KEY `unique_schedule_seat` (`schedule_id`,`active_seat`),
  UNIQUE KEY `unique_schedule_passenger` (`schedule_id`,`active_passenger`),
  KEY `passenger_id` (`passenger_id`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`passenger_id`) REFERENCES `passengers` (`passenger_id`),
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`),
  CONSTRAINT `chk_book_fare` CHECK ((`fare` > 0)),
  CONSTRAINT `chk_book_status` CHECK ((`booking_status` in (_utf8mb4'Pending',_utf8mb4'Confirmed',_utf8mb4'Paid',_utf8mb4'Completed',_utf8mb4'Cancelled')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buses`
--

DROP TABLE IF EXISTS `buses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `buses` (
  `bus_id` int NOT NULL AUTO_INCREMENT,
  `bus_number` varchar(20) NOT NULL,
  `plate_number` varchar(20) NOT NULL,
  `bus_type` varchar(30) NOT NULL,
  `brand` varchar(50) NOT NULL,
  `model` varchar(50) NOT NULL,
  `seating_capacity` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Available',
  PRIMARY KEY (`bus_id`),
  UNIQUE KEY `bus_number` (`bus_number`),
  UNIQUE KEY `plate_number` (`plate_number`),
  CONSTRAINT `chk_bus_capacity` CHECK ((`seating_capacity` > 0)),
  CONSTRAINT `chk_bus_status` CHECK ((`status` in (_utf8mb4'Available',_utf8mb4'Assigned',_utf8mb4'In Transit',_utf8mb4'Maintenance',_utf8mb4'Inactive')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buses`
--

LOCK TABLES `buses` WRITE;
/*!40000 ALTER TABLE `buses` DISABLE KEYS */;
INSERT INTO `buses` VALUES (1,'BUS-001','ABC-1234','Air-conditioned','Isuzu','LV123',45,'Available'),(2,'BUS-002','XYZ-5678','Ordinary','Hino','RM2',50,'Available'),(3,'BUS-003','DEF-9012','Deluxe','Volvo','B8R',40,'Maintenance'),(4,'BUS-004','GHI-3456','Ordinary','Isuzu','Journey',45,'Available');
/*!40000 ALTER TABLE `buses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `passengers`
--

DROP TABLE IF EXISTS `passengers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `passengers` (
  `passenger_id` int NOT NULL AUTO_INCREMENT,
  `passenger_number` varchar(20) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `contact_number` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`passenger_id`),
  UNIQUE KEY `passenger_number` (`passenger_number`),
  CONSTRAINT `chk_pass_status` CHECK ((`status` in (_utf8mb4'Active',_utf8mb4'Inactive')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `passengers`
--

LOCK TABLES `passengers` WRITE;
/*!40000 ALTER TABLE `passengers` DISABLE KEYS */;
INSERT INTO `passengers` VALUES (1,'PSG-0001','Juan','Dela Cruz','09171234567','juan@example.com','Solano, Nueva Vizcaya','Active'),(2,'PSG-0002','Maria','Santos','09181234567','maria@example.com','Bayombong, Nueva Vizcaya','Active');
/*!40000 ALTER TABLE `passengers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `payment_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `amount_due` decimal(10,2) NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `change_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_method` varchar(30) NOT NULL,
  `payment_status` varchar(20) NOT NULL DEFAULT 'Paid',
  PRIMARY KEY (`payment_id`),
  KEY `booking_id` (`booking_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  CONSTRAINT `chk_pay_amounts` CHECK (((`amount_paid` > 0) and (`amount_due` > 0) and (`change_amount` >= 0))),
  CONSTRAINT `chk_pay_status` CHECK ((`payment_status` in (_utf8mb4'Paid',_utf8mb4'Refunded')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `routes` (
  `route_id` int NOT NULL AUTO_INCREMENT,
  `route_code` varchar(20) NOT NULL,
  `origin` varchar(100) NOT NULL,
  `destination` varchar(100) NOT NULL,
  `distance` decimal(10,2) DEFAULT NULL,
  `estimated_duration` varchar(50) DEFAULT NULL,
  `fare` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`route_id`),
  UNIQUE KEY `route_code` (`route_code`),
  CONSTRAINT `chk_route_fare` CHECK ((`fare` > 0)),
  CONSTRAINT `chk_route_places` CHECK ((`origin` <> `destination`)),
  CONSTRAINT `chk_route_status` CHECK ((`status` in (_utf8mb4'Active',_utf8mb4'Inactive')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (1,'R001','Bayombong','Tuguegarao',150.00,'4 hours',250.00,'Active'),(2,'R002','Bayombong','Santiago',90.00,'2 hours 30 min',150.00,'Active'),(3,'R003','Bagabag','Solano',12.00,'30 min',80.00,'Active'),(4,'R004','Solano','Bayombong',10.00,'30 min',50.00,'Active');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `bus_id` int NOT NULL,
  `route_id` int NOT NULL,
  `departure_date` date NOT NULL,
  `departure_time` time NOT NULL,
  `arrival_time` time NOT NULL,
  `available_seats` int NOT NULL,
  `schedule_status` varchar(20) NOT NULL DEFAULT 'Scheduled',
  PRIMARY KEY (`schedule_id`),
  KEY `route_id` (`route_id`),
  KEY `idx_sched_bus_date` (`bus_id`,`departure_date`),
  CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`),
  CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`),
  CONSTRAINT `chk_sched_seats` CHECK ((`available_seats` >= 0)),
  CONSTRAINT `chk_sched_status` CHECK ((`schedule_status` in (_utf8mb4'Scheduled',_utf8mb4'Ongoing',_utf8mb4'Completed',_utf8mb4'Cancelled'))),
  CONSTRAINT `chk_sched_times` CHECK ((`arrival_time` > `departure_time`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
INSERT INTO `schedules` VALUES (1,1,1,'2026-10-16','08:00:00','12:00:00',45,'Scheduled'),(2,2,4,'2026-10-16','09:30:00','10:00:00',50,'Scheduled'),(3,4,2,'2026-10-17','13:00:00','15:30:00',45,'Scheduled');
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `ticket_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `ticket_number` varchar(30) NOT NULL,
  `issue_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `seat_number` varchar(10) NOT NULL,
  `ticket_status` varchar(20) NOT NULL DEFAULT 'Valid',
  `boarded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`ticket_id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  UNIQUE KEY `ticket_number` (`ticket_number`),
  CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
  CONSTRAINT `chk_ticket_status` CHECK ((`ticket_status` in (_utf8mb4'Valid',_utf8mb4'Used',_utf8mb4'Cancelled',_utf8mb4'Expired')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(30) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  CONSTRAINT `chk_user_role` CHECK ((`role` in (_utf8mb4'Administrator',_utf8mb4'Transportation Manager',_utf8mb4'Booking Staff',_utf8mb4'Cashier',_utf8mb4'Dispatcher',_utf8mb4'Management'))),
  CONSTRAINT `chk_user_status` CHECK ((`status` in (_utf8mb4'Active',_utf8mb4'Inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-15 16:48:23
