/*	Chequear estado de la base de datos.
SELECT name, state_desc 
FROM sys.databases;
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


SELECT
    session_id,
    login_name,
    status,
    host_name,
    program_name,
    login_time,
    last_request_start_time,
    last_request_end_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;
