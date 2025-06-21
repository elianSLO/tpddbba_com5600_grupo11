
USE Com5600G11;
GO

---PRUEBAS DE STORED PROCEDURES PARA TABLA CLASE

----------------------------------------------------------- PRUEBA SP insertarClase

-- Limpiar tablas para pruebas limpias y consistentes (si es seguro)
DELETE FROM psn.Clase;
DELETE FROM psn.Categoria;
DELETE FROM psn.Actividad;
DELETE FROM psn.Profesor;

DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);

-- Insertar categorías usando SP
EXEC stp.insertarCategoria 'Cadete', 17, 15000.00, '2025-12-31', 180000.00, '2025-12-31';
EXEC stp.insertarCategoria 'Mayor', 99, 25000.00, '2025-12-31', 300000.00, '2025-12-31';
EXEC stp.insertarCategoria 'Menor', 12, 10000.00, '2025-12-31', 120000.00, '2025-12-31';

-- Insertar actividades usando SP
EXEC stp.insertarActividad 'Futsal', 2500.00, '2025-12-31';
EXEC stp.insertarActividad 'Natación', 3000.00, '2025-12-31';

-- Insertar profesor
INSERT INTO psn.Profesor (dni, nombre, apellido, email, tel)
VALUES 
('11111111', 'Esteban', 'Gómez', 'esteban@prof.com', '1144556677'),
('22222222', 'María', 'López', 'maria@prof.com', '1144556678'),
('33333333', 'Jorge', 'Ramírez', 'jorge@prof.com', '1144556679');

-- Insertar clases usando SP
EXEC stp.insertarClase 1 ,1, 1, 'Lunes', '18:00';
EXEC stp.insertarClase 2 ,2, 2, 'Martes', '19:00';
EXEC stp.insertarClase 3 ,2, 3, 'Miercoles', '10:00';

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
