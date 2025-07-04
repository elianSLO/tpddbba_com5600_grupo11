/*
====================================================================================
 Archivo		: 04.1_Importacion.sql
 Proyecto		: Instituci?n Deportiva Sol Norte.
 Descripci?n	: Scripts para importar datos a las tablas desde xls y csv.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Versi?n		: 1.0
====================================================================================
*/

Use Com5600G11
GO

----------------------------------------------------------------------------------------------------------------
--	CONFIGURACIONES INICIALES
----------------------------------------------------------------------------------------------------------------

--	Habilito config. opciones avanzadas.
EXEC sp_configure 'show advanced options', 1;			
RECONFIGURE;  

--	Permito usar OPENROWSET y otras consultas distribuidas.
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;		
RECONFIGURE;  

--	Permito que el proveedor OLEDB (Microsoft.ACE.OLEDB.12.0) se ejecute dentro del proceso de SQL Server.
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;		

--	Habilito el pasaje de par?metros a las consultas din?micas.
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;		
GO


--Chequear nombre del servicio para  darle permiso de acceso a los directorios donde se guarda la informaci?n.
/*
SELECT servicename, service_account			
FROM sys.dm_server_services;


EXEC master.dbo.sp_enum_oledb_providers;
EXEC master.sys.sp_MSget_oledb_providers;
EXEC sp_enum_oledb_providers;
*/

----------------------------------------------------------------------------------------------------------------
-- IMPORTAR_SOCIOS
----------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Socios') 
BEGIN
    DROP PROCEDURE Persona.Importar_Socios;
END;
GO

CREATE OR ALTER PROCEDURE Persona.Importar_Socios
	@RutaArchivo NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL DROP TABLE ##Temp;
	CREATE TABLE ##Temp (
		id INT IDENTITY(1,1) PRIMARY KEY,
		tcod_socio VARCHAR(255), tnombre VARCHAR(255), tapellido VARCHAR(255), tdni VARCHAR(255),
		temail VARCHAR(255), tfecha_nac VARCHAR(255), ttel VARCHAR(255), ttel_emerg VARCHAR(255),
		tnombre_cobertura VARCHAR(255), tnro_afiliado VARCHAR(255), ttel_cobertura VARCHAR(255)
	);

	DECLARE @SQL NVARCHAR(MAX) = '
	INSERT INTO ##Temp SELECT 
		CONVERT(VARCHAR(255), F1), CONVERT(VARCHAR(255), F2), CONVERT(VARCHAR(255), F3),
		CONVERT(VARCHAR(255), F4), CONVERT(VARCHAR(255), F5), CONVERT(VARCHAR(255), F6),
		CONVERT(VARCHAR(255), F7), CONVERT(VARCHAR(255), F8), CONVERT(VARCHAR(255), F9),
		CONVERT(VARCHAR(255), F10), CONVERT(VARCHAR(255), F11)
	FROM OPENROWSET(
		''Microsoft.ACE.OLEDB.12.0'',
		''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
		''SELECT * FROM [Responsables de Pago$]''
	)';
	EXEC sp_executesql @SQL;

	DELETE FROM ##Temp WHERE tcod_socio = 'Nro de Socio';

	DECLARE @id INT = 1, @maxId INT;
	SELECT @maxId = MAX(id) FROM ##Temp;

	DECLARE @resultado INT = 0, @filas_importadas INT = 0, @filas_ignoradas INT = 0;

	WHILE @id <= @maxId
	BEGIN
		DECLARE 
			@cod_socio VARCHAR(15), @nombre VARCHAR(50), @apellido VARCHAR(50), @dni CHAR(8),
			@email VARCHAR(100), @fecha_nac DATE, @tel VARCHAR(15), @tel_emerg VARCHAR(15),
			@nombre_cobertura VARCHAR(50), @nro_afiliado VARCHAR(50), @tel_cobertura VARCHAR(15);

		SELECT 
			@cod_socio = LEFT(LTRIM(RTRIM(tcod_socio)),15),
			@nombre = LEFT(LTRIM(RTRIM(tnombre)),50),
			@apellido = LEFT(LTRIM(RTRIM(tapellido)),50),
			@dni = LEFT(LTRIM(RTRIM(tdni)),8),
			@email = LEFT(LTRIM(RTRIM(temail)),100),
			@fecha_nac = TRY_CONVERT(DATE, REPLACE(tfecha_nac, CHAR(160), ''), 103),
			@tel = LEFT(LTRIM(RTRIM(ttel)),15),
			@tel_emerg = LEFT(LTRIM(RTRIM(ttel_emerg)),15),
			@nombre_cobertura = LEFT(LTRIM(RTRIM(tnombre_cobertura)),50),
			@nro_afiliado = LEFT(LTRIM(RTRIM(tnro_afiliado)),50),
			@tel_cobertura = LEFT(LTRIM(RTRIM(ttel_cobertura)),15)
		FROM ##Temp WHERE id = @id;

		BEGIN TRY
			EXEC @resultado = Persona.insertarSocio
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
				@cod_responsable = NULL,
				@estado = NULL,
				@saldo = NULL;
			IF @resultado = 1 SET @filas_importadas += 1; ELSE SET @filas_ignoradas += 1;
		END TRY
		BEGIN CATCH
			SET @filas_ignoradas += 1;
		END CATCH

		SET @id += 1;
	END

	DROP TABLE ##Temp;
	PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
	PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END;
GO

----------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------
-- IMPORTAR_PAGOS
----------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Pagos') 
BEGIN
    DROP PROCEDURE Finanzas.Importar_Pagos;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.Importar_Pagos
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tcod_pago       VARCHAR(255),
        tfecha_pago     VARCHAR(255),    
        tresponsable    VARCHAR(255),
        tmonto          VARCHAR(255),
        tmedio_pago     VARCHAR(255)
    );

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
        INSERT INTO ##Temp (tcod_pago, tfecha_pago, tresponsable, tmonto, tmedio_pago)
        SELECT 
            CONVERT(VARCHAR(255), F1),
            CONVERT(VARCHAR(255), F2),
            CONVERT(VARCHAR(255), F3),
            CONVERT(VARCHAR(255), F4),
            CONVERT(VARCHAR(255), F5)
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
            ''SELECT * FROM [pago cuotas$]''
        )';
    EXEC sp_executesql @SQL;

    DELETE FROM ##Temp WHERE tcod_pago LIKE 'Id de pago';

    DECLARE 
        @maxId INT,
        @id INT = 1,
        @tcod_pago VARCHAR(255),
        @tfecha_pago VARCHAR(255),    
        @tresponsable VARCHAR(255),
        @tmonto VARCHAR(255),
        @tmedio_pago VARCHAR(255),

        @cod_pago BIGINT,
        @fecha_pago DATE,
        @responsable VARCHAR(15),
        @monto DECIMAL(10,2),
        @medio_pago VARCHAR(15),

        @resultado INT,
        @filas_importadas INT = 0,
        @filas_ignoradas INT = 0;

    SELECT @maxId = MAX(id) FROM ##Temp;

    WHILE @id <= @maxId
    BEGIN
        SELECT 
            @tcod_pago = tcod_pago,
            @tfecha_pago = tfecha_pago,
            @tresponsable = tresponsable,
            @tmonto = tmonto,
            @tmedio_pago = tmedio_pago
        FROM ##Temp WHERE id = @id;

        SET @cod_pago = TRY_CAST(@tcod_pago AS BIGINT);
        SET @fecha_pago = TRY_CONVERT(DATE, @tfecha_pago, 103);
        SET @responsable = LEFT(LTRIM(RTRIM(@tresponsable)), 15);
        SET @monto = TRY_CAST(@tmonto AS DECIMAL(10,2));
        SET @medio_pago = LEFT(LTRIM(RTRIM(@tmedio_pago)), 15);

        BEGIN TRY
            EXEC @resultado = Finanzas.insertarPago
                @cod_pago = @cod_pago,
                @monto = @monto,
                @fecha_pago = @fecha_pago,
                @estado = 'Pagado',
                @responsable = @responsable,
                @medio_pago = @medio_pago;

            IF @resultado = 1 
                SET @filas_importadas += 1;
            ELSE
                SET @filas_ignoradas += 1;
        END TRY
        BEGIN CATCH
            SET @filas_ignoradas += 1;
        END CATCH

        SET @id += 1;
    END
    DROP TABLE ##Temp;

    PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
    PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END;
GO

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- IMPORTAR_CATEGORIAS
----------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Categorias') 
BEGIN
    DROP PROCEDURE Club.Importar_Categorias;
END;
GO

CREATE OR ALTER PROCEDURE Club.Importar_Categorias
	@RutaArchivo NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
		DROP TABLE ##Temp;

	CREATE TABLE ##Temp
	(
		id INT IDENTITY(1,1) PRIMARY KEY,
		tdescripcion		VARCHAR(255),
		tvalor_mensual		VARCHAR(255),
		tvig_valor_mens		VARCHAR(255)
	);

	IF OBJECT_ID('tempdb..##Temp2') IS NOT NULL
		DROP TABLE ##Temp2;

	CREATE TABLE ##Temp2
	(
		tvalor_dia_socios_ad	VARCHAR(255),
		tvalor_dia_socios_men	VARCHAR(255),
		tvalor_dia_invi_ad		VARCHAR(255),
		tvalor_dia_invi_men		VARCHAR(255),

		tvalor_anual		VARCHAR(255),
		tvig_valor_anual		VARCHAR(255)
	);

	DECLARE @SQL NVARCHAR(MAX);

	SET @SQL = '
    INSERT INTO ##Temp (tdescripcion, tvalor_mensual, tvig_valor_mens)
    SELECT 
        CONVERT(VARCHAR(255), F1),
        CONVERT(VARCHAR(255), F2),
        CONVERT(VARCHAR(255), F3)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Tarifas$B11:D13]''
    )';

	EXEC sp_executesql @SQL;

	SET @SQL = '
    INSERT INTO ##Temp2 (tvalor_dia_socios_ad, tvalor_dia_socios_men, tvalor_dia_invi_ad)
    SELECT 
        CONVERT(VARCHAR(255), F1),
        CONVERT(VARCHAR(255), F2),
		CONVERT(VARCHAR(255), F3)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Tarifas$D17:I22]''
    )';

	EXEC sp_executesql @SQL;
	
	DECLARE 
		@maxId INT,
		@id INT = 1,
		@tdescripcion VARCHAR(255),
		@tvalor_mensual VARCHAR(255),
		@tvig_valor_mens VARCHAR(255),

		@descripcion VARCHAR(50),
		@valor_mensual DECIMAL(10,2),
		@vig_valor_mens DATE,
		@edad_min INT,
		@edad_max INT,

		@filas_importadas INT = 0,
		@filas_ignoradas INT = 0,
		@resultado INT;

	SELECT @maxId = MAX(id) FROM ##Temp;

	WHILE @id <= @maxId
	BEGIN
		SELECT 
			@tdescripcion = tdescripcion,
			@tvalor_mensual = tvalor_mensual,
			@tvig_valor_mens = tvig_valor_mens
		FROM ##Temp WHERE id = @id;

		SET @descripcion = LEFT(LTRIM(RTRIM(@tdescripcion)), 50);
		SET @valor_mensual = TRY_CONVERT(DECIMAL(10,2), REPLACE(LTRIM(RTRIM(@tvalor_mensual)), CHAR(160), ''));
		SET @vig_valor_mens = TRY_CONVERT(DATE, REPLACE(LTRIM(RTRIM(@tvig_valor_mens)), CHAR(160), ''), 103);

		SET @edad_max = CASE @descripcion
			WHEN 'Menor' THEN 12
			WHEN 'Cadete' THEN 17
			WHEN 'Mayor' THEN 99
			ELSE NULL
		END;

		SET @edad_min = CASE @edad_max
			WHEN 12 THEN 0
			WHEN 17 THEN 13
			WHEN 99 THEN 18
			ELSE NULL
		END;

		BEGIN TRY
			EXEC @resultado = Club.insertarCategoria
				@descripcion = @descripcion,
				@edad_max = @edad_max,
				@edad_min = @edad_min,
				@valor_mensual = @valor_mensual,
				@vig_valor_mens = @vig_valor_mens,
				@valor_anual = NULL,
				@vig_valor_anual = NULL;

			IF @resultado = 1
				SET @filas_importadas += 1;
			ELSE
				SET @filas_ignoradas += 1;
		END TRY
		BEGIN CATCH
			SET @filas_ignoradas += 1;
		END CATCH

		SET @id += 1;
	END

	DROP TABLE ##Temp;
	DROP TABLE ##Temp2;

	PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
	PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END;
GO

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- IMPORTAR_ACTIVIDADES
----------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Actividades') 
BEGIN
    DROP PROCEDURE Club.Importar_Actividades;
END;
GO

CREATE OR ALTER PROCEDURE Club.Importar_Actividades
	@RutaArchivo NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
		DROP TABLE ##Temp;

	CREATE TABLE ##Temp
	(
		id INT IDENTITY(1,1) PRIMARY KEY,
		tnombre				VARCHAR(255),
		tvalor_mensual		VARCHAR(255),
		tvig_valor			VARCHAR(255)
	);

	DECLARE @SQL NVARCHAR(MAX);
	SET @SQL = '
    INSERT INTO ##Temp (tnombre, tvalor_mensual, tvig_valor)
    SELECT 
        CONVERT(VARCHAR(255), F1),
        CONVERT(VARCHAR(255), F2),
        CONVERT(VARCHAR(255), F3)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Tarifas$B3:D8]''
    )';

	EXEC sp_executesql @SQL;

	DELETE FROM ##Temp WHERE tnombre = 'Actividad';

	DECLARE 
		@maxId INT,
		@id INT = 1,
		@tnombre VARCHAR(255),
		@tvalor_mensual VARCHAR(255),
		@tvig_valor VARCHAR(255),

		@nombre VARCHAR(50),
		@valor_mensual DECIMAL(10,2),
		@vig_valor DATE,

		@resultado INT,
		@filas_importadas INT = 0,
		@filas_ignoradas INT = 0;

	SELECT @maxId = MAX(id) FROM ##Temp;

	WHILE @id <= @maxId
	BEGIN
		SELECT 
			@tnombre = tnombre,
			@tvalor_mensual = tvalor_mensual,
			@tvig_valor = tvig_valor
		FROM ##Temp WHERE id = @id;

		SET @nombre = LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			LTRIM(RTRIM(@tnombre)),
			'?','a'), '?','e'), '?','i'), '?','o'), '?','u'),
			'?','A'), '?','E'), '?','I'), '?','O'), '?','U'), 50);

		SET @valor_mensual = TRY_CONVERT(DECIMAL(10,2), REPLACE(LTRIM(RTRIM(@tvalor_mensual)), CHAR(160), ''));
		SET @vig_valor = TRY_CONVERT(DATE, REPLACE(LTRIM(RTRIM(@tvig_valor)), CHAR(160), ''), 103);

		BEGIN TRY
			EXEC @resultado = Club.insertarActividad
				@nombre = @nombre,
				@vig_valor = @vig_valor,
				@valor_mensual = @valor_mensual;
			IF @resultado = 1
				SET @filas_importadas += 1;
			ELSE
				SET @filas_ignoradas += 1;
		END TRY
		BEGIN CATCH
			SET @filas_ignoradas += 1;
		END CATCH

		SET @id += 1;
	END

	DROP TABLE ##Temp;

	PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
	PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END;
GO


----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- IMPORTAR_GRUPO_FAMILIAR
----------------------------------------------------------------------------------------------------------------

--EXEC Persona.insertarSocio 'SN-4001','20004001','Nombre Socio','Apellido Socio','1990-01-01',NULL,NULL,NULL,1,0,'OSDE','OS40010000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4002','20004002','Nombre Socio','Apellido Socio','1990-01-02',NULL,NULL,NULL,1,0,'OSDE','OS40020000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4005','20004005','Nombre Socio','Apellido Socio','1990-01-03',NULL,NULL,NULL,1,0,'Swiss Medical','SM40050000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4011','20004011','Nombre Socio','Apellido Socio','1990-01-04',NULL,NULL,NULL,1,0,'Medife','MF40110000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4013','20004013','Nombre Socio','Apellido Socio','1990-01-05',NULL,NULL,NULL,1,0,'Galeno','GL40130000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4014','20004014','Nombre Socio','Apellido Socio','1990-01-06',NULL,NULL,NULL,1,0,'OSDE','OS40140000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4019','20004019','Nombre Socio','Apellido Socio','1990-01-07',NULL,NULL,NULL,1,0,'Swiss Medical','SM40190000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4022','20004022','Nombre Socio','Apellido Socio','1990-01-08',NULL,NULL,NULL,1,0,'Medife','MF40220000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4031','20004031','Nombre Socio','Apellido Socio','1990-01-09',NULL,NULL,NULL,1,0,'Galeno','GL40310000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4032','20004032','Nombre Socio','Apellido Socio','1990-01-10',NULL,NULL,NULL,1,0,'OSDE','OS40320000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4045','20004045','Nombre Socio','Apellido Socio','1990-01-11',NULL,NULL,NULL,1,0,'Swiss Medical','SM40450000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4046','20004046','Nombre Socio','Apellido Socio','1990-01-12',NULL,NULL,NULL,1,0,'Medife','MF40460000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4047','20004047','Nombre Socio','Apellido Socio','1990-01-13',NULL,NULL,NULL,1,0,'Galeno','GL40470000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4048','20004048','Nombre Socio','Apellido Socio','1990-01-14',NULL,NULL,NULL,1,0,'OSDE','OS40480000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4051','20004051','Nombre Socio','Apellido Socio','1990-01-15',NULL,NULL,NULL,1,0,'Swiss Medical','SM40510000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4056','20004056','Nombre Socio','Apellido Socio','1990-01-16',NULL,NULL,NULL,1,0,'Medife','MF40560000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4059','20004059','Nombre Socio','Apellido Socio','1990-01-17',NULL,NULL,NULL,1,0,'Galeno','GL40590000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4061','20004061','Nombre Socio','Apellido Socio','1990-01-18',NULL,NULL,NULL,1,0,'OSDE','OS40610000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4062','20004062','Nombre Socio','Apellido Socio','1990-01-19',NULL,NULL,NULL,1,0,'Swiss Medical','SM40620000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4063','20004063','Nombre Socio','Apellido Socio','1990-01-20',NULL,NULL,NULL,1,0,'Medife','MF40630000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4073','20004073','Nombre Socio','Apellido Socio','1990-01-21',NULL,NULL,NULL,1,0,'Galeno','GL40730000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4074','20004074','Nombre Socio','Apellido Socio','1990-01-22',NULL,NULL,NULL,1,0,'OSDE','OS40740000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4077','20004077','Nombre Socio','Apellido Socio','1990-01-23',NULL,NULL,NULL,1,0,'Swiss Medical','SM40770000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4079','20004079','Nombre Socio','Apellido Socio','1990-01-24',NULL,NULL,NULL,1,0,'Medife','MF40790000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4080','20004080','Nombre Socio','Apellido Socio','1990-01-25',NULL,NULL,NULL,1,0,'Galeno','GL40800000',NULL,NULL;
--EXEC Persona.insertarSocio 'SN-4081','20004081','Nombre Socio','Apellido Socio','1990-01-26',NULL,NULL,NULL,1,0,'OSDE','OS40810000',NULL,NULL;

--EXEC Persona.Importar_SociosConResponsable 'C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx'

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_SociosConResponsable') 
BEGIN
    DROP PROCEDURE Persona.Importar_SociosConResponsable;
END;
GO

CREATE OR ALTER PROCEDURE Persona.Importar_SociosConResponsable
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        id INT IDENTITY(1,1) PRIMARY KEY,
        tcod_socio              VARCHAR(255),
        tcod_responsable        VARCHAR(255),        
        tnombre                 VARCHAR(255),
        tapellido               VARCHAR(255),
        tdni                    VARCHAR(255),
        temail                  VARCHAR(255),
        tfecha_nac              VARCHAR(255),
        ttel                    VARCHAR(255),
        ttel_emerg              VARCHAR(255),
        tnombre_cobertura       VARCHAR(255),
        tnro_afiliado           VARCHAR(255),
        ttel_cobertura          VARCHAR(255)
    );

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE 
        @maxId INT,
        @id INT = 1,

        @tcod_socio VARCHAR(255), @tcod_responsable VARCHAR(255),
        @tnombre VARCHAR(255), @tapellido VARCHAR(255),
        @tdni VARCHAR(255), @temail VARCHAR(255), @tfecha_nac VARCHAR(255),
        @ttel VARCHAR(255), @ttel_emerg VARCHAR(255), @tnombre_cobertura VARCHAR(255),
        @tnro_afiliado VARCHAR(255), @ttel_cobertura VARCHAR(255),

        @cod_socio VARCHAR(15), @cod_responsable VARCHAR(15),
        @nombre VARCHAR(50), @apellido VARCHAR(50),
        @dni CHAR(8), @email VARCHAR(100), @fecha_nac DATE,
        @tel VARCHAR(15), @tel_emerg VARCHAR(15), @nombre_cobertura VARCHAR(50),
        @nro_afiliado VARCHAR(50), @tel_cobertura VARCHAR(15),

        @resultado INT,
        @filas_socios_importadas INT = 0,
        @filas_socios_ignoradas INT = 0;

    SET @SQL = '
        INSERT INTO ##Temp (tcod_socio, tcod_responsable, tnombre, tapellido, tdni, temail, tfecha_nac, ttel, ttel_emerg, tnombre_cobertura, tnro_afiliado, ttel_cobertura)
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
            CONVERT(VARCHAR(255), F11),
            CONVERT(VARCHAR(255), F12)
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
            ''SELECT * FROM [Grupo Familiar$]''
        )';

    EXEC sp_executesql @SQL;

    DELETE FROM ##Temp WHERE tcod_socio = 'Nro de Socio' OR tcod_socio IS NULL OR tcod_socio = '';

    SELECT @maxId = MAX(id) FROM ##Temp;

    SET @id = 1;
    WHILE @id <= @maxId
    BEGIN
        SELECT 
            @tcod_socio = LTRIM(RTRIM(tcod_socio)),
            @tcod_responsable = LTRIM(RTRIM(tcod_responsable)),
            @tnombre = LTRIM(RTRIM(tnombre)),
            @tapellido = LTRIM(RTRIM(tapellido)),
            @tdni = LTRIM(RTRIM(tdni)),
            @temail = LTRIM(RTRIM(temail)),
            @tfecha_nac = LTRIM(RTRIM(tfecha_nac)),
            @ttel = LTRIM(RTRIM(ttel)),
            @ttel_emerg = LTRIM(RTRIM(ttel_emerg)),
            @tnombre_cobertura = LTRIM(RTRIM(tnombre_cobertura)),
            @tnro_afiliado = LTRIM(RTRIM(tnro_afiliado)),
            @ttel_cobertura = LTRIM(RTRIM(ttel_cobertura))
        FROM ##Temp WHERE id = @id;

        SET @cod_socio = LEFT(@tcod_socio, 15);
        SET @cod_responsable = LEFT(@tcod_responsable, 15);
        SET @nombre = LEFT(@tnombre, 50);
        SET @apellido = LEFT(@tapellido, 50);
        SET @dni = LEFT(@tdni, 8);
        SET @email = LEFT(@temail, 100);
        SET @tel = LEFT(@ttel, 15);
        SET @tel_emerg = LEFT(@ttel_emerg, 15);
        SET @nombre_cobertura = LEFT(@tnombre_cobertura, 50);
        SET @nro_afiliado = LEFT(@tnro_afiliado, 50);
        SET @tel_cobertura = LEFT(@ttel_cobertura, 15);

        SET @fecha_nac = TRY_CONVERT(DATE, REPLACE(@tfecha_nac, CHAR(160), ''), 103);

        IF @cod_socio IS NULL OR @cod_socio = ''
        BEGIN
            PRINT 'Error al insertar socio en fila ' + CAST(@id AS VARCHAR) + ': Falta codigo de socio.';
            SET @filas_socios_ignoradas += 1;
            SET @id += 1;
            CONTINUE;
        END

        -- Verifico que el responsable socio exista para no violar FK
        IF @cod_responsable IS NOT NULL AND @cod_responsable <> ''
            AND NOT EXISTS(SELECT 1 FROM Persona.Responsable WHERE cod_responsable = @cod_responsable)
            AND NOT EXISTS(SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_responsable)
        BEGIN
            PRINT 'Error al insertar socio en fila ' + CAST(@id AS VARCHAR) + ': Responsable ' + @cod_responsable + ' no existe.';
            SET @filas_socios_ignoradas += 1;
            SET @id += 1;
            CONTINUE;
        END

        BEGIN TRY
            EXEC @resultado = Persona.insertarSocio
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
                @cod_responsable = @cod_responsable,
                @estado = NULL,
                @saldo = NULL;

            IF @resultado = 1
                SET @filas_socios_importadas += 1;
            ELSE
                SET @filas_socios_ignoradas += 1;
        END TRY
        BEGIN CATCH
            PRINT 'Error al insertar socio en fila ' + CAST(@id AS VARCHAR) + ': ' + ERROR_MESSAGE();
            SET @filas_socios_ignoradas += 1;
        END CATCH;

        SET @id += 1;
    END

    DROP TABLE ##Temp;

    PRINT 'Socios importados: ' + CAST(@filas_socios_importadas AS VARCHAR);
    PRINT 'Socios ignorados: ' + CAST(@filas_socios_ignoradas AS VARCHAR);
END;
GO



-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
--	IMPORTAR HOJA DE ASISTENCIAS
----------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Asistencias') 
BEGIN
    DROP PROCEDURE Actividad.Importar_Asistencias;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.Importar_Asistencias
    @RutaArchivo NVARCHAR(255),
	@mostrarErrores INT,
	@mostrarImportadas INT
AS
BEGIN
    IF @mostrarErrores NOT BETWEEN 0 AND 1
        THROW 50001, 'El par�metro @mostrarErrores debe ser 0 o 1.', 1;

    IF @mostrarImportadas NOT BETWEEN 0 AND 1
        THROW 50002, 'El par�metro @mostrarImportadas debe ser 0 o 1.', 1;

	SET NOCOUNT ON;

-- Crear la tabla para registrar errores de importacion
	IF OBJECT_ID('tempdb..#LogErroresImportacion') IS NOT NULL DROP TABLE #LogErroresImportacion;
	CREATE TABLE #LogErroresImportacion 
	(
		Id                          INT IDENTITY(1,1) PRIMARY KEY,
        FechaHoraError              DATETIME DEFAULT GETDATE(),
        Nro_Socio_Excel             VARCHAR(15) NULL,
        Actividad_Excel             VARCHAR(50) NULL,
        Fecha_Asistencia_Excel      NVARCHAR(50) NULL,
        Asistencia_Estado_Excel     VARCHAR(5) NULL,
        Profesor_Excel              VARCHAR(50) NULL,
        Motivo_Error                VARCHAR(MAX)
	);

	BEGIN TRANSACTION;
	BEGIN TRY

		SET LANGUAGE 'Spanish';
		
        IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;
        CREATE TABLE #AsistenciaCruda 
		(
            Nro_Socio_Excel             VARCHAR(15),
            Actividad_Excel             VARCHAR(50),
            Fecha_Asistencia_Excel      NVARCHAR(50),
            Asistencia_Estado_Excel     VARCHAR(5),
            Profesor_Excel              VARCHAR(50)
		);

		DECLARE @Comando NVARCHAR(MAX);
		SET @Comando = '
			INSERT INTO #AsistenciaCruda (Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel)
            SELECT
                [Nro de Socio],
                Actividad,
                [fecha de asistencia],
                Asistencia,
                Profesor
			FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES;'',
				''SELECT * FROM [presentismo_actividades$]''
			);';
        
		EXEC(@Comando);
        -- Validar existencias de Socio, Actividad y Profesor y transformar la fecha.

        IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;
        CREATE TABLE #AsistenciaValidadaPaso1 (
            id_cruda                    INT IDENTITY(1,1) PRIMARY KEY,
            Nro_Socio_Excel_Src         VARCHAR(15),
            Actividad_Excel_Src         VARCHAR(50),
            Fecha_Asistencia_Excel_Src  NVARCHAR(50),
            Asistencia_Estado_Excel_Src VARCHAR(5),
            Profesor_Excel_Src          VARCHAR(50),

            cod_socio                   VARCHAR(15) NOT NULL,
            cod_actividad               INT NOT NULL,
            cod_profesor                INT NOT NULL,
            fecha_asistencia            DATE NOT NULL,
            estado_asistencia           CHAR(1) NOT NULL,
            dia_semana_asistencia       VARCHAR(9) NOT NULL -- dia de semana ('Lunes', 'Martes')
        );

        -- Insertar en la tabla validada y registrar errores de no existencia
        INSERT INTO #AsistenciaValidadaPaso1 (
            Nro_Socio_Excel_Src, Actividad_Excel_Src, Fecha_Asistencia_Excel_Src, Asistencia_Estado_Excel_Src, Profesor_Excel_Src,
            cod_socio, cod_actividad, cod_profesor, fecha_asistencia, estado_asistencia, dia_semana_asistencia
        )
        SELECT
            AC.Nro_Socio_Excel,
            AC.Actividad_Excel,
            AC.Fecha_Asistencia_Excel,
            AC.Asistencia_Estado_Excel,
            AC.Profesor_Excel,
            S.cod_socio,
            ACT.cod_actividad,
            P.cod_prof,
            TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE),
            LEFT(AC.Asistencia_Estado_Excel, 1), -- se toma solo el primer caracter
            DATENAME(dw, TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE))
        FROM
            #AsistenciaCruda AS AC
        LEFT JOIN
            psn.Socio AS S ON AC.Nro_Socio_Excel = S.cod_socio
        LEFT JOIN
            psn.Actividad AS ACT ON AC.Actividad_Excel = ACT.nombre
        LEFT JOIN
            psn.Profesor AS P ON TRIM(AC.Profesor_Excel) = P.nombre + ' ' + P.apellido COLLATE Modern_Spanish_CI_AS
        WHERE
            S.cod_socio IS NOT NULL
            AND ACT.cod_actividad IS NOT NULL
            AND P.cod_prof IS NOT NULL
            AND TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE) IS NOT NULL
            AND LEFT(AC.Asistencia_Estado_Excel, 1) IN ('P','A','J'); -- [MODIFICACION]: Reestablecido el filtro de estados v�lidos


        -- Registrar errores de filas que no se pudieron validar
        INSERT INTO #LogErroresImportacion (
            Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel, Motivo_Error
        )
        SELECT
            AC.Nro_Socio_Excel,
            AC.Actividad_Excel,
            AC.Fecha_Asistencia_Excel,
            AC.Asistencia_Estado_Excel,
            AC.Profesor_Excel,
            CASE
                WHEN S.cod_socio IS NULL THEN 'Socio no existe en la base de datos.'
                WHEN ACT.cod_actividad IS NULL THEN 'Actividad no existe en la base de datos.'
                WHEN P.cod_prof IS NULL THEN 'Profesor no existe en la base de datos.'
                WHEN TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE) IS NULL THEN 'Formato de fecha de asistencia inv�lido: ' + AC.Fecha_Asistencia_Excel
                WHEN LEFT(AC.Asistencia_Estado_Excel, 1) NOT IN ('P','A','J') THEN 'Estado de asistencia inv�lido: ' + AC.Asistencia_Estado_Excel
                ELSE 'Error de validaci�n desconocido en Paso 2.'
            END
        FROM
            #AsistenciaCruda AS AC
        LEFT JOIN
            Persona.Socio AS S ON AC.Nro_Socio_Excel = S.cod_socio
        LEFT JOIN
            Club.Actividad AS ACT ON AC.Actividad_Excel = ACT.nombre
        LEFT JOIN
            Persona.Profesor AS P ON TRIM(AC.Profesor_Excel) = P.nombre + ' ' + P.apellido COLLATE Modern_Spanish_CI_AS 
        WHERE
            S.cod_socio IS NULL
            OR ACT.cod_actividad IS NULL
            OR P.cod_prof IS NULL
            OR TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE) IS NULL
            OR LEFT(AC.Asistencia_Estado_Excel, 1) NOT IN ('P','A','J');


        -- Validar Inscripcion del Socio en la Actividad y Coincidencia del Dia de Clase. Preparar las asistencias finales para la insercion.


        IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;

        CREATE TABLE #AsistenciasFinales (
            fecha                   DATE NOT NULL,
            cod_socio               VARCHAR(15) NOT NULL,
            cod_clase               INT NOT NULL,
            estado                  CHAR(1) NOT NULL,
            cod_profesor            INT NOT NULL,
            PRIMARY KEY (fecha, cod_socio, cod_clase)
        );

        -- Insertar en la tabla final solo las asistencias que cumplen todas las condiciones
        INSERT INTO #AsistenciasFinales (fecha, cod_socio, cod_clase, estado, cod_profesor)
        SELECT DISTINCT -- por si un socio esta inscripto en multiples clases con el mismo dia y actividad
            AV.fecha_asistencia,
            AV.cod_socio,
            C.cod_clase,
            AV.estado_asistencia,
            AV.cod_profesor
        FROM
            #AsistenciaValidadaPaso1 AS AV
        INNER JOIN
            Actividad.Inscripto AS I ON AV.cod_socio = I.cod_socio
        INNER JOIN
            Actividad.Clase AS C ON I.cod_clase = C.cod_clase
                                AND AV.cod_actividad = C.cod_actividad
                                AND AV.dia_semana_asistencia = C.dia
                                AND AV.cod_profesor = C.cod_prof;

        -- Registrar errores de filas que no se pudieron validar
        INSERT INTO #LogErroresImportacion (
            Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel, Motivo_Error
        )
        SELECT
            AV.Nro_Socio_Excel_Src,
            AV.Actividad_Excel_Src,
            AV.Fecha_Asistencia_Excel_Src,
            AV.Asistencia_Estado_Excel_Src,
            AV.Profesor_Excel_Src,
            CASE
                WHEN NOT EXISTS (SELECT 1 FROM Actividad.Inscripto I JOIN Actividad.Clase C ON I.cod_clase = C.cod_clase WHERE I.cod_socio = AV.cod_socio AND C.cod_actividad = AV.cod_actividad) THEN 'Socio no inscripto en la actividad especificada.'
                WHEN NOT EXISTS (SELECT 1 FROM Actividad.Inscripto I JOIN Actividad.Clase C ON I.cod_clase = C.cod_clase WHERE I.cod_socio = AV.cod_socio AND C.cod_actividad = AV.cod_actividad AND C.dia = AV.dia_semana_asistencia) THEN 'D�a de asistencia no coincide con ning�n d�a de clase del socio para esta actividad.'
                ELSE 'Validaci�n de inscripci�n o clase fallida. (Motivo no especificado en CASE)' -- [MODIFICACION]: Mensaje m�s descriptivo
            END
        FROM
            #AsistenciaValidadaPaso1 AS AV
        LEFT JOIN
            #AsistenciasFinales AS AF ON AV.cod_socio = AF.cod_socio
                                        AND AV.fecha_asistencia = AF.fecha
                                        AND AV.cod_profesor = AF.cod_profesor
        WHERE
            AF.fecha IS NULL;

        -- Insertar las asistencias en la tabla final psn.Asiste

		-- Crear una tabla temporal con un ID para iterar
		IF OBJECT_ID('tempdb..#AsistenciasParaInsertar') IS NOT NULL DROP TABLE #AsistenciasParaInsertar;
		SELECT IDENTITY(INT, 1, 1) AS RowID, AF.fecha, AF.cod_socio, AF.cod_clase, AF.estado
		INTO #AsistenciasParaInsertar
		FROM #AsistenciasFinales AS AF
		LEFT JOIN Actividad.Asiste AS PA ON AF.fecha = PA.fecha AND AF.cod_socio = PA.cod_socio AND AF.cod_clase = PA.cod_clase
		WHERE PA.fecha IS NULL;

		DECLARE @RowCount INT = (SELECT COUNT(*) FROM #AsistenciasParaInsertar);
		DECLARE @CurrentRow INT = 1;

		WHILE @CurrentRow <= @RowCount
		BEGIN
			SELECT
				@Fecha = fecha,
				@CodSocio = cod_socio,
				@CodClase = cod_clase,
				@Estado = estado
			FROM #AsistenciasParaInsertar
			WHERE RowID = @CurrentRow;

            EXEC Actividad.insertarAsiste
                @fecha      = @Fecha,
                @cod_socio  = @CodSocio,
                @cod_clase  = @CodClase,
                @estado     = @Estado;

			SET @CurrentRow = @CurrentRow + 1;
		END;


        -- Si todo fue bien, confirmar la transaccion
        COMMIT TRANSACTION;
        PRINT 'Importacion completada exitosamente.';
		IF @mostrarErrores = 1
		BEGIN
			SELECT * FROM #LogErroresImportacion;
		END
		IF @mostrarImportadas = 1
		BEGIN
			SELECT * FROM #AsistenciasFinales;
		END

	END TRY
	BEGIN CATCH

        ROLLBACK TRANSACTION;
        INSERT INTO #LogErroresImportacion (
            Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel, Motivo_Error
        )
        VALUES (
            NULL, 
            NULL, 
            NULL,
            NULL,
            NULL,
            'Error general en el proceso de importacion: ' + ERROR_MESSAGE()
        );

        PRINT 'Importaci�n fallida. La transaccion ha sido revertida. Error: ' + ERROR_MESSAGE();

	END CATCH;

	IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;
	IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;
	IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;
	IF OBJECT_ID('tempdb..#LogErroresImportacion') IS NOT NULL DROP TABLE #LogErroresImportacion;
END
GO

--EXEC imp.Importar_Asistencias 
--'D:\repos\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx','presentismo_actividades',1,0
--'C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios prueba.xlsx',
--'presentismo_actividades',
--1, 1


--DELETE FROM Persona.Socio
EXEC Persona.Importar_Socios'D:\repos\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx'
SELECT * FROM Persona.Socio

--DELETE FROM Finanzas.Pago
EXEC Finanzas.Importar_Pagos 'D:\repos\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx'
SELECT * FROM Finanzas.Pago

--DELETE FROM Club.Categoria
EXEC Club.Importar_Categorias 'D:\repos\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx'
SELECT * FROM Club.Categoria

--DELETE FROM Club.Actividad
EXEC Club.Importar_Actividades'D:\repos\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx'
SELECT * FROM Club.Actividad

--DELETE FROM Persona.Socio DELETE FROM Persona.Responsable
EXEC Persona.Importar_SociosConResponsable'D:\repos\tpddbba_com5600_grupo11\Solution\import\Datos socios.xlsx'
SELECT * FROM Persona.Socio
SELECT * FROM Persona.Responsable