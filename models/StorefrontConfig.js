const { pool } = require('../config/database');
const { DEFAULT_HOME, DEFAULT_THEME, mergeHomeConfig, mergeThemeConfig } = require('../utils/storefrontDefaults');

let tablesReady = false;

async function ensureTables() {
  if (tablesReady) return;
  await pool.execute(`
    CREATE TABLE IF NOT EXISTS storefront_config (
      id          TINYINT UNSIGNED NOT NULL PRIMARY KEY DEFAULT 1,
      home_json   JSON NOT NULL,
      theme_json  JSON NOT NULL,
      updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB
  `);
  const [rows] = await pool.execute('SELECT id FROM storefront_config WHERE id = 1 LIMIT 1');
  if (!rows.length) {
    try {
      await pool.execute(
        'INSERT INTO storefront_config (id, home_json, theme_json) VALUES (1, ?, ?)',
        [JSON.stringify(DEFAULT_HOME), JSON.stringify(DEFAULT_THEME)]
      );
    } catch (err) {
      if (err.code !== 'ER_DUP_ENTRY') throw err;
    }
  }
  tablesReady = true;
}

function parseJson(val, fallback) {
  if (!val) return fallback;
  try {
    return typeof val === 'string' ? JSON.parse(val) : val;
  } catch (_) {
    return fallback;
  }
}

async function getConfig() {
  await ensureTables();
  const [rows] = await pool.execute('SELECT * FROM storefront_config WHERE id = 1 LIMIT 1');
  const row = rows[0];
  if (!row) {
    return {
      home: mergeHomeConfig(),
      theme: mergeThemeConfig(),
      updated_at: null,
    };
  }
  return {
    home: mergeHomeConfig(parseJson(row.home_json, DEFAULT_HOME)),
    theme: mergeThemeConfig(parseJson(row.theme_json, DEFAULT_THEME)),
    updated_at: row.updated_at,
  };
}

async function saveHome(home) {
  await ensureTables();
  const merged = mergeHomeConfig(home);
  await pool.execute(
    'UPDATE storefront_config SET home_json = ? WHERE id = 1',
    [JSON.stringify(merged)]
  );
  return merged;
}

async function saveTheme(theme) {
  await ensureTables();
  const merged = mergeThemeConfig(theme);
  await pool.execute(
    'UPDATE storefront_config SET theme_json = ? WHERE id = 1',
    [JSON.stringify(merged)]
  );
  return merged;
}

module.exports = {
  ensureTables,
  getConfig,
  saveHome,
  saveTheme,
};
