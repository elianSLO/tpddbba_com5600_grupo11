/*
====================================================================================
 Archivo		: 06_Usuarios.sql
 Proyecto		: Institución Deportiva Sol Norte.
 Descripción	: Scripts para los login y usuarios.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Versión		: 1.0
====================================================================================
*/
use Com5600G11
go

EXEC sp_configure 'remote access'
-- select name from sys.sql_logins	


--	Se crean los usuarios para los desarrolladores.
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'elian')
BEGIN
    CREATE LOGIN elian
    WITH PASSWORD = 'elian',
         DEFAULT_DATABASE = Com5600G11,
         CHECK_POLICY = OFF,
         CHECK_EXPIRATION = OFF;
END
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'lucas')
BEGIN
    CREATE LOGIN lucas
    WITH PASSWORD = 'lucas',
         DEFAULT_DATABASE = Com5600G11,
         CHECK_POLICY = OFF,
         CHECK_EXPIRATION = OFF;
END
GO


IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'matias')
BEGIN
    CREATE LOGIN matias
    WITH PASSWORD = 'matias',
         DEFAULT_DATABASE = Com5600G11,
         CHECK_POLICY = OFF,
         CHECK_EXPIRATION = OFF;
END
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'elian')
    CREATE USER elian FOR LOGIN elian;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'lucas')
    CREATE USER lucas FOR LOGIN lucas;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'matias')
    CREATE USER matias FOR LOGIN matias;
GO

alter role db_owner add member elian
alter role db_owner add member lucas
alter role db_owner add member matias
go

----------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Jefe_Tesoreria' AND type = 'R')
    CREATE ROLE Jefe_Tesoreria;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrativo_Cobranza' AND type = 'R')
    CREATE ROLE Administrativo_Cobranza;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrativo_Morosidad' AND type = 'R')
    CREATE ROLE Administrativo_Morosidad;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrativo_Facturacion' AND type = 'R')
    CREATE ROLE Administrativo_Facturacion;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Administrativo_Socio' AND type = 'R')
    CREATE ROLE Administrativo_Socio;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Socio_Web' AND type = 'R')
    CREATE ROLE Socio_Web;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Presidente' AND type = 'R')
    CREATE ROLE Presidente;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vicepresidente' AND type = 'R')
    CREATE ROLE Vicepresidente;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Secretario' AND type = 'R')
    CREATE ROLE Secretario;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vocales' AND type = 'R')
    CREATE ROLE Vocales;




----------------------------------------------
-- ROL: Jefe_Tesoreria
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Finanzas   TO Jefe_Tesoreria;

----------------------------------------------
-- ROL: Administrativo_Cobranza
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Finanzas	TO Administrativo_Cobranza;


----------------------------------------------
-- ROL: Administrativo_Morosidad
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Finanzas	TO Administrativo_Morosidad;

----------------------------------------------
-- ROL: Administrativo_Facturacion
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Finanzas	TO Administrativo_Facturacion;

----------------------------------------------
-- ROL: Administrativo_Socio
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Persona	TO Administrativo_Socio;


----------------------------------------------
-- ROL: Socio_Web
----------------------------------------------
GRANT EXECUTE ON OBJECT::Actividad.insertarReserva		TO Socio_Web;

----------------------------------------------
-- ROL: Presidente
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Finanzas	TO Presidente;
GRANT EXECUTE ON SCHEMA::Club	    TO Presidente;
GRANT EXECUTE ON SCHEMA::Persona	TO Presidente;
GRANT EXECUTE ON SCHEMA::Actividad	TO Presidente;
GRANT EXECUTE ON SCHEMA::Rep		TO Presidente;

----------------------------------------------
-- ROL: Vicepresidente
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Finanzas	TO Vicepresidente;
GRANT EXECUTE ON SCHEMA::Club	    TO Vicepresidente;
GRANT EXECUTE ON SCHEMA::Persona	TO Vicepresidente;
GRANT EXECUTE ON SCHEMA::Actividad	TO Vicepresidente;
GRANT EXECUTE ON SCHEMA::Rep		TO Vicepresidente;

----------------------------------------------
-- ROL: Secretario
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Club	    TO Secretario;
GRANT EXECUTE ON SCHEMA::Persona	TO Secretario;
GRANT EXECUTE ON SCHEMA::Actividad	TO Secretario;
GRANT EXECUTE ON SCHEMA::Rep		TO Secretario;

----------------------------------------------
-- ROL: Vocales

----------------------------------------------






