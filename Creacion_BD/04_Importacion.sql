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

EXEC sp_configure 'show advanced options', 1;  
RECONFIGURE;  
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;  
RECONFIGURE;  

EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;

exec imp.Importar_Pagos 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';

SELECT servicename, service_account 
FROM sys.dm_server_services;




IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Pagos') 
BEGIN
    DROP PROCEDURE imp.Importar_Pagos;
    PRINT 'SP Importar_Pagos ya existe --> se borró';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Pagos
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        cod_pago BIGINT,
        fecha_pago DATE,
        responsable_pago VARCHAR(15),
        monto DECIMAL(10,2),
        medio_pago VARCHAR(15)
    );

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    INSERT INTO ##Temp (cod_pago, fecha_pago, responsable_pago, monto, medio_pago)
    SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
        ''SELECT [Id de pago], [fecha], [Responsable de pago], [Valor], [Medio de pago] FROM [pago cuotas$]''
    )';

    EXEC sp_executesql @SQL;
    PRINT 'Datos cargados en ##Temp.';

    DECLARE @cod_pago BIGINT,
            @fecha_pago DATE,
            @responsable_pago VARCHAR(15),
            @monto DECIMAL(10,2),
            @medio_pago VARCHAR(15);

    DECLARE cur CURSOR LOCAL FOR
    SELECT cod_pago, fecha_pago, responsable_pago, monto, medio_pago
    FROM ##Temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable_pago, @monto, @medio_pago;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Solo insertar si no existe
        IF NOT EXISTS (SELECT 1 FROM psn.Pago p WHERE p.cod_pago = @cod_pago)
        BEGIN
            EXEC stp.insertarPago 
                @monto = @monto,
                @fecha_pago = @fecha_pago,
                @estado = 'Pagado',  -- o 'REALIZADO' si quieres, pero stp espera 'Pagado', 'Pendiente' o 'Anulado'
                @responsable_pago = @responsable_pago;
        END

        FETCH NEXT FROM cur INTO @cod_pago, @fecha_pago, @responsable_pago, @monto, @medio_pago;
    END

    CLOSE cur;
    DEALLOCATE cur;

    DROP TABLE ##Temp;
    PRINT '##Temp eliminada.';
    PRINT 'Importación completada correctamente.';
END;
GO

exec imp.Importar_Socios 'D:\repos\tpddbba_com5600_grupo11\Creacion_BD\import\Datos socios.xlsx';

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'Importar_Socios') 
BEGIN
    DROP PROCEDURE imp.Importar_Socios;
    PRINT 'SP Importar_Socios ya existe --> se borró';
END;
GO

CREATE OR ALTER PROCEDURE imp.Importar_Socios
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Temp') IS NOT NULL
        DROP TABLE ##Temp;

    CREATE TABLE ##Temp
    (
        cod_socio          VARCHAR(15) PRIMARY KEY CHECK (cod_socio LIKE 'SN-[0-9][0-9][0-9][0-9][0-9]'),
        dni                CHAR(8) UNIQUE,
        nombre             VARCHAR(50),
        apellido           VARCHAR(50),
        fecha_nac          DATE,
        email              VARCHAR(100),
        tel                VARCHAR(15) CHECK (tel NOT LIKE '%[^0-9]%' AND LEN(tel) BETWEEN 10 AND 14),
        tel_emerg          VARCHAR(15) CHECK (tel_emerg NOT LIKE '%[^0-9]%' AND LEN(tel_emerg) BETWEEN 10 AND 14),
        nombre_cobertura   VARCHAR(50),
        nro_afiliado       VARCHAR(50),
        tel_cobertura      VARCHAR(15) CHECK (tel_cobertura NOT LIKE '%[^0-9]%' AND LEN(tel_cobertura) BETWEEN 10 AND 14)
    );

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    INSERT INTO ##Temp (cod_socio, nombre, apellido, dni, email, fecha_nac, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura)
    SELECT [Nro de Socio], [Nombre], [apellido], [DNI], [email personal], [fecha de nacimiento], [teléfono de contacto], 
           [teléfono de contacto emergencia], [Nombre de la obra social o prepaga], [nro. de socio obra social/prepaga ], 
           [teléfono de contacto de emergencia ]
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;Database=' + @RutaArchivo + ''',
        ''SELECT [Nro de Socio], [Nombre], [apellido], [DNI], [email personal], [fecha de nacimiento], 
                 [teléfono de contacto], [teléfono de contacto emergencia], [Nombre de la obra social o prepaga], 
                 [nro. de socio obra social/prepaga ], [teléfono de contacto de emergencia ] FROM [Responsables de Pago$]''
    )';

    EXEC sp_executesql @SQL;
    PRINT 'Datos cargados en ##Temp.';

    DECLARE
        @cod_socio        VARCHAR(15),
        @dni              CHAR(8),
        @nombre           VARCHAR(50),
        @apellido         VARCHAR(50),
        @fecha_nac        DATE,
        @email            VARCHAR(100),
        @tel              VARCHAR(15),
        @tel_emerg        VARCHAR(15),
        @nombre_cobertura VARCHAR(50),
        @nro_afiliado     VARCHAR(50),
        @tel_cobertura    VARCHAR(15);

    DECLARE cur CURSOR LOCAL FOR
    SELECT cod_socio, dni, nombre, apellido, fecha_nac, email, tel, tel_emerg, nombre_cobertura, nro_afiliado, tel_cobertura
    FROM ##Temp;

    OPEN cur;

    FETCH NEXT FROM cur INTO @cod_socio, @dni, @nombre, @apellido, @fecha_nac, @email, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificamos que no exista el socio
        IF NOT EXISTS (SELECT 1 FROM psn.Socio s WHERE s.cod_socio = @cod_socio)
        BEGIN
            EXEC stp.insertarSocio 
                @cod_socio, 
                @nombre, 
                @apellido, 
                @dni, 
                @email,
                @fecha_nac,
                @tel,
                @tel_emerg,
                @nombre_cobertura,
                @nro_afiliado,
                @tel_cobertura;
        END

        FETCH NEXT FROM cur INTO @cod_socio, @dni, @nombre, @apellido, @fecha_nac, @email, @tel, @tel_emerg, @nombre_cobertura, @nro_afiliado, @tel_cobertura;
    END

    CLOSE cur;
    DEALLOCATE cur;

    DROP TABLE ##Temp;
    PRINT '##Temp eliminada.';
    PRINT 'Importación completada correctamente.';
END;
GO
