Use Com5600G11
GO

-- 10. FACTURA

-- PRUEBA  emitirFactura

-- Inserto Socio
-- Limpio la tabla primero (si es seguro)
DELETE FROM psn.Socio 

EXEC stp.insertarSocio
    @cod_socio = 'SN-00001',
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nac = '1990-05-15',
    @email = 'juan.perez@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = 'NS-00001';

-- Pruebo emitirFactura

EXEC stp.emitirFactura @cod_socio = 'SN-00001' 


-- Pruebo modificarFactura

-- Estado inválido
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'PENDIENTE';

-- Factura no existente
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 9999, @nuevo_estado = 'PAGADA';

-- Marcar como VENCIDA (con recargo si está vencida)
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'VENCIDA';

-- Marcar como ANULADA
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'ANULADA';

-- Marcar como PAGADA
EXEC stp.modificarFactura @cod_socio = 'SN-00001', @cod_Factura = 1, @nuevo_estado = 'PAGADA';






