Use Com5600G11
GO


----- 6. REEMBOLSO

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM Finanzas.Reembolso
DBCC CHECKIDENT ('Finanzas.Reembolso', RESEED, 0);

-- 6.1 INSERCION

EXEC Finanzas.insertarReembolso
    @monto = 1500.00,
    @medio_Pago = 'Transferencia',
    @fecha = '2025-06-10',
    @motivo = 'Consulta médica'; 
-- 6.2 MODIFICACION

EXEC Finanzas.modificarReembolso
    @codReembolso = 1,
    @monto = 2000.00,
    @medio_Pago = 'Tarjeta de crédito',
    @fecha = '2025-06-11',
    @motivo = 'Estudios clínicos';

-- 6.3 BORRADO

-- 6.3.1 Borrado Exitoso

EXEC Finanzas.borrarReembolso @codReembolso = 1;

-- 6.3.2 Borrado Fallido

EXEC Finanzas.borrarReembolso @codReembolso = 99;
