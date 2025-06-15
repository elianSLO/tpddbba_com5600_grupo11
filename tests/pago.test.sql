Use Com5600G11
GO

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