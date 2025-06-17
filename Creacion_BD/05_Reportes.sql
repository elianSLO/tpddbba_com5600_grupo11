
---- REPORTES

--Crear el Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Rep')
	BEGIN
		EXEC('CREATE SCHEMA Rep');
		PRINT ' Schema creado exitosamente';
	END;
go

-- REPORTE 1: Socios Morosos

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_SociosMorosos_XML') 
BEGIN
    DROP PROCEDURE Rep.Reporte_SociosMorosos_XML;
    PRINT 'SP Reporte_SociosMorosos_XML ya existe. Se crear� nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_SociosMorosos_XML
	@fechaInicio DATE,
	@fechaFin DATE 
AS
BEGIN
	SET NOCOUNT ON;
	WITH FacturasVencidas AS (
		SELECT
			f.cod_socio,
			s.nombre,
			s.apellido,
			FORMAT(f.fecha_vto, 'yyyy-MM') AS mes_incumplido
		FROM psn.Factura f
		INNER JOIN psn.Socio s ON f.cod_socio = s.cod_socio
		WHERE f.estado = 'Vencida'
		AND f.fecha_vto BETWEEN @fechaInicio AND @fechaFin
	),
	ConteoMorosidad AS (
		SELECT 
			cod_socio,
			nombre,
			apellido,
			mes_incumplido,
			COUNT(*) OVER (PARTITION BY cod_socio) AS veces_moroso
		FROM FacturasVencidas
	),
	MorososFiltrados AS (
		SELECT *
		FROM ConteoMorosidad
		WHERE veces_moroso > 2
	)
	SELECT 
		cod_socio AS [@cod_socio],
		nombre AS [Nombre],
		apellido AS [Apellido],
		mes_incumplido AS [MesIncumplido],
		veces_moroso AS [RankingMorosidad]
	FROM MorososFiltrados
	ORDER BY veces_moroso DESC
	FOR XML PATH('Socio'), ROOT('MorososRecurrentes');
END;
GO

-- REPORTE 2: Ingresos Mensuales

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_IngresosMensuales_XML') 
BEGIN
    DROP PROCEDURE Rep.Reporte_IngresosMensuales_XML;
    PRINT 'SP Reporte_IngresosMensuales_XML ya existe. Se crear� nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_IngresosMensuales_XML
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE 1: Ingresos mensuales por actividad
    WITH IngresosMensuales AS (
        SELECT
            A.cod_actividad,
            A.nombre AS nombre_actividad,
            YEAR(F.fecha_emision) AS anio,
            MONTH(F.fecha_emision) AS mes,
            SUM(I.monto) AS ingreso_mensual
        FROM psn.Factura F
        INNER JOIN psn.Item_Factura I ON F.cod_Factura = I.cod_Factura
        INNER JOIN psn.Clase C ON CAST(I.descripcion AS INT) = C.cod_clase
        INNER JOIN psn.Actividad A ON C.cod_actividad = A.cod_actividad
        WHERE 
            F.estado = 'Pagada'
            AND F.fecha_emision >= '2025-01-01'
            AND F.fecha_emision <= GETDATE()
        GROUP BY
            A.cod_actividad, A.nombre, YEAR(F.fecha_emision), MONTH(F.fecha_emision)
    ),
    -- CTE 2: Acumulado mensual por actividad
    IngresosAcumulados AS (
        SELECT
            cod_actividad,
            nombre_actividad,
            anio,
            mes,
            ingreso_mensual,
            SUM(ingreso_mensual) OVER (PARTITION BY cod_actividad, anio ORDER BY mes) AS ingreso_acumulado
        FROM IngresosMensuales
    )
    
    -- Resultado final en formato XML
    SELECT
        cod_actividad        AS [@cod_actividad],
        nombre_actividad     AS [NombreActividad],
        anio                 AS [A�o],
        mes                  AS [Mes],
        ingreso_mensual      AS [IngresoMensual],
        ingreso_acumulado    AS [IngresoAcumulado]
    FROM IngresosAcumulados
    ORDER BY nombre_actividad, anio, mes
    FOR XML PATH('Actividad'), ROOT('IngresosMensuales');
END;
GO

-- REPORTE 3: Inasistencias

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_Inasistencias_XML') 
BEGIN
    DROP PROCEDURE Rep.Reporte_Inasistencias_XML;
    PRINT 'SP Reporte_Inasistencias_XML ya existe. Se crear� nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_Inasistencias_XML
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE: Inscriptos y clases asociadas
    WITH Inscriptos AS (
        SELECT 
            I.cod_socio,
            I.cod_clase,
            I.fecha_inscripcion,
            C.categoria,
            C.cod_actividad,
            A.nombre AS nombre_actividad
        FROM psn.Inscripto I
        INNER JOIN psn.Clase C ON I.cod_clase = C.cod_clase
        INNER JOIN psn.Actividad A ON C.cod_actividad = A.cod_actividad
    ),

    -- CTE: Asistencias efectivas
    Asistencias AS (
        SELECT 
            cod_socio,
            cod_clase,
            fecha
        FROM psn.Asiste
    ),

    -- CTE: Total de fechas distintas de asistencia por clase (como si fueran clases dictadas)
    FechasDictadas AS (
        SELECT DISTINCT
            cod_clase,
            fecha
        FROM psn.Asiste
    ),

    -- CTE: Generar posibles asistencias esperadas (por clase y socio)
    PosiblesAsistencias AS (
        SELECT 
            I.cod_socio,
            I.cod_clase,
            F.fecha,
            I.categoria,
            I.cod_actividad,
            I.nombre_actividad
        FROM Inscriptos I
        INNER JOIN FechasDictadas F 
            ON I.cod_clase = F.cod_clase
           AND F.fecha >= I.fecha_inscripcion
    ),

    -- CTE: Inasistencias (cuando no fue en una fecha dictada)
    Inasistencias AS (
        SELECT 
            PA.cod_socio,
            PA.cod_clase,
            PA.fecha,
            PA.categoria,
            PA.cod_actividad,
            PA.nombre_actividad
        FROM PosiblesAsistencias PA
        LEFT JOIN Asistencias A
            ON PA.cod_socio = A.cod_socio
           AND PA.cod_clase = A.cod_clase
           AND PA.fecha = A.fecha
        WHERE A.cod_socio IS NULL
    ),

    -- CTE: Conteo por categor�a y actividad
    ConteoInasistencias AS (
        SELECT 
            categoria,
            cod_actividad,
            nombre_actividad,
            COUNT(*) AS cantidad_inasistencias
        FROM Inasistencias
        GROUP BY categoria, cod_actividad, nombre_actividad
    )

    -- Resultado en XML
    SELECT
        categoria               AS [@categoria],
        cod_actividad           AS [@cod_actividad],
        nombre_actividad        AS [Actividad],
        cantidad_inasistencias  AS [Inasistencias]
    FROM ConteoInasistencias
    ORDER BY cantidad_inasistencias DESC
    FOR XML PATH('Registro'), ROOT('InasistenciasPorCategoria');
END;
GO

-- REPORTE 4: Socios con Inasistencias

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_SociosConInasistencias_XML') 
BEGIN
    DROP PROCEDURE Rep.Reporte_SociosConInasistencias_XML;
    PRINT 'SP Reporte_SociosConInasistencias_XML ya existe. Se crear� nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_SociosConInasistencias_XML
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE: Fechas en que se dictaron clases (tomadas desde la tabla Asiste)
    WITH FechasDictadas AS (
        SELECT DISTINCT 
            cod_clase,
            fecha
        FROM psn.Asiste
    ),

    -- CTE: Socios inscriptos a clases
    Inscriptos AS (
        SELECT 
            cod_socio,
            cod_clase,
            fecha_inscripcion
        FROM psn.Inscripto
    ),

    -- CTE: Generar combinaciones esperadas de clase-socio-fecha
    ClasesEsperadas AS (
        SELECT 
            i.cod_socio,
            fd.cod_clase,
            fd.fecha
        FROM FechasDictadas fd
        INNER JOIN Inscriptos i 
            ON fd.cod_clase = i.cod_clase
           AND fd.fecha >= i.fecha_inscripcion
    ),

    -- CTE: Asistencias reales
    Asistencias AS (
        SELECT 
            cod_socio,
            cod_clase,
            fecha
        FROM psn.Asiste
    ),

    -- CTE: Inasistencias (cuando el socio no fue a una clase en la que deber�a haber estado)
    Inasistencias AS (
        SELECT 
            ce.cod_socio,
            ce.cod_clase,
            ce.fecha
        FROM ClasesEsperadas ce
        LEFT JOIN Asistencias a
            ON ce.cod_socio = a.cod_socio
           AND ce.cod_clase = a.cod_clase
           AND ce.fecha = a.fecha
        WHERE a.cod_socio IS NULL
    ),

    -- CTE: �ltima categor�a del socio seg�n la suscripci�n m�s reciente
    UltimaCategoria AS (
        SELECT 
            sus.cod_socio,
            cat.descripcion AS categoria,
            ROW_NUMBER() OVER (PARTITION BY sus.cod_socio ORDER BY sus.fecha_suscripcion DESC) AS rn
        FROM psn.Suscripcion sus
        INNER JOIN psn.Categoria cat ON sus.cod_categoria = cat.cod_categoria
    ),

    -- CTE: Detalles de socios con al menos una inasistencia
    DetallesSociosInasistentes AS (
        SELECT DISTINCT
            s.cod_socio,
            s.nombre,
            s.apellido,
            DATEDIFF(YEAR, s.fecha_nac, GETDATE()) AS edad,
            uc.categoria,
            act.nombre AS actividad
        FROM Inasistencias i
        INNER JOIN psn.Socio s ON i.cod_socio = s.cod_socio
        INNER JOIN psn.Clase c ON i.cod_clase = c.cod_clase
        INNER JOIN psn.Actividad act ON c.cod_actividad = act.cod_actividad
        INNER JOIN UltimaCategoria uc ON s.cod_socio = uc.cod_socio AND uc.rn = 1
    )

    -- Resultado final en XML
    SELECT 
        nombre      AS [Nombre],
        apellido    AS [Apellido],
        edad        AS [Edad],
        categoria   AS [Categoria],
        actividad   AS [Actividad]
    FROM DetallesSociosInasistentes
    ORDER BY apellido, nombre
    FOR XML PATH('Socio'), ROOT('SociosConInasistencias');
END;
GO

-- PRUEBA

EXEC Rep.Reporte_SociosMorosos_XML @fechaInicio = '2025-01-01', @fechaFin = '2026-01-01'

EXEC Rep.Reporte_IngresosMensuales_XML

EXEC Rep.Reporte_Inasistencias_XML

EXEC Rep.Reporte_SociosConInasistencias_XML
