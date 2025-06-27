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
GRANT EXECUTE ON OBJECT::stp.insertarPago			TO Jefe_Tesoreria;
GRANT EXECUTE ON OBJECT::stp.modificarPago			TO Jefe_Tesoreria;
GRANT EXECUTE ON OBJECT::stp.borrarPago				TO Jefe_Tesoreria;
GRANT EXECUTE ON OBJECT::stp.insertarReembolso		TO Jefe_Tesoreria;
GRANT EXECUTE ON OBJECT::stp.modificarReembolso		TO Jefe_Tesoreria;
GRANT EXECUTE ON OBJECT::stp.borrarReembolso		TO Jefe_Tesoreria;


----------------------------------------------
-- ROL: Administrativo_Cobranza
----------------------------------------------
GRANT EXECUTE ON OBJECT::stp.insertarPago			TO Administrativo_Cobranza;
GRANT EXECUTE ON OBJECT::stp.modificarPago			TO Administrativo_Cobranza;
GRANT EXECUTE ON OBJECT::stp.insertarReembolso		TO Administrativo_Cobranza;
GRANT EXECUTE ON OBJECT::stp.modificarReembolso		TO Administrativo_Cobranza;


----------------------------------------------
-- ROL: Administrativo_Morosidad
----------------------------------------------
GRANT EXECUTE ON OBJECT::stp.emitirFactura			TO Administrativo_Morosidad;
GRANT EXECUTE ON OBJECT::stp.modificarFactura		TO Administrativo_Morosidad;

----------------------------------------------
-- ROL: Administrativo_Facturacion
----------------------------------------------
GRANT EXECUTE ON OBJECT::stp.emitirFactura			TO Administrativo_Facturacion;
GRANT EXECUTE ON OBJECT::stp.modificarFactura		TO Administrativo_Facturacion;
GRANT EXECUTE ON OBJECT::stp.borrarFactura			TO Administrativo_Facturacion;
GRANT EXECUTE ON OBJECT::stp.insertarItem_factura	TO Administrativo_Facturacion;
GRANT EXECUTE ON OBJECT::stp.modificarItem_factura	TO Administrativo_Facturacion;
GRANT EXECUTE ON OBJECT::stp.borrarItem_factura		TO Administrativo_Facturacion;

----------------------------------------------
-- ROL: Administrativo_Socio
----------------------------------------------
GRANT EXECUTE ON OBJECT::stp.insertarSocio			TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarSocio			TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.borrarSocio			TO Administrativo_Socio;

GRANT EXECUTE ON OBJECT::stp.insertarInvitado		TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarInvitado		TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.borrarInvitado			TO Administrativo_Socio;

GRANT EXECUTE ON OBJECT::stp.insertarSuscripcion	TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarSuscripcion	TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.borrarSuscripcion		TO Administrativo_Socio;

GRANT EXECUTE ON OBJECT::stp.insertarResponsable	TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarResponsable	TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.borrarResponsable		TO Administrativo_Socio;

GRANT EXECUTE ON OBJECT::stp.insertarCategoria		TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarCategoria		TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.borrarCategoria		TO Administrativo_Socio;

GRANT EXECUTE ON OBJECT::stp.insertarActividad		TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarActividad		TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.eliminarActividad		TO Administrativo_Socio;

----------------------------------------------
-- ROL: Socio_Web
----------------------------------------------
GRANT EXECUTE ON OBJECT::stp.insertarReserva		TO Socio_Web;

----------------------------------------------
-- ROL: Presidente
----------------------------------------------
GRANT EXECUTE ON SCHEMA::stp						TO Presidente;
GRANT EXECUTE ON SCHEMA::Rep						TO Presidente;

----------------------------------------------
-- ROL: Vicepresidente
----------------------------------------------
GRANT EXECUTE ON SCHEMA::stp						TO Vicepresidente;
GRANT EXECUTE ON SCHEMA::Rep						TO Vicepresidente;

----------------------------------------------
-- ROL: Secretario
----------------------------------------------
GRANT EXECUTE ON SCHEMA::Rep						TO Secretario;

GRANT EXECUTE ON OBJECT::stp.emitirFactura			TO Secretario;
GRANT EXECUTE ON OBJECT::stp.insertarItem_factura	TO Secretario;

GRANT EXECUTE ON OBJECT::stp.insertarSocio			TO Secretario;
GRANT EXECUTE ON OBJECT::stp.modificarSocio			TO Secretario;

GRANT EXECUTE ON OBJECT::stp.insertarInvitado		TO Secretario;
GRANT EXECUTE ON OBJECT::stp.modificarInvitado		TO Secretario;

GRANT EXECUTE ON OBJECT::stp.insertarResponsable	TO Administrativo_Socio;
GRANT EXECUTE ON OBJECT::stp.modificarResponsable	TO Administrativo_Socio;

GRANT EXECUTE ON OBJECT::stp.insertarCategoria		TO Secretario;
GRANT EXECUTE ON OBJECT::stp.modificarCategoria		TO Secretario;
GRANT EXECUTE ON OBJECT::stp.borrarCategoria		TO Secretario;

GRANT EXECUTE ON OBJECT::stp.insertarActividad		TO Secretario;
GRANT EXECUTE ON OBJECT::stp.modificarActividad		TO Secretario;
GRANT EXECUTE ON OBJECT::stp.eliminarActividad		TO Secretario;

----------------------------------------------
-- ROL: Vocales

----------------------------------------------






