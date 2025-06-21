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


--	Se crean los usuarios para los desarrolladores.
--IF NOT EXISTS(SELECT * FROM sys.sql_logins)
CREATE LOGIN elian
WITH PASSWORD = 'elian', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;
GO

CREATE LOGIN lucas
WITH PASSWORD = 'lucas', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;
GO

CREATE LOGIN matias
WITH PASSWORD = 'matias', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;
GO

create user elian for LOGIN elian
create user lucas for LOGIN lucas
create user matias for LOGIN matias
GO

alter role db_owner add member elian
alter role db_owner add member lucas
alter role db_owner add member matias
go

select name from sys.sql_logins			--	Ver los usuarios.


