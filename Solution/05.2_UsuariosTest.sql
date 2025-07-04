USE Com5600G11;
GO

-- Simular sesión como JefeTesoreria
EXECUTE AS USER = 'JefeTesoreria';
GO

----------------------------------------------------------------------------------------------------------------
-- 1. Ejecutar SP permitido (Finanzas)
----------------------------------------------------------------------------------------------------------------
BEGIN TRY
    EXEC Finanzas.insertarPago 
        @cod_pago = 1,
        @monto = 1500.00,
        @fecha_pago = '2025-06-10',
        @estado = 'Pagado',
        @responsable = 'SN-0000',
        @medio_pago = 'TARJETA';

    RAISERROR('OK: Puede ejecutar procedimiento de Finanzas.insertarPago.', 0, 1);
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('ERROR: No puede ejecutar procedimiento de Finanzas.insertarPago. Detalles: %s', 16, 1, @msg);
END CATCH;
GO

----------------------------------------------------------------------------------------------------------------
-- 2. Intentar ejecutar SP no permitido (Persona)
----------------------------------------------------------------------------------------------------------------
BEGIN TRY
    EXEC Persona.insertarInvitado
        @cod_invitado = 'NS-9001',
        @dni = '12345678',
        @nombre = 'Lucas',
        @apellido = 'Varela',
        @fecha_nac = '1990-05-01',
        @email = 'lucas@email.com',
        @tel = '1122334455',
        @estado = 1,
        @saldo = 0,
        @nombre_cobertura = 'OSDE',
        @nro_afiliado = '001',
        @tel_cobertura = '1144556677',
        @cod_responsable = NULL;

    RAISERROR('ERROR: ¡Pudo ejecutar Persona.insertarInvitado y no debería!', 16, 1);
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Bloqueo correcto: no puede ejecutar Persona.insertarInvitado. Detalles: %s', 0, 1, @msg);
END CATCH;
GO

----------------------------------------------------------------------------------------------------------------
-- 3. Intentar SELECT sin permiso
----------------------------------------------------------------------------------------------------------------
BEGIN TRY
    SELECT TOP 1 * FROM Persona.Socio;

    RAISERROR('ERROR: ¡Pudo hacer SELECT en Persona.Socio y no debería!', 16, 1);
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Bloqueo correcto: no puede hacer SELECT en Persona.Socio. Detalles: %s', 0, 1, @msg);
END CATCH;
GO

----------------------------------------------------------------------------------------------------------------
-- 4. Intentar SELECT con permiso
----------------------------------------------------------------------------------------------------------------
BEGIN TRY
    SELECT TOP 1 * FROM Finanzas.Pago;

    RAISERROR('OK: ¡Pudo hacer SELECT en Finanzas.Pago!', 16, 1);
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Bloqueo correcto: no puede hacer SELECT en Finanzas.Pago. Detalles: %s', 0, 1, @msg);
END CATCH;
GO

----------------------------------------------------------------------------------------------------------------
-- Restaurar contexto original
REVERT;
GO

----------------------------------------------------------------------------------------------------------------






-- Simular sesión como AdministrativoSocio
EXECUTE AS USER = 'AdministrativoSocio';
GO

-- 1. Ejecutar SP no permitido (Finanzas)
BEGIN TRY
    EXEC Finanzas.insertarPago 
        @cod_pago = 1,
        @monto = 1500.00,
        @fecha_pago = '2025-06-10',
        @estado = 'Pagado',
        @responsable = 'SN-0000',
        @medio_pago = 'TARJETA';

    RAISERROR('ERROR: ¡Pudo ejecutar Finanzas.insertarPago y no debería!', 16, 1);
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Bloqueo correcto: no puede ejecutar Finanzas.insertarPago. Detalles: %s', 0, 1, @msg);
END CATCH;
GO

-- 2. Ejecutar SP permitido (Persona)
BEGIN TRY
    EXEC Persona.insertarInvitado
        @cod_invitado = 'NS-9001',
        @dni = '12345678',
        @nombre = 'Lucas',
        @apellido = 'Varela',
        @fecha_nac = '1990-05-01',
        @email = 'lucas@email.com',
        @tel = '1122334455',
        @estado = 1,
        @saldo = 0,
        @nombre_cobertura = 'OSDE',
        @nro_afiliado = '001',
        @tel_cobertura = '1144556677',
        @cod_responsable = NULL;

    RAISERROR('OK: Pudo ejecutar Persona.insertarInvitado correctamente.', 16, 1);
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('ERROR: No pudo ejecutar Persona.insertarInvitado. Detalles: %s', 0, 1, @msg);
END CATCH;
GO

REVERT;
GO
