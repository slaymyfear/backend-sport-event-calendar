-- ============================================================
-- populate_from_api.sql
-- ============================================================

-- Make sure we’re using the correct DB
USE multiplesportdatabase_schema;

-- ============================================================
-- ✅ SUPPORT TABLES (CREATE IF NOT EXISTS)
-- ============================================================

-- Create table for match cards if not exists
CREATE TABLE IF NOT EXISTS match_card (
  card_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  player_id INT,
  card_type ENUM('yellow', 'second_yellow', 'red'),
  minute INT,
  FOREIGN KEY (event_id) REFERENCES event(event_id),
  FOREIGN KEY (player_id) REFERENCES player(player_id)
);

-- Create table for match goals if not exists
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

-- ============================================================
-- ✅ SPORT
-- ============================================================

INSERT IGNORE INTO sport (name) VALUES ('football');

-- ============================================================
-- ✅ TEAMS
-- ============================================================

INSERT IGNORE INTO team (name, official_name, slug, abbreviation, city, country)
VALUES 
('Al Shabab FC',          'Al Shabab FC',          'al-shabab-fc',         'SHA', NULL, 'KSA'),
('FC Nasaf',              'FC Nasaf',              'fc-nasaf-qarshi',      'NAS', NULL, 'UZB'),
('Al Hilal Saudi FC',     'Al Hilal Saudi FC',     'al-hilal-saudi-fc',    'HIL', NULL, 'KSA'),
('SHABAB AL AHLI DUBAI',  'SHABAB AL AHLI DUBAI',  'shabab-al-ahli-club',  'SAH', NULL, 'UAE'),
('AL DUHAIL SC',          'AL DUHAIL SC',          'al-duhail-sc',         'DUH', NULL, 'QAT'),
('AL RAYYAN SC',          'AL RAYYAN SC',          'al-rayyan-sc',         'RYN', NULL, 'QAT'),
('Al Faisaly FC',         'Al Faisaly FC',         'al-faisaly-fc',        'FAI', NULL, 'KSA'),
('FOOLAD KHOUZESTAN FC',  'FOOLAD KHOUZESTAN FC',  'foolad-khuzestan-fc',  'FLD', NULL, 'IRN'),
('Urawa Red Diamonds',    'Urawa Red Diamonds',    'urawa-red-diamonds',   'RED', NULL, 'JPN');

-- ============================================================
-- ✅ COMPETITION — AFC CL
-- ============================================================

INSERT IGNORE INTO competition (name, sport_id, description)
SELECT 'AFC Champions League', sport_id, 'Asian Football Confederation Champions League'
FROM sport WHERE name = 'football';

-- ============================================================
-- ✅ SEASON
-- ============================================================

INSERT IGNORE INTO season (name, start_date, end_date)
VALUES ('2025-2026', '2025-01-01', '2026-12-31');

-- ============================================================
-- ✅ COMPETITION_SEASON (STAGES)
-- ============================================================

-- ROUND OF 16
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT 
    c.competition_id,
    s.season_id,
    'ROUND OF 16',
    4
FROM competition c
JOIN season s ON s.name = '2025-2026'
WHERE c.name = 'AFC Champions League';

-- FINAL
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT 
    c.competition_id,
    s.season_id,
    'FINAL',
    7
FROM competition c
JOIN season s ON s.name = '2025-2026'
WHERE c.name = 'AFC Champions League';

-- ============================================================
-- ✅ EVENTS
-- ============================================================

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
WHERE c.name = 'AFC Champions League'
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

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
WHERE c.name = 'AFC Champions League'
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

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
WHERE c.name = 'AFC Champions League'
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16'

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
WHERE c.name = 'AFC Champions League'
AND s.name = '2025-2026'
AND cs.phase = 'ROUND OF 16';

-- ============================================================
-- ✅ PERIODS FOR PLAYED MATCH
-- ============================================================

INSERT INTO period (
    event_id,
    period_number,
    home_score,
    away_score
)
SELECT 
    e.event_id,
    1,
    1,
    2
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
WHERE ht.name = 'Al Shabab FC'
AND at.name = 'FC Nasaf'
AND e.event_date = '2025-11-03';

-- ============================================================
-- ✅ TEAM ↔ COMPETITION SEASON MAPPING
-- ============================================================

INSERT IGNORE INTO team_competition (team_id, competition_season_id)
SELECT DISTINCT
    t.team_id,
    cs.competition_season_id
FROM team t
JOIN competition_season cs
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

-- ============================================================
-- ✅ DONE
-- ============================================================

SELECT '✅ populate_from_api complete' AS status;
