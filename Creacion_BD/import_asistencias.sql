
USE Com5600G11;
GO


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
    @datasrc = 'C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx',     ----- Ruta file
    @provstr = 'Excel 12.0;HDR=YES';
GO

-- Crear la tabla para registrar errores de importacion (No es temporal)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.LogErroresImportacion') AND type = N'U')
BEGIN
    CREATE TABLE psn.LogErroresImportacion (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        FechaHoraError  DATETIME DEFAULT GETDATE(),
        Nro_Socio_Excel VARCHAR(15) NULL,
        Actividad_Excel VARCHAR(50) NULL,
        Fecha_Asistencia_Excel NVARCHAR(50) NULL,
        Asistencia_Estado_Excel VARCHAR(5) NULL,
        Profesor_Excel  VARCHAR(50) NULL,
        Motivo_Error    VARCHAR(MAX)
    );
END
ELSE
BEGIN
    PRINT 'La tabla psn.LogErroresImportacion ya existe.';
END;
GO

-- Iniciar una transaccion para asegurar la atomicidad de la importacion
BEGIN TRANSACTION;
BEGIN TRY

    IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;

    CREATE TABLE #AsistenciaCruda (
        Nro_Socio_Excel     VARCHAR(15),
        Actividad_Excel     VARCHAR(50),
        Fecha_Asistencia_Excel NVARCHAR(50),
        Asistencia_Estado_Excel VARCHAR(5),
        Profesor_Excel      VARCHAR(50)
    );

    INSERT INTO #AsistenciaCruda (Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel)
    SELECT
        [Nro de Socio],
        Actividad,
        [fecha de asistencia],
        Asistencia,
        Profesor
    FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
                    'Excel 12.0;Database=C:\Users\matia\Desktop\BDDA\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx;HDR=YES',
                    'SELECT * FROM [presentismo_actividades$]');

    SELECT TOP 100 * FROM #AsistenciaCruda;

    -- Validar existencias de Socio, Actividad y Profesor y transformar la fecha.

    IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;

    CREATE TABLE #AsistenciaValidadaPaso1 (
        id_cruda            INT IDENTITY(1,1) PRIMARY KEY,
        Nro_Socio_Excel_Src VARCHAR(15),
        Actividad_Excel_Src VARCHAR(50),
        Fecha_Asistencia_Excel_Src NVARCHAR(50),
        Asistencia_Estado_Excel_Src VARCHAR(5),
        Profesor_Excel_Src  VARCHAR(50),

        cod_socio           VARCHAR(15) NOT NULL,
        cod_actividad       INT NOT NULL,
        cod_profesor        INT NOT NULL,
        fecha_asistencia    DATE NOT NULL,
        estado_asistencia   VARCHAR(5) NOT NULL,
        dia_semana_asistencia VARCHAR(9) NOT NULL -- dia de semana ('Lunes', 'Martes')
    );

    -- Insertar en la tabla validada y registrar errores de no existencia
    INSERT INTO #AsistenciaValidadaPaso1 (
        Nro_Socio_Excel_Src, Actividad_Excel_Src, Fecha_Asistencia_Excel_Src, Asistencia_Estado_Excel_Src, Profesor_Excel_Src,
        cod_socio, cod_actividad, cod_profesor, fecha_asistencia, estado_asistencia, dia_semana_asistencia
    )
    SELECT
        AC.Nro_Socio_Excel, AC.Actividad_Excel, AC.Fecha_Asistencia_Excel, AC.Asistencia_Estado_Excel, AC.Profesor_Excel,
        S.cod_socio,
        ACT.cod_actividad,
        P.cod_prof,
        TRY_CONVERT(DATE, AC.Fecha_Asistencia_Excel, 103), -- TRY_CONVERT para manejar formatos incorrectos 'DD/MM/YYYY'
        AC.Asistencia_Estado_Excel,
        DATENAME(dw, TRY_CONVERT(DATE, AC.Fecha_Asistencia_Excel, 103))
    FROM
        #AsistenciaCruda AS AC
    LEFT JOIN
        psn.Socio AS S ON AC.Nro_Socio_Excel = S.cod_socio
    LEFT JOIN
        psn.Actividad AS ACT ON AC.Actividad_Excel = ACT.nombre
    LEFT JOIN
        psn.Profesor AS P ON AC.Profesor_Excel = P.nombre
    WHERE
        S.cod_socio IS NOT NULL AND ACT.cod_actividad IS NOT NULL AND P.cod_prof IS NOT NULL
        AND TRY_CONVERT(DATE, AC.Fecha_Asistencia_Excel, 103) IS NOT NULL; -- Asegurar que la fecha es valida

    -- Registrar errores de filas que no se pudieron validar
    INSERT INTO psn.LogErroresImportacion (
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
            WHEN TRY_CONVERT(DATE, AC.Fecha_Asistencia_Excel, 103) IS NULL THEN 'Formato de fecha de asistencia invalido.'
            ELSE 'Error de validacion desconocido en Paso 2.'
        END
    FROM
        #AsistenciaCruda AS AC
    LEFT JOIN
        psn.Socio AS S ON AC.Nro_Socio_Excel = S.cod_socio
    LEFT JOIN
        psn.Actividad AS ACT ON AC.Actividad_Excel = ACT.nombre
    LEFT JOIN
        psn.Profesor AS P ON AC.Profesor_Excel = P.nombre
    WHERE
        S.cod_socio IS NULL OR ACT.cod_actividad IS NULL OR P.cod_prof IS NULL
        OR TRY_CONVERT(DATE, AC.Fecha_Asistencia_Excel, 103) IS NULL;




    -- Validar Inscripcion del Socio en la Actividad y Coincidencia del Dia de Clase. Preparar las asistencias finales para la insercion.


    IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;

    CREATE TABLE #AsistenciasFinales (
        fecha           DATE NOT NULL,
        cod_socio       VARCHAR(15) NOT NULL,
        cod_clase       INT NOT NULL,
        estado          VARCHAR(5) NOT NULL,
        cod_profesor    INT NOT NULL,
        PRIMARY KEY (fecha, cod_socio, cod_clase) -- Simula la PK de psn.Asiste para evitar duplicados del origen
    );

    -- Insertar en la tabla final solo las asistencias que cumplen todas las condiciones
    INSERT INTO #AsistenciasFinales (fecha, cod_socio, cod_clase, estado, cod_profesor)
    SELECT DISTINCT -- Usamos DISTINCT por si un socio esta inscripto en multiples clases con el mismo dia y actividad
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
    INSERT INTO psn.LogErroresImportacion (
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
            WHEN NOT EXISTS (SELECT 1 FROM psn.Inscripto I JOIN psn.Clase C ON I.cod_clase = C.cod_clase WHERE I.cod_socio = AV.cod_socio AND C.cod_actividad = AV.cod_actividad AND C.dia = AV.dia_semana_asistencia) THEN 'D�a de asistencia no coincide con ning�n d�a de clase del socio para esta actividad.'
            ELSE 'Error de validacion desconocido en Paso 3.'
        END
    FROM
        #AsistenciaValidadaPaso1 AS AV
    LEFT JOIN
        #AsistenciasFinales AS AF ON AV.cod_socio = AF.cod_socio
                                   AND AV.fecha_asistencia = AF.fecha
                                   AND AV.cod_actividad = (SELECT cod_actividad FROM psn.Clase WHERE cod_clase = AF.cod_clase)
    WHERE
        AF.fecha IS NULL; -- Si no se encontro en las asistencias finales, es un error

    -- Insertar las asistencias en la tabla final psn.Asiste

    INSERT INTO psn.Asiste (fecha, cod_socio, cod_clase, estado, cod_profesor)
    SELECT
        AF.fecha,
        AF.cod_socio,
        AF.cod_clase,
        AF.estado,
        AF.cod_profesor
    FROM
        #AsistenciasFinales AS AF
    LEFT JOIN
        psn.Asiste AS PA ON AF.fecha = PA.fecha AND AF.cod_socio = PA.cod_socio AND AF.cod_clase = PA.cod_clase
    WHERE
        PA.fecha IS NULL; -- Solo insertar si no existe un registro con la misma PK en la tabla final


    -- Si todo fue bien, confirmar la transaccion
    COMMIT TRANSACTION;
    PRINT 'Importacion completada exitosamente. Revise psn.LogErroresImportacion para posibles problemas.';

END TRY
BEGIN CATCH
    -- Si ocurre un error, revertir la transaccion
    ROLLBACK TRANSACTION;

    -- Registrar el error del CATCH en la tabla de log
    INSERT INTO psn.LogErroresImportacion (
        Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel, Motivo_Error
    )
    SELECT TOP 1 -- Para capturar el contexto del error mas reciente o general si es posible
        Nro_Socio_Excel, Actividad_Excel, Fecha_Asistencia_Excel, Asistencia_Estado_Excel, Profesor_Excel,
        'Error general en el proceso de importacion: ' + ERROR_MESSAGE()
    FROM
        #AsistenciaCruda
    ORDER BY (SELECT NULL); -- No importa el orden, solo toma uno para el log de error general

    PRINT 'Importaci�n fallida. La transaccion ha sido revertida. Error: ' + ERROR_MESSAGE();

END CATCH;


-- Limpieza de Tablas Temporales

IF OBJECT_ID('tempdb..#AsistenciaCruda') IS NOT NULL DROP TABLE #AsistenciaCruda;
IF OBJECT_ID('tempdb..#AsistenciaValidadaPaso1') IS NOT NULL DROP TABLE #AsistenciaValidadaPaso1;
IF OBJECT_ID('tempdb..#AsistenciasFinales') IS NOT NULL DROP TABLE #AsistenciasFinales;
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