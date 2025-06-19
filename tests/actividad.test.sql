Use Com5600G11
GO

-- 8. ACTIVIDAD

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0); -- Usar solo para delete luego de insertar

-- 8.1 INSERCIÓN DE ACTIVIDADES

-- 8.1.1 INSERCIÓN VÁLIDA
EXEC stp.insertarActividad
    @nombre = 'Futsal',
    @valor_mensual = 250000,
    @vig_valor = '2026-01-01';

-- Verifico la correcta inserción de las actividades:

SELECT * FROM psn.Actividad

-- 8.1.2 Nombre de Actividad Incorrecto (debe dar error)
EXEC stp.insertarActividad
    @nombre = 'Basquet', -- No permitido en la lista
    @valor_mensual = 2000.00,
    @vig_valor = '2025-11-01';

-- 8.1.3 Valor Mensual Negativo o Cero (debe dar error)
EXEC stp.insertarActividad
    @nombre = 'Vóley',
    @valor_mensual = 0.00, -- Valor inválido
    @vig_valor = '2025-10-01';

EXEC stp.insertarActividad
    @nombre = 'Taekwondo',
    @valor_mensual = -500.00, -- Valor inválido
    @vig_valor = '2025-09-01';

-- 8.1.4 Fecha de Vigencia Pasada (debe dar error)
EXEC stp.insertarActividad
    @nombre = 'Ajedrez',
    @valor_mensual = 1000.00,
    @vig_valor = '2024-01-01'; -- Fecha pasada


-- 8.2 MODIFICACIÓN DE ACTIVIDADES

-- 8.2.1 MODIFICACIÓN VÁLIDA (se asume que 'Futsal' ya existe por las pruebas de inserción)
EXEC stp.modificarActividad
    @nombre = 'Futsal',
    @valor_mensual = 2750.00,
    @vig_valor = '2026-03-15';

-- Verificación de modificación
SELECT * FROM psn.Actividad 

-- 8.2.2 Actividad No Existente (debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Yoga', -- No existe y no está en la lista de actividades permitidas
    @valor_mensual = 1800.00,
    @vig_valor = '2025-12-01';

-- 8.2.3 Valor Mensual Negativo o Cero (debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Natación',
    @valor_mensual = -10.00, -- Valor inválido
    @vig_valor = '2025-11-15';

EXEC stp.modificarActividad
    @nombre = 'Natación',
    @valor_mensual = 0.00, -- Valor inválido
    @vig_valor = '2025-11-15';

-- 8.2.4 Fecha de Vigencia Pasada (debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Futsal',
    @valor_mensual = 2800.00,
    @vig_valor = '2023-05-20'; -- Fecha pasada

---
-- 8.3 BORRADO DE ACTIVIDADES

-- 8.3.1 Eliminación Exitosa 
EXEC stp.eliminarActividad @nombre = 'Futsal';

-- Verificación de eliminación
SELECT * FROM psn.Actividad WHERE nombre = 'Futsal';

-- 8.3.2 Eliminación Fallida (Actividad no existente)

EXEC stp.eliminarActividad @nombre = 'Handball'; 