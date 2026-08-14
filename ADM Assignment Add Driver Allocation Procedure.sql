CREATE OR REPLACE PROCEDURE prc_AddDriverAllocation (v_driverID IN Driver.DriverID%TYPE, v_scheduleID IN Schedule.ScheduleID%TYPE) IS
v_exists NUMBER;
MULTIPLE_ALLOCATION EXCEPTION;
PRAGMA EXCEPTION_INIT(MULTIPLE_ALLOCATION, -20000);

BEGIN
    SELECT COUNT(*)
    INTO v_exists
    FROM DriverAllocation DA
    JOIN Schedule S1 ON DA.ScheduleID = S1.ScheduleID
    JOIN Schedule S2 ON S2.ScheduleID = v_scheduleID
    WHERE DA.DriverID = v_driverID
    AND S1.ScheduleDate = S2.ScheduleDate;

    IF v_exists > 0 THEN
        RAISE MULTIPLE_ALLOCATION;
    ELSE
        INSERT INTO DriverAllocation (DriverID, ScheduleID) VALUES (v_driverID, v_scheduleID);
        DBMS_OUTPUT.PUT_LINE('Driver allocation added successfully.');
    END IF;

    EXCEPTION
    WHEN MULTIPLE_ALLOCATION THEN
        DBMS_OUTPUT.PUT_LINE('Driver ' || v_driverID || ' is already allocated on the same date as ' || v_scheduleID || '.');

END;
/
