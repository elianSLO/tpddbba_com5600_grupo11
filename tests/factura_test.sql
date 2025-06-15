Use Com5600G11
GO



-- 10. FACTURA

-- 10.1 PRUEBA  emitirFactura

-- Limpio la tabla Factura para pruebas (si es seguro)

DELETE FROM psn.Factura
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);

-- Inserto Socio para pruebas
-- Limpio la tabla primero (si es seguro)
DELETE FROM psn.Socio 

EXEC stp.insertarSocio
    @cod_socio = 'SN-00001',
    @dni = '12345672',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nac = '2015-05-15',
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
SELECT * FROM psn.Socio

-- CASO 1. Pruebo emitirFactura
EXEC stp.emitirFactura @cod_socio = 'SN-00001' 

-- Verifico que se insertó correctamente.
SELECT * from psn.Factura



-- CASO 10.2  PRUEBA modificarFactura

-- Estado inválido
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'PENDIENTE';

-- Factura no existente
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 9999, @nuevo_estado = 'PAGADA';

-- Marcar como PAGADA
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'PAGADA';

-- Verifico que se actualizó:
SELECT * FROM psn.Factura

-- Marcar como VENCIDA (Si está vencida luego la segunda fecha)
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'VENCIDA';

-- Verifico que se actualizó:
SELECT * from psn.Factura

-- Marcar como ANULADA
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'ANULADA';

-- Verifico que se actualizó (ver que el monto pasa a ser 0.00):
SELECT * from psn.Factura




-- CASO 10.3 PRUEBA borrarFactura

-- Borro factura existente

EXEC stp.borrarFactura @cod_Factura = 1

-- Borro la misma factura devuelta y verifico que ya no existe

EXEC stp.borrarFactura @cod_Factura = 1

-- Ahora intento borrar factura inexistente 

EXEC stp.borrarFactura @cod_Factura = 999






