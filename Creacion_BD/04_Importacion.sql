/*
====================================================================================
 Archivo		: 04_Procedimientos_Tablas.sql
 Proyecto		: Institución Deportiva Sol Norte.
 Descripción	: Scripts para importar datos a las tablas desde xls y csv.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Versión		: 1.0
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

--	Habilito el pasaje de parámetros a las consultas dinámicas.
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;		
GO

--Chequear nombre del servicio para  darle permiso de acceso a los directorios donde se guarda la información.
SELECT servicename, service_account			
FROM sys.dm_server_services;

/*
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
FROM OPENQUERY(LinkerServer_EXCEL, 'SELECT TOP 1 * FROM [Tarifas$]');
GO
*/	-- En algunas importaciones se uso un linker server, en otras no.

----------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------
--	Crear el esquema.
----------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
	BEGIN
		EXEC('CREATE SCHEMA imp');
		PRINT ' Schema creado exitosamente';
	END;
GO

----------------------------------------------------------------------------------------------------------------
--	IMPORTAR HOJA DE PAGOS
----------------------------------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
--	IMPORTAR HOJA DE SOCIOS
----------------------------------------------------------------------------------------------------------------

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

	-- Variables formateadas
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
		SET @cod_socio				= LEFT(LTRIM(RTRIM(@tcod_socio)), 15);
		SET @nombre					= LEFT(LTRIM(RTRIM(@tnombre)), 50);
		SET @apellido				= LEFT(LTRIM(RTRIM(@tapellido)), 50);
		SET @dni					= LEFT(LTRIM(RTRIM(@tdni)), 8);
		SET @email					= LEFT(LTRIM(RTRIM(@temail)), 100);
		SET @fecha_nac				= TRY_CONVERT(DATE, REPLACE(LTRIM(RTRIM(@tfecha_nac)), CHAR(160), ''), 103); -- dd/MM/yyyy
		SET @tel					= LEFT(LTRIM(RTRIM(@ttel)), 15);
		SET @tel_emerg				= LEFT(LTRIM(RTRIM(@ttel_emerg)), 15);
		SET @nombre_cobertura		= LEFT(LTRIM(RTRIM(@tnombre_cobertura)), 50);
		SET @nro_afiliado			= LEFT(LTRIM(RTRIM(@tnro_afiliado)), 50);
		SET @tel_cobertura			= LEFT(LTRIM(RTRIM(@ttel_cobertura)), 15);

		-- Validación
		IF @cod_socio IS NOT NULL AND @nombre <> '' AND @apellido <> '' AND @dni <> ''
		BEGIN TRY
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
		END TRY
		BEGIN CATCH
			SET @filas_ignoradas += 1;

			-- Mostrar información útil
			PRINT 'Fila ignorada: Socio=' + ISNULL(@cod_socio, 'NULL') +
				  ', Nombre=' + ISNULL(@nombre, 'NULL') +
				  ', Apellido=' + ISNULL(@apellido, 'NULL') +
				  ', DNI=' + ISNULL(@dni, 'NULL');

			PRINT 'Error: ' + ERROR_MESSAGE();
		END CATCH

		FETCH NEXT FROM cur INTO 
			@tcod_socio, @tnombre, @tapellido, @tdni, @temail, @tfecha_nac,
			@ttel, @ttel_emerg, @tnombre_cobertura, @tnro_afiliado, @ttel_cobertura;
	END
	CLOSE cur;
	DEALLOCATE cur;
	DROP TABLE ##Temp
	PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
	PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END
GO

----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
--	IMPORTAR HOJA DE ACTIVIDADES
----------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Actividades') 
BEGIN
    DROP PROCEDURE imp.Importar_Actividades;
    PRINT 'Importar_Actividades existía y fue borrado';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Actividades
	@RutaArchivo NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	-- Limpieza tabla temporal si existe
	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
		DROP TABLE ##Temp;

	CREATE TABLE ##Temp
	(
		tnombre				VARCHAR(255),
		tvalor_mensual		VARCHAR(255),
		tvig_valor			VARCHAR(255)
	);

	DECLARE @filas_importadas INT = 0, @filas_ignoradas INT = 0;

	DECLARE @SQL NVARCHAR(MAX);
	SET @SQL = '
    INSERT INTO ##Temp
    SELECT 
        CONVERT(VARCHAR(255), F1),
        CONVERT(VARCHAR(255), F2),
        CONVERT(VARCHAR(255), F3)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Tarifas$B2:D8]''
    )
    WHERE F1 IS NOT NULL';
	EXEC sp_executesql @SQL;
	
	-- Elimina encabezado
	DELETE FROM ##Temp WHERE tnombre = 'Actividad';
	
	-- Variables cursor
	DECLARE 
		@tnombre				VARCHAR(255),
		@tvalor_mensual			VARCHAR(255),
		@tvig_valor				VARCHAR(255);

	-- Variables formateadas
	DECLARE 
		@nombre			VARCHAR(50),
		@valor_mensual	DECIMAL(10,2),
		@vig_valor		DATE;

	DECLARE cur CURSOR LOCAL FAST_FORWARD FOR 
		SELECT tnombre, tvalor_mensual, tvig_valor FROM ##Temp;

	OPEN cur;

	-- Primer fetch antes del WHILE
	FETCH NEXT FROM cur INTO @tnombre, @tvalor_mensual, @tvig_valor;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Limpieza y conversión
		SET @nombre					= LEFT(LTRIM(RTRIM(@tnombre)), 50);
		SET @valor_mensual			= TRY_CONVERT(DECIMAL(10,2),REPLACE(LTRIM(RTRIM(@tvalor_mensual)), CHAR(160), ''));
		SET @vig_valor				= TRY_CONVERT(DATE, REPLACE(LTRIM(RTRIM(@tvig_valor)), CHAR(160), ''), 103); -- dd/MM/yyyy

		IF @nombre IS NOT NULL AND @vig_valor IS NOT NULL AND @valor_mensual IS NOT NULL
		BEGIN TRY
			EXEC stp.insertarActividad
				@nombre = @nombre,
				@vig_valor = @vig_valor,
				@valor_mensual = @valor_mensual;
			SET @filas_importadas += 1;
		END TRY
		BEGIN CATCH
			SET @filas_ignoradas += 1;
			PRINT 'Fila ignorada: Nombre=' + ISNULL(@nombre, 'NULL') +
				  ', Valor=' + ISNULL(CAST(@valor_mensual AS VARCHAR(20)), 'NULL') +
				  ', Vig=' + ISNULL(CONVERT(VARCHAR, @vig_valor, 103), 'NULL');
			PRINT 'Error: ' + ERROR_MESSAGE();
		END CATCH

		-- Fetch siguiente para continuar el loop
		FETCH NEXT FROM cur INTO @tnombre, @tvalor_mensual, @tvig_valor;
	END

	CLOSE cur;
	DEALLOCATE cur;
	DROP TABLE ##Temp;
	PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
	PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END
GO

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
--	IMPORTAR HOJA DE CATEGORIAS
----------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Categorias') 
BEGIN
    DROP PROCEDURE imp.Importar_Categorias;
    PRINT 'Importar_Categorias existía y fue borrado';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Categorias
	@RutaArchivo NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	-- Limpieza tabla temporal si existe
	IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
		DROP TABLE ##Temp;

	CREATE TABLE ##Temp
	(
		tdescripcion		VARCHAR(255),
		tvalor_mensual		VARCHAR(255),
		tvig_valor_mens		VARCHAR(255)--,
		--tvalor_anual		VARCHAR(255),
		--tvig_valor_anual	VARCHAR(255)
	);

	DECLARE @filas_importadas INT = 0, @filas_ignoradas INT = 0;

	DECLARE @SQL NVARCHAR(MAX);
	SET @SQL = '
    INSERT INTO ##Temp
    SELECT 
        CONVERT(VARCHAR(255), F1),
        CONVERT(VARCHAR(255), F2),
        CONVERT(VARCHAR(255), F3)
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=NO;IMEX=1;Database=' + @RutaArchivo + ''',
        ''SELECT * FROM [Tarifas$B10:D13]''
    )
    WHERE F1 IS NOT NULL';
	EXEC sp_executesql @SQL;
	
	-- Elimina encabezado
	DELETE FROM ##Temp WHERE tdescripcion = 'Actividad';
	-- Variables cursor
	DECLARE 
		@tdescripcion			VARCHAR(255),
		@tvalor_mensual			VARCHAR(255),
		@tvig_valor_mens		VARCHAR(255);

	-- Variables formateadas
	DECLARE 
		@descripcion	VARCHAR(50),
		@valor_mensual	DECIMAL(10,2),
		@vig_valor_mens	DATE;

	DECLARE cur CURSOR LOCAL FAST_FORWARD FOR 
		SELECT tdescripcion, tvalor_mensual, tvig_valor_mens FROM ##Temp;

	OPEN cur;

	-- Primer fetch antes del WHILE
	FETCH NEXT FROM cur INTO @tdescripcion, @tvalor_mensual, @tvig_valor_mens;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Limpieza y conversión
		SET @descripcion					= LEFT(LTRIM(RTRIM(@tdescripcion)), 50);
		SET @valor_mensual			= TRY_CONVERT(DECIMAL(10,2),REPLACE(LTRIM(RTRIM(@tvalor_mensual)), CHAR(160), ''));
		SET @vig_valor_mens				= TRY_CONVERT(DATE, REPLACE(LTRIM(RTRIM(@tvig_valor_mens)), CHAR(160), ''), 103); -- dd/MM/yyyy

		IF @descripcion IS NOT NULL AND @valor_mensual IS NOT NULL AND @vig_valor_mens IS NOT NULL
		BEGIN TRY
			EXEC stp.insertarCategoria
				@descripcion = @descripcion,
				@vig_valor_mens = @vig_valor_mens,
				@valor_mensual = @valor_mensual,
				@edad_max = 10,
				@valor_anual = 10.0,
				@vig_valor_anual = '27/07/2031';
			SET @filas_importadas += 1;
		END TRY
		BEGIN CATCH
			SET @filas_ignoradas += 1;
			PRINT 'Fila ignorada: Nombre=' + ISNULL(@descripcion, 'NULL') +
				  ', Valor=' + ISNULL(CAST(@valor_mensual AS VARCHAR(20)), 'NULL') +
				  ', Vig=' + ISNULL(CONVERT(VARCHAR, @vig_valor_mens, 103), 'NULL');
			PRINT 'Error: ' + ERROR_MESSAGE();
		END CATCH

		-- Fetch siguiente para continuar el loop
		FETCH NEXT FROM cur INTO @tdescripcion, @tvalor_mensual, @tvig_valor_mens;
	END

	CLOSE cur;
	DEALLOCATE cur;
	DROP TABLE ##Temp;
	PRINT 'Filas importadas: ' + CAST(@filas_importadas AS VARCHAR);
	PRINT 'Filas ignoradas: ' + CAST(@filas_ignoradas AS VARCHAR);
END
GO

----------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
--	IMPORTAR HOJA DE ASISTENCIAS
----------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Asistencias') 
BEGIN
    DROP PROCEDURE imp.Importar_Asistencias;
    PRINT 'Importar_Asistencias existía y fue borrado';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Asistencias
    @RutaArchivo NVARCHAR(255),
	@nombreHoja NVARCHAR(255),
	@mostrarErrores INT,
	@mostrarImportadas INT
AS
BEGIN
    IF @mostrarErrores NOT BETWEEN 0 AND 1
        THROW 50001, 'El parámetro @mostrarErrores debe ser 0 o 1.', 1;

    IF @mostrarImportadas NOT BETWEEN 0 AND 1
        THROW 50002, 'El parámetro @mostrarImportadas debe ser 0 o 1.', 1;

	SET NOCOUNT ON;

-- Crear la tabla para registrar errores de importacion
	IF OBJECT_ID('tempdb..#LogErroresImportacion') IS NOT NULL DROP TABLE #LogErroresImportacion;
	CREATE TABLE #LogErroresImportacion (
		Id              INT IDENTITY(1,1) PRIMARY KEY,
   		FechaHoraError  DATETIME DEFAULT GETDATE(),
   		Nro_Socio_Excel VARCHAR(15) NULL,
   		Actividad_Excel VARCHAR(50) NULL,
   		Fecha_Asistencia_Excel NVARCHAR(50) NULL,
   		Asistencia_Estado_Excel VARCHAR(5) NULL,
   		Profesor_Excel  VARCHAR(50) NULL,
   		Motivo_Error    VARCHAR(MAX)
	);

	BEGIN TRANSACTION;
	BEGIN TRY

		SET LANGUAGE 'Spanish';
		
   		IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;

   		CREATE TABLE #AsistenciaCruda (
       		Nro_Socio_Excel     VARCHAR(15),
       		Actividad_Excel     VARCHAR(50),
       		Fecha_Asistencia_Excel NVARCHAR(50),
       		Asistencia_Estado_Excel VARCHAR(5),
       		Profesor_Excel      VARCHAR(50)
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
				''SELECT * FROM [' + @nombreHoja + '$]''
			);';
   		
		EXEC(@Comando);
   		-- Validar existencias de Socio, Actividad y Profesor y transformar la fecha.

   		IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;

   		CREATE TABLE #AsistenciaValidadaPaso1 (
       		id_cruda            INT IDENTITY(1,1) PRIMARY KEY,
       		Nro_Socio_Excel_Src VARCHAR(15),
       		Actividad_Excel_Src VARCHAR(50),
       		Fecha_Asistencia_Excel_Src NVARCHAR(50),
       		Asistencia_Estado_Excel_Src VARCHAR(5),
       		Profesor_Excel_Src  VARCHAR(50),

       		cod_socio           VARCHAR(15) NOT NULL,
       		cod_actividad       INT NOT NULL,
       		cod_profesor        INT NOT NULL,
       		fecha_asistencia    DATE NOT NULL,
       		estado_asistencia   CHAR(1) NOT NULL,
       		dia_semana_asistencia VARCHAR(9) NOT NULL -- dia de semana ('Lunes', 'Martes')
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
			AND LEFT(AC.Asistencia_Estado_Excel, 1) IN ('P','A','J'); -- [MODIFICACION]: Reestablecido el filtro de estados válidos


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
           		WHEN TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE) IS NULL THEN 'Formato de fecha de asistencia inválido: ' + AC.Fecha_Asistencia_Excel
           		WHEN LEFT(AC.Asistencia_Estado_Excel, 1) NOT IN ('P','A','J') THEN 'Estado de asistencia inválido: ' + AC.Asistencia_Estado_Excel
           		ELSE 'Error de validación desconocido en Paso 2.'
       		END
   		FROM
       		#AsistenciaCruda AS AC
   		LEFT JOIN
       		psn.Socio AS S ON AC.Nro_Socio_Excel = S.cod_socio
   		LEFT JOIN
       		psn.Actividad AS ACT ON AC.Actividad_Excel = ACT.nombre
   		LEFT JOIN
       		psn.Profesor AS P ON TRIM(AC.Profesor_Excel) = P.nombre + ' ' + P.apellido COLLATE Modern_Spanish_CI_AS 
   		WHERE
       		S.cod_socio IS NULL
       		OR ACT.cod_actividad IS NULL
       		OR P.cod_prof IS NULL
       		OR TRY_CAST(AC.Fecha_Asistencia_Excel AS DATE) IS NULL
       		OR LEFT(AC.Asistencia_Estado_Excel, 1) NOT IN ('P','A','J');


   		-- Validar Inscripcion del Socio en la Actividad y Coincidencia del Dia de Clase. Preparar las asistencias finales para la insercion.


   		IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;

   		CREATE TABLE #AsistenciasFinales (
       		fecha           DATE NOT NULL,
       		cod_socio       VARCHAR(15) NOT NULL,
       		cod_clase       INT NOT NULL,
       		estado          CHAR(1) NOT NULL,
       		cod_profesor    INT NOT NULL,
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
       		psn.Inscripto AS I ON AV.cod_socio = I.cod_socio
   		INNER JOIN
       		psn.Clase AS C ON I.cod_clase = C.cod_clase
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
           		WHEN NOT EXISTS (SELECT 1 FROM psn.Inscripto I JOIN psn.Clase C ON I.cod_clase = C.cod_clase WHERE I.cod_socio = AV.cod_socio AND C.cod_actividad = AV.cod_actividad) THEN 'Socio no inscripto en la actividad especificada.'
           		WHEN NOT EXISTS (SELECT 1 FROM psn.Inscripto I JOIN psn.Clase C ON I.cod_clase = C.cod_clase WHERE I.cod_socio = AV.cod_socio AND C.cod_actividad = AV.cod_actividad AND C.dia = AV.dia_semana_asistencia) THEN 'Día de asistencia no coincide con ningún día de clase del socio para esta actividad.'
           		ELSE 'Validación de inscripción o clase fallida. (Motivo no especificado en CASE)' -- [MODIFICACION]: Mensaje más descriptivo
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

   		DECLARE @Fecha DATE;
   		DECLARE @CodSocio VARCHAR(15);
   		DECLARE @CodClase INT;
   		DECLARE @Estado CHAR(1);

   		-- Crear un cursor para iterar sobre las filas de #AsistenciasFinales que NO existen en psn.Asiste
   		DECLARE cur_asistencias CURSOR LOCAL FORWARD_ONLY FOR
   		SELECT
       		AF.fecha,
       		AF.cod_socio,
       		AF.cod_clase,
       		AF.estado
   		FROM
       		#AsistenciasFinales AS AF
   		LEFT JOIN
       		psn.Asiste AS PA ON AF.fecha = PA.fecha AND AF.cod_socio = PA.cod_socio AND AF.cod_clase = PA.cod_clase
   		WHERE
       		PA.fecha IS NULL;

   		OPEN cur_asistencias;

   		FETCH NEXT FROM cur_asistencias INTO @Fecha, @CodSocio, @CodClase, @Estado;

   		WHILE @@FETCH_STATUS = 0
   		BEGIN

       		EXEC stp.insertarAsiste
           		@fecha      = @Fecha,
           		@cod_socio  = @CodSocio,
           		@cod_clase  = @CodClase,
           		@estado     = @Estado

       		FETCH NEXT FROM cur_asistencias INTO @Fecha, @CodSocio, @CodClase, @Estado;
   		END;

   		CLOSE cur_asistencias;
   		DEALLOCATE cur_asistencias;


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

   		PRINT 'Importación fallida. La transaccion ha sido revertida. Error: ' + ERROR_MESSAGE();

	END CATCH;

	IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;
	IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;
	IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;
	IF OBJECT_ID('tempdb..#LogErroresImportacion') IS NOT NULL DROP TABLE #LogErroresImportacion;
END
GO
--EXEC imp.Importar_Asistencias 
--'C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios prueba.xlsx',
--'presentismo_actividades',
--1, 1

----------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------
--	EJECUCION DE LAS IMPORTACIONES
----------------------------------------------------------------------------------------------------------------

