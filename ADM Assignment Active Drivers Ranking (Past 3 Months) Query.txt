DROP INDEX idx_schedule_date;
CREATE INDEX idx_schedule_date ON Schedule(ScheduleDate);

SET PAGESIZE 50
SET LINESIZE 100

TTITLE CENTER 'Active Drivers Ranking (Past 3 Months)' SKIP 2

COLUMN "Driver ID" FORMAT A20
COLUMN "Driver Name" FORMAT A50
COLUMN "Total Schedules" FORMAT 999
COLUMN Ranking FORMAT 999

CREATE OR REPLACE VIEW DriversActiveRankingView AS
SELECT D.DriverID AS "Driver ID", 
       D.FullName AS "Driver Name", 
       COUNT(S.ScheduleID) AS "Total Schedules", 
       RANK() OVER (ORDER BY COUNT(S.ScheduleID) DESC) AS Ranking
FROM Driver D
LEFT JOIN DriverAllocation DA ON D.DriverID = DA.DriverID
LEFT JOIN Schedule S ON DA.ScheduleID = S.ScheduleID
AND S.ScheduleDate >= ADD_MONTHS(SYSDATE, -3)
GROUP BY D.DriverID, D.FullName;

SELECT * FROM DriversActiveRankingView;

CLEAR COLUMNS
TTITLE OFF
