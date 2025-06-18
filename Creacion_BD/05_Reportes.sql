
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
    ORDER BY cod_actividad, anio, mes
    FOR XML PATH('Actividad'), ROOT('IngresosMensuales');
END;
GO

-- REPORTE 3: Inasistencias por Categoria y Actividad

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_Inasistencias_XML')
BEGIN
    DROP PROCEDURE Rep.Reporte_Inasistencias_XML;
	PRINT 'SP Reporte_Inasistencias_XML ya existe. Se creará nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_Inasistencias_XML
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE: Relación socio-clase-categoría-actividad
    WITH DatosSocioClase AS (
        SELECT 
            I.cod_socio,
            C.cod_clase,
            C.cod_actividad,
            C.categoria,
            A.nombre AS nombre_actividad,
            Cat.descripcion AS nombre_categoria
        FROM psn.Inscripto I
        INNER JOIN psn.Clase C ON I.cod_clase = C.cod_clase
        INNER JOIN psn.Actividad A ON C.cod_actividad = A.cod_actividad
        INNER JOIN psn.Suscripcion S ON I.cod_socio = S.cod_socio AND S.cod_categoria = C.categoria
        INNER JOIN psn.Categoria Cat ON S.cod_categoria = Cat.cod_categoria
    ),

    -- Fechas dictadas por clase
    FechasDictadas AS (
        SELECT DISTINCT cod_clase, fecha
        FROM psn.Asiste
    ),

    -- Combinaciones posibles
    PosiblesAsistencias AS (
        SELECT 
            D.cod_socio,
            F.cod_clase,
            F.fecha,
            D.cod_actividad,
            D.categoria,
            D.nombre_actividad,
            D.nombre_categoria
        FROM DatosSocioClase D
        INNER JOIN FechasDictadas F ON D.cod_clase = F.cod_clase
    ),

    -- Asistencias reales (registradas)
    AsistenciasRegistradas AS (
        SELECT cod_socio, cod_clase, fecha, estado
        FROM psn.Asiste
    ),

    -- Inasistencias (sin asistencia o estado distinto de 'P')
    Inasistencias AS (
        SELECT 
            P.cod_socio,
            P.cod_actividad,
            P.categoria,
            P.nombre_actividad,
            P.nombre_categoria
        FROM PosiblesAsistencias P
        LEFT JOIN AsistenciasRegistradas A
            ON P.cod_socio = A.cod_socio AND P.cod_clase = A.cod_clase AND P.fecha = A.fecha
        WHERE A.cod_socio IS NULL OR A.estado IN ('A', 'J')
    )

    -- Resultado final
    SELECT 
        nombre_categoria,
        nombre_actividad,
        COUNT(DISTINCT cod_socio) AS cantidad_socios_inasistentes
    FROM Inasistencias
    GROUP BY nombre_categoria, nombre_actividad
    ORDER BY cantidad_socios_inasistentes DESC
    FOR XML AUTO, ROOT('Inasistencias');
END;
GO

-- REPORTE 4: Socios con Inasistencias

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Reporte_SociosConInasistencias')
BEGIN
    DROP PROCEDURE Rep.Reporte_SociosConInasistencias;
	PRINT 'SP Reporte_SociosConInasistencias_XML ya existe. Se creará nuevamente.';
END;
GO

CREATE OR ALTER PROCEDURE Rep.Reporte_SociosConInasistencias
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE 1: Socios con sus clases y actividades
    WITH SociosInscriptos AS (
        SELECT 
            S.cod_socio,
            S.nombre,
            S.apellido,
            S.fecha_nac,
            A.nombre AS nombre_actividad,
            C.cod_clase
        FROM psn.Inscripto I
        INNER JOIN psn.Socio S ON I.cod_socio = S.cod_socio
        INNER JOIN psn.Clase C ON I.cod_clase = C.cod_clase
        INNER JOIN psn.Actividad A ON C.cod_actividad = A.cod_actividad
        WHERE I.estado = 'Inscripto'
    ),

    -- CTE 2: Última categoría vigente del socio
    CategoriaActual AS (
        SELECT 
            cod_socio,
            cod_categoria,
            ROW_NUMBER() OVER (PARTITION BY cod_socio ORDER BY fecha_suscripcion DESC) AS rn
        FROM psn.Suscripcion
    ),

    -- CTE 3: Categoría con descripción
    SociosConCategoria AS (
        SELECT 
            SI.*,
            CAT.descripcion AS categoria
        FROM SociosInscriptos SI
        LEFT JOIN CategoriaActual SC ON SI.cod_socio = SC.cod_socio AND SC.rn = 1
        LEFT JOIN psn.Categoria CAT ON SC.cod_categoria = CAT.cod_categoria
    ),

    -- CTE 4: Inasistencias detectadas
    Inasistencias AS (
        SELECT cod_socio, cod_clase
        FROM psn.Asiste
        WHERE estado = 'A'
        GROUP BY cod_socio, cod_clase
    )

    -- Resultado final: socios con inasistencias
    SELECT 
        SC.nombre        AS [Nombre],
        SC.apellido      AS [Apellido],
        DATEDIFF(YEAR, SC.fecha_nac, GETDATE()) AS [Edad],
        SC.categoria     AS [Categoria],
        SC.nombre_actividad AS [Actividad]
    FROM SociosConCategoria SC
    INNER JOIN Inasistencias IA
        ON SC.cod_socio = IA.cod_socio AND SC.cod_clase = IA.cod_clase
    ORDER BY SC.apellido, SC.nombre
    FOR XML PATH('Socio'), ROOT('SociosConInasistencias');
END;
GO







-------------------------------------------------------------------- PRUEBAS

-- Nota: El reporte XML debe visualizarse con la opción "Results to Grid" (CTRL + D)

-------------------------------------------------------------------- REPORTE 1: SOCIOS MOROSOS

-- Limpiar datos anteriores (solo para pruebas)
DELETE FROM psn.Factura;
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);
DELETE FROM psn.Socio;

-- Insertar socios de prueba
INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES 
('SN-00001', 'Ana', 'Pérez', '12345678', 'ana@email.com', '1990-01-01', '1122334455', '1199887766', 'OSDE', 'A123', '1133445566', 1, 0, NULL),
('SN-00002', 'Luis', 'Gómez', '87654321', 'luis@email.com', '1985-05-10', '1144556677', '1100110011', 'Swiss', 'B456', '1177889900', 1, 0, NULL),
('SN-00003', 'Carla', 'Ruiz', '11223344', 'carla@email.com', '1982-12-30', '1199881122', '1133557799', 'Galeno', 'C789', '1122446688', 1, 0, NULL);

-- Insertar facturas con distintos estados y fechas
-- Ana (SN-00001) tiene 3 facturas vencidas => debe aparecer
INSERT INTO psn.Factura (monto, fecha_emision, fecha_vto, fecha_seg_vto, recargo, estado, cod_socio)
VALUES
(1000, '2024-12-01', '2025-01-01', NULL, 0, 'Vencida', 'SN-00001'),
(1200, '2025-01-01', '2025-02-01', NULL, 0, 'Vencida', 'SN-00001'),
(1300, '2025-02-01', '2025-03-01', NULL, 0, 'Vencida', 'SN-00001'),
(900,  '2025-03-01', '2025-04-01', NULL, 0, 'Pagada',  'SN-00001');

-- Luis (SN-00002) tiene 2 facturas vencidas => NO debe aparecer
INSERT INTO psn.Factura (monto, fecha_emision, fecha_vto, fecha_seg_vto, recargo, estado, cod_socio)
VALUES
(1500, '2025-01-15', '2025-02-15', NULL, 0, 'Vencida', 'SN-00002'),
(1600, '2025-02-15', '2025-03-15', NULL, 0, 'Vencida', 'SN-00002');

-- Carla (SN-00003) tiene 3 facturas, pero solo 1 vencida => NO debe aparecer
INSERT INTO psn.Factura (monto, fecha_emision, fecha_vto, fecha_seg_vto, recargo, estado, cod_socio)
VALUES
(1100, '2025-01-20', '2025-02-20', NULL, 0, 'Pagada',  'SN-00003'),
(1150, '2025-02-20', '2025-03-20', NULL, 0, 'Vencida', 'SN-00003'),
(1200, '2025-03-20', '2025-04-20', NULL, 0, 'Pagada',  'SN-00003');

-- Ejecutar SP con un rango de fechas que incluya todas las facturas anteriores
EXEC Rep.Reporte_SociosMorosos_XML 
    @fechaInicio = '2025-01-01', 
    @fechaFin = '2025-04-30';

--------------------------------------------------------------------- REPORTE 2: INGRESOS MENSUALES Y ACUMULADO POR ACTIVIDAD

-- Limpiar datos anteriores para pruebas (solo si es seguro)

DELETE FROM psn.Factura;
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);
DELETE FROM psn.Socio;
DELETE FROM psn.Item_Factura;
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
DELETE FROM psn.Profesor;
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- ACTIVIDADES (valores actualizados)
INSERT INTO psn.Actividad (nombre, valor_mensual, vig_valor)
VALUES 
('Futsal', 25000, '2026-01-01'),
('Vóley', 30000, '2026-01-01'),
('Taekwondo', 25000, '2026-01-01'),
('Baile artístico', 30000, '2026-01-01'),
('Natación', 45000, '2026-01-01'),
('Ajedrez', 2000, '2026-01-01');

-- PROFESORES (uno por actividad)
INSERT INTO psn.Profesor (dni, nombre, apellido, email, tel)
VALUES 
('11111111', 'Esteban', 'Gómez', 'esteban@prof.com', '1144556677'),
('22222222', 'María', 'López', 'maria@prof.com', '1144556678'),
('33333333', 'Jorge', 'Ramírez', 'jorge@prof.com', '1144556679'),
('44444444', 'Laura', 'Sosa', 'laura@prof.com', '1144556680'),
('55555555', 'Carlos', 'Díaz', 'carlos@prof.com', '1144556681'),
('66666666', 'Lucía', 'Bianchi', 'lucia@prof.com', '1144556682');

-- CLASES (una por actividad, asignando profesor correspondiente)
-- cod_actividad: del 1 al 6, cod_prof: del 1 al 6 (según inserción anterior)
INSERT INTO psn.Clase (categoria, cod_actividad, cod_prof, dia, horario)
VALUES 
(1, 1, 1, 'Lunes', '10:00'),         
(2, 2, 2, 'Martes', '11:00'),        
(3, 3, 3, 'Miercoles', '12:00'),     
(4, 4, 4, 'Jueves', '13:00'),        
(5, 5, 5, 'Viernes', '14:00'),       
(6, 6, 6, 'Sabado', '15:00');        

-- SOCIOS
INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES 
('SN-1001', 'Sofía', 'Paz', '10000001', 'sofia@socio.com', '1990-01-01', '1122334455', '1199887766', 'OSDE', '0001', '1133112233', 1, 0, NULL),
('SN-1002', 'Tomás', 'Leiva', '10000002', 'tomas@socio.com', '1988-02-02', '1144556677', '1166554433', 'Swiss', '0002', '1144223344', 1, 0, NULL);

-- FACTURAS (Enero y Febrero 2025, una para cada socio)
INSERT INTO psn.Factura (monto, fecha_emision, fecha_vto, fecha_seg_vto, recargo, estado, cod_socio)
VALUES 
(25000.00, '2025-01-10', '2025-01-20', NULL, 0.00, 'Pagada', 'SN-1001'), 
(30000.00, '2025-01-12', '2025-01-22', NULL, 0.00, 'Pagada', 'SN-1002'), 
(25000.00, '2025-02-10', '2025-02-20', NULL, 0.00, 'Pagada', 'SN-1001'), 
(30000.00, '2025-02-12', '2025-02-22', NULL, 0.00, 'Pagada', 'SN-1002'),
(25000.00, '2025-01-14', '2025-01-24', NULL, 0.00, 'Pagada', 'SN-1001'),  
(30000.00, '2025-01-16', '2025-01-26', NULL, 0.00, 'Pagada', 'SN-1002'),  
(45000.00, '2025-01-18', '2025-01-28', NULL, 0.00, 'Pagada', 'SN-1001'),  
(2000.00,  '2025-01-20', '2025-01-30', NULL, 0.00, 'Pagada', 'SN-1002'),  
(25000.00, '2025-02-14', '2025-02-24', NULL, 0.00, 'Pagada', 'SN-1001'),  
(30000.00, '2025-02-16', '2025-02-26', NULL, 0.00, 'Pagada', 'SN-1002'),  
(45000.00, '2025-02-18', '2025-02-28', NULL, 0.00, 'Pagada', 'SN-1001'),  
(2000.00,  '2025-02-20', '2025-03-01', NULL, 0.00, 'Pagada', 'SN-1002');

-- ÍTEMS de FACTURA (referencia a cod_clase: suponiendo IDENTITY de clases = 1 para Futsal, 2 para Vóley)
INSERT INTO psn.Item_Factura (cod_item, cod_Factura, monto, descripcion)
VALUES
(1, 1, 25000.00, '1'),
(2, 2, 30000.00, '2'),
(3, 3, 25000.00, '1'),
(4, 4, 30000.00, '2'),
(5, 5, 25000.00, '3'),
(6, 6, 30000.00, '4'),
(7, 7, 45000.00, '5'),
(8, 8, 2000.00,  '6'),
(9, 9, 25000.00, '3'),
(10, 10, 30000.00, '4'),
(11, 11, 45000.00, '5'),
(12, 12, 2000.00,  '6');

-- EJECUTAR SP
EXEC Rep.Reporte_IngresosMensuales_XML;


---------------------------------------------------------------------- REPORTE 3: CANTIDAD DE INASISTENCIAS POR ACTIVIDAD Y CATEGORIA

-- Limpiar datos anteriores para pruebas (solo si es seguro)

DELETE FROM psn.Suscripcion;
DELETE FROM psn.Factura;
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);
DELETE FROM psn.Categoria
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);
DELETE FROM psn.Asiste;
DELETE FROM psn.Inscripto;
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
DELETE FROM psn.Socio;
DELETE FROM psn.Profesor;
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);


-- ACTIVIDADES
INSERT INTO psn.Actividad (nombre, valor_mensual, vig_valor)
VALUES 
('Futsal', 25000, '2026-01-01'),
('Vóley', 30000, '2026-01-01'),
('Taekwondo', 25000, '2026-01-01'),
('Baile artístico', 30000, '2026-01-01'),
('Natación', 45000, '2026-01-01'),
('Ajedrez', 2000, '2026-01-01');

-- CATEGORÍAS
INSERT INTO psn.Categoria (descripcion, edad_max, valor_mensual, vig_valor_mens, valor_anual, vig_valor_anual)
VALUES
('Menor', 12, 5000, '2025-01-01', 50000, '2025-01-01'),
('Cadete', 17, 6000, '2025-01-01', 60000, '2025-01-01'),
('Mayor', 99, 7000, '2025-01-01', 70000, '2025-01-01');

-- SOCIOS
INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES 
('SN-2001', 'Luna', 'Rojas', '10100001', 'luna@socio.com', '2015-01-01', '1111111111', '1222222222', 'OSDE', 'A001', '1111000000', 1, 0, NULL),
('SN-2002', 'Ezequiel', 'Gómez', '10100002', 'eze@socio.com', '2014-02-01', '1111111112', '1222222223', 'OSDE', 'A002', '1111000001', 1, 0, NULL),
('SN-2101', 'Bruno', 'Acosta', '10200001', 'bruno@socio.com', '2010-03-01', '1111111113', '1222222224', 'Swiss', 'B001', '1111000002', 1, 0, NULL),
('SN-2102', 'Martina', 'Lopez', '10200002', 'martina@socio.com', '2011-04-01', '1111111114', '1222222225', 'Swiss', 'B002', '1111000003', 1, 0, NULL),
('SN-2201', 'Lucía', 'Fernández', '10300001', 'lucia@socio.com', '1990-05-01', '1111111115', '1222222226', 'Medife', 'C001', '1111000004', 1, 0, NULL),
('SN-2202', 'Marcos', 'Silva', '10300002', 'marcos@socio.com', '1985-06-01', '1111111116', '1222222227', 'Medife', 'C002', '1111000005', 1, 0, NULL),
('SN-2003', 'Julieta', 'Maidana', '10100003', 'julieta@socio.com', '2013-03-03', '1111111117', '1222222228', 'OSDE', 'A003', '1111000006', 1, 0, NULL),
('SN-2103', 'Carlos', 'Benítez', '10200003', 'carlos@socio.com', '2010-03-03', '1111111118', '1222222229', 'Swiss', 'B003', '1111000007', 1, 0, NULL),
('SN-2104', 'Rocío', 'Franco', '10200004', 'rocio@socio.com', '2011-04-04', '1111111119', '1222222230', 'Swiss', 'B004', '1111000008', 1, 0, NULL),
('SN-2203', 'Tomás', 'Ibarra', '10300003', 'tomas@socio.com', '1989-07-07', '1111111120', '1222222231', 'Medife', 'C003', '1111000009', 1, 0, NULL),
('SN-2204', 'Camila', 'Moreira', '10300004', 'camila@socio.com', '1988-08-08', '1111111121', '1222222232', 'Medife', 'C004', '1111000010', 1, 0, NULL),
('SN-2205', 'Gustavo', 'Lagos', '10300005', 'gustavo@socio.com', '1985-09-09', '1111111122', '1222222233', 'Medife', 'C005', '1111000011', 1, 0, NULL);

-- PROFESORES
INSERT INTO psn.Profesor (dni, nombre, apellido, email, tel)
VALUES 
('10000001', 'Carlos', 'Ruiz', 'car@prof.com', '1122330001'),
('10000002', 'Sandra', 'Vera', 'san@prof.com', '1122330002'),
('10000003', 'Ramón', 'Iglesias', 'ram@prof.com', '1122330003'),
('10000004', 'Lucía', 'Martínez', 'luc@prof.com', '1122330004'),
('10000005', 'Roberto', 'Díaz', 'rob@prof.com', '1122330005'),
('10000006', 'Julieta', 'Alonso', 'jul@prof.com', '1122330006');

-- CLASES
INSERT INTO psn.Clase (categoria, cod_actividad, cod_prof, dia, horario)
VALUES
(1, 1, 1, 'Lunes', '09:00'),
(1, 2, 2, 'Lunes', '10:00'),
(2, 3, 3, 'Martes', '09:00'),
(2, 4, 4, 'Martes', '10:00'),
(3, 5, 5, 'Miercoles', '09:00'),
(3, 6, 6, 'Miercoles', '10:00');

-- SUSCRIPCIONES
INSERT INTO psn.Suscripcion (cod_socio, cod_categoria, fecha_suscripcion, fecha_vto, tiempoSuscr)
VALUES
('SN-2001', 1, '2025-05-01', '2025-06-01', 'M'),
('SN-2002', 1, '2025-05-01', '2025-06-01', 'M'),
('SN-2003', 1, '2025-05-01', '2025-06-01', 'M'),
('SN-2101', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2102', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2103', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2104', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2201', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2202', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2203', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2204', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2205', 3, '2025-05-01', '2025-06-01', 'M');

-- INSCRIPCIONES
INSERT INTO psn.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES
('2025-05-02', 'Inscripto', 'SN-2001', 1),
('2025-05-02', 'Inscripto', 'SN-2002', 2),
('2025-05-02', 'Inscripto', 'SN-2003', 2),
('2025-05-02', 'Inscripto', 'SN-2101', 3),
('2025-05-02', 'Inscripto', 'SN-2102', 4),
('2025-05-02', 'Inscripto', 'SN-2103', 3),
('2025-05-02', 'Inscripto', 'SN-2104', 3),
('2025-05-02', 'Inscripto', 'SN-2201', 5),
('2025-05-02', 'Inscripto', 'SN-2202', 6),
('2025-05-02', 'Inscripto', 'SN-2203', 5),
('2025-05-02', 'Inscripto', 'SN-2204', 5),
('2025-05-02', 'Inscripto', 'SN-2205', 5);

-- ASISTENCIAS

INSERT INTO psn.Asiste (fecha, cod_socio, cod_clase, estado)
VALUES
('2025-05-10', 'SN-2001', 1, 'P'),
('2025-05-17', 'SN-2001', 1, 'P'),
('2025-05-10', 'SN-2002', 2, 'A'),
('2025-05-17', 'SN-2002', 2, 'P'),
('2025-05-10', 'SN-2003', 2, 'A'),
('2025-05-17', 'SN-2003', 2, 'P'),
('2025-05-10', 'SN-2101', 3, 'A'),
('2025-05-17', 'SN-2101', 3, 'P'),
('2025-05-10', 'SN-2102', 4, 'P'),
('2025-05-17', 'SN-2102', 4, 'P'),
('2025-05-10', 'SN-2103', 3, 'A'),
('2025-05-17', 'SN-2103', 3, 'A'),
('2025-05-10', 'SN-2104', 3, 'A'),
('2025-05-17', 'SN-2104', 3, 'A'),
('2025-05-10', 'SN-2201', 5, 'A'),
('2025-05-17', 'SN-2201', 5, 'A'),
('2025-05-10', 'SN-2203', 5, 'A'),
('2025-05-17', 'SN-2203', 5, 'A'),
('2025-05-10', 'SN-2204', 5, 'A'),
('2025-05-17', 'SN-2204', 5, 'A'),
('2025-05-10', 'SN-2205', 5, 'A'),
('2025-05-17', 'SN-2205', 5, 'A'),
('2025-05-10', 'SN-2202', 6, 'A'),
('2025-05-17', 'SN-2202', 6, 'P');


-- EJECUTAR SP
EXEC Rep.Reporte_Inasistencias_XML;

-----------------------------------------------------------------   REPORTE 4: SOCIOS CON INASISTENCIAS

-- Limpiar datos anteriores para pruebas (solo si es seguro)

DELETE FROM psn.Suscripcion;
DELETE FROM psn.Factura;
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);
DELETE FROM psn.Categoria
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);
DELETE FROM psn.Asiste;
DELETE FROM psn.Inscripto;
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
DELETE FROM psn.Socio;
DELETE FROM psn.Profesor;
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);


-- ACTIVIDADES
INSERT INTO psn.Actividad (nombre, valor_mensual, vig_valor)
VALUES 
('Futsal', 25000, '2026-01-01'),
('Vóley', 30000, '2026-01-01'),
('Taekwondo', 25000, '2026-01-01'),
('Baile artístico', 30000, '2026-01-01'),
('Natación', 45000, '2026-01-01'),
('Ajedrez', 2000, '2026-01-01');

-- CATEGORÍAS
INSERT INTO psn.Categoria (descripcion, edad_max, valor_mensual, vig_valor_mens, valor_anual, vig_valor_anual)
VALUES
('Menor', 12, 5000, '2025-01-01', 50000, '2025-01-01'),
('Cadete', 17, 6000, '2025-01-01', 60000, '2025-01-01'),
('Mayor', 99, 7000, '2025-01-01', 70000, '2025-01-01');

-- SOCIOS
INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES 
('SN-2001', 'Luna', 'Rojas', '10100001', 'luna@socio.com', '2015-01-01', '1111111111', '1222222222', 'OSDE', 'A001', '1111000000', 1, 0, NULL),
('SN-2002', 'Ezequiel', 'Gómez', '10100002', 'eze@socio.com', '2014-02-01', '1111111112', '1222222223', 'OSDE', 'A002', '1111000001', 1, 0, NULL),
('SN-2101', 'Bruno', 'Acosta', '10200001', 'bruno@socio.com', '2010-03-01', '1111111113', '1222222224', 'Swiss', 'B001', '1111000002', 1, 0, NULL),
('SN-2102', 'Martina', 'Lopez', '10200002', 'martina@socio.com', '2011-04-01', '1111111114', '1222222225', 'Swiss', 'B002', '1111000003', 1, 0, NULL),
('SN-2201', 'Lucía', 'Fernández', '10300001', 'lucia@socio.com', '1990-05-01', '1111111115', '1222222226', 'Medife', 'C001', '1111000004', 1, 0, NULL),
('SN-2202', 'Marcos', 'Silva', '10300002', 'marcos@socio.com', '1985-06-01', '1111111116', '1222222227', 'Medife', 'C002', '1111000005', 1, 0, NULL),
('SN-2003', 'Julieta', 'Maidana', '10100003', 'julieta@socio.com', '2013-03-03', '1111111117', '1222222228', 'OSDE', 'A003', '1111000006', 1, 0, NULL),
('SN-2103', 'Carlos', 'Benítez', '10200003', 'carlos@socio.com', '2010-03-03', '1111111118', '1222222229', 'Swiss', 'B003', '1111000007', 1, 0, NULL),
('SN-2104', 'Rocío', 'Franco', '10200004', 'rocio@socio.com', '2011-04-04', '1111111119', '1222222230', 'Swiss', 'B004', '1111000008', 1, 0, NULL),
('SN-2203', 'Tomás', 'Ibarra', '10300003', 'tomas@socio.com', '1989-07-07', '1111111120', '1222222231', 'Medife', 'C003', '1111000009', 1, 0, NULL),
('SN-2204', 'Camila', 'Moreira', '10300004', 'camila@socio.com', '1988-08-08', '1111111121', '1222222232', 'Medife', 'C004', '1111000010', 1, 0, NULL),
('SN-2205', 'Gustavo', 'Lagos', '10300005', 'gustavo@socio.com', '1985-09-09', '1111111122', '1222222233', 'Medife', 'C005', '1111000011', 1, 0, NULL);

-- PROFESORES
INSERT INTO psn.Profesor (dni, nombre, apellido, email, tel)
VALUES 
('10000001', 'Carlos', 'Ruiz', 'car@prof.com', '1122330001'),
('10000002', 'Sandra', 'Vera', 'san@prof.com', '1122330002'),
('10000003', 'Ramón', 'Iglesias', 'ram@prof.com', '1122330003'),
('10000004', 'Lucía', 'Martínez', 'luc@prof.com', '1122330004'),
('10000005', 'Roberto', 'Díaz', 'rob@prof.com', '1122330005'),
('10000006', 'Julieta', 'Alonso', 'jul@prof.com', '1122330006');

-- CLASES
INSERT INTO psn.Clase (categoria, cod_actividad, cod_prof, dia, horario)
VALUES
(1, 1, 1, 'Lunes', '09:00'),
(1, 2, 2, 'Lunes', '10:00'),
(2, 3, 3, 'Martes', '09:00'),
(2, 4, 4, 'Martes', '10:00'),
(3, 5, 5, 'Miercoles', '09:00'),
(3, 6, 6, 'Miercoles', '10:00');

-- SUSCRIPCIONES
INSERT INTO psn.Suscripcion (cod_socio, cod_categoria, fecha_suscripcion, fecha_vto, tiempoSuscr)
VALUES
('SN-2001', 1, '2025-05-01', '2025-06-01', 'M'),
('SN-2002', 1, '2025-05-01', '2025-06-01', 'M'),
('SN-2003', 1, '2025-05-01', '2025-06-01', 'M'),
('SN-2101', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2102', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2103', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2104', 2, '2025-05-01', '2025-06-01', 'M'),
('SN-2201', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2202', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2203', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2204', 3, '2025-05-01', '2025-06-01', 'M'),
('SN-2205', 3, '2025-05-01', '2025-06-01', 'M');

-- INSCRIPCIONES
INSERT INTO psn.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES
('2025-05-02', 'Inscripto', 'SN-2001', 1),
('2025-05-02', 'Inscripto', 'SN-2002', 2),
('2025-05-02', 'Inscripto', 'SN-2003', 2),
('2025-05-02', 'Inscripto', 'SN-2101', 3),
('2025-05-02', 'Inscripto', 'SN-2102', 4),
('2025-05-02', 'Inscripto', 'SN-2103', 3),
('2025-05-02', 'Inscripto', 'SN-2104', 3),
('2025-05-02', 'Inscripto', 'SN-2201', 5),
('2025-05-02', 'Inscripto', 'SN-2202', 6),
('2025-05-02', 'Inscripto', 'SN-2203', 5),
('2025-05-02', 'Inscripto', 'SN-2204', 5),
('2025-05-02', 'Inscripto', 'SN-2205', 5);

-- ASISTENCIAS

INSERT INTO psn.Asiste (fecha, cod_socio, cod_clase, estado)
VALUES
('2025-05-10', 'SN-2001', 1, 'P'),
('2025-05-17', 'SN-2001', 1, 'P'),
('2025-05-10', 'SN-2002', 2, 'A'),
('2025-05-17', 'SN-2002', 2, 'P'),
('2025-05-10', 'SN-2003', 2, 'A'),
('2025-05-17', 'SN-2003', 2, 'P'),
('2025-05-10', 'SN-2101', 3, 'A'),
('2025-05-17', 'SN-2101', 3, 'P'),
('2025-05-10', 'SN-2102', 4, 'P'),
('2025-05-17', 'SN-2102', 4, 'P'),
('2025-05-10', 'SN-2103', 3, 'A'),
('2025-05-17', 'SN-2103', 3, 'A'),
('2025-05-10', 'SN-2104', 3, 'A'),
('2025-05-17', 'SN-2104', 3, 'A'),
('2025-05-10', 'SN-2201', 5, 'A'),
('2025-05-17', 'SN-2201', 5, 'A'),
('2025-05-10', 'SN-2203', 5, 'A'),
('2025-05-17', 'SN-2203', 5, 'A'),
('2025-05-10', 'SN-2204', 5, 'A'),
('2025-05-17', 'SN-2204', 5, 'A'),
('2025-05-10', 'SN-2205', 5, 'A'),
('2025-05-17', 'SN-2205', 5, 'A'),
('2025-05-10', 'SN-2202', 6, 'A'),
('2025-05-17', 'SN-2202', 6, 'P');


-- Ejecutar el SP
EXEC Rep.Reporte_SociosConInasistencias;

