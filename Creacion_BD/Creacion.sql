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
