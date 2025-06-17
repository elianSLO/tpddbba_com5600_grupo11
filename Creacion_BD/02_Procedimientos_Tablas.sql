USE Com5600G11
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stp')
	BEGIN
		EXEC('CREATE SCHEMA stp');
		PRINT 'Esquema creado exitosamente';
	END;
go

-- STORED PROCEDURES PARA CATEGORIA ----------------------------------------------------------------
-- INSERCION DE CATEGORIA

IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarCategoria')
BEGIN
    DROP PROCEDURE stp.insertarCategoria;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarCategoria
	@descripcion		VARCHAR(50),
	@edad_max			INT,
	@valor_mensual		DECIMAL(10,2),
	@vig_valor_mens		DATE,
	@valor_anual		DECIMAL(10,2),
	@vig_valor_anual	DATE	
AS
BEGIN
	SET NOCOUNT ON;

	-- Validar que la descripcion sea válida
	IF @descripcion NOT IN ('Cadete', 'Mayor', 'Menor')
	BEGIN
		PRINT 'La descripción debe ser Cadete, Mayor o Menor.'
		RETURN;
	END

	-- Validar que no exista ya una categoria con la misma descripcion
	IF EXISTS (SELECT 1 FROM psn.Categoria WHERE descripcion = @descripcion)
	BEGIN
		PRINT 'Ya existe una categoría con esa descripción.'
		RETURN;
	END

	-- Validar que la edad máxima sea mayor a 0
	IF (@edad_max <= 0)
	BEGIN
		PRINT 'La edad máxima debe ser un número mayor a 0.'
		RETURN;
	END

	-- Validar que los montos no sean nulos o negativos
	IF (@valor_mensual <= 0 OR @valor_mensual IS NULL OR @valor_anual <= 0 OR @valor_anual IS NULL)
	BEGIN
		PRINT 'El valor de la suscripción debe ser mayor a cero'
		RETURN;
	END

	-- Validar que las fechas de vigencia no sean anteriores a hoy
	IF (@vig_valor_mens < CAST(GETDATE() AS DATE) OR @vig_valor_anual < CAST(GETDATE() AS DATE))
	BEGIN
		PRINT 'Fecha de vigencia inválida'
		RETURN;
	END

	INSERT INTO psn.Categoria(descripcion,edad_max,valor_mensual,vig_valor_mens,valor_anual,vig_valor_anual)
	VALUES (@descripcion,@edad_max,@valor_mensual,@vig_valor_mens,@valor_anual,@vig_valor_anual);

	PRINT 'Categoría insertada correctamente'
END
GO

-- SP PARA MODIFICAR CATEGORIA

IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarCategoria')
BEGIN
    DROP PROCEDURE stp.modificarCategoria;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarCategoria
    @cod_categoria      INT,
    @descripcion        VARCHAR(50),
    @edad_max           INT,
    @valor_mensual      DECIMAL(10,2),
    @vig_valor_mens     DATE,
    @valor_anual        DECIMAL(10,2),
    @vig_valor_anual    DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la categoría exista por código
    IF NOT EXISTS (SELECT 1 FROM psn.Categoria WHERE cod_categoria = @cod_categoria)
    BEGIN
        PRINT 'No existe una categoría con ese código para modificar.'
        RETURN;
    END

    -- Validar que la descripción sea válida
    IF @descripcion NOT IN ('Cadete', 'Mayor', 'Menor')
    BEGIN
        PRINT 'La descripción debe ser Cadete, Mayor o Menor.'
        RETURN;
    END

    -- Validar que la nueva descripción no esté en uso por otra categoría diferente
    IF EXISTS (
        SELECT 1 FROM psn.Categoria
        WHERE descripcion = @descripcion AND cod_categoria <> @cod_categoria
    )
    BEGIN
        PRINT 'Otra categoría ya tiene esa descripción.'
        RETURN;
    END

    -- Validar que la edad máxima sea mayor a 0
    IF (@edad_max <= 0)
    BEGIN
        PRINT 'La edad máxima debe ser un número mayor a 0.'
        RETURN;
    END

    -- Validar que los montos no sean nulos o negativos
    IF (@valor_mensual <= 0 OR @valor_mensual IS NULL OR @valor_anual <= 0 OR @valor_anual IS NULL)
    BEGIN
        PRINT 'El valor de la suscripción debe ser mayor a cero.'
        RETURN;
    END

    -- Validar que las fechas de vigencia no sean anteriores a hoy
    IF (@vig_valor_mens < CAST(GETDATE() AS DATE) OR @vig_valor_anual < CAST(GETDATE() AS DATE))
    BEGIN
        PRINT 'Fecha de vigencia inválida.'
        RETURN;
    END

    -- Actualizar la categoría
    UPDATE psn.Categoria
    SET descripcion = @descripcion,
        edad_max = @edad_max,
        valor_mensual = @valor_mensual,
        vig_valor_mens = @vig_valor_mens,
        valor_anual = @valor_anual,
        vig_valor_anual = @vig_valor_anual
    WHERE cod_categoria = @cod_categoria;

    PRINT 'Categoría modificada correctamente.';
END
GO

-- SP PARA BORRAR CATEGORIA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarCategoria')
BEGIN
    DROP PROCEDURE stp.borrarCategoria;
END;
GO
CREATE OR ALTER PROCEDURE stp.borrarCategoria
        @cod_categoria INT
    AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT 1 FROM psn.Categoria WHERE cod_categoria = @cod_categoria)
        BEGIN
            DELETE FROM psn.Categoria WHERE cod_categoria = @cod_categoria;
            PRINT 'Categoria eliminada.';
        END
        ELSE
        BEGIN
            PRINT 'No existe categoria.';
        END
    END
GO

----------------------------------------------------------------------------------------------------------------
--	STORED PROCEDURES PARA TABLA ACTIVIDAD

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarActividad')
BEGIN
    DROP PROCEDURE stp.insertarActividad;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarActividad
    @nombre         VARCHAR(50),
    @valor_mensual  DECIMAL(10,2),
    @vig_valor      DATE
AS
BEGIN
    SET NOCOUNT ON;

    /*-- Validar el nombre de la actividad 
    IF @nombre COLLATE Modern_Spanish_CI_AI NOT IN (
        'Futsal',
        'Vóley',
        'Taekwondo',
        'Baile artístico',
        'Natación',
        'Ajedrez'
    )
    BEGIN
        PRINT 'El nombre de la actividad no es correcto.'
        RETURN;
    END*/	

    -- Validar que no exista ya una actividad con el mismo nombre
    IF EXISTS (SELECT 1 FROM psn.Actividad WHERE nombre = @nombre)
    BEGIN
        PRINT 'La actividad ya existe y no se puede insertar nuevamente.'
        RETURN;
    END

    -- Validar que el valor mensual sea coherente
    IF @valor_mensual <= 0
    BEGIN
        PRINT 'Error en el valor mensual.'
        RETURN
    END

    -- Validar fecha de vigencia
    IF @vig_valor < CAST(GETDATE() AS DATE)
    BEGIN
        PRINT 'Fecha de vigencia invalida.'
        RETURN
    END

    INSERT INTO psn.Actividad (nombre, valor_mensual, vig_valor)
    VALUES (@nombre, @valor_mensual, @vig_valor)

    PRINT 'Actividad agregada correctamente.'
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarActividad')
BEGIN
    DROP PROCEDURE stp.modificarActividad;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarActividad
	@nombre				VARCHAR(50),
	@valor_mensual		DECIMAL(10,2),
	@vig_valor			DATE
AS
BEGIN
	-- Validar que exista la actividad
		 IF @nombre COLLATE Modern_Spanish_CI_AI NOT IN (
        'Futsal',
        'Vóley',
        'Taekwondo',
        'Baile artístico',
        'Natación',
        'Ajedrez'
    )
	 BEGIN
        PRINT 'La actividad no existe.'
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
	WHERE nombre = @nombre;

	PRINT 'Actividad modificada correctamente.';
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'eliminarActividad')
BEGIN
    DROP PROCEDURE stp.eliminarActividad;
END;
GO

CREATE OR ALTER PROCEDURE stp.eliminarActividad
	@nombre VARCHAR(50)
AS
BEGIN
	-- Validar que exista la descripción de la actividad
	IF NOT EXISTS (SELECT 1 FROM psn.Actividad WHERE nombre = @nombre)
	BEGIN
		PRINT 'No existe esa actividad.'
		RETURN;
	END
	DELETE FROM psn.Actividad
	WHERE nombre = @nombre;

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
	@cod_socio			VARCHAR(15),
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@fecha_nac			DATE,
	@email				VARCHAR(100),
	@tel				VARCHAR(50),
	@tel_emerg			VARCHAR(50),
	@estado				BIT,
	@saldo				DECIMAL(10,2),
	@nombre_cobertura	VARCHAR(50),
	@nro_afiliado		VARCHAR(50),
	@tel_cobertura		VARCHAR(50),
	@cod_responsable	VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	/*-- Validación de campos obligatorios
	IF @cod_socio IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
	   @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
	   @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
	   OR @tel_cobertura IS NULL
       -- cod_responsable puede ser null si es mayor
	BEGIN
		PRINT 'Error: Ningún campo puede ser NULL';
		RETURN;
	END;*/

	-- Validaciones
	IF NOT (@cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
            @cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'El código de socio debe tener formato "SN-XXXXX".';
		RETURN;
	END;

	IF @cod_responsable IS NOT NULL AND NOT (
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9]' OR 
	    @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'El código de responsable debe tener formato "SN-XXXXX" o "NS-XXXXX".';
		RETURN;
    END;

	IF LEN(@dni) <> 8
	BEGIN
		PRINT 'Error: El DNI debe ser de 8 dígitos';
		RETURN;
	END;

	IF EXISTS (SELECT 1 FROM psn.Socio WHERE dni = @dni)
	BEGIN
		PRINT 'Error: Ya existe un socio con ese DNI';
		RETURN;
	END;

	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
		PRINT 'Error: El nombre solo puede contener letras y espacios.';
		RETURN;
	END;

	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
		PRINT 'Error: El apellido solo puede contener letras y espacios.';
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

	-- Solo se valida que no tenga letras
	IF @tel LIKE '%[^0-9 ()-/]%' OR @tel_emerg LIKE '%[^0-9 ()-/]%' OR @tel_cobertura LIKE '%[^0-9 ()-/]%'
	BEGIN
		PRINT 'Error: Los teléfonos solo deben contener números.';
		RETURN;
	END;

	-- Insertar socio
	INSERT INTO psn.Socio (
		cod_socio, dni, nombre, apellido, fecha_nac, email,
		tel, tel_emerg, estado, saldo,
		nombre_cobertura, nro_afiliado, tel_cobertura,
		cod_responsable
	)
	VALUES (
		@cod_socio, @dni, @nombre, @apellido, @fecha_nac, @email,
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
	@cod_socio			VARCHAR(15),
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@fecha_nac			DATE,
	@email				VARCHAR(100),
	@tel				VARCHAR(50),
	@tel_emerg			VARCHAR(50),
	@estado				BIT,
	@saldo				DECIMAL(10,2),
	@nombre_cobertura	VARCHAR(50),
	@nro_afiliado		VARCHAR(50),
	@tel_cobertura		VARCHAR(50),
	@cod_responsable	VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	IF @cod_socio IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
	   @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
	   @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
	   OR @tel_cobertura IS NULL
	BEGIN
		PRINT 'Error: Ningún campo puede ser NULL';
		RETURN;
	END;

	IF @cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'
	BEGIN
		PRINT 'El código de socio debe tener formato "SN-XXXXX".';
		RETURN;
	END;

	IF @cod_responsable IS NOT NULL AND NOT (
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9]' OR 
	    @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'El código de responsable debe tener formato "SN-XXXXX" o "NS-XXXXX".';
		RETURN;
    END;

	IF NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
	BEGIN
		PRINT 'Error: Socio no encontrado.';
		RETURN;
	END;

	IF LEN(@dni) <> 8
	BEGIN
		PRINT 'Error: El DNI debe ser de 8 dígitos';
		RETURN;
	END;

	IF @nombre LIKE '%[^a-zA-Z ]%' OR @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
		PRINT 'Error: El nombre y apellido solo pueden contener letras y espacios.';
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

	-- Teléfonos: solo números
	IF @tel LIKE '%[^0-9 ()-/]%' OR @tel_emerg LIKE '%[^0-9 ()-/]%' OR @tel_cobertura LIKE '%[^0-9 ()-/]%'
	BEGIN
		PRINT 'Error: Los teléfonos solo deben contener números.';
		RETURN;
	END;

	-- Update
	UPDATE psn.Socio
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
        @cod_socio VARCHAR(15)
    AS
    BEGIN
        SET NOCOUNT ON;
		-- Validación de que el código del socio sea del tipo "SN-XXXXX"
		IF @cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'
		BEGIN
			PRINT 'El código de socio debe tener formato "SN-XXXX".'
			RETURN;
		END
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
    @cod_invitado       VARCHAR(15),
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
    @cod_responsable    VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_invitado IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @fecha_nac IS NULL OR @email IS NULL OR @tel IS NULL OR @tel_emerg IS NULL OR
       @estado IS NULL OR @saldo IS NULL OR @nombre_cobertura IS NULL OR @nro_afiliado IS NULL 
       OR @tel_cobertura IS NULL
    BEGIN
        PRINT 'Error: Ningún campo puede ser NULL';
        RETURN;
    END;

    IF NOT (@cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para @cod_invitado.';
        RETURN;
    END

	IF @cod_responsable IS NOT NULL AND NOT (
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9]' OR 
	    @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'El código de responsable debe tener formato "SN-XXXXX" o "NS-XXXXX".';
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
        cod_invitado, dni, nombre, apellido, fecha_nac, email,
        tel, tel_emerg, estado, saldo,
        nombre_cobertura, nro_afiliado, tel_cobertura,
        cod_responsable
    )
    VALUES (
        @cod_invitado, @dni, @nombre, @apellido, @fecha_nac, @email,
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
    @cod_invitado       VARCHAR(15),
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

    IF NOT (@cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para @cod_invitado.';
        RETURN;
    END

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
    @cod_invitado VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (@cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para @cod_invitado.';
        RETURN;
    END

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
	@monto				DECIMAL(10,2),
	@fecha_pago			DATE,
	@estado				VARCHAR(15),
	@paga_socio			VARCHAR(15) = NULL,
	@paga_invitado		VARCHAR(15) = NULL,
	@medio_pago			VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	IF @monto <= 0
	BEGIN
		PRINT 'ERROR: El monto debe ser mayor a cero.';
		RETURN;
	END

	IF @fecha_pago > GETDATE()
	BEGIN
		PRINT 'ERROR: La fecha de pago no puede ser futura.';
		RETURN;
	END

	IF @estado NOT IN ('Pendiente', 'Pagado', 'Anulado')
	BEGIN
		PRINT 'ERROR: El estado debe ser: Pendiente, Pagado o Anulado.';
		RETURN;
	END

	IF (@paga_socio IS NULL AND @paga_invitado IS NULL) OR
	   (@paga_socio IS NOT NULL AND @paga_invitado IS NOT NULL)
	BEGIN
		PRINT 'ERROR: Debe especificar solo uno entre paga_socio o paga_invitado.';
		RETURN;
	END

	IF @medio_pago IS NULL OR LEN(@medio_pago) = 0
	BEGIN
		PRINT 'ERROR: El medio de pago debe ser informado.';
		RETURN;
	END

	IF @paga_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @paga_socio)
	BEGIN
		PRINT 'ERROR: El código de socio especificado no existe.';
		RETURN;
	END

	IF @paga_invitado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @paga_invitado)
	BEGIN
		PRINT 'ERROR: El código de invitado especificado no existe.';
		RETURN;
	END

	INSERT INTO psn.Pago (monto, fecha_pago, estado, paga_socio, paga_invitado, medio_pago)
	VALUES (@monto, @fecha_pago, @estado, @paga_socio, @paga_invitado, @medio_pago);

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
	@cod_pago			BIGINT,
	@monto				DECIMAL(10,2),
	@fecha_pago			DATE,
	@estado				VARCHAR(15),
	@paga_socio			VARCHAR(15) = NULL,
	@paga_invitado		VARCHAR(15) = NULL,
	@medio_pago			VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM psn.Pago WHERE cod_pago = @cod_pago)
	BEGIN
		PRINT 'ERROR: No existe un pago con el código especificado.';
		RETURN;
	END

	IF @monto <= 0
	BEGIN
		PRINT 'ERROR: El monto debe ser mayor a cero.';
		RETURN;
	END

	IF @fecha_pago > GETDATE()
	BEGIN
		PRINT 'ERROR: La fecha de pago no puede ser futura.';
		RETURN;
	END

	IF @estado NOT IN ('Pendiente', 'Pagado', 'Anulado')
	BEGIN
		PRINT 'ERROR: El estado debe ser: Pendiente, Pagado o Anulado.';
		RETURN;
	END

	IF (@paga_socio IS NULL AND @paga_invitado IS NULL) OR
	   (@paga_socio IS NOT NULL AND @paga_invitado IS NOT NULL)
	BEGIN
		PRINT 'ERROR: Debe especificar solo uno entre paga_socio o paga_invitado.';
		RETURN;
	END

	IF @medio_pago IS NULL OR LEN(@medio_pago) = 0
	BEGIN
		PRINT 'ERROR: El medio de pago debe ser informado.';
		RETURN;
	END

	IF @paga_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @paga_socio)
	BEGIN
		PRINT 'ERROR: El código de socio especificado no existe.';
		RETURN;
	END

	IF @paga_invitado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM psn.Invitado WHERE cod_invitado = @paga_invitado)
	BEGIN
		PRINT 'ERROR: El código de invitado especificado no existe.';
		RETURN;
	END

	UPDATE psn.Pago
	SET monto = @monto,
		fecha_pago = @fecha_pago,
		estado = @estado,
		paga_socio = @paga_socio,
		paga_invitado = @paga_invitado,
		medio_pago = @medio_pago
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



--------- SPs SUSCRIBIR 

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarSuscripcion')
BEGIN
    DROP PROCEDURE stp.insertarSuscripcion;
END
GO

CREATE OR ALTER PROCEDURE stp.insertarSuscripcion
	@cod_socio VARCHAR(15),
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

	INSERT INTO psn.Suscripcion (cod_socio, cod_categoria, fecha_suscripcion, fecha_vto, tiempoSuscr)
	VALUES(@cod_socio, @cod_categoria, @fecha_inscripcion, @fecha_venc, UPPER(@tipoSuscripcion))

	PRINT 'Socio suscrito exitosamente.'
END

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarSuscripcion')
BEGIN
    DROP PROCEDURE stp.modificarSuscripcion;
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarSuscripcion')
BEGIN
    DROP PROCEDURE stp.modificarSuscripcion;
END
GO

CREATE OR ALTER PROCEDURE stp.modificarSuscripcion
	@cod_socio VARCHAR(15),
	@nueva_cat INT,
	@tiempo CHAR(1)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM psn.Suscripcion WHERE cod_socio = @cod_socio)
		BEGIN
			PRINT 'No existe suscripcion'
			RETURN
		END
	IF NOT EXISTS (SELECT 1 FROM psn.Suscripcion WHERE cod_categoria = @nueva_cat)
		BEGIN
			PRINT 'No existe categoria'
			RETURN
		END
	DECLARE @edadLimite INT, @edadSocio INT, @fnac DATE
	SET @edadLimite = (SELECT edad_max from psn.Categoria WHERE cod_categoria = @nueva_cat)
	SET @fnac = ( SELECT fecha_nac from psn.Socio WHERE cod_socio = @cod_socio)
	SET @edadSocio = (SELECT DATEDIFF(YEAR,@fnac,GETDATE()))

	IF (@edadSocio > @edadLimite)
	BEGIN
		PRINT 'Categoria incorrecta'
		RETURN
	END
	IF EXISTS (
		SELECT 1
		FROM psn.Suscripcion
		WHERE cod_socio = @cod_socio
		  AND cod_categoria = @nueva_cat
		  AND tiempoSuscr = @tiempo
	)
	BEGIN
		PRINT 'La suscripción ya fue modificada anteriormente.'
		RETURN
	END

	UPDATE psn.Suscripcion
	SET 
		cod_categoria = ISNULL(cod_categoria,@nueva_cat),
		tiempoSuscr = ISNULL(tiempoSuscr, @tiempo)
	WHERE cod_socio = @cod_socio

	PRINT 'Modificación exitosa.'
END

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarSuscripcion')
BEGIN
    DROP PROCEDURE stp.borrarSuscripcion;
END;
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarSuscripcion')
BEGIN
    DROP PROCEDURE stp.borrarSuscripcion;
END
GO

CREATE OR ALTER PROCEDURE stp.borrarSuscripcion
    @cod_socio VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validación: verificar que exista el código
    IF NOT EXISTS (SELECT 1 FROM psn.Suscripcion WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: No existe suscripcion.';
        RETURN;
    END

    -- Eliminación del registro
    DELETE FROM psn.Suscripcion
    WHERE cod_socio = @cod_socio

    PRINT 'Suscripcion eliminada';
END;
GO

-----------------------------------------------------------------------------------------
--	SP PARA FACTURAS

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'emitirFactura')
BEGIN
    DROP PROCEDURE stp.emitirFactura;
END;
GO


CREATE OR ALTER PROCEDURE stp.emitirFactura
	@cod_socio		VARCHAR(15)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM psn.Socio WHERE cod_socio = @cod_socio)
	BEGIN
		PRINT 'No existe el socio'
		RETURN
	END
	DECLARE @categoria	INT,
			@monto		DECIMAL(10,2),
			@fecha_emision	DATE,
			@fecha_vto		DATE,
			@fecha_seg_vto	DATE,
			@estado			VARCHAR(10),
			@tipoSuscripc	CHAR(1),
			@recargo		INT
	SET @categoria = (SELECT cod_categoria FROM psn.Suscripcion WHERE @cod_socio = cod_socio)
	SET @tipoSuscripc = (SELECT tiempoSuscr FROM psn.Suscripcion WHERE @cod_socio = cod_socio)
	SET @monto = (SELECT valor_mensual from psn.Categoria WHERE cod_categoria = @categoria)
	SET @fecha_emision = GETDATE();
	SET @fecha_vto = DATEADD(DAY,5,@fecha_emision)
	SET @fecha_seg_vto = DATEADD(DAY,5,@fecha_vto)
	SET @estado = 'Pendiente'
	SET @recargo = 0

	INSERT INTO psn.Factura (monto,fecha_emision,fecha_vto,fecha_seg_vto,recargo,estado,cod_socio)
	VALUES (@monto,@fecha_emision,@fecha_vto,@fecha_seg_vto, @recargo,@estado,@cod_socio)

	PRINT 'Factura emitida exitosamente.'
	
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarFactura')
BEGIN
    DROP PROCEDURE stp.modificarFactura;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarFactura
    @cod_socio     VARCHAR(15),
    @cod_Factura   INT,
    @nuevo_estado  VARCHAR(10) -- 'VENCIDA', 'ANULADA' o 'PAGADA'
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia de la factura con ese socio
    IF NOT EXISTS (SELECT 1 FROM psn.Factura WHERE cod_socio = @cod_socio AND cod_Factura = @cod_Factura)
    BEGIN
        PRINT 'No existe la factura para ese socio';
        RETURN;
    END

    -- Validar que el estado ingresado sea uno de los válidos
    IF @nuevo_estado NOT IN ('VENCIDA', 'ANULADA', 'PAGADA')
    BEGIN
        PRINT 'Estado inválido. Debe ser VENCIDA, ANULADA o PAGADA.';
        RETURN;
    END

    -- Variables para actualizar
    DECLARE @monto         DECIMAL(10,2),
            @fecha_seg_vto DATE;

    -- Obtener valores actuales
    SELECT 
        @monto = monto,
        @fecha_seg_vto = fecha_seg_vto
    FROM psn.Factura
    WHERE cod_Factura = @cod_Factura;

    -- Lógica según estado
    IF @nuevo_estado = 'VENCIDA'
    BEGIN
        IF GETDATE() > @fecha_seg_vto
            SET @monto = @monto * 1.10; -- recargo del 10%
    END
    ELSE IF @nuevo_estado = 'ANULADA'
    BEGIN
        SET @monto = 0;
    END
    -- Si el nuevo estado es ABONADA: se mantiene el monto

    -- Actualización
    UPDATE psn.Factura
    SET 
        estado = @nuevo_estado,
        monto = @monto
    WHERE cod_Factura = @cod_Factura;

    PRINT 'Factura actualizada correctamente';
END
GO


IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarFactura')
BEGIN
    DROP PROCEDURE stp.borrarFactura;
END;
GO

CREATE OR ALTER PROCEDURE stp.borrarFactura
    @cod_Factura INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Validación: verificar que exista el código
    IF NOT EXISTS (SELECT 1 FROM psn.Factura WHERE cod_Factura = @cod_Factura)
    BEGIN
        PRINT 'Error: No existe factura.';
        RETURN;
    END

    -- Eliminación del registro
    DELETE FROM psn.Factura
    WHERE cod_Factura = @cod_Factura;

    PRINT 'Factura eliminada correctamente.';
END;
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
    @cod_responsable VARCHAR(15),
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

    IF NOT (@cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para cod_responsable.';
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
    @cod_responsable VARCHAR(15),
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

    IF NOT (@cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para cod_responsable.';
        RETURN;
    END

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
        cod_responsable = @cod_responsable,
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
    @cod_responsable VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (@cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para cod_responsable.';
        RETURN;
    END

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
    @cod_socio          VARCHAR(15) = NULL,
    @cod_invitado       VARCHAR(15) = NULL,
    @monto              DECIMAL(10,2),
    @fechahoraInicio    DATETIME,
    @fechahoraFin       DATETIME,
    @piletaSUMColonia   VARCHAR(50),
    @return_cod_reserva INT OUTPUT
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

    IF @cod_socio IS NOT NULL AND NOT (
        @cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para @cod_socio.';
        RETURN;
    END

    IF @cod_invitado IS NOT NULL AND NOT (
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para cod_invitado.';
        RETURN;
    END

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

    SET @return_cod_reserva = SCOPE_IDENTITY();
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
    @cod_socio          VARCHAR(15) = NULL,
    @cod_invitado       VARCHAR(15) = NULL,
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

    IF @cod_socio IS NOT NULL AND NOT (
        @cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para @cod_socio.';
        RETURN;
    END

    IF @cod_invitado IS NOT NULL AND NOT (
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para cod_invitado.';
        RETURN;
    END

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


-- SP: insertarClase

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarClase')
BEGIN
    DROP PROCEDURE stp.insertarClase;
END;
GO

CREATE OR ALTER PROCEDURE stp.insertarClase
    @categoria     INT,
    @cod_actividad INT,
    @cod_prof      INT,
    @dia           VARCHAR(9),
    @horario       TIME
AS
BEGIN
    SET NOCOUNT ON;

    IF @categoria IS NULL OR @cod_actividad IS NULL OR @dia IS NULL OR @horario IS NULL OR @cod_prof IS NULL
    BEGIN
        PRINT 'Error: Ningún parámetro puede ser NULL.';
        RETURN;
    END;

    IF @dia NOT IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
    BEGIN
        PRINT 'Error: Día inválido.';
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

    IF NOT EXISTS (SELECT 1 FROM psn.Profesor WHERE @cod_prof = @cod_prof)
    BEGIN
        PRINT 'Error: No se encontró profesor.';
        RETURN;
    END;

    IF EXISTS (
        SELECT 1 FROM psn.Clase
        WHERE categoria = @categoria AND cod_actividad = @cod_actividad
              AND dia = @dia AND horario = @horario
    )
    BEGIN
        PRINT 'Error: Ya existe una clase con esa combinación.';
        RETURN;
    END;

    INSERT INTO psn.Clase (categoria, cod_actividad, dia, horario, cod_prof)
    VALUES (@categoria, @cod_actividad, @dia, @horario, @cod_prof);

    PRINT 'Clase insertada correctamente.';
END;
GO


-- SP: modificarClase

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarClase')
BEGIN
    DROP PROCEDURE stp.modificarClase;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarClase
    @cod_clase     INT,
    @categoria     INT,
    @cod_actividad INT,
    @dia           VARCHAR(9),
    @horario       TIME
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_clase IS NULL OR @categoria IS NULL OR @cod_actividad IS NULL OR @dia IS NULL OR @horario IS NULL
    BEGIN
        PRINT 'Error: Ningún parámetro puede ser NULL.';
        RETURN;
    END;

    IF @dia NOT IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
    BEGIN
        PRINT 'Error: Día inválido.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM psn.Clase WHERE cod_clase = @cod_clase)
    BEGIN
        PRINT 'Error: La clase especificada no existe.';
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

    IF EXISTS (
        SELECT 1 FROM psn.Clase
        WHERE categoria = @categoria AND cod_actividad = @cod_actividad
              AND dia = @dia AND horario = @horario
              AND cod_clase <> @cod_clase
    )
    BEGIN
        PRINT 'Error: Ya existe otra clase con esa combinación.';
        RETURN;
    END;

    UPDATE psn.Clase
    SET
        categoria     = @categoria,
        cod_actividad = @cod_actividad,
        dia           = @dia,
        horario       = @horario
    WHERE cod_clase = @cod_clase;

    PRINT 'Clase modificada correctamente.';
END;
GO


-- SP: borrarClase

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

CREATE OR ALTER PROCEDURE stp.insertarItem_factura
    @cod_item INT,
    @cod_Factura INT,
    @monto DECIMAL(10,2),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM psn.Factura WHERE cod_Factura = @cod_Factura
    )
    BEGIN
        RAISERROR('La factura con código %d no existe.', 16, 1, @cod_Factura);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM psn.Item_Factura WHERE cod_item = @cod_item AND cod_Factura = @cod_Factura
    )
    BEGIN
        RAISERROR('Ya existe un item con el mismo cod_item para esta factura.', 16, 1);
        RETURN;
    END

    INSERT INTO psn.Item_Factura (cod_item, cod_Factura, monto, descripcion)
    VALUES (@cod_item, @cod_Factura, @monto, @descripcion);

    PRINT 'Item insertado correctamente.';
END;
GO

-- MODIFICACION ITEM_FACTURA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarItem_factura')
BEGIN
    DROP PROCEDURE stp.modificarItem_factura;
END;
GO

CREATE OR ALTER PROCEDURE stp.modificarItem_Factura
    @cod_item INT,
    @cod_Factura INT,
    @monto DECIMAL(10,2),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el item exista
    IF NOT EXISTS (
        SELECT 1
        FROM psn.Item_Factura
        WHERE cod_Factura = @cod_Factura
          AND cod_item = @cod_item
    )
    BEGIN
        PRINT 'El item de factura no existe.';
        RETURN;
    END

    -- Actualizar los datos del item
    UPDATE psn.Item_Factura
    SET monto = @monto,
        descripcion = @descripcion
    WHERE cod_Factura = @cod_Factura
      AND cod_item = @cod_item;

    PRINT 'Item de factura modificado correctamente.';
END;
GO


-- BORRADO ITEM_FACTURA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarItem_factura')
BEGIN
    DROP PROCEDURE stp.borrarItem_factura;
END;
GO

CREATE OR ALTER PROCEDURE stp.borrarItem_factura
    @cod_item INT,
    @cod_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que exista la factura
    IF NOT EXISTS (SELECT 1 FROM psn.Factura WHERE cod_Factura = @cod_Factura)
    BEGIN
        PRINT 'La factura no existe.';
        RETURN;
    END

    -- Validar que exista el ítem en esa factura
    IF NOT EXISTS (
        SELECT 1
        FROM psn.Item_Factura
        WHERE cod_Factura = @cod_Factura AND cod_item = @cod_item
    )
    BEGIN
        PRINT 'El ítem no existe en la factura especificada.';
        RETURN;
    END

    -- Eliminar el ítem
    DELETE FROM psn.Item_Factura
    WHERE cod_Factura = @cod_Factura AND cod_item = @cod_item;

    -- Actualizar el monto total de la factura
    UPDATE psn.Factura
    SET monto = (
        SELECT ISNULL(SUM(monto), 0)
        FROM psn.Item_Factura
        WHERE cod_Factura = @cod_Factura
    )
    WHERE cod_Factura = @cod_Factura;

    PRINT 'Ítem eliminado y monto actualizado en la factura.';
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
    @cod_socio  VARCHAR(15),
    @cod_clase  INT,
    @estado         CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @fecha IS NULL OR @fecha > GETDATE()
    BEGIN
        PRINT 'Error: La fecha no puede ser nula ni futura.';
        RETURN;
    END

    IF @estado IS NULL OR @estado NOT IN ('P','A','J')
    BEGIN
        PRINT 'Error: La fecha no puede ser nula ni futura.';
        RETURN;
    END

    IF @cod_socio IS NULL OR (@cod_socio  NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' 
                          AND @cod_socio  NOT LIKE 'SN-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo de código de socio.';
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
    INSERT INTO psn.Asiste (fecha, cod_socio, cod_clase, estado)
    VALUES (@fecha, @cod_socio, @cod_clase, @estado);

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
    @cod_socio_original VARCHAR(15),
    @cod_clase_original INT,
    @nueva_fecha        DATE,
    @nuevo_cod_socio    VARCHAR(15),
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

    IF @nuevo_cod_socio IS NULL OR @nuevo_cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'
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
    @cod_socio  VARCHAR(15),
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
    @cod_socio         VARCHAR(15),
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

    IF @cod_socio IS NULL OR (@cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' AND @cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para código de socio.';
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
    @cod_socio_original VARCHAR(15),
    @cod_clase_original INT,
    @nueva_fecha        DATE,
    @nuevo_estado       VARCHAR(50),
    @nuevo_cod_socio    VARCHAR(15),
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

    IF @nuevo_cod_socio IS NULL OR (@nuevo_cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' AND @nuevo_cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erróneo para código de socio.';
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
    @cod_socio         VARCHAR(15),
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
