-- Fix duplicate events issue (safe mode compatible)
USE multiplesportdatabase_schema;

-- Step 1: Identify duplicate events
SELECT 
    e.event_date,
    e.start_time,
    ht.name as home_team,
    at.name as away_team,
    COUNT(*) as duplicate_count,
    GROUP_CONCAT(e.event_id) as event_ids
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
GROUP BY e.event_date, e.start_time, ht.name, at.name
HAVING COUNT(*) > 1;

-- Step 2: Create backup
CREATE TABLE IF NOT EXISTS event_backup AS SELECT * FROM event;

-- Step 3: Find which events to keep (lowest event_id for each duplicate group)
CREATE TEMPORARY TABLE events_to_keep AS
SELECT MIN(event_id) as event_id_to_keep
FROM event
GROUP BY event_date, start_time, home_team_id, away_team_id;

-- Step 4: Create temporary table with events to delete
CREATE TEMPORARY TABLE events_to_delete AS
SELECT e.event_id
FROM event e
WHERE e.event_id NOT IN (SELECT event_id_to_keep FROM events_to_keep);

-- Step 5: Check what we're about to delete
SELECT 
    'Events to be deleted' as check_type,
    e.event_id,
    e.event_date,
    e.start_time,
    ht.name as home_team,
    at.name as away_team
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
WHERE e.event_id IN (SELECT event_id FROM events_to_delete)
ORDER BY e.event_date, e.start_time;

-- Step 6: Delete duplicates using primary key (safe mode compatible)
DELETE FROM event 
WHERE event_id IN (SELECT event_id FROM events_to_delete);

-- Step 7: Verify cleanup
SELECT 
    'After cleanup - checking for duplicates' as check_type,
    e.event_date,
    e.start_time,
    ht.name as home_team,
    at.name as away_team,
    COUNT(*) as duplicate_count
FROM event e
JOIN team ht ON e.home_team_id = ht.team_id
JOIN team at ON e.away_team_id = at.team_id
GROUP BY e.event_date, e.start_time, ht.name, at.name
HAVING COUNT(*) > 1;

-- Step 8: Show final event list
SELECT 
    'Final event list' AS check_type,
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

-- Step 9: Clean up temp tables
DROP TEMPORARY TABLE events_to_keep;
DROP TEMPORARY TABLE events_to_delete;
