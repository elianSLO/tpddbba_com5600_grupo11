--Crear la Base de datos
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com5600G11')
	BEGIN
		CREATE DATABASE Com5600G11;
		PRINT 'Base de datos creada exitosamente';
	END;
go

USE Com5600G11
go

--Crear el esquema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'psn')
	BEGIN
		EXEC('CREATE SCHEMA psn');
		PRINT 'Esquema creado exitosamente';
	END;
go

--Creacion de tablas

-- TABLA SOCIO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Socio') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es que sea unicode
	BEGIN
		CREATE TABLE psn.Socio (
			cod_socio			INT IDENTITY(1,1) PRIMARY KEY,
			dni					CHAR(8) UNIQUE,
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			fecha_nac			DATE,
			email				VARCHAR(100),
			tel					VARCHAR(15) check (tel NOT LIKE '%[^0-9]%' and		
													LEN(tel) between 10 and 14),
			tel_emerg			VARCHAR(15) check (tel_emerg NOT LIKE '%[^0-9]%' and		
													LEN(tel_emerg) between 10 and 14),
			estado				BIT, -- 1 - Habilitado, 0 - No habilitado (Pago atrasado o impago)
			saldo				DECIMAL(10,2),
			nombre_cobertura	VARCHAR(50),
			nro_afiliado		VARCHAR(50),
			tel_cobertura		VARCHAR(15) check (tel_cobertura NOT LIKE '%[^0-9]%' and		
													LEN(tel_cobertura) between 10 and 14),
			cod_responsable		INT
		);
		PRINT 'Tabla Socio creada correctamente.';
	END 
ELSE
	BEGIN
		PRINT 'La tabla Socio ya existe.';
	END;
go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Invitado') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es que sea unicode
	BEGIN
		CREATE TABLE psn.Invitado (
			cod_invitado		INT IDENTITY(1,1) PRIMARY KEY,
			dni					CHAR(8) UNIQUE,
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			fecha_nac			DATE,
			email				VARCHAR(100),
			tel					VARCHAR(15) check (tel NOT LIKE '%[^0-9]%' and		
													LEN(tel) between 10 and 14),
			tel_emerg			VARCHAR(15) check (tel_emerg NOT LIKE '%[^0-9]%' and		
													LEN(tel_emerg) between 10 and 14),
			estado				BIT, -- 1 - Habilitado, 0 - No habilitado (Pago atrasado o impago)
			saldo				DECIMAL(10,2),
			nombre_cobertura	VARCHAR(50),
			nro_afiliado		VARCHAR(50),
			tel_cobertura		VARCHAR(15) check (tel_cobertura NOT LIKE '%[^0-9]%' and		
													LEN(tel_cobertura) between 10 and 14),		
			cod_responsable		INT,

		);
		PRINT 'Tabla Invitado creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Invitado ya existe.';
	END;
go

-- TABLA PROFESOR

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Profesor') AND type = N'U')
	BEGIN
		CREATE TABLE psn.Profesor (
			cod_prof			INT IDENTITY(1,1) PRIMARY KEY,
			dni					CHAR(8) UNIQUE, 
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			email				VARCHAR(100),
			tel					VARCHAR(15) check (	tel NOT LIKE '%[^0-9]%' and		-- Solo numeros.
													LEN(tel) between 10 and 14)		-- 2 a 4 digitos para prefijo + 6 a 8 para numero / 0800 incluidos
		);
		PRINT 'Tabla Profesor creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Profesor ya existe.';
	END;
go

-- TABLA RESPONSABLE

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Responsable') AND type = N'U')
	BEGIN
		CREATE TABLE psn.Responsable (
			cod_responsable		INT IDENTITY(1,1) PRIMARY KEY,
			dni					CHAR(8) UNIQUE, 
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			email				VARCHAR(100),
			parentezco			VARCHAR(50),
			fecha_nac			DATE,
			nro_socio			INT,				--VER
			tel					VARCHAR(15) check (	tel NOT LIKE '%[^0-9]%' and		-- Solo numeros.
													LEN(tel) between 10 and 14)		-- 2 a 4 digitos para prefijo + 6 a 8 para numero / 0800 incluidos
		);
		PRINT 'Tabla Responsable creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Responsable ya existe.';
	END;
go


-- TABLA CATEGORIA

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Categoria') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Categoria (
			cod_categoria		INT IDENTITY(1,1) PRIMARY KEY,
			descripcion			VARCHAR(50),
			edad_max			INT,
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
go

--ALTER TABLE psn.Categoria add edad_max int

-- TABLA SUSCRIPCION

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Suscripcion') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Suscripcion (
		fecha_suscripcion	DATE,
		fecha_vto			DATE,
		cod_socio			INT,
		cod_categoria		INT,
		constraint pk_suscripcion primary key (fecha_suscripcion,cod_socio,cod_categoria),
		);
		PRINT 'Tabla Suscripcion creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Suscripcion ya existe.';
	END;
go


-- TABLA ACTIVIDAD

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Actividad') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Actividad (
			cod_actividad INT IDENTITY(1,1) PRIMARY KEY,
			descripcion VARCHAR(50),
			valor_mensual DECIMAL(10,2),
			vig_valor DATE
		);
		PRINT 'Tabla Actividad creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Actividad ya existe.';
	END;
go


-- TABLA PAGO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Pago') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Pago (
			cod_pago		INT IDENTITY(1,1) PRIMARY KEY,
			monto			DECIMAL(10,2),
			fecha_pago		DATE,
			estado			VARCHAR(15),
			cod_socio		INT,
			cod_invitado	INT
		);
		PRINT 'Tabla Pago creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Pago ya existe.';
	END;
go

-- TABLA FACTURA

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Factura') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Factura (
			codFactura		INT IDENTITY(1,1) PRIMARY KEY,
			monto			DECIMAL(10,2),
			fecha_emision	DATE,
			fecha_vto		DATE,
			fecha_seg_vto	DATE,
			recargo			DECIMAL(10,2),
			estado			VARCHAR(10) CHECK (estado IN ('Pendiente', 'Pagada','Vencida')),
			cod_socio		INT
		); 
		PRINT 'Tabla Factura creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Factura ya existe.';
	END;
go

-- TABLA REEMBOLSO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Reembolso') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Reembolso (
			codReembolso		INT IDENTITY(1,1) PRIMARY KEY,
			monto				DECIMAL(10,2),
			medio_Pago			VARCHAR(50),
			fecha				DATE,
			motivo				VARCHAR(50)
		);
		PRINT 'Tabla Reembolso creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Reembolso ya existe.';
	END;
go

-- TABLA RESERVA

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Reserva') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Reserva (
			codReserva			INT IDENTITY(1,1) PRIMARY KEY,
			monto				DECIMAL(10,2),
			fechahoraInicio		DATETIME,	
			fechahoraFin		DATETIME,
			piletaSUMcolonia	VARCHAR(50),
			cod_socio			INT,
			cod_invitado		INT
		);
		PRINT 'Tabla Reserva creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Reserva ya existe.';
	END;
go

-- TABLA CLASE

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Clase') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Clase (
		cod_clase			INT IDENTITY (1,1) PRIMARY KEY,
		categoria			INT NOT NULL,
		cod_actividad		INT NOT NULL,
		);
		PRINT 'Tabla Clase creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Clase ya existe.';
	END;
go

-- TABLA INSCRIPTO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Inscripto') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Inscripto (
		fecha_inscripcion		DATE NOT NULL,
		estado					VARCHAR(50),
		cod_socio				INT NOT NULL,
		cod_clase				INT NOT NULL
		);
		PRINT 'Tabla Inscripto creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Inscripto ya existe.';
	END;
go



-- TABLA ASISTE

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Asiste') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Asiste (
		fecha		DATE NOT NULL,
		cod_socio	INT NOT NULL,
		cod_clase	INT NOT NULL
		);
		PRINT 'Tabla Asiste creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Asiste ya existe.';
	END;
go

-- Una vez creadas todas las tablas, defino claves.

alter table psn.Socio add constraint fk_responsable FOREIGN KEY (cod_responsable) references psn.Responsable(cod_responsable);

alter table psn.Suscripcion add 		
	constraint fk_socio_sus foreign key	(cod_socio) references psn.Socio(cod_socio),
	constraint fk_cat_sus foreign key (cod_categoria) references psn.Categoria(cod_categoria);

alter table psn.Pago add 		
	constraint fk_socio_pago foreign key (cod_socio) references psn.Socio(cod_socio),
	constraint fk_invit_pago foreign key (cod_invitado) references psn.Invitado(cod_invitado);

alter table psn.Factura add 		
	constraint fk_socio_fact foreign key (cod_socio) references psn.Socio(cod_socio);

alter table psn.Reserva add 		
	constraint fk_socio_res foreign key (cod_socio) references psn.Socio(cod_socio),
	constraint fk_invit_res foreign key (cod_invitado) references psn.Invitado(cod_invitado);

alter table psn.Clase add 		
	constraint fk_act_clase foreign key (cod_actividad) references psn.Actividad(cod_actividad);

alter table psn.Inscripto add 	
	constraint pk_inscripto primary key (fecha_inscripcion,cod_socio,cod_clase),
	constraint fk_socio_inscripto foreign key (cod_socio) references psn.Socio(cod_socio),
	constraint fk_clase_inscripto foreign key (cod_clase) references psn.Clase(cod_clase);

alter table psn.Asiste add 	
constraint pk_asiste primary key (fecha,cod_socio,cod_clase),
constraint fk_socio_asiste foreign key (cod_socio) references psn.Socio(cod_socio),
constraint fk_clase_asiste foreign key (cod_clase) references psn.Clase(cod_clase);

go