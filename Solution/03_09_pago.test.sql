Use Com5600G11
GO

------ 4. PAGO

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM Finanzas.Pago
DELETE FROM Finanzas.Factura
DELETE FROM Persona.Socio
DELETE FROM Persona.Responsable
DBCC CHECKIDENT ('Finanzas.Factura', RESEED, 0);
DBCC CHECKIDENT ('Finanzas.Pago', RESEED, 0);
-- Antes debo insertar Socio o Responsable para hacer las pruebas

INSERT INTO Persona.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES ('SN-9000', 'Carlos', 'Ruiz', '12345678', 'carlos@correo.com', '1990-01-01', '1122334455', '1199887766', 'OSDE', '0001', '1133112233', 1, 0, NULL);
INSERT INTO Persona.Responsable (cod_responsable, nombre, apellido, dni, email, tel)
VALUES ('SN-10000', 'María', 'López', '87654321', 'maria@correo.com', '1144556677');

EXEC Finanzas.emitirFactura @cod_socio = 'SN-9000' 
SELECT * FROM Finanzas.Factura

-- 4.1 PRUEBA DE INSERCIÓN DE PAGO

EXEC Finanzas.insertarPago
	@cod_factura = 1,
	@fecha_pago = '2025-06-10',
	@responsable = 'SN-9000',
	@medio_pago = 'TARJETA';
GO
select * from Finanzas.Pago
SELECT * FROM Finanzas.Factura -- Factura pasa a estado Pagada

-- 4.2 PRUEBA DE MODIFICACIÓN DE PAGO  -- Se prueban todos los campos modificados en una sola prueba

EXEC Finanzas.modificarPago
	@cod_factura = 1,
	@fecha_pago = '2025-06-15',
	@responsable = 'SN-10000',
	@medio_pago = 'TRANSFERENCIA';
GO
select * from Finanzas.Pago

-- 4.3 PRUEBA DE BORRADO DE PAGO

EXEC Finanzas.borrarPago
	@cod_factura = 1;
GO
SELECT * FROM Finanzas.Factura -- Factura pasa a estado Pendiente