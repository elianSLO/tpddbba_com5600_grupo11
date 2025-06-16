USE Com5600G11;
GO


-- PREPARAR PARA TESTEAR

--DROP TABLE psn.Profesor;
--DROP TABLE psn.Clase;
--DROP TABLE psn.Actividad;
--DROP TABLE psn.Categoria;
--DROP TABLE psn.Socio;

--EXEC stp.insertarSocio
--    @cod_socio = 'SN-4148',
--    @dni = '12345678',
--    @nombre = 'Pablo',
--    @apellido = 'Rodriguez',
--    @fecha_nac = '1990-05-15',
--    @email = 'juan.perez@mail.com',
--    @tel = '1122334455',
--    @tel_emerg = '1133445566',
--    @estado = 1,
--    @saldo = 0,
--    @nombre_cobertura = 'OSDE',
--    @nro_afiliado = 'OS12345678',
--    @tel_cobertura = '1144556677',
--    @cod_responsable = NULL;

--EXEC stp.insertarProfesor 
--    @dni = '12345678',
--    @nombre = 'Pablo',
--    @apellido = 'Rodrigez',
--    @email = 'juan.perez@email.com',
--    @tel = '9876114321';

--EXEC stp.insertarActividad
--    @nombre = 'Futsal',
--    @valor_mensual = 250000,
--    @vig_valor = '2026-01-01';

--EXEC stp.insertarCategoria 'Cadete', 14, 1800.00, '2025-12-31', 18000.00, '2025-12-31';

--EXEC stp.insertarClase 
--    @categoria = 1, 
--    @cod_actividad = 1, 
--    @cod_prof = 1, 
--    @dia = 'Lunes', 
--    @horario = '18:00';


--DECLARE @FechaActual DATE;
--SET @FechaActual = CAST(GETDATE() AS DATE);
--EXEC stp.insertarInscripto
--    @fecha_inscripcion = @FechaActual,
--    @estado            = 1,
--    @cod_socio         = 'SN-4148',
--    @cod_clase         = 1;

--SELECT TOP 1 A.cod_actividad, A.nombre, C.cod_clase, C.dia, C.cod_prof, P.nombre, P.apellido FROM [Com5600G11].[psn].[Actividad] A
--INNER JOIN [Com5600G11].[psn].[Clase] C 
--ON C.cod_actividad = A.cod_actividad
--INNER JOIN [Com5600G11].[psn].[Profesor] P
--ON P.cod_prof = C.cod_prof

--SELECT TOP 1 * FROM psn.Inscripto


-------- IMPORTAR PRESENTISMO
SET LANGUAGE 'Spanish';
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO


EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
GO

EXEC sp_addlinkedserver
    @server = 'LinkedServer_Asistencias',
    @srvproduct = 'ACE 12.0',
    @provider = 'Microsoft.ACE.OLEDB.12.0',
    @datasrc = 'C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios prueba.xlsx',     ----- Ruta file
    @provstr = 'Excel 12.0;HDR=YES';
GO

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

    IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;

    CREATE TABLE #AsistenciaCruda (
        Nro_Socio_Excel     VARCHAR(15),
        Actividad_Excel     VARCHAR(50),
        Fecha_Asistencia_Excel NVARCHAR(50),
        Asistencia_Estado_Excel VARCHAR(5),
        Profesor_Excel      VARCHAR(50)
    );

    INSERT INTO #AsistenciaCruda (Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel)
    SELECT
        [Nro de Socio],
        Actividad,
        [fecha de asistencia],
        Asistencia,
        Profesor
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
                    'Excel 12.0;Database=C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios prueba.xlsx;HDR=YES',
                    'SELECT * FROM [presentismo_actividades$]');

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
	SELECT * FROM #AsistenciasFinales;
	SELECT * FROM #LogErroresImportacion;

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


-- Limpieza de Tablas Temporales

IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;
IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;
IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;
IF OBJECT_ID('tempdb..#LogErroresImportacion') IS NOT NULL DROP TABLE #LogErroresImportacion;
GO


-- Crear esquema de importacion
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
	BEGIN
		EXEC('CREATE SCHEMA imp');
		PRINT 'Esquema "imp" creado exitosamente.';
	END;
GO

-- Limpieza del Linked Server
PRINT 'Eliminando Linked Server "LinkedServer_Asistencias"...';
IF EXISTS (SELECT * FROM sys.servers WHERE name = 'LinkedServer_Asistencias')
BEGIN
    EXEC sp_dropserver 'LinkedServer_Asistencias', 'droplogins';
    PRINT 'Linked Server "LinkedServer_Asistencias" eliminado.';
END
ELSE
BEGIN
    PRINT 'Linked Server "LinkedServer_Asistencias" no existe para eliminar.';
END;
GO