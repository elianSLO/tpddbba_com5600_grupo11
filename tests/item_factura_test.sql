-- PRUEBAS SPs Item_Factura

-- Primero inserto Socio y Factura para pruebas

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

-- Inserto Factura para ese socio
EXEC stp.emitirFactura @cod_socio = 'SN-00001' 

SELECT * FROM psn.Factura

-- PRUEBAS PARA stp.insertarItem_factura

--CASO 11.1.1 Prueba insertarItem_factura: caso válido 
EXEC stp.insertarItem_factura @cod_Factura = 1;

SELECT * FROM psn.Item_Factura

--CASO 11.1.2 Código de Factura inválido
EXEC stp.insertarItem_factura @cod_Factura = 0;

--CASO 11.1.3 Código de Factura NULO
EXEC stp.insertarItem_factura @cod_Factura = NULL;


-- PRUEBAS PARA stp.modificarItem_factura

-- Suponiendo que el IDENTITY de cod_item se incrementa y existe un item con ID 1
DECLARE @ultimo_item INT;
SELECT TOP 1 @ultimo_item = cod_item FROM psn.Item_Factura ORDER BY cod_item DESC;

IF @ultimo_item IS NOT NULL
BEGIN
    PRINT '--- Prueba modificarItem_factura: caso válido ---';
    EXEC stp.modificarItem_factura @cod_item = @ultimo_item, @cod_Factura = 2;

    PRINT '--- Prueba modificarItem_factura: cod_item inexistente ---';
    EXEC stp.modificarItem_factura @cod_item = -1, @cod_Factura = 2;

    PRINT '--- Prueba modificarItem_factura: cod_Factura inválido (0) ---';
    EXEC stp.modificarItem_factura @cod_item = @ultimo_item, @cod_Factura = 0;

    PRINT '--- Prueba modificarItem_factura: cod_Factura nulo ---';
    EXEC stp.modificarItem_factura @cod_item = @ultimo_item, @cod_Factura = NULL;
END
ELSE
BEGIN
    PRINT 'No hay ítems de factura para probar modificar.';
END

-- PRUEBAS PARA stp.borrarItem_factura

-- Insertamos un ítem temporal para probar el borrado

EXEC stp.insertarItem_factura @cod_Factura = 3;

-- Obtener el último item insertado
DECLARE @item_temp INT;
SELECT TOP 1 @item_temp = cod_item FROM psn.Item_Factura ORDER BY cod_item DESC;

PRINT '--- Prueba borrarItem_factura: caso válido ---';
EXEC stp.borrarItem_factura @cod_item = @item_temp;

PRINT '--- Prueba borrarItem_factura: cod_item inexistente ---';
EXEC stp.borrarItem_factura @cod_item = -999;
