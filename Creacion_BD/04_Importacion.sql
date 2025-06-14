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

--	Registro el origen de los datos.
EXEC sp_addlinkedserver 
    @server = 'LinkerServer_EXCEL',
    @srvproduct = 'ACE 12.0',
    @provider = 'Microsoft.ACE.OLEDB.12.0',
    @datasrc = 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',
    @provstr = 'Excel 12.0;HDR=NO';

EXEC sp_tables_ex 'LinkerServer_EXCEL';
GO
--EXEC sp_dropserver 'LinkerServer_EXCEL', 'droplogins';		-- Eliminar 



SELECT * 
FROM OPENQUERY(LinkerServer_EXCEL, 'SELECT TOP 1 * FROM [Responsables de Pago$]');
GO

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

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Pagos') 
BEGIN
    DROP PROCEDURE imp.Importar_Pagos;
    PRINT 'Importar_Pagos existía y fue borrado';
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

    -- Crear tabla temporal global
    CREATE TABLE ##Temp
    (
        cod_pago			BIGINT,
        fecha_pago			DATE,
        responsable_pago	VARCHAR(15),
        monto				DECIMAL(10,2),
        medio_pago			VARCHAR(15)
    );

    -- Armar SQL dinámico
    DECLARE @SQL NVARCHAR(MAX);

	SET @SQL = '
		INSERT INTO ##Temp
		SELECT * FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
			''SELECT * FROM [pago cuotas$]''
		);
	';

    EXEC sp_executesql @SQL;
    PRINT 'Datos cargados en ##Temp.';

    -- Recorrer ##Temp y llamar al SP
    DECLARE @cod_pago			BIGINT,
            @fecha_pago			DATE,
            @responsable_pago	VARCHAR(15),
            @monto				DECIMAL(10,2),
            @medio_pago			VARCHAR(15);

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

--delete from psn.Pago
exec imp.Importar_Pagos 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';
select * from psn.Pago
GO
-----------------------------------------------------------------------------------------------------------------------

SELECT * FROM OPENQUERY(LinkerServer_EXCEL, 
	'SELECT TOP 1 * FROM [Responsables de Pago$]')





-----------------------------------------------------------------------------------------------------------------------
--	Importar Socios.
	exec imp.Importar_Socios --'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';
	select * from psn.Socio
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Socios') 
BEGIN
    DROP PROCEDURE imp.Importar_Socios;
    PRINT 'Importar_Socios existía y fue borrado';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Socios
    --@RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        cod_socio            VARCHAR(100),
        nombre               VARCHAR(100),
        apellido             VARCHAR(100),
        dni                  VARCHAR(100),
        email                VARCHAR(100),
        fecha_nac            VARCHAR(100),
        tel                  VARCHAR(100),
        tel_emerg            VARCHAR(100),
        nombre_cobertura     VARCHAR(100),
        nro_afiliado         VARCHAR(100),
        tel_cobertura        VARCHAR(100)
    );

    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
		INSERT INTO ##Temp (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura)
		SELECT F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11
		FROM OPENQUERY(LinkerServer_EXCEL, ''SELECT * FROM [Responsables de Pago$]'');
		';


    EXEC sp_executesql @SQL;

    -- Cursor para insertar en tabla definitiva
    DECLARE 
        @cod_socio        VARCHAR(15),
        @nombre           VARCHAR(50),
        @apellido         VARCHAR(50),
        @dni              CHAR(8),
        @email            VARCHAR(100),
        @fecha_nac        DATE,
        @tel              VARCHAR(15),
        @tel_emerg        VARCHAR(15),
        @nombre_cobertura VARCHAR(50),
        @nro_afiliado     VARCHAR(50),
        @tel_cobertura    VARCHAR(15);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura
    FROM ##Temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO @cod_socio, @nombre, @apellido, @dni, @email, @fecha_nac, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC stp.insertarSocio
            @cod_socio = @cod_socio,
            @nombre = @nombre,
            @apellido = @apellido,
            @dni = @dni,
            @email = @email,
            @fecha_nac = @fecha_nac,
            @tel = @tel,
            @tel_emerg = @tel_emerg,
            @nombre_cobertura = @nombre_cobertura,
            @nro_afiliado = @nro_afiliado,
            @tel_cobertura = @tel_cobertura;

        FETCH NEXT FROM cur INTO @cod_socio, @nombre, @apellido, @dni, @email, @fecha_nac, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;
    END

    CLOSE cur;
    DEALLOCATE cur;
	
    DROP TABLE ##Temp;

    PRINT 'Importación completada correctamente.';
END
GO




SELECT TOP 1 * 
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=NO;Database=D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',
    'SELECT * FROM [Responsables de Pago$]'
);






exec imp.ImportarTarifas 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx'
-----------------------------------------------------------------------------------------------------------------------
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
        ''SELECT * FROM [Tarifas$B2:D8]''
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
        ''SELECT * FROM [Tarifas$B10:D13]''
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

-----------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        cod_socio            VARCHAR(15),
        nombre               VARCHAR(50),
        apellido             VARCHAR(50),
        dni                  CHAR(8),
        email                VARCHAR(100),
        fecha_nac            DATE,
        tel                  VARCHAR(150),
        tel_emerg            VARCHAR(150),
        nombre_cobertura     VARCHAR(50),
        nro_afiliado         VARCHAR(50),
        tel_cobertura        VARCHAR(150)
    );

    DECLARE @SQL NVARCHAR(MAX);

    INSERT INTO ##Temp
	SELECT
		F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11
	FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;HDR=NO;Database=D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',
		'SELECT * FROM [Responsables de Pago$] WHERE F1 NOT LIKE ''Nro de Socio%'''
	);

