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

--	Listar hojas de un xls
EXEC sp_addlinkedserver 
    @server = 'EXCEL_IMPORT',
    @srvproduct = 'ACE 12.0',
    @provider = 'Microsoft.ACE.OLEDB.12.0',
    @datasrc = 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',
    @provstr = 'Excel 12.0;HDR=YES';

EXEC sp_tables_ex 'EXCEL_IMPORT';

EXEC sp_dropserver 'EXCEL_IMPORT', 'droplogins';
GO

SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;HDR=YES;Database=D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',
    'SELECT * FROM [Responsables de Pago$]'
);
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
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
        DROP TABLE #Temp;

    -- Crear tabla temporal
    CREATE TABLE #Temp
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
    INSERT INTO #Temp (cod_pago, fecha_pago, responsable_pago, monto, medio_pago)
    SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
        ''SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago] FROM [pago cuotas$]''
    )';

    EXEC sp_executesql @SQL;
    PRINT 'Datos cargados en #Temp.';

    -- Recorrer ##Temp y llamar al SP
    DECLARE @cod_pago			BIGINT,
            @fecha_pago			DATE,
            @responsable_pago	VARCHAR(15),
            @monto				DECIMAL(10,2),
            @medio_pago			VARCHAR(15);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT cod_pago, fecha_pago, responsable_pago, monto, medio_pago
    FROM #Temp;

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
    DROP TABLE #Temp;
    PRINT '#Temp eliminada.';
    PRINT 'Importación completada correctamente.';
END
GO
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
--	Importar Socios.
	exec imp.Importar_Socios 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Socios') 
BEGIN
    DROP PROCEDURE imp.Importar_Socios;
    PRINT 'SP Importar_Socios ya existe --> se borró';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Socios
 -- Eliminar tabla temporal si existe
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
        DROP TABLE #Temp;

    -- Crear tabla temporal
    CREATE TABLE #Temp
    (
        cod_socio			VARCHAR(15),
		nombre				VARCHAR(50),
		apellido			VARCHAR(50),
		dni					CHAR(8),
		email				VARCHAR(100),
		fecha_nac			DATE,
		tel					VARCHAR(15),
		tel_emerg			VARCHAR(15),
		nombre_cobertura	VARCHAR(50),
		nro_afiliado		VARCHAR(50),
		tel_cobertura		VARCHAR(15)--,
		--estado				BIT,
		--saldo				DECIMAL(10,2),
		--cod_responsable		VARCHAR(15)
    );

    -- Armar SQL dinámico
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
INSERT INTO #Temp (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura)
SELECT [Nro de Socio] AS cod_socio, [Nombre] AS nombre, [apellido] AS apellido, [DNI] AS dni, [email personal] AS email, 
       [fecha de nacimiento] AS fecha_nac, [teléfono de contacto] AS tel, [teléfono de contacto emergencia] AS tel_emerg, 
       [Nombre de la obra social o prepaga] AS nombre_cobertura, [nro. de socio obra social/prepaga ] AS nro_afiliado, [teléfono de contacto de emergencia ] AS tel_cobertura
FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''', 
''SELECT [Nro de Socio], [Nombre], [apellido], [DNI], [email personal], [fecha de nacimiento], [teléfono de contacto], [teléfono de contacto emergencia], [Nombre de la obra social o prepaga], [nro. de socio obra social/prepaga ], [teléfono de contacto de emergencia ] FROM [Responsables de Pago$]'')
';

EXEC sp_executesql @SQL;

    PRINT 'Datos cargados en #Temp.';

    -- Recorrer ##Temp y llamar al SP
    DECLARE @cod_socio        VARCHAR(15),
			@dni              CHAR(8),
			@nombre           VARCHAR(50),
			@apellido         VARCHAR(50),
			@fecha_nac        DATE,
			@email            VARCHAR(100),
			@tel              VARCHAR(15),
			@tel_emerg        VARCHAR(15),
			@nombre_cobertura VARCHAR(50),
			@nro_afiliado     VARCHAR(50),
			@tel_cobertura    VARCHAR(15);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT cod_socio, dni, nombre, apellido, fecha_nac, email, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura
    FROM #Temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO @cod_socio, @dni, @nombre, @apellido, @fecha_nac, @email, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Llamar al SP con reglas de negocio
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
			@tel_cobertura = @tel_cobertura

        FETCH NEXT FROM cur INTO @cod_socio, @dni, @nombre, @apellido, @fecha_nac, @email, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Eliminar ##Temp
    DROP TABLE #Temp;
    PRINT '#Temp eliminada.';
    PRINT 'Importación completada correctamente.';
	PRINT @SQL;
END
-----------------------------------------------------------------------------------------------------------------------















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

