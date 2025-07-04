/*
====================================================================================
 Archivo		: 02_Procedimientos_Tablas.sql
 Proyecto		: Instituci�n Deportiva Sol Norte.
 Descripci�n	: Scripts para inserci�n, modificaci�n y eliminaci�n en tablas.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Versi�n		: 1.0
====================================================================================
*/


USE Com5600G11
go


----------------------------------------------
--	Creacion SPs.	
----------------------------------------------

----------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA CATEGORIA
----------------------------------------------------------------------------------------------------------------

-- SP PARA INSERTAR CATEGORIA
IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarCategoria')
BEGIN
    DROP PROCEDURE Club.insertarCategoria;
END;
GO

CREATE OR ALTER PROCEDURE Club.insertarCategoria
	@descripcion		VARCHAR(50),
	@edad_max			INT,
	@edad_min			INT,
	@valor_mensual		DECIMAL(10,2),
	@vig_valor_mens		DATE,
	@valor_anual		DECIMAL(10,2),
	@vig_valor_anual	DATE	
AS
BEGIN
	SET NOCOUNT ON;

	-- Validar que la descripcion sea v�lida
	IF @descripcion NOT IN ('Cadete', 'Mayor', 'Menor')
	BEGIN
		PRINT 'La descripci�n debe ser Cadete, Mayor o Menor.'
		RETURN;
	END

	-- Validar que no exista ya una categoria con la misma descripcion
	IF EXISTS (SELECT 1 FROM Club.Categoria WHERE descripcion = @descripcion)
	BEGIN
		PRINT 'Ya existe una categor�a con esa descripci�n.'
		RETURN;
	END

	-- Validar que la edad m�xima sea mayor a 0
	IF (@edad_max <= 0 AND @edad_max < @edad_min)
	BEGIN
		PRINT 'La edad m�xima debe ser un n�mero mayor a 0.'
		RETURN;
	END

	IF (@edad_min <= 0 AND @edad_min > @edad_max)
	BEGIN
		PRINT 'La edad m�xima debe ser un n�mero mayor a 0.'
		RETURN;
	END

	-- Validar que los montos no sean nulos o negativos
	IF	@valor_mensual <= 0 OR @valor_mensual IS NULL 
	BEGIN
		PRINT 'El valor de la suscripci�n mensual debe ser mayor a cero'
		RETURN;
	END

	/*IF	@valor_anual <= 0 OR @valor_anual IS NULL 
	BEGIN
		PRINT 'El valor de la suscripci�n debe ser mayor a cero'
		RETURN;
	END

	-- Validar que las fechas de vigencia no sean anteriores a hoy
	IF (@vig_valor_mens < CAST(GETDATE() AS DATE) OR @vig_valor_anual < CAST(GETDATE() AS DATE))
	BEGIN
		PRINT 'Fecha de vigencia anual inv�lida'
		RETURN;
	END*/

	INSERT INTO Club.Categoria(descripcion,edad_max,valor_mensual,vig_valor_mens,valor_anual,vig_valor_anual, edad_min)
	VALUES (@descripcion,@edad_max,@valor_mensual,@vig_valor_mens,@valor_anual,@vig_valor_anual, @edad_min);

	PRINT 'Categor�a insertada correctamente'
	RETURN 1;
END
GO

----------------------------------------------------------------------------------------------------------------

-- SP PARA MODIFICAR CATEGORIA
IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarCategoria')
BEGIN
    DROP PROCEDURE Club.modificarCategoria;
END;
GO

CREATE OR ALTER PROCEDURE Club.modificarCategoria
    @cod_categoria      INT,
    @descripcion        VARCHAR(50),
	@edad_min			INT,
    @edad_max           INT,
    @valor_mensual      DECIMAL(10,2),
    @vig_valor_mens     DATE,
    @valor_anual        DECIMAL(10,2),
    @vig_valor_anual    DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la categor�a exista por c�digo
    IF NOT EXISTS (SELECT 1 FROM Club.Categoria WHERE cod_categoria = @cod_categoria)
    BEGIN
        PRINT 'No existe una categor�a con ese c�digo para modificar.'
        RETURN;
    END

    -- Validar que la descripci�n sea v�lida
    IF @descripcion NOT IN ('Cadete', 'Mayor', 'Menor')
    BEGIN
        PRINT 'La descripci�n debe ser Cadete, Mayor o Menor.'
        RETURN;
    END

    -- Validar que la nueva descripci�n no est� en uso por otra categor�a diferente
    IF EXISTS (
        SELECT 1 FROM Club.Categoria
        WHERE descripcion = @descripcion AND cod_categoria <> @cod_categoria
    )
    BEGIN
        PRINT 'Otra categor�a ya tiene esa descripci�n.'
        RETURN;
    END

    -- Validar que la edad m�xima sea mayor a 0
	IF (@edad_max <= 0 AND @edad_max < @edad_min)
	BEGIN
		PRINT 'La edad m�xima debe ser un n�mero mayor a 0.'
		RETURN;
	END

	IF (@edad_min <= 0 AND @edad_min > @edad_max)
	BEGIN
		PRINT 'La edad m�xima debe ser un n�mero mayor a 0.'
		RETURN;
	END

    -- Validar que los montos no sean nulos o negativos
    IF (@valor_mensual <= 0 OR @valor_mensual IS NULL OR @valor_anual <= 0 OR @valor_anual IS NULL)
    BEGIN
        PRINT 'El valor de la suscripci�n debe ser mayor a cero.'
        RETURN;
    END

    -- Validar que las fechas de vigencia no sean anteriores a hoy
    IF (@vig_valor_mens < CAST(GETDATE() AS DATE) OR @vig_valor_anual < CAST(GETDATE() AS DATE))
    BEGIN
        PRINT 'Fecha de vigencia inv�lida.'
        RETURN;
    END

    -- Actualizar la categor�a
    UPDATE Club.Categoria
    SET descripcion = @descripcion,
		edad_min = @edad_min,
        edad_max = @edad_max,
        valor_mensual = @valor_mensual,
        vig_valor_mens = @vig_valor_mens,
        valor_anual = @valor_anual,
        vig_valor_anual = @vig_valor_anual
    WHERE cod_categoria = @cod_categoria;

    PRINT 'Categor�a modificada correctamente.';
END
GO

----------------------------------------------------------------------------------------------------------------

-- SP PARA BORRAR CATEGORIA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarCategoria')
BEGIN
    DROP PROCEDURE Club.borrarCategoria;
END;
GO

CREATE OR ALTER PROCEDURE Club.borrarCategoria
        @cod_categoria INT
    AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT 1 FROM Club.Categoria WHERE cod_categoria = @cod_categoria)
        BEGIN
            DELETE FROM Club.Categoria WHERE cod_categoria = @cod_categoria;
            PRINT 'Categoria eliminada.';
        END
        ELSE
        BEGIN
            PRINT 'No existe categoria.';
        END
    END
GO

----------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------
--	STORED PROCEDURES PARA TABLA ACTIVIDAD
----------------------------------------------------------------------------------------------------------------

--	SP PARA INSERTAR ACTIVIDAD
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarActividad')
BEGIN
    DROP PROCEDURE Club.insertarActividad;
END;
GO

CREATE OR ALTER PROCEDURE Club.insertarActividad
    @nombre         VARCHAR(50),
    @valor_mensual  DECIMAL(10,2),
    @vig_valor      DATE
AS
BEGIN
    SET NOCOUNT ON;

    /*-- Validar el nombre de la actividad 
    IF @nombre COLLATE Modern_Spanish_CI_AI NOT IN (
        'Futsal',
        'Voley',
        'Taekwondo',
        'Baile artistico',
        'Natacion',
        'Ajedrez'
    )
    BEGIN
        PRINT 'El nombre de la actividad no es correcto.'
        RETURN;
    END	
	*/

    -- Validar que no exista ya una actividad con el mismo nombre
    IF EXISTS (SELECT 1 FROM Club.Actividad WHERE nombre = @nombre)
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

    INSERT INTO Club.Actividad (nombre, valor_mensual, vig_valor)
    VALUES (@nombre, @valor_mensual, @vig_valor)

    PRINT 'Actividad agregada correctamente.'
	RETURN 1;
END
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA MODIFICAR ACTIVIDAD
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarActividad')
BEGIN
    DROP PROCEDURE Club.modificarActividad;
END;
GO

CREATE OR ALTER PROCEDURE Club.modificarActividad
	@nombre				VARCHAR(50),
	@valor_mensual		DECIMAL(10,2),
	@vig_valor			DATE
AS
BEGIN
	-- Validar que exista la actividad
		 IF @nombre COLLATE Modern_Spanish_CI_AI NOT IN (
        'Futsal',
        'V�ley',
        'Taekwondo',
        'Baile art�stico',
        'Nataci�n',
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

	-- Validar que la fecha no est� en el pasado
	IF @vig_valor < GETDATE()
	BEGIN
		PRINT 'Fecha de vigencia inv�lida.'
		RETURN;
	END

	-- Actualizar la actividad
	UPDATE Club.Actividad
	SET
		valor_mensual = @valor_mensual,
		vig_valor = @vig_valor
	WHERE nombre = @nombre;

	PRINT 'Actividad modificada correctamente.';
END
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA ELIMINAR ACTIVIDAD
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'eliminarActividad')
BEGIN
    DROP PROCEDURE Club.eliminarActividad;
END;
GO

CREATE OR ALTER PROCEDURE Club.eliminarActividad
	@nombre VARCHAR(50)
AS
BEGIN
	-- Validar que exista la descripci�n de la actividad
	IF NOT EXISTS (SELECT 1 FROM Club.Actividad WHERE nombre = @nombre)
	BEGIN
		PRINT 'No existe esa actividad.'
		RETURN;
	END
	DELETE FROM Club.Actividad
	WHERE nombre = @nombre;

	PRINT 'Actividad elimnada correctamente.';
END
GO

----------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------
--	STORED PROCEDURES PARA TABLA SOCIO
----------------------------------------------------------------------------------------------------------------

--	Funcion para calcular edad a partir de una fecha.
IF OBJECT_ID('Persona.fn_CalcularEdad') IS NOT NULL
    DROP FUNCTION Persona.fn_CalcularEdad;
GO

CREATE FUNCTION Persona.fn_CalcularEdad
(
    @fecha_nac DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;

    SET @edad = DATEDIFF(YEAR, @fecha_nac, GETDATE()) 
              - CASE 
                    WHEN MONTH(@fecha_nac) > MONTH(GETDATE()) 
                      OR (MONTH(@fecha_nac) = MONTH(GETDATE()) AND DAY(@fecha_nac) > DAY(GETDATE()))
                    THEN 1 
                    ELSE 0 
                END;

    RETURN @edad;
END;
GO

----------------------------------------------------------------------------------------------------------------

-- SP PARA INSERTAR SOCIO
IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarSocio')
BEGIN
    DROP PROCEDURE Persona.insertarSocio;
END;
GO

CREATE OR ALTER PROCEDURE Persona.insertarSocio
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

	--	Validaci�n de campos obligatorios
	/*IF	@cod_socio			IS NULL OR	@dni			IS NULL OR	@nombre		IS NULL OR	@apellido IS NULL OR 
		@fecha_nac			IS NULL /*OR	@email			IS NULL OR	@tel		IS NULL*/ OR	@tel_emerg IS NULL OR
		@nombre_cobertura	IS NULL OR	@nro_afiliado	IS NULL OR	@tel_cobertura IS NULL
       -- cod_responsable puede ser null si es mayor de edad el socio.
	BEGIN
		PRINT 'Error: Faltan datos.';
		RETURN;
	END;*/

	-- Validaciones
	IF NOT (@cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
            @cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'Error: El c�digo de socio debe tener formato "SN-XXXXX".';
		RETURN;
	END;

	DECLARE @edad INT;
	SET @edad = Persona.fn_CalcularEdad(@fecha_nac);

	IF @edad < 18 AND @cod_responsable IS NULL
	BEGIN
		PRINT 'Error: El socio es menor de 18 a�os y debe tener un responsable asignado.';
		RETURN;
	END;

	IF @cod_responsable IS NOT NULL AND NOT (
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9]' OR 
	    @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'Error: El c�digo de responsable debe tener formato "SN-XXXXX" o "NS-XXXXX".';
		RETURN;
    END;

	IF LEN(@dni) <> 8
	BEGIN
		PRINT 'Error: El DNI debe ser de 8 d�gitos';
		RETURN;
	END;

	IF EXISTS (SELECT 1 FROM Persona.Socio WHERE dni = @dni)
	BEGIN
		PRINT CONCAT ('Error: Ya existe un socio con ese DNI (', @dni, ')');
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
		PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END;

	IF @saldo < 0
	BEGIN
		PRINT 'Error: Saldo inv�lido. No puede ser negativo.';
		RETURN;
	END;

	/*-- Solo se valida que no tenga letras
	IF @tel LIKE '%[^0-9 ()-/]%' OR @tel_emerg LIKE '%[^0-9 ()-/]%' OR @tel_cobertura LIKE '%[^0-9 ()-/]%'
	BEGIN
		PRINT 'Error: Los tel�fonos solo deben contener n�meros.';
		RETURN;
	END;*/

	-- Insertar socio
	INSERT INTO Persona.Socio 
	(
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
	RETURN 1;
END;
GO

----------------------------------------------------------------------------------------------------------------

-- SP PARA MODIFICAR SOCIO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarSocio')
BEGIN
    DROP PROCEDURE Persona.modificarSocio;
END;
GO

CREATE OR ALTER PROCEDURE Persona.modificarSocio
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
		PRINT 'Error: Ning�n campo puede ser NULL';
		RETURN;
	END;

	IF @cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'
	BEGIN
		PRINT 'El c�digo de socio debe tener formato "SN-XXXXX".';
		RETURN;
	END;

	IF @cod_responsable IS NOT NULL AND NOT (
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9]' OR 
	    @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'El c�digo de responsable debe tener formato "SN-XXXXX" o "NS-XXXXX".';
		RETURN;
    END;

	IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_socio)
	BEGIN
		PRINT 'Error: Socio no encontrado.';
		RETURN;
	END;

	IF LEN(@dni) <> 8
	BEGIN
		PRINT 'Error: El DNI debe ser de 8 d�gitos';
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
		PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END;

	IF @saldo < 0
	BEGIN
		PRINT 'Saldo inv�lido. No puede ser negativo.';
		RETURN;
	END;

	-- Tel�fonos: solo n�meros
	IF @tel LIKE '%[^0-9 ()-/]%' OR @tel_emerg LIKE '%[^0-9 ()-/]%' OR @tel_cobertura LIKE '%[^0-9 ()-/]%'
	BEGIN
		PRINT 'Error: Los tel�fonos solo deben contener n�meros.';
		RETURN;
	END;

	-- Update
	UPDATE Persona.Socio
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

----------------------------------------------------------------------------------------------------------------

-- SP PARA BORRAR SOCIO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarSocio')
BEGIN
    DROP PROCEDURE Persona.borrarSocio;
END;
GO

CREATE OR ALTER PROCEDURE Persona.borrarSocio
        @cod_socio VARCHAR(15)
    AS
    BEGIN
        SET NOCOUNT ON;
		-- Validaci�n de que el c�digo del socio sea del tipo "SN-XXXXX"
		IF @cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'
		BEGIN
			PRINT 'El c�digo de socio debe tener formato "SN-XXXX".'
			RETURN;
		END
        IF EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_socio)
        BEGIN
            DELETE FROM Persona.Socio WHERE cod_socio = @cod_socio;
            PRINT 'Socio borrado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El socio con el c�digo especificado no existe.';
        END
    END
GO

----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA PROFESOR
----------------------------------------------------------------------------------------------------------------

-- SP PARA INSERTAR PROFESOR
IF  EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarProfesor')
BEGIN
    DROP PROCEDURE Persona.insertarProfesor;
END;
GO

CREATE OR ALTER PROCEDURE Persona.insertarProfesor
	@dni				CHAR(8),
	@nombre				VARCHAR(50),
	@apellido			VARCHAR(50),
	@email				VARCHAR(100),
	@tel				VARCHAR(15)
AS
BEGIN
	
    -- Validaci�n de que ning�n campo sea NULL
    IF @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR 
       @email IS NULL OR @tel IS NULL
    BEGIN
        PRINT 'Error: Ning�n campo puede ser NULL';
        RETURN;
    END;

    -- Validaci�n de que el DNI tenga 8 d�gitos
    IF LEN(@dni) < 8 or LEN(@dni) > 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 d�gitos';
        RETURN;
	END;

	-- Validaci�n de que el DNI no est� insertado
	IF EXISTS (SELECT 1 FROM Persona.Profesor WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un profesor con ese DNI';
        RETURN;
    END;

		-- Validaci�n de que el nombre s�lo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de que el apellido s�lo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

	-- Validaci�n del telefono
	IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
	BEGIN
    PRINT 'Error: Tel�fono inv�lido. Debe contener entre 8 y 14 d�gitos num�ricos.';
    RETURN;
	END

    -- Insertar el profesor
	INSERT INTO Persona.Profesor(
	dni, nombre, apellido, email, tel)
	VALUES (@dni, @nombre, @apellido, @email, @tel);
    
    PRINT 'Profesor insertado correctamente';

END;
GO

----------------------------------------------------------------------------------------------------------------

--SP PARA MODIFICAR PROFESOR
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarProfesor')
BEGIN
    DROP PROCEDURE Persona.modificarProfesor;
END;
GO

CREATE OR ALTER PROCEDURE Persona.modificarProfesor
    @cod_prof   INT,
    @dni        CHAR(8),
    @nombre     VARCHAR(50),
    @apellido   VARCHAR(50),
    @email      VARCHAR(100),
    @tel        VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaci�n de que ning�n campo sea NULL
    IF @cod_prof IS NULL OR @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR @email IS NULL OR @tel IS NULL
    BEGIN
        PRINT 'Error: Ning�n campo puede ser NULL';
        RETURN;
    END;

    -- Validaci�n de existencia del profesor
    IF NOT EXISTS (SELECT 1 FROM Persona.Profesor WHERE cod_prof = @cod_prof)
    BEGIN
        PRINT 'Error: Profesor no encontrado';
        RETURN;
    END;

    -- Validaci�n de DNI
    IF LEN(@dni) <> 8
    BEGIN
        PRINT 'Error: El DNI debe tener exactamente 8 d�gitos';
        RETURN;
    END;

	-- Validaci�n de que el nombre s�lo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de que el apellido s�lo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

    -- Validaci�n de email
    IF @email NOT LIKE '_%@_%._%'
    BEGIN
        PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com';
        RETURN;
    END;

    -- Validaci�n de tel�fono
    IF (LEN(@tel) < 10 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono inv�lido. Debe contener entre 10 y 14 d�gitos num�ricos';
        RETURN;
    END;

    -- Actualizar profesor
    UPDATE Persona.Profesor
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

----------------------------------------------------------------------------------------------------------------

-- SP PARA BORRAR PROFESOR
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarProfesor')
BEGIN
    DROP PROCEDURE Persona.borrarProfesor;
END;
GO

CREATE OR ALTER PROCEDURE Persona.borrarProfesor
        @cod_prof INT
    AS
    BEGIN
        SET NOCOUNT ON;
        IF EXISTS (SELECT 1 FROM Persona.Profesor WHERE cod_prof = @cod_prof)
        BEGIN
            DELETE FROM Persona.Profesor WHERE cod_prof = @cod_prof;
            PRINT 'Profesor borrado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'El profesor con el c�digo especificado no existe.';
        END
    END
GO

----------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA INVITADO
----------------------------------------------------------------------------------------------------------------

-- SP PARA INSERTAR INVITADO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarInvitado')
BEGIN
    DROP PROCEDURE Persona.insertarInvitado;
END;
GO

CREATE OR ALTER PROCEDURE Persona.insertarInvitado
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
        PRINT 'Error: Ning�n campo puede ser NULL';
        RETURN;
    END;

    IF NOT (@cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para @cod_invitado.';
       �RETURN;
����END

	IF @cod_responsable IS NOT NULL AND NOT (
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
        @cod_responsable NOT LIKE 'SN-[0-9][0-9][0-9][0-9]' OR 
	    @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable NOT LIKE 'NS-[0-9][0-9][0-9][0-9]')
	BEGIN
		PRINT 'El c�digo de responsable debe tener formato "SN-XXXXX" o "NS-XXXXX".';
		RETURN;
    END;

    IF LEN(@dni) <> 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 d�gitos';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM Persona.Invitado WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un invitado con ese DNI';
        RETURN;
    END;

	-- Validaci�n de que el nombre s�lo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de que el apellido s�lo contenga letras y espacios
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
        PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com.';
        RETURN;
    END;

    IF @saldo < 0
    BEGIN
        PRINT 'Saldo inv�lido. No puede ser negativo.';
        RETURN;
    END;

    IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono inv�lido.';
        RETURN;
    END;

    IF (LEN(@tel_emerg) < 8 OR LEN(@tel_emerg) > 14 OR @tel_emerg LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono de emergencia inv�lido.';
        RETURN;
    END;

    IF (LEN(@tel_cobertura) < 8 OR LEN(@tel_cobertura) > 14 OR @tel_cobertura LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono de cobertura inv�lido.';
        RETURN;
    END;

    INSERT INTO Persona.Invitado (
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

----------------------------------------------------------------------------------------------------------------

-- SP PARA MODIFICAR INVITADO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarInvitado')
BEGIN
    DROP PROCEDURE Persona.modificarInvitado;
END;
GO

CREATE OR ALTER PROCEDURE Persona.modificarInvitado
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
        PRINT 'Error: Ning�n campo puede ser NULL';
        RETURN;
    END;

    IF NOT (@cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para @cod_invitado.';
       �RETURN;
����END

    IF NOT EXISTS (SELECT 1 FROM Persona.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        PRINT 'Error: Invitado no encontrado.';
        RETURN;
    END;

    IF LEN(@dni) <> 8
    BEGIN
        PRINT 'Error: El DNI debe ser de 8 d�gitos';
        RETURN;
    END;

	-- Validaci�n de que el nombre s�lo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de que el apellido s�lo contenga letras y espacios
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
        PRINT 'Error: Email inv�lido.';
        RETURN;
    END;

    IF @saldo < 0
    BEGIN
        PRINT 'Saldo inv�lido. No puede ser negativo.';
        RETURN;
    END;

    IF (LEN(@tel) < 8 OR LEN(@tel) > 14 OR @tel LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono inv�lido.';
        RETURN;
    END;

    IF (LEN(@tel_emerg) < 8 OR LEN(@tel_emerg) > 14 OR @tel_emerg LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono de emergencia inv�lido.';
        RETURN;
    END;

    IF (LEN(@tel_cobertura) < 8 OR LEN(@tel_cobertura) > 14 OR @tel_cobertura LIKE '%[^0-9]%')
    BEGIN
        PRINT 'Error: Tel�fono de cobertura inv�lido.';
        RETURN;
    END;

    UPDATE Persona.Invitado
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

----------------------------------------------------------------------------------------------------------------

-- SP PARA BORRAR INVITADO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarInvitado')
BEGIN
    DROP PROCEDURE Persona.borrarInvitado;
END;
GO

CREATE OR ALTER PROCEDURE Persona.borrarInvitado
    @cod_invitado VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (@cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para @cod_invitado.';
       �RETURN;
����END

    IF EXISTS (SELECT 1 FROM Persona.Invitado WHERE cod_invitado = @cod_invitado)
    BEGIN
        DELETE FROM Persona.Invitado WHERE cod_invitado = @cod_invitado;
        PRINT 'Invitado borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El invitado con el c�digo especificado no existe.';
    END
END;
GO

----------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA PAGO
----------------------------------------------------------------------------------------------------------------

-- SP PARA INSERCION DE PAGO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarPago')
BEGIN
    DROP PROCEDURE Finanzas.insertarPago;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.insertarPago
	@cod_pago			BIGINT,
	@monto				DECIMAL(10,2),
	@fecha_pago			DATE,
	@estado				VARCHAR(15),
	@responsable		VARCHAR(15),
	@medio_pago			VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	--	Validaci�n de campos obligatorios
	IF	@cod_pago		IS NULL OR	@monto		IS NULL OR		@fecha_pago	IS NULL OR	
		@responsable	IS NULL	OR	@estado		IS NULL 
	BEGIN
		PRINT 'ERROR: Faltan datos.';
		RETURN;
	END

	IF @cod_pago <= 0
	BEGIN
		PRINT 'ERROR: El codigo de pago debe ser mayor a 0.';
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM Finanzas.Pago WHERE cod_pago = @cod_pago)
	BEGIN
		PRINT CONCAT('ERROR: El codigo de pago ya existe. (', @cod_pago, ')');
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

	IF @medio_pago IS NULL OR LEN(@medio_pago) = 0
	BEGIN
		PRINT 'ERROR: El medio de pago debe ser informado.';
		RETURN;
	END

	IF @medio_pago NOT IN ('TARJETA','TRANSFERENCIA','EFECTIVO')
	BEGIN
		PRINT 'ERROR: Medio de pago incorrecto.';
		RETURN;
	END


	IF @responsable IS NOT NULL AND 
	(
		NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @responsable)
		AND
		NOT EXISTS (SELECT 1 FROM Persona.Responsable WHERE cod_responsable = @responsable)
	)
	BEGIN
		PRINT CONCAT('ERROR: El c�digo de responsable especificado no existe (', @responsable, ')');
		RETURN;
	END


	
	INSERT INTO Finanzas.Pago (cod_pago, monto, fecha_pago, estado, responsable, medio_pago)
	VALUES (@cod_pago,@monto, @fecha_pago, @estado, @responsable, @medio_pago);

	PRINT 'Pago insertado correctamente.';
	RETURN 1;
END;
GO

----------------------------------------------------------------------------------------------------------------

-- SP PARA MODIFICACION DE PAGO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarPago')
BEGIN
    DROP PROCEDURE Finanzas.modificarPago;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.modificarPago
	@cod_pago			BIGINT,
	@monto				DECIMAL(10,2),
	@fecha_pago			DATE,
	@estado				VARCHAR(15),
	@responsable		VARCHAR(15),
	@medio_pago			VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Finanzas.Pago WHERE cod_pago = @cod_pago)
	BEGIN
		PRINT 'ERROR: No existe un pago con el c�digo especificado.';
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

	IF @medio_pago IS NULL OR LEN(@medio_pago) = 0
	BEGIN
		PRINT 'ERROR: El medio de pago debe ser informado.';
		RETURN;
	END

	IF @medio_pago NOT IN ('TARJETA','TRANSFERENCIA')
	BEGIN
		PRINT 'ERROR: Medio de pago incorrecto.';
		RETURN;
	END

	IF @responsable IS NOT NULL AND 
	(
		NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @responsable)
		AND
		NOT EXISTS (SELECT 1 FROM Persona.Responsable WHERE cod_responsable = @responsable)
	)
	BEGIN
		PRINT CONCAT('ERROR: El c�digo de responsable especificado no existe (', @responsable, ')');
		RETURN;
	END

	UPDATE Finanzas.Pago
	SET monto = @monto,
		fecha_pago = @fecha_pago,
		estado = @estado,
		responsable = @responsable,
		medio_pago = @medio_pago
	WHERE cod_pago = @cod_pago;

	PRINT 'Pago modificado correctamente.';
END;
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA BORRAR PAGO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarPago')
BEGIN
    DROP PROCEDURE Finanzas.borrarPago;
END;
GO

CREATE PROCEDURE Finanzas.borrarPago
	@cod_pago INT
AS
BEGIN
	SET NOCOUNT ON;

	-- Validaci�n: existencia del pago
	IF NOT EXISTS (SELECT 1 FROM Finanzas.Pago WHERE cod_pago = @cod_pago)
	BEGIN
		PRINT 'ERROR: No existe un pago con ese c�digo.';
		RETURN;
	END

	-- Eliminaci�n
	DELETE FROM Finanzas.Pago
	WHERE cod_pago = @cod_pago;

	PRINT 'Pago eliminado correctamente.';
END;
GO

----------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA PAGO
----------------------------------------------------------------------------------------------------------------

--	SP PARA INSERTAR SUSCRIPCI�N
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarSuscripcion')
BEGIN
    DROP PROCEDURE Club.insertarSuscripcion;
END
GO

CREATE OR ALTER PROCEDURE Club.insertarSuscripcion
	@cod_socio VARCHAR(15),
	@tipoSuscripcion CHAR(1), --Si es anual A, si es mensual M
	@cod_categoria INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_socio)
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
	SET @edadLimite = (SELECT edad_max from Finanzas.Categoria WHERE cod_categoria = @cod_categoria)
	SET @fnac = ( SELECT fecha_nac from Persona.Socio WHERE cod_socio = @cod_socio)
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

	INSERT INTO Club.Suscripcion (cod_socio, cod_categoria, fecha_suscripcion, fecha_vto, tiempoSuscr)
	VALUES(@cod_socio, @cod_categoria, @fecha_inscripcion, @fecha_venc, UPPER(@tipoSuscripcion))

	PRINT 'Socio suscrito exitosamente.'
END

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarSuscripcion')
BEGIN
    DROP PROCEDURE Club.modificarSuscripcion;
END
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA MODIFICAR SUSCRIPCI�N
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarSuscripcion')
BEGIN
    DROP PROCEDURE Club.modificarSuscripcion;
END
GO

CREATE OR ALTER PROCEDURE Club.modificarSuscripcion
	@cod_socio VARCHAR(15),
	@nueva_cat INT,
	@tiempo CHAR(1)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Club.Suscripcion WHERE cod_socio = @cod_socio)
		BEGIN
			PRINT 'No existe suscripcion'
			RETURN
		END
	IF (UPPER(@tiempo) NOT IN ('A','M'))
	BEGIN
		PRINT 'Tipo de suscripcion erronea'
		RETURN
	END
	IF NOT EXISTS (SELECT 1 FROM Club.Suscripcion WHERE cod_categoria = @nueva_cat)
		BEGIN
			PRINT 'No existe categoria'
			RETURN
		END
	DECLARE @edadLimite INT, @edadSocio INT, @fnac DATE
	SET @edadLimite = (SELECT edad_max from Club.Categoria WHERE cod_categoria = @nueva_cat)
	SET @fnac = ( SELECT fecha_nac from Persona.Socio WHERE cod_socio = @cod_socio)
	SET @edadSocio = (SELECT DATEDIFF(YEAR,@fnac,GETDATE()))

	IF (@edadSocio > @edadLimite)
	BEGIN
		PRINT 'Categoria incorrecta'
		RETURN
	END
	IF EXISTS (
		SELECT 1
		FROM Club.Suscripcion
		WHERE cod_socio = @cod_socio
		  AND cod_categoria = @nueva_cat
		  AND tiempoSuscr = @tiempo
	)
	BEGIN
		PRINT 'La suscripci�n ya fue modificada anteriormente.'
		RETURN
	END

	UPDATE Club.Suscripcion
	SET 
		cod_categoria = ISNULL(cod_categoria,@nueva_cat),
		tiempoSuscr = ISNULL(tiempoSuscr, @tiempo)
	WHERE cod_socio = @cod_socio

	PRINT 'Modificaci�n exitosa.'
END

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarSuscripcion')
BEGIN
    DROP PROCEDURE Club.borrarSuscripcion;
END;
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA BORRAR SUSCRIPCI�N
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarSuscripcion')
BEGIN
    DROP PROCEDURE Club.borrarSuscripcion;
END
GO

CREATE OR ALTER PROCEDURE Club.borrarSuscripcion
    @cod_socio VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validaci�n: verificar que exista el c�digo
    IF NOT EXISTS (SELECT 1 FROM Club.Suscripcion WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: No existe suscripcion.';
        RETURN;
    END

    -- Eliminaci�n del registro
    DELETE FROM Club.Suscripcion
    WHERE cod_socio = @cod_socio

    PRINT 'Suscripcion eliminada';
END;
GO

----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
--	STORED PROCEDURES PARA TABLA FACTURA
----------------------------------------------------------------------------------------------------------------

--	SP PARA INSERTAR FACTURA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'emitirFactura')
BEGIN
    DROP PROCEDURE Finanzas.emitirFactura;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.emitirFactura
	@cod_socio		VARCHAR(15)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_socio)
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
	SET @categoria		= (SELECT cod_categoria FROM Club.Suscripcion WHERE @cod_socio = cod_socio)
	SET @tipoSuscripc	= (SELECT tiempoSuscr FROM Club.Suscripcion WHERE @cod_socio = cod_socio)
	SET @monto			= (SELECT valor_mensual from Club.Categoria WHERE cod_categoria = @categoria)
	SET @fecha_emision	= GETDATE();
	SET @fecha_vto		= DATEADD(DAY,5,@fecha_emision)
	SET @fecha_seg_vto	= DATEADD(DAY,5,@fecha_vto)
	SET @estado			= 'Pendiente'
	SET @recargo		= 0

	INSERT INTO Finanzas.Factura (monto,fecha_emision,fecha_vto,fecha_seg_vto,recargo,estado,cod_socio)
	VALUES (@monto,@fecha_emision,@fecha_vto,@fecha_seg_vto, @recargo,@estado,@cod_socio)

	PRINT 'Factura emitida exitosamente.'
	
END
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA MODIFICAR FACTURA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarFactura')
BEGIN
    DROP PROCEDURE Finanzas.modificarFactura;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.modificarFactura
    @cod_socio     VARCHAR(15),
    @cod_Factura   INT,
    @nuevo_estado  VARCHAR(10) -- 'VENCIDA', 'ANULADA' o 'PAGADA'
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia de la factura con ese socio
    IF NOT EXISTS (SELECT 1 FROM Finanzas.Factura WHERE cod_socio = @cod_socio AND cod_Factura = @cod_Factura)
    BEGIN
        PRINT 'No existe la factura para ese socio';
        RETURN;
    END

    -- Validar que el estado ingresado sea uno de los v�lidos
    IF @nuevo_estado NOT IN ('VENCIDA', 'ANULADA', 'PAGADA')
    BEGIN
        PRINT 'Estado inv�lido. Debe ser VENCIDA, ANULADA o PAGADA.';
        RETURN;
    END

    -- Variables para actualizar
    DECLARE @monto         DECIMAL(10,2),
            @fecha_seg_vto DATE;

    -- Obtener valores actuales
    SELECT 
        @monto = monto,
        @fecha_seg_vto = fecha_seg_vto
    FROM Finanzas.Factura
    WHERE cod_Factura = @cod_Factura;

    -- L�gica seg�n estado
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

    -- Actualizaci�n
    UPDATE Finanzas.Factura
    SET 
        estado = @nuevo_estado,
        monto = @monto
    WHERE cod_Factura = @cod_Factura;

    PRINT 'Factura actualizada correctamente';
END
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA BORRAR FACTURA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarFactura')
BEGIN
    DROP PROCEDURE Finanzas.borrarFactura;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.borrarFactura
    @cod_Factura INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Validaci�n: verificar que exista el c�digo
    IF NOT EXISTS (SELECT 1 FROM Finanzas.Factura WHERE cod_Factura = @cod_Factura)
    BEGIN
        PRINT 'Error: No existe factura.';
        RETURN;
    END

    -- Eliminaci�n del registro
    DELETE FROM Finanzas.Factura
    WHERE cod_Factura = @cod_Factura;

    PRINT 'Factura eliminada correctamente.';
END;
GO

----------------------------------------------------------------------------------------------------------------
-- STORED PROCEDURES PARA TABLA REEMBOLSO
----------------------------------------------------------------------------------------------------------------

--- SP PARA INSERTAR REEMBOLSO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarReembolso')
BEGIN
    DROP PROCEDURE Finanzas.insertarReembolso;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.insertarReembolso
    @monto       DECIMAL(10,2),
    @medio_Pago  VARCHAR(50),
    @fecha       DATE,
    @motivo      VARCHAR(50),
    @cod_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaci�n: monto debe ser mayor a 0
    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto debe ser mayor a cero.';
        RETURN;
    END

    IF @cod_factura <= 0
    BEGIN
        PRINT 'Error: El código de factura debe ser mayor a cero.';
        RETURN;
    END

    IF @cod_factura IS NULL OR NOT EXISTS (SELECT 1 FROM psn.Factura WHERE cod_Factura = @cod_factura AND estado = 'Pagada')
    BEGIN
        PRINT 'Error: No existe una factura con estado <Pagada> con el código especificado.';
        RETURN;
    END

    -- Validaci�n: medio_Pago no debe ser NULL ni vac�o
    IF @medio_Pago IS NULL OR LTRIM(RTRIM(@medio_Pago)) = ''
    BEGIN
        PRINT 'Error: El medio de pago no puede estar vac�o.';
        RETURN;
    END

    -- Validaci�n: fecha no puede ser futura
    IF @fecha > GETDATE()
    BEGIN
        PRINT 'Error: La fecha no puede ser futura.';
        RETURN;
    END

    -- Validaci�n: motivo no debe ser NULL ni vac�o
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = ''
    BEGIN
        PRINT 'Error: El motivo no puede estar vac�o.';
        RETURN;
    END

    -- Transaccion para insertar el reembolso y cambiar el estado de la factura a 'Anulada'
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE psn.Factura
        SET estado = 'Anulada'
        WHERE cod_Factura = @cod_factura;

        INSERT INTO psn.Reembolso (monto, medio_Pago, fecha, motivo, cod_factura)
        VALUES (@monto, @medio_Pago, @fecha, @motivo, @cod_factura);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertir la transacción
        ROLLBACK TRANSACTION;
        PRINT 'Error al insertar el reembolso: ' + ERROR_MESSAGE();
        RETURN;
    END CATCH;

    PRINT 'Reembolso insertado correctamente.';
END;
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA MODIFICAR REEMBOLSO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarReembolso')
BEGIN
    DROP PROCEDURE Finanzas.modificarReembolso;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.modificarReembolso
    @codReembolso INT,
    @monto        DECIMAL(10,2),
    @medio_Pago   VARCHAR(50),
    @fecha        DATE,
    @motivo       VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaci�n: c�digo debe existir
    IF NOT EXISTS (SELECT 1 FROM Finanzas.Reembolso WHERE codReembolso = @codReembolso)
    BEGIN
        PRINT 'Error: No existe un reembolso con el c�digo especificado.';
        RETURN;
    END

    -- Validaci�n: monto debe ser mayor a 0
    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto debe ser mayor a cero.';
        RETURN;
    END

    -- Validaci�n: medio_Pago no debe ser NULL ni vac�o
    IF @medio_Pago IS NULL OR LTRIM(RTRIM(@medio_Pago)) = ''
    BEGIN
        PRINT 'Error: El medio de pago no puede estar vac�o.';
        RETURN;
    END

    -- Validaci�n: fecha no puede ser futura
    IF @fecha > GETDATE()
    BEGIN
        PRINT 'Error: La fecha no puede ser futura.';
        RETURN;
    END

    -- Validaci�n: motivo no debe ser NULL ni vac�o
    IF @motivo IS NULL OR LTRIM(RTRIM(@motivo)) = ''
    BEGIN
        PRINT 'Error: El motivo no puede estar vac�o.';
        RETURN;
    END

    -- Actualizaci�n de datos
    UPDATE Finanzas.Reembolso
    SET
        monto = @monto,
        medio_Pago = @medio_Pago,
        fecha = @fecha,
        motivo = @motivo
    WHERE codReembolso = @codReembolso;

    PRINT 'Reembolso modificado correctamente.';
END;
GO

----------------------------------------------------------------------------------------------------------------

--	SP PARA BORRAR REEMBOLSO
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarReembolso')
BEGIN
    DROP PROCEDURE Finanzas.borrarReembolso;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.borrarReembolso
    @codReembolso INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaci�n: verificar que exista el c�digo
    IF NOT EXISTS (SELECT 1 FROM Finanzas.Reembolso WHERE codReembolso = @codReembolso)
    BEGIN
        PRINT 'Error: No existe un reembolso con el c�digo especificado.';
        RETURN;
    END

    -- transacción para eliminar el reembolso y revertir el estado de la factura a 'Pagada'
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Revertir el estado de la factura a 'Pagada'
        DECLARE @cod_factura INT;
        SELECT @cod_factura = cod_factura FROM psn.Reembolso WHERE codReembolso = @codReembolso;
        UPDATE psn.Factura
        SET estado = 'Pagada'
        WHERE cod_Factura = @cod_factura;
        -- Eliminar el reembolso
        DELETE FROM psn.Reembolso
        WHERE codReembolso = @codReembolso;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertir la transacción
        ROLLBACK TRANSACTION;
        PRINT 'Error al eliminar el reembolso: ' + ERROR_MESSAGE();
        RETURN;
    END CATCH;

    PRINT 'Reembolso eliminado correctamente.';
END;
GO

----------------------------------------------------------------------------------------------------------------

--- STORED PROCEDURES PARA TABLA RESPONSABLE


---- INSERCION RESPONSABLE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarResponsable')
BEGIN
    DROP PROCEDURE Persona.insertarResponsable;
END;
GO

CREATE OR ALTER PROCEDURE Persona.insertarResponsable
    @cod_responsable	VARCHAR(15),
    @nombre				VARCHAR(50) = NULL,		--	Se asignan con valores por defecto para chequear si ya es socio.
    @apellido			VARCHAR(50)	= NULL,
	@dni				CHAR(8)		= NULL,
    @email				VARCHAR(100)= NULL,
	@fecha_nac			DATE		= NULL,
	@tel				VARCHAR(15)	= NULL,
    @parentezco			VARCHAR(50)	= NULL
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @esSocio INT = 0;

	IF	@cod_responsable	IS NULL
	BEGIN
		PRINT 'Falta codigo de responsable';
		RETURN;
	END

	IF @cod_responsable LIKE ('SN%')
	BEGIN
		SET @esSocio = 1
	END
	ELSE IF @cod_responsable LIKE ('NS%')
	BEGIN
		SET @esSocio = 0;
	END

	IF @esSocio = 1
	BEGIN
		RETURN
	END


	--	Validaci�n de campos obligatorios
	IF(	@nombre		IS NULL OR	@apellido		IS NULL OR	@dni	IS NULL OR
		@fecha_nac	IS NULL OR	@email			IS NULL OR	@tel	IS NULL)
	BEGIN
		PRINT 'Error: Faltan datos.'
		RETURN;
	END

    -- Validaciones
    IF @dni IS NULL OR LEN(@dni) != 8 OR @dni NOT LIKE '%[0-9]%'
    BEGIN
        PRINT 'Error: El DNI debe contener exactamente 8 d�gitos num�ricos.';
        RETURN;
    END

    IF NOT (@cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato erroneo para cod_responsable.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Persona.Responsable WHERE dni = @dni)
    BEGIN
        PRINT 'Error: Ya existe un responsable con ese DNI.';
        RETURN;
    END

  -- Validaci�n de que el nombre s�lo contenga letras y espacios
	IF @nombre LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El nombre solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de que el apellido s�lo contenga letras y espacios
	IF @apellido LIKE '%[^a-zA-Z ]%'
	BEGIN
    PRINT 'Error: El apellido solo puede contener letras y espacios.';
    RETURN;
	END

	-- Validaci�n de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

    IF @parentezco IS NULL OR LTRIM(RTRIM(@parentezco)) = ''
    BEGIN
        PRINT 'Error: El parentezco no puede estar vac�o.';
        RETURN;
    END

    IF @fecha_nac IS NULL OR @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser nula ni futura.';
        RETURN;
    END

    IF @tel IS NULL OR @tel LIKE '%[^0-9]%' OR LEN(@tel) < 10 OR LEN(@tel) > 14
    BEGIN
        PRINT 'Error: El tel�fono debe contener solo n�meros y tener entre 10 y 14 d�gitos.';
        RETURN;
    END

    -- Inserci�n
    INSERT INTO Persona.Responsable (cod_responsable, nombre, apellido, dni, email, fecha_nac, tel, parentezco)
    VALUES (@cod_responsable, @nombre, @apellido, @dni, @email, @fecha_nac, @tel, @parentezco);

    PRINT 'Responsable insertado correctamente.';
END;
GO

---- MODIFICACION RESPONSABLE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarResponsable')
BEGIN
    DROP PROCEDURE Persona.modificarResponsable;
END;
GO

CREATE OR ALTER PROCEDURE Persona.modificarResponsable
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
        PRINT 'Error: Formato err�neo para cod_responsable.';
       �RETURN;
����END

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Persona.Responsable WHERE cod_responsable = @cod_responsable)
    BEGIN
        PRINT 'Error: No existe un responsable con ese c�digo.';
        RETURN;
    END

    -- Validaciones (igual que en el insert)
    IF @dni IS NULL OR LEN(@dni) != 8 OR @dni NOT LIKE '%[0-9]%'
    BEGIN
        PRINT 'Error: El DNI debe contener exactamente 8 d�gitos num�ricos.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Persona.Responsable 
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

	-- Validaci�n de email
	IF @email NOT LIKE '_%@_%._%'
	BEGIN
		PRINT 'Error: Email inv�lido. Debe tener formato ejemplo@dominio.com.';
		RETURN;
	END

    IF @parentezco IS NULL OR LTRIM(RTRIM(@parentezco)) = ''
    BEGIN
        PRINT 'Error: El parentezco no puede estar vac�o.';
        RETURN;
    END

    IF @fecha_nac IS NULL OR @fecha_nac > GETDATE()
    BEGIN
        PRINT 'Error: La fecha de nacimiento no puede ser nula ni futura.';
        RETURN;
    END

    IF @nro_socio IS NULL OR @nro_socio <= 0
    BEGIN
        PRINT 'Error: El n�mero de socio debe ser un n�mero positivo.';
        RETURN;
    END

    IF @tel IS NULL OR @tel LIKE '%[^0-9]%' OR LEN(@tel) < 10 OR LEN(@tel) > 14
    BEGIN
        PRINT 'Error: El tel�fono debe contener solo n�meros y tener entre 10 y 14 d�gitos.';
        RETURN;
    END

    -- Actualizaci�n
    UPDATE Persona.Responsable
    SET dni = @dni,
        cod_responsable = @cod_responsable,
        nombre = @nombre,
        apellido = @apellido,
        email = @email,
        parentezco = @parentezco,
        fecha_nac = @fecha_nac,
        tel = @tel
    WHERE cod_responsable = @cod_responsable;

    PRINT 'Responsable modificado correctamente.';
END;
GO

---- BORRADO RESPONSABLE
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarResponsable')
BEGIN
    DROP PROCEDURE Persona.borrarResponsable;
END;
GO

CREATE OR ALTER PROCEDURE Persona.borrarResponsable
    @cod_responsable VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (@cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para cod_responsable.';
       �RETURN;
����END

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Persona.Responsable WHERE cod_responsable = @cod_responsable)
    BEGIN
        PRINT 'Error: No existe un responsable con ese c�digo.';
        RETURN;
    END

    -- Eliminaci�n
    DELETE FROM Persona.Responsable
    WHERE cod_responsable = @cod_responsable;

    PRINT 'Responsable eliminado correctamente.';
END;
GO

---------------
-- STORED PROCEDURES PARA TABLA RESERVA

-- SP PARA INSERTAR RESERVA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarReserva')
BEGIN
    DROP PROCEDURE Actividad.insertarReserva;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.insertarReserva
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
        PRINT 'Error: Formato err�neo para @cod_socio.';
       �RETURN;
����END

    IF @cod_invitado IS NOT NULL AND NOT (
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para cod_invitado.';
       �RETURN;
����END

    IF @cod_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: El codigo de socio especificado no existe.';
        RETURN;
    END;

    IF @cod_invitado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Invitado WHERE cod_invitado = @cod_invitado)
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

    IF EXISTS (SELECT 1 FROM Actividad.Reserva
               WHERE piletaSUMColonia = @piletaSUMColonia
                 AND (
                        (@fechahoraInicio < fechahoraFin AND @fechahoraFin > fechahoraInicio) -- Solapamiento
                     )
              )
    BEGIN
       PRINT 'Error: El recurso "' + @piletaSUMColonia + '" ya esta reservado en el horario solicitado.';
       RETURN;
    END;

    INSERT INTO Actividad.Reserva (
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
    DROP PROCEDURE Actividad.modificarReserva;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.modificarReserva
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

    IF NOT EXISTS (SELECT 1 FROM Actividad.Reserva WHERE cod_reserva = @cod_reserva)
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
        PRINT 'Error: Formato err�neo para @cod_socio.';
       �RETURN;
����END

    IF @cod_invitado IS NOT NULL AND NOT (
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]' OR
        @cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para cod_invitado.';
       �RETURN;
����END

    IF @cod_socio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Socio WHERE cod_socio = @cod_socio)
    BEGIN
        PRINT 'Error: El codigo de socio especificado no existe.';
        RETURN;
    END;

    IF @cod_invitado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Persona.Invitado WHERE cod_invitado = @cod_invitado)
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

    IF EXISTS (SELECT 1 FROM Actividad.Reserva
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

    UPDATE Actividad.Reserva
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
    DROP PROCEDURE Actividad.borrarReserva;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.borrarReserva
    @cod_reserva INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Actividad.Reserva WHERE cod_reserva = @cod_reserva)
    BEGIN
        PRINT 'Error: El codigo de reserva especificado no existe.';
        RETURN;
    END;

    DELETE FROM Actividad.Reserva
    WHERE cod_reserva = @cod_reserva;

    PRINT 'Reserva borrada correctamente.';
END;
GO

---------------


-- SP: insertarClase

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarClase')
BEGIN
    DROP PROCEDURE Actividad.insertarClase;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.insertarClase
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
        PRINT 'Error: Ning�n par�metro puede ser NULL.';
        RETURN;
    END;

    IF @dia NOT IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
    BEGIN
        PRINT 'Error: D�a inv�lido.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Club.Categoria WHERE cod_categoria = @categoria)
    BEGIN
        PRINT 'Error: La categor�a especificada no existe.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Club.Actividad WHERE cod_actividad = @cod_actividad)
    BEGIN
        PRINT 'Error: La actividad especificada no existe.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Persona.Profesor WHERE @cod_prof = @cod_prof)
    BEGIN
        PRINT 'Error: No se encontr� profesor.';
        RETURN;
    END;

    IF EXISTS (
        SELECT 1 FROM Actividad.Clase
        WHERE categoria = @categoria AND cod_actividad = @cod_actividad
              AND dia = @dia AND horario = @horario
    )
    BEGIN
        PRINT 'Error: Ya existe una clase con esa combinaci�n.';
        RETURN;
    END;

    INSERT INTO Actividad.Clase (categoria, cod_actividad, dia, horario, cod_prof)
    VALUES (@categoria, @cod_actividad, @dia, @horario, @cod_prof);

    PRINT 'Clase insertada correctamente.';
END;
GO


-- SP: modificarClase

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarClase')
BEGIN
    DROP PROCEDURE Actividad.modificarClase;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.modificarClase
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
        PRINT 'Error: Ning�n par�metro puede ser NULL.';
        RETURN;
    END;

    IF @dia NOT IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
    BEGIN
        PRINT 'Error: D�a inv�lido.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Actividad.Clase WHERE cod_clase = @cod_clase)
    BEGIN
        PRINT 'Error: La clase especificada no existe.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Club.Categoria WHERE cod_categoria = @categoria)
    BEGIN
        PRINT 'Error: La nueva categor�a especificada no existe.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Club.Actividad WHERE cod_actividad = @cod_actividad)
    BEGIN
        PRINT 'Error: La nueva actividad especificada no existe.';
        RETURN;
    END;

    IF EXISTS (
        SELECT 1 FROM Actividad.Clase
        WHERE categoria = @categoria AND cod_actividad = @cod_actividad
              AND dia = @dia AND horario = @horario
              AND cod_clase <> @cod_clase
    )
    BEGIN
        PRINT 'Error: Ya existe otra clase con esa combinaci�n.';
        RETURN;
    END;

    UPDATE Actividad.Clase
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
    DROP PROCEDURE Actividad.borrarClase;
END;
GO

CREATE OR ALTER PROCEDURE Actividad.borrarClase
    @cod_clase INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cod_clase IS NULL
    BEGIN
        PRINT 'Error: El c�digo de clase no puede ser NULL.';
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Actividad.Clase WHERE cod_clase = @cod_clase)
    BEGIN
        PRINT 'Error: La clase con el c�digo especificado no existe.';
        RETURN;
    END;

    DELETE FROM Actividad.Clase
    WHERE cod_clase = @cod_clase;

    PRINT 'Clase eliminada correctamente.';
END;
GO






--- STORED PROCEDURES PARA ITEM_FACTURA

-- INSERCION ITEM_FACTURA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarItem_factura')
BEGIN
    DROP PROCEDURE Finanzas.insertarItem_factura;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.insertarItem_factura
    @cod_item INT,
    @cod_Factura INT,
    @monto DECIMAL(10,2),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia de la factura
    IF NOT EXISTS (
        SELECT 1 FROM Finanzas.Factura WHERE cod_Factura = @cod_Factura
    )
    BEGIN
        PRINT 'Error: La factura con el c�digo ' + CAST(@cod_Factura AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Validar que no exista el mismo cod_item en esa factura
    IF EXISTS (
        SELECT 1 FROM Finanzas.Item_Factura WHERE cod_item = @cod_item AND cod_Factura = @cod_Factura
    )
    BEGIN
        PRINT 'Error: Ya existe un item con el mismo cod_item para esta factura.';
        RETURN;
    END

    -- Validar que el monto sea positivo
    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto debe ser un valor positivo mayor a cero.';
        RETURN;
    END

    -- Validar que la descripci�n no sea NULL ni vac�a o solo espacios
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        PRINT 'Error: La descripci�n no puede ser vac�a ni nula.';
        RETURN;
    END

    -- Inserci�n
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Finanzas.Item_Factura (cod_item, cod_Factura, monto, descripcion)
        VALUES (@cod_item, @cod_Factura, @monto, @descripcion);

        UPDATE Finanzas.Factura
        SET monto = monto + @monto
        WHERE cod_Factura = @cod_Factura;

        COMMIT TRANSACTION;
        PRINT 'Item insertado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Item no se pudo insertar correctamente.';
        THROW;
    END CATCH;
END;
GO


-- MODIFICACION ITEM_FACTURA

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarItem_factura')
BEGIN
    DROP PROCEDURE Finanzas.modificarItem_factura;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.modificarItem_Factura
    @cod_item INT,
    @cod_Factura INT,
    @monto DECIMAL(10,2),
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

	-- Validar existencia de la factura
    IF NOT EXISTS (
        SELECT 1 FROM Finanzas.Factura WHERE cod_Factura = @cod_Factura
    )
    BEGIN
        PRINT 'Error: La factura con el c�digo ' + CAST(@cod_Factura AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Validar que el item exista
    IF NOT EXISTS (
        SELECT 1
        FROM Finanzas.Item_Factura
        WHERE cod_Factura = @cod_Factura
          AND cod_item = @cod_item
    )
    BEGIN
        PRINT 'Error: El item de factura no existe.';
        RETURN;
    END

    -- Validar que el monto sea positivo
    IF @monto <= 0
    BEGIN
        PRINT 'Error: El monto debe ser un valor positivo mayor a cero.';
        RETURN;
    END

    -- Validar que la descripci�n no sea NULL ni vac�a o solo espacios
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        PRINT 'Error: La descripci�n no puede ser vac�a ni nula.';
        RETURN;
    END

    -- Actualizar los datos del item y factura
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @monto_anterior DECIMAL(10,2) = (SELECT monto FROM Finanzas.Item_Factura WHERE cod_Factura = @cod_Factura AND cod_item = @cod_item);

        UPDATE Finanzas.Item_Factura
        SET monto = @monto,
            descripcion = @descripcion
        WHERE cod_Factura = @cod_Factura
          AND cod_item = @cod_item;

        UPDATE Finanzas.Factura
        SET monto = monto - @monto_anterior + @monto
        WHERE cod_Factura = @cod_Factura;

        COMMIT TRANSACTION;
        PRINT 'Item de factura modificado correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Item no se pudo modificar correctamente.';
        THROW;
    END CATCH;
END;
GO



-- BORRADO ITEM_FACTURA
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarItem_factura')
BEGIN
    DROP PROCEDURE Finanzas.borrarItem_factura;
END;
GO

CREATE OR ALTER PROCEDURE Finanzas.borrarItem_factura
    @cod_item INT,
    @cod_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Finanzas.Factura WHERE cod_Factura = @cod_Factura)
    BEGIN
        PRINT 'Error: La factura con el c�digo ' + CAST(@cod_Factura AS VARCHAR) + ' no existe.';
        RETURN;
    END

    DECLARE @monto_item_a_borrar DECIMAL(10,2);

    SELECT @monto_item_a_borrar = monto
    FROM Finanzas.Item_Factura
    WHERE cod_Factura = @cod_Factura AND cod_item = @cod_item;

    IF @monto_item_a_borrar IS NULL
    BEGIN
        PRINT 'Error: El �tem con el c�digo ' + CAST(@cod_item AS VARCHAR) + ' no existe en la factura ' + CAST(@cod_Factura AS VARCHAR) + '.';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM Finanzas.Item_Factura
        WHERE cod_Factura = @cod_Factura AND cod_item = @cod_item;

        UPDATE Finanzas.Factura
        SET monto = monto - @monto_item_a_borrar
        WHERE cod_Factura = @cod_Factura;

        COMMIT TRANSACTION;
        PRINT 'Item eliminado y monto actualizado en la factura correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: El item no se pudo eliminar o el monto de la factura no se pudo actualizar.';
        THROW
    END CATCH
END;
GO


----------------------- SPs ASISTE

-- INSERCION ASISTE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarAsiste')
BEGIN
    DROP PROCEDURE Actividad.insertarAsiste;
END;
GO

CREATE PROCEDURE Actividad.insertarAsiste
    @fecha      DATE,
    @cod_socio  VARCHAR(15),
    @cod_clase  INT,
    @estado     CHAR(1)
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
        PRINT 'Error: Estado inv�lido.';
        RETURN;
    END

    IF @cod_socio IS NULL OR (@cod_socio  NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' 
                          AND @cod_socio  NOT LIKE 'SN-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo de c�digo de socio.';
        RETURN;
    END

    IF NOT EXISTS (
    SELECT 1 FROM Persona.Socio
        WHERE cod_socio = @cod_socio
    )
    BEGIN
        PRINT 'Error: No se encontr� al socio.';
        RETURN;
    END

    IF @cod_clase IS NULL OR @cod_clase <= 0
    BEGIN
        PRINT 'Error: El c�digo de clase debe ser un n�mero positivo.';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Clase
        WHERE cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: La clase no existe';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Inscripto
        WHERE @cod_socio = cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: El socio no esta inscripto a esta clase';
        RETURN;
    END

    -- Validar si ya existe ese registro
    IF EXISTS (
        SELECT 1 FROM Actividad.Asiste
        WHERE fecha = @fecha AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: Ya existe un registro con esa combinaci�n de fecha, socio y clase.';
        RETURN;
    END

    -- Inserci�n
    INSERT INTO Actividad.Asiste (fecha, cod_socio, cod_clase, estado)
    VALUES (@fecha, @cod_socio, @cod_clase, @estado);

    PRINT 'Asistencia registrada correctamente.';
END;
GO

-- MODIFICACION ASISTE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarAsiste')
BEGIN
    DROP PROCEDURE Actividad.modificarAsiste;
END;
GO

CREATE PROCEDURE Actividad.modificarAsiste
    @fecha_original     DATE,
    @cod_socio_original VARCHAR(15),
    @cod_clase_original INT,
    @nuevo_estado       CHAR(1),
    @nueva_fecha        DATE,
    @nuevo_cod_socio    VARCHAR(15),
    @nuevo_cod_clase    INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones para nuevos datos
    IF @nueva_fecha IS NULL OR @nueva_fecha > GETDATE()
    BEGIN
        PRINT 'Error: La nueva fecha no puede ser nula ni futura.';
        RETURN;
    END

    IF @nuevo_cod_socio IS NULL OR @nuevo_cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'
    BEGIN
        PRINT 'Error: El nuevo c�digo de socio debe ser un n�mero positivo.';
        RETURN;
    END

    IF NOT EXISTS (
    SELECT 1 FROM Persona.Socio
        WHERE cod_socio = @nuevo_cod_socio
    )
    BEGIN
        PRINT 'Error: No se encontr� al socio.';
        RETURN;
    END

    IF @nuevo_cod_clase IS NULL OR @nuevo_cod_clase <= 0
    BEGIN
        PRINT 'Error: El nuevo c�digo de clase debe ser un n�mero positivo.';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Clase
        WHERE cod_clase = @nuevo_cod_clase
    )
    BEGIN
        PRINT 'Error: La clase no existe';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Inscripto
        WHERE @nuevo_cod_socio = cod_socio AND cod_clase = @nuevo_cod_clase
    )
    BEGIN
        PRINT 'Error: El socio no esta inscripto a esta clase';
        RETURN;
    END

    IF @nuevo_estado IS NULL OR @nuevo_estado NOT IN ('P','A','J')
    BEGIN
        PRINT 'Error: Estado inv�lido.';
        RETURN;
    END

    -- Validar existencia del registro original
    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Asiste
        WHERE fecha = @fecha_original AND cod_socio = @cod_socio_original AND cod_clase = @cod_clase_original
    )
    BEGIN
        PRINT 'Error: No se encontr� el registro original de asistencia.';
        RETURN;
    END

    -- Validar duplicado en nuevos valores
    IF EXISTS (
        SELECT 1 FROM Actividad.Asiste
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

    -- Actualizaci�n
    UPDATE Actividad.Asiste
    SET fecha = @nueva_fecha,
        cod_socio = @nuevo_cod_socio,
        cod_clase = @nuevo_cod_clase,
        estado = @nuevo_estado
    WHERE fecha = @fecha_original AND cod_socio = @cod_socio_original AND cod_clase = @cod_clase_original;

    PRINT 'Registro de asistencia modificado correctamente.';
END;
GO

-- BORRADO ASISTE

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarAsiste')
BEGIN
    DROP PROCEDURE Actividad.borrarAsiste;
END;
GO

CREATE PROCEDURE Actividad.borrarAsiste
    @fecha      DATE,
    @cod_socio  VARCHAR(15),
    @cod_clase  INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del registro
    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Asiste
        WHERE fecha = @fecha AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: No se encontr� un registro con esos datos.';
        RETURN;
    END

    -- Eliminaci�n
    DELETE FROM Actividad.Asiste
    WHERE fecha = @fecha AND cod_socio = @cod_socio AND cod_clase = @cod_clase;

    PRINT 'Asistencia eliminada correctamente.';
END;
GO


------------------------------------------ SPs INSCRIPTO

-- INSERCION INSCRIPTO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'insertarInscripto')
    DROP PROCEDURE Actividad.insertarInscripto;
GO

CREATE PROCEDURE Actividad.insertarInscripto
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
        PRINT 'Error: La fecha de inscripci�n no puede ser nula ni futura.';
        RETURN;
    END

    IF @estado IS NULL OR LTRIM(RTRIM(@estado)) = ''
    BEGIN
        PRINT 'Error: El estado no puede estar vac�o.';
        RETURN;
    END

    IF @cod_socio IS NULL OR (@cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' AND @cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para c�digo de socio.';
        RETURN;
    END

    IF @cod_clase IS NULL OR @cod_clase <= 0
    BEGIN
        PRINT 'Error: El c�digo de clase debe ser un n�mero positivo.';
        RETURN;
    END

    -- Validar duplicado
    IF EXISTS (
        SELECT 1 FROM Actividad.Inscripto
        WHERE fecha_inscripcion = @fecha_inscripcion AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: Ya existe una inscripci�n con esos datos.';
        RETURN;
    END

    -- Inserci�n
    INSERT INTO Actividad.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
    VALUES (@fecha_inscripcion, @estado, @cod_socio, @cod_clase);

    PRINT 'Inscripci�n registrada correctamente.';
END;
GO

-- MODIFICACION INSCRIPTO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'modificarInscripto')
    DROP PROCEDURE Actividad.modificarInscripto;
GO

CREATE PROCEDURE Actividad.modificarInscripto
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
        SELECT 1 FROM Actividad.Inscripto
        WHERE fecha_inscripcion = @fecha_original AND cod_socio = @cod_socio_original AND cod_clase = @cod_clase_original
    )
    BEGIN
        PRINT 'Error: No se encontr� la inscripci�n original.';
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
        PRINT 'Error: El nuevo estado no puede estar vac�o.';
        RETURN;
    END

    IF @nuevo_cod_socio IS NULL OR (@nuevo_cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' AND @nuevo_cod_socio NOT LIKE 'SN-[0-9][0-9][0-9][0-9]')
    BEGIN
        PRINT 'Error: Formato err�neo para c�digo de socio.';
        RETURN;
    END

    IF @nuevo_cod_clase IS NULL OR @nuevo_cod_clase <= 0
    BEGIN
        PRINT 'Error: El nuevo c�digo de clase debe ser un n�mero positivo.';
        RETURN;
    END

    -- Validar duplicado con nuevos datos
    IF EXISTS (
        SELECT 1 FROM Actividad.Inscripto
        WHERE fecha_inscripcion = @nueva_fecha AND cod_socio = @nuevo_cod_socio AND cod_clase = @nuevo_cod_clase
          AND NOT (
              fecha_inscripcion = @fecha_original AND
              cod_socio = @cod_socio_original AND
              cod_clase = @cod_clase_original
          )
    )
    BEGIN
        PRINT 'Error: Ya existe otra inscripci�n con los nuevos datos.';
        RETURN;
    END

    -- Actualizaci�n
    UPDATE Actividad.Inscripto
    SET fecha_inscripcion = @nueva_fecha,
        estado = @nuevo_estado,
        cod_socio = @nuevo_cod_socio,
        cod_clase = @nuevo_cod_clase
    WHERE fecha_inscripcion = @fecha_original
      AND cod_socio = @cod_socio_original
      AND cod_clase = @cod_clase_original;

    PRINT 'Inscripci�n modificada correctamente.';
END;
GO


-- BORRADO INSCRIPTO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'borrarInscripto')
    DROP PROCEDURE Actividad.borrarInscripto;
GO

CREATE PROCEDURE Actividad.borrarInscripto
    @fecha_inscripcion DATE,
    @cod_socio         VARCHAR(15),
    @cod_clase         INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (
        SELECT 1 FROM Actividad.Inscripto
        WHERE fecha_inscripcion = @fecha_inscripcion AND cod_socio = @cod_socio AND cod_clase = @cod_clase
    )
    BEGIN
        PRINT 'Error: No se encontr� una inscripci�n con esos datos.';
        RETURN;
    END

    -- Eliminaci�n
    DELETE FROM Actividad.Inscripto
    WHERE fecha_inscripcion = @fecha_inscripcion
      AND cod_socio = @cod_socio
      AND cod_clase = @cod_clase;

    PRINT 'Inscripci�n eliminada correctamente.';
END;
GO
