# OceanView Resort Management System

A web-based hotel management system built with Java Servlets, JSP, and MySQL.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Default Login](#default-login)
- [API Endpoints](#api-endpoints)
- [Running Tests](#running-tests)
- [Test Coverage Summary](#test-coverage-summary)

---

## Overview

OceanView Resort is a full-stack hotel management web application that allows an admin to manage rooms, guests, reservations, and receptionist accounts. Receptionists have limited access to handle guest check-ins and reservations.

---

## Features

- **Authentication** — Secure login/logout with BCrypt password hashing and session management
- **Room Management** — Add, edit, delete, and view rooms with availability tracking
- **Guest Management** — Register, update, and delete guest profiles
- **Reservation Management** — Create, update, and cancel reservations with automatic room status sync
- **Receptionist Management** — Admin can add, edit, and remove receptionist accounts
- **Role-based Access Control** — Admin has full access; receptionists have restricted write access
- **REST JSON API** — All data operations use JSON responses

---

## Tech Stack

| Layer       | Technology                          |
|-------------|-------------------------------------|
| Language    | Java 21                             |
| Web         | Jakarta Servlet API 6.1, JSP        |
| Server      | Apache Tomcat 8.5.96                |
| Database    | MySQL 8 (via XAMPP)                 |
| JSON        | Google Gson 2.10.1                  |
| Security    | jBCrypt 0.4                         |
| Build       | Apache Maven                        |
| Testing     | JUnit Jupiter 5.13.2, Mockito 5.11.0|

---

## Project Structure

```
OceanViewResort/
├── src/
│   ├── main/
│   │   ├── java/com/example/oceanviewresort/
│   │   │   ├── controller/          # Servlet controllers (REST API)
│   │   │   │   ├── LoginServlet.java
│   │   │   │   ├── LogoutServlet.java
│   │   │   │   ├── RoomServlet.java
│   │   │   │   ├── GuestServlet.java
│   │   │   │   ├── ReservationServlet.java
│   │   │   │   └── ReceptionistServlet.java
│   │   │   ├── dao/                 # Data Access Objects
│   │   │   │   ├── UserDAO.java
│   │   │   │   ├── RoomDAO.java
│   │   │   │   ├── GuestDAO.java
│   │   │   │   └── ReservationDAO.java
│   │   │   ├── model/               # Plain Java models
│   │   │   │   ├── User.java
│   │   │   │   ├── Room.java
│   │   │   │   ├── Guest.java
│   │   │   │   └── Reservation.java
│   │   │   ├── service/
│   │   │   │   └── AuthService.java # Login authentication logic
│   │   │   └── util/
│   │   │       └── DBConnection.java # Singleton DB connection
│   │   ├── resources/
│   │   │   └── db.properties        # Database configuration
│   │   └── webapp/
│   │       ├── index.jsp            # Redirects to login
│   │       ├── views/
│   │       │   ├── login.jsp
│   │       │   ├── dashboard.jsp        # Admin dashboard
│   │       │   └── receptionist-dashboard.jsp
│   │       └── WEB-INF/
│   │           └── web.xml
│   └── test/
│       └── java/com/example/oceanviewresort/
│           ├── controller/          # Servlet unit tests
│           ├── dao/                 # DAO unit tests (Mockito + MockedStatic)
│           ├── model/               # Model unit tests
│           └── service/             # AuthService unit tests
├── pom.xml
└── README.md
```

---

## Prerequisites

- **Java 21** or later
- **Apache Maven 3.8+**
- **Apache Tomcat 8.5.96** (or compatible)
- **XAMPP** (MySQL server)

---

## Database Setup

1. Start XAMPP and ensure MySQL is running.
2. Open phpMyAdmin at `http://localhost/phpmyadmin` or use any MySQL client.
3. Create the database and tables:

```sql
CREATE DATABASE IF NOT EXISTS oceanviewresort_db;
USE oceanviewresort_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(20) NOT NULL DEFAULT 'receptionist',
    active TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    type VARCHAR(50),
    price_per_night DOUBLE,
    capacity INT,
    status VARCHAR(20) DEFAULT 'available',
    description TEXT
);

CREATE TABLE guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    id_type VARCHAR(50),
    id_number VARCHAR(50)
);

CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'confirmed',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);
```

4. Create the default admin user (password: `admin123`):

```sql
INSERT INTO users (username, password, full_name, role, active)
VALUES ('admin',
        '$2a$10$yourBcryptHashHere',
        'Administrator', 'admin', 1);
```

> To generate the correct BCrypt hash, run the application once and use the `/api/login` endpoint, or use an online BCrypt generator with cost factor 10.

---

## Running the Application

### Build the WAR

```bash
mvn clean package
```

### Deploy to Tomcat

Copy the generated WAR file to Tomcat's `webapps/` directory:

```
target/OceanViewResort-1.0-SNAPSHOT.war  →  <tomcat>/webapps/
```

Then start Tomcat:

```bash
# Windows
<tomcat>/bin/startup.bat
```

### Access the Application

```
http://localhost:8080/OceanViewResort-1.0-SNAPSHOT/
```

---

## Default Login

| Role         | Username | Password  |
|--------------|----------|-----------|
| Admin        | admin    | admin123  |

---

## API Endpoints

All endpoints return `application/json`.

### Authentication
| Method | URL          | Description              | Access |
|--------|--------------|--------------------------|--------|
| POST   | /api/login   | Authenticate user        | Public |
| POST   | /api/logout  | Invalidate session       | Any    |

### Rooms
| Method | URL        | Description        | Access         |
|--------|------------|--------------------|----------------|
| GET    | /api/room  | List all rooms     | Logged in      |
| POST   | /api/room  | Add a room         | Admin only     |
| PUT    | /api/room  | Update a room      | Admin only     |
| DELETE | /api/room  | Delete a room      | Admin only     |

### Guests
| Method | URL         | Description        | Access                  |
|--------|-------------|--------------------|-------------------------|
| GET    | /api/guest  | List all guests    | Logged in               |
| POST   | /api/guest  | Register a guest   | Admin or Receptionist   |
| PUT    | /api/guest  | Update a guest     | Admin or Receptionist   |
| DELETE | /api/guest  | Delete a guest     | Admin or Receptionist   |

### Reservations
| Method | URL               | Description             | Access                |
|--------|-------------------|-------------------------|-----------------------|
| GET    | /api/reservation  | List all reservations   | Logged in             |
| POST   | /api/reservation  | Create a reservation    | Admin or Receptionist |
| PUT    | /api/reservation  | Update a reservation    | Admin or Receptionist |
| DELETE | /api/reservation  | Delete a reservation    | Admin only            |

### Receptionists
| Method | URL               | Description              | Access     |
|--------|-------------------|--------------------------|------------|
| GET    | /api/receptionist | List all receptionists   | Admin only |
| POST   | /api/receptionist | Add a receptionist       | Admin only |
| PUT    | /api/receptionist | Update a receptionist    | Admin only |
| DELETE | /api/receptionist | Delete a receptionist    | Admin only |

---

## Running Tests

```bash
mvn test
```

Expected output:

```
Tests run: 127, Failures: 0, Errors: 0, Skipped: 0
```

---

## Test Coverage Summary

| Package        | Test File                  | Tests |
|----------------|----------------------------|-------|
| service        | AuthServiceTest            | 13    |
| model          | UserTest                   | 4     |
| model          | RoomTest                   | 7     |
| model          | GuestTest                  | 5     |
| model          | ReservationTest            | 9     |
| dao            | UserDAOTest                | 11    |
| dao            | RoomDAOTest                | 9     |
| dao            | GuestDAOTest               | 9     |
| dao            | ReservationDAOTest         | 10    |
| controller     | LoginServletTest           | 3     |
| controller     | LogoutServletTest          | 3     |
| controller     | RoomServletTest            | 8     |
| controller     | GuestServletTest           | 6     |
| controller     | ReservationServletTest     | 7     |
| controller     | ReceptionistServletTest    | 7     |
| **Total**      |                            | **127** |

DAO tests use `MockedStatic<DBConnection>` to mock the database singleton without requiring a real database connection.
