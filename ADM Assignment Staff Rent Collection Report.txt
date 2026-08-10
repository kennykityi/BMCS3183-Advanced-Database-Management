SET PAGESIZE 1000
SET LINESIZE 1200
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE prc_StaffRentCollectionReport IS
v_grandTotal    RentalCollection.AmountCollected%TYPE;
v_totalValue    RentalCollection.AmountCollected%TYPE;

CURSOR staffCursor IS
SELECT Distinct StaffID, FullName, Position, Email, PhoneNo
FROM Staff
ORDER BY StaffID;

CURSOR shopCursor(v_staffID Staff.StaffID%TYPE) IS
SELECT SH.ShopID, SH.ShopName, SH.ShopType, SH.OwnerName, SUM(RC.AmountCollected) AS Total_Rent_Collected
FROM Shop SH 
JOIN RentalCollection RC 
ON SH.ShopID = RC.ShopID
WHERE RC.StaffID = v_staffID
GROUP BY SH.ShopID, SH.ShopName, SH.ShopType, SH.OwnerName
ORDER BY SH.ShopID;

staffList staffCursor%ROWTYPE;
shopList shopCursor%ROWTYPE;

BEGIN
OPEN staffCursor;
v_totalValue := 0;
DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));
DBMS_OUTPUT.PUT_LINE(LPAD('-',55, '-') || RPAD('STAFF RENTAL COLLECTION REPORT', 80, '-'));
DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));
LOOP
 	FETCH staffCursor into staffList;
 	EXIT WHEN staffCursor%NOTFOUND;

--Header
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('Staff ID: ' || staffList.StaffID);
DBMS_OUTPUT.PUT_LINE('Staff Name: ' || staffList.FullName);
DBMS_OUTPUT.PUT_LINE('Position: ' || staffList.Position);
DBMS_OUTPUT.PUT_LINE('Email: ' || staffList.Email);
DBMS_OUTPUT.PUT_LINE('Contact No: ' || staffList.PhoneNo);

--Heading
DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));
DBMS_OUTPUT.PUT_LINE (RPAD('Shop ID',15,' ') || ' ' ||
                      RPAD('Shop Name', 40, ' ') || ' ' ||
                      RPAD('Shop Type', 20, ' ') || ' ' ||
 		      RPAD('Owner Name',30,' ') || ' ' ||
                      RPAD('Amount Collected', 30, ' '));
DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));

--Body
OPEN shopCursor(staffList.StaffID);
v_grandTotal := 0;
LOOP
 	FETCH shopCursor INTO shopList;
 	EXIT WHEN shopCursor%NOTFOUND;

 	DBMS_OUTPUT.PUT_LINE(RPAD(shopList.ShopID, 15,' ') || ' ' ||
                        RPAD(shopList.ShopName, 40, ' ') || ' ' ||
                        RPAD(shopList.ShopType, 20,' ') || ' ' ||
                        RPAD(shopList.OwnerName, 30,' ') || ' '||
		        RPAD(shopList.Total_Rent_Collected, 30,' '));
 	v_grandTotal := v_grandTotal + shopList.Total_Rent_Collected;
END LOOP;

 	v_totalValue := v_totalValue + v_grandTotal;

DBMS_OUTPUT.PUT_LINE(LPAD('-', 135, '-'));
DBMS_OUTPUT.PUT_LINE('Total Rent Collected: ' || TO_CHAR(v_grandTotal, '$999,999,999.99'));
DBMS_OUTPUT.PUT_LINE('Total Number of Shops Collected: ' || shopCursor%ROWCOUNT);
DBMS_OUTPUT.PUT_LINE(LPAD('=', 135, '='));

CLOSE shopCursor;

END LOOP;

--Footer
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('Total amount of rent collected: ' || TO_CHAR(v_totalValue, '$99,999,999,999.99'));
DBMS_OUTPUT.PUT_LINE('Total number of staff: ' || staffCursor%ROWCOUNT);
CLOSE staffCursor;
DBMS_OUTPUT.PUT_LINE(LPAD('=',65, '=') || RPAD('END OF REPORT', 70, '='));

END;
/

EXEC prc_StaffRentCollectionReport
