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

------------------------------------------------------------- Prueba SP insertarAsiste

-- SET DE PRUEBAS PARA stp.insertarAsiste


-- 1. Caso válido
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 2. Registro duplicado (mismo socio, clase y fecha)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 3. Fecha futura
EXEC stp.insertarAsiste 
    @fecha = '2025-12-31',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 4. Fecha nula
EXEC stp.insertarAsiste 
    @fecha = NULL,
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 5. Código de socio inválido (formato incorrecto)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'S-00001', 
    @cod_clase = 1;
GO

-- 6. Código de clase inválido (NULL)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = NULL;
GO

-- 6. Código de clase inválido (negativo)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = -5;
GO

--  7. Socio no existente (pero formato válido)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'SN-99999',
    @cod_clase = 1;
GO

-- 8. Segundo registro válido (otro socio y clase)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-14',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO



----------------------------------------------------------------- Prueba SP modificarAsiste

-- 1. Modificación válida: cambiar fecha y clase del socio SN-00001
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-15',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 1,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_cod_clase    = 2;
GO

-- 2. Intentar modificar a un registro ya existente (duplicado)
-- El registro (2025-06-14, SN-00002, clase 2) ya existe
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-16',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-14',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;
GO

-- 3. Registro original inexistente
EXEC stp.modificarAsiste
    @fecha_original     = '2025-01-01',
    @cod_socio_original = 'SN-00099',
    @cod_clase_original = 9,
    @nueva_fecha        = '2025-06-17',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_cod_clase    = 1;
GO

-- 4. Nueva fecha futura
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-12-31',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;
GO

-- 5. Nueva fecha nula
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = NULL,
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;
GO

-- 6. Código de socio inválido (mal formado)
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SOC-01',
    @nuevo_cod_clase    = 2;
GO

-- 7. Código de clase inválido (NULL)
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = NULL;
GO

-- 8. Código de clase inválido (negativo)
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-14',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-16',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = -3;
GO

-- 9. Restaurar registro original modificado en la prueba 1 (opcional para dejar limpio)
EXEC stp.modificarAsiste
    @fecha_original     = '2025-06-16',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-15',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_cod_clase    = 1;
GO

--------------------------------------------------------------- Prueba SP borrarAsiste

-- 1. Borrar un registro existente (SN-00001, clase 1, fecha 2025-06-15)
-- Primero volvemos a insertar para asegurarnos que existe
EXEC stp.insertarAsiste 
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- Luego lo eliminamos
EXEC stp.borrarAsiste
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 2. Intentar borrar nuevamente el mismo registro (ya no existe)
EXEC stp.borrarAsiste
    @fecha = '2025-06-15',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 3. Eliminar un registro inexistente (fecha/código no coincide)
EXEC stp.borrarAsiste
    @fecha = '2025-01-01',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
GO

-- 4. Código de socio con formato válido pero no existente
EXEC stp.borrarAsiste
    @fecha = '2025-06-15',
    @cod_socio = 'SN-99999',
    @cod_clase = 1;
GO

-- 5. Borrar otro registro real existente (SN-00002, clase 2, fecha 2025-06-14)
EXEC stp.insertarAsiste 
    @fecha = '2025-06-14',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO

EXEC stp.borrarAsiste
    @fecha = '2025-06-14',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
GO
