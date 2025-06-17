
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
    PRINT 'SP Reporte_SociosMorosos_XML ya existe. Se creará nuevamente.';
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
    PRINT 'SP Reporte_IngresosMensuales_XML ya existe. Se creará nuevamente.';
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
        anio                 AS [Año],
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
    DROP PROCEDURE Rep.Reporte_IngresosMensuales_XML;
    PRINT 'SP Reporte_Inasistencias_XML ya existe. Se creará nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_Inasistencias_XML
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE: Todas las clases dictadas
    WITH ClasesProgramadas AS (
        SELECT 
            cod_clase,
            fecha
        FROM psn.Clase_Dictada
    ),

    -- CTE: Asistencias registradas
    Asistencias AS (
        SELECT 
            A.cod_socio,
            CD.cod_clase,
            CD.fecha
        FROM psn.Asiste A
        INNER JOIN psn.Clase_Dictada CD ON A.cod_clase = CD.cod_clase AND A.fecha = CD.fecha
    ),

    -- CTE: Posibles asistencias esperadas por socio (basado en inscripción)
    PosiblesAsistencias AS (
        SELECT 
            I.cod_socio,
            CD.cod_clase,
            CD.fecha
        FROM psn.Inscripto I
        INNER JOIN psn.Clase_Dictada CD ON I.cod_clase = CD.cod_clase
        WHERE CD.fecha >= I.fecha_inscripcion
    ),

    -- CTE: Inasistencias = clases que el socio debería haber ido pero no fue
    Inasistencias AS (
        SELECT 
            PA.cod_socio,
            PA.cod_clase,
            PA.fecha
        FROM PosiblesAsistencias PA
        LEFT JOIN Asistencias A 
            ON PA.cod_socio = A.cod_socio 
            AND PA.cod_clase = A.cod_clase 
            AND PA.fecha = A.fecha
        WHERE A.cod_socio IS NULL
    ),

    -- CTE: Enriquecer con datos de actividad y categoría
    InasistenciasDetalle AS (
        SELECT 
            I.cod_socio,
            S.categoria,
            A.cod_actividad,
            Act.nombre AS nombre_actividad
        FROM Inasistencias I
        INNER JOIN psn.Socio S ON I.cod_socio = S.cod_socio
        INNER JOIN psn.Clase C ON I.cod_clase = C.cod_clase
        INNER JOIN psn.Actividad Act ON C.cod_actividad = Act.cod_actividad
    ),

    -- CTE: Contar inasistencias por categoría y actividad
    ConteoInasistencias AS (
        SELECT 
            categoria,
            cod_actividad,
            nombre_actividad,
            COUNT(*) AS cantidad_inasistencias
        FROM InasistenciasDetalle
        GROUP BY categoria, cod_actividad, nombre_actividad
    )

    -- Resultado final
    SELECT
        categoria             AS [@categoria],
        cod_actividad         AS [@cod_actividad],
        nombre_actividad      AS [Actividad],
        cantidad_inasistencias AS [Inasistencias]
    FROM ConteoInasistencias
    ORDER BY cantidad_inasistencias DESC
    FOR XML PATH('Registro'), ROOT('InasistenciasPorCategoria');
END;
GO

-- REPORTE 4: 

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_SociosConInasistencias_XML') 
BEGIN
    DROP PROCEDURE Rep.Reporte_IngresosMensuales_XML;
    PRINT 'SP Reporte_SociosConInasistencias_XML ya existe. Se creará nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_SociosConInasistencias_XML
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE: Todas las clases dictadas para las actividades donde hay socios inscriptos
    WITH ClasesProgramadas AS (
        SELECT 
            cd.cod_clase,
            cd.fecha,
            i.cod_socio
        FROM psn.Clase_Dictada cd
        INNER JOIN psn.Inscripto i 
            ON cd.cod_clase = i.cod_clase
        WHERE cd.fecha >= i.fecha_inscripcion
    ),

    -- CTE: Asistencias reales
    Asistencias AS (
        SELECT 
            a.cod_socio,
            a.cod_clase,
            a.fecha
        FROM psn.Asiste a
    ),

    -- CTE: Inasistencias = clases que el socio debería haber asistido pero no lo hizo
    Inasistencias AS (
        SELECT 
            cp.cod_socio,
            cp.cod_clase,
            cp.fecha
        FROM ClasesProgramadas cp
        LEFT JOIN Asistencias a 
            ON cp.cod_socio = a.cod_socio 
            AND cp.cod_clase = a.cod_clase 
            AND cp.fecha = a.fecha
        WHERE a.cod_socio IS NULL
    ),

    -- CTE: Traer detalles del socio y la actividad
    DetallesSociosInasistentes AS (
        SELECT DISTINCT
            s.cod_socio,
            s.nombre,
            s.apellido,
            DATEDIFF(YEAR, s.fecha_nac, GETDATE()) AS edad,
            s.categoria,
            act.nombre AS actividad
        FROM Inasistencias i
        INNER JOIN psn.Socio s ON i.cod_socio = s.cod_socio
        INNER JOIN psn.Clase c ON i.cod_clase = c.cod_clase
        INNER JOIN psn.Actividad act ON c.cod_actividad = act.cod_actividad
    )

    -- Resultado final
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
