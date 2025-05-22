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


---------- STORED PROCEDURES PARA TABLA SOCIO

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

---------------
-- STORED PROCEDURES PARA TABLA PROFESOR

-- SP PARA INSERTAR PROFESOR

IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarProfesor')
BEGIN
    DROP PROCEDURE stp.insertarProfesor;
END;
GO
CREATE OR ALTER PROCEDURE stp.insertarProfesor
	@cod_prof			INT,
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@email				VARCHAR(100),
	@tel				VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;
    -- Validación de que ningún campo sea NULL
    IF @cod_prof IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @email IS NULL OR @tel IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    -- Validación de que el profesor no se haya insertado
    IF EXISTS (SELECT 1 FROM psn.Profesor WHERE cod_prof = @cod_prof)
    BEGIN
        PRINT 'Socio ya existente';
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

--------------------------- 
-- STORED PROCEDURES PARA TABLA INVITADO

-- SP PARA INSERTAR INVITADO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarInvitado')
BEGIN
    DROP PROCEDURE stp.insertarInvitado;
END;
GO
CREATE OR ALTER PROCEDURE stp.insertarInvitado
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

    IF EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        PRINT 'Invitado ya existente';
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