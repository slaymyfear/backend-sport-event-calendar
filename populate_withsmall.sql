-- populate_from_api.sql (Updated with all 5 matches)
-- First, let's make sure we're using the correct database
USE multiplesportdatabase_schema;

-- Add new columns to existing tables only if they don't exist
SET @dbname = DATABASE();

-- Check and add columns to team table
SET @table_name = 'team';
SET @column_name = 'official_name';
SET @check_sql = CONCAT(
    'SELECT COUNT(*) INTO @col_exists FROM information_schema.COLUMNS ',
    'WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?'
);
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE team ADD COLUMN official_name VARCHAR(200)', 
    'SELECT "official_name column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add slug
SET @column_name = 'slug';
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE team ADD COLUMN slug VARCHAR(200)', 
    'SELECT "slug column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add abbreviation
SET @column_name = 'abbreviation';
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE team ADD COLUMN abbreviation VARCHAR(10)', 
    'SELECT "abbreviation column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add external_id to competition if it doesn't exist
SET @table_name = 'competition';
SET @column_name = 'external_id';
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE competition ADD COLUMN external_id VARCHAR(100)', 
    'SELECT "external_id column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add stage_ordering to competition_season if it doesn't exist
SET @table_name = 'competition_season';
SET @column_name = 'stage_ordering';
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE competition_season ADD COLUMN stage_ordering INT', 
    'SELECT "stage_ordering column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create new table for match cards if it doesn't exist
CREATE TABLE IF NOT EXISTS match_card (
  card_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  player_id INT,
  card_type ENUM('yellow', 'second_yellow', 'red'),
  minute INT,
  FOREIGN KEY (event_id) REFERENCES event(event_id),
  FOREIGN KEY (player_id) REFERENCES player(player_id)
);

-- Create table for match goals if it doesn't exist
CREATE TABLE IF NOT EXISTS match_goal (
  goal_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  player_id INT,
  minute INT,
  period_id INT,
  FOREIGN KEY (event_id) REFERENCES event(event_id),
  FOREIGN KEY (player_id) REFERENCES player(player_id),
  FOREIGN KEY (period_id) REFERENCES period(period_id)
);

-- Insert sport if it doesn't exist
INSERT IGNORE INTO sport (name) VALUES ('football');

-- Insert teams with all available data (using INSERT IGNORE to handle duplicates)
INSERT IGNORE INTO team (name, official_name, slug, abbreviation, city, country)
VALUES 
('Al Shabab FC', 'Al Shabab FC', 'al-shabab-fc', 'SHA', NULL, 'KSA'),
('FC Nasaf', 'FC Nasaf', 'fc-nasaf-qarshi', 'NAS', NULL, 'UZB'),
('Al Hilal Saudi FC', 'Al Hilal Saudi FC', 'al-hilal-saudi-fc', 'HIL', NULL, 'KSA'),
('SHABAB AL AHLI DUBAI', 'SHABAB AL AHLI DUBAI', 'shabab-al-ahli-club', 'SAH', NULL, 'UAE'),
('AL DUHAIL SC', 'AL DUHAIL SC', 'al-duhail-sc', 'DUH', NULL, 'QAT'),
('AL RAYYAN SC', 'AL RAYYAN SC', 'al-rayyan-sc', 'RYN', NULL, 'QAT'),
('Al Faisaly FC', 'Al Faisaly FC', 'al-faisaly-fc', 'FAI', NULL, 'KSA'),
('FOOLAD KHOUZESTAN FC', 'FOOLAD KHOUZESTAN FC', 'foolad-khuzestan-fc', 'FLD', NULL, 'IRN'),
('Urawa Red Diamonds', 'Urawa Red Diamonds', 'urawa-red-diamonds', 'RED', NULL, 'JPN');

-- Insert competition if it doesn't exist
INSERT IGNORE INTO competition (name, sport_id, description, external_id)
SELECT 'AFC Champions League', sport_id, 'Asian Football Confederation Champions League', 'afc-champions-league'
FROM sport WHERE name = 'football';

-- Insert season if it doesn't exist
INSERT IGNORE INTO season (name, start_date, end_date)
VALUES ('2025-2026', '2025-01-01', '2026-12-31');

-- Insert competition_season if it doesn't exist (now including stage ordering)
-- ROUND OF 16 stage
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT 
    c.competition_id, 
    s.season_id, 
    'ROUND OF 16',
    4  -- from API stage.ordering
FROM competition c
JOIN season s ON s.name = '2025-2026'
WHERE c.name = 'AFC Champions League';

-- FINAL stage
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT 
    c.competition_id, 
    s.season_id, 
    'FINAL',
    7  -- from API stage.ordering for FINAL
FROM competition c
JOIN season s ON s.name = '2025-2026'
WHERE c.name = 'AFC Champions League';

-- Insert events for all 5 matches from the JSON
INSERT IGNORE INTO event (
    competition_season_id,
    event_date,
    start_time,
    home_team_id,
    away_team_id,
    status,
    home_score,
    away_score
)
-- Match 1: Al Shabab FC vs FC Nasaf (played on 2025-11-03)
SELECT 
    cs.competition_season_id,
    '2025-11-03',
    '00:00:00',
    ht.team_id,
    at.team_id,
    'played',
    1,  -- homeGoals from JSON
    2   -- awayGoals from JSON
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Al Shabab FC'
JOIN team at ON at.name = 'FC Nasaf'
WHERE c.name = 'AFC Champions League' 
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

UNION ALL

-- Match 2: Al Hilal Saudi FC vs SHABAB AL AHLI DUBAI (scheduled on 2025-11-03)
SELECT 
    cs.competition_season_id,
    '2025-11-03',
    '16:00:00',
    ht.team_id,
    at.team_id,
    'scheduled',
    0,  -- homeGoals from JSON
    0   -- awayGoals from JSON
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Al Hilal Saudi FC'
JOIN team at ON at.name = 'SHABAB AL AHLI DUBAI'
WHERE c.name = 'AFC Champions League' 
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

UNION ALL

-- Match 3: AL DUHAIL SC vs AL RAYYAN SC (scheduled on 2025-11-04)
SELECT 
    cs.competition_season_id,
    '2025-11-04',
    '15:25:00',
    ht.team_id,
    at.team_id,
    'scheduled',
    0,  -- homeGoals from JSON
    0   -- awayGoals from JSON
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'AL DUHAIL SC'
JOIN team at ON at.name = 'AL RAYYAN SC'
WHERE c.name = 'AFC Champions League' 
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

UNION ALL

-- Match 4: Al Faisaly FC vs FOOLAD KHOUZESTAN FC (scheduled on 2025-11-04)
SELECT 
    cs.competition_season_id,
    '2025-11-04',
    '08:00:00',
    ht.team_id,
    at.team_id,
    'scheduled',
    0,  -- homeGoals from JSON
    0   -- awayGoals from JSON
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Al Faisaly FC'
JOIN team at ON at.name = 'FOOLAD KHOUZESTAN FC'
WHERE c.name = 'AFC Champions League' 
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

UNION ALL

-- Match 5: TBD vs Urawa Red Diamonds (FINAL stage on 2025-11-19)
-- Note: This match has null home team in JSON, so we'll set home_team_id to NULL
SELECT 
    cs.competition_season_id,
    '2025-11-19',
    '00:00:00',
    NULL,  -- home_team_id is NULL as per JSON
    at.team_id,
    'scheduled',
    NULL,  -- homeGoals unknown
    NULL   -- awayGoals unknown
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team at ON at.name = 'Urawa Red Diamonds'
WHERE c.name = 'AFC Champions League' 
AND s.name = '2025-2026'
AND cs.phase = 'FINAL';

-- Insert period for the played match (Al Shabab vs Nasaf) if it doesn't exist
INSERT IGNORE INTO period (
    event_id,
    period_number,
    home_score,
    away_score
)
SELECT 
    e.event_id,
    1,  -- Assuming one period for simplicity
    1,  -- Home goals from JSON
    2   -- Away goals from JSON
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
WHERE ht.name = 'Al Shabab FC' 
AND at.name = 'FC Nasaf'
AND e.event_date = '2025-11-03'
AND e.status = 'played';

-- Insert team_competition entries for all teams
INSERT IGNORE INTO team_competition (team_id, competition_season_id)
SELECT DISTINCT t.team_id, cs.competition_season_id
FROM team t
CROSS JOIN competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
WHERE c.name = 'AFC Champions League' 
AND s.name = '2025-2026'
AND t.name IN (
    'Al Shabab FC',
    'FC Nasaf',
    'Al Hilal Saudi FC',
    'SHABAB AL AHLI DUBAI',
    'AL DUHAIL SC',
    'AL RAYYAN SC',
    'Al Faisaly FC',
    'FOOLAD KHOUZESTAN FC',
    'Urawa Red Diamonds'
);

-- Verify the inserted events
SELECT 
    'Event verification' AS check_type,
    e.event_id,
    e.event_date,
    e.start_time,
    ht.name as home_team,
    at.name as away_team,
    e.home_score,
    e.away_score,
    e.status,
    cs.phase as stage
FROM event e
LEFT JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
JOIN competition_season cs ON e.competition_season_id = cs.competition_season_id
JOIN competition c ON cs.competition_id = c.competition_id
WHERE c.name = 'AFC Champions League'
ORDER BY e.event_date, e.start_time;
