
USE Com5600G11;
GO

---PRUEBAS DE STORED PROCEDURES PARA TABLA CLASE

----------------------------------------------------------- PRUEBA SP insertarClase

-- Limpiar tablas para pruebas limpias y consistentes (si es seguro)
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Categoria;
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);
PRINT 'Tablas Clase, Categoria y Actividad limpiadas.';

-- Insertar categorías usando SP
EXEC stp.insertarCategoria 'Cadete', 14, 1800.00, '2025-12-31', 18000.00, '2025-12-31';
EXEC stp.insertarCategoria 'Mayor', 25, 2300.00, '2025-12-31', 23000.00, '2025-12-31';

-- Insertar actividades usando SP
EXEC stp.insertarActividad 'Fútbol', 2500.00, '2025-12-31';
EXEC stp.insertarActividad 'Natación', 3000.00, '2025-12-31';

-- Insertar clases usando SP
EXEC stp.insertarClase 1, 1, 'Lunes', '18:00';
EXEC stp.insertarClase 1, 2, 'Martes', '19:00';
EXEC stp.insertarClase 2, 2, 'Miércoles', '10:00';

-- Mostrar clases insertadas

SELECT * FROM psn.Clase;


---------------------------------------------------------- PRUEBA SP modificarClase

-- Test 1: Parámetros NULL
EXEC stp.modificarClase NULL, 1, 1, 'Lunes', '18:00';

-- Test 2: Día inválido
EXEC stp.modificarClase 1, 1, 1, 'Funday', '18:00';

-- Test 3: Clase que no existe

EXEC stp.modificarClase 999, 1, 1, 'Lunes', '18:00';

-- Test 4: Categoría no existe

EXEC stp.modificarClase 1, 999, 1, 'Lunes', '18:00';

-- Test 5: Actividad no existe

EXEC stp.modificarClase 1, 1, 999, 'Lunes', '18:00';

-- Test 6: Intentar modificar para duplicar una clase existente

-- Hay clase 1 (Cadete, Fútbol, Lunes 18:00)
-- Clase 2 es (Cadete, Natación, Martes 19:00)
-- Intentamos cambiar clase 2 a lunes 18:00 igual que clase 1 (debe fallar)
EXEC stp.modificarClase 2, 1, 1, 'Lunes', '18:00';

-- Test 7: Modificación correcta

EXEC stp.modificarClase 2, 2, 2, 'Miercoles', '20:00';

-- Mostrar clases después de modificar

SELECT * FROM psn.Clase;

----------------------------------------------------------- PRUEBA SP borrarClase

-- Prueba 1: Borrar clase existente (usamos cod_clase 1)
EXEC stp.borrarClase 1;

-- Ver clases luego de borrar
SELECT * FROM psn.Clase;

-- Prueba 2: Borrar clase no existente (por ejemplo código 999)

EXEC stp.borrarClase 999;

-- Prueba 3: Borrar con NULL

EXEC stp.borrarClase NULL;
