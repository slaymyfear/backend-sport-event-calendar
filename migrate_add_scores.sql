-- Complete migration: Add score columns to event table and populate from periods
USE multiplesportdatabase_schema;

-- Temporarily disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Step 1: Add columns (safe to run multiple times with IF NOT EXISTS check)
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'multiplesportdatabase_schema' 
    AND TABLE_NAME = 'event' 
    AND COLUMN_NAME = 'home_score'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE event ADD COLUMN home_score INT NULL, ADD COLUMN away_score INT NULL',
    'SELECT "Columns already exist" AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Update events with scores aggregated from their periods
UPDATE event e
INNER JOIN (
    SELECT 
        event_id,
        SUM(COALESCE(home_score, 0)) as total_home_score,
        SUM(COALESCE(away_score, 0)) as total_away_score
    FROM period
    GROUP BY event_id
    HAVING total_home_score > 0 OR total_away_score > 0
) p ON e.event_id = p.event_id
SET 
    e.home_score = p.total_home_score,
    e.away_score = p.total_away_score,
    e.status = 'played'
WHERE (e.home_score IS NULL AND e.away_score IS NULL)
   OR (e.home_score = 0 AND e.away_score = 0);

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Verify: Show events with scores
SELECT 
    e.event_id,
    ht.name as home_team,
    at.name as away_team,
    e.home_score,
    e.away_score,
    e.status,
    e.event_date
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
WHERE e.home_score IS NOT NULL OR e.away_score IS NOT NULL
ORDER BY e.event_date;
