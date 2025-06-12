-- 3. SCRIPT DE IMPORTACION DE DATOS - 12/06/2025 - Com 5600 - Grupo 11 - Base de Datos Aplicadas,
-- Integrantes: 
--ATENCION: puede ejecutar el archivo como bloque para crear los SP  y luego ir ejecutandolos de a uno para ver la insercion

Use Com5600G11
-----------------------------------------------------------------------------------------------------------------------
--Crear el Schema de impotacion
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'imp')
	BEGIN
		EXEC('CREATE SCHEMA imp');
		PRINT ' Schema creado exitosamente';
	END;
go


