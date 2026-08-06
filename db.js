const { Pool } = require('pg');

// Reads connection info from environment variables.
// When run via docker-compose, POSTGRES_HOST will be the service name "db".
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  database: process.env.POSTGRES_DB || 'cruddb',
});

// Creates the "items" table if it doesn't already exist.
async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS items (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      description TEXT,
      created_at TIMESTAMP DEFAULT NOW()
    );
  `);
  console.log('Database ready: "items" table checked/created.');
}

module.exports = { pool, initDb };
