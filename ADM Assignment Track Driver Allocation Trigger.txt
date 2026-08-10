DROP SEQUENCE driverAllocation_audit_seq;

CREATE SEQUENCE driverAllocation_audit_seq
MINVALUE 1
MAXVALUE 99999
START WITH 1
INCREMENT BY 1
NOCACHE;

DROP TABLE ActionDriverAllocation;

CREATE TABLE ActionDriverAllocation(
AuditID                 NUMBER       NOT NULL,
DriverID	  	VARCHAR2(10) NOT NULL,
ScheduleID  		VARCHAR2(10) NOT NULL,
NewScheduleID  		VARCHAR2(10),
Shift 			VARCHAR2(10) NOT NULL,
NewShift		VARCHAR2(10),
UserID        		VARCHAR2(30),   
TransDate  		DATE,
TransTime 		CHAR(8),
TransAction 		VARCHAR2(6)
);

CREATE OR REPLACE TRIGGER trg_track_DriverAllocation
AFTER INSERT OR UPDATE OR DELETE ON DriverAllocation
FOR EACH ROW
BEGIN      	
  CASE
    WHEN INSERTING THEN
      INSERT INTO ActionDriverAllocation (
        AuditID, DriverID, ScheduleID, NewScheduleID,
        Shift, NewShift,
        UserID, TransDate, TransTime, TransAction
      ) VALUES (
        driverAllocation_audit_seq.NEXTVAL,
        :NEW.DriverID, :NEW.ScheduleID, NULL,
        :NEW.Shift, NULL,
        USER, SYSDATE, TO_CHAR(SYSDATE, 'HH24:MI:SS'), 'INSERT'
      );

    WHEN UPDATING THEN
      INSERT INTO ActionDriverAllocation (
        AuditID, DriverID, ScheduleID, NewScheduleID,
        Shift, NewShift,
        UserID, TransDate, TransTime, TransAction
      ) VALUES (
        driverAllocation_audit_seq.NEXTVAL,
        :OLD.DriverID, :OLD.ScheduleID, :NEW.ScheduleID,
        :OLD.Shift, :NEW.Shift,
        USER, SYSDATE, TO_CHAR(SYSDATE, 'HH24:MI:SS'), 'UPDATE'
      );

    WHEN DELETING THEN
      INSERT INTO ActionDriverAllocation (
        AuditID, DriverID, ScheduleID, NewScheduleID,
        Shift, NewShift,
        UserID, TransDate, TransTime, TransAction
      ) VALUES (
        driverAllocation_audit_seq.NEXTVAL,
        :OLD.DriverID, :OLD.ScheduleID, NULL,
        :OLD.Shift, NULL,
        USER, SYSDATE, TO_CHAR(SYSDATE, 'HH24:MI:SS'), 'DELETE'
      );
  END CASE;
END;
/
