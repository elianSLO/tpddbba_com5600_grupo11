

-- PRUEBA PARA TABLA SUSCRIPCION 

-- Suscripci�n relaciona Socio con Categor�a.

-- Inserto varios Socios en Tabla Socio

DELETE FROM psn.Socio

EXEC stp.insertarSocio
    @cod_socio = 'SN-00001',
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'P�rez',
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

EXEC stp.insertarSocio
    @cod_socio = 'SN-00002',
    @dni = '23456789',
    @nombre = 'Mar�a',
    @apellido = 'G�mez',
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

EXEC stp.insertarSocio
    @cod_socio = 'SN-00003',
    @dni = '34567890',
    @nombre = 'Carlos',
    @apellido = 'Fern�ndez',
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

EXEC stp.insertarSocio
    @cod_socio = 'SN-00004',
    @dni = '45678901',
    @nombre = 'Luc�a',
    @apellido = 'Mart�nez',
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

EXEC stp.insertarSocio
    @cod_socio = 'SN-00005',
    @dni = '56789012',
    @nombre = 'Tom�s',
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

SELECT * FROM psn.Socio 


----- Inserto en tabla Categoria

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM psn.Categoria
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);

-- INSERTO LAS 3 CATEGORIAS VALIDAS

EXEC stp.insertarCategoria 
    @descripcion = 'Menor',
	@edad_max = 12,
    @valor_mensual = 10000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 1200000.00, 
    @vig_valor_anual = '10-05-2025';

EXEC stp.insertarCategoria 
    @descripcion = 'Cadete',
	@edad_max = 17,
    @valor_mensual = 10000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 2000000.00, 
    @vig_valor_anual = '10-05-2025';

EXEC stp.insertarCategoria 
    @descripcion = 'Mayor',
	@edad_max = 99,
    @valor_mensual = 25000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 2000000.00, 
    @vig_valor_anual = '10-05-2025';

-- Verifico 

SELECT * FROM psn.Categoria


-- Pruebo SP insertarSuscripcion

-- ========================================
-- PRUEBAS PROCEDIMIENTO stp.insertarSuscripcion
-- ========================================

-- PRUEBA 1: Edad supera la edad m�xima de la categor�a
-- Carlos (19 a�os) en categor�a Cadete (edad_max = 17)
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-00003',
    @tipoSuscripcion = 'M',
    @cod_categoria = 2;  -- Cadete
-- Esperado: 'Categoria incorrecta'


-- PRUEBA 2: Suscripci�n v�lida anual
-- Tom�s (14 a�os) en categor�a Cadete (edad_max = 17)
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-00005',
    @tipoSuscripcion = 'A',
    @cod_categoria = 2; -- Cadete
-- Esperado: Inserci�n OK


-- PRUEBA 3: Suscripci�n v�lida mensual
-- Juan (35 a�os) en categor�a Mayor (edad_max = 99)
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-00001',
    @tipoSuscripcion = 'M',
    @cod_categoria = 3; -- Mayor
-- Esperado: Inserci�n OK


-- PRUEBA 4: Tipo de suscripci�n inv�lido ('Z')
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-00001',
    @tipoSuscripcion = 'Z',
    @cod_categoria = 3;
-- Esperado: 'Tipo de suscripcion erronea'


-- PRUEBA 5: Socio inexistente
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-99999',
    @tipoSuscripcion = 'M',
    @cod_categoria = 1;
-- Esperado: 'No existe socio'


-- PRUEBA 6: Edad fuera de rango
-- Mar�a (39 a�os) en categor�a Menor (edad_max = 12)
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-00002',
    @tipoSuscripcion = 'A',
    @cod_categoria = 1; -- Menor
-- Esperado: 'Categoria incorrecta'

-- PRUEBA 7: Edad igual al l�mite (requiere categor�a nueva)
-- Luc�a (26 a�os) en categor�a con edad_max = 26
-- Insertar nueva categor�a especial

EXEC stp.insertarCategoria 
    @descripcion = 'Especial 26',
    @edad_max = 26,
    @valor_mensual = 15000.00, 
    @vig_valor_mens = '2026-01-01', 
    @valor_anual = 180000.00, 
    @vig_valor_anual = '2025-05-10';

-- Suponiendo que el cod_categoria insertado es el 4:
EXEC stp.insertarSuscripcion
    @cod_socio = 'SN-00004',
    @tipoSuscripcion = 'M',
    @cod_categoria = 4;
-- Esperado: Inserci�n OK

-- ========================================
-- Verificar resultados
-- ========================================
SELECT * FROM psn.Suscripcion;





