-- PRUEBAS TABLAS ASISTE

-- Para las pruebas tengo que insertar datos en las tablas Socio, Clase, Actividad y Categoria

-- Limpiar tablas para pruebas limpias y consistentes (si es seguro)
USE Com5600G11
GO

SET NOCOUNT ON;

DELETE FROM Club.Suscripcion
DELETE FROM Actividad.Inscripto
DELETE FROM Actividad.Asiste;
DELETE FROM Actividad.Clase;
DBCC CHECKIDENT ('Actividad.Clase', RESEED, 0);
DELETE FROM Club.Categoria;
DBCC CHECKIDENT ('Club.Categoria', RESEED, 0);
DELETE FROM Club.Actividad;
DBCC CHECKIDENT ('Club.Actividad', RESEED, 0);
DELETE FROM Persona.Profesor;
DBCC CHECKIDENT ('Persona.Profesor', RESEED, 0);
DELETE FROM Persona.Socio

-- Insertar socios usando SP

EXEC Persona.insertarSocio
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

-- Insertar socio 2

EXEC Persona.insertarSocio
    @cod_socio = 'SN-00002',
    @dni = '87654321',
    @nombre = 'Lucía',
    @apellido = 'Fernández',
    @fecha_nac = '2000-08-20',
    @email = 'lucia.fernandez@mail.com',
    @tel = '1144556677',
    @tel_emerg = '1166778899',
    @estado = 1,
    @saldo = 0.00,
    @nombre_cobertura = 'Galeno',
    @nro_afiliado = 'AFI67890',
    @tel_cobertura = '08101234567',
    @cod_responsable = NULL;
GO


EXEC Club.insertarCategoria 'Cadete', 17,13, 1800.00, '2025-12-31', 18000.00, '2025-12-31';
EXEC Club.insertarCategoria 'Mayor', 99,18, 2300.00, '2025-12-31', 23000.00, '2025-12-31';

delete from Club.Suscripcion
EXEC Club.insertarActividad 'Futsal', 2500.00, '2025-12-31';
EXEC Club.insertarActividad 'Natación', 3000.00, '2025-12-31';

EXEC Persona.insertarProfesor 12123123, 'Pablo', 'Ramirez', 'pablo@mail.com', '1112312323';

EXEC Actividad.insertarClase 1, 1, 1, 'Lunes', '18:00';
EXEC Actividad.insertarClase 1, 2, 1, 'Lunes', '18:00';
EXEC Actividad.insertarClase 1, 2, 1, 'Miercoles', '18:00';


DECLARE @FechaActual DATE;
SET @FechaActual = CAST(GETDATE() AS DATE);
EXEC Actividad.insertarInscripto
    @fecha_inscripcion = @FechaActual,
    @estado            = 1,
    @cod_socio         = 'SN-00001',
    @cod_clase         = 1;


EXEC Actividad.insertarInscripto
    @fecha_inscripcion = @FechaActual,
    @estado            = 1,
    @cod_socio         = 'SN-00002',
    @cod_clase         = 1;


EXEC Actividad.insertarInscripto
    @fecha_inscripcion = @FechaActual,
    @estado            = 1,
    @cod_socio         = 'SN-00001',
    @cod_clase         = 2;

EXEC Actividad.insertarInscripto
    @fecha_inscripcion = @FechaActual,
    @estado            = 1,
    @cod_socio         = 'SN-00002',
    @cod_clase         = 2;
GO

------------------------------------------------------------- Prueba SP insertarAsiste

-- SET DE PRUEBAS PARA stp.insertarAsiste
PRINT ' '
PRINT '-------------------- TESTS --------------------'

-- 1. Caso válido
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @cod_socio = 'SN-00001',
    @estado = 'P',
    @cod_clase = 1;
GO

-- 2. Registro duplicado (mismo socio, clase y fecha)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @cod_socio = 'SN-00001',
    @estado = 'P',
    @cod_clase = 1;
GO

-- 3. Fecha futura
EXEC Actividad.insertarAsiste 
    @fecha = '2025-12-31',
    @cod_socio = 'SN-00001',
    @estado = 'P',
    @cod_clase = 1;
GO

-- 4. Fecha nula
EXEC Actividad.insertarAsiste 
    @fecha = NULL,
    @cod_socio = 'SN-00001',
    @estado = 'P',
    @cod_clase = 1;
GO

-- 5. Código de socio inválido (formato incorrecto)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @estado = 'P',
    @cod_socio = 'S-00001', 
    @cod_clase = 1;
GO

-- 6. Código de clase inválido (NULL)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @estado = 'P',
    @cod_socio = 'SN-00001',
    @cod_clase = NULL;
GO

-- 6. Código de clase inválido (negativo)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @estado = 'P',
    @cod_socio = 'SN-00001',
    @cod_clase = -5;
GO

--  7. Socio no existente (pero formato válido)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @estado = 'P',
    @cod_socio = 'SN-99999',
    @cod_clase = 1;
GO

-- 8. Estado invalido (opcion incorrecta)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-14',
    @estado = 'G',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO

-- 8. Estado invalido (NULL)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-14',
    @estado = NULL,
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO

-- 10. Segundo registro válido (otro socio y clase)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-14',
    @estado = 'P',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO




----------------------------------------------------------------- Prueba SP modificarAsiste

-- 1. Modificación válida: cambiar fecha y clase del socio SN-00001
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-16',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 1,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_cod_clase    = 2,
    @nuevo_estado       = 'A';
GO

-- 2. Intentar modificar a un registro ya existente (duplicado)
-- El registro (2025-06-14, SN-00002, clase 2) ya existe
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-16',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-14',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 2;
GO

-- 3. Registro original inexistente
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-01-01',
    @cod_socio_original = 'SN-00099',
    @cod_clase_original = 9,
    @nueva_fecha        = '2025-06-17',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 1;
GO

-- 4. Nueva fecha futura
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-12-31',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 2;
GO

-- 5. Nueva fecha nula
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = NULL,
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 2;
GO

-- 6. Código de socio inválido (mal formado)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SOC-01',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 2;
GO

-- 7. Código de socio inválido (no existe)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-02302',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SOC-01',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 2;
GO

-- 8. Código de clase inválido (NULL)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = NULL;
GO

-- 9. Código de clase inválido (No existe)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 10;
GO

-- 10. Código de clase inválido (negativo)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = -3;
GO

-- 11. Estado inválido (opcion incorrecta)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = 'G',
    @nuevo_cod_clase    =  3;
GO

-- 12. Estado inválido (NULL)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_estado       = NULL,
    @nuevo_cod_clase    = -3;
GO

-- 13. Restaurar registro original modificado en la prueba 1 (opcional para dejar limpio)
EXEC Actividad.modificarAsiste
    @fecha_original     = '2025-06-16',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_estado       = 'P',
    @nuevo_cod_clase    = 1;
GO

--------------------------------------------------------------- Prueba SP borrarAsiste

-- 1. Borrar un registro existente (SN-00001, clase 1, fecha 2025-06-15)
-- Primero volvemos a insertar para asegurarnos que existe
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-16',
    @cod_socio = 'SN-00001',
    @estado = 'P',
    @cod_clase = 1;
GO

-- Luego lo eliminamos
EXEC Actividad.borrarAsiste
    @fecha = '2025-06-16',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 2. Intentar borrar nuevamente el mismo registro (ya no existe)
EXEC Actividad.borrarAsiste
    @fecha = '2025-06-16',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 3. Eliminar un registro inexistente (fecha/código no coincide)
EXEC Actividad.borrarAsiste
    @fecha = '2025-01-01',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 4. Código de socio con formato válido pero no existente
EXEC Actividad.borrarAsiste
    @fecha = '2025-06-16',
    @cod_socio = 'SN-99999',
    @cod_clase = 1;
GO

-- 5. Borrar otro registro real existente (SN-00002, clase 2, fecha 2025-06-14)
EXEC Actividad.insertarAsiste 
    @fecha = '2025-06-14',
    @cod_socio = 'SN-00002',
    @estado = 'P',
    @cod_clase = 2;
GO

EXEC Actividad.borrarAsiste
    @fecha = '2025-06-14',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO
