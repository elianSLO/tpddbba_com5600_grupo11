SELECT name, state_desc 
FROM sys.databases;

use Com5600G11
go
CREATE LOGIN usuario_test
WITH PASSWORD = '1234', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;

CREATE LOGIN elian
WITH PASSWORD = 'elian', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;

CREATE LOGIN lucas
WITH PASSWORD = 'lucas', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;

CREATE LOGIN matias
WITH PASSWORD = 'matias', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;

CREATE LOGIN josue
WITH PASSWORD = 'josue', DEFAULT_DATABASE = Com5600G11,
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF ;

--create user usuario_test for LOGIN usuario_test
create user elian for LOGIN elian
create user lucas for LOGIN lucas
create user matias for LOGIN matias
create user josue for LOGIN josue

alter role db_owner add member elian
alter role db_owner add member lucas
alter role db_owner add member matias
alter role db_owner add member josue

select role from sys

select name from sys.sql_logins