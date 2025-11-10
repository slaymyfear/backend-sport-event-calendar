-- Create and select database
CREATE DATABASE IF NOT EXISTS multiplesportdatabase_schema;
USE multiplesportdatabase_schema;

-- ------------------------------------------------------------
-- 1) sport
-- ------------------------------------------------------------
CREATE TABLE sport (
  sport_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- 2) team
-- ------------------------------------------------------------
CREATE TABLE team (
  team_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  logo_url VARCHAR(500),
  city VARCHAR(100),
  country VARCHAR(100),
  founded_year INT,

  -- ✅ Additions
  official_name VARCHAR(200),
  abbreviation VARCHAR(20),
  slug VARCHAR(200),

  CONSTRAINT uq_team UNIQUE (name, city, country)
);

-- ------------------------------------------------------------
-- 3) ruleset
-- ------------------------------------------------------------
CREATE TABLE ruleset (
  ruleset_id INT AUTO_INCREMENT PRIMARY KEY,
  sport_id INT NOT NULL,
  num_periods INT,
  period_duration_min INT,
  overtime_allowed BOOLEAN DEFAULT FALSE,
  scoring_rules JSON,
  CONSTRAINT _ruleset_sport_id_fk FOREIGN KEY (sport_id) REFERENCES sport(sport_id)
);

-- ------------------------------------------------------------
-- 4) competition
-- ------------------------------------------------------------
CREATE TABLE competition (
  competition_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  sport_id INT NOT NULL,
  description TEXT,
  CONSTRAINT _competition_sport_id_fk FOREIGN KEY (sport_id) REFERENCES sport(sport_id),
  CONSTRAINT uq_competition UNIQUE (name, sport_id)
);

-- ------------------------------------------------------------
-- 5) season
-- ------------------------------------------------------------
CREATE TABLE season (
  season_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  start_date DATE,
  end_date DATE,
  CONSTRAINT chk_season_dates CHECK (start_date < end_date)
);

-- ------------------------------------------------------------
-- 6) competition_season
-- ------------------------------------------------------------
CREATE TABLE competition_season (
  competition_season_id INT AUTO_INCREMENT PRIMARY KEY,
  competition_id INT NOT NULL,
  season_id INT NOT NULL,
  phase VARCHAR(100) NOT NULL,
  ruleset_id INT,

  -- ✅ Added for stage ordering support
  stage_ordering INT,

  CONSTRAINT _competition_season_competition_id_fk 
    FOREIGN KEY (competition_id) REFERENCES competition(competition_id) ON DELETE CASCADE,

  CONSTRAINT _competition_season_season_id_fk 
    FOREIGN KEY (season_id) REFERENCES season(season_id) ON DELETE CASCADE,

  CONSTRAINT _competition_season_ruleset_id_fk 
    FOREIGN KEY (ruleset_id) REFERENCES ruleset(ruleset_id) ON DELETE SET NULL,

  CONSTRAINT uq_cs UNIQUE (competition_id, season_id, phase)
);

-- ------------------------------------------------------------
-- 7) coach
-- ------------------------------------------------------------
CREATE TABLE coach (
  coach_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  nationality VARCHAR(100),
  age INT,
  team_id INT,
  sport_id INT NOT NULL,
  matches_coached INT DEFAULT 0,
  wins INT DEFAULT 0,
  losses INT DEFAULT 0,
  draws INT DEFAULT 0,
  performance JSON,
  CONSTRAINT _coach_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE SET NULL,
  CONSTRAINT _coach_sport_id_fk FOREIGN KEY (sport_id) REFERENCES sport(sport_id)
);

-- ------------------------------------------------------------
-- 8) position
-- ------------------------------------------------------------
CREATE TABLE `position` (
  position_id INT AUTO_INCREMENT PRIMARY KEY,
  sport_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  description TEXT,
  CONSTRAINT _position_sport_id_fk FOREIGN KEY (sport_id) REFERENCES sport(sport_id),
  CONSTRAINT uq_position UNIQUE (sport_id, name)
);

-- ------------------------------------------------------------
-- 9) player
-- ------------------------------------------------------------
CREATE TABLE player (
  player_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  birth_date DATE,
  position_id INT,
  team_id INT,
  nationality VARCHAR(100),
  CONSTRAINT _player_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE SET NULL,
  CONSTRAINT _player_position_id_fk FOREIGN KEY (position_id) REFERENCES `position`(position_id) ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 10) venue
-- ------------------------------------------------------------
CREATE TABLE venue (
  venue_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  city VARCHAR(100),
  country VARCHAR(100),
  capacity INT,
  CONSTRAINT uq_venue UNIQUE (name, city, country)
);

-- ------------------------------------------------------------
-- 11) team_competition
-- ------------------------------------------------------------
CREATE TABLE team_competition (
  team_competition_id INT AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  competition_season_id INT NOT NULL,
  CONSTRAINT _team_competition_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE,
  CONSTRAINT _team_competition_competition_season_id_fk FOREIGN KEY (competition_season_id) REFERENCES competition_season(competition_season_id) ON DELETE CASCADE,
  CONSTRAINT uq_team_comp UNIQUE (team_id, competition_season_id)
);

-- ------------------------------------------------------------
-- 12) event
-- ------------------------------------------------------------
CREATE TABLE event (
  event_id INT AUTO_INCREMENT PRIMARY KEY,
  competition_season_id INT NOT NULL,
  event_date DATE NOT NULL,
  start_time TIME,
  home_team_id INT NOT NULL,
  away_team_id INT NOT NULL,
  venue_id INT,
  status VARCHAR(50) DEFAULT 'scheduled',

  -- ✅ Generic scoring summary
  home_score INT,
  away_score INT,
  winner_name VARCHAR(200),

  CONSTRAINT chk_event_teams CHECK (home_team_id <> away_team_id),

  CONSTRAINT _event_competition_season_id_fk 
    FOREIGN KEY (competition_season_id) REFERENCES competition_season(competition_season_id) ON DELETE CASCADE,

  CONSTRAINT _event_home_team_id_fk FOREIGN KEY (home_team_id) REFERENCES team(team_id),

  CONSTRAINT _event_away_team_id_fk FOREIGN KEY (away_team_id) REFERENCES team(team_id),

  CONSTRAINT _event_venue_id_fk FOREIGN KEY (venue_id) REFERENCES venue(venue_id)
);

-- ------------------------------------------------------------
-- ✅ NEW — event_card (works for football and other sports)
-- ------------------------------------------------------------
CREATE TABLE event_card (
  card_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  player_id INT,
  team_id INT,
  card_type ENUM('yellow','second_yellow','red') NOT NULL,
  timestamp DATETIME,
  CONSTRAINT _ec_event_fk FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
  CONSTRAINT _ec_player_fk FOREIGN KEY (player_id) REFERENCES player(player_id),
  CONSTRAINT _ec_team_fk FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- ------------------------------------------------------------
-- 13) period
-- ------------------------------------------------------------
CREATE TABLE period (
  period_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  ruleset_id INT,
  period_number INT NOT NULL,
  start_timestamp DATETIME,
  end_timestamp DATETIME,
  home_score INT DEFAULT 0,
  away_score INT DEFAULT 0,
  CONSTRAINT _period_event_id_fk FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
  CONSTRAINT _period_ruleset_id_fk FOREIGN KEY (ruleset_id) REFERENCES ruleset(ruleset_id)
);

-- ------------------------------------------------------------
-- 14) event_lineup
-- ------------------------------------------------------------
CREATE TABLE event_lineup (
  event_lineup_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  team_id INT NOT NULL,
  lineup_type VARCHAR(50),
  formation VARCHAR(50),
  submitted_at DATETIME,
  CONSTRAINT _event_lineup_event_id_fk FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
  CONSTRAINT _event_lineup_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id),
  CONSTRAINT uq_lineup UNIQUE (event_id, team_id, lineup_type)
);

-- ------------------------------------------------------------
-- 15) lineup_player
-- ------------------------------------------------------------
CREATE TABLE lineup_player (
  lineup_player_id INT AUTO_INCREMENT PRIMARY KEY,
  event_lineup_id INT NOT NULL,
  player_id INT NOT NULL,
  position_id INT,
  is_starting BOOLEAN DEFAULT FALSE,
  shirt_number INT,
  CONSTRAINT _lineup_player_event_lineup_id_fk FOREIGN KEY (event_lineup_id) REFERENCES event_lineup(event_lineup_id) ON DELETE CASCADE,
  CONSTRAINT _lineup_player_player_id_fk FOREIGN KEY (player_id) REFERENCES player(player_id),
  CONSTRAINT _lineup_player_position_id_fk FOREIGN KEY (position_id) REFERENCES `position`(position_id)
);

-- ------------------------------------------------------------
-- 16) score_type
-- ------------------------------------------------------------
CREATE TABLE score_type (
  score_type_id INT AUTO_INCREMENT PRIMARY KEY,
  sport_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  points_value DECIMAL(6,2) NOT NULL DEFAULT 1,
  description TEXT,
  CONSTRAINT _score_type_sport_id_fk FOREIGN KEY (sport_id) REFERENCES sport(sport_id),
  CONSTRAINT uq_scoretype UNIQUE (sport_id, name)
);

-- ------------------------------------------------------------
-- 17) score
-- ------------------------------------------------------------
CREATE TABLE score (
  score_id INT AUTO_INCREMENT PRIMARY KEY,
  event_id INT NOT NULL,
  team_id INT NOT NULL,
  player_id INT,
  score_type_id INT NOT NULL,
  period_id INT,
  timestamp DATETIME,
  CONSTRAINT _score_event_id_fk FOREIGN KEY (event_id) REFERENCES event(event_id) ON DELETE CASCADE,
  CONSTRAINT _score_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id),
  CONSTRAINT _score_player_id_fk FOREIGN KEY (player_id) REFERENCES player(player_id),
  CONSTRAINT _score_score_type_id_fk FOREIGN KEY (score_type_id) REFERENCES score_type(score_type_id),
  CONSTRAINT _score_period_id_fk FOREIGN KEY (period_id) REFERENCES period(period_id)
);

-- ------------------------------------------------------------
-- 18) player_event_stats
-- ------------------------------------------------------------
CREATE TABLE player_event_stats (
  stat_id INT AUTO_INCREMENT PRIMARY KEY,
  player_id INT NOT NULL,
  event_id INT NOT NULL,
  minutes_played INT,
  goals INT DEFAULT 0,
  points INT DEFAULT 0,
  assists INT DEFAULT 0,
  rebounds INT DEFAULT 0,
  saves INT DEFAULT 0,
  aces INT DEFAULT 0,
  metrics JSON,
  CONSTRAINT _player_event_stats_player_id_fk FOREIGN KEY (player_id) REFERENCES player(player_id),
  CONSTRAINT _player_event_stats_event_id_fk FOREIGN KEY (event_id) REFERENCES event(event_id),
  CONSTRAINT uq_pes UNIQUE (player_id, event_id)
);

-- ------------------------------------------------------------
-- 19) player_season_stats
-- ------------------------------------------------------------
CREATE TABLE player_season_stats (
  stat_id INT AUTO_INCREMENT PRIMARY KEY,
  player_id INT NOT NULL,
  competition_season_id INT NOT NULL,
  games_played INT DEFAULT 0,
  goals INT DEFAULT 0,
  points INT DEFAULT 0,
  assists INT DEFAULT 0,
  rebounds INT DEFAULT 0,
  saves INT DEFAULT 0,
  aces INT DEFAULT 0,
  metrics JSON,
  CONSTRAINT _player_season_stats_player_id_fk FOREIGN KEY (player_id) REFERENCES player(player_id),
  CONSTRAINT _player_season_stats_competition_season_id_fk FOREIGN KEY (competition_season_id) REFERENCES competition_season(competition_season_id),
  CONSTRAINT uq_pss UNIQUE (player_id, competition_season_id)
);

-- ------------------------------------------------------------
-- 20) team_season_stats
-- ------------------------------------------------------------
CREATE TABLE team_season_stats (
  stat_id INT AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  competition_season_id INT NOT NULL,
  total_players INT,
  avg_player_age DECIMAL(5,2),
  metrics JSON,
  CONSTRAINT _team_season_stats_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id),
  CONSTRAINT _team_season_stats_competition_season_id_fk FOREIGN KEY (competition_season_id) REFERENCES competition_season(competition_season_id),
  CONSTRAINT uq_tss UNIQUE (team_id, competition_season_id)
);

-- ------------------------------------------------------------
-- 21) team_form
-- ------------------------------------------------------------
CREATE TABLE team_form (
  team_form_id INT AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  competition_season_id INT NOT NULL,
  last_n_games INT,
  wins INT DEFAULT 0,
  draws INT DEFAULT 0,
  losses INT DEFAULT 0,
  form_string VARCHAR(255),

  CONSTRAINT _team_form_team_id_fk 
    FOREIGN KEY (team_id) REFERENCES team(team_id),

  CONSTRAINT _team_form_competition_season_id_fk 
    FOREIGN KEY (competition_season_id) REFERENCES competition_season(competition_season_id),

  CONSTRAINT uq_team_form UNIQUE (team_id, competition_season_id, last_n_games)
);

-- ------------------------------------------------------------
-- 22) player_team_history
-- ------------------------------------------------------------
CREATE TABLE player_team_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  player_id INT NOT NULL,
  team_id INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE,
  transfer_type VARCHAR(50),
  fee_currency VARCHAR(10),
  fee_amount DECIMAL(12,2),
  CONSTRAINT _player_team_history_player_id_fk FOREIGN KEY (player_id) REFERENCES player(player_id),
  CONSTRAINT _player_team_history_team_id_fk FOREIGN KEY (team_id) REFERENCES team(team_id),
  CONSTRAINT chk_pth_dates CHECK (to_date IS NULL OR to_date >= from_date)
);

-- ------------------------------------------------------------
-- Indexes
-- ------------------------------------------------------------
CREATE INDEX idx_event_date ON event(event_date);
CREATE INDEX idx_player_team ON player(team_id);
CREATE INDEX idx_player_position ON player(position_id);
CREATE INDEX idx_lineup_player_position ON lineup_player(position_id);
