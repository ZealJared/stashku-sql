SELECT 
    isc.TABLE_CATALOG AS [catalog],
    isc.TABLE_SCHEMA AS [schema],
    isc.TABLE_NAME AS [name],
    isc.COLUMN_NAME AS [property],
    CAST(ISNULL(con.Keyed, 0) AS BIT) AS keyed,
    isc.ORDINAL_POSITION AS position,
    CAST((CASE
        WHEN isc.IS_NULLABLE LIKE 'Y%' THEN 1
        ELSE 0
    END) AS BIT) AS nullable,
    CAST((CASE
        WHEN isc.COLUMN_DEFAULT IS NOT NULL THEN 1
        ELSE 0
    END) AS BIT) AS hasDefault,
    UPPER(isc.DATA_TYPE) AS dataType,
    isc.CHARACTER_MAXIMUM_LENGTH AS charLength,
    isc.NUMERIC_PRECISION AS numberPrecision,
    isc.NUMERIC_PRECISION_RADIX AS numberRadix
    FROM INFORMATION_SCHEMA.COLUMNS isc
        OUTER APPLY (
            SELECT TOP 1 (1) AS Keyed
                FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                     INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON 
                        kcu.CONSTRAINT_CATALOG = tc.CONSTRAINT_CATALOG 
                        AND kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA 
                        AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME 
                        AND kcu.TABLE_CATALOG = isc.TABLE_CATALOG 
                        AND kcu.TABLE_SCHEMA = isc.TABLE_SCHEMA 
                        AND kcu.TABLE_NAME = isc.TABLE_NAME 
                        AND kcu.COLUMN_NAME = isc.COLUMN_NAME
                WHERE 
                    tc.CONSTRAINT_TYPE IN ('UNIQUE', 'FOREIGN KEY', 'PRIMARY KEY')
        ) con
    WHERE
        UPPER(isc.TABLE_NAME) = UPPER(@resource)
        OR UPPER(isc.TABLE_SCHEMA + '.' + isc.TABLE_NAME) = UPPER(@resource)
        OR UPPER(isc.TABLE_CATALOG + '.' + isc.TABLE_SCHEMA + '.' + isc.TABLE_NAME) = UPPER(@resource)
    ORDER BY isc.TABLE_CATALOG, isc.TABLE_SCHEMA, isc.TABLE_NAME, isc.ORDINAL_POSITION;