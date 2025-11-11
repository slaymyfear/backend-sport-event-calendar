-- Fix scores issue: Add columns and populate from periods
USE multiplesportdatabase_schema;

-- Step 1: Add score columns to event table only if they don't exist
SET @dbname = DATABASE();

-- Check and add home_score if it doesn't exist
SET @table_name = 'event';
SET @column_name = 'home_score';
SET @check_sql = CONCAT(
    'SELECT COUNT(*) INTO @col_exists FROM information_schema.COLUMNS ',
    'WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?'
);
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE event ADD COLUMN home_score INT NULL', 
    'SELECT "home_score column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add away_score if it doesn't exist
SET @column_name = 'away_score';
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE event ADD COLUMN away_score INT NULL', 
    'SELECT "away_score column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Check what data we have in periods
SELECT 
    'Period data check' AS check_type,
    p.event_id,
    e.event_date,
    ht.name as home_team,
    at.name as away_team,
    SUM(p.home_score) as total_home,
    SUM(p.away_score) as total_away,
    COUNT(*) as period_count
FROM period p
JOIN event e ON p.event_id = e.event_id
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
GROUP BY p.event_id, e.event_date, ht.name, at.name;

-- Step 3: Temporarily disable safe update mode and update event scores from periods
SET SQL_SAFE_UPDATES = 0;

UPDATE event e
INNER JOIN (
    SELECT 
        event_id,
        SUM(COALESCE(home_score, 0)) as total_home_score,
        SUM(COALESCE(away_score, 0)) as total_away_score
    FROM period
    GROUP BY event_id
) p ON e.event_id = p.event_id
SET 
    e.home_score = p.total_home_score,
    e.away_score = p.total_away_score,
    e.status = 'played'
WHERE p.total_home_score > 0 OR p.total_away_score > 0;

SET SQL_SAFE_UPDATES = 1;

-- Step 4: Verify the results
SELECT 
    'Final event scores' AS check_type,
    e.event_id,
    e.event_date,
    e.start_time,
    ht.name as home_team,
    at.name as away_team,
    e.home_score,
    e.away_score,
    e.status
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
ORDER BY e.event_date, e.start_time;
