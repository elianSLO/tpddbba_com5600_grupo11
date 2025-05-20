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
		PRINT ' Schema creado exitosamente';
	END;
go

--Creacion de tablas

-- TABLA SOCIO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Socio') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es q sea unicode
	BEGIN
		CREATE TABLE psn.Socio (
			numero INT IDENTITY(1,1) PRIMARY KEY,
			dni INT UNIQUE, 
			nombre VARCHAR(50),
			apellido VARCHAR(50),
			fecha_nac DATE,
			email VARCHAR(50),
			telefono VARCHAR(20),
			telefono_aux VARCHAR(20)
		);
		PRINT 'Tabla Socio creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Socio ya existe.';
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

