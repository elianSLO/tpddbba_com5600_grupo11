
--- CASO 2 -- TABLA INVITADO

USE Com5600G11;
GO

-- Borrado de tabla previo
DELETE FROM Persona.Invitado 


-- PRUEBAS: INSERTAR INVITADO


-- Caso válido
EXEC Persona.insertarInvitado
    @cod_invitado = 'NS-9001',
    @dni = '12345678',
    @nombre = 'Lucas',
    @apellido = 'Varela',
    @fecha_nac = '1990-05-01',
    @email = 'lucas@email.com',
    @tel = '1122334455',
    @tel_emerg = '1199887766',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = '001',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL;

-- Error: DNI duplicado
EXEC Persona.insertarInvitado
    @cod_invitado = 'NS-9002',
    @dni = '12345678', -- ya existe
    @nombre = 'Pedro',
    @apellido = 'Gómez',
    @fecha_nac = '1995-08-10',
    @email = 'pedro@email.com',
    @tel = '1133445566',
    @tel_emerg = '1177889900',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'Swiss Medical',
    @nro_afiliado = '002',
    @tel_cobertura = '1155667788',
    @cod_responsable = NULL;

-- Error: Formato código inválido
EXEC Persona.insertarInvitado
    @cod_invitado = 'XX-0001',
    @dni = '87654321',
    @nombre = 'Ana',
    @apellido = 'Pérez',
    @fecha_nac = '2000-12-12',
    @email = 'ana@email.com',
    @tel = '1122334455',
    @tel_emerg = '1199887766',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'Medifé',
    @nro_afiliado = '003',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL;


-- PRUEBAS: MODIFICAR INVITADO


-- Modificación válida
EXEC Persona.modificarInvitado
    @cod_invitado = 'NS-9001',
    @dni = '12345678',
    @nombre = 'Lucas Modificado',
    @apellido = 'Varela Mod',
    @fecha_nac = '1990-05-01',
    @email = 'lucasmod@email.com',
    @tel = '1100110011',
    @tel_emerg = '1188887777',
    @estado = 0,
    @saldo = 1000,
    @nombre_cobertura = 'OSDE Nueva',
    @nro_afiliado = 'MOD001',
    @tel_cobertura = '1177778888',
    @cod_responsable = 0;

-- Error: No existe el invitado
EXEC Persona.modificarInvitado
    @cod_invitado = 'NS-9999', -- no existe
    @dni = '99999999',
    @nombre = 'No',
    @apellido = 'Existe',
    @fecha_nac = '1990-01-01',
    @email = 'no@email.com',
    @tel = '12345678',
    @tel_emerg = '12345678',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'Nada',
    @nro_afiliado = '000',
    @tel_cobertura = '12345678',
    @cod_responsable = 0;


-- PRUEBAS: BORRAR INVITADO


-- Borrado correcto
EXEC Persona.borrarInvitado @cod_invitado = 'NS-9001';

-- Error: Código no existe
EXEC Persona.borrarInvitado @cod_invitado = 'NS-9999';

-- Error: Código malformado
EXEC Persona.borrarInvitado @cod_invitado = 'BAD-CODE';

