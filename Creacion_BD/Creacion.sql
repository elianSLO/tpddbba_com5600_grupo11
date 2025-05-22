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

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Socio') AND type = N'U') -- 'U' tabla creada por el usuario 'N' es q sea unicode
	BEGIN
		CREATE TABLE psn.Socio (
			cod_socio INT IDENTITY(1,1) PRIMARY KEY,
			dni int UNIQUE check (dni > 999999 and dni < 99999999),
			nombre VARCHAR(50),
			apellido VARCHAR(50),
			fecha_nac DATE,
			email VARCHAR(100),
			tel VARCHAR(15),
			tel_emerg VARCHAR(15),
			estado BIT, -- 1 - Habilitado, 0 - No habilitado (Pago atrasado o impago)
			saldo DECIMAL(10,2),
			nombre_cobertura varchar(50),
			nro_afiliado varchar(50),
			tel_cobertura  varchar(15),

			constraint ck_tel check (
				tel NOT LIKE '%[^0-9]%' and		-- Solo numeros.
				LEN(tel) between 10 and 14		-- 2 a 4 digitos para prefijo + 6 a 8 para numero / 0800 incluidos
			)
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
			email VARCHAR(100),
			tel varchar(15),

			constraint ck_tel check (
				tel NOT LIKE '%[^0-9]%' and		-- Solo numeros.
				LEN(tel) between 10 and 14		-- 2 a 4 digitos para prefijo + 6 a 8 para numero / 0800 incluidos
			)
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
			cod_categoria INT PRIMARY KEY,
			nombre VARCHAR(50),
			valor_mensual DECIMAL(10,2),
			vig_valor_mens DATE,
			valor_anual DECIMAL(10,2),
			vig_valor_anual DATE
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
			cod_actividad INT PRIMARY KEY,
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
			cod_factura INT IDENTITY(1,1) PRIMARY KEY,
			fecha_emision DATE,
			fecha_vto DATE,
			fecha_segundo_vto DATE, -- VER SI VA O NO
			tipo_factura CHAR(1) CHECK (tipo_factura IN ('A', 'B', 'C')),
			estado_factura VARCHAR(10) CHECK (estado_factura IN ('Pendiente', 'Pagada'))	
		); 
		PRINT 'Tabla Factura creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Factura ya existe.';
	END;
go

-- TABLA MEDIO DE PAGO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.MediodePago') AND type = N'U') 
	BEGIN
		CREATE TABLE psn.MediodePago (
			cod_mediopago INT IDENTITY(1,1) PRIMARY KEY,
			descripcion VARCHAR(50)
		);
		PRINT 'Tabla Medio de Pago creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Medio de Pago ya existe.';
	END;
go

