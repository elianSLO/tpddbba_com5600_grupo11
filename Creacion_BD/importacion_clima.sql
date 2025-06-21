use Com5600G11;
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
BEGIN
    EXEC('CREATE SCHEMA imp');
END;
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Clima' AND SCHEMA_NAME(schema_id) = 'imp')
BEGIN
    DROP PROCEDURE imp.Importar_Clima;
END;
GO

CREATE PROCEDURE imp.Importar_Clima
    @RutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Carpeta NVARCHAR(500);
    DECLARE @Archivo NVARCHAR(255);
    DECLARE @SQL NVARCHAR(MAX);

    SET @Carpeta = LEFT(@RutaArchivo, LEN(@RutaArchivo) - CHARINDEX('\', REVERSE(@RutaArchivo)));
    SET @Archivo = RIGHT(@RutaArchivo, CHARINDEX('\', REVERSE(@RutaArchivo)) - 1);

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    SET @SQL = '
        SELECT * 
        INTO ##TempData
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Text;Database=' + @Carpeta + ';HDR=NO;IMEX=1;'',
            ''SELECT * FROM [' + @Archivo + ']''
        );
    ';

    EXEC(@SQL);

    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ClimaDiario' AND SCHEMA_NAME(schema_id) = 'imp')
    BEGIN
        CREATE TABLE imp.ClimaDiario (
            [time] DATE PRIMARY KEY,
            temperature_2m DECIMAL(6,1),
            rain DECIMAL(6,2),
            relative_humidity_2m DECIMAL(5,0),
            wind_speed_100m DECIMAL(6,1)
        );
    END

    INSERT INTO imp.ClimaDiario (time, temperature_2m, rain, relative_humidity_2m, wind_speed_100m)
    SELECT 
        CAST(SUBSTRING(F1, 1, 10) AS DATE) AS [time], 
        CAST(ROUND(AVG(F2) / 10.0, 1) AS DECIMAL(6,1)),
        CAST(ROUND(SUM(F3) / 100.0, 2) AS DECIMAL(6,2)),
        CAST(ROUND(AVG(F4), 0) AS DECIMAL(5,0)),
        CAST(ROUND(AVG(F5) / 10.0, 1) AS DECIMAL(6,1))
    FROM ##TempData AS T
    WHERE T.F1 IS NOT NULL
      AND T.F2 IS NOT NULL
      AND T.F3 IS NOT NULL
      AND T.F4 IS NOT NULL
      AND T.F5 IS NOT NULL
      AND TRY_CAST(SUBSTRING(T.F1, 1, 10) AS DATE) IS NOT NULL
      AND NOT EXISTS (
            SELECT 1
            FROM imp.ClimaDiario AS CD
            WHERE CD.[time] = TRY_CAST(SUBSTRING(T.F1, 1, 10) AS DATE)
        )
    GROUP BY SUBSTRING(F1, 1, 10)
    ORDER BY [time];

    DROP TABLE ##TempData;

END;
GO

--EXEC imp.Importar_Clima @RutaArchivo = N'C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\TPI-2025-1C\open-meteo-buenosaires_2025.csv';