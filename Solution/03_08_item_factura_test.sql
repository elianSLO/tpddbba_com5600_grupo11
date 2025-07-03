----------- PRUEBAS SP Item_Factura

-- Selecciono la base de datos 

USE Com5600G11
GO

-- Borrado de tablas

DELETE FROM Persona.Socio 
DELETE FROM Finanzas.Factura
DELETE FROM Finanzas.Item_Factura


------------------------------------------------------------ 1. PRUEBAS insertarItem_Factura

INSERT INTO Persona.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES ('SN-00001', 'Juan', 'Pérez', '12345678', 'juan@example.com', '1990-05-10', '123456789', '987654321', 'OSDE', 'AF123', '1122334455', 1, 0.00, NULL);

INSERT INTO Finanzas.Factura (monto, fecha_emision, fecha_vto, fecha_seg_vto, recargo, estado, cod_socio)
VALUES (2000.00, '2025-06-01', '2025-06-10', '2025-06-20', 0.1, 'Pendiente', 'SN-00001');

SELECT cod_Factura FROM Finanzas.Factura WHERE cod_socio = 'SN-00001';


-- CASO 1.1: Inserción correcta.

EXEC Finanzas.insertarItem_factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 25000.00,
    @descripcion = 'Cuota Categoría Mayor';

-- Verificacion: 

SELECT * FROM Finanzas.Item_Factura

-- CASO 1.2: Inserción del mismo item (debe dar error)

EXEC Finanzas.insertarItem_factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 25000.00,
    @descripcion = 'Cuota Categoría Mayor';

-- CASO 1.3: Código de factura inexistente.

EXEC Finanzas.insertarItem_factura 
    @cod_item = 1,
    @cod_Factura = 2,
    @monto = 25000.00,
    @descripcion = 'Cuota Categoría Mayor';

-- CASO 1.4: Monto negativo

EXEC Finanzas.insertarItem_factura 
    @cod_item = 2,
    @cod_Factura = 1,
    @monto = -10000,
    @descripcion = 'Cuota Categoría Mayor';

-- CASO 1.5: Cateogría Vacía 

EXEC Finanzas.insertarItem_factura 
    @cod_item = 2,
    @cod_Factura = 1,
    @monto = 10000,
    @descripcion = '';

-- CASO 1.6: Categoría NULL

EXEC Finanzas.insertarItem_factura 
    @cod_item = 2,
    @cod_Factura = 1,
    @monto = 10000,
    @descripcion = NULL;

----------------------------------------------------------- 2. PRUEBAS modificarItem_Factura

-- CASO 2.1 - Modificacion correcta

EXEC Finanzas.modificarItem_Factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 15000.00, -- Cambio Precio
    @descripcion = 'Cuota Categoría Cadete'; -- Cambio Categoria

-- CASO 2.2 - Modificación factura inexistente

EXEC Finanzas.modificarItem_Factura 
    @cod_item = 1,
    @cod_Factura = 2,
    @monto = 15000.00,
    @descripcion = 'Cuota Categoría Cadete'; -- Cambio Categoria

-- CASO 2.3 - Modificación con Monto negativo

EXEC Finanzas.modificarItem_Factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = -15000.00, 
    @descripcion = 'Cuota Categoría Cadete'; 

-- CASO 2.4 - Modificación con Categoría vacía

EXEC Finanzas.modificarItem_Factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 15000.00, 
    @descripcion = '';

-- CASO 2.5 - Modificación con Cateogría nula

EXEC Finanzas.modificarItem_Factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 15000.00, 
    @descripcion = NULL;

-------------------------------------------------------------- 3. PRUEBAS borrarItem_Factura

-- Borro el item 1

EXEC Finanzas.borrarItem_factura @cod_item = 1, @cod_factura = 1

-- Verifico que el item no existe.

EXEC Finanzas.borrarItem_factura @cod_item = 1, @cod_factura = 1 

