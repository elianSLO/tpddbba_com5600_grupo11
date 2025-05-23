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
GO

---------------------------------------------------------------------------------------------------------------
-- MODIFICAR

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
----------------------------------------------------------------------------------------------------------------
--	STORED PROCEDURES PARA TABLA ACTIVIDAD

CREATE OR ALTER PROCEDURE stp.insertarActividad
	@descripcion		VARCHAR(50),
	@valor_mensual		DECIMAL(10,2),
	@vig_valor			DATE
AS
BEGIN
	--	Validar que no exista la misma descripción para otra actividad.
	IF (EXISTS (SELECT 1 FROM psn.Actividad WHERE @descripcion = descripcion)
		BEGIN
			PRINT 'Ya existe esa actividad.'
			RETURN;
		END
	--	Validar que el valor mensual sea coherente
	IF @valor_mensual <= 0
		BEGIN
			PRINT 'Error en el valor mensual.'
			RETURN
		END
	IF @vig_valor < GETDATE()
		BEGIN
			PRINT 'Fecha de vigencia invalida.'

	INSERT INTO psn.Actividad (descripcion,valor_mensual,vig_valor)
		VALUES(@descripcion,@valor_mensual,@vig_valor)
	PRINT 'Actividad agregada correctamente.'
END
GO

CREATE OR ALTER PROCEDURE stp.modificarActividad
	@descripcion		VARCHAR(50),
	@valor_mensual		DECIMAL(10,2),
	@vig_valor			DATE
AS
BEGIN
	-- Validar que exista la descripción de la actividad
	IF NOT EXISTS (SELECT 1 FROM psn.Actividad WHERE descripcion = @descripcion)
	BEGIN
		PRINT 'No existe esa actividad.'
		RETURN;
	END

	-- Validar que el valor mensual sea coherente
	IF @valor_mensual <= 0
	BEGIN
		PRINT 'Error en el valor mensual.'
		RETURN;
	END

	-- Validar que la fecha no esté en el pasado
	IF @vig_valor < GETDATE()
	BEGIN
		PRINT 'Fecha de vigencia inválida.'
		RETURN;
	END

	-- Actualizar la actividad
	UPDATE psn.Actividad
	SET
		valor_mensual = @valor_mensual,
		vig_valor = @vig_valor
	WHERE descripcion = @descripcion;

	PRINT 'Actividad modificada correctamente.';
END
GO

CREATE OR ALTER PROCEDURE stp.eliminarActividad
	@descripcion VARCHAR(50)
AS
BEGIN
	-- Validar que exista la descripción de la actividad
	IF NOT EXISTS (SELECT 1 FROM psn.Actividad WHERE descripcion = @descripcion)
	BEGIN
		PRINT 'No existe esa actividad.'
		RETURN;
	END
	DELETE FROM psn.Actividad
	WHERE descripcion = @descripcion;

	PRINT 'Actividad elimnada correctamente.';
END
GO


----------------------------------------------------------------------------------------------------------------

--	STORED PROCEDURES PARA TABLA SOCIO
-- SP PARA INSERTAR SOCIO

IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarSocio')
BEGIN
    DROP PROCEDURE stp.insertarSocio;
END;
GO
CREATE OR ALTER PROCEDURE stp.insertarSocio 
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@fecha_nac			DATE,
	@email				VARCHAR(100),
	@tel				VARCHAR(15),
	@tel_emerg			VARCHAR(15),
	@estado				BIT,
	@saldo				DECIMAL(10,2),
	@nombre_cobertura	VARCHAR(50),
	@nro_afiliado		VARCHAR(50),
	@tel_cobertura		VARCHAR(15),
	@cod_responsable	INT
AS
BEGIN
	SET NOCOUNT ON;
    -- Validación de que ningún campo sea NULL
    IF @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
	   @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
	   OR @tel_cobertura IS NULL OR @cod_responsable IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    -- Validación de que el DNI tenga 8 dígitos
    IF LEN(@dni) < 8 or LEN(@dni) > 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 dígitos';
        RETURN;
	END;

	-- Validación de que el DNI no esté insertado
	IF EXISTS (SELECT 1 FROM psn.Socio WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un socio con ese DNI';
        RETURN;
    END;

	-- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

    -- Validación de que la fecha de nacimiento no sea futura
    IF @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser futura';
        RETURN;
    END;

	-- Validación de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

	-- Validacion de saldo
	IF @saldo < 0
	BEGIN
		PRINT 'Saldo inválido. No puede ser negativo.';
		RETURN;
	END

	-- Validación del telefono
	IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

	-- Validacion del telefono de emergencia
	IF (LEN(@tel_emerg) < 8 OR LEN(@tel_emerg) > 14 OR @tel_emerg LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono de emergencia inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

	-- Validacion del telefono de cobertura

	IF (LEN(@tel_cobertura) < 8 OR LEN(@tel_cobertura) > 14 OR @tel_cobertura LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono de cobertura inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

    -- Insertar el socio
	INSERT INTO psn.Socio (
	dni, nombre, apellido, fecha_nac, email,
	tel, tel_emerg, estado, saldo,
	nombre_cobertura, nro_afiliado, tel_cobertura,
	cod_responsable
	)
	VALUES (
	@dni, @nombre, @apellido, @fecha_nac, @email,
	@tel, @tel_emerg, @estado, @saldo,
	@nombre_cobertura, @nro_afiliado, @tel_cobertura,
	@cod_responsable
	);
    
    PRINT 'Socio insertado correctamente';
END;
GO

-- SP PARA MODIFICAR SOCIO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarSocio')
BEGIN
    DROP PROCEDURE stp.modificarSocio;
END;
GO
CREATE OR ALTER PROCEDURE stp.modificarSocio
	@cod_socio			INT,
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@fecha_nac			DATE,
	@email				VARCHAR(100),
	@tel				VARCHAR(15),
	@tel_emerg			VARCHAR(15),
	@estado				BIT,
	@saldo				DECIMAL(10,2),
	@nombre_cobertura	VARCHAR(50),
	@nro_afiliado		VARCHAR(50),
	@tel_cobertura		VARCHAR(15),
	@cod_responsable	INT
AS
BEGIN
	SET NOCOUNT ON;
    -- Validación de que ningún campo sea NULL
    IF @cod_socio IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
	   @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
	   OR @tel_cobertura IS NULL OR @cod_responsable IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    -- Validación de que el socio se haya insertado
    IF NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: Socio no encontrado.';
        RETURN;
    END;

    -- Validación de que el DNI tenga 8 dígitos
    IF LEN(@dni) < 8 or LEN(@dni) > 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 dígitos';
        RETURN;
	END;

		-- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

    -- Validación de que la fecha de nacimiento no sea futura
    IF @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser futura';
        RETURN;
    END;

	-- Validación de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

	-- Validacion de saldo
	IF @saldo < 0
	BEGIN
		PRINT 'Saldo inválido. No puede ser negativo.';
		RETURN;
	END

	-- Validación del telefono
	IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

	-- Validacion del telefono de emergencia
	IF (LEN(@tel_emerg) < 8 OR LEN(@tel_emerg) > 14 OR @tel_emerg LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono de emergencia inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

	-- Validacion del telefono de cobertura

	IF (LEN(@tel_cobertura) < 8 OR LEN(@tel_cobertura) > 14 OR @tel_cobertura LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono de cobertura inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

		UPDATE Socio
	SET
		dni = @dni,
		nombre = @nombre,
		apellido = @apellido,
		fecha_nac = @fecha_nac,
		email = @email,
		tel = @tel,
		tel_emerg = @tel_emerg,
		estado = @estado,
		saldo = @saldo,
		nombre_cobertura = @nombre_cobertura,
		nro_afiliado = @nro_afiliado,
		tel_cobertura = @tel_cobertura,
		cod_responsable = @cod_responsable
	WHERE cod_socio = @cod_socio;
    
    PRINT 'Socio modificado correctamente';
END;
GO

-- SP PARA BORRAR SOCIO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarSocio')
BEGIN
    DROP PROCEDURE stp.borrarSocio;
END;
GO
CREATE OR ALTER PROCEDURE stp.borrarSocio
        @cod_socio INT
    AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
        BEGIN
            DELETE FROM psn.Socio WHERE cod_socio = @cod_socio;
            PRINT 'Socio borrado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El socio con el código especificado no existe.';
        END
    END
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA PROFESOR

-- SP PARA INSERTAR PROFESOR

IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarProfesor')
BEGIN
    DROP PROCEDURE stp.insertarProfesor;
END;
GO
CREATE OR ALTER PROCEDURE stp.insertarProfesor
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@email				VARCHAR(100),
	@tel				VARCHAR(15)
AS
BEGIN
	
    -- Validación de que ningún campo sea NULL
    IF @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @email IS NULL OR @tel IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    -- Validación de que el DNI tenga 8 dígitos
    IF LEN(@dni) < 8 or LEN(@dni) > 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 dígitos';
        RETURN;
	END;

	-- Validación de que el DNI no esté insertado
	IF EXISTS (SELECT 1 FROM psn.Profesor WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un profesor con ese DNI';
        RETURN;
    END;

		-- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

	-- Validación del telefono
	IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Teléfono inválido. Debe contener entre 8 y 14 dígitos numéricos.';
    RETURN;
	END

    -- Insertar el profesor
	INSERT INTO psn.Profesor(
	dni, nombre, apellido, email, tel)
	VALUES (@dni, @nombre, @apellido, @email, @tel);
    
    PRINT 'Profesor insertado correctamente';

END;
GO

--SP PARA MODIFICAR PROFESOR

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarProfesor')
BEGIN
    DROP PROCEDURE stp.modificarProfesor;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarProfesor
    @cod_prof   INT,
    @dni        CHAR(8),
    @nombre     VARCHAR(50),
    @apellido   VARCHAR(50),
    @email      VARCHAR(100),
    @tel        VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de que ningún campo sea NULL
    IF @cod_prof IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR @email IS NULL OR @tel IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    -- Validación de existencia del profesor
    IF NOT EXISTS (SELECT 1 FROM psn.Profesor WHERE cod_prof = @cod_prof)
    BEGIN
        PRINT 'Error: Profesor no encontrado';
        RETURN;
    END;

    -- Validación de DNI
    IF LEN(@dni) <> 8
    BEGIN
        PRINT 'Error: El DNI debe tener exactamente 8 dígitos';
        RETURN;
    END;

	-- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

    -- Validación de email
    IF @email NOT LIKE '_%@_%._%'
    BEGIN
        PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com';
        RETURN;
    END;

    -- Validación de teléfono
    IF (LEN(@tel) < 10 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono inválido. Debe contener entre 10 y 14 dígitos numéricos';
        RETURN;
    END;

    -- Actualizar profesor
    UPDATE psn.Profesor
    SET
        dni = @dni,
        nombre = @nombre,
        apellido = @apellido,
        email = @email,
        tel = @tel
    WHERE cod_prof = @cod_prof;

    PRINT 'Profesor modificado correctamente';
END;
GO

-- SP PARA BORRAR PROFESOR

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarProfesor')
BEGIN
    DROP PROCEDURE stp.borrarProfesor;
END;
GO
CREATE OR ALTER PROCEDURE stp.borrarProfesor
        @cod_prof INT
    AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT 1 FROM psn.Profesor WHERE cod_prof = @cod_prof)
        BEGIN
            DELETE FROM psn.Profesor WHERE cod_prof = @cod_prof;
            PRINT 'Profesor borrado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El profesor con el código especificado no existe.';
        END
    END
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA INVITADO

-- SP PARA INSERTAR INVITADO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarInvitado')
BEGIN
    DROP PROCEDURE stp.insertarInvitado;
END;
GO
CREATE OR ALTER PROCEDURE stp.insertarInvitado
    @dni                CHAR(8),
    @nombre             VARCHAR(50),
    @apellido           VARCHAR(50),
    @fecha_nac          DATE,
    @email              VARCHAR(100),
    @tel                VARCHAR(15),
    @tel_emerg          VARCHAR(15),
    @estado             BIT,
    @saldo              DECIMAL(10,2),
    @nombre_cobertura   VARCHAR(50),
    @nro_afiliado       VARCHAR(50),
    @tel_cobertura      VARCHAR(15),
    @cod_responsable    INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
       @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
       OR @tel_cobertura IS NULL OR @cod_responsable IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    IF LEN(@dni) <> 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 dígitos';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM psn.Invitado WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un invitado con ese DNI';
        RETURN;
    END;

	-- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

    IF @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser futura';
        RETURN;
    END;

    IF @email NOT LIKE '_%@_%._%'
    BEGIN
        PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com.';
        RETURN;
    END;

    IF @saldo < 0
    BEGIN
        PRINT 'Saldo inválido. No puede ser negativo.';
        RETURN;
    END;

    IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono inválido.';
        RETURN;
    END;

    IF (LEN(@tel_emerg) < 8 OR LEN(@tel_emerg) > 14 OR @tel_emerg LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono de emergencia inválido.';
        RETURN;
    END;

    IF (LEN(@tel_cobertura) < 8 OR LEN(@tel_cobertura) > 14 OR @tel_cobertura LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono de cobertura inválido.';
        RETURN;
    END;

    INSERT INTO psn.Invitado (
        dni, nombre, apellido, fecha_nac, email,
        tel, tel_emerg, estado, saldo,
        nombre_cobertura, nro_afiliado, tel_cobertura,
        cod_responsable
    )
    VALUES (
        @dni, @nombre, @apellido, @fecha_nac, @email,
        @tel, @tel_emerg, @estado, @saldo,
        @nombre_cobertura, @nro_afiliado, @tel_cobertura,
        @cod_responsable
    );

    PRINT 'Invitado insertado correctamente';
END;
GO


-- SP PARA MODIFICAR INVITADO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarInvitado')
BEGIN
    DROP PROCEDURE stp.modificarInvitado;
END;
GO
CREATE OR ALTER PROCEDURE stp.modificarInvitado
    @cod_invitado       INT,
    @dni                CHAR(8),
    @nombre             VARCHAR(50),
    @apellido           VARCHAR(50),
    @fecha_nac          DATE,
    @email              VARCHAR(100),
    @tel                VARCHAR(15),
    @tel_emerg          VARCHAR(15),
    @estado             BIT,
    @saldo              DECIMAL(10,2),
    @nombre_cobertura   VARCHAR(50),
    @nro_afiliado       VARCHAR(50),
    @tel_cobertura      VARCHAR(15),
    @cod_responsable    INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_invitado IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
       @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
       OR @tel_cobertura IS NULL OR @cod_responsable IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        PRINT 'Error: Invitado no encontrado.';
        RETURN;
    END;

    IF LEN(@dni) <> 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 dígitos';
        RETURN;
    END;

	-- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

    IF @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser futura';
        RETURN;
    END;

    IF @email NOT LIKE '_%@_%._%'
    BEGIN
        PRINT 'Error: Email inválido.';
        RETURN;
    END;

    IF @saldo < 0
    BEGIN
        PRINT 'Saldo inválido. No puede ser negativo.';
        RETURN;
    END;

    IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono inválido.';
        RETURN;
    END;

    IF (LEN(@tel_emerg) < 8 OR LEN(@tel_emerg) > 14 OR @tel_emerg LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono de emergencia inválido.';
        RETURN;
    END;

    IF (LEN(@tel_cobertura) < 8 OR LEN(@tel_cobertura) > 14 OR @tel_cobertura LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Teléfono de cobertura inválido.';
        RETURN;
    END;

    UPDATE psn.Invitado
    SET
        dni = @dni,
        nombre = @nombre,
        apellido = @apellido,
        fecha_nac = @fecha_nac,
        email = @email,
        tel = @tel,
        tel_emerg = @tel_emerg,
        estado = @estado,
        saldo = @saldo,
        nombre_cobertura = @nombre_cobertura,
        nro_afiliado = @nro_afiliado,
        tel_cobertura = @tel_cobertura,
        cod_responsable = @cod_responsable
    WHERE cod_invitado = @cod_invitado;

    PRINT 'Invitado modificado correctamente';
END;
GO


-- SP PARA BORRAR INVITADO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarInvitado')
BEGIN
    DROP PROCEDURE stp.borrarInvitado;
END;
GO
CREATE OR ALTER PROCEDURE stp.borrarInvitado
    @cod_invitado INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        DELETE FROM psn.Invitado WHERE cod_invitado = @cod_invitado;
        PRINT 'Invitado borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El invitado con el código especificado no existe.';
    END
END;
GO

------------------------------------------- SP PARA TABLA PAGO

----------- STORED PROCEDURE PARA INSERCION DE PAGO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarPago')
BEGIN
    DROP PROCEDURE stp.insertarPago;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarPago
	@monto			DECIMAL(10,2),
	@fecha_pago		DATE,
	@estado			VARCHAR(15),
	@cod_socio		INT = NULL,
	@cod_invitado	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Validación: monto > 0
	IF @monto <= 0
	BEGIN
		PRINT 'ERROR: El monto debe ser mayor a cero.';
		RETURN;
	END

	-- Validación: fecha de pago no puede ser futura
	IF @fecha_pago > GETDATE()
	BEGIN
		PRINT 'ERROR: La fecha de pago no puede ser futura.';
		RETURN;
	END

	-- Validación: estado permitido
	IF @estado NOT IN ('Pendiente', 'Pagado', 'Anulado')
	BEGIN
		PRINT 'Error: El estado debe ser: Pendiente, Pagado o Anulado.';
		RETURN;
	END

	-- Validación: al menos uno de los códigos debe estar presente
	IF @cod_socio IS NULL AND @cod_invitado IS NULL
	BEGIN
		PRINT 'Error: Debe especificar un código de socio o de invitado.';
		RETURN;
	END

	-- Validación: no ambos códigos a la vez 
	IF @cod_socio IS NOT NULL AND @cod_invitado IS NOT NULL
	BEGIN
		PRINT 'ERROR: Solo se debe especificar cod_socio o cod_invitado, no ambos.';
		RETURN;
	END

	-- Inserción
	INSERT INTO psn.Pago (monto, fecha_pago, estado, cod_socio, cod_invitado)
	VALUES (@monto, @fecha_pago, @estado, @cod_socio, @cod_invitado);

	PRINT 'Pago insertado correctamente.';
END;
GO

----------- STORED PROCEDURE PARA MODIFICACION DE PAGO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarPago')
BEGIN
    DROP PROCEDURE stp.modificarPago;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarPago
	@cod_pago		INT,
	@monto			DECIMAL(10,2),
	@fecha_pago		DATE,
	@estado			VARCHAR(15),
	@cod_socio		INT = NULL,
	@cod_invitado	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Validación: existencia del pago
	IF NOT EXISTS (SELECT 1 FROM psn.Pago WHERE cod_pago = @cod_pago)
	BEGIN
		PRINT 'ERROR: No existe un pago con ese código.';
		RETURN;
	END

	-- Validación: monto > 0
	IF @monto <= 0
	BEGIN
		PRINT 'ERROR: El monto debe ser mayor a cero.';
		RETURN;
	END

	-- Validación: fecha de pago no puede ser futura
	IF @fecha_pago > GETDATE()
	BEGIN
		PRINT 'ERROR: La fecha de pago no puede ser futura.';
		RETURN;
	END

	-- Validación: estado permitido
	IF @estado NOT IN ('Pendiente', 'Pagado', 'Anulado')
	BEGIN
		PRINT 'ERROR: El estado debe ser: Pendiente, Pagado o Anulado.';
		RETURN;
	END

	-- Validación: al menos uno de los códigos debe estar presente
	IF @cod_socio IS NULL AND @cod_invitado IS NULL
	BEGIN
		PRINT 'ERROR: Debe especificar un código de socio o de invitado.';
		RETURN;
	END

	-- Validación: no ambos códigos a la vez
	IF @cod_socio IS NOT NULL AND @cod_invitado IS NOT NULL
	BEGIN
		PRINT 'ERROR: Solo se debe especificar cod_socio o cod_invitado, no ambos.';
		RETURN;
	END

	-- Actualización
	UPDATE Com5600G11.psn.Pago
	SET
		monto = @monto,
		fecha_pago = @fecha_pago,
		estado = @estado,
		cod_socio = @cod_socio,
		cod_invitado = @cod_invitado
	WHERE cod_pago = @cod_pago;

	PRINT 'Pago modificado correctamente.';
END;
GO


----------- STORED PROCEDURE PARA BORRAR PAGO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarPago')
BEGIN
    DROP PROCEDURE stp.borrarPago;
END;
GO

CREATE PROCEDURE stp.borrarPago
	@cod_pago INT
AS
BEGIN
	SET NOCOUNT ON;

	-- Validación: existencia del pago
	IF NOT EXISTS (SELECT 1 FROM psn.Pago WHERE cod_pago = @cod_pago)
	BEGIN
		PRINT 'ERROR: No existe un pago con ese código.';
		RETURN;
	END

	-- Eliminación
	DELETE FROM psn.Pago
	WHERE cod_pago = @cod_pago;

	PRINT 'Pago eliminado correctamente.';
END;
GO


----------------------------------------------------------------------


--------- SPs SUSCRIBIR 

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'suscribirSocio')
BEGIN
    DROP PROCEDURE stp.suscribirSocio;
END;
GO
CREATE OR ALTER PROCEDURE stp.suscribirSocio
	@cod_socio INT,
	@tipoSuscripcion CHAR(1), --Si es anual A, si es mensual M
	@cod_categoria INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
	BEGIN
		PRINT 'No existe socio'
		RETURN
	END

	IF (UPPER(@tipoSuscripcion) NOT IN ('A','M'))
	BEGIN
		PRINT 'Tipo de suscripcion erronea'
		RETURN
	END
	DECLARE @edadLimite INT, @edadSocio INT, @fnac DATE
	SET @edadLimite = (SELECT edad_max from psn.Categoria WHERE cod_categoria = @cod_categoria)
	SET @fnac = ( SELECT fecha_nac from psn.Socio WHERE cod_socio = @cod_socio)
	SET @edadSocio = (SELECT DATEDIFF(YEAR,@fnac,GETDATE()))

	IF (@edadSocio > @edadLimite)
	BEGIN
		PRINT 'Categoria incorrecta'
		RETURN
	END
	DECLARE @fecha_inscripcion DATE, @fecha_venc DATE;
	SET @fecha_inscripcion = GETDATE()
	
	IF(UPPER(@tipoSuscripcion) = 'A')
		SET	@fecha_venc = DATEADD(MONTH, 12, @fecha_inscripcion)
	ELSE
		SET	@fecha_venc = DATEADD(MONTH, 1, @fecha_inscripcion)

	INSERT INTO psn.Suscripcion (cod_socio,cod_categoria,fecha_suscripcion,fecha_vto)
	VALUES(@cod_socio,@cod_categoria,@fecha_inscripcion,@fecha_venc)
END




-----------------------------------------------------------------------------------------
--	SP PARA FACTURAS

IF NOT EXISTS (SELECT * FROM sys.procedures WHERE (object_id = OBJECT_ID('emitirFactura') AND type = N'U')
BEGIN
    DROP PROCEDURE stp.modificarInvitado;
END;
GO
CREATE OR ALTER PROCEDURE stp.emitirFactura
	@cod_socio		INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
	BEGIN
		PRINT 'No existe el socio'
		RETURN
	END
	DECLARE @categoria	INT,
			@monto		DECIMAL(10,2)
	SET @categoria = (SELECT cod_categoria from psn.Suscripcion WHERE @cod_socio = cod_socio)
	--SET @monto = (SELECT valor_mensual)
	
END
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
----- SP PARA REEMBOLSO

--- INSERCION REEMBOLSO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarReembolso')
BEGIN
    DROP PROCEDURE stp.insertarReembolso;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarReembolso
    @monto       DECIMAL(10,2),
    @medio_Pago  VARCHAR(50),
    @fecha       DATE,
    @motivo      VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: monto debe ser mayor a 0
    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto debe ser mayor a cero.';
        RETURN;
    END

    -- Validación: medio_Pago no debe ser NULL ni vacío
    IF @medio_Pago IS NULL OR LTRIM(RTRIM(@medio_Pago)) = ''
    BEGIN
        PRINT 'Error: El medio de pago no puede estar vacío.';
        RETURN;
    END

    -- Validación: fecha no puede ser futura
    IF @fecha > GETDATE()
    BEGIN
        PRINT 'Error: La fecha no puede ser futura.';
        RETURN;
    END

    -- Validación: motivo no debe ser NULL ni vacío
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = ''
    BEGIN
        PRINT 'Error: El motivo no puede estar vacío.';
        RETURN;
    END

    -- Inserción de datos
    INSERT INTO psn.Reembolso (monto, medio_Pago, fecha, motivo)
    VALUES (@monto, @medio_Pago, @fecha, @motivo);

    PRINT 'Reembolso insertado correctamente.';
END;
GO

--- MODIFICACION REEMBOLSO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarReembolso')
BEGIN
    DROP PROCEDURE stp.modificarReembolso;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarReembolso
    @codReembolso INT,
    @monto        DECIMAL(10,2),
    @medio_Pago   VARCHAR(50),
    @fecha        DATE,
    @motivo       VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: código debe existir
    IF NOT EXISTS (SELECT 1 FROM psn.Reembolso WHERE codReembolso = @codReembolso)
    BEGIN
        PRINT 'Error: No existe un reembolso con el código especificado.';
        RETURN;
    END

    -- Validación: monto debe ser mayor a 0
    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto debe ser mayor a cero.';
        RETURN;
    END

    -- Validación: medio_Pago no debe ser NULL ni vacío
    IF @medio_Pago IS NULL OR LTRIM(RTRIM(@medio_Pago)) = ''
    BEGIN
        PRINT 'Error: El medio de pago no puede estar vacío.';
        RETURN;
    END

    -- Validación: fecha no puede ser futura
    IF @fecha > GETDATE()
    BEGIN
        PRINT 'Error: La fecha no puede ser futura.';
        RETURN;
    END

    -- Validación: motivo no debe ser NULL ni vacío
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = ''
    BEGIN
        PRINT 'Error: El motivo no puede estar vacío.';
        RETURN;
    END

    -- Actualización de datos
    UPDATE psn.Reembolso
    SET
        monto = @monto,
        medio_Pago = @medio_Pago,
        fecha = @fecha,
        motivo = @motivo
    WHERE codReembolso = @codReembolso;

    PRINT 'Reembolso modificado correctamente.';
END;
GO

--- BORRADO REEMBOLSO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarReembolso')
BEGIN
    DROP PROCEDURE stp.borrarReembolso;
END;
GO

CREATE OR ALTER PROCEDURE stp.borrarReembolso
    @codReembolso INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: verificar que exista el código
    IF NOT EXISTS (SELECT 1 FROM psn.Reembolso WHERE codReembolso = @codReembolso)
    BEGIN
        PRINT 'Error: No existe un reembolso con el código especificado.';
        RETURN;
    END

    -- Eliminación del registro
    DELETE FROM psn.Reembolso
    WHERE codReembolso = @codReembolso;

    PRINT 'Reembolso eliminado correctamente.';
END;
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--- STORED PROCEDURES PARA TABLA RESPONSABLE


---- INSERCION RESPONSABLE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarResponsable')
BEGIN
    DROP PROCEDURE stp.insertarResponsable;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarResponsable
    @dni         CHAR(8),
    @nombre      VARCHAR(50),
    @apellido    VARCHAR(50),
    @email       VARCHAR(100),
    @parentezco  VARCHAR(50),
    @fecha_nac   DATE,
    @nro_socio   INT,
    @tel         VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @dni IS NULL OR LEN(@dni) != 8 OR @dni NOT LIKE '%[0-9]%'
    BEGIN
        PRINT 'Error: El DNI debe contener exactamente 8 dígitos numéricos.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM psn.Responsable WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un responsable con ese DNI.';
        RETURN;
    END

  -- Validación de que el nombre sólo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de que el apellido sólo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

    IF @parentezco IS NULL OR LTRIM(RTRIM(@parentezco)) = ''
    BEGIN
        PRINT 'Error: El parentezco no puede estar vacío.';
        RETURN;
    END

    IF @fecha_nac IS NULL OR @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser nula ni futura.';
        RETURN;
    END

    IF @nro_socio IS NULL OR @nro_socio <= 0
    BEGIN
        PRINT 'Error: El número de socio debe ser un número positivo.';
        RETURN;
    END

    IF @tel IS NULL OR @tel LIKE '%[^0-9]%' OR LEN(@tel) < 10 OR LEN(@tel) > 14
    BEGIN
        PRINT 'Error: El teléfono debe contener solo números y tener entre 10 y 14 dígitos.';
        RETURN;
    END

    -- Inserción
    INSERT INTO psn.Responsable (dni, nombre, apellido, email, parentezco, fecha_nac, nro_socio, tel)
    VALUES (@dni, @nombre, @apellido, @email, @parentezco, @fecha_nac, @nro_socio, @tel);

    PRINT 'Responsable insertado correctamente.';
END;
GO

---- MODIFICACION RESPONSABLE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarResponsable')
BEGIN
    DROP PROCEDURE stp.modificarResponsable;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarResponsable
    @cod_responsable INT,
    @dni             CHAR(8),
    @nombre          VARCHAR(50),
    @apellido        VARCHAR(50),
    @email           VARCHAR(100),
    @parentezco      VARCHAR(50),
    @fecha_nac       DATE,
    @nro_socio       INT,
    @tel             VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM psn.Responsable WHERE cod_responsable = @cod_responsable)
    BEGIN
        PRINT 'Error: No existe un responsable con ese código.';
        RETURN;
    END

    -- Validaciones (igual que en el insert)
    IF @dni IS NULL OR LEN(@dni) != 8 OR @dni NOT LIKE '%[0-9]%'
    BEGIN
        PRINT 'Error: El DNI debe contener exactamente 8 dígitos numéricos.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM psn.Responsable 
        WHERE dni = @dni AND cod_responsable != @cod_responsable
    )
    BEGIN
        PRINT 'Error: Otro responsable ya tiene ese DNI.';
        RETURN;
    END

	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validación de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inválido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

    IF @parentezco IS NULL OR LTRIM(RTRIM(@parentezco)) = ''
    BEGIN
        PRINT 'Error: El parentezco no puede estar vacío.';
        RETURN;
    END

    IF @fecha_nac IS NULL OR @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser nula ni futura.';
        RETURN;
    END

    IF @nro_socio IS NULL OR @nro_socio <= 0
    BEGIN
        PRINT 'Error: El número de socio debe ser un número positivo.';
        RETURN;
    END

    IF @tel IS NULL OR @tel LIKE '%[^0-9]%' OR LEN(@tel) < 10 OR LEN(@tel) > 14
    BEGIN
        PRINT 'Error: El teléfono debe contener solo números y tener entre 10 y 14 dígitos.';
        RETURN;
    END

    -- Actualización
    UPDATE psn.Responsable
    SET dni = @dni,
        nombre = @nombre,
        apellido = @apellido,
        email = @email,
        parentezco = @parentezco,
        fecha_nac = @fecha_nac,
        nro_socio = @nro_socio,
        tel = @tel
    WHERE cod_responsable = @cod_responsable;

    PRINT 'Responsable modificado correctamente.';
END;
GO

---- BORRADO RESPONSABLE
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarResponsable')
BEGIN
    DROP PROCEDURE stp.borrarResponsable;
END;
GO

CREATE OR ALTER PROCEDURE stp.borrarResponsable
    @cod_responsable INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM psn.Responsable WHERE cod_responsable = @cod_responsable)
    BEGIN
        PRINT 'Error: No existe un responsable con ese código.';
        RETURN;
    END

    -- Eliminación
    DELETE FROM psn.Responsable
    WHERE cod_responsable = @cod_responsable;

    PRINT 'Responsable eliminado correctamente.';
END;
GO

---------------
-- STORED PROCEDURES PARA TABLA RESERVA

-- SP PARA INSERTAR RESERVA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarReserva')
BEGIN
    DROP PROCEDURE stp.insertarReserva;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarReserva
    @cod_socio          INT = NULL,
    @cod_invitado       INT = NULL,
    @monto              DECIMAL(10,2),
    @fechahoraInicio    DATETIME,
    @fechahoraFin       DATETIME,
    @piletaSUMColonia   VARCHAR(50)   
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_socio IS NULL AND @cod_invitado IS NULL
    BEGIN
        PRINT 'Error: Debe especificar un codigo de socio o de invitado para la reserva.';
        RETURN;
    END;

    IF @cod_socio IS NOT NULL AND @cod_invitado IS NOT NULL
    BEGIN
        PRINT 'Error: Solo se debe especificar cod_socio o cod_invitado, no ambos.';
        RETURN;
    END;

    IF @cod_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: El codigo de socio especificado no existe.';
        RETURN;
    END;

    IF @cod_invitado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        PRINT 'Error: El codigo de invitado especificado no existe.';
        RETURN;
    END;

    IF @monto IS NULL OR @fechahoraInicio IS NULL OR @fechahoraFin IS NULL OR @piletaSUMColonia IS NULL
    BEGIN
        PRINT 'Error: Campos criticos (monto, fecha/hora, recurso) no pueden ser NULL.';
        RETURN;
    END;

    IF @fechahoraInicio < GETDATE()
    BEGIN
        PRINT 'Error: La fecha y hora de inicio de la reserva no puede ser en el pasado.';
        RETURN;
    END;

    IF @fechahoraInicio >= @fechahoraFin
    BEGIN
        PRINT 'Error: La fecha y hora de inicio debe ser anterior a la fecha y hora de fin.';
        RETURN;
    END;

    IF DATEDIFF(minute, @fechahoraInicio, @fechahoraFin) < 60
    BEGIN
        PRINT 'Error: La duracion de la reserva debe ser al menos de 60 minutos.';
        RETURN;
    END;

    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto de la reserva debe ser mayor a cero.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM psn.Reserva
               WHERE piletaSUMColonia = @piletaSUMColonia
                 AND (
                        (@fechahoraInicio < fechahoraFin AND @fechahoraFin > fechahoraInicio) -- Solapamiento
                     )
              )
    BEGIN
       PRINT 'Error: El recurso "' + @piletaSUMColonia + '" ya esta reservado en el horario solicitado.';
       RETURN;
    END;

    INSERT INTO psn.Reserva (
        cod_socio,
        cod_invitado,
        monto,
        fechahoraInicio,
        fechahoraFin,
        piletaSUMColonia
    )
    VALUES (
        @cod_socio,
        @cod_invitado,
        @monto,
        @fechahoraInicio,
        @fechahoraFin,
        @piletaSUMColonia
    );

    PRINT 'Reserva insertada correctamente.';
END;
GO

-- SP PARA MODIFICAR RESERVA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarReserva')
BEGIN
    DROP PROCEDURE stp.modificarReserva;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarReserva
    @cod_reserva        INT,
    @cod_socio          INT = NULL,
    @cod_invitado       INT = NULL,
    @monto              DECIMAL(10,2),
    @fechahoraInicio    DATETIME,
    @fechahoraFin       DATETIME,
    @piletaSUMColonia   VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM psn.Reserva WHERE cod_reserva = @cod_reserva)
    BEGIN
        PRINT 'Error: El codigo de reserva especificado no existe.';
        RETURN;
    END;

    IF @cod_socio IS NULL AND @cod_invitado IS NULL
    BEGIN
        PRINT 'Error: Debe especificar un codigo de socio o de invitado para la reserva.';
        RETURN;
    END;

    IF @cod_socio IS NOT NULL AND @cod_invitado IS NOT NULL
    BEGIN
        PRINT 'Error: Solo se debe especificar cod_socio o cod_invitado, no ambos.';
        RETURN;
    END;

    IF @cod_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: El codigo de socio especificado no existe.';
        RETURN;
    END;

    IF @cod_invitado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        PRINT 'Error: El codigo de invitado especificado no existe.';
        RETURN;
    END;

    IF @monto IS NULL OR @fechahoraInicio IS NULL OR @fechahoraFin IS NULL OR @piletaSUMColonia IS NULL
    BEGIN
        PRINT 'Error: Campos criticos (monto, fecha/hora, recurso) no pueden ser NULL.';
        RETURN;
    END;
    
    IF @fechahoraInicio < GETDATE()
    BEGIN
        PRINT 'Error: La fecha y hora de inicio de la reserva no puede ser en el pasado.';
        RETURN;
    END;

    IF @fechahoraInicio >= @fechahoraFin
    BEGIN
        PRINT 'Error: La fecha y hora de inicio debe ser anterior a la fecha y hora de fin.';
        RETURN;
    END;

    IF DATEDIFF(minute, @fechahoraInicio, @fechahoraFin) < 60
    BEGIN
        PRINT 'Error: La duracion de la reserva debe ser al menos de 60 minutos.';
        RETURN;
    END;

    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto de la reserva debe ser mayor a cero.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM psn.Reserva
               WHERE cod_reserva <> @cod_reserva -- Excluir la reserva que se esta modificando
                 AND piletaSUMColonia = @piletaSUMColonia
                 AND (
                        (@fechahoraInicio < fechahoraFin AND @fechahoraFin > fechahoraInicio) -- Solapamiento
                     )
              )
    BEGIN
       PRINT 'Error: El recurso "' + @piletaSUMColonia + '" ya esta reservado en el horario solicitado por otra reserva.';
       RETURN;
    END;

    UPDATE psn.Reserva
    SET
        cod_socio = @cod_socio,
        cod_invitado = @cod_invitado,
        monto = @monto,
        fechahoraInicio = @fechahoraInicio,
        fechahoraFin = @fechahoraFin,
        piletaSUMColonia = @piletaSUMColonia
    WHERE cod_reserva = @cod_reserva;

    PRINT 'Reserva modificada correctamente.';
END;
GO

-- SP PARA BORRAR RESERVA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarReserva')
BEGIN
    DROP PROCEDURE stp.borrarReserva;
END;
GO

CREATE OR ALTER PROCEDURE stp.borrarReserva
    @cod_reserva INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM psn.Reserva WHERE cod_reserva = @cod_reserva)
    BEGIN
        PRINT 'Error: El codigo de reserva especificado no existe.';
        RETURN;
    END;

    DELETE FROM psn.Reserva
    WHERE cod_reserva = @cod_reserva;

    PRINT 'Reserva borrada correctamente.';
END;
GO

---------------
-- STORED PROCEDURES PARA TABLA CLASE

-- SP PARA INSERTAR CLASE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarClase')
BEGIN
    DROP PROCEDURE stp.insertarClase;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarClase
    @categoria     INT,
    @cod_actividad INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @categoria IS NULL OR @cod_actividad IS NULL
    BEGIN
        PRINT 'Error: Los campos categoría y código de actividad no pueden ser NULL.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Categoria WHERE cod_categoria = @categoria)
    BEGIN
        PRINT 'Error: La categoría especificada no existe.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Actividad WHERE cod_actividad = @cod_actividad)
    BEGIN
        PRINT 'Error: La actividad especificada no existe.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM psn.Clase WHERE categoria = @categoria AND cod_actividad = @cod_actividad)
    BEGIN
        PRINT 'Error: Ya existe una clase con esta combinación de categoría y actividad.';
        RETURN;
    END;

    INSERT INTO psn.Clase (categoria, cod_actividad)
    VALUES (@categoria, @cod_actividad);

    PRINT 'Clase insertada correctamente.';
END;
GO

-- SP PARA MODIFICAR CLASE
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarClase')
BEGIN
    DROP PROCEDURE stp.modificarClase;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarClase
    @cod_clase     INT,
    @categoria     INT,
    @cod_actividad   INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_clase IS NULL
    BEGIN
        PRINT 'Error: El código de clase no puede ser NULL.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Clase WHERE cod_clase = @cod_clase)
    BEGIN
        PRINT 'Error: La clase con el código especificado no existe.';
        RETURN;
    END;

    IF @categoria IS NULL OR @cod_actividad IS NULL
    BEGIN
        PRINT 'Error: Los campos categoría y código de actividad no pueden ser NULL para la modificación.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Categoria WHERE cod_categoria = @categoria)
    BEGIN
        PRINT 'Error: La nueva categoría especificada no existe.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Actividad WHERE cod_actividad = @cod_actividad)
    BEGIN
        PRINT 'Error: La nueva actividad especificada no existe.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM psn.Clase WHERE categoria = @categoria AND cod_actividad = @cod_actividad AND cod_clase <> @cod_clase)
    BEGIN
        PRINT 'Error: La modificación resultaría en una clase duplicada con esta combinación de categoría y actividad.';
        RETURN;
    END;

    UPDATE psn.Clase
    SET
        categoria = @categoria,
        cod_actividad = @cod_actividad
    WHERE cod_clase = @cod_clase;

    PRINT 'Clase modificada correctamente.';
END;
GO

-- SP PARA BORRAR CLASE
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarClase')
BEGIN
    DROP PROCEDURE stp.borrarClase;
END;
GO

CREATE OR ALTER PROCEDURE stp.borrarClase
    @cod_clase INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_clase IS NULL
    BEGIN
        PRINT 'Error: El código de clase no puede ser NULL.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Clase WHERE cod_clase = @cod_clase)
    BEGIN
        PRINT 'Error: La clase con el código especificado no existe.';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM psn.HorarioClase WHERE cod_clase = @cod_clase)
    BEGIN
         PRINT 'Error: No se puede eliminar la clase porque tiene horarios asociados.';
         RETURN;
     END;

    DELETE FROM psn.Clase
    WHERE cod_clase = @cod_clase;

    PRINT 'Clase eliminada correctamente.';
END;
GO

--- STORED PROCEDURES PARA ITEM_FACTURA

-- INSERCION ITEM_FACTURA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarItem_factura')
BEGIN
    DROP PROCEDURE stp.insertarItem_factura;
END;
GO

CREATE PROCEDURE stp.insertarItem_factura
    @cod_Factura INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: cod_Factura debe ser mayor a 0
    IF @cod_Factura IS NULL OR @cod_Factura <= 0
    BEGIN
        PRINT 'Error: El código de factura debe ser un número positivo.';
        RETURN;
    END

    -- Inserción
    INSERT INTO psn.Item_Factura (cod_Factura)
    VALUES (@cod_Factura);

    PRINT 'Item de factura insertado correctamente.';
END;
GO


-- MODIFICACION ITEM_FACTURA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarItem_factura')
BEGIN
    DROP PROCEDURE stp.modificarItem_factura;
END;
GO

CREATE PROCEDURE stp.modificarItem_factura
    @cod_item     INT,
    @cod_Factura  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia de cod_item
    IF NOT EXISTS (SELECT 1 FROM psn.Item_Factura WHERE cod_item = @cod_item)
    BEGIN
        PRINT 'Error: No existe un ítem de factura con ese código.';
        RETURN;
    END

    -- Validación: cod_Factura debe ser mayor a 0
    IF @cod_Factura IS NULL OR @cod_Factura <= 0
    BEGIN
        PRINT 'Error: El código de factura debe ser un número positivo.';
        RETURN;
    END

    -- Actualización
    UPDATE psn.Item_Factura
    SET cod_Factura = @cod_Factura
    WHERE cod_item = @cod_item;

    PRINT 'Item de factura modificado correctamente.';
END;
GO

-- BORRADO ITEM_FACTURA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarItem_factura')
BEGIN
    DROP PROCEDURE stp.borrarItem_factura;
END;
GO

CREATE PROCEDURE stp.borrarItem_factura
    @cod_item INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM psn.Item_Factura WHERE cod_item = @cod_item)
    BEGIN
        PRINT 'Error: No existe un ítem de factura con ese código.';
        RETURN;
    END

    -- Eliminación
    DELETE FROM psn.Item_Factura
    WHERE cod_item = @cod_item;

    PRINT 'Item de factura eliminado correctamente.';
END;
GO


----------------------- SPs ASISTE

-- INSERCION ASISTE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarAsiste')
BEGIN
    DROP PROCEDURE stp.insertarAsiste;
END;
GO

CREATE PROCEDURE stp.insertarAsiste
    @fecha      DATE,
    @cod_socio  INT,
    @cod_clase  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @fecha IS NULL OR @fecha > GETDATE()
    BEGIN
        PRINT 'Error: La fecha no puede ser nula ni futura.';
        RETURN;
    END

    IF @cod_socio IS NULL OR @cod_socio <= 0
    BEGIN
        PRINT 'Error: El código de socio debe ser un número positivo.';
        RETURN;
    END

    IF @cod_clase IS NULL OR @cod_clase <= 0
    BEGIN
        PRINT 'Error: El código de clase debe ser un número positivo.';
        RETURN;
    END

    -- Validar si ya existe ese registro
    IF EXISTS (
        SELECT 1 FROM psn.Asiste
        WHERE fecha = @fecha AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: Ya existe un registro con esa combinación de fecha, socio y clase.';
        RETURN;
    END

    -- Inserción
    INSERT INTO psn.Asiste (fecha, cod_socio, cod_clase)
    VALUES (@fecha, @cod_socio, @cod_clase);

    PRINT 'Asistencia registrada correctamente.';
END;
GO

-- MODIFICACION ASISTE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarAsiste')
BEGIN
    DROP PROCEDURE stp.modificarAsiste;
END;
GO

CREATE PROCEDURE stp.modificarAsiste
    @fecha_original     DATE,
    @cod_socio_original INT,
    @cod_clase_original INT,
    @nueva_fecha        DATE,
    @nuevo_cod_socio    INT,
    @nuevo_cod_clase    INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del registro original
    IF NOT EXISTS (
        SELECT 1 FROM psn.Asiste
        WHERE fecha = @fecha_original AND cod_socio = @cod_socio_original AND cod_clase = @cod_clase_original
    )
    BEGIN
        PRINT 'Error: No se encontró el registro original de asistencia.';
        RETURN;
    END

    -- Validaciones para nuevos datos
    IF @nueva_fecha IS NULL OR @nueva_fecha > GETDATE()
    BEGIN
        PRINT 'Error: La nueva fecha no puede ser nula ni futura.';
        RETURN;
    END

    IF @nuevo_cod_socio IS NULL OR @nuevo_cod_socio <= 0
    BEGIN
        PRINT 'Error: El nuevo código de socio debe ser un número positivo.';
        RETURN;
    END

    IF @nuevo_cod_clase IS NULL OR @nuevo_cod_clase <= 0
    BEGIN
        PRINT 'Error: El nuevo código de clase debe ser un número positivo.';
        RETURN;
    END

    -- Validar duplicado en nuevos valores
    IF EXISTS (
        SELECT 1 FROM psn.Asiste
        WHERE fecha = @nueva_fecha AND cod_socio = @nuevo_cod_socio AND cod_clase = @nuevo_cod_clase
          AND NOT (
              fecha = @fecha_original AND
              cod_socio = @cod_socio_original AND
              cod_clase = @cod_clase_original
          )
    )
    BEGIN
        PRINT 'Error: Ya existe otro registro con los nuevos valores.';
        RETURN;
    END

    -- Actualización
    UPDATE psn.Asiste
    SET fecha = @nueva_fecha,
        cod_socio = @nuevo_cod_socio,
        cod_clase = @nuevo_cod_clase
    WHERE fecha = @fecha_original AND cod_socio = @cod_socio_original AND cod_clase = @cod_clase_original;

    PRINT 'Registro de asistencia modificado correctamente.';
END;
GO

-- BORRADO ASISTE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarAsiste')
BEGIN
    DROP PROCEDURE stp.borrarAsiste;
END;
GO

CREATE PROCEDURE stp.borrarAsiste
    @fecha      DATE,
    @cod_socio  INT,
    @cod_clase  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del registro
    IF NOT EXISTS (
        SELECT 1 FROM psn.Asiste
        WHERE fecha = @fecha AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: No se encontró un registro con esos datos.';
        RETURN;
    END

    -- Eliminación
    DELETE FROM psn.Asiste
    WHERE fecha = @fecha AND cod_socio = @cod_socio AND cod_clase = @cod_clase;

    PRINT 'Asistencia eliminada correctamente.';
END;
GO


------------------------------------------ SPs INSCRIPTO

-- INSERCION INSCRIPTO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarInscripto')
    DROP PROCEDURE stp.insertarInscripto;
GO

CREATE PROCEDURE stp.insertarInscripto
    @fecha_inscripcion DATE,
    @estado            VARCHAR(50),
    @cod_socio         INT,
    @cod_clase         INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @fecha_inscripcion IS NULL OR @fecha_inscripcion > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de inscripción no puede ser nula ni futura.';
        RETURN;
    END

    IF @estado IS NULL OR LTRIM(RTRIM(@estado)) = ''
    BEGIN
        PRINT 'Error: El estado no puede estar vacío.';
        RETURN;
    END

    IF @cod_socio IS NULL OR @cod_socio <= 0
    BEGIN
        PRINT 'Error: El código de socio debe ser un número positivo.';
        RETURN;
    END

    IF @cod_clase IS NULL OR @cod_clase <= 0
    BEGIN
        PRINT 'Error: El código de clase debe ser un número positivo.';
        RETURN;
    END

    -- Validar duplicado
    IF EXISTS (
        SELECT 1 FROM psn.Inscripto
        WHERE fecha_inscripcion = @fecha_inscripcion AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: Ya existe una inscripción con esos datos.';
        RETURN;
    END

    -- Inserción
    INSERT INTO psn.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
    VALUES (@fecha_inscripcion, @estado, @cod_socio, @cod_clase);

    PRINT 'Inscripción registrada correctamente.';
END;
GO

-- MODIFICACION INSCRIPTO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarInscripto')
    DROP PROCEDURE stp.modificarInscripto;
GO

CREATE PROCEDURE stp.modificarInscripto
    @fecha_original     DATE,
    @cod_socio_original INT,
    @cod_clase_original INT,
    @nueva_fecha        DATE,
    @nuevo_estado       VARCHAR(50),
    @nuevo_cod_socio    INT,
    @nuevo_cod_clase    INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del registro original
    IF NOT EXISTS (
        SELECT 1 FROM psn.Inscripto
        WHERE fecha_inscripcion = @fecha_original AND cod_socio = @cod_socio_original AND cod_clase = @cod_clase_original
    )
    BEGIN
        PRINT 'Error: No se encontró la inscripción original.';
        RETURN;
    END

    -- Validaciones nuevas
    IF @nueva_fecha IS NULL OR @nueva_fecha > GETDATE()
    BEGIN
        PRINT 'Error: La nueva fecha no puede ser nula ni futura.';
        RETURN;
    END

    IF @nuevo_estado IS NULL OR LTRIM(RTRIM(@nuevo_estado)) = ''
    BEGIN
        PRINT 'Error: El nuevo estado no puede estar vacío.';
        RETURN;
    END

    IF @nuevo_cod_socio IS NULL OR @nuevo_cod_socio <= 0
    BEGIN
        PRINT 'Error: El nuevo código de socio debe ser un número positivo.';
        RETURN;
    END

    IF @nuevo_cod_clase IS NULL OR @nuevo_cod_clase <= 0
    BEGIN
        PRINT 'Error: El nuevo código de clase debe ser un número positivo.';
        RETURN;
    END

    -- Validar duplicado con nuevos datos
    IF EXISTS (
        SELECT 1 FROM psn.Inscripto
        WHERE fecha_inscripcion = @nueva_fecha AND cod_socio = @nuevo_cod_socio AND cod_clase = @nuevo_cod_clase
          AND NOT (
              fecha_inscripcion = @fecha_original AND
              cod_socio = @cod_socio_original AND
              cod_clase = @cod_clase_original
          )
    )
    BEGIN
        PRINT 'Error: Ya existe otra inscripción con los nuevos datos.';
        RETURN;
    END

    -- Actualización
    UPDATE psn.Inscripto
    SET fecha_inscripcion = @nueva_fecha,
        estado = @nuevo_estado,
        cod_socio = @nuevo_cod_socio,
        cod_clase = @nuevo_cod_clase
    WHERE fecha_inscripcion = @fecha_original
      AND cod_socio = @cod_socio_original
      AND cod_clase = @cod_clase_original;

    PRINT 'Inscripción modificada correctamente.';
END;
GO


-- BORRADO INSCRIPTO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarInscripto')
    DROP PROCEDURE stp.borrarInscripto;
GO

CREATE PROCEDURE stp.borrarInscripto
    @fecha_inscripcion DATE,
    @cod_socio         INT,
    @cod_clase         INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (
        SELECT 1 FROM psn.Inscripto
        WHERE fecha_inscripcion = @fecha_inscripcion AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: No se encontró una inscripción con esos datos.';
        RETURN;
    END

    -- Eliminación
    DELETE FROM psn.Inscripto
    WHERE fecha_inscripcion = @fecha_inscripcion
      AND cod_socio = @cod_socio
      AND cod_clase = @cod_clase;

    PRINT 'Inscripción eliminada correctamente.';
END;
GO
