--Crear la Base de datos
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com5600G11')
	BEGIN
		CREATE DATABASE Com5600G11;
		PRINT 'Base de datos creada exitosamente';
	END;
go

USE Com5600G11
go

--Crear el Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'psn')
	BEGIN
		EXEC('CREATE SCHEMA psn');
		PRINT 'Schema creado exitosamente';
	END;
go

--Creacion de tablas

-- TABLA SOCIO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Socio') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es q sea unicode
	BEGIN
		CREATE TABLE psn.Socio (
			cod_socio INT IDENTITY(1,1) PRIMARY KEY,
			dni char(8) UNIQUE,
			nombre VARCHAR(50),
			apellido VARCHAR(50),
			fecha_nac DATE,
			email VARCHAR(50),
			telefono VARCHAR(20),
			telefono_aux VARCHAR(20),
			nombre_cobertura VARCHAR(50),
		);
		PRINT 'Tabla Socio creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Socio ya existe.';
	END;
go

-- TABLA PROFESOR

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Profesor') AND type = N'U')
	BEGIN
		CREATE TABLE psn.Profesor (
			cod_prof INT IDENTITY(1,1) PRIMARY KEY,
			dni char(8) UNIQUE, 
			nombre VARCHAR(50),
			apellido VARCHAR(50),
			email VARCHAR(50),
			telefono VARCHAR(20)
		);
		PRINT 'Tabla Profesor creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Profesor ya existe.';
	END;
go


-- TABLA CATEGORIA

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Categoria') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Categoria (
			cod_categoria INT IDENTITY(1,1) PRIMARY KEY,
			nombre VARCHAR(50),
			costo DECIMAL(10,2)
		);
		PRINT 'Tabla Categoria creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Categoria ya existe.';
	END;
go

-- TABLA ACTIVIDAD

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Actividad') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.Actividad (
			cod_actividad INT IDENTITY(1,1) PRIMARY KEY,
			descripcion VARCHAR(50),
			costo_mensual DECIMAL(10,2),
			costo_invitado DECIMAL(10,2)
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
			cod_pago INT IDENTITY(1,1) PRIMARY KEY,
			monto DECIMAL(10,2),
			fecha DATE			
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
			codFactura INT IDENTITY(1,1) PRIMARY KEY,
			monto DECIMAL(10,2),
			fecha_emision DATE,
			fecha_vto DATE,
			fecha_seg_vto DATE,
			recargo DECIMAL(10,2),
			estado VARCHAR(10) CHECK (estado IN ('Pendiente', 'Pagada'))	
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
			codReembolso INT IDENTITY(1,1) PRIMARY KEY,
			medio_Pago VARCHAR(50),
			monto DECIMAL(10,2),
			fecha DATE,
			motivo VARCHAR(50)
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
			codReservaSUM INT IDENTITY(1,1) PRIMARY KEY,
			medio_Pago VARCHAR(50),
			monto DECIMAL(10,2),
			fechahoraInicio DATETIME,	
			fechahoraFin DATETIME,
			piletaSUMcolonia VARCHAR(50)
		);
		PRINT 'Tabla Reserva creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Reserva ya existe.';
	END;
go

-- 