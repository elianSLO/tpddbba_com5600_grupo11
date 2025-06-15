-- SCRIPT DE PRUEBAS

--Estas pruebas se ejecutaran paso por paso siguiendo las instruccion en el orden dado

-- Usar la base de datos

Use Com5600G11
GO

-- Prueba 1: SPs para Tabla Socio
-- Prueba 2: SPs para Tabla Invitado
-- Prueba 3: Sps para Tabla Profesor
-- Prueba 4: SPs para Tabla Pago
-- Prueba 5:
-- Prueba 6:
-- Prueba 7:

-----------PRUEBA 1: TABLA SOCIO

DELETE FROM psn.Socio

-- CASO 1.1 INSERCION

-- CASO 1.1.1 Inserción válida

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
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = 'NS-00001';

-- CASO 1.1.2. DNI repetido (12345678 ya existe)

EXEC stp.insertarSocio
    @cod_socio = 'SN-00002',
    @dni = '12345678',
    @nombre = 'Carlos',
    @apellido = 'Gómez',
    @fecha_nac = '1985-01-20',
    @email = 'carlos@mail.com',
    @tel = '12345678',
    @tel_emerg = '12345678',
    @estado = 1,
    @saldo = 100,
    @nombre_cobertura = 'Swiss Medical',
    @nro_afiliado = 'SM87654321',
    @tel_cobertura = '12345678',
    @cod_responsable = 'SN-00002';

-- CASO 1.1.3. Código de socio con formato incorrecto

EXEC stp.insertarSocio
    @cod_socio = 'S-00003',
    @dni = '23456789',
    @nombre = 'Ana',
    @apellido = 'López',
    @fecha_nac = '1992-08-12',
    @email = 'ana@mail.com',
    @tel = '1123456789',
    @tel_emerg = '1134567890',
    @estado = 1,
    @saldo = 200,
    @nombre_cobertura = 'Medife',
    @nro_afiliado = 'MD12345678',
    @tel_cobertura = '1156789012',
    @cod_responsable = 'SN-00003';

-- 1.1.4. Código de responsable con formato inválido

EXEC stp.insertarSocio
    @cod_socio = 'SN-00004',
    @dni = '34567890',
    @nombre = 'Lucía',
    @apellido = 'Martínez',
    @fecha_nac = '1988-03-30',
    @email = 'lucia@mail.com',
    @tel = '1145678912',
    @tel_emerg = '1167890123',
    @estado = 1,
    @saldo = 150,
    @nombre_cobertura = 'Galeno',
    @nro_afiliado = 'GL123456',
    @tel_cobertura = '1189012345',
    @cod_responsable = 'XSN-00001'; -- inválido

-- 1.1.5. Teléfono con letras

EXEC stp.insertarSocio
    @cod_socio = 'SN-00005',
    @dni = '45678901',
    @nombre = 'Pedro',
    @apellido = 'Ramírez',
    @fecha_nac = '1995-09-10',
    @email = 'pedro@mail.com',
    @tel = '11ABC67890', -- inválido
    @tel_emerg = '1122334455',
    @estado = 1,
    @saldo = 80,
    @nombre_cobertura = 'PAMI',
    @nro_afiliado = 'PM123456',
    @tel_cobertura = '1133445566',
    @cod_responsable = 'SN-00005';

-- 1.1.6. Email inválido

EXEC stp.insertarSocio
    @cod_socio = 'SN-00006',
    @dni = '56789012',
    @nombre = 'María',
    @apellido = 'Suárez',
    @fecha_nac = '1993-11-25',
    @email = 'maria.mail.com', -- inválido
    @tel = '1155667788',
    @tel_emerg = '1122334455',
    @estado = 1,
    @saldo = 50,
    @nombre_cobertura = 'IOMA',
    @nro_afiliado = 'IO987654',
    @tel_cobertura = '1144556677',
    @cod_responsable = 'SN-00006';

-- 1.1.7. Fecha de nacimiento futura

EXEC stp.insertarSocio
    @cod_socio = 'SN-00007',
    @dni = '67890123',
    @nombre = 'Esteban',
    @apellido = 'Sosa',
    @fecha_nac = '2099-01-01', -- inválido
    @email = 'esteban@mail.com',
    @tel = '1122446688',
    @tel_emerg = '1133557799',
    @estado = 1,
    @saldo = 70,
    @nombre_cobertura = 'Osde',
    @nro_afiliado = 'OS998877',
    @tel_cobertura = '1177889900',
    @cod_responsable = 'NS-00007';

-- 1.1.8. Saldo negativo

EXEC stp.insertarSocio
    @cod_socio = 'SN-00008',
    @dni = '78901234',
    @nombre = 'Joaquín',
    @apellido = 'Nieto',
    @fecha_nac = '1991-04-18',
    @email = 'joaquin@mail.com',
    @tel = '1199887766',
    @tel_emerg = '1122446688',
    @estado = 1,
    @saldo = -100, -- inválido
    @nombre_cobertura = 'Medicus',
    @nro_afiliado = 'MD654321',
    @tel_cobertura = '1166778899',
    @cod_responsable = 'SN-00008';


-- CASO 1.2 MODIFICACION

-- CASO 1.2.1 - Modificacion Valida

EXEC stp.modificarSocio
    @cod_socio = 'SN-00001',
    @dni = '11112222',
    @nombre = 'Juan',
    @apellido = 'González',
    @fecha_nac = '1985-12-10',
    @email = 'juan.gonzalez@mail.com',
    @tel = '1199887766',
    @tel_emerg = '1133445566',
    @estado = 0,
    @saldo = 100,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS123456',
    @tel_cobertura = '1144556677',
    @cod_responsable = 'SN-00001';

-- CASO 1.2.2. Código de socio inexistente
EXEC stp.modificarSocio
    @cod_socio = 'SN-99999', -- no existe
    @dni = '12345678',
    @nombre = 'Carlos',
    @apellido = 'Rodríguez',
    @fecha_nac = '1991-05-20',
    @email = 'carlos@mail.com',
    @tel = '1133221100',
    @tel_emerg = '1122334455',
    @estado = 1,
    @saldo = 50,
    @nombre_cobertura = 'Galeno',
    @nro_afiliado = 'GL001122',
    @tel_cobertura = '1177889900',
    @cod_responsable = 'NS-00002';

-- CASO 1.2.3. Código de responsable inválido
EXEC stp.modificarSocio
    @cod_socio = 'SN-00001',
    @dni = '11112222',
    @nombre = 'María',
    @apellido = 'Pérez',
    @fecha_nac = '1993-03-25',
    @email = 'maria@mail.com',
    @tel = '1144556677',
    @tel_emerg = '1133557799',
    @estado = 1,
    @saldo = 200,
    @nombre_cobertura = 'Medicus',
    @nro_afiliado = 'MD123456',
    @tel_cobertura = '1166778899',
    @cod_responsable = 'XX-00001'; -- inválido

-- CASO 1.2.4. Email inválido

EXEC stp.modificarSocio
    @cod_socio = 'SN-00001',
    @dni = '11112222',
    @nombre = 'Pedro',
    @apellido = 'Sosa',
    @fecha_nac = '1980-06-18',
    @email = 'pedro.mail.com', -- mal formato
    @tel = '1144556677',
    @tel_emerg = '1122334455',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'IOMA',
    @nro_afiliado = 'IO555666',
    @tel_cobertura = '1177889900',
    @cod_responsable = 'NS-00002';

-- CASO 1.2.5. Teléfono con letras

EXEC stp.modificarSocio
    @cod_socio = 'SN-00001',
    @dni = '11112222',
    @nombre = 'Lucía',
    @apellido = 'García',
    @fecha_nac = '1999-02-15',
    @email = 'lucia@mail.com',
    @tel = '11A234567', -- letras
    @tel_emerg = '1144556677',
    @estado = 1,
    @saldo = 300,
    @nombre_cobertura = 'OMINT',
    @nro_afiliado = 'OM998877',
    @tel_cobertura = '1133445566',
    @cod_responsable = 'SN-00002';

-- CASO 1.2.6. Fecha de nacimiento futura

EXEC stp.modificarSocio
    @cod_socio = 'SN-00001',
    @dni = '11112222',
    @nombre = 'Esteban',
    @apellido = 'Martínez',
    @fecha_nac = '2099-01-01', -- futura
    @email = 'esteban@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1122334455',
    @estado = 1,
    @saldo = 100,
    @nombre_cobertura = 'Galeno',
    @nro_afiliado = 'GL123123',
    @tel_cobertura = '1144556677',
    @cod_responsable = 'SN-00001';

-- CASO 1.2.7. Saldo negativo
EXEC stp.modificarSocio
    @cod_socio = 'SN-00001',
    @dni = '11112222',
    @nombre = 'Joaquín',
    @apellido = 'Sánchez',
    @fecha_nac = '1984-11-11',
    @email = 'joaquin@mail.com',
    @tel = '1133557799',
    @tel_emerg = '1177889900',
    @estado = 1,
    @saldo = -100, -- inválido
    @nombre_cobertura = 'Medife',
    @nro_afiliado = 'MF123123',
    @tel_cobertura = '1188997766',
    @cod_responsable = 'SN-00003';

-- CASO 1.3 BORRADO

-- 1.3.1.  Borrado válido (el socio SN-00001 debería existir si ejecutaste las pruebas anteriores)
EXEC stp.borrarSocio @cod_socio = 'SN-00001';

-- 1.3.2. Socio inexistente
EXEC stp.borrarSocio @cod_socio = 'SN-99999';

-- 1.3.3. Formato de código inválido (letra de más)
EXEC stp.borrarSocio @cod_socio = 'SNN-12345';

-- 1.3.4. Formato de código inválido (faltan números)
EXEC stp.borrarSocio @cod_socio = 'SN-123';

-- 1.3.5. Código vacío
EXEC stp.borrarSocio @cod_socio = '';


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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';


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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';

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
	@cod_responsable = 'SN-00003';


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
	@cod_responsable = 'SN-00003';


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
	@cod_responsable = 'SN-00003';


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
	@cod_responsable = 'SN-00003';

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

------ 4. PAGO

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Pago
DBCC CHECKIDENT ('psn.Pago', RESEED, 0);

-- Antes debo insertar Socio o Invitado para hacer las pruebas


-- 4.1 PRUEBA DE INSERCIÓN DE PAGO

EXEC stp.insertarPago
	@monto = 1500.00,
	@fecha_pago = '2025-06-10',
	@estado = 'Pagado',
	@cod_socio = 1,  -- Asegurarse que este socio exista, sino dará error
	@cod_invitado = NULL;
GO

select * from psn.Pago
-- 4.2 PRUEBA DE MODIFICACIÓN DE PAGO

EXEC stp.modificarPago
	@cod_pago = 1,  -- Reemplazar con el ID real insertado
	@monto = 1800.00,
	@fecha_pago = '2025-06-12',
	@estado = 'Pendiente',
	@cod_socio = 1,
	@cod_invitado = NULL;  -- Asegurate que este invitado exista
GO

-- 4.3 PRUEBA DE BORRADO DE PAGO

EXEC stp.borrarPago
	@cod_pago = 1;
GO


-- 5. RESPONSABLE

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM psn.Responsable
DBCC CHECKIDENT ('psn.Responsable', RESEED, 0);


-- 5.1 PRUEBA DE INSERCIÓN DE RESPONSABLE

EXEC stp.insertarResponsable
    @dni = '12345678',
    @nombre = 'Carlos',
    @apellido = 'Ramirez',
    @email = 'carlos.ramirez@example.com',
    @parentezco = 'Padre',
    @fecha_nac = '1980-05-15',
    @nro_socio = 101,        -- Socio existente
    @tel = '1134567890';
GO

-- 5.2 PRUEBA DE MODIFICACIÓN DE RESPONSABLE

EXEC stp.modificarResponsable
    @cod_responsable = 1,     -- Reemplazar por el valor real
    @dni = '12345678',
    @nombre = 'Carlos',
    @apellido = 'Ramírez',
    @email = 'cramirez@example.com',
    @parentezco = 'Padre',
    @fecha_nac = '1980-05-15',
    @nro_socio = 101,
    @tel = '1134567899';
GO

-- 5.3 PRUEBA DE BORRADO DE RESPONSABLE

EXEC stp.borrarResponsable
    @cod_responsable = 'SN-00003';
GO

----- 6. REEMBOLSO

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM psn.Reembolso
DBCC CHECKIDENT ('psn.Reembolso', RESEED, 0);

-- 6.1 INSERCION

EXEC stp.insertarReembolso
    @monto = 1500.00,
    @medio_Pago = 'Transferencia',
    @fecha = '2025-06-10',
    @motivo = 'Consulta médica'; 

-- 6.2 MODIFICACION

EXEC stp.modificarReembolso
    @codReembolso = 1,
    @monto = 2000.00,
    @medio_Pago = 'Tarjeta de crédito',
    @fecha = '2025-06-11',
    @motivo = 'Estudios clínicos';

-- 6.3 BORRADO

-- 6.3.1 Borrado Exitoso

EXEC stp.borrarReembolso @codReembolso = 1;

-- 6.3.2 Borrado Fallido

EXEC stp.borrarReembolso @codReembolso = 99;


-- 7. CATEGORIA

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM psn.Categoria
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);


-- 7.1.1 INSERCION VALIDA

EXEC stp.insertarCategoria 
    @descripcion = 'Mayor',
	@edad_max = 40,
    @valor_mensual = 1000.00, 
    @vig_valor_mens = '10-05-2026', 
    @valor_anual = 10000.00, 
    @vig_valor_anual = '10-05-2025';

-- Verificación de inserción

SELECT * FROM psn.Categoria WHERE descripcion = 'Mayor';

-- 7.1.2 Valor incorrecto en Descripcion (debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Adulto', -- debe ser 'Cadete','Mayor' o 'Menor'
	@edad_max = 40,
    @valor_mensual = 1500.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 16000.00,
    @vig_valor_anual = '2025-07-01';

-- 7.1.3 Valor de la suscripción negativo (debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Menor',
	@edad_max = 15,
    @valor_mensual = -100.00,  -- Negativo
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 16000.00,
    @vig_valor_anual = '2025-07-01';

-- 7.1.4 Valor anual nulo (debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Cadete',
	@edad_max = 20,
    @valor_mensual = 1200.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = NULL,  -- Nulo
    @vig_valor_anual = '2025-07-01';

-- 7.1.5 Fecha pasada (debe dar error) 

EXEC stp.insertarCategoria 
    @descripcion = 'Mayor',
	@edad_max = 40,
    @valor_mensual = 1200.00,
    @vig_valor_mens = '2023-01-01',  -- Fecha en el pasado
    @valor_anual = 15000.00,
    @vig_valor_anual = '2025-07-01';

-- 7.1.6 Fecha pasada anual (Debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Menor',
	@edad_max = 12,
    @valor_mensual = 1300.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 14000.00,
    @vig_valor_anual = '2023-01-01';  -- Fecha en el pasado

-- 7.1.7 Edad incorrecta

EXEC stp.insertarCategoria 
    @descripcion = 'Mayor',
	@edad_max = -19,
    @valor_mensual = 1500.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 16000.00,
    @vig_valor_anual = '2025-07-01';


-- 7.2 MODIFICACION 

-- 7.2.1 MODIFICACIÓN VÁLIDA

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Cadete',
    @edad_max = 35,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '12-31-2025',
    @valor_anual = 12000.00,
    @vig_valor_anual = '12-31-2025';

--  7.2.2 Categoría no existente

EXEC stp.modificarCategoria 
    @cod_categoria = 999,
    @descripcion = 'Mayor',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '10-02-2025';

--  7.2.3 Descripción inválida

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Senior', -- inválido
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--  7.2.4 Edad máxima <= 0

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Mayor',
    @edad_max = 0,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--  7.2.5 Valor mensual <= 0

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Menor',
    @edad_max = 40,
    @valor_mensual = 0, -- inválido
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--  7.2.6 Valor anual nulo

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Menor',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = NULL, -- inválido
    @vig_valor_anual = '2025-06-01';

-- 7.2.7 Fecha de vigencia mensual pasada

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Cadete',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2020-01-01', -- pasada
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--- 7.2.8 Fecha de vigencia anual pasada

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Mayor',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2020-01-01'; -- pasada


----------- 7.3 BORADO DE CATEGORIA

-- 7.3.1 Borrado Exitoso

EXEC stp.borrarCategoria @cod_categoria = 1;

-- 7.3.2 Borrado Fallido

EXEC stp.borrarCategoria @cod_categoria = 999;

---------------------------------------------------------------------------------

-- 8. ACTIVIDAD

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Actividad;
DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);

-- 8.1 INSERCIÓN DE ACTIVIDADES

-- 8.1.1 INSERCIÓN VÁLIDA
EXEC stp.insertarActividad
    @nombre = 'Futsal',
    @valor_mensual = 2500.00,
    @vig_valor = '2026-01-01';

-- Verificación de inserción
SELECT * FROM psn.Actividad WHERE nombre = 'Futsal';

-- 8.1.2 INSERCIÓN VÁLIDA (otra actividad)
EXEC stp.insertarActividad
    @nombre = 'Natación',
    @valor_mensual = 3000.00,
    @vig_valor = '2025-12-31';

-- Verificación de inserción
SELECT * FROM psn.Actividad WHERE nombre = 'Natación';

-- 8.1.3 Nombre de Actividad Incorrecto (debe dar error)
EXEC stp.insertarActividad
    @nombre = 'Basquet', -- No permitido en la lista
    @valor_mensual = 2000.00,
    @vig_valor = '2025-11-01';

-- 8.1.4 Valor Mensual Negativo o Cero (debe dar error)
EXEC stp.insertarActividad
    @nombre = 'Vóley',
    @valor_mensual = 0.00, -- Valor inválido
    @vig_valor = '2025-10-01';

EXEC stp.insertarActividad
    @nombre = 'Taekwondo',
    @valor_mensual = -500.00, -- Valor inválido
    @vig_valor = '2025-09-01';

-- 8.1.5 Fecha de Vigencia Pasada (debe dar error)
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
SELECT * FROM psn.Actividad WHERE nombre = 'Futsal';

-- 8.2.2 Actividad No Existente (debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Yoga', -- No existe y no está en la lista de actividades permitidas
    @valor_mensual = 1800.00,
    @vig_valor = '2025-12-01';

-- 8.2.3 Nombre de Actividad Incorrecto (aunque exista, si la SP valida el nombre, debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Deporte', -- No permitido en la lista
    @valor_mensual = 1800.00,
    @vig_valor = '2025-12-01';

-- 8.2.4 Valor Mensual Negativo o Cero (debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Natación',
    @valor_mensual = -10.00, -- Valor inválido
    @vig_valor = '2025-11-15';

EXEC stp.modificarActividad
    @nombre = 'Natación',
    @valor_mensual = 0.00, -- Valor inválido
    @vig_valor = '2025-11-15';

-- 8.2.5 Fecha de Vigencia Pasada (debe dar error)
EXEC stp.modificarActividad
    @nombre = 'Futsal',
    @valor_mensual = 2800.00,
    @vig_valor = '2023-05-20'; -- Fecha pasada

---
-- 8.3 ELIMINACIÓN DE ACTIVIDADES

-- 8.3.1 Eliminación Exitosa (se asume 'Natación' existe)
EXEC stp.eliminarActividad @nombre = 'Natación';

-- Verificación de eliminación
SELECT * FROM psn.Actividad WHERE nombre = 'Natación'; -- Debe retornar 0 filas

-- 8.3.2 Eliminación Fallida (Actividad no existente)
EXEC stp.eliminarActividad @nombre = 'Vóley'; -- 'Vóley' no fue insertado en este script hasta ahora

EXEC stp.eliminarActividad @nombre = 'Natación'; -- Intentar eliminar de nuevo 'Natación', que ya fue borrada


-- 9. RESERVA

-- Limpiar la tabla psn.Reserva para pruebas
DELETE FROM psn.Reserva;
DBCC CHECKIDENT ('psn.Reserva', RESEED, 0);

-- Vaciar tablas y Preparar tablas
DELETE FROM psn.Socio;
DELETE FROM psn.Invitado;
-- responsable
EXEC stp.insertarInvitado
	@dni = '87654429',
    @cod_invitado = 'NS-0001',
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
	@cod_responsable = NULL;
EXEC stp.insertarSocio
    @cod_socio = 'SN-12345',
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nac = '1990-05-15',
    @email = 'juan@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL;
EXEC stp.insertarSocio
    @cod_socio = 'SN-56789',
    @dni = '12333378',
    @nombre = 'Maria',
    @apellido = 'Garcia',
    @fecha_nac = '1990-05-15',
    @email = 'maria@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL;

--9.1 INSERCIÓN DE RESERVAS

-- 9.1.1 INSERCIÓN VÁLIDA (Reserva de Socio)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 500.00,
    @fechahoraInicio = '2025-07-01 10:00:00',
    @fechahoraFin = '2025-07-01 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- Verificación de inserción
SELECT * FROM psn.Reserva WHERE cod_socio = 'SN-12345';

-- 9.1.2 INSERCIÓN VÁLIDA (Reserva de Invitado)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-0001',
    @monto = 750.00,
    @fechahoraInicio = '2025-07-02 14:00:00',
    @fechahoraFin = '2025-07-02 15:30:00',
    @piletaSUMColonia = 'SUM';

-- Verificación de inserción
SELECT * FROM psn.Reserva WHERE cod_invitado = 'NS-0001';

-- 9.1.3 Error: Ni cod_socio ni cod_invitado especificados (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = '2025-07-03 09:00:00',
    @fechahoraFin = '2025-07-03 10:00:00',
    @piletaSUMColonia = 'Colonia';

-- 9.1.4 Error: Ambos cod_socio y cod_invitado especificados (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = 'NS-0001',
    @monto = 200.00,
    @fechahoraInicio = '2025-07-04 11:00:00',
    @fechahoraFin = '2025-07-04 12:00:00',
    @piletaSUMColonia = 'Pileta Niños';

-- 9.1.5 Error: Formato de cod_socio erróneo (menos de 4 dígitos) (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-123',
    @cod_invitado = NULL,
    @monto = 300.00,
    @fechahoraInicio = '2025-07-05 13:00:00',
    @fechahoraFin = '2025-07-05 14:00:00',
    @piletaSUMColonia = 'Cancha Futbol';

-- 9.1.6 Error: Formato de cod_invitado erróneo (más de 4 dígitos, según SP) (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-00001', -- El SP solo acepta 4 dígitos para invitado
    @monto = 300.00,
    @fechahoraInicio = '2025-07-05 13:00:00',
    @fechahoraFin = '2025-07-05 14:00:00',
    @piletaSUMColonia = 'Cancha Futbol';

-- 9.1.7 Error: cod_socio no existente (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-9999',
    @cod_invitado = NULL,
    @monto = 400.00,
    @fechahoraInicio = '2025-07-06 10:00:00',
    @fechahoraFin = '2025-07-06 11:00:00',
    @piletaSUMColonia = 'Gimnasio';

-- 9.1.8 Error: cod_invitado no existente (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-9999',
    @monto = 500.00,
    @fechahoraInicio = '2025-07-07 14:00:00',
    @fechahoraFin = '2025-07-07 15:00:00',
    @piletaSUMColonia = 'Salón Eventos';

-- 9.1.9 Error: Monto NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = NULL, -- Inválido
    @fechahoraInicio = '2025-07-08 10:00:00',
    @fechahoraFin = '2025-07-08 11:00:00',
    @piletaSUMColonia = 'Cancha Tenis';

-- 9.1.10 Error: fechainicio NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = NULL, -- Inválido
    @fechahoraFin = '2025-07-09 11:00:00',
    @piletaSUMColonia = 'Cancha Tenis';

-- 9.1.11 Error: fechafin NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = '2025-07-09 10:00:00',
    @fechahoraFin = NULL, -- Inválido
    @piletaSUMColonia = 'Cancha Tenis';

-- 9.1.12 Error: piletaSUMColonia NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = '2025-07-10 10:00:00',
    @fechahoraFin = '2025-07-10 11:00:00',
    @piletaSUMColonia = NULL; -- Inválido

-- 9.1.13 Error: Fecha y hora de inicio en el pasado (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 600.00,
    @fechahoraInicio = '2024-01-01 09:00:00', -- Pasado
    @fechahoraFin = '2024-01-01 10:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.14 Error: Fecha y hora de inicio es igual o posterior a la de fin (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 700.00,
    @fechahoraInicio = '2025-07-11 10:00:00',
    @fechahoraFin = '2025-07-11 10:00:00', -- Igual
    @piletaSUMColonia = 'Pileta Principal';

EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 700.00,
    @fechahoraInicio = '2025-07-11 11:00:00',
    @fechahoraFin = '2025-07-11 10:00:00', -- Inicio posterior a fin
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.15 Error: Duración de reserva menor a 60 minutos (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 800.00,
    @fechahoraInicio = '2025-07-12 10:00:00',
    @fechahoraFin = '2025-07-12 10:45:00', -- 45 minutos
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.16 Error: Monto de reserva menor o igual a cero (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 0.00, -- Inválido
    @fechahoraInicio = '2025-07-13 10:00:00',
    @fechahoraFin = '2025-07-13 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.17 Error: Solapamiento de reserva para el mismo recurso (debe dar error)
-- Insertar una reserva base para generar solapamiento
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 500.00,
    @fechahoraInicio = '2025-08-01 10:00:00',
    @fechahoraFin = '2025-08-01 12:00:00',
    @piletaSUMColonia = 'SUM';

-- Intento de solapamiento total
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 550.00,
    @fechahoraInicio = '2025-08-01 10:30:00',
    @fechahoraFin = '2025-08-01 11:30:00',
    @piletaSUMColonia = 'SUM';

-- Intento de solapamiento al inicio
EXEC stp.insertarReserva
    @cod_socio = 'SN-56789', -- Se cambió el socio para evitar la misma persona
    @cod_invitado = NULL,
    @monto = 550.00,
    @fechahoraInicio = '2025-08-01 09:30:00',
    @fechahoraFin = '2025-08-01 10:30:00',
    @piletaSUMColonia = 'SUM';

-- Intento de solapamiento al final
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 550.00,
    @fechahoraInicio = '2025-08-01 11:30:00',
    @fechahoraFin = '2025-08-01 12:30:00',
    @piletaSUMColonia = 'SUM';

---

-- 9.2 MODIFICACIÓN DE RESERVAS

-- Insertar una reserva para modificar
DECLARE @codReservaModificar INT;
EXEC stp.insertarReserva
    @cod_socio = 'SN-56789',
    @cod_invitado = NULL,
    @monto = 900.00,
    @fechahoraInicio = '2025-09-01 08:00:00',
    @fechahoraFin = '2025-09-01 09:30:00',
    @piletaSUMColonia = 'Colonia',
    @return_cod_reserva = @codReservaModificar OUTPUT; -- Obtener el ID de la reserva recién insertada

-- 9.2.1 MODIFICACIÓN VÁLIDA
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345', -- Cambiando socio
    @cod_invitado = NULL,
    @monto = 950.00,
    @fechahoraInicio = '2025-09-01 10:00:00', -- Cambiando horario
    @fechahoraFin = '2025-09-01 11:30:00',
    @piletaSUMColonia = 'Colonia';

-- Verificación de modificación
-- SELECT * FROM psn.Reserva WHERE cod_reserva = @codReservaModificar;

-- Insertar otra reserva para modificar (con invitado)
DECLARE @codReservaModificar2 INT;
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-0002',
    @monto = 600.00,
    @fechahoraInicio = '2025-09-02 16:00:00',
    @fechahoraFin = '2025-09-02 17:00:00',
    @piletaSUMColonia = 'Gimnasio',
    @return_cod_reserva = @codReservaModificar2 OUTPUT;

-- 9.2.2 MODIFICACIÓN VÁLIDA (cambiando de invitado a socio)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar2,
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 620.00,
    @fechahoraInicio = '2025-09-02 16:00:00',
    @fechahoraFin = '2025-09-02 17:00:00',
    @piletaSUMColonia = 'Gimnasio';

-- Verificación de modificación
-- SELECT * FROM psn.Reserva WHERE cod_reserva = @codReservaModificar2;

-- 9.2.3 Error: Código de reserva no existente (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = 9999, -- No existe
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-01 10:00:00',
    @fechahoraFin = '2025-10-01 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.4 Error: Ni cod_socio ni cod_invitado especificados (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = NULL,
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-02 10:00:00',
    @fechahoraFin = '2025-10-02 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.5 Error: Ambos cod_socio y cod_invitado especificados (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345',
    @cod_invitado = 'NS-0001',
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-03 10:00:00',
    @fechahoraFin = '2025-10-03 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.6 Error: Formato de cod_socio erróneo (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-ABC',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-04 10:00:00',
    @fechahoraFin = '2025-10-04 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.7 Error: cod_socio no existente (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-9999',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-05 10:00:00',
    @fechahoraFin = '2025-10-05 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.8 Error: Fecha de inicio en el pasado (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2024-01-01 10:00:00', -- Pasada
    @fechahoraFin = '2025-10-06 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.9 Error: Monto menor o igual a cero (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 0.00, -- Inválido
    @fechahoraInicio = '2025-10-07 10:00:00',
    @fechahoraFin = '2025-10-07 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.10 Error: Solapamiento con otra reserva existente (debe dar error)
-- Insertar una tercera reserva para causar solapamiento
DECLARE @codReservaSolapada INT;
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 400.00,
    @fechahoraInicio = '2025-11-01 14:00:00',
    @fechahoraFin = '2025-11-01 16:00:00',
    @piletaSUMColonia = 'Pileta Niños',
    @return_cod_reserva = @codReservaSolapada OUTPUT;
PRINT 'Código de Reserva Solapada (esperado): ' + CAST(@codReservaSolapada AS VARCHAR(10));

-- Intentar modificar @codReservaModificar para que se solape con @codReservaSolapada
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-56789', -- Se cambió el socio para evitar la misma persona
    @cod_invitado = NULL,
    @monto = 900.00,
    @fechahoraInicio = '2025-11-01 15:00:00', -- Se solapa con @codReservaSolapada
    @fechahoraFin = '2025-11-01 17:00:00',
    @piletaSUMColonia = 'Pileta Niños';

---

-- 9.3 ELIMINACIÓN DE RESERVAS

-- Insertar una reserva para eliminar exitosamente
DECLARE @codReservaEliminar INT;
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 150.00,
    @fechahoraInicio = '2025-12-01 09:00:00',
    @fechahoraFin = '2025-12-01 10:00:00',
    @piletaSUMColonia = 'SUM',
    @return_cod_reserva = @codReservaEliminar OUTPUT;

-- 9.3.1 Eliminación Exitosa
EXEC stp.borrarReserva @cod_reserva = @codReservaEliminar;

-- Verificación de eliminación
-- SELECT * FROM psn.Reserva WHERE cod_reserva = @codReservaEliminar; -- Debe retornar 0 filas

-- 9.3.2 Eliminación Fallida (Reserva no existente)
EXEC stp.borrarReserva @cod_reserva = 99999; -- No existe









