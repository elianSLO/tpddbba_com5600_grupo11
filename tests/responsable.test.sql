Use Com5600G11
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