-- PRUEBAS TABLAS ASISTE

-- Para las pruebas tengo que insertar datos en las tablas Socio, Clase, Actividad y Categoria

-- Limpiar tablas para pruebas limpias y consistentes (si es seguro)

DELETE FROM psn.Socio
DELETE FROM psn.Clase;
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);
DELETE FROM psn.Categoria;
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);


-- Insertar socios usando SP

EXEC stp.insertarSocio
    @cod_socio = 'SN-00001',
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nac = '1990-05-15',
    @email = 'juan.perez@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'AFI12345',
    @tel_cobertura = '08008881234',
    @cod_responsable = NULL;
GO

-- Insertar socio menor de edad (con responsable)
EXEC stp.insertarSocio
    @cod_socio = 'SN-00002',
    @dni = '87654321',
    @nombre = 'Lucía',
    @apellido = 'Fernández',
    @fecha_nac = '2010-08-20',
    @email = 'lucia.fernandez@mail.com',
    @tel = '1144556677',
    @tel_emerg = '1166778899',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'Galeno',
    @nro_afiliado = 'AFI67890',
    @tel_cobertura = '08101234567',
    @cod_responsable = 'NS-00001';
GO


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

-- 1. Prueba SP insertarAsiste

-- 2. Prueba SP modificarAsiste

-- 3. Prueba SP borrarAsiste