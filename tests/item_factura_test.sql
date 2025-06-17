----------- PRUEBAS SP Item_Factura

-- Selecciono la base de datos 

USE Com5600G11
GO

-- Limpio las tablas a utilizar

-- Tabla Socio
DELETE psn.Socio 

-- Tabla Factura
DELETE psn.Factura
DBCC CHECKIDENT ('psn.Factura', RESEED, 0);

-- Tabla Item_Fctura
DELETE psn.Item_Factura

------------------------------------------------------------ PRUEBA DE STORED PROCEDURE insertarItem_Factura

INSERT INTO psn.Socio (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura, estado, saldo, cod_responsable)
VALUES ('SN-00001', 'Juan', 'P�rez', '12345678', 'juan@example.com', '1990-05-10', '123456789', '987654321', 'OSDE', 'AF123', '1122334455', 1, 0.00, NULL);

INSERT INTO psn.Factura (monto, fecha_emision, fecha_vto, fecha_seg_vto, recargo, estado, cod_socio)
VALUES (2000.00, '2025-06-01', '2025-06-10', '2025-06-20', 0.1, 'Pendiente', 'SN-00001');

SELECT cod_Factura FROM psn.Factura WHERE cod_socio = 'SN-00001';


-- CASO 1.1: Inserci�n correcta.

EXEC stp.insertarItem_factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 25000.00,
    @descripcion = 'Cuota Categor�a Mayor';

-- Verificacion: 

SELECT * FROM psn.Item_Factura

-- CASO 1.2: Inserci�n del mismo item (debe dar error)

EXEC stp.insertarItem_factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 25000.00,
    @descripcion = 'Cuota Categor�a Mayor';

-- CASO 1.3: C�digo de factura inexistente.

EXEC stp.insertarItem_factura 
    @cod_item = 1,
    @cod_Factura = 2,
    @monto = 25000.00,
    @descripcion = 'Cuota Categor�a Mayor';

-- CASO 1.4: Monto negativo

EXEC stp.insertarItem_factura 
    @cod_item = 2,
    @cod_Factura = 1,
    @monto = -10000,
    @descripcion = 'Cuota Categor�a Mayor';

-- CASO 1.5: Cateogr�a Vac�a 

EXEC stp.insertarItem_factura 
    @cod_item = 2,
    @cod_Factura = 1,
    @monto = 10000,
    @descripcion = '';

-- CASO 1.6: Categor�a NULL

EXEC stp.insertarItem_factura 
    @cod_item = 2,
    @cod_Factura = 1,
    @monto = 10000,
    @descripcion = NULL;

---- 2. modificarItem_Factura

EXEC stp.modificarItem_Factura 
    @cod_item = 1,
    @cod_Factura = 1,
    @monto = 15000.00, -- Cambio Precio
    @descripcion = 'Cuota Categor�a Cadete'; -- Cambio Categoria

---- 3. borrarItem_Factura

-- Borro el item 1

EXEC stp.borrarItem_factura @cod_item = 1, @cod_factura = 1

-- Verifico que el item no existe.

EXEC stp.borrarItem_factura @cod_item = 1, @cod_factura = 1 

