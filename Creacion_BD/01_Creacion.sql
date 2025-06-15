--Crear la Base de datos
drop database Com5600G11
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
			cod_socio			VARCHAR(15) PRIMARY KEY CHECK (cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
															   cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9]'),
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			dni					CHAR(8) UNIQUE,
			email				VARCHAR(100),
			fecha_nac			DATE,
			tel					VARCHAR(50) check (tel NOT LIKE '%[^0-9 -()/]%'),											
			tel_emerg			VARCHAR(50) check (tel_emerg NOT LIKE '%[^0-9 -()/]%'),		
			nombre_cobertura	VARCHAR(50),
			nro_afiliado		VARCHAR(50),
			tel_cobertura		VARCHAR(50) check (tel_cobertura NOT LIKE '%[^0-9 -()/]%'),	
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
go

-- TABLA INVITADO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Invitado') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es que sea unicode
	BEGIN
		CREATE TABLE psn.Invitado (
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
			tel					VARCHAR(50) check (tel NOT LIKE '%[^0-9 -]%')
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
			cod_responsable		VARCHAR(15) PRIMARY KEY CHECK (
			cod_responsable LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR
			cod_responsable LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]'),
			dni					CHAR(8) UNIQUE, 
			nombre				VARCHAR(50),
			apellido			VARCHAR(50),
			email				VARCHAR(100),
			parentezco			VARCHAR(50),
			fecha_nac			DATE,
			nro_socio			INT,				
			tel					VARCHAR(50) check (	tel NOT LIKE '%[^0-9 -]%')
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
go


-- TABLA ACTIVIDAD

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Actividad') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Actividad (
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
go

-- PAGO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Pago') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Pago (
			cod_pago			BIGINT PRIMARY KEY,
			monto				DECIMAL(10,2),
			fecha_pago			DATE,
			estado				VARCHAR(15),
			paga_socio			VARCHAR(15) CHECK (paga_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]' OR 
												   paga_socio LIKE 'SN-[0-9][0-9][0-9][0-9]'),
			paga_invitado		VARCHAR(15) CHECK (paga_invitado LIKE 'NS-[0-9][0-9][0-9][0-9][0-9]' OR 
												   paga_invitado LIKE 'NS-[0-9][0-9][0-9][0-9]'),
			medio_pago			VARCHAR(15)
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
			cod_Factura		INT IDENTITY(1,1) PRIMARY KEY,
			monto			DECIMAL(10,2),
			fecha_emision	DATE,
			fecha_vto		DATE,
			fecha_seg_vto	DATE,
			recargo			DECIMAL(10,2),
			estado			VARCHAR(10) CHECK (estado IN ('Pendiente', 'Pagada','Vencida')),
			cod_socio		VARCHAR(15)
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
		cod_socio				VARCHAR(15) NOT NULL,
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
			fecha			DATE NOT NULL,
			cod_socio		VARCHAR(15) NOT NULL CHECK (cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'),
			cod_clase		INT NOT NULL,
			estado			CHAR(1) CHECK (estado IN ('P','PP','A','J')),
			cod_profesor	INT,
			CONSTRAINT fk_socio FOREIGN KEY (cod_socio) REFERENCES psn.Socio (cod_socio),
			CONSTRAINT fk_clase FOREIGN KEY (cod_clase) REFERENCES psn.Clase(cod_clase),
			CONSTRAINT fk_profesor FOREIGN KEY (cod_profesor) REFERENCES psn.Profesor(cod_prof)
		);	
		PRINT 'Tabla Asiste creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Asiste ya existe.';
	END;
go

-- TABLA ITEM_FACTURA

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Item_Factura') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Item_Factura (
			cod_item	INT IDENTITY(1,1) PRIMARY KEY,
			cod_Factura	INT,
			monto		DECIMAL(10,2),
		
      CONSTRAINT FK_ItemFactura_Factura FOREIGN KEY (cod_Factura)
      REFERENCES psn.Factura (cod_Factura)
      ON DELETE CASCADE
		);
		PRINT 'Tabla Item_Factura creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Item_Factura ya existe.';
	END;
GO


-- Una vez creadas todas las tablas, defino claves.

alter table psn.Socio add constraint fk_responsable FOREIGN KEY (cod_responsable) references psn.Responsable(cod_responsable);

alter table psn.Suscripcion add 		
	constraint fk_socio_sus foreign key	(cod_socio) references psn.Socio(cod_socio),
	constraint fk_cat_sus foreign key (cod_categoria) references psn.Categoria(cod_categoria);

alter table psn.Pago add 		
	constraint fk_socio_pago foreign key (paga_socio) references psn.Socio(cod_socio),
	constraint fk_invit_pago foreign key (paga_invitado) references psn.Invitado(cod_invitado);

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