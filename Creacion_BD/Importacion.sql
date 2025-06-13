-- SCRIPT DE IMPORTACION DE DATOS --
-- Comision 5600 - Grupo 11
-- Fecha: 12/06/2025
-- Integrantes: 

Use Com5600G11
-----------------------------------------------------------------------------------------------------------------------
--Crear el Schema de impotacion
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
	BEGIN
		EXEC('CREATE SCHEMA imp');
		PRINT ' Schema creado exitosamente';
	END;
go

-- SP para importar archivo excel Datos Socios

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'importarSocios')
BEGIN
    DROP PROCEDURE imp.importarSocios;
    PRINT 'SP Importar_ElectronicAccessories ya existe --> se borró';
END;
GO

-- -- 3. Procedimiento para importar reporte meteorologico

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'importarReporteMeteorologico') 
BEGIN
     DROP PROCEDURE imp.importarReporteMeteorologico;
     PRINT 'SP importarReporteMeteorologico ya existe --> se borró';
END;
GO

