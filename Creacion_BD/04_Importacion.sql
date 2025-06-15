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

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL				--	Tabla temporal que trae toda la info. como cadena de texto.
        DROP TABLE ##Temp;
    CREATE TABLE ##Temp
    (
        tcod_pago				VARCHAR(255),
        tfecha_pago				VARCHAR(255),	
        tresponsable_pago		VARCHAR(255),
        tmonto					VARCHAR(255),
        tmedio_pago				VARCHAR(255)
    );

	DECLARE	@filas_importadas		INT = 0,				--	Variables para control.
			@filas_ignoradas		INT = 0;

    DECLARE @SQL NVARCHAR(MAX);								-- Consulta dinámica que carga ##Temp desde el Excel.
    SET @SQL = '
        INSERT INTO ##Temp
		SELECT 
			tcod_pago			= CONVERT(VARCHAR(255), F1),
			tfecha_pago			= CONVERT(VARCHAR(255), F2),
			tresponsable_pago	= CONVERT(VARCHAR(255), F3),
			tmonto				= CONVERT(VARCHAR(255), F4),
			tmedio_pago			= CONVERT(VARCHAR(255), F5)
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;HDR=NO;IMEX=1;Database=D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx'',
			''SELECT * FROM [pago cuotas$]''
		)';
    EXEC sp_executesql @SQL;

	DELETE FROM ##Temp Where tcod_pago LIKE ('Id de pago');		--	Elimino encabezado.

	DECLARE	@cod_pago		BIGINT,								--	Variables para dar formato.
			@fecha_pago		DATE,
			@responsable	VARCHAR(15),
			@monto			DECIMAL(10,2),
			@medio_pago		VARCHAR(15);

	DECLARE cur CURSOR FOR		--	Cursor para recorrer fila a fila ##Temp.
	SELECT 
		tcod_pago, 
		tfecha_pago, 
		tresponsable_pago, 
		tmonto, 
		tmedio_pago
	FROM ##Temp

	OPEN cur
	FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable, @monto, @medio_pago

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--	Intento castear lo que llega de ##Temp
		SET @cod_pago		= TRY_CAST(@cod_pago AS BIGINT)
		SET @fecha_pago		= TRY_CAST(@fecha_pago AS DATE)
		SET @responsable	= LEFT(@responsable, 15)
		SET @monto			= TRY_CAST(@monto AS DECIMAL(10,2))
		SET @medio_pago		= LEFT(@medio_pago, 15)

		IF @cod_pago IS NOT NULL AND @fecha_pago IS NOT NULL AND @monto IS NOT NULL
        BEGIN
		-- Llamo al SP que tiene las reglas de negocio para insertar.
			EXEC stp.insertarPago 
				@monto = @monto,
				@fecha_pago = @fecha_pago,
				@estado = 'PAGADO',  
				@paga_socio = @responsable,
				@paga_invitado = NULL,
				@medio_pago = @medio_pago
			SET @filas_importadas += 1
		END
		ELSE
		BEGIN
			SET @filas_ignoradas += 1
		END
		FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable, @monto, @medio_pago
	END

	CLOSE cur
	DEALLOCATE cur


    DROP TABLE ##Temp;
    PRINT CONCAT('Filas importadas: ', @filas_importadas);
    PRINT CONCAT('Filas ignoradas: ', @filas_ignoradas);
    PRINT 'Importe completo.';
END
GO

--delete from psn.Pago
exec imp.Importar_Pagos 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';
select * from psn.Pago
GO











	exec imp.Importar_Socios 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';
	select * from psn.Socio


-----------------------------------------------------------------------------------------------------------------------
--	Importar Socios.

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Socios') 
BEGIN
    DROP PROCEDURE imp.Importar_Socios;
    PRINT 'Importar_Socios existía y fue borrado';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Socios
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpieza tabla temporal si existe
    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        tcod_socio            VARCHAR(255),
        tnombre               VARCHAR(255),
        tapellido             VARCHAR(255),
        tdni                  VARCHAR(255),
        temail                VARCHAR(255),
        tfecha_nac            VARCHAR(255),
        ttel                  VARCHAR(255),
        ttel_emerg            VARCHAR(255),
        tnombre_cobertura     VARCHAR(255),
        tnro_afiliado         VARCHAR(255),
        ttel_cobertura        VARCHAR(255)
    );

    DECLARE @filas_importadas INT = 0, @filas_ignoradas INT = 0;

    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
        INSERT INTO ##Temp
        SELECT 
            CONVERT(VARCHAR(255), F1),
            CONVERT(VARCHAR(255), F2),
            CONVERT(VARCHAR(255), F3),
            CONVERT(VARCHAR(255), F4),
            CONVERT(VARCHAR(255), F5),
            CONVERT(VARCHAR(255), F6),
            CONVERT(VARCHAR(255), F7),
            CONVERT(VARCHAR(255), F8),
            CONVERT(VARCHAR(255), F9),
            CONVERT(VARCHAR(255), F10),
            CONVERT(VARCHAR(255), F11)
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
            ''SELECT * FROM [Responsables de Pago$]''
        )';
    EXEC sp_executesql @SQL;

    -- Elimina encabezado
    DELETE FROM ##Temp WHERE tcod_socio = 'Nro de Socio';

    -- Variables de cursor
    DECLARE 
        @tcod_socio VARCHAR(255), @tnombre VARCHAR(255), @tapellido VARCHAR(255),
        @tdni VARCHAR(255), @temail VARCHAR(255), @tfecha_nac VARCHAR(255),
        @ttel VARCHAR(255), @ttel_emerg VARCHAR(255), @tnombre_cobertura VARCHAR(255),
        @tnro_afiliado VARCHAR(255), @ttel_cobertura VARCHAR(255);

    -- Variables finales
    DECLARE 
        @cod_socio VARCHAR(15), @nombre VARCHAR(50), @apellido VARCHAR(50),
        @dni CHAR(8), @email VARCHAR(100), @fecha_nac DATE,
        @tel VARCHAR(15), @tel_emerg VARCHAR(15), @nombre_cobertura VARCHAR(50),
        @nro_afiliado VARCHAR(50), @tel_cobertura VARCHAR(15);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT * FROM ##Temp;

    OPEN cur;
    FETCH NEXT FROM cur INTO 
        @tcod_socio, @tnombre, @tapellido, @tdni, @temail, @tfecha_nac,
        @ttel, @ttel_emerg, @tnombre_cobertura, @tnro_afiliado, @ttel_cobertura;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Limpieza y conversión
        SET @cod_socio = LEFT(LTRIM(RTRIM(@tcod_socio)), 15);
        SET @nombre = LEFT(LTRIM(RTRIM(@tnombre)), 50);
        SET @apellido = LEFT(LTRIM(RTRIM(@tapellido)), 50);
        SET @dni = LEFT(LTRIM(RTRIM(@tdni)), 8);
        SET @email = LEFT(LTRIM(RTRIM(@temail)), 100);
        SET @fecha_nac = TRY_CONVERT(DATE, REPLACE(LTRIM(RTRIM(@tfecha_nac)), CHAR(160), ''), 103); -- dd/MM/yyyy
        SET @tel = LEFT(LTRIM(RTRIM(@ttel)), 15);
        SET @tel_emerg = LEFT(LTRIM(RTRIM(@ttel_emerg)), 15);
        SET @nombre_cobertura = LEFT(LTRIM(RTRIM(@tnombre_cobertura)), 50);
        SET @nro_afiliado = LEFT(LTRIM(RTRIM(@tnro_afiliado)), 50);
        SET @tel_cobertura = LEFT(LTRIM(RTRIM(@ttel_cobertura)), 15);

        -- Validación
        IF @cod_socio IS NOT NULL AND @nombre <> '' AND @apellido <> '' AND @dni <> ''
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
                @tel_cobertura = @tel_cobertura,
                @cod_responsable = 'NS-0000',
                @estado = 1,
                @saldo = 0.0;
            SET @filas_importadas += 1;
        END
        ELSE
        BEGIN
            PRINT 'Fila ignorada -> Socio: ' + ISNULL(@tcod_socio, 'NULL') + 
                  ', Fecha Nac: ' + ISNULL(@tfecha_nac, 'NULL');
            SET @filas_ignoradas += 1;
        END

        FETCH NEXT FROM cur INTO 
            @tcod_socio, @tnombre, @tapellido, @tdni, @temail, @tfecha_nac,
            @ttel, @ttel_emerg, @tnombre_cobertura, @tnro_afiliado, @ttel_cobertura;
    END

    CLOSE cur;
    DEALLOCATE cur;
    PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
    PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
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



	CREATE OR ALTER PROCEDURE imp.Importar_Socios
	@RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL				--	Tabla temporal que trae toda la info. como cadena de texto.
        DROP TABLE ##Temp;
    CREATE TABLE ##Temp
    (
        tcod_socio            VARCHAR(255),
        tnombre               VARCHAR(255),
        tapellido             VARCHAR(255),
        tdni                  VARCHAR(255),
        temail                VARCHAR(255),
        tfecha_nac            VARCHAR(255),
        ttel                  VARCHAR(255),
        ttel_emerg            VARCHAR(255),
        tnombre_cobertura     VARCHAR(255),
        tnro_afiliado         VARCHAR(255),
        ttel_cobertura        VARCHAR(255)
    );

	DECLARE	@filas_importadas		INT = 0,				--	Variables para control.
			@filas_ignoradas		INT = 0;

    DECLARE @SQL NVARCHAR(MAX);								-- Consulta dinámica que carga ##Temp desde el Excel.
    SET @SQL = '
        INSERT INTO ##Temp
		SELECT 
			tcod_socio			= CONVERT(VARCHAR(255), F1),
			tnombre				= CONVERT(VARCHAR(255), F2),
			tapellido			= CONVERT(VARCHAR(255), F3),
			tdni				= CONVERT(VARCHAR(255), F4),
			temail				= CONVERT(VARCHAR(255), F5),
			tfecha_nac			= CONVERT(VARCHAR(255), F6),
			ttel				= CONVERT(VARCHAR(255), F7),
			ttel_emerg			= CONVERT(VARCHAR(255), F8),
			tnombre_cobertura	= CONVERT(VARCHAR(255), F9),
			tnro_afiliado		= CONVERT(VARCHAR(255), F10),
			ttel_cobertura		= CONVERT(VARCHAR(255), F11)

		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
			''SELECT * FROM [Responsables de Pago$]''
		)';
    EXEC sp_executesql @SQL;

	--DELETE TOP (1) FROM ##Temp		--	No garantiza ser la primer fila.
	DELETE FROM ##Temp WHERE tcod_socio = 'Nro de Socio';		--	Elimino el encabezado.

	--	Variables para dar formato.
    DECLARE 
		@cod_socio        VARCHAR(15),
		@nombre           VARCHAR(50),
		@apellido         VARCHAR(50),
		@dni              CHAR(8),
		@email            VARCHAR(100),
		@fecha_nac        VARCHAR(100),
		@tel              VARCHAR(15),
		@tel_emerg        VARCHAR(15),
		@nombre_cobertura VARCHAR(50),
		@nro_afiliado     VARCHAR(50),
		@tel_cobertura    VARCHAR(15);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT	tcod_socio, 
			tnombre, 
			tapellido, 
			tdni, 
			temail, 
			tfecha_nac, 
			ttel, 
			ttel_emerg, 
			tnombre_cobertura, 
			tnro_afiliado,
			ttel_cobertura
    FROM ##Temp;

    OPEN cur;
	FETCH NEXT FROM cur INTO @cod_socio, @nombre, @apellido, @dni, @email, @fecha_nac, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @cod_socio        = TRY_CAST(@cod_socio AS BIGINT);
		SET @nombre           = LEFT(@nombre, 50);
		SET @apellido         = LEFT(@apellido, 50);
		SET @dni              = LEFT(@dni, 8);
		SET @email            = LEFT(@email, 100);
		SET @fecha_nac        = TRY_CAST(@fecha_nac AS DATE);
		SET @tel              = LEFT(@tel, 15);
		SET @tel_emerg        = LEFT(@tel_emerg, 15);
		SET @nombre_cobertura = LEFT(@nombre_cobertura, 50);
		SET @nro_afiliado     = LEFT(@nro_afiliado, 50);
		SET @tel_cobertura    = LEFT(@tel_cobertura, 15);

		IF @cod_socio IS NOT NULL AND @nombre IS NOT NULL AND @apellido IS NOT NULL AND @dni IS NOT NULL
		BEGIN
			EXEC stp.insertarSocio
				@cod_socio         = @cod_socio,
				@nombre            = @nombre,
				@apellido          = @apellido,
				@dni               = @dni,
				@email             = @email,
				@fecha_nac         = @fecha_nac,
				@tel               = @tel,
				@tel_emerg         = @tel_emerg,
				@nombre_cobertura  = @nombre_cobertura,
				@nro_afiliado      = @nro_afiliado,
				@tel_cobertura     = @tel_cobertura,
				@cod_responsable   = 'NS-0000',
				@estado            = 1,
				@saldo             = 0.0;

			SET @filas_importadas += 1;
		END
		ELSE
		BEGIN
			SET @filas_ignoradas += 1;
		END

		FETCH NEXT FROM cur INTO @cod_socio, @nombre, @apellido, @dni, @email, @fecha_nac, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;
	END


    CLOSE cur;
    DEALLOCATE cur;
	SELECT * FROM ##Temp
    DROP TABLE ##Temp;
    PRINT CONCAT('Filas importadas: ', @filas_importadas);
    PRINT CONCAT('Filas ignoradas: ', @filas_ignoradas);
    PRINT 'Importe completo.';
END
GO
