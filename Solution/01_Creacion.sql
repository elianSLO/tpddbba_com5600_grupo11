/*
====================================================================================
 Archivo		: 01_Creacion.sql
 Proyecto		: Institucion Deportiva Sol Norte.
 Descripcion	: Scripts para creacion/eliminacion de la base de datos.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Version		: 1.0
====================================================================================
*/


----------------------------------------------
--	Crear la base de datos.
----------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com5600G11')
	BEGIN
		CREATE DATABASE Com5600G11;
		PRINT 'Base de datos creada exitosamente';
	END;
GO

USE Com5600G11
GO

----------------------------------------------
--	Crear el esquema.	
----------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Persona')
	BEGIN
		EXEC('CREATE SCHEMA Persona');
		PRINT 'Esquema creado exitosamente';
	END;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Finanzas')
	BEGIN
		EXEC('CREATE SCHEMA Finanzas');
		PRINT 'Esquema creado exitosamente';
	END;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Club')
	BEGIN
		EXEC('CREATE SCHEMA Club');
		PRINT 'Esquema creado exitosamente';
	END;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Actividad')
	BEGIN
		EXEC('CREATE SCHEMA Actividad');
		PRINT 'Esquema creado exitosamente';
	END;
GO



----------------------------------------------
--	Creacion de las tablas.
----------------------------------------------


-- TABLA SOCIO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Persona.Socio') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es que sea unicode
	BEGIN
		CREATE TABLE Persona.Socio (
			cod_socio			VARCHAR(15) PRIMARY KEY CHECK (cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
															   cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]'),
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			dni					CHAR(8) UNIQUE,
			email				VARCHAR(100),
			fecha_nac			DATE,
			tel					VARCHAR(50) /*check (tel NOT LIKE '%[^0-9 -()/]%')*/,											
			tel_emerg			VARCHAR(50) /*check (tel_emerg NOT LIKE '%[^0-9 -()/]%')*/,		
			nombre_cobertura	VARCHAR(50),
			nro_afiliado		VARCHAR(50),
			tel_cobertura		VARCHAR(50) /*check (tel_cobertura NOT LIKE '%[^0-9 -()/]%')*/,	
			estado				BIT, -- 1 - Habilitado, 0 - No habilitado (Pago atrasado o impago)
			saldo				DECIMAL(10,2),
			cod_responsable		VARCHAR(15)
		);
		PRINT 'Tabla Socio creada correctamente.';
	END 
ELSE
	BEGIN
		PRINT 'La tabla Socio ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA RESPONSABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Persona.Responsable') AND type = N'U')
	BEGIN
		CREATE TABLE Persona.Responsable 
		(
			cod_responsable		VARCHAR(15) PRIMARY KEY	CHECK (	cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR 
																cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9]'		OR
																cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
																cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9]'),
			nombre				VARCHAR(50), 
			apellido			VARCHAR(50),
			dni					CHAR(8) /*UNIQUE*/ , 			
			email				VARCHAR(100),
			fecha_nac			DATE,	
			tel					VARCHAR(50),				/*check (	tel NOT LIKE '%[^0-9 -]%')*/
			parentezco			VARCHAR(50),			
		);
		PRINT 'Tabla Responsable creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Responsable ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA INVITADO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Persona.Invitado') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es que sea unicode
	BEGIN
		CREATE TABLE Persona.Invitado (
			cod_invitado		VARCHAR(15) PRIMARY KEY CHECK (cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR 
																cod_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]'),
			dni					CHAR(8) UNIQUE,
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			fecha_nac			DATE,
			email				VARCHAR(100),
			tel					VARCHAR(50) check (tel NOT LIKE '%[^0-9 -]%'),		
			tel_emerg			VARCHAR(50) check (tel_emerg NOT LIKE '%[^0-9 -]%'),		
			estado				BIT, -- 1 - Habilitado, 0 - No habilitado (Pago atrasado o impago)
			saldo				DECIMAL(10,2),
			nombre_cobertura	VARCHAR(50),
			nro_afiliado		VARCHAR(50),
			tel_cobertura		VARCHAR(50) check (tel_cobertura NOT LIKE '%[^0-9 -]%'),				
			cod_responsable		VARCHAR(15),

		);
		PRINT 'Tabla Invitado creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Invitado ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA PROFESOR
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Persona.Profesor') AND type = N'U')
	BEGIN
		CREATE TABLE Persona.Profesor (
			cod_prof			INT IDENTITY(1,1) PRIMARY KEY,
			dni					CHAR(8) UNIQUE, 
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			email				VARCHAR(100),
			tel					VARCHAR(50) check (tel NOT LIKE '%[^0-9 -]%')
		);
		PRINT 'Tabla Profesor creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Profesor ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA PAGO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Finanzas.Pago') AND type = N'U') 
	BEGIN
		CREATE TABLE Finanzas.Pago 
		(
			cod_pago	INT IDENTITY(1,1) PRIMARY KEY,
			cod_factura	INT NOT NULL,
			fecha_pago			DATE,
			responsable			VARCHAR(15) CHECK (responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
												   								responsable LIKE 'SN-[0-9][0-9][0-9][0-9]'OR 
												   								responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]'OR 
												   								responsable LIKE 'NS-[0-9][0-9][0-9][0-9]'),
			medio_pago			VARCHAR(15)
		);
		PRINT 'Tabla Pago creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Pago ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA FACTURA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Finanzas.Factura') AND type = N'U') 
	BEGIN
		CREATE TABLE Finanzas.Factura (
			cod_Factura		INT IDENTITY(1,1) PRIMARY KEY,
			monto			DECIMAL(10,2),
			fecha_emision	DATE,
			fecha_vto		DATE,
			fecha_seg_vto	DATE,
			recargo			DECIMAL(10,2),
			estado			VARCHAR(10) CHECK (estado IN ('Pendiente', 'Pagada','Vencida','Anulada')),
			cod_socio		VARCHAR(15)
		); 
		PRINT 'Tabla Factura creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Factura ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA ITEM_FACTURA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Finanzas.Item_Factura') AND type = N'U') 
	BEGIN
		CREATE TABLE Finanzas.Item_Factura (
			cod_item	INT NOT NULL, -- No puede ser auotincremental 
			cod_Factura	INT NOT NULL,
			monto		DECIMAL(10,2),
			descripcion VARCHAR(50)
		
      CONSTRAINT FK_ItemFactura_Factura FOREIGN KEY (cod_Factura)
      REFERENCES Finanzas.Factura (cod_Factura) -- Clave primaria compuesta, cada codigo de factura con sus respectivos items
      ON DELETE CASCADE
		);
		PRINT 'Tabla Item_Factura creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Item_Factura ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA REEMBOLSO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Finanzas.Reembolso') AND type = N'U') 
	BEGIN
		CREATE TABLE Finanzas.Reembolso (
			codReembolso		INT IDENTITY(1,1) PRIMARY KEY,
			fecha				DATE,
			motivo				VARCHAR(50),
			cod_factura		INT NOT NULL
		);
		PRINT 'Tabla Reembolso creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Reembolso ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA RESERVA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Actividad.Reserva') AND type = N'U') 
	BEGIN
		CREATE TABLE Actividad.Reserva (
			cod_reserva			INT IDENTITY(1,1) PRIMARY KEY,
			monto				DECIMAL(10,2),
			fechahoraInicio		DATETIME,	
			fechahoraFin		DATETIME,
			piletaSUMcolonia	VARCHAR(50),
			cod_socio			VARCHAR(15),
			cod_invitado		VARCHAR (15)
		);
		PRINT 'Tabla Reserva creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Reserva ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA CLASE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Actividad.Clase') AND type = N'U') 
	BEGIN
		CREATE TABLE Actividad.Clase (
			cod_clase			INT IDENTITY (1,1) PRIMARY KEY,
			categoria			INT NOT NULL,
			cod_actividad		INT NOT NULL,
			cod_prof			INT NOT NULL,
			dia					VARCHAR(9) NOT NULL CHECK (dia IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')),
			horario				TIME NOT NULL
		);
		PRINT 'Tabla Clase creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Clase ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------
-- TABLA CATEGORIA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Club.Categoria') AND type = N'U') 
	BEGIN
		CREATE TABLE Club.Categoria (
			cod_categoria		INT IDENTITY(1,1) PRIMARY KEY,
			descripcion			VARCHAR(50),
			edad_max			INT,
			edad_min			INT,
			valor_mensual		DECIMAL(10,2),
			vig_valor_mens		DATE,
			valor_anual			DECIMAL(10,2),
			vig_valor_anual		DATE
		);
		PRINT 'Tabla Categoria creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Categoria ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------
-- TABLA SUSCRIPCION
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Club.Suscripcion') AND type = N'U') 
	BEGIN
		CREATE TABLE Club.Suscripcion (
		fecha_suscripcion	DATE,
		fecha_vto			DATE,
		cod_socio			VARCHAR(15),
		cod_categoria		INT,
		tiempoSuscr			CHAR(1),
		constraint pk_suscripcion primary key (fecha_suscripcion,cod_socio,cod_categoria),
		);
		PRINT 'Tabla Suscripcion creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Suscripcion ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA ACTIVIDAD
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Club.Actividad') AND type = N'U') 
	BEGIN
		CREATE TABLE Club.Actividad (
			cod_actividad INT IDENTITY(1,1) PRIMARY KEY,
			nombre VARCHAR(50),
			valor_mensual DECIMAL(10,2),
			vig_valor DATE
		);
		PRINT 'Tabla Actividad creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Actividad ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA INSCRIPTO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Actividad.Inscripto') AND type = N'U') 
	BEGIN
		CREATE TABLE Actividad.Inscripto (
		fecha_inscripcion		DATE NOT NULL,
		estado					VARCHAR(50),
		cod_socio				VARCHAR(15) NOT NULL,
		cod_clase				INT NOT NULL
		);
		PRINT 'Tabla Inscripto creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Inscripto ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

-- TABLA ASISTE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Actividad.Asiste') AND type = N'U') 
	BEGIN
		CREATE TABLE Actividad.Asiste (
			fecha			DATE NOT NULL,
			cod_socio		VARCHAR(15) NOT NULL CHECK (cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]'),
			cod_clase		INT NOT NULL,
			estado			CHAR(1) CHECK (estado IN ('P','A','J')),
			CONSTRAINT fk_socio FOREIGN KEY (cod_socio) REFERENCES Persona.Socio (cod_socio),
			CONSTRAINT fk_clase FOREIGN KEY (cod_clase) REFERENCES Actividad.Clase(cod_clase)
		);	
		PRINT 'Tabla Asiste creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Asiste ya existe.';
	END;
GO

----------------------------------------------------------------------------------------------------------------

----------------------------------------------
--	Claves y restricciones.
----------------------------------------------
/*	
-- FK Persona.Socio -> Persona.Responsable
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_responsable' AND parent_object_id = OBJECT_ID('Persona.Socio')
)
BEGIN
    ALTER TABLE Persona.Socio 
    ADD CONSTRAINT fk_responsable 
    FOREIGN KEY (cod_responsable) REFERENCES Persona.Responsable(cod_responsable);
END;
*/
----------------------------------------------------------------------------------------------------------------

-- FK Club.Suscripcion -> Persona.Socio
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_socio_sus' AND parent_object_id = OBJECT_ID('Club.Suscripcion')
)
BEGIN
    ALTER TABLE Club.Suscripcion 
    ADD CONSTRAINT fk_socio_sus 
    FOREIGN KEY (cod_socio) REFERENCES Persona.Socio(cod_socio);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Club.Suscripcion -> Club.Categoria
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_cat_sus' AND parent_object_id = OBJECT_ID('Club.Suscripcion')
)
BEGIN
    ALTER TABLE Club.Suscripcion 
    ADD CONSTRAINT fk_cat_sus 
    FOREIGN KEY (cod_categoria) REFERENCES Club.Categoria(cod_categoria);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Finanzas.Factura -> Persona.Socio
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_socio_fact' AND parent_object_id = OBJECT_ID('Finanzas.Factura')
)
BEGIN
    ALTER TABLE Finanzas.Factura 
    ADD CONSTRAINT fk_socio_fact 
    FOREIGN KEY (cod_socio) REFERENCES Persona.Socio(cod_socio);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Reserva -> Persona.Socio
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_socio_res' AND parent_object_id = OBJECT_ID('Actividad.Reserva')
)
BEGIN
    ALTER TABLE Actividad.Reserva 
    ADD CONSTRAINT fk_socio_res 
    FOREIGN KEY (cod_socio) REFERENCES Persona.Socio(cod_socio);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Reserva -> Persona.Invitado
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_invit_res' AND parent_object_id = OBJECT_ID('Actividad.Reserva')
)
BEGIN
    ALTER TABLE Actividad.Reserva 
    ADD CONSTRAINT fk_invit_res 
    FOREIGN KEY (cod_invitado) REFERENCES Persona.Invitado(cod_invitado);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Clase -> Club.Actividad
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_act_clase' AND parent_object_id = OBJECT_ID('Actividad.Clase')
)
BEGIN
    ALTER TABLE Actividad.Clase 
    ADD CONSTRAINT fk_act_clase 
    FOREIGN KEY (cod_actividad) REFERENCES Club.Actividad(cod_actividad);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Clase -> Persona.Profesor
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_prof_clase' AND parent_object_id = OBJECT_ID('Actividad.Clase')
)
BEGIN
    ALTER TABLE Actividad.Clase 
    ADD CONSTRAINT fk_prof_clase 
    FOREIGN KEY (cod_prof) REFERENCES Persona.Profesor(cod_prof);
END;

----------------------------------------------------------------------------------------------------------------

-- PK Actividad.Inscripto
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'pk_inscripto' AND object_id = OBJECT_ID('Actividad.Inscripto')
)
BEGIN
    ALTER TABLE Actividad.Inscripto 
    ADD CONSTRAINT pk_inscripto 
    PRIMARY KEY (fecha_inscripcion, cod_socio, cod_clase);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Inscripto -> Persona.Socio
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_socio_inscripto' AND parent_object_id = OBJECT_ID('Actividad.Inscripto')
)
BEGIN
    ALTER TABLE Actividad.Inscripto 
    ADD CONSTRAINT fk_socio_inscripto 
    FOREIGN KEY (cod_socio) REFERENCES Persona.Socio(cod_socio);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Inscripto -> Actividad.Clase
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_clase_inscripto' AND parent_object_id = OBJECT_ID('Actividad.Inscripto')
)
BEGIN
    ALTER TABLE Actividad.Inscripto 
    ADD CONSTRAINT fk_clase_inscripto 
    FOREIGN KEY (cod_clase) REFERENCES Actividad.Clase(cod_clase);
END;

----------------------------------------------------------------------------------------------------------------

-- PK Actividad.Asiste
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'pk_asiste' AND object_id = OBJECT_ID('Actividad.Asiste')
)
BEGIN
    ALTER TABLE Actividad.Asiste 
    ADD CONSTRAINT pk_asiste 
    PRIMARY KEY (fecha, cod_socio, cod_clase);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Asiste -> Persona.Socio
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_socio_asiste' AND parent_object_id = OBJECT_ID('Actividad.Asiste')
)
BEGIN
    ALTER TABLE Actividad.Asiste 
    ADD CONSTRAINT fk_socio_asiste 
    FOREIGN KEY (cod_socio) REFERENCES Persona.Socio(cod_socio);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Actividad.Asiste -> Actividad.Clase
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_clase_asiste' AND parent_object_id = OBJECT_ID('Actividad.Asiste')
)
BEGIN
    ALTER TABLE Actividad.Asiste 
    ADD CONSTRAINT fk_clase_asiste 
    FOREIGN KEY (cod_clase) REFERENCES Actividad.Clase(cod_clase);
END;

----------------------------------------------------------------------------------------------------------------

-- FK Finanzas.Factura -> Finanzas.Reembolso
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_fact_reembolso' AND parent_object_id = OBJECT_ID('Finanzas.Reembolso')
)
BEGIN
    ALTER TABLE Finanzas.Reembolso
    ADD CONSTRAINT fk_fact_reembolso
    FOREIGN KEY (cod_factura) REFERENCES Finanzas.Factura(cod_Factura);
END;
GO

----------------------------------------------------------------------------------------------------------------

-- FK Finanzas.Factura -> Finanzas.Pago
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'fk_fact_pago' AND parent_object_id = OBJECT_ID('Finanzas.Pago')
)
BEGIN
    ALTER TABLE Finanzas.Pago
    ADD CONSTRAINT fk_fact_pago
    FOREIGN KEY (cod_factura) REFERENCES Finanzas.Factura(cod_Factura);
END;
GO