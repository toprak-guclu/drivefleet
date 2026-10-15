# DriveFleet — Car Rental Database & Admin Panel

A MySQL-backed car rental management system built for the **Database Systems** course at Yaşar University (Software Engineering, 2026).
Most of the business logic lives in the database itself: views drive the reports and triggers enforce the rental rules.

## What's inside

| Part | Details |
|---|---|
| **Schema** | 11 tables — branches, users, categories, features, insurances, vehicles, vehicle categories/features, rentals, payments, maintenance records |
| **Views** | 18 reporting views (fleet summary, monthly revenue, insurance usage, maintenance dashboard, …) |
| **Triggers** | 13 triggers that enforce business rules (below) |
| **API** | Node.js + Express REST API (`server_admin.js`) using `mysql2` with parameterized queries |
| **Admin panel** | Single-page HTML dashboard (`car_rental_dashboard_admin.html`) for vehicles, customers, rentals, payments and maintenance, with filters and sorting (click any column header; the fleet page also has a "Sort by" menu for price, year, mileage and brand) |

### Business rules enforced by triggers

- **No double booking:** a vehicle cannot be rented twice for overlapping dates (on insert and update).
- **Automatic pricing:** the rental total is calculated from the vehicle's daily rate, the insurance price and the number of days.
- **Vehicle status sync:** vehicle status follows its rentals and maintenance records (e.g. maintenance moves a vehicle to `OUT_OF_SERVICE`; moving a rental to another car releases the old one).
- **Customer stats:** each customer's `total_rentals` is recalculated after a rental is added, changed or removed.

Trigger errors (e.g. double booking) and constraint errors (duplicate plate, invalid value) are returned to the dashboard as readable messages with proper HTTP status codes.

The API has no login, so it only listens on `localhost` and only accepts browser requests from the local dashboard.

## Running locally

**Windows, one click:** double-click `start_drivefleet.bat`. On the first run it asks for your MySQL user and password (saved to a local `.env`), offers to import the database if it does not exist yet, installs the npm packages, starts the API and opens the dashboard.

**Manual steps:**

Requirements: MySQL 8, Node.js 20.12 or newer.

1. Import the database: `mysql -u root -p < database/drivefleet.sql`
2. Copy `.env.example` to `.env` and fill in your MySQL password.
3. Install packages: `npm install`
4. Start: `node server_admin.js` (API on http://localhost:3000), then open `car_rental_dashboard_admin.html`.
   On Windows you can simply double-click `start_drivefleet.bat`.

## Docs

- [ER diagram](docs/er-diagram.pdf)
