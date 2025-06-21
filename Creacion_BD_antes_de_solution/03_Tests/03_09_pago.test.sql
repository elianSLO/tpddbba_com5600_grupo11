Use Com5600G11
GO

------ 4. PAGO

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Pago
DELETE FROM psn.Socio
DELETE FROM psn.Responsable

-- Antes debo insertar Socio o Responsable para hacer las pruebas

IF NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = 'SN-9000')
BEGIN
	INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
	VALUES ('SN-9000', 'Carlos', 'Ruiz', '12345678', 'carlos@correo.com', '1990-01-01', '1122334455', '1199887766', 'OSDE', '0001', '1133112233', 1, 0, NULL);
END;

IF NOT EXISTS (SELECT 1 FROM psn.Responsable WHERE cod_responsable = 'SN-1000')
BEGIN
	INSERT INTO psn.Responsable (cod_responsable, nombre, apellido, dni, email, tel)
	VALUES ('SN-10000', 'María', 'López', '87654321', 'maria@correo.com', '1144556677');
END;


-- 4.1 PRUEBA DE INSERCIÓN DE PAGO

EXEC stp.insertarPago
	@cod_pago = 1,
	@monto = 1500.00,
	@fecha_pago = '2025-06-10',
	@estado = 'Pagado',
	@responsable = 'SN-9000',
	@medio_pago = 'TARJETA';
GO

select * from psn.Pago
-- 4.2 PRUEBA DE MODIFICACIÓN DE PAGO  -- Se prueban todos los campos modificados en una sola prueba

EXEC stp.modificarPago
	@cod_pago = 1,
	@monto = 2500.00,
	@fecha_pago = '2025-06-15',
	@estado = 'Pendiente',
	@responsable = 'SN-10000',
	@medio_pago = 'TRANSFERENCIA';
GO

-- 4.3 PRUEBA DE BORRADO DE PAGO

EXEC stp.borrarPago
	@cod_pago = 1;
GO