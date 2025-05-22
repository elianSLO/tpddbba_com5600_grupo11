USE Com5600G11
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stp')
	BEGIN
		EXEC('CREATE SCHEMA stp');
		PRINT 'Esquema creado exitosamente';
	END;
go

-- STORED PROCEDURES PARA CATEGORIA ----------------------------------------------------------------
-- INSERCION

IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarCategoria')
BEGIN
    DROP PROCEDURE stp.insertarCategoria;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarCategoria
	@cod_categoria		INT,
	@descripcion		VARCHAR(50),
	@valor_mensual		DECIMAL(10,2),
	@vig_valor_mens		DATE,
	@valor_anual		DECIMAL(10,2),
	@vig_valor_anual	DATE	
AS
BEGIN
	--	Validar que no exista la categoria
	IF EXISTS (SELECT 1 FROM psn.Categoria WHERE @cod_categoria = cod_categoria)
		BEGIN
			PRINT 'La categoria ya existe en la tabla.'
            RETURN;
        END;
	--	Validar que descripcion no exista
	IF EXISTS (SELECT 1 FROM psn.Categoria WHERE @descripcion = descripcion)
		BEGIN
			PRINT 'La categoria ya existe en la tabla.'
            RETURN;
        END;
		--	Validar que los montos no sean nulos o negativos
		IF (@valor_mensual <= 0 or @valor_mensual IS NULL or @valor_anual <= 0 or @valor_anual IS NULL)
		BEGIN
			PRINT 'El valor de la suscripcion debe ser mayor a cero'
			RETURN;
		END;
		IF (@vig_valor_mens < GETDATE() or @vig_valor_anual < GETDATE())
			BEGIN
				PRINT 'Fecha de vigencia invalida'
            RETURN;
			END;
		
		INSERT INTO psn.Categoria(cod_categoria,descripcion,valor_mensual,vig_valor_mens,valor_anual,vig_valor_anual)
        VALUES (@cod_categoria,@descripcion,@valor_mensual,@vig_valor_mens,@valor_anual,@vig_valor_anual);
		PRINT 'Categoria insertada correctamente'
END

CREATE OR ALTER PROCEDURE stp.modificarCategoria
	@cod_categoria		INT,
	@descripcion		VARCHAR(50),
	@valor_mensual		DECIMAL(10,2),
	@vig_valor_mens		DATE,
	@valor_anual		DECIMAL(10,2),
	@vig_valor_anual	DATE	
AS
BEGIN
	--	Validar que exista la categoria
	IF NOT EXISTS (SELECT 1 FROM psn.Categoria WHERE @cod_categoria = cod_categoria)
		BEGIN
			PRINT 'La categoria no existe en la tabla.'
            RETURN;
        END;
	--	Validar que descripcion no exista
	IF EXISTS (SELECT 1 FROM psn.Categoria WHERE @descripcion = descripcion)
		BEGIN
			PRINT 'La categoria ya existe en la tabla.'
            RETURN;
        END;
		--	Validar que los montos no sean nulos o negativos
		IF (@valor_mensual <= 0 or @valor_mensual IS NULL or @valor_anual <= 0 or @valor_anual IS NULL)
		BEGIN
			PRINT 'El valor de la suscripcion debe ser mayor a cero'
			RETURN;
		END;
		IF (@vig_valor_mens < GETDATE() or @vig_valor_anual < GETDATE())
			BEGIN
				PRINT 'Fecha de vigencia invalida'
            RETURN;
			END;
		
		UPDATE psn.Categoria
		SET
			descripcion = ISNULL(@descripcion,descripcion),
			valor_mensual = ISNULL(@valor_mensual,valor_mensual),
			vig_valor_mens = ISNULL(@vig_valor_mens, vig_valor_mens),
			valor_anual = ISNULL(@valor_anual, valor_anual),
			vig_valor_anual = ISNULL(@vig_valor_anual, vig_valor_anual)
		where cod_categoria = @cod_categoria;
		PRINT 'Categoria actualizada correctamente'
END


