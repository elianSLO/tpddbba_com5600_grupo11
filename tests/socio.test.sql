Use Com5600G11
GO

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