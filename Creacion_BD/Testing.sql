-- SCRIPT DE PRUEBAS

--Estas pruebas se ejecutaran paso por paso siguiendo las instruccion en el orden dado

-- Usar la base de datos

Use Com5600G11
GO

-----------PRUEBA 1: TABLA SOCIO

------ 1.1 INSERCION

-- CASO 1.1.1: Inserción válida

EXEC stp.insertarSocio
	@dni = '12345678',
	@nombre = 'Juan',
	@apellido = 'Pérez',
	@fecha_nac = '1990-05-20',
	@email = 'juan.perez@email.com',
	@tel = '1123456789',
	@tel_emerg = '1198765432',
	@estado = 1,
	@saldo = 1000.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'A12345',
	@tel_cobertura = '1134567890',
	@cod_responsable = 1;

-- CASO 1.1.2: DNI ya existente (debe fallar por duplicado)

EXEC stp.insertarSocio
	@dni = '12345679', -- mismo DNI que antes
	@nombre = 'Carlos',
	@apellido = 'Gómez',
	@fecha_nac = '1985-01-10',
	@email = 'carlos.gomez@email.com',
	@tel = '1134567891',
	@tel_emerg = '1198765433',
	@estado = 1,
	@saldo = 200.00,
	@nombre_cobertura = 'Swiss Medical',
	@nro_afiliado = 'B67890',
	@tel_cobertura = '1145678901',
	@cod_responsable = 1;

-- CASO 1.1.3: Email inválido (debe fallar por validación)

EXEC stp.insertarSocio
	@dni = '87654321',
	@nombre = 'Ana',
	@apellido = 'Martínez',
	@fecha_nac = '1992-11-15',
	@email = 'ana.martinez-email.com', -- sin @
	@tel = '1134567892',
	@tel_emerg = '1198765434',
	@estado = 1,
	@saldo = 500.00,
	@nombre_cobertura = 'Medifé',
	@nro_afiliado = 'C54321',
	@tel_cobertura = '1156789012',
	@cod_responsable = 1;

-- CASO 1.1.4: Fecha de nacimiento futura (debe fallar)

EXEC stp.insertarSocio
	@dni = '23456789',
	@nombre = 'Lucía',
	@apellido = 'Fernández',
	@fecha_nac = '2100-01-01',
	@email = 'lucia.fernandez@email.com',
	@tel = '1134567893',
	@tel_emerg = '1198765435',
	@estado = 1,
	@saldo = 300.00,
	@nombre_cobertura = 'Galeno',
	@nro_afiliado = 'D98765',
	@tel_cobertura = '1167890123',
	@cod_responsable = 1;

-- CASO 1.1.5: Saldo negativo (debe fallar)

EXEC stp.insertarSocio
	@dni = '34567890',
	@nombre = 'Pedro',
	@apellido = 'López',
	@fecha_nac = '1980-07-07',
	@email = 'pedro.lopez@email.com',
	@tel = '1134567894',
	@tel_emerg = '1198765436',
	@estado = 1,
	@saldo = -100.00,
	@nombre_cobertura = 'IOMA',
	@nro_afiliado = 'E11223',
	@tel_cobertura = '1178901234',
	@cod_responsable = 1;

-- CASO 1.1.6: Teléfono con letras (debe fallar)
-- Nota: Se utiliza la misma validación para teléfono auxiliar y teléfono de cobertura

EXEC stp.insertarSocio
	@dni = '45678901',
	@nombre = 'Sofía',
	@apellido = 'Ramírez',
	@fecha_nac = '1995-09-30',
	@email = 'sofia.ramirez@email.com',
	@tel = '444A5678', -- contiene letra
	@tel_emerg = '1198765437',
	@estado = 1,
	@saldo = 0.00,
	@nombre_cobertura = 'Osdepym',
	@nro_afiliado = 'F33445',
	@tel_cobertura = '1189012345',
	@cod_responsable = 1;

-- CASO 1.1.7: Campo obligatorio NULL (debe fallar)

EXEC stp.insertarSocio
	@dni = NULL,
	@nombre = 'Marta',
	@apellido = 'Suárez',
	@fecha_nac = '1988-03-25',
	@email = 'marta.suarez@email.com',
	@tel = '1134567895',
	@tel_emerg = '1198765438',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'Accord Salud',
	@nro_afiliado = 'G55667',
	@tel_cobertura = '1190123456',
	@cod_responsable = 1;

-- CONSULTA FINAL: Ver los datos reales insertados

-- SOCIOS INSERTADOS CORRECTAMENTE 
SELECT * FROM psn.Socio

------ 1.2 MODIFICACION DE LA TABLA SOCIO

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Socio
DBCC CHECKIDENT ('psn.Socio', RESEED, 0);

-- Aseguramos que exista un socio base para modificar
-- Este debe coincidir con un 'cod_socio' que vayamos a usar en las pruebas

-- Inserción de socio para pruebas

EXEC stp.insertarSocio
	@dni = '87654329',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.gutierrez@email.com',
	@tel = '1130000001',
	@tel_emerg = '1140000001',
	@estado = 1,
	@saldo = 300.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X12345',
	@tel_cobertura = '1150000001',
	@cod_responsable = 1;

-- CASO 1.2.1: Modificación válida

EXEC stp.modificarSocio
	@cod_socio = 1,
	@dni = '87654321',
	@nombre = 'Carlos A.',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.a.gutierrez@email.com',
	@tel = '1130000002',
	@tel_emerg = '1140000002',
	@estado = 1,
	@saldo = 500.00,
	@nombre_cobertura = 'Swiss Medical',
	@nro_afiliado = 'X12345-2',
	@tel_cobertura = '1150000002',
	@cod_responsable = 1;

-- CASO 1.2.2: Código de socio no existente (debe fallar)

EXEC stp.modificarSocio
	@cod_socio = 9999,
	@dni = '12345678',
	@nombre = 'Inexistente',
	@apellido = 'Socio',
	@fecha_nac = '1990-01-01',
	@email = 'test@email.com',
	@tel = '1131231234',
	@tel_emerg = '1143214321',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'Medife',
	@nro_afiliado = 'Z00000',
	@tel_cobertura = '1177777777',
	@cod_responsable = 1;

-- CASO 1.2.3: Fecha de nacimiento futura (debe fallar)

EXEC stp.modificarSocio
	@cod_socio = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '2100-01-01',
	@email = 'carlos@email.com',
	@tel = '1130000003',
	@tel_emerg = '1140000003',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000003',
	@cod_responsable = 1;

-- CASO 1.2.4: Email inválido (debe fallar)

EXEC stp.modificarSocio
	@cod_socio = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.email.com', -- sin @
	@tel = '1130000004',
	@tel_emerg = '1140000004',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000004',
	@cod_responsable = 1;

-- CASO 1.2.5: Teléfono con letras (debe fallar)

EXEC stp.modificarSocio
	@cod_socio = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos@email.com',
	@tel = '11A34567',
	@tel_emerg = '1140000005',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000005',
	@cod_responsable = 1;


-- CASO 1.2.6: Saldo negativo (debe fallar)

EXEC stp.modificarSocio
	@cod_socio = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos@email.com',
	@tel = '1130000006',
	@tel_emerg = '1140000006',
	@estado = 1,
	@saldo = -50.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000006',
	@cod_responsable = 1;


-- CASO 1.2.7: Campo obligatorio en NULL (debe fallar)

EXEC stp.modificarSocio
	@cod_socio = 1,
	@dni = NULL,
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos@email.com',
	@tel = '1130000007',
	@tel_emerg = '1140000007',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000007',
	@cod_responsable = 1;


-- CONSULTA FINAL: Ver el socio modificado

SELECT * FROM psn.Socio WHERE cod_socio = 1;

---- 1.3 BORRADO DE TABLA SOCIO

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Socio
DBCC CHECKIDENT ('psn.Socio', RESEED, 0);

-- Insertar socio para borrar

EXEC stp.insertarSocio
	@dni = '99887236',
	@nombre = 'Laura',
	@apellido = 'Martínez',
	@fecha_nac = '1992-03-05',
	@email = 'laura.martinez@email.com',
	@tel = '1123456789',
	@tel_emerg = '1134567890',
	@estado = 1,
	@saldo = 150.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'LM123456',
	@tel_cobertura = '1145678901',
	@cod_responsable = 1;

-- CASO 1.3.1: Borrado de socio existente

EXEC stp.borrarSocio @cod_socio = 1;

-- Verificar que se borró

SELECT * FROM psn.Socio WHERE cod_socio = 1;

-- CASO 1.3.2: Borrado de socio inexistente

EXEC stp.borrarSocio @cod_socio = 9999;

-------------------------------------------------------------------------------------------------

--- CASO 2 -- TABLA INVITADO

------ 2.1 INSERCION

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Invitado
DBCC CHECKIDENT ('psn.Invitado', RESEED, 0);


-- CASO 2.1.1: Inserción válida

EXEC stp.insertarInvitado
	@dni = '12345678',
	@nombre = 'Juan',
	@apellido = 'Pérez',
	@fecha_nac = '1990-05-20',
	@email = 'juan.perez@email.com',
	@tel = '1123456789',
	@tel_emerg = '1198765432',
	@estado = 1,
	@saldo = 1000.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'A12345',
	@tel_cobertura = '1134567890',
	@cod_responsable = 1;

-- CASO 2.1.2: DNI ya existente (debe fallar por duplicado)

EXEC stp.insertarInvitado
	@dni = '12345678', -- mismo DNI que antes
	@nombre = 'Carlos',
	@apellido = 'Gómez',
	@fecha_nac = '1985-01-10',
	@email = 'carlos.gomez@email.com',
	@tel = '1134567891',
	@tel_emerg = '1198765433',
	@estado = 1,
	@saldo = 200.00,
	@nombre_cobertura = 'Swiss Medical',
	@nro_afiliado = 'B67890',
	@tel_cobertura = '1145678901',
	@cod_responsable = 1;

-- CASO 2.1.3: Email inválido (debe fallar por validación)

EXEC stp.insertarInvitado
	@dni = '87654321',
	@nombre = 'Ana',
	@apellido = 'Martínez',
	@fecha_nac = '1992-11-15',
	@email = 'ana.martinez-email.com', -- sin @
	@tel = '1134567892',
	@tel_emerg = '1198765434',
	@estado = 1,
	@saldo = 500.00,
	@nombre_cobertura = 'Medifé',
	@nro_afiliado = 'C54321',
	@tel_cobertura = '1156789012',
	@cod_responsable = 1;

-- CASO 2.1.4: Fecha de nacimiento futura (debe fallar)

EXEC stp.insertarInvitado
	@dni = '23456789',
	@nombre = 'Lucía',
	@apellido = 'Fernández',
	@fecha_nac = '2100-01-01',
	@email = 'lucia.fernandez@email.com',
	@tel = '1134567893',
	@tel_emerg = '1198765435',
	@estado = 1,
	@saldo = 300.00,
	@nombre_cobertura = 'Galeno',
	@nro_afiliado = 'D98765',
	@tel_cobertura = '1167890123',
	@cod_responsable = 1;

-- CASO 2.1.5: Saldo negativo (debe fallar)

EXEC stp.insertarInvitado
	@dni = '34567890',
	@nombre = 'Pedro',
	@apellido = 'López',
	@fecha_nac = '1980-07-07',
	@email = 'pedro.lopez@email.com',
	@tel = '1134567894',
	@tel_emerg = '1198765436',
	@estado = 1,
	@saldo = -100.00,
	@nombre_cobertura = 'IOMA',
	@nro_afiliado = 'E11223',
	@tel_cobertura = '1178901234',
	@cod_responsable = 1;

-- CASO 2.1.6: Teléfono con letras (debe fallar)

EXEC stp.insertarInvitado
	@dni = '45678901',
	@nombre = 'Sofía',
	@apellido = 'Ramírez',
	@fecha_nac = '1995-09-30',
	@email = 'sofia.ramirez@email.com',
	@tel = '444A5678', -- contiene letra
	@tel_emerg = '1198765437',
	@estado = 1,
	@saldo = 0.00,
	@nombre_cobertura = 'Osdepym',
	@nro_afiliado = 'F33445',
	@tel_cobertura = '1189012345',
	@cod_responsable = 1;

-- CASO 2.1.7: Campo obligatorio NULL (debe fallar)

EXEC stp.insertarInvitado
	@dni = NULL,
	@nombre = 'Marta',
	@apellido = 'Suárez',
	@fecha_nac = '1988-03-25',
	@email = 'marta.suarez@email.com',
	@tel = '1134567895',
	@tel_emerg = '1198765438',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'Accord Salud',
	@nro_afiliado = 'G55667',
	@tel_cobertura = '1190123456',
	@cod_responsable = 1;

-- CONSULTA FINAL: Ver los datos reales insertados

-- INVITADOS INSERTADOS CORRECTAMENTE 

SELECT * FROM psn.Invitado

------ 1.2 MODIFICACION DE LA TABLA INVITADOS

-- Aseguramos que exista un invitado base para modificar
-- Este debe coincidir con un `cod_invitado` que vayamos a usar en las pruebas

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Invitado
DBCC CHECKIDENT ('psn.Invitado', RESEED, 0);

-- INSERTANDO SOCIO BASE PARA PRUEBAS

EXEC stp.insertarInvitado
	@dni = '87654329',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.gutierrez@email.com',
	@tel = '1130000001',
	@tel_emerg = '1140000001',
	@estado = 1,
	@saldo = 300.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X12345',
	@tel_cobertura = '1150000001',
	@cod_responsable = 1;


-- CASO 2.2.1: Modificación válida

EXEC stp.modificarInvitado
	@cod_invitado = 2,
	@dni = '87654321',
	@nombre = 'Carlos A.',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.a.gutierrez@email.com',
	@tel = '1130000002',
	@tel_emerg = '1140000002',
	@estado = 1,
	@saldo = 500.00,
	@nombre_cobertura = 'Swiss Medical',
	@nro_afiliado = 'X12345-2',
	@tel_cobertura = '1150000002',
	@cod_responsable = 1;

-- CASO 2.2.2: Código de socio no existente (debe fallar)

EXEC stp.modificarInvitado
	@cod_invitado = 9999,
	@dni = '12345678',
	@nombre = 'Inexistente',
	@apellido = 'Socio',
	@fecha_nac = '1990-01-01',
	@email = 'test@email.com',
	@tel = '1131231234',
	@tel_emerg = '1143214321',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'Medife',
	@nro_afiliado = 'Z00000',
	@tel_cobertura = '1177777777',
	@cod_responsable = 1;

-- CASO 2.2.3: Fecha de nacimiento futura (debe fallar)

EXEC stp.modificarInvitado
	@cod_invitado = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '2100-01-01',
	@email = 'carlos@email.com',
	@tel = '1130000003',
	@tel_emerg = '1140000003',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000003',
	@cod_responsable = 1;

-- CASO 2.2.4: Email inválido (debe fallar)

EXEC stp.modificarInvitado
	@cod_invitado = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.email.com', -- sin @
	@tel = '1130000004',
	@tel_emerg = '1140000004',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000004',
	@cod_responsable = 1;

-- CASO 2.2.5: Teléfono con letras (debe fallar)

EXEC stp.modificarInvitado
	@cod_invitado = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos@email.com',
	@tel = '11A34567',
	@tel_emerg = '1140000005',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000005',
	@cod_responsable = 1;


-- CASO 2.2.6: Saldo negativo (debe fallar)

EXEC stp.modificarInvitado
	@cod_invitado = 1,
	@dni = '87654321',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos@email.com',
	@tel = '1130000006',
	@tel_emerg = '1140000006',
	@estado = 1,
	@saldo = -50.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000006',
	@cod_responsable = 1;


-- CASO 2.2.7: Campo obligatorio en NULL (debe fallar)

EXEC stp.modificarInvitado
	@cod_invitado = 1,
	@dni = NULL,
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos@email.com',
	@tel = '1130000007',
	@tel_emerg = '1140000007',
	@estado = 1,
	@saldo = 100.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X54321',
	@tel_cobertura = '1150000007',
	@cod_responsable = 1;


-- CONSULTA FINAL: Ver el invitado modificado

SELECT * FROM psn.Invitado WHERE cod_invitado = 1;

---- 2.3 BORRADO DE TABLA INVITADO

-- Insertar invitado para borrar

EXEC stp.insertarInvitado
	@dni = '99887236',
	@nombre = 'Laura',
	@apellido = 'Martínez',
	@fecha_nac = '1992-03-05',
	@email = 'laura.martinez@email.com',
	@tel = '1123456789',
	@tel_emerg = '1134567890',
	@estado = 1,
	@saldo = 150.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'LM123456',
	@tel_cobertura = '1145678901',
	@cod_responsable = 1;

-- CASO 2.3.1: Borrado de invitado existente

EXEC stp.borrarInvitado @cod_invitado = 1;
-- Verificar que se borró
SELECT * FROM psn.Invitado WHERE cod_invitado = 1;

-- CASO 1.3.2: Borrado de invitado inexistente

EXEC stp.borrarInvitado @cod_invitado = 9999;

-------------------------------------------------------------------------------------------------

--- CASO 3: TABLA PROFESOR

-- 3.1 INSERCION EN LA TABLA PROFESOR

-- Asegúrate de que la tabla psn.Profesor existe antes de ejecutar las pruebas

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- 3.1.1. Inserción exitosa
EXEC stp.insertarProfesor 
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @email = 'juan.perez@email.com',
    @tel = '9876114321';

-- 3.1.2. DNI duplicado
EXEC stp.insertarProfesor 
    @dni = '12345678',
    @nombre = 'Carlos',
    @apellido = 'Ramírez',
    @email = 'carlos.ramirez@email.com',
    @tel = '12345678';

-- 3.1.3. DNI inválido (menos de 8 caracteres)
EXEC stp.insertarProfesor 
    @dni = '12345',
    @nombre = 'Ana',
    @apellido = 'López',
    @email = 'ana.lopez@email.com',
    @tel = '987654321';

-- 3.1.4. Email inválido
EXEC stp.insertarProfesor 
    @dni = '87654321',
    @nombre = 'Lucía',
    @apellido = 'Gómez',
    @email = 'lucia#correo',
    @tel = '987654321';

-- 3.1.5. Teléfono con caracteres no numéricos
EXEC stp.insertarProfesor 
    @dni = '23456789',
    @nombre = 'Mario',
    @apellido = 'Torres',
    @email = 'mario.torres@email.com',
    @tel = '9876ABCD';

-- 6. Teléfono demasiado corto
EXEC stp.insertarProfesor 
    @dni = '34567890',
    @nombre = 'Laura',
    @apellido = 'Martínez',
    @email = 'laura.martinez@email.com',
    @tel = '123456';

-- 7. Campo NULL
EXEC stp.insertarProfesor 
    @dni = NULL,
    @nombre = 'Pedro',
    @apellido = 'Jiménez',
    @email = 'pedro.jimenez@email.com',
    @tel = '12345678';

-- Verifica los registros insertados

SELECT * FROM psn.Profesor;


----- CASO 3.2 MODIFICACION DE TABLA PROFESOR

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- CREAR UN PROFESOR BASE PARA MODIFICACIONES
EXEC stp.insertarProfesor
    @dni = '87654322',
    @nombre = 'Juan',
    @apellido = 'Perez',
    @email = 'juan.perez@correo.com',
    @tel = '1134667890';

-- CASO 3.2.1: Modificación válida

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654321',
    @nombre = 'Carlos',
    @apellido = 'Ramirez',
    @email = 'carlos.ramirez@correo.com',
    @tel = '1134567890';

-- CASO 3.2.2: Profesor no existente (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 999,
    @dni = '12345678',
    @nombre = 'Roberto',
    @apellido = 'García',
    @email = 'roberto.garcia@correo.com',
    @tel = '1122334455';

-- CASO 3.2.3: DNI inválido (menos de 8 dígitos, debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '1234567', -- 7 dígitos
    @nombre = 'Laura',
    @apellido = 'Martinez',
    @email = 'laura.martinez@correo.com',
    @tel = '1134567891';

-- CASO 3.2.4: Nombre con caracteres inválidos (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654322',
    @nombre = 'An@',
    @apellido = 'Ramirez',
    @email = 'ana.ramirez@correo.com',
    @tel = '1134567892';

-- CASO 3.2.5: Apellido con números (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654323',
    @nombre = 'Lucía',
    @apellido = 'Rami2ez',
    @email = 'lucia.ramirez@correo.com',
    @tel = '1134567893';

-- CASO 3.2.6: Email inválido (sin arroba, debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654324',
    @nombre = 'Diego',
    @apellido = 'Sosa',
    @email = 'diego.sosaemail.com', -- inválido
    @tel = '1134567894';

-- CASO 3.2.7: Teléfono con letras (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654325',
    @nombre = 'Paula',
    @apellido = 'Fernández',
    @email = 'paula.fernandez@correo.com',
    @tel = '11345ABCD'; -- inválido

-- CASO 3.2.8: Teléfono muy corto (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654326',
    @nombre = 'Martín',
    @apellido = 'López',
    @email = 'martin.lopez@correo.com',
    @tel = '123456'; -- menos de 10 dígitos

-- CASO 3.2.9: Campo obligatorio NULL (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = NULL, -- campo nulo
    @nombre = 'Verónica',
    @apellido = 'Suárez',
    @email = 'veronica.suarez@correo.com',
    @tel = '1134567895';

-- CONSULTA FINAL: Ver estado del profesor base

SELECT * FROM psn.Profesor WHERE cod_prof = 1;

---------------- CASO 3.3 BORRADO DE TABLA PROFESOR

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- Insertar profesor para borrar

EXEC stp.insertarProfesor
	@dni = '99887236',
	@nombre = 'Laura',
	@apellido = 'Martínez',
	@email = 'laura.martinez@email.com',
	@tel = '1123456789'

-- Verificar inserción correcta

SELECT * FROM psn.Profesor

-- CASO 3.3.1: Borrado de socio existente

EXEC stp.borrarProfesor @cod_prof = 1;

-- Verificar que se borró

SELECT * FROM psn.Profesor WHERE cod_prof = 1;

-- CASO 3.3.2: Borrado de socio inexistente

EXEC stp.borrarProfesor @cod_prof = 9999;



------------------------------------------------------------------------------------
--CONTINUAR








