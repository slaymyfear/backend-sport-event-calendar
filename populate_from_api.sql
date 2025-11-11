-- First, let's make sure we're using the correct database
USE multiplesportdatabase_schema;

-- Add new columns to existing tables
ALTER TABLE team 
ADD COLUMN official_name VARCHAR(200),
ADD COLUMN slug VARCHAR(200),
ADD COLUMN abbreviation VARCHAR(10);

ALTER TABLE competition 
ADD COLUMN external_id VARCHAR(100);

ALTER TABLE competition_season 
ADD COLUMN stage_ordering INT;

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
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT 
    c.competition_id, 
    s.season_id, 
    'ROUND OF 16',
    4  -- from API stage.ordering
FROM competition c
JOIN season s ON s.name = '2025-2026'
WHERE c.name = 'AFC Champions League';

-- Also add the FINAL stage
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT 
    c.competition_id, 
    s.season_id, 
    'FINAL',
    7  -- from API stage.ordering for FINAL
FROM competition c
JOIN season s ON s.name = '2025-2026'
WHERE c.name = 'AFC Champions League';

-- Insert events
INSERT INTO event (
    competition_season_id,
    event_date,
    start_time,
    home_team_id,
    away_team_id,
    status
)
SELECT 
    cs.competition_season_id,
    '2025-11-03',
    '00:00:00',
    ht.team_id,
    at.team_id,
    'played'
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Al Shabab FC'
JOIN team at ON at.name = 'FC Nasaf'
WHERE c.name = 'AFC Champions League' AND s.name = '2025-2026'
UNION ALL
SELECT 
    cs.competition_season_id,
    '2025-11-03',
    '16:00:00',
    ht.team_id,
    at.team_id,
    'scheduled'
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Al Hilal Saudi FC'
JOIN team at ON at.name = 'SHABAB AL AHLI DUBAI'
WHERE c.name = 'AFC Champions League' AND s.name = '2025-2026'
UNION ALL
SELECT 
    cs.competition_season_id,
    '2025-11-04',
    '15:25:00',
    ht.team_id,
    at.team_id,
    'scheduled'
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'AL DUHAIL SC'
JOIN team at ON at.name = 'AL RAYYAN SC'
WHERE c.name = 'AFC Champions League' AND s.name = '2025-2026'
UNION ALL
SELECT 
    cs.competition_season_id,
    '2025-11-04',
    '08:00:00',
    ht.team_id,
    at.team_id,
    'scheduled'
FROM competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Al Faisaly FC'
JOIN team at ON at.name = 'FOOLAD KHOUZESTAN FC'
WHERE c.name = 'AFC Champions League' AND s.name = '2025-2026';

-- Insert period for the played match (Al Shabab vs Nasaf)
INSERT INTO period (
    event_id,
    period_number,
    home_score,
    away_score
)
SELECT 
    e.event_id,
    1,  -- Assuming one period for simplicity
    1,  -- Home goals
    2   -- Away goals
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
WHERE ht.name = 'Al Shabab FC' 
AND at.name = 'FC Nasaf'
AND e.event_date = '2025-11-03';

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
