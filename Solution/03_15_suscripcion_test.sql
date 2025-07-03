

-- PRUEBA PARA TABLA SUSCRIPCION 

-- Suscripción relaciona Socio con Categoría.

-- Inserto varios Socios en Tabla Socio

DELETE FROM Persona.Socio

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
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL

EXEC Persona.insertarSocio
    @cod_socio = 'SN-00002',
    @dni = '23456789',
    @nombre = 'María',
    @apellido = 'Gómez',
    @fecha_nac = '1985-10-20',
    @email = 'maria.gomez@mail.com',
    @tel = '1166778899',
    @tel_emerg = '1177889900',
    @estado = 1,
    @saldo = 500,
    @nombre_cobertura = 'Swiss Medical',
    @nro_afiliado = 'SM87654321',
    @tel_cobertura = '1199887766',
    @cod_responsable = NULL;

EXEC Persona.insertarSocio
    @cod_socio = 'SN-00003',
    @dni = '34567890',
    @nombre = 'Carlos',
    @apellido = 'Fernández',
    @fecha_nac = '2005-08-15',
    @email = 'carlos.fernandez@mail.com',
    @tel = '1155337799',
    @tel_emerg = '1155223366',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'Galeno',
    @nro_afiliado = 'GA65432109',
    @tel_cobertura = '1133667788',
    @cod_responsable = NULL;

EXEC Persona.insertarSocio
    @cod_socio = 'SN-00004',
    @dni = '45678901',
    @nombre = 'Lucía',
    @apellido = 'Martínez',
    @fecha_nac = '1999-03-12',
    @email = 'lucia.martinez@mail.com',
    @tel = '1133445566',
    @tel_emerg = '1144223344',
    @estado = 1,
    @saldo = 150,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS11223344',
    @tel_cobertura = '1122113344',
    @cod_responsable = NULL;

EXEC Persona.insertarSocio
    @cod_socio = 'SN-00005',
    @dni = '56789012',
    @nombre = 'Tomás',
    @apellido = 'Ruiz',
    @fecha_nac = '2010-07-30',
    @email = 'tomas.ruiz@mail.com',
    @tel = '1144667788',
    @tel_emerg = '1177993355',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'Hospital Italiano',
    @nro_afiliado = 'HI99887766',
    @tel_cobertura = '1100998877',
    @cod_responsable = NULL;

-- Verifico que se insertaron correctamente

SELECT * FROM Persona.Socio 


----- Inserto en tabla Categoria

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM Actividad.Categoria
DBCC CHECKIDENT ('Actividad.Categoria', RESEED, 0);

-- INSERTO LAS 3 CATEGORIAS VALIDAS

EXEC Actividad.insertarCategoria 
    @descripcion = 'Menor',
	@edad_max = 12,
    @valor_mensual = 10000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 1200000.00, 
    @vig_valor_anual = '10-05-2025';

EXEC Actividad.insertarCategoria 
    @descripcion = 'Cadete',
	@edad_max = 17,
    @valor_mensual = 10000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 2000000.00, 
    @vig_valor_anual = '10-05-2025';

EXEC Actividad.insertarCategoria 
    @descripcion = 'Mayor',
	@edad_max = 99,
    @valor_mensual = 25000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 2000000.00, 
    @vig_valor_anual = '10-05-2025';

-- Verifico 

SELECT * FROM Actividad.Categoria


-- Pruebo SP insertarSuscripcion

-- Limpio la tabla Suscripcion para pruebas (si es seguro)

DELETE FROM Club.Suscripcion


----------------------------------------------------------- 1. PRUEBAS STORED PROCEDURE insertarSuscripcion


-- PRUEBA 1
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00003',
    @tipoSuscripcion = 'M',
    @cod_categoria = 2;  
-- Esperado: 'Categoria incorrecta'


-- PRUEBA 2: Suscripción válida anual
-- Tomás (14 años) en categoría Cadete (edad_max = 17)
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00005',
    @tipoSuscripcion = 'A',
    @cod_categoria = 2; 
-- Esperado: Inserción OK


-- PRUEBA 3: Suscripción válida mensual
-- Juan (35 años) en categoría Mayor (edad_max = 99)
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00001',
    @tipoSuscripcion = 'M',
    @cod_categoria = 3; 
-- Esperado: Inserción OK


-- PRUEBA 4: Tipo de suscripción inválido ('Z')
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00001',
    @tipoSuscripcion = 'Z',
    @cod_categoria = 3;
-- Esperado: 'Tipo de suscripcion erronea'


-- PRUEBA 5: Socio inexistente
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-99999',
    @tipoSuscripcion = 'M',
    @cod_categoria = 1;
-- Esperado: 'No existe socio'


-- PRUEBA 6: Edad fuera de rango
-- María (39 años) en categoría Menor (edad_max = 12)
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00002',
    @tipoSuscripcion = 'A',
    @cod_categoria = 1; 
-- Esperado: 'Categoria incorrecta'


-- Verificar resultados esperados del test (2 inserciones correctas, una mensual y una anual)
SELECT * FROM Club.Suscripcion;


--------------------------------------------------------2. PRUEBAS DE STORED PROCEDURE modificarSuscripcion


-- PRUEBA 1: Modificación correcta

EXEC Club.modificarSuscripcion
    @cod_socio = 'SN-00005',
    @nueva_cat = 3,  
    @tiempo = 'A';


-- PRUEBA 2: Categoría incorrecta

EXEC Club.modificarSuscripcion
    @cod_socio = 'SN-00001',
    @nueva_cat = 4,  
    @tiempo = 'M';

-- PRUEBA 3: Socio que no tiene suscripción

EXEC Club.modificarSuscripcion
    @cod_socio = 'SN-00002',  
    @nueva_cat = 3,
    @tiempo = 'M';

-- PRUEBA 5: Tipo de Suscripción no válido

EXEC Club.modificarSuscripcion
    @cod_socio = 'SN-00001',
    @nueva_cat = 3,  
    @tiempo = 'D';


-------------------------------------------------------- 3. PRUEBAS DE STORED PROCEDURE borrarSuscripcion

-- RESETEO DE DATOS

-- Elimino suscripciones

DELETE FROM Club.Suscripcion 

-- Inserto una suscripción para cada uno para probar luego el borrado
EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00001',
    @tipoSuscripcion = 'M',
    @cod_categoria = 3;  

EXEC Club.insertarSuscripcion
    @cod_socio = 'SN-00005',
    @tipoSuscripcion = 'A',
    @cod_categoria = 2;  

-- VERIFICACIÓN DE INSERCIONES

SELECT * FROM Club.Suscripcion WHERE cod_socio IN ('SN-00001', 'SN-00005');

-- PRUEBA 3.1: Eliminar suscripción existente (SN-00001)

EXEC Club.borrarSuscripcion @cod_socio = 'SN-00001';

--  PRUEBA 3.2: Eliminar nuevamente la misma (debería dar error)

EXEC Club.borrarSuscripcion @cod_socio = 'SN-00001';

-- PRUEBA 3.3: Eliminar otra suscripción válida (SN-00005)

EXEC Club.borrarSuscripcion @cod_socio = 'SN-00005';

-- PRUEBA 3.4: Intentar borrar un código inexistente

EXEC Club.borrarSuscripcion @cod_socio = 'SN-99999';

--- VERIFICACIÓN FINAL: Los socios 1 y 5 fueron dados de baja como suscriptores

SELECT * FROM Club.Suscripcion WHERE cod_socio IN ('SN-00001', 'SN-00005');









