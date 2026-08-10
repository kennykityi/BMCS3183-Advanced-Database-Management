DROP INDEX idx_rental_shopid;
CREATE INDEX idx_rental_shopid ON RentalCollection(ShopID);

SET PAGESIZE 50
SET LINESIZE 120

TTITLE CENTER 'Staff Rent Collecting Ranking' SKIP 2

COLUMN StaffID FORMAT A9
COLUMN FullName FORMAT A20
COLUMN "Dominant Shop Type" FORMAT A50
COLUMN TotalCollections FORMAT 99
COLUMN CollectionRank FORMAT 9

CREATE OR REPLACE VIEW StaffRentCollectingView AS
WITH ShopTypeRanking AS (
    SELECT 
        S.StaffID,
        S.FullName,
        SH.ShopType,
        COUNT(SH.ShopType) AS CollectionCount,
        RANK() OVER (
            PARTITION BY S.StaffID 
            ORDER BY COUNT(*) DESC
        ) AS ShopTypeRank
    FROM Staff S
    LEFT JOIN RentalCollection RC ON S.StaffID = RC.StaffID
    LEFT JOIN Shop SH ON RC.ShopID = SH.ShopID
    GROUP BY S.StaffID, S.FullName, SH.ShopType
),
DominantShopTypes AS (
    SELECT 
        StaffID,
        FullName,
        LISTAGG(ShopType, ', ') WITHIN GROUP (ORDER BY ShopType) AS DominantShopTypes
    FROM ShopTypeRanking
    WHERE ShopTypeRank = 1
    GROUP BY StaffID, FullName
),
TotalCollections AS (
    SELECT 
        S.StaffID,
        COUNT(RC.ShopID) AS TotalCollections,
        RANK() OVER (
            ORDER BY COUNT(*) DESC
        ) AS CollectionRank
    FROM Staff S
    LEFT JOIN RentalCollection RC ON S.StaffID = RC.StaffID
    GROUP BY S.StaffID
)
SELECT 
    DST.StaffID,
    DST.FullName,
    DST.DominantShopTypes AS "Dominant Shop Type",
    TC.TotalCollections,
    TC.CollectionRank AS "Staff Collection Rank"
FROM DominantShopTypes DST
JOIN TotalCollections TC ON DST.StaffID = TC.StaffID
ORDER BY TC.CollectionRank;

SELECT * FROM StaffRentCollectingView;

CLEAR COLUMNS
TTITLE OFF
