
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
    DROP PROCEDURE Rep.Reporte_Inasistencias_XML;
    PRINT 'SP Reporte_Inasistencias_XML ya existe. Se creará nuevamente.';
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

    -- CTE: Conteo por categoría y actividad
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
    PRINT 'SP Reporte_SociosConInasistencias_XML ya existe. Se creará nuevamente.';
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

    -- CTE: Inasistencias (cuando el socio no fue a una clase en la que debería haber estado)
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

    -- CTE: Última categoría del socio según la suscripción más reciente
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

-- Ejecutar el SP con un rango de fechas que incluya todas las facturas anteriores
EXEC Rep.Reporte_SociosMorosos_XML 
    @fechaInicio = '2025-01-01', 
    @fechaFin = '2025-04-30';

--------------------------------------------------------------------- REPORTE 2: INGRESOS MENSUALES

-- Limpiar datos anteriores para pruebas (solo si es seguro)

DELETE FROM psn.Factura;
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);
DELETE FROM psn.Item_Factura;
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
DELETE FROM psn.Socio;
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
(25000.00, '2025-01-10', '2025-01-20', NULL, 0.00, 'Pagada', 'SN-1001'), -- Futsal
(30000.00, '2025-01-12', '2025-01-22', NULL, 0.00, 'Pagada', 'SN-1002'), -- Vóley
(25000.00, '2025-02-10', '2025-02-20', NULL, 0.00, 'Pagada', 'SN-1001'), -- Futsal
(30000.00, '2025-02-12', '2025-02-22', NULL, 0.00, 'Pagada', 'SN-1002'); -- Vóley

-- ÍTEMS de FACTURA (referencia a cod_clase: suponiendo IDENTITY de clases = 1 para Futsal, 2 para Vóley)
INSERT INTO psn.Item_Factura (cod_item, cod_Factura, monto, descripcion)
VALUES
(1, 1, 25000.00, '1'),
(2, 2, 30000.00, '2'),
(3, 3, 25000.00, '1'),
(4, 4, 30000.00, '2');

-- EJECUTAR el SP
EXEC Rep.Reporte_IngresosMensuales_XML;


---------------------------------------------------------------------- REPORTE 3: INASISTENCIAS

-- LIMPIEZA DE DATOS ANTERIORES (opcional para entorno de pruebas)

DELETE FROM psn.Factura;
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);
DELETE FROM psn.Asiste;
DELETE FROM psn.Inscripto;
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
DELETE FROM psn.Socio;
DELETE FROM psn.Profesor;
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);




-- Asegurarse de que existan las clases del 1 al 5 para las actividades
-- Futsal (1), Vóley (2), Taekwondo (3), Baile artístico (4), Natación (5)
-- (ya deben estar insertadas)

-- SOCIOS (si no existen)
INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES 
('SN-1001', 'Sofía', 'Paz', '10000001', 'sofia@socio.com', '1990-01-01', '1122334455', '1199887766', 'OSDE', '0001', '1133112233', 1, 0, NULL),
('SN-1002', 'Tomás', 'Leiva', '10000002', 'tomas@socio.com', '1988-02-02', '1144556677', '1166554433', 'Swiss', '0002', '1144223344', 1, 0, NULL),
('SN-1003', 'Lucía', 'Martínez', '10000003', 'lucia@socio.com', '1995-03-03', '1155667788', '1177889900', 'OSDE', '0003', '1177223344', 1, 0, NULL),
('SN-1004', 'Julián', 'Fernández', '10000004', 'julian@socio.com', '1992-04-04', '1166778899', '1188990011', 'Swiss', '0004', '1188223344', 1, 0, NULL),
('SN-1005', 'Valen', 'Suárez', '10000005', 'valen@socio.com', '1991-05-05', '1177889900', '1199001122', 'Medife','0005', '1199223344', 1, 0, NULL);

-- INSCRIPCIONES (una por socio, asociada a una clase distinta)
INSERT INTO psn.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES 
('2025-05-02', 'Inscripto', 'SN-1001', 1),
('2025-05-02', 'Inscripto', 'SN-1002', 2),
('2025-05-02', 'Inscripto', 'SN-1003', 3),
('2025-05-02', 'Inscripto', 'SN-1004', 4),
('2025-05-02', 'Inscripto', 'SN-1005', 5);

-- FECHAS DE CLASES DICTADAS (se infieren desde las asistencias)
-- 4 fechas distintas de clases: todos los viernes de mayo
-- 02, 09, 16, 23 de mayo de 2025

-- ASISTENCIAS (solo a las 2 primeras clases: 02 y 09 de mayo)
INSERT INTO psn.Asiste (fecha, cod_socio, cod_clase, estado)
VALUES
('2025-05-02', 'SN-1001', 1, 'A'),
('2025-05-09', 'SN-1001', 1, 'A'),
('2025-05-02', 'SN-1002', 2, 'A'),
('2025-05-09', 'SN-1002', 2, 'A'),
('2025-05-02', 'SN-1003', 3, 'A'),
('2025-05-09', 'SN-1003', 3, 'A'),
('2025-05-02', 'SN-1004', 4, 'A'),
('2025-05-09', 'SN-1004', 4, 'A'),
('2025-05-02', 'SN-1005', 5, 'A'),
('2025-05-09', 'SN-1005', 5, 'A');

-- EJECUTAR SP
EXEC Rep.Reporte_Inasistencias_XML;

-----------------------------------------------------------------   REPORTE 4

-- Limpieza previa (por si ejecutaste antes)
DELETE FROM psn.Asiste;
DELETE FROM psn.Inscripto;
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
DELETE FROM psn.Suscripcion;
DELETE FROM psn.Categoria;
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);
DELETE FROM psn.Socio;

-- 1. Insertar categorías
INSERT INTO psn.Categoria (descripcion, edad_max, valor_mensual, vig_valor_mens, valor_anual, vig_valor_anual)
VALUES 
    ('Mayor', 99, 25000, '2026-01-01', 300000,'2026-01-01'),
    ('Cadete', 17, 15000, '2026-01-01', 180000, '2026-01-01'),
    ('Menor', 12, 10000, '2026-01-01', 120000, '2026-01-01');


-- 2. Insertar socios
INSERT INTO psn.Socio (cod_socio, nombre, apellido, fecha_nac)
VALUES 
    ('SN-00001', 'Ana', 'Gomez', '1990-05-12'),
    ('SN-00002', 'Luis', 'Martinez', '1985-10-20');

-- 3. Insertar suscripciones
INSERT INTO psn.Suscripcion (cod_socio, cod_categoria, fecha_suscripcion)
VALUES 
    ('SN-00001', 1, '2025-01-01'),
    ('SN-00002', 2, '2025-01-15');

-- 4. Insertar actividad
INSERT INTO psn.Actividad (nombre, valor_mensual, vig_valor)
VALUES 
('Futsal', 25000, '2026-01-01'),
('Vóley', 30000, '2026-01-01'),
('Taekwondo', 25000, '2026-01-01'),
('Baile artístico', 30000, '2026-01-01'),
('Natación', 45000, '2026-01-01'),
('Ajedrez', 2000, '2026-01-01');

-- 5. Insertar clases
INSERT INTO psn.Clase (cod_clase, cod_actividad, dia, horario)
VALUES 
    (1, 1, 'Martes', '10:00'),
    (2, 2, 'Jueves', '10:00');

-- 6. Inscribir socios
INSERT INTO psn.Inscripto (cod_socio, cod_clase, fecha_inscripcion)
VALUES 
    ('SN-00001', 1001, '2025-05-20'),
    ('SN-00001', 1002, '2025-05-20'),
    ('SN-00002', 1001, '2025-05-25');

-- 7. Registrar asistencias (sólo una asistencia, el resto será inasistencia)
INSERT INTO psn.Asiste (cod_socio, cod_clase, fecha)
VALUES 
    ('SN-00001', 1001, '2025-06-01'); -- Asistió solo a una clase

-- 8. Ejecutar el SP
EXEC Rep.Reporte_SociosConInasistencias_XML;
GO

