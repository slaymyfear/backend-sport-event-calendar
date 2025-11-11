-- Fix scores issue: Add columns and populate from periods
USE multiplesportdatabase_schema;

-- Step 1: Add score columns to event table (run this even if columns might exist)
-- If columns already exist, you'll get an error - that's OK, just continue
ALTER TABLE event 
ADD COLUMN home_score INT NULL,
ADD COLUMN away_score INT NULL;

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

-- Step 3: Update event scores from periods
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

