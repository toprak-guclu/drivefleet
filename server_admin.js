const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const fs = require('fs');
const path = require('path');

// Load settings from a local .env file if present (Node 20.12+). The .env file is never committed.
const envFile = path.join(__dirname, '.env');
if (fs.existsSync(envFile)) process.loadEnvFile(envFile);

const app = express();

// The dashboard is opened as a local file (origin "null") or from localhost.
// Other websites must not be able to call this admin API from the browser.
app.use(cors({
  origin(origin, callback) {
    const allowed = !origin || origin === 'null' || /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
    callback(null, allowed);
  }
}));
app.use(express.json());

// Connection settings come from environment variables (see .env.example).
const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'drivefleet',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

async function query(sql, params = []) {
  const [rows] = await db.query(sql, params);
  return rows;
}

function asyncRoute(handler) {
  return (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);
}

function requireFields(body, fields) {
  for (const f of fields) {
    if (body[f] === undefined || body[f] === null || String(body[f]).trim() === '') {
      const err = new Error(`${f} is required`);
      err.status = 400;
      throw err;
    }
  }
}

function parseId(value) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) {
    const err = new Error('Invalid id');
    err.status = 400;
    throw err;
  }
  return id;
}

function normalizeIdArray(value) {
  if (!Array.isArray(value)) return [];
  return [...new Set(value.map(Number).filter(Number.isFinite))];
}

async function replaceVehicleRelations(conn, vehicleId, categoryIds = [], featureIds = []) {
  await conn.query('DELETE FROM vehicle_categories WHERE vehicle_id = ?', [vehicleId]);
  await conn.query('DELETE FROM vehicle_features WHERE vehicle_id = ?', [vehicleId]);

  if (categoryIds.length) {
    await conn.query(
      'INSERT INTO vehicle_categories (vehicle_id, category_id) VALUES ?',
      [categoryIds.map(id => [vehicleId, id])]
    );
  }

  if (featureIds.length) {
    await conn.query(
      'INSERT INTO vehicle_features (vehicle_id, feature_id) VALUES ?',
      [featureIds.map(id => [vehicleId, id])]
    );
  }
}

// ------------------------------------------------------------
// Dashboard read endpoints
// ------------------------------------------------------------
app.get('/api/vehicles', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_vehicles ORDER BY id'));
}));

app.get('/api/customers', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_customers ORDER BY id'));
}));

app.get('/api/rentals', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_rentals ORDER BY rental_id DESC'));
}));

app.get('/api/payments', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_payments ORDER BY payment_id DESC'));
}));

app.get('/api/payment-summary', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_payment_summary'));
}));

app.get('/api/rental-summary', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_rental_summary'));
}));

app.get('/api/branches', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_dashboard_branches'));
}));

app.get('/api/maintenance', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_maintenance_dashboard ORDER BY maintenance_id DESC'));
}));

app.get('/api/vehicle-full-details', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_vehicle_full_details ORDER BY vehicle_id'));
}));

app.get('/api/category-feature-report', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_vehicle_category_feature_report ORDER BY branch, category'));
}));

app.get('/api/rental-insurance-report', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_rental_insurance_report ORDER BY rental_id DESC'));
}));

app.get('/api/insurance-usage-report', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_insurance_usage_report ORDER BY insurance_id'));
}));

app.get('/api/out-of-service-report', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_out_of_service_vehicle_report ORDER BY vehicle_id'));
}));

app.get('/api/complex-rental-payment-insurance-report', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_complex_rental_payment_insurance_report ORDER BY rental_id DESC'));
}));

app.get('/api/fleet-summary', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_fleet_summary ORDER BY city'));
}));

app.get('/api/monthly-revenue', asyncRoute(async (req, res) => {
  res.json(await query('SELECT * FROM v_monthly_revenue'));
}));

// ------------------------------------------------------------
// Admin read endpoints
// ------------------------------------------------------------
app.get('/api/admin/vehicles', asyncRoute(async (req, res) => {
  res.json(await query(`
    SELECT
      v.id, v.brand, v.model, v.year, v.plate,
      v.fuel_type, v.transmission, v.daily_rate, v.mileage,
      v.status, v.branch_id,
      b.city AS branch_city, b.name AS branch_name,
      GROUP_CONCAT(DISTINCT c.id ORDER BY c.id SEPARATOR ',') AS category_ids,
      GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS category_names,
      GROUP_CONCAT(DISTINCT f.id ORDER BY f.id SEPARATOR ',') AS feature_ids,
      GROUP_CONCAT(DISTINCT f.name ORDER BY f.name SEPARATOR ', ') AS feature_names
    FROM vehicles v
    JOIN branches b ON b.id = v.branch_id
    LEFT JOIN vehicle_categories vc ON vc.vehicle_id = v.id
    LEFT JOIN categories c ON c.id = vc.category_id
    LEFT JOIN vehicle_features vf ON vf.vehicle_id = v.id
    LEFT JOIN features f ON f.id = vf.feature_id
    GROUP BY
      v.id, v.brand, v.model, v.year, v.plate,
      v.fuel_type, v.transmission, v.daily_rate, v.mileage,
      v.status, v.branch_id, b.city, b.name
    ORDER BY v.id
  `));
}));

app.get('/api/admin/customers', asyncRoute(async (req, res) => {
  res.json(await query(`
    SELECT id, full_name, email, phone, license_no, role, avg_rating, total_rentals
    FROM users
    ORDER BY id
  `));
}));

app.get('/api/admin/categories', asyncRoute(async (req, res) => {
  res.json(await query('SELECT id, name FROM categories ORDER BY name'));
}));

app.get('/api/admin/features', asyncRoute(async (req, res) => {
  res.json(await query('SELECT id, name FROM features ORDER BY name'));
}));

// ------------------------------------------------------------
// Admin vehicle CRUD
// ------------------------------------------------------------
app.post('/api/admin/vehicles', asyncRoute(async (req, res) => {
  requireFields(req.body, ['brand', 'model', 'year', 'plate', 'fuel_type', 'transmission', 'daily_rate', 'mileage', 'branch_id', 'status']);
  const { brand, model, year, plate, fuel_type, transmission, daily_rate, mileage, branch_id, status } = req.body;
  const categoryIds = normalizeIdArray(req.body.category_ids);
  const featureIds = normalizeIdArray(req.body.feature_ids);

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const [result] = await conn.query(`
      INSERT INTO vehicles (brand, model, year, plate, fuel_type, transmission, daily_rate, mileage, branch_id, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [brand, model, year, plate, fuel_type, transmission, daily_rate, mileage, branch_id, status]);

    await replaceVehicleRelations(conn, result.insertId, categoryIds, featureIds);
    await conn.commit();
    res.status(201).json({ id: result.insertId });
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}));

app.put('/api/admin/vehicles/:id', asyncRoute(async (req, res) => {
  requireFields(req.body, ['brand', 'model', 'year', 'plate', 'fuel_type', 'transmission', 'daily_rate', 'mileage', 'branch_id', 'status']);
  const { brand, model, year, plate, fuel_type, transmission, daily_rate, mileage, branch_id, status } = req.body;
  const categoryIds = normalizeIdArray(req.body.category_ids);
  const featureIds = normalizeIdArray(req.body.feature_ids);
  const vehicleId = parseId(req.params.id);

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const [result] = await conn.query(`
      UPDATE vehicles
      SET brand = ?, model = ?, year = ?, plate = ?, fuel_type = ?, transmission = ?,
          daily_rate = ?, mileage = ?, branch_id = ?, status = ?
      WHERE id = ?
    `, [brand, model, year, plate, fuel_type, transmission, daily_rate, mileage, branch_id, status, vehicleId]);

    if (result.affectedRows === 0) {
      await conn.rollback();
      return res.status(404).json({ error: 'Vehicle not found' });
    }

    await replaceVehicleRelations(conn, vehicleId, categoryIds, featureIds);
    await conn.commit();
    res.json({ updated: true });
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}));

app.delete('/api/admin/vehicles/:id', asyncRoute(async (req, res) => {
  const vehicleId = parseId(req.params.id);
  const rentalCheck = await query('SELECT COUNT(*) AS count FROM rentals WHERE vehicle_id = ?', [vehicleId]);
  if (rentalCheck[0].count > 0) {
    return res.status(409).json({ error: 'This vehicle has rental records. Delete is blocked to protect rental history. Change status to OUT_OF_SERVICE instead.' });
  }
  const result = await query('DELETE FROM vehicles WHERE id = ?', [vehicleId]);
  if (result.affectedRows === 0) return res.status(404).json({ error: 'Vehicle not found' });
  res.status(204).end();
}));

// ------------------------------------------------------------
// Admin customer CRUD
// ------------------------------------------------------------
app.post('/api/admin/customers', asyncRoute(async (req, res) => {
  requireFields(req.body, ['full_name', 'email', 'role']);
  const { full_name, email, phone, license_no, role, avg_rating, total_rentals } = req.body;
  const result = await query(`
    INSERT INTO users (full_name, email, phone, license_no, role, avg_rating, total_rentals)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `, [full_name, email, phone || null, license_no || null, role, avg_rating || null, total_rentals || 0]);
  res.status(201).json({ id: result.insertId });
}));

app.put('/api/admin/customers/:id', asyncRoute(async (req, res) => {
  requireFields(req.body, ['full_name', 'email', 'role']);
  const { full_name, email, phone, license_no, role, avg_rating, total_rentals } = req.body;
  const result = await query(`
    UPDATE users
    SET full_name = ?, email = ?, phone = ?, license_no = ?, role = ?, avg_rating = ?, total_rentals = ?
    WHERE id = ?
  `, [full_name, email, phone || null, license_no || null, role, avg_rating || null, total_rentals || 0, parseId(req.params.id)]);
  if (result.affectedRows === 0) return res.status(404).json({ error: 'Customer not found' });
  res.json({ updated: true });
}));

app.delete('/api/admin/customers/:id', asyncRoute(async (req, res) => {
  const customerId = parseId(req.params.id);
  const rentalCheck = await query('SELECT COUNT(*) AS count FROM rentals WHERE user_id = ?', [customerId]);
  if (rentalCheck[0].count > 0) {
    return res.status(409).json({ error: 'This customer has rental records. Delete is blocked to protect rental history.' });
  }
  const result = await query('DELETE FROM users WHERE id = ?', [customerId]);
  if (result.affectedRows === 0) return res.status(404).json({ error: 'Customer not found' });
  res.status(204).end();
}));

// ------------------------------------------------------------
// Health check
// ------------------------------------------------------------
app.get('/api/health', asyncRoute(async (req, res) => {
  await query('SELECT 1 AS ok');
  res.json({ ok: true });
}));


// Errors are turned into clear JSON responses for the dashboard.
// Business-rule errors raised by triggers (SIGNAL SQLSTATE '45000'), such as
// double booking, are shown to the user as they are.
// Keyed by MySQL error number (errno).
const DB_ERRORS = {
  1062: [409, 'A record with the same unique value (e.g. plate, email or license no) already exists.'],
  1452: [400, 'A referenced record (e.g. branch, category or feature) does not exist.'],
  1451: [409, 'This record is used by other records and cannot be deleted.'],
  3819: [400, 'A value is outside the allowed range.'], // CHECK constraint (MySQL)
  4025: [400, 'A value is outside the allowed range.'], // CHECK constraint (MariaDB)
  1366: [400, 'A value has the wrong format.'],
  1265: [400, 'A value is not allowed for this field.']
};

app.use((err, req, res, next) => {
  if (err.sqlState === '45000') {
    return res.status(409).json({ error: err.sqlMessage });
  }
  if (DB_ERRORS[err.errno]) {
    const [status, message] = DB_ERRORS[err.errno];
    return res.status(status).json({ error: message });
  }
  if (err.status) {
    return res.status(err.status).json({ error: err.message });
  }
  console.error(err);
  res.status(500).json({ error: 'Server error. Check the server console for details.' });
});

// Listen on localhost only: this admin API has no login, so it should not be reachable from the network.
const HOST = process.env.HOST || '127.0.0.1';
const PORT = process.env.PORT || 3000;
app.listen(PORT, HOST, () => {
  console.log(`DriveFleet admin API running on http://localhost:${PORT}`);
});
