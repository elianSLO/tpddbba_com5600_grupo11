-- SCRIPT DE IMPORTACION DE DATOS --
-- Comision 5600 - Grupo 11
-- Fecha: 12/06/2025
-- Integrantes: 

Use Com5600G11
-----------------------------------------------------------------------------------------------------------------------
--Crear el Schema de impotacion
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
	BEGIN
		EXEC('CREATE SCHEMA imp');
		PRINT ' Schema creado exitosamente';
	END;
go

EXEC sp_configure 'show advanced options', 1;  
RECONFIGURE;  
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;  
RECONFIGURE;  

EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;

exec imp.Importar_Pagos 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';

SELECT servicename, service_account 
FROM sys.dm_server_services;

select * from psn.Pago
delete from psn.Pago
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Pagos') 
BEGIN
    DROP PROCEDURE imp.Importar_Pagos;
    PRINT 'SP Importar_Pagos ya existe --> se borró';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Pagos
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        cod_pago BIGINT,
        fecha_pago DATE,
        responsable_pago VARCHAR(15),
        monto DECIMAL(10,2),
        medio_pago VARCHAR(15)
    );

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    INSERT INTO ##Temp (cod_pago, fecha_pago, responsable_pago, monto, medio_pago)
    SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
        ''SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago] FROM [pago cuotas$]''
    )';

    EXEC sp_executesql @SQL;
    PRINT 'Datos cargados en ##Temp.';

    DECLARE @cod_pago BIGINT,
            @fecha_pago DATE,
            @responsable_pago VARCHAR(15),
            @monto DECIMAL(10,2),
            @medio_pago VARCHAR(15);

    DECLARE cur CURSOR LOCAL FOR
    SELECT cod_pago, fecha_pago, responsable_pago, monto, medio_pago
    FROM ##Temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable_pago, @monto, @medio_pago;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Solo insertar si no existe
        IF NOT EXISTS (SELECT 1 FROM psn.Pago p WHERE p.cod_pago = @cod_pago)
        BEGIN
            EXEC stp.insertarPago 
                @monto = @monto,
                @fecha_pago = @fecha_pago,
                @estado = 'Pagado',  -- o 'REALIZADO' si quieres, pero stp espera 'Pagado', 'Pendiente' o 'Anulado'
                @responsable_pago = @responsable_pago;
        END

        FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable_pago, @monto, @medio_pago;
    END

    CLOSE cur;
    DEALLOCATE cur;

    DROP TABLE ##Temp;
    PRINT '##Temp eliminada.';
    PRINT 'Importación completada correctamente.';
END;
GO

