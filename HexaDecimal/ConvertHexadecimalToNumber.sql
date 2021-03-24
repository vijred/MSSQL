-- Sample usage of function: SELECT * from dbo.HexStringToDecimal('0xC76E3460B3FDB42D')
-- Usecase: Attempted to generate Actual execution plan using Queryhash, this needs conversion from Hexadecimal to number where BIGINT is not suggicietnt, this works like a charm
-- NOTE: Attempt using this from SQL Server 2016 

-- 100% this is used from sgmunson comment @ https://www.sqlservercentral.com/forums/topic/how-can-convert-hex-value-to-decimal-in-sql-server-2012 
 

USE tempdb
GO

CREATE FUNCTION dbo.HexStringToDecimal (
    @VarBinChar varchar(22)
)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
WITH XREF AS ( SELECT '0' AS Chr, 0 AS Num UNION ALL
    SELECT '1', 1 UNION ALL
    SELECT '2', 2 UNION ALL
    SELECT '3', 3 UNION ALL
    SELECT '4', 4 UNION ALL
    SELECT '5', 5 UNION ALL
    SELECT '6', 6 UNION ALL
    SELECT '7', 7 UNION ALL
    SELECT '8', 8 UNION ALL
    SELECT '9', 9 UNION ALL
    SELECT 'A', 10 UNION ALL
    SELECT 'B', 11 UNION ALL
    SELECT 'C', 12 UNION ALL
    SELECT 'D', 13 UNION ALL
    SELECT 'E', 14 UNION ALL
    SELECT 'F', 15
),
    Numbers AS (

        SELECT 1 AS N UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1 UNION ALL
        SELECT 1
),
    Tally AS ( SELECT TOP (LEN(@VarBinChar)) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS CharPos
        FROM Numbers AS N1
            CROSS APPLY Numbers AS N2
)
SELECT
    @VarbinChar                                    AS VarBinChar,
    SUM(Y.NumValue)                                AS DecimalValue,
    FORMAT(SUM(Y.NumValue), '##,#', 'en-US')    AS StringRepresentation
FROM (
    SELECT TOP 100 PERCENT T.CharPos, C.TheChar, C.Multiplier, C.NumValue
    FROM Tally AS T
        CROSS APPLY (
            SELECT
                SUBSTRING(REVERSE(@VarBinChar), T.CharPos, 1)                AS TheChar,
                POWER(CONVERT(decimal(25,0), 16), (T.CharPos - 1))            AS Multiplier,
                POWER(CONVERT(decimal(25,0), 16), (T.CharPos - 1)) * X.Num    AS NumValue
            FROM XREF AS X
            WHERE X.Chr = SUBSTRING(REVERSE(@VarBinChar), T.CharPos, 1) 
            ) AS C
    ORDER BY T.CharPos ASC
    ) AS Y;
GO


SELECT * from dbo.HexStringToDecimal('0xC76E3460B3FDB42D')

