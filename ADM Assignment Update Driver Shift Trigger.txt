CREATE OR REPLACE TRIGGER trg_UpdateDriverShift
BEFORE INSERT OR UPDATE ON DriverAllocation
FOR EACH ROW
DECLARE
    v_departureTime Schedule.DepartureTime%TYPE;
    v_time          NUMBER;
BEGIN
    SELECT DepartureTime INTO v_departureTime
    FROM Schedule
    WHERE ScheduleID = :NEW.ScheduleID;

    v_time := TO_NUMBER(TO_CHAR(v_departureTime, 'HH24MI'));

    IF v_time BETWEEN 500 AND 1159 THEN
        :NEW.Shift := 'Morning';
    ELSIF v_time BETWEEN 1200 AND 1659 THEN
        :NEW.Shift := 'Afternoon';
    ELSIF v_time BETWEEN 1700 AND 2059 THEN
        :NEW.Shift := 'Evening';
    ELSE
        :NEW.Shift := 'Night';
    END IF;

END;
/
