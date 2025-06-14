-- SCRIPT DE IMPORTACION DE DATOS --
-- Comision 5600 - Grupo 11
-- Fecha: 12/06/2025
-- Integrantes: 

Use Com5600G11
GO

EXEC sp_configure 'show advanced options', 1;			--	Habilito config. opciones avanzadas.
RECONFIGURE;  

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;		--	Permito usar OPENROWSET y otras consultas distribuidas.
RECONFIGURE;  
GO


EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;		--	Permito que el proveedor OLEDB (Microsoft.ACE.OLEDB.12.0) se ejecute dentro del proceso de SQL Server.
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;		--	Habilito el pasaje de parámetros a las consultas dinámicas.
GO

SELECT servicename, service_account			--Chequear nombre del servicio para  darle permiso de acceso a los directorios donde se guarda la información.
FROM sys.dm_server_services;

-----------------------------------------------------------------------------------------------------------------------
--	Crear el esquema de importacion.
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
	BEGIN
		EXEC('CREATE SCHEMA imp');
		PRINT ' Schema creado exitosamente';
	END;
GO



-----------------------------------------------------------------------------------------------------------------------
--	Importar pagos.
	exec imp.Importar_Pagos 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';

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

    -- Eliminar tabla temporal si existe
    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    -- Crear tabla temporal
    CREATE TABLE ##Temp
    (
        cod_pago BIGINT,
        fecha_pago DATE,
        responsable_pago VARCHAR(15),
        monto DECIMAL(10,2),
        medio_pago VARCHAR(15)
    );

    -- Armar SQL dinámico
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

    -- Recorrer ##Temp y llamar al SP
    DECLARE @cod_pago BIGINT,
            @fecha_pago DATE,
            @responsable_pago VARCHAR(15),
            @monto DECIMAL(10,2),
            @medio_pago VARCHAR(15);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT cod_pago, fecha_pago, responsable_pago, monto, medio_pago
    FROM ##Temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable_pago, @monto, @medio_pago;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Llamar al SP con reglas de negocio
        EXEC stp.insertarPago 
            @monto = @monto,
            @fecha_pago = @fecha_pago,
            @estado = 'Pagado',
            @responsable_pago = @responsable_pago;

        FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable_pago, @monto, @medio_pago;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Eliminar ##Temp
    DROP TABLE ##Temp;
    PRINT '##Temp eliminada.';
    PRINT 'Importación completada correctamente.';
END
GO



SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=YES;Database=D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',
    'SELECT * FROM [pago cuotas$]'
);



-- Importacion Tarifas

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Tarifas') 
BEGIN
    DROP PROCEDURE imp.Importar_Tarifas;
    PRINT 'SP Importar_Tarifas ya existe --> se borró';
END;
GO

CREATE OR ALTER PROCEDURE imp.ImportarTarifas
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal: Actividad

    IF OBJECT_ID('tempdb..##TempActividad') IS NOT NULL DROP TABLE ##TempActividad;

    CREATE TABLE ##TempActividad (
        nombre_actividad VARCHAR(50),
        valor_mensual DECIMAL(10,2),
        vig_valor DATE
    );

    -- Tabla temporal: Categoria
   
    IF OBJECT_ID('tempdb..##TempCategoria') IS NOT NULL DROP TABLE ##TempCategoria;

    CREATE TABLE ##TempCategoria (
        descripcion VARCHAR(50),
        valor_mensual DECIMAL(10,2),
        vig_valor_mens DATE
    );

    -- SQL dinámico: Actividad

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    INSERT INTO ##TempActividad (nombre_actividad, valor_mensual, vig_valor)
    SELECT [Actividad], [Valor por mes], CONVERT(DATE, [Vigente hasta], 103)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Hoja1$B2:D8]''
    );';
    EXEC(@SQL);
    PRINT 'Datos cargados en ##TempActividad.';

    -- SQL dinámico: Categoria
    
    SET @SQL = '
    INSERT INTO ##TempCategoria (descripcion, valor_mensual, vig_valor_mens)
    SELECT [Categoria socio], [Valor cuota], CONVERT(DATE, [Vigente hasta], 103)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Hoja1$B10:D13]''
    );';
    EXEC(@SQL);
    PRINT 'Datos cargados en ##TempCategoria.';

    -- Insertar en psn.Actividad -- USAR SP insertarActividad


    INSERT INTO psn.Actividad (nombre,valor_mensual,vig_valor)
    SELECT nombre_actividad, valor_mensual, vig_valor
    FROM ##TempActividad;

    -- Insertar en psn.Categoria -- USAR SP insertarCategoria
 
    INSERT INTO psn.Categoria (
        descripcion, edad_max, valor_mensual, vig_valor_mens,
        valor_anual, vig_valor_anual
    )
    SELECT descripcion, NULL, valor_mensual, vig_valor_mens, NULL, NULL
    FROM ##TempCategoria;

    -- Limpiar temporales

    DROP TABLE ##TempActividad;
    DROP TABLE ##TempCategoria;

    PRINT 'Importación de tarifas completada correctamente.';
END;
GO