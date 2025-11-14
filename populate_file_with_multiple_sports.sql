-- populate_comprehensive_sports_data_complete.sql
-- COMPLETE population script for ALL sports data from JSON
USE multiplesportdatabase_schema;

-- Step 1: Add any missing columns to tables
SET @dbname = DATABASE();

-- Add venue capacity if it doesn't exist
SET @table_name = 'venue';
SET @column_name = 'capacity';
SET @check_sql = CONCAT(
    'SELECT COUNT(*) INTO @col_exists FROM information_schema.COLUMNS ',
    'WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?'
);
PREPARE stmt FROM @check_sql;
EXECUTE stmt USING @dbname, @table_name, @column_name;
DEALLOCATE PREPARE stmt;

SET @add_sql = IF(@col_exists = 0, 
    'ALTER TABLE venue ADD COLUMN capacity INT NULL', 
    'SELECT "capacity column already exists" AS message');
PREPARE stmt FROM @add_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Insert sports
INSERT IGNORE INTO sport (name) VALUES 
('football'),
('basketball'),
('hockey'),
('american-football'),
('tennis');

-- Step 3: Insert competitions
INSERT IGNORE INTO competition (name, sport_id, description, external_id)
SELECT 'Premier League', sport_id, 'English Premier League', 'premier-league' FROM sport WHERE name = 'football'
UNION ALL SELECT 'La Liga', sport_id, 'Spanish La Liga', 'la-liga' FROM sport WHERE name = 'football'
UNION ALL SELECT 'Serie A', sport_id, 'Italian Serie A', 'serie-a' FROM sport WHERE name = 'football'
UNION ALL SELECT 'Ligue 1', sport_id, 'French Ligue 1', 'ligue-1' FROM sport WHERE name = 'football'
UNION ALL SELECT 'UEFA Champions League', sport_id, 'UEFA Champions League', 'uefa-champions-league' FROM sport WHERE name = 'football'
UNION ALL SELECT 'UEFA Europa League', sport_id, 'UEFA Europa League', 'uefa-europa-league' FROM sport WHERE name = 'football'
UNION ALL SELECT 'NBA', sport_id, 'National Basketball Association', 'nba' FROM sport WHERE name = 'basketball'
UNION ALL SELECT 'NBA Playoffs', sport_id, 'NBA Playoffs', 'nba-playoffs' FROM sport WHERE name = 'basketball'
UNION ALL SELECT 'NHL', sport_id, 'National Hockey League', 'nhl' FROM sport WHERE name = 'hockey'
UNION ALL SELECT 'NFL', sport_id, 'National Football League', 'nfl' FROM sport WHERE name = 'american-football'
UNION ALL SELECT 'Wimbledon', sport_id, 'Wimbledon Championships', 'wimbledon' FROM sport WHERE name = 'tennis'
UNION ALL SELECT 'US Open', sport_id, 'US Open Tennis', 'us-open' FROM sport WHERE name = 'tennis'
UNION ALL SELECT 'Australian Open', sport_id, 'Australian Open Tennis', 'australian-open' FROM sport WHERE name = 'tennis';

-- Step 4: Insert seasons
INSERT IGNORE INTO season (name, start_date, end_date) VALUES
('2023-2024', '2023-07-01', '2024-06-30'),
('2024-2025', '2024-07-01', '2025-06-30'),
('2025-2026', '2025-07-01', '2026-06-30');

-- Step 5: Insert competition_season entries
INSERT IGNORE INTO competition_season (competition_id, season_id, phase, stage_ordering)
SELECT c.competition_id, s.season_id, 'Regular Season', 1
FROM competition c
CROSS JOIN season s
WHERE c.name IN ('Premier League', 'La Liga', 'Serie A', 'Ligue 1', 'NBA', 'NHL', 'NFL')
AND s.name IN ('2023-2024', '2024-2025', '2025-2026')

UNION ALL
SELECT c.competition_id, s.season_id, 'Group Stage', 2
FROM competition c
CROSS JOIN season s
WHERE c.name IN ('UEFA Champions League', 'UEFA Europa League')
AND s.name IN ('2023-2024', '2024-2025', '2025-2026')

UNION ALL
SELECT c.competition_id, s.season_id, 'Quarter Final', 5
FROM competition c
CROSS JOIN season s
WHERE c.name IN ('UEFA Champions League', 'UEFA Europa League')
AND s.name IN ('2023-2024', '2024-2025', '2025-2026')

UNION ALL
SELECT c.competition_id, s.season_id, 'Semi Final', 6
FROM competition c
CROSS JOIN season s
WHERE c.name IN ('UEFA Champions League', 'UEFA Europa League')
AND s.name IN ('2023-2024', '2024-2025', '2025-2026')

UNION ALL
SELECT c.competition_id, s.season_id, 'Final', 7
FROM competition c
CROSS JOIN season s
WHERE c.name IN ('UEFA Champions League', 'UEFA Europa League', 'Wimbledon', 'US Open', 'Australian Open')
AND s.name IN ('2023-2024', '2024-2025', '2025-2026')

UNION ALL
SELECT c.competition_id, s.season_id, 'First Round', 2
FROM competition c
CROSS JOIN season s
WHERE c.name = 'NBA Playoffs'
AND s.name IN ('2024-2025')

UNION ALL
SELECT c.competition_id, s.season_id, 'Conference Semifinals', 3
FROM competition c
CROSS JOIN season s
WHERE c.name = 'NBA Playoffs'
AND s.name IN ('2024-2025')

UNION ALL
SELECT c.competition_id, s.season_id, 'Conference Finals', 4
FROM competition c
CROSS JOIN season s
WHERE c.name = 'NBA Playoffs'
AND s.name IN ('2024-2025')

UNION ALL
SELECT c.competition_id, s.season_id, 'NBA Finals', 5
FROM competition c
CROSS JOIN season s
WHERE c.name = 'NBA Playoffs'
AND s.name IN ('2024-2025')

UNION ALL
SELECT c.competition_id, s.season_id, 'Playoffs', 3
FROM competition c
CROSS JOIN season s
WHERE c.name = 'NHL'
AND s.name IN ('2023-2024')

UNION ALL
SELECT c.competition_id, s.season_id, 'Stanley Cup Final', 4
FROM competition c
CROSS JOIN season s
WHERE c.name = 'NHL'
AND s.name IN ('2023-2024');

-- Step 6: Insert venues
INSERT IGNORE INTO venue (name, city, country, capacity)
VALUES
-- Football stadiums
('Emirates Stadium', 'London', 'ENG', 60260),
('Old Trafford', 'Manchester', 'ENG', 74600),
('Anfield', 'Liverpool', 'ENG', 54074),
('Etihad Stadium', 'Manchester', 'ENG', 55017),
('Stamford Bridge', 'London', 'ENG', 40341),
('Tottenham Hotspur Stadium', 'London', 'ENG', 62850),
('Santiago Bernabéu', 'Madrid', 'ESP', 81044),
('Camp Nou', 'Barcelona', 'ESP', 99354),
('Wanda Metropolitano', 'Madrid', 'ESP', 68456),
('Benito Villamarín', 'Seville', 'ESP', 60852),
('Ramón Sánchez Pizjuán', 'Seville', 'ESP', 43284),
('San Siro', 'Milan', 'ITA', 80018),
('Stadio Giuseppe Meazza', 'Milan', 'ITA', 80018),
('Stadio Olimpico', 'Rome', 'ITA', 70400),
('Allianz Stadium', 'Turin', 'ITA', 41507),
('Parc des Princes', 'Paris', 'FRA', 47929),
('Allianz Arena', 'Munich', 'DEU', 75000),
('Signal Iduna Park', 'Dortmund', 'DEU', 81365),
('Estádio José Alvalade', 'Lisbon', 'PRT', 50529),
('Gewiss Stadium', 'Bergamo', 'ITA', 21500),
('Stade Vélodrome', 'Marseille', 'FRA', 67394),
('BayArena', 'Leverkusen', 'DEU', 30000),
('London Stadium', 'London', 'ENG', 60000),
('Wembley Stadium', 'London', 'ENG', 90000),

-- Basketball arenas
('Paycom Center', 'Oklahoma City', 'USA', 18203),
('TD Garden', 'Boston', 'USA', 18624),
('Madison Square Garden', 'New York', 'USA', 19812),
('Fiserv Forum', 'Milwaukee', 'USA', 17500),
('Gainbridge Fieldhouse', 'Indianapolis', 'USA', 17923),
('Target Center', 'Minneapolis', 'USA', 19356),
('Chase Center', 'San Francisco', 'USA', 18064),
('Crypto.com Arena', 'Los Angeles', 'USA', 19060),
('American Airlines Center', 'Dallas', 'USA', 19200),
('Kaseya Center', 'Miami', 'USA', 19600),
('Amway Center', 'Orlando', 'USA', 18846),
('Ball Arena', 'Denver', 'USA', 19520),
('Scotiabank Arena', 'Toronto', 'CAN', 19800),
('Rocket Mortgage FieldHouse', 'Cleveland', 'USA', 19432),
('Golden 1 Center', 'Sacramento', 'USA', 17608),

-- Hockey arenas
('Rogers Place', 'Edmonton', 'CAN', 18347),
('Amerant Bank Arena', 'Sunrise', 'USA', 19250),

-- NFL stadiums
('Arrowhead Stadium', 'Kansas City', 'USA', 76416),
('Lambeau Field', 'Green Bay', 'USA', 81441),

-- Tennis venues
('Centre Court', 'London', 'GBR', 14979),
('Arthur Ashe Stadium', 'New York', 'USA', 23771),
('Rod Laver Arena', 'Melbourne', 'AUS', 14820);

-- Step 7: Insert teams
INSERT IGNORE INTO team (name, official_name, slug, abbreviation, city, country)
VALUES
-- Football teams
('Arsenal', 'Arsenal FC', 'arsenal', 'ARS', 'London', 'ENG'),
('Everton', 'Everton FC', 'everton', 'EVE', 'Liverpool', 'ENG'),
('Real Madrid', 'Real Madrid CF', 'real-madrid', 'RMA', 'Madrid', 'ESP'),
('Manchester City', 'Manchester City FC', 'manchester-city', 'MCI', 'Manchester', 'ENG'),
('Bayern Munich', 'FC Bayern München', 'bayern-munich', 'BAY', 'Munich', 'DEU'),
('PSG', 'Paris Saint-Germain FC', 'psg', 'PSG', 'Paris', 'FRA'),
('Borussia Dortmund', 'Borussia Dortmund', 'dortmund', 'BVB', 'Dortmund', 'DEU'),
('Inter Milan', 'FC Internazionale Milano', 'inter-milan', 'INT', 'Milan', 'ITA'),
('AC Milan', 'AC Milan', 'ac-milan', 'MIL', 'Milan', 'ITA'),
('Manchester United', 'Manchester United FC', 'manchester-united', 'MUN', 'Manchester', 'ENG'),
('Fulham', 'Fulham FC', 'fulham', 'FUL', 'London', 'ENG'),
('Liverpool', 'Liverpool FC', 'liverpool', 'LIV', 'Liverpool', 'ENG'),
('Chelsea', 'Chelsea FC', 'chelsea', 'CHE', 'London', 'ENG'),
('Barcelona', 'FC Barcelona', 'barcelona', 'BAR', 'Barcelona', 'ESP'),
('Juventus', 'Juventus FC', 'juventus', 'JUV', 'Turin', 'ITA'),
('Monaco', 'AS Monaco', 'monaco', 'MON', 'Monaco', 'FRA'),
('Tottenham Hotspur', 'Tottenham Hotspur FC', 'tottenham-hotspur', 'TOT', 'London', 'ENG'),
('Sevilla', 'Sevilla FC', 'sevilla', 'SEV', 'Seville', 'ESP'),
('Atletico Madrid', 'Club Atlético de Madrid', 'atletico-madrid', 'ATM', 'Madrid', 'ESP'),
('Real Betis', 'Real Betis Balompié', 'real-betis', 'BET', 'Seville', 'ESP'),
('Napoli', 'SSC Napoli', 'napoli', 'NAP', 'Naples', 'ITA'),
('Roma', 'AS Roma', 'roma', 'ROM', 'Rome', 'ITA'),

-- Basketball teams
('Oklahoma City Thunder', 'Oklahoma City Thunder', 'thunder', 'OKC', 'Oklahoma City', 'USA'),
('Memphis Grizzlies', 'Memphis Grizzlies', 'grizzlies', 'MEM', 'Memphis', 'USA'),
('Boston Celtics', 'Boston Celtics', 'celtics', 'BOS', 'Boston', 'USA'),
('Miami Heat', 'Miami Heat', 'heat', 'MIA', 'Miami', 'USA'),
('New York Knicks', 'New York Knicks', 'knicks', 'NYK', 'New York', 'USA'),
('Cleveland Cavaliers', 'Cleveland Cavaliers', 'cavaliers', 'CLE', 'Cleveland', 'USA'),
('New Orleans Pelicans', 'New Orleans Pelicans', 'pelicans', 'NOP', 'New Orleans', 'USA'),
('Milwaukee Bucks', 'Milwaukee Bucks', 'bucks', 'MIL', 'Milwaukee', 'USA'),
('Atlanta Hawks', 'Atlanta Hawks', 'hawks', 'ATL', 'Atlanta', 'USA'),
('Indiana Pacers', 'Indiana Pacers', 'pacers', 'IND', 'Indianapolis', 'USA'),
('Philadelphia 76ers', 'Philadelphia 76ers', '76ers', 'PHI', 'Philadelphia', 'USA'),
('Minnesota Timberwolves', 'Minnesota Timberwolves', 'timberwolves', 'MIN', 'Minneapolis', 'USA'),
('Phoenix Suns', 'Phoenix Suns', 'suns', 'PHX', 'Phoenix', 'USA'),
('Golden State Warriors', 'Golden State Warriors', 'warriors', 'GSW', 'San Francisco', 'USA'),
('Dallas Mavericks', 'Dallas Mavericks', 'mavericks', 'DAL', 'Dallas', 'USA'),
('Denver Nuggets', 'Denver Nuggets', 'nuggets', 'DEN', 'Denver', 'USA'),
('Houston Rockets', 'Houston Rockets', 'rockets', 'HOU', 'Houston', 'USA'),
('LA Lakers', 'Los Angeles Lakers', 'lakers', 'LAL', 'Los Angeles', 'USA'),
('Detroit Pistons', 'Detroit Pistons', 'pistons', 'DET', 'Detroit', 'USA'),
('Orlando Magic', 'Orlando Magic', 'magic', 'ORL', 'Orlando', 'USA'),
('Utah Jazz', 'Utah Jazz', 'jazz', 'UTA', 'Salt Lake City', 'USA'),
('LA Clippers', 'Los Angeles Clippers', 'clippers', 'LAC', 'Los Angeles', 'USA'),
('Toronto Raptors', 'Toronto Raptors', 'raptors', 'TOR', 'Toronto', 'CAN'),
('Brooklyn Nets', 'Brooklyn Nets', 'nets', 'BKN', 'Brooklyn', 'USA'),
('Sacramento Kings', 'Sacramento Kings', 'kings', 'SAC', 'Sacramento', 'USA'),

-- Hockey teams
('Edmonton Oilers', 'Edmonton Oilers', 'oilers', 'EDM', 'Edmonton', 'CAN'),
('Vancouver Canucks', 'Vancouver Canucks', 'canucks', 'VAN', 'Vancouver', 'CAN'),
('Florida Panthers', 'Florida Panthers', 'panthers', 'FLA', 'Sunrise', 'USA'),

-- NFL teams
('Kansas City Chiefs', 'Kansas City Chiefs', 'chiefs', 'KC', 'Kansas City', 'USA'),
('Baltimore Ravens', 'Baltimore Ravens', 'ravens', 'BAL', 'Baltimore', 'USA'),
('Green Bay Packers', 'Green Bay Packers', 'packers', 'GB', 'Green Bay', 'USA'),
('San Francisco 49ers', 'San Francisco 49ers', '49ers', 'SF', 'San Francisco', 'USA'),

-- Tennis players (treated as teams for individual sports)
('Carlos Alcaraz', 'Carlos Alcaraz', 'alcaraz', 'ALC', NULL, 'ESP'),
('Novak Djokovic', 'Novak Djokovic', 'djokovic', 'DJK', NULL, 'SRB'),
('Coco Gauff', 'Coco Gauff', 'gauff', 'GAU', NULL, 'USA'),
('Aryna Sabalenka', 'Aryna Sabalenka', 'sabalenka', 'SAB', NULL, 'BLR'),
('Jannik Sinner', 'Jannik Sinner', 'sinner', 'SIN', NULL, 'ITA'),
('Daniil Medvedev', 'Daniil Medvedev', 'medvedev', 'MED', NULL, 'RUS');

-- Step 8: Insert ALL events from JSON (COMPLETE SET)
INSERT IGNORE INTO event (
    competition_season_id,
    event_date,
    start_time,
    home_team_id,
    away_team_id,
    venue_id,
    status,
    home_score,
    away_score
)
-- Football Events 2023-2024
SELECT cs.competition_season_id, '2024-05-19', '16:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 2, 1
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Arsenal' JOIN team at ON at.name = 'Everton' JOIN venue v ON v.name = 'Emirates Stadium'
WHERE c.name = 'Premier League' AND s.name = '2023-2024' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2024-04-09', '18:45:00', ht.team_id, at.team_id, v.venue_id, 'played', 3, 3
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Real Madrid' JOIN team at ON at.name = 'Manchester City' JOIN venue v ON v.name = 'Santiago Bernabéu'
WHERE c.name = 'UEFA Champions League' AND s.name = '2023-2024' AND cs.phase = 'Quarter Final'

UNION ALL SELECT cs.competition_season_id, '2024-04-17', '19:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 1, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Bayern Munich' JOIN team at ON at.name = 'Arsenal' JOIN venue v ON v.name = 'Allianz Arena'
WHERE c.name = 'UEFA Champions League' AND s.name = '2023-2024' AND cs.phase = 'Quarter Final'

UNION ALL SELECT cs.competition_season_id, '2024-05-08', '20:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 0, 1
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'PSG' JOIN team at ON at.name = 'Borussia Dortmund' JOIN venue v ON v.name = 'Parc des Princes'
WHERE c.name = 'UEFA Champions League' AND s.name = '2023-2024' AND cs.phase = 'Semi Final'

UNION ALL SELECT cs.competition_season_id, '2024-04-21', '18:45:00', ht.team_id, at.team_id, v.venue_id, 'played', 2, 1
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Inter Milan' JOIN team at ON at.name = 'AC Milan' JOIN venue v ON v.name = 'San Siro'
WHERE c.name = 'Serie A' AND s.name = '2023-2024' AND cs.phase = 'Regular Season'

-- Football Events 2024-2025
UNION ALL SELECT cs.competition_season_id, '2024-08-18', '15:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 1, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Manchester United' JOIN team at ON at.name = 'Fulham' JOIN venue v ON v.name = 'Old Trafford'
WHERE c.name = 'Premier League' AND s.name = '2024-2025' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2024-09-21', '16:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 2, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Liverpool' JOIN team at ON at.name = 'Chelsea' JOIN venue v ON v.name = 'Anfield'
WHERE c.name = 'Premier League' AND s.name = '2024-2025' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2024-10-26', '19:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 2, 1
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Barcelona' JOIN team at ON at.name = 'Real Madrid' JOIN venue v ON v.name = 'Camp Nou'
WHERE c.name = 'La Liga' AND s.name = '2024-2025' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2024-11-09', '17:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 1, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Juventus' JOIN team at ON at.name = 'AC Milan' JOIN venue v ON v.name = 'Allianz Stadium'
WHERE c.name = 'Serie A' AND s.name = '2024-2025' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2024-12-07', '20:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 3, 1
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'PSG' JOIN team at ON at.name = 'Monaco' JOIN venue v ON v.name = 'Parc des Princes'
WHERE c.name = 'Ligue 1' AND s.name = '2024-2025' AND cs.phase = 'Regular Season'

-- Football Events 2025-2026
UNION ALL SELECT cs.competition_season_id, '2025-11-08', '18:45:00', ht.team_id, at.team_id, v.venue_id, 'played', 4, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Manchester United' JOIN team at ON at.name = 'Chelsea' JOIN venue v ON v.name = 'Old Trafford'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-15', '15:30:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Arsenal' JOIN team at ON at.name = 'Chelsea' JOIN venue v ON v.name = 'Emirates Stadium'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-22', '19:15:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Arsenal' JOIN team at ON at.name = 'Tottenham Hotspur' JOIN venue v ON v.name = 'Emirates Stadium'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-24', '13:00:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Arsenal' JOIN team at ON at.name = 'Manchester City' JOIN venue v ON v.name = 'Emirates Stadium'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-12-01', '12:00:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Manchester City' JOIN team at ON at.name = 'Manchester United' JOIN venue v ON v.name = 'Etihad Stadium'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-03', '12:15:00', ht.team_id, at.team_id, v.venue_id, 'played', 1, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Manchester City' JOIN team at ON at.name = 'Liverpool' JOIN venue v ON v.name = 'Etihad Stadium'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-27', '20:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 1, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Liverpool' JOIN team at ON at.name = 'Manchester United' JOIN venue v ON v.name = 'Anfield'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-10', '19:15:00', ht.team_id, at.team_id, v.venue_id, 'in progress', 1, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Manchester United' JOIN team at ON at.name = 'Chelsea' JOIN venue v ON v.name = 'Old Trafford'
WHERE c.name = 'Premier League' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

-- La Liga 2025-2026
UNION ALL SELECT cs.competition_season_id, '2025-11-11', '13:45:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Sevilla' JOIN team at ON at.name = 'Atletico Madrid' JOIN venue v ON v.name = 'Ramón Sánchez Pizjuán'
WHERE c.name = 'La Liga' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-27', '16:45:00', ht.team_id, at.team_id, v.venue_id, 'played', 4, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Atletico Madrid' JOIN team at ON at.name = 'Real Madrid' JOIN venue v ON v.name = 'Wanda Metropolitano'
WHERE c.name = 'La Liga' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-11', '21:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 4, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Real Madrid' JOIN team at ON at.name = 'Barcelona' JOIN venue v ON v.name = 'Santiago Bernabéu'
WHERE c.name = 'La Liga' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-11', '15:45:00', ht.team_id, at.team_id, v.venue_id, 'played', 1, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Real Betis' JOIN team at ON at.name = 'Atletico Madrid' JOIN venue v ON v.name = 'Benito Villamarín'
WHERE c.name = 'La Liga' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-23', '13:30:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Barcelona' JOIN team at ON at.name = 'Real Betis' JOIN venue v ON v.name = 'Camp Nou'
WHERE c.name = 'La Liga' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-08', '20:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 2, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Real Betis' JOIN team at ON at.name = 'Barcelona' JOIN venue v ON v.name = 'Benito Villamarín'
WHERE c.name = 'La Liga' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

-- Serie A 2025-2026
UNION ALL SELECT cs.competition_season_id, '2025-11-16', '15:15:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'AC Milan' JOIN team at ON at.name = 'Napoli' JOIN venue v ON v.name = 'San Siro'
WHERE c.name = 'Serie A' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-11', '16:15:00', ht.team_id, at.team_id, v.venue_id, 'played', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Inter Milan' JOIN team at ON at.name = 'Napoli' JOIN venue v ON v.name = 'San Siro'
WHERE c.name = 'Serie A' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-30', '20:15:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Inter Milan' JOIN team at ON at.name = 'Napoli' JOIN venue v ON v.name = 'San Siro'
WHERE c.name = 'Serie A' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-27', '14:45:00', ht.team_id, at.team_id, v.venue_id, 'played', 3, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Roma' JOIN team at ON at.name = 'Inter Milan' JOIN venue v ON v.name = 'Stadio Olimpico'
WHERE c.name = 'Serie A' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-08', '20:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 0, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Roma' JOIN team at ON at.name = 'AC Milan' JOIN venue v ON v.name = 'Stadio Olimpico'
WHERE c.name = 'Serie A' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-03', '12:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 3, 3
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Juventus' JOIN team at ON at.name = 'Napoli' JOIN venue v ON v.name = 'Allianz Stadium'
WHERE c.name = 'Serie A' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

-- Champions League 2025-2026
UNION ALL SELECT cs.competition_season_id, '2025-11-10', '19:15:00', ht.team_id, at.team_id, v.venue_id, 'in progress', 1, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Real Madrid' JOIN team at ON at.name = 'Barcelona' JOIN venue v ON v.name = 'Santiago Bernabéu'
WHERE c.name = 'UEFA Champions League' AND s.name = '2025-2026' AND cs.phase = 'Group Stage'

UNION ALL SELECT cs.competition_season_id, '2025-12-10', '21:45:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Barcelona' JOIN team at ON at.name = 'PSG' JOIN venue v ON v.name = 'Camp Nou'
WHERE c.name = 'UEFA Champions League' AND s.name = '2025-2026' AND cs.phase = 'Group Stage'

UNION ALL SELECT cs.competition_season_id, '2025-11-08', '20:15:00', ht.team_id, at.team_id, v.venue_id, 'played', 2, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Inter Milan' JOIN team at ON at.name = 'Manchester City' JOIN venue v ON v.name = 'San Siro'
WHERE c.name = 'UEFA Champions League' AND s.name = '2025-2026' AND cs.phase = 'Group Stage'

-- NBA Playoffs 2024-2025 (First Round)
UNION ALL SELECT cs.competition_season_id, '2025-04-19', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 118, 102
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Memphis Grizzlies' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-20', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 112, 95
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Boston Celtics' JOIN team at ON at.name = 'Miami Heat' JOIN venue v ON v.name = 'TD Garden'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-21', '00:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 109, 104
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'New York Knicks' JOIN team at ON at.name = 'Cleveland Cavaliers' JOIN venue v ON v.name = 'Madison Square Garden'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-22', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 121, 99
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'New Orleans Pelicans' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-23', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 115, 108
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Milwaukee Bucks' JOIN team at ON at.name = 'Atlanta Hawks' JOIN venue v ON v.name = 'Fiserv Forum'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-24', '00:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 120, 111
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Indiana Pacers' JOIN team at ON at.name = 'Philadelphia 76ers' JOIN venue v ON v.name = 'Gainbridge Fieldhouse'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-25', '02:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 117, 101
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Minnesota Timberwolves' JOIN team at ON at.name = 'Phoenix Suns' JOIN venue v ON v.name = 'Target Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

UNION ALL SELECT cs.competition_season_id, '2025-04-26', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 114, 110
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Golden State Warriors' JOIN team at ON at.name = 'Dallas Mavericks' JOIN venue v ON v.name = 'Chase Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'First Round'

-- NBA Playoffs 2024-2025 (Conference Semifinals)
UNION ALL SELECT cs.competition_season_id, '2025-05-06', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 108, 112
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Boston Celtics' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'TD Garden'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Semifinals'

UNION ALL SELECT cs.competition_season_id, '2025-05-07', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 110, 116
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Milwaukee Bucks' JOIN team at ON at.name = 'New York Knicks' JOIN venue v ON v.name = 'Fiserv Forum'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Semifinals'

UNION ALL SELECT cs.competition_season_id, '2025-05-08', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 119, 105
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Golden State Warriors' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Semifinals'

UNION ALL SELECT cs.competition_season_id, '2025-05-09', '02:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 111, 107
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Minnesota Timberwolves' JOIN team at ON at.name = 'Denver Nuggets' JOIN venue v ON v.name = 'Target Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Semifinals'

-- NBA Playoffs 2024-2025 (Conference Finals)
UNION ALL SELECT cs.competition_season_id, '2025-05-22', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 138, 135
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Indiana Pacers' JOIN team at ON at.name = 'New York Knicks' JOIN venue v ON v.name = 'Gainbridge Fieldhouse'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Finals'

UNION ALL SELECT cs.competition_season_id, '2025-05-23', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 120, 104
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Minnesota Timberwolves' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Finals'

UNION ALL SELECT cs.competition_season_id, '2025-05-24', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 109, 114
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'New York Knicks' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'Madison Square Garden'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Finals'

UNION ALL SELECT cs.competition_season_id, '2025-05-25', '02:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 101, 118
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Minnesota Timberwolves' JOIN team at ON at.name = 'Oklahoma City Thunder' JOIN venue v ON v.name = 'Target Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'Conference Finals'

-- NBA Playoffs 2024-2025 (NBA Finals)
UNION ALL SELECT cs.competition_season_id, '2025-06-05', '01:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 110, 111
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

UNION ALL SELECT cs.competition_season_id, '2025-06-07', '01:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 123, 107
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

UNION ALL SELECT cs.competition_season_id, '2025-06-10', '01:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 116, 107
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Indiana Pacers' JOIN team at ON at.name = 'Oklahoma City Thunder' JOIN venue v ON v.name = 'Gainbridge Fieldhouse'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

UNION ALL SELECT cs.competition_season_id, '2025-06-12', '01:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 104, 111
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Indiana Pacers' JOIN team at ON at.name = 'Oklahoma City Thunder' JOIN venue v ON v.name = 'Gainbridge Fieldhouse'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

UNION ALL SELECT cs.competition_season_id, '2025-06-15', '01:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 120, 109
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

UNION ALL SELECT cs.competition_season_id, '2025-06-18', '01:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 91, 108
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Indiana Pacers' JOIN team at ON at.name = 'Oklahoma City Thunder' JOIN venue v ON v.name = 'Gainbridge Fieldhouse'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

UNION ALL SELECT cs.competition_season_id, '2025-06-22', '01:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 103, 91
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA Playoffs' AND s.name = '2024-2025' AND cs.phase = 'NBA Finals'

-- NBA Regular Season 2025-2026
UNION ALL SELECT cs.competition_season_id, '2025-10-21', '00:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 119, 112
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Oklahoma City Thunder' JOIN team at ON at.name = 'Houston Rockets' JOIN venue v ON v.name = 'Paycom Center'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-21', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 115, 109
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'LA Lakers' JOIN team at ON at.name = 'Golden State Warriors' JOIN venue v ON v.name = 'Crypto.com Arena'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-22', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 111, 106
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Boston Celtics' JOIN team at ON at.name = 'New York Knicks' JOIN venue v ON v.name = 'TD Garden'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-22', '01:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 118, 113
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Dallas Mavericks' JOIN team at ON at.name = 'Phoenix Suns' JOIN venue v ON v.name = 'American Airlines Center'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-23', '00:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 118, 114
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Milwaukee Bucks' JOIN team at ON at.name = 'Indiana Pacers' JOIN venue v ON v.name = 'Fiserv Forum'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-23', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 109, 107
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Miami Heat' JOIN team at ON at.name = 'Philadelphia 76ers' JOIN venue v ON v.name = 'Kaseya Center'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-28', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 109, 102
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Orlando Magic' JOIN team at ON at.name = 'Detroit Pistons' JOIN venue v ON v.name = 'Amway Center'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-28', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 115, 110
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Denver Nuggets' JOIN team at ON at.name = 'Utah Jazz' JOIN venue v ON v.name = 'Ball Arena'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-31', '00:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 116, 122
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Minnesota Timberwolves' JOIN team at ON at.name = 'Oklahoma City Thunder' JOIN venue v ON v.name = 'Target Center'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-10-31', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 118, 112
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'LA Clippers' JOIN team at ON at.name = 'LA Lakers' JOIN venue v ON v.name = 'Crypto.com Arena'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-01', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 109, 120
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Toronto Raptors' JOIN team at ON at.name = 'Boston Celtics' JOIN venue v ON v.name = 'Scotiabank Arena'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-01', '01:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 109, 112
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Indiana Pacers' JOIN team at ON at.name = 'New York Knicks' JOIN venue v ON v.name = 'Gainbridge Fieldhouse'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-03', '00:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 116, 112
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Cleveland Cavaliers' JOIN team at ON at.name = 'Brooklyn Nets' JOIN venue v ON v.name = 'Rocket Mortgage FieldHouse'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2025-11-03', '02:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 118, 115
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Sacramento Kings' JOIN team at ON at.name = 'Houston Rockets' JOIN venue v ON v.name = 'Golden 1 Center'
WHERE c.name = 'NBA' AND s.name = '2025-2026' AND cs.phase = 'Regular Season'

-- NHL Games
UNION ALL SELECT cs.competition_season_id, '2024-05-18', '23:00:00', ht.team_id, at.team_id, v.venue_id, 'played', 3, 2
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Edmonton Oilers' JOIN team at ON at.name = 'Vancouver Canucks' JOIN venue v ON v.name = 'Rogers Place'
WHERE c.name = 'NHL' AND s.name = '2023-2024' AND cs.phase = 'Playoffs'

UNION ALL SELECT cs.competition_season_id, '2024-06-08', '23:30:00', ht.team_id, at.team_id, v.venue_id, 'played', 4, 1
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Florida Panthers' JOIN team at ON at.name = 'Edmonton Oilers' JOIN venue v ON v.name = 'Amerant Bank Arena'
WHERE c.name = 'NHL' AND s.name = '2023-2024' AND cs.phase = 'Stanley Cup Final'

-- NFL Games
UNION ALL SELECT cs.competition_season_id, '2024-09-12', '00:20:00', ht.team_id, at.team_id, v.venue_id, 'played', 27, 24
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Kansas City Chiefs' JOIN team at ON at.name = 'Baltimore Ravens' JOIN venue v ON v.name = 'Arrowhead Stadium'
WHERE c.name = 'NFL' AND s.name = '2023-2024' AND cs.phase = 'Regular Season'

UNION ALL SELECT cs.competition_season_id, '2024-12-25', '00:15:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', 0, 0
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Green Bay Packers' JOIN team at ON at.name = 'San Francisco 49ers' JOIN venue v ON v.name = 'Lambeau Field'
WHERE c.name = 'NFL' AND s.name = '2023-2024' AND cs.phase = 'Regular Season'

-- Tennis Matches
UNION ALL SELECT cs.competition_season_id, '2024-07-14', '13:00:00', ht.team_id, at.team_id, v.venue_id, 'played', NULL, NULL
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Carlos Alcaraz' JOIN team at ON at.name = 'Novak Djokovic' JOIN venue v ON v.name = 'Centre Court'
WHERE c.name = 'Wimbledon' AND s.name = '2023-2024' AND cs.phase = 'Final'

UNION ALL SELECT cs.competition_season_id, '2024-09-08', '19:00:00', ht.team_id, at.team_id, v.venue_id, 'played', NULL, NULL
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Coco Gauff' JOIN team at ON at.name = 'Aryna Sabalenka' JOIN venue v ON v.name = 'Arthur Ashe Stadium'
WHERE c.name = 'US Open' AND s.name = '2023-2024' AND cs.phase = 'Final'

UNION ALL SELECT cs.competition_season_id, '2025-01-26', '08:00:00', ht.team_id, at.team_id, v.venue_id, 'scheduled', NULL, NULL
FROM competition_season cs JOIN competition c ON c.competition_id = cs.competition_id JOIN season s ON s.season_id = cs.season_id
JOIN team ht ON ht.name = 'Jannik Sinner' JOIN team at ON at.name = 'Daniil Medvedev' JOIN venue v ON v.name = 'Rod Laver Arena'
WHERE c.name = 'Australian Open' AND s.name = '2024-2025' AND cs.phase = 'Final';

-- Step 9: Insert team_competition relationships
INSERT IGNORE INTO team_competition (team_id, competition_season_id)
SELECT DISTINCT t.team_id, cs.competition_season_id
FROM team t
CROSS JOIN competition_season cs
JOIN competition c ON c.competition_id = cs.competition_id
WHERE (c.name IN ('Premier League', 'La Liga', 'Serie A', 'Ligue 1') AND t.country IN ('ENG', 'ESP', 'ITA', 'FRA', 'MON'))
   OR (c.name = 'UEFA Champions League' AND t.name IN ('Real Madrid', 'Manchester City', 'Bayern Munich', 'Arsenal', 'PSG', 'Borussia Dortmund', 'Inter Milan', 'AC Milan', 'Barcelona', 'Chelsea', 'Liverpool', 'Manchester United', 'Juventus', 'Napoli', 'Atletico Madrid', 'Sevilla', 'Real Betis', 'Tottenham Hotspur', 'Fulham', 'Everton', 'Monaco'))
   OR (c.name = 'UEFA Europa League' AND t.name IN ('Sevilla', 'Atletico Madrid', 'Real Betis', 'Roma'))
   OR (c.name = 'NBA' AND t.country IN ('USA', 'CAN'))
   OR (c.name = 'NBA Playoffs' AND t.name IN ('Oklahoma City Thunder', 'Boston Celtics', 'New York Knicks', 'Indiana Pacers', 'Memphis Grizzlies', 'Miami Heat', 'Cleveland Cavaliers', 'New Orleans Pelicans', 'Milwaukee Bucks', 'Atlanta Hawks', 'Philadelphia 76ers', 'Minnesota Timberwolves', 'Phoenix Suns', 'Golden State Warriors', 'Dallas Mavericks', 'Denver Nuggets', 'Houston Rockets', 'LA Lakers', 'Detroit Pistons', 'Orlando Magic', 'Utah Jazz', 'LA Clippers', 'Toronto Raptors', 'Brooklyn Nets', 'Sacramento Kings'))
   OR (c.name = 'NHL' AND t.name IN ('Edmonton Oilers', 'Vancouver Canucks', 'Florida Panthers'))
   OR (c.name = 'NFL' AND t.name IN ('Kansas City Chiefs', 'Baltimore Ravens', 'Green Bay Packers', 'San Francisco 49ers'))
   OR (c.name IN ('Wimbledon', 'US Open', 'Australian Open') AND t.name IN ('Carlos Alcaraz', 'Novak Djokovic', 'Coco Gauff', 'Aryna Sabalenka', 'Jannik Sinner', 'Daniil Medvedev'));

-- Step 10: Final verification and summary
SELECT 'COMPREHENSIVE SPORTS DATA POPULATION COMPLETE' as status;

-- Show comprehensive data summary
SELECT 
    s.name as sport,
    COUNT(DISTINCT c.name) as competition_count,
    COUNT(DISTINCT t.name) as team_count,
    COUNT(DISTINCT e.event_id) as event_count,
    SUM(CASE WHEN e.status = 'played' THEN 1 ELSE 0 END) as played_events,
    SUM(CASE WHEN e.status = 'scheduled' THEN 1 ELSE 0 END) as scheduled_events,
    SUM(CASE WHEN e.status = 'in progress' THEN 1 ELSE 0 END) as in_progress_events
FROM sport s
LEFT JOIN competition c ON s.sport_id = c.sport_id
LEFT JOIN team t ON s.sport_id = s.sport_id
LEFT JOIN event e ON s.sport_id = s.sport_id
GROUP BY s.name
ORDER BY s.name;

-- Show sample events from each sport
SELECT 
    s.name as sport,
    c.name as competition,
    cs.phase,
    e.event_date,
    ht.name as home_team,
    at.name as away_team,
    e.home_score,
    e.away_score,
    e.status,
    v.name as venue
FROM event e
JOIN competition_season cs ON e.competition_season_id = cs.competition_season_id
JOIN competition c ON cs.competition_id = c.competition_id
JOIN sport s ON c.sport_id = s.sport_id
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
LEFT JOIN venue v ON e.venue_id = v.venue_id
ORDER BY e.event_date, e.start_time
LIMIT 50;
