/*
====================================================================================
 Archivo		: 06_Usuarios.sql
 Proyecto		: Institución Deportiva Sol Norte.
 Descripción	: Creación de logins, usuarios y asignación de roles.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Versión		: 1.0
====================================================================================
*/


----------------------------------------------------------------------------------------------------------------
-- 1. CREACIÓN DE LOGINS (A NIVEL DE SERVIDOR)
----------------------------------------------------------------------------------------------------------------
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'elian')
    CREATE LOGIN elian WITH PASSWORD = 'elian', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'lucas')
    CREATE LOGIN lucas WITH PASSWORD = 'lucas', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'matias')
    CREATE LOGIN matias WITH PASSWORD = 'matias', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;


IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'JefeTesoreria')
    CREATE LOGIN JefeTesoreria WITH PASSWORD = 'JefeTesoreria', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'AdministrativoCobranza')
    CREATE LOGIN AdministrativoCobranza WITH PASSWORD = 'AdministrativoCobranza', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'AdministrativoMorosidad')
    CREATE LOGIN AdministrativoMorosidad WITH PASSWORD = 'AdministrativoMorosidad', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'AdministrativoFacturacion')
    CREATE LOGIN AdministrativoFacturacion WITH PASSWORD = 'AdministrativoFacturacion', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'AdministrativoSocio')
    CREATE LOGIN AdministrativoSocio WITH PASSWORD = 'AdministrativoSocio', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'SocioWeb')
    CREATE LOGIN SocioWeb WITH PASSWORD = 'SocioWeb', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'Presidente')
    CREATE LOGIN Presidente WITH PASSWORD = 'Presidente', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'Vicepresidente')
    CREATE LOGIN Vicepresidente WITH PASSWORD = 'Vicepresidente', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'Secretario')
    CREATE LOGIN Secretario WITH PASSWORD = 'Secretario', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'Vocales')
    CREATE LOGIN Vocales WITH PASSWORD = 'Vocales', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO




----------------------------------------------------------------------------------------------------------------
-- 2. CREACIÓN DE USUARIOS EN LA BASE Com5600G11
----------------------------------------------------------------------------------------------------------------
USE Com5600G11;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'elian')
    CREATE USER elian FOR LOGIN elian;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'lucas')
    CREATE USER lucas FOR LOGIN lucas;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'matias')
    CREATE USER matias FOR LOGIN matias;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'JefeTesoreria')
    CREATE USER JefeTesoreria FOR LOGIN JefeTesoreria;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoCobranza')
    CREATE USER AdministrativoCobranza FOR LOGIN AdministrativoCobranza;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoMorosidad')
    CREATE USER AdministrativoMorosidad FOR LOGIN AdministrativoMorosidad;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoFacturacion')
    CREATE USER AdministrativoFacturacion FOR LOGIN AdministrativoFacturacion;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoSocio')
    CREATE USER AdministrativoSocio FOR LOGIN AdministrativoSocio;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SocioWeb')
    CREATE USER SocioWeb FOR LOGIN SocioWeb;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Presidente')
    CREATE USER Presidente FOR LOGIN Presidente;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vicepresidente')
    CREATE USER Vicepresidente FOR LOGIN Vicepresidente;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Secretario')
    CREATE USER Secretario FOR LOGIN Secretario;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vocales')
    CREATE USER Vocales FOR LOGIN Vocales;
GO


----------------------------------------------------------------------------------------------------------------
-- 3. ASIGNAR USUARIOS DE DESARROLLO
----------------------------------------------------------------------------------------------------------------
ALTER ROLE db_owner ADD MEMBER elian;
ALTER ROLE db_owner ADD MEMBER lucas;
ALTER ROLE db_owner ADD MEMBER matias;
GO

----------------------------------------------------------------------------------------------------------------
-- 4. CREACIÓN DE ROLES EN LA BASE 
----------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RJefe_Tesoreria' AND type = 'R')
    CREATE ROLE RJefe_Tesoreria;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RAdministrativo_Cobranza' AND type = 'R')
    CREATE ROLE RAdministrativo_Cobranza;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RAdministrativo_Morosidad' AND type = 'R')
    CREATE ROLE RAdministrativo_Morosidad;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RAdministrativo_Facturacion' AND type = 'R')
    CREATE ROLE RAdministrativo_Facturacion;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RAdministrativo_Socio' AND type = 'R')
    CREATE ROLE RAdministrativo_Socio;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RSocio_Web' AND type = 'R')
    CREATE ROLE RSocio_Web;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RPresidente' AND type = 'R')
    CREATE ROLE RPresidente;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RVicepresidente' AND type = 'R')
    CREATE ROLE RVicepresidente;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RSecretario' AND type = 'R')
    CREATE ROLE RSecretario;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RVocales' AND type = 'R')
    CREATE ROLE RVocales;
GO



----------------------------------------------------------------------------------------------------------------
-- 5. ASIGNACIÓN DE USUARIOS A ROLES
----------------------------------------------------------------------------------------------------------------
ALTER ROLE RJefe_Tesoreria ADD MEMBER JefeTesoreria;
GO

ALTER ROLE RAdministrativo_Cobranza ADD MEMBER AdministrativoCobranza;
GO

ALTER ROLE RAdministrativo_Morosidad ADD MEMBER AdministrativoMorosidad;
GO

ALTER ROLE RAdministrativo_Facturacion ADD MEMBER AdministrativoFacturacion;
GO

ALTER ROLE RAdministrativo_Socio ADD MEMBER AdministrativoSocio;
GO

ALTER ROLE RSocio_Web ADD MEMBER SocioWeb;
GO

ALTER ROLE RPresidente ADD MEMBER Presidente;
GO

ALTER ROLE RVicepresidente ADD MEMBER Vicepresidente;
GO

ALTER ROLE RSecretario ADD MEMBER Secretario;
GO

ALTER ROLE RVocales ADD MEMBER Vocales;
GO


----------------------------------------------------------------------------------------------------------------
-- 6. ASIGNACIÓN DE PERMISOS A CADA ROL
----------------------------------------------------------------------------------------------------------------

GRANT EXECUTE ON SCHEMA::Finanzas TO RJefe_Tesoreria;
GRANT SELECT  ON SCHEMA::Finanzas TO RJefe_Tesoreria;

GRANT EXECUTE ON SCHEMA::Finanzas TO RAdministrativo_Cobranza;
GRANT EXECUTE ON SCHEMA::Finanzas TO RAdministrativo_Morosidad;
GRANT EXECUTE ON SCHEMA::Finanzas TO RAdministrativo_Facturacion;
GRANT EXECUTE ON SCHEMA::Persona  TO RAdministrativo_Socio;

GRANT EXECUTE ON OBJECT::Actividad.insertarReserva TO RSocio_Web;

GRANT EXECUTE ON SCHEMA::Finanzas  TO RPresidente;
GRANT EXECUTE ON SCHEMA::Club      TO RPresidente;
GRANT EXECUTE ON SCHEMA::Persona   TO RPresidente;
GRANT EXECUTE ON SCHEMA::Actividad TO RPresidente;
GRANT EXECUTE ON SCHEMA::Rep       TO RPresidente;

GRANT EXECUTE ON SCHEMA::Finanzas  TO RVicepresidente;
GRANT EXECUTE ON SCHEMA::Club      TO RVicepresidente;
GRANT EXECUTE ON SCHEMA::Persona   TO RVicepresidente;
GRANT EXECUTE ON SCHEMA::Actividad TO RVicepresidente;
GRANT EXECUTE ON SCHEMA::Rep       TO RVicepresidente;

GRANT EXECUTE ON SCHEMA::Club      TO RSecretario;
GRANT EXECUTE ON SCHEMA::Persona   TO RSecretario;
GRANT EXECUTE ON SCHEMA::Actividad TO RSecretario;
GRANT EXECUTE ON SCHEMA::Rep       TO RSecretario;



----------------------------------------------------------------------------------------------------------------
-- 7. BLOQUEO DE OTROS ESQUEMAS
----------------------------------------------------------------------------------------------------------------
-- DENY EXECUTE ON SCHEMA::Persona      TO RJefeTesoreria;
-- DENY EXECUTE ON SCHEMA::Actividad    TO RJefeTesoreria;
-- DENY EXECUTE ON SCHEMA::Club         TO RJefeTesoreria;
-- DENY EXECUTE ON SCHEMA::Rep          TO RJefeTesoreria;
