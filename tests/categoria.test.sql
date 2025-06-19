Use Com5600G11
GO

-- 7. CATEGORIA

-- Limpiar la tabla para pruebas (solo si es seguro)

DELETE FROM psn.Categoria
DBCC CHECKIDENT ('psn.Categoria', RESEED, 0);


-- 7.1.1 INSERCION VALIDA

EXEC stp.insertarCategoria 
    @descripcion = 'Mayor',
	@edad_max = 99,
    @valor_mensual = 25000.00, 
    @vig_valor_mens = '2025-12-31', 
    @valor_anual = 300000.00, 
    @vig_valor_anual = '2025-12-31';

-- Verificación de inserción

SELECT * FROM psn.Categoria WHERE descripcion = 'Mayor';

-- 7.1.2 Valor incorrecto en Descripcion (debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Adulto', -- debe ser 'Cadete','Mayor' o 'Menor'
	@edad_max = 40,
    @valor_mensual = 1500.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 16000.00,
    @vig_valor_anual = '2025-07-01';

-- 7.1.3 Valor de la suscripción negativo (debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Menor',
	@edad_max = 15,
    @valor_mensual = -100.00,  -- Negativo
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 16000.00,
    @vig_valor_anual = '2025-07-01';

-- 7.1.4 Valor anual nulo (debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Cadete',
	@edad_max = 20,
    @valor_mensual = 1200.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = NULL,  -- Nulo
    @vig_valor_anual = '2025-07-01';

-- 7.1.5 Fecha pasada (debe dar error) 

EXEC stp.insertarCategoria 
    @descripcion = 'Cadete',
	@edad_max = 40,
    @valor_mensual = 1200.00,
    @vig_valor_mens = '2023-01-01',  -- Fecha en el pasado
    @valor_anual = 15000.00,
    @vig_valor_anual = '2025-07-01';

-- 7.1.6 Fecha pasada anual (Debe dar error)

EXEC stp.insertarCategoria 
    @descripcion = 'Menor',
	@edad_max = 12,
    @valor_mensual = 1300.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 14000.00,
    @vig_valor_anual = '2023-01-01';  -- Fecha en el pasado

-- 7.1.7 Edad incorrecta

EXEC stp.insertarCategoria 
    @descripcion = 'Cadete',
	@edad_max = -19,
    @valor_mensual = 1500.00,
    @vig_valor_mens = '2025-07-01',
    @valor_anual = 16000.00,
    @vig_valor_anual = '2025-07-01';


-- 7.2 MODIFICACION 

-- 7.2.1 MODIFICACIÓN VÁLIDA

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Cadete',
    @edad_max = 35,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '12-31-2025',
    @valor_anual = 12000.00,
    @vig_valor_anual = '12-31-2025';

--  7.2.2 Categoría no existente

EXEC stp.modificarCategoria 
    @cod_categoria = 999,
    @descripcion = 'Mayor',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '10-02-2025';

--  7.2.3 Descripción inválida

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Senior', -- inválido
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--  7.2.4 Edad máxima <= 0

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Mayor',
    @edad_max = 0,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--  7.2.5 Valor mensual <= 0

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Menor',
    @edad_max = 40,
    @valor_mensual = 0, -- inválido
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--  7.2.6 Valor anual nulo

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Menor',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = NULL, -- inválido
    @vig_valor_anual = '2025-06-01';

-- 7.2.7 Fecha de vigencia mensual pasada

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Cadete',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2020-01-01', -- pasada
    @valor_anual = 12000.00,
    @vig_valor_anual = '2025-06-01';

--- 7.2.8 Fecha de vigencia anual pasada

EXEC stp.modificarCategoria 
    @cod_categoria = 1,
    @descripcion = 'Mayor',
    @edad_max = 40,
    @valor_mensual = 1100.00,
    @vig_valor_mens = '2026-06-01',
    @valor_anual = 12000.00,
    @vig_valor_anual = '2020-01-01'; -- pasada


----------- 7.3 BORADO DE CATEGORIA

-- 7.3.1 Borrado Exitoso

EXEC stp.borrarCategoria @cod_categoria = 1;

-- 7.3.2 Borrado Fallido

EXEC stp.borrarCategoria @cod_categoria = 999;