Use Com5600G11
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