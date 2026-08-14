CREATE OR REPLACE PROCEDURE prc_AddRentCollection (
    v_shopID           IN RentalCollection.ShopID%TYPE,
    v_staffID          IN RentalCollection.StaffID%TYPE,
    v_amountCollected  IN RentalCollection.AmountCollected%TYPE,
    v_paymentMethod    IN RentalCollection.PaymentMethod%TYPE,
    v_notes            IN RentalCollection.Notes%TYPE DEFAULT '-'
) IS
v_shopExists   NUMBER;
v_staffExists  NUMBER;
v_maxNum       NUMBER;
v_newID        RentalCollection.CollectionID%TYPE;

BEGIN
    SELECT COUNT(*) INTO v_shopExists
    FROM Shop
    WHERE ShopID = v_shopID;

    IF v_shopExists = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Invalid Shop ID.');
    END IF;

    SELECT COUNT(*) INTO v_staffExists
    FROM Staff
    WHERE StaffID = v_staffID;

    IF v_staffExists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid Staff ID.');
    END IF;

    IF v_amountCollected <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Amount collected must be greater than 0.');
    END IF;

    SELECT NVL(MAX(TO_NUMBER(SUBSTR(CollectionID, 4))), 0)
    INTO v_maxNum
    FROM RentalCollection;

    v_newID := 'COL' || LPAD(v_maxNum + 1, 3, '0');


    INSERT INTO RentalCollection (CollectionID, ShopID, StaffID, CollectionDate, AmountCollected, PaymentMethod, Notes) VALUES (v_newID, v_shopID, v_staffID, SYSDATE, v_amountCollected, v_paymentMethod, v_notes);

    DBMS_OUTPUT.PUT_LINE('Rent collection added successfully in ' || v_newID || '.');

END;
/
