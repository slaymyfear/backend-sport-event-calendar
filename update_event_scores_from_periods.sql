-- Update event scores from period table (run this after adding the columns)
USE multiplesportdatabase_schema;

-- Update events with scores aggregated from their periods
UPDATE event e
INNER JOIN (
    SELECT 
        event_id,
        SUM(home_score) as total_home_score,
        SUM(away_score) as total_away_score
    FROM period
    GROUP BY event_id
) p ON e.event_id = p.event_id
SET 
    e.home_score = p.total_home_score,
    e.away_score = p.total_away_score,
    e.status = 'played'
WHERE (e.home_score IS NULL OR e.away_score IS NULL)
AND e.event_id IN (SELECT event_id FROM period);
