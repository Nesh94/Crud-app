const { Pool } = require('pg');

// Reads connection info from environment variables.
// When run via docker-compose, POSTGRES_HOST will be the service name "db".
// When run against AWS RDS, POSTGRES_SSL=true must be set, since RDS
// requires encrypted connections by default and refuses plain ones.
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  database: process.env.POSTGRES_DB || 'cruddb',
  ssl: process.env.POSTGRES_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Creates the "items" table if it doesn't already exist.
// Retries a few times in case Postgres is still starting up.
async function initDb(retries = 10, delayMs = 3000) {
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      await pool.query(`
        CREATE TABLE IF NOT EXISTS items (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          created_at TIMESTAMP DEFAULT NOW()
        );
      `);
      console.log('Database ready: "items" table checked/created.');
      return;
    } catch (err) {
      console.log(`DB not ready yet (attempt ${attempt}/${retries}): ${err.message}`);
      if (attempt === retries) throw err;
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }
}

module.exports = { pool, initDb };
