Use Com5600G11
GO


----- 6. REEMBOLSO

DELETE FROM Finanzas.Reembolso
DELETE FROM Finanzas.Pago
DELETE FROM Finanzas.Factura
DBCC CHECKIDENT ('Finanzas.Factura', RESEED, 0);
DBCC CHECKIDENT ('Finanzas.Reembolso', RESEED, 0);
DBCC CHECKIDENT ('Finanzas.Pago', RESEED, 0);
DELETE FROM Persona.Socio 

EXEC Persona.insertarSocio
    @cod_socio = 'SN-00001',
    @dni = '12345672',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nac = '2001-05-15',
    @email = 'juan.perez@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL ;

EXEC Finanzas.emitirFactura @cod_socio = 'SN-00001' 
EXEC Finanzas.insertarPago
	@cod_factura = 1,
	@fecha_pago = '2025-06-10',
	@responsable = 'SN-00001',
	@medio_pago = 'TARJETA';
SELECT * FROM Finanzas.Factura
SELECT * FROM Finanzas.Pago

-- 6.1 INSERCION

EXEC Finanzas.insertarReembolso
    @cod_factura = 1,
    @fecha = '2025-06-10',
    @motivo = 'Consulta médica'; 
SELECT * FROM Finanzas.Reembolso
SELECT * FROM Finanzas.Factura -- Factura pasa a estado Anulada
-- 6.2 MODIFICACION

EXEC Finanzas.modificarReembolso
    @cod_factura = 1,
    @fecha = '2025-06-11',
    @motivo = 'Estudios clínicos';
SELECT * FROM Finanzas.Reembolso
-- 6.3 BORRADO

-- 6.3.1 Borrado Exitoso

EXEC Finanzas.borrarReembolso @cod_factura = 1;
SELECT * FROM Finanzas.Factura -- Factura pasa a estado Pagada

-- 6.3.2 Borrado Fallido

EXEC Finanzas.borrarReembolso @cod_factura = 99;
