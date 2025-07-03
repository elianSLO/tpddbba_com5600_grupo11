Use Com5600G11
GO



-- 10. FACTURA

-- 10.1 PRUEBA  emitirFactura

-- Limpio la tabla Factura para pruebas (si es seguro)

DELETE FROM Finanzas.Factura
DBCC CHECKIDENT ('Finanzas.Factura', RESEED, 0);

-- Inserto Socio para pruebas
-- Limpio la tabla primero (si es seguro)
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

-- Verifico que se insertó correctamente.
SELECT * FROM Persona.Socio

-- CASO 10.1.1 Pruebo emitirFactura con socio existente
EXEC Finanzas.emitirFactura @cod_socio = 'SN-00001' 

-- Verifico que se insertó correctamente.
SELECT * from Finanzas.Factura

-- CASO 10.1.2 Pruebo emitirFactura con socio inexistente

EXEC Finanzas.emitirFactura @cod_socio = 'SN-00002' 



-- CASO 10.2  PRUEBA modificarFactura

-- 10.2.1 Estado inválido
EXEC Finanzas.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'PENDIENTE';

-- 10.2.2 Factura no existente
EXEC Finanzas.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 9999, @nuevo_estado = 'PAGADA';

-- 10.2.3 Marcar como PAGADA
EXEC Finanzas.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'PAGADA';

-- Verifico que se actualizó:
SELECT * FROM Finanzas.Factura

-- 10.2.4 Marcar como VENCIDA (Si está vencida luego la segunda fecha aplica recargo)
EXEC Finanzas.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'VENCIDA';

-- Verifico que se actualizó:
SELECT * from Finanzas.Factura

-- 10.2.5 Marcar como ANULADA
EXEC Finanzas.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'ANULADA';

-- Verifico que se actualizó (ver que el monto pasa a ser 0.00):
SELECT * from Finanzas.Factura




-- CASO 10.3 PRUEBA borrarFactura

-- 10.3.1 Borro factura existente

EXEC Finanzas.borrarFactura @cod_Factura = 1

-- 10.3.2 Borro la misma factura devuelta y verifico que ya no existe

EXEC Finanzas.borrarFactura @cod_Factura = 1

-- 10.3.3 Borro factura inexistente 

EXEC Finanzas.borrarFactura @cod_Factura = 999






