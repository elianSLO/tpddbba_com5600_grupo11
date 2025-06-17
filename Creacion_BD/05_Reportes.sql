
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

-- REPORTE 2: 

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

-- REPORTE 3:


