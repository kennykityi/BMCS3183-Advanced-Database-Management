SET PAGESIZE 1000
SET LINESIZE 1200
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE prc_DriverScheduleReport IS

CURSOR driverCursor IS
SELECT Distinct D.DriverID, D.FullName, D.Email, D.ContactNo, BC.CompanyName
FROM Driver D 
JOIN Bus_Company BC
ON D.BusCompanyID = BC.BusCompanyID
JOIN DriverAllocation DA 
ON D.DriverID = DA.DriverID
JOIN Schedule S
ON S.ScheduleID = DA.ScheduleID
ORDER BY D.DriverID;

CURSOR scheduleCursor(v_driverID Driver.DriverID%TYPE) IS
SELECT DA.ScheduleID, S.ScheduleDate, TO_CHAR(S.DepartureTime, 'DD-MON-YYYY HH24:MI:SS') AS DepartureTime, TO_CHAR(S.ArrivalTime, 'DD-MON-YYYY HH24:MI:SS') AS ArrivalTime, S.Destination, DA.Shift
FROM Schedule S 
JOIN DriverAllocation DA 
ON S.ScheduleID = DA.ScheduleID
WHERE DA.DriverID = v_driverID;

driverList driverCursor%ROWTYPE;
scheduleList scheduleCursor%ROWTYPE;

BEGIN
OPEN driverCursor;
DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));
DBMS_OUTPUT.PUT_LINE(LPAD('-',55, '-') || RPAD('DRIVER SCHEDULE REPORT', 80, '-'));

DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));
LOOP
 	FETCH driverCursor into driverList;
 	EXIT WHEN driverCursor%NOTFOUND;

--Header

DBMS_OUTPUT.PUT_LINE('Driver ID: ' || driverList.DriverID);
DBMS_OUTPUT.PUT_LINE('Driver Name: ' || driverList.FullName);
DBMS_OUTPUT.PUT_LINE('Email: ' || driverList.Email);
DBMS_OUTPUT.PUT_LINE('Contact No: ' || driverList.ContactNo);
DBMS_OUTPUT.PUT_LINE('Company Name: ' || driverList.CompanyName);

--Heading
DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));
DBMS_OUTPUT.PUT_LINE (RPAD('Schedule ID',15,' ') || ' ' ||
                      RPAD('Schedule Date', 25, ' ') || ' ' ||
                      RPAD('Departure Time', 25, ' ') || ' ' ||
                      RPAD('Arrival Time', 25, ' ') || ' ' ||
 		      RPAD('Destination',25,' ') || ' ' ||
                      RPAD('Shift',15, ' '));
DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));

--Body
OPEN scheduleCursor(driverList.DriverID);
LOOP
 	FETCH scheduleCursor INTO scheduleList;
 	EXIT WHEN scheduleCursor%NOTFOUND;

 	DBMS_OUTPUT.PUT_LINE(RPAD(scheduleList.ScheduleID, 15,' ') || ' ' ||
                        RPAD(scheduleList.ScheduleDate, 25, ' ') || ' ' ||
                        RPAD(scheduleList.DepartureTime, 25,' ') || ' ' ||
                        RPAD(scheduleList.ArrivalTime, 25,' ') || ' '||
		        RPAD(scheduleList.Destination, 25,' ') || ' ' ||
                        RPAD(scheduleList.Shift, 15,' '));
END LOOP;

DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));
DBMS_OUTPUT.PUT_LINE('Total Number of Schedules: ' || scheduleCursor%ROWCOUNT);
DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));
DBMS_OUTPUT.PUT_LINE(CHR(10));

CLOSE scheduleCursor;

END LOOP;

--Footer
DBMS_OUTPUT.PUT_LINE('Total number of Drivers: ' || driverCursor%ROWCOUNT);
CLOSE driverCursor;
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE(LPAD('=',65, '=') || RPAD('END OF REPORT', 70, '='));

END;
/

EXEC prc_DriverScheduleReport
