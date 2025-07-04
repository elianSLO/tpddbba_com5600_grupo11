/*
====================================================================================
 Archivo		: 01_Encriptacion.sql
 Proyecto		: Institución Deportiva Sol Norte.
 Descripción	: Scripts para protección de datos sensibles de los empleados registrados en la base de datos.
 Autor			: COM5600_G11
 Fecha entrega	: 2025-06-20
 Versión		: 1.0
====================================================================================
*/


USE Com5600G11
GO

-- CREO TABLA EMPLEADO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.Persona.Empleado') AND type = N'U')
	BEGIN
		CREATE TABLE Persona.Empleado (
			id_empleado INT PRIMARY KEY,
			nombre VARCHAR(100),
			apellido VARCHAR(100),
			dni INT,
			direccion VARCHAR(255),
			cuil VARCHAR(200),
			email_personal VARCHAR(255),
			email_empresarial VARCHAR(255),
			turno VARCHAR(50),
			rol VARCHAR(50),
			area VARCHAR(50)
		);
		PRINT 'Tabla Empleado creada correctamente.';
	END
ELSE
	BEGIN
		PRINT 'La tabla Empleado ya existe.';
	END;
go


--TRIGGER DE ENCRIPTACION
------------------------------------------------------------------------------------------------------------------------------------------------
--AGREGAR CAMPOS PARA ENCRIPTAR

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'nombre_enc')
    ALTER TABLE Persona.Empleado ADD nombre_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'apellido_enc')
    ALTER TABLE Persona.Empleado ADD apellido_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'dni_enc')
    ALTER TABLE Persona.Empleado ADD dni_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'direccion_enc')
    ALTER TABLE Persona.Empleado ADD direccion_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'cuil_enc')
    ALTER TABLE Persona.Empleado ADD cuil_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'email_personal_enc')
    ALTER TABLE Persona.Empleado ADD email_personal_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'email_empresarial_enc')
    ALTER TABLE Persona.Empleado ADD email_empresarial_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'turno_enc')
    ALTER TABLE Persona.Empleado ADD turno_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'rol_enc')
    ALTER TABLE Persona.Empleado ADD rol_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'Persona' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'area_enc')
    ALTER TABLE Persona.Empleado ADD area_enc VARBINARY(MAX);

GO

--TRIGGER PARA QUE CADA VEZ QUE SE INGRESA UN REGISTRO A LA TABLA, LOS DATOS SENSIBLES SEAN ENCRIPTADOS (SE ENCUENTRA DESACTIVADO)
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name='trg_Empleado_Encrypt')
    DROP TRIGGER Persona.trg_Empleado_Encrypt;
GO
CREATE TRIGGER Persona.trg_Empleado_Encrypt
ON Persona.Empleado 
AFTER INSERT
AS
BEGIN
    DECLARE @passphrase NVARCHAR(100) = 'Xg7#pV@1zK$9mTqW';

    -- Encriptar y actualizar las columnas encriptadas
    UPDATE e
    SET 
        e.nombre_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.nombre),
        e.apellido_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.apellido),
        e.dni_enc = ENCRYPTBYPASSPHRASE(@passphrase, CAST(i.dni AS VARCHAR)),
        e.direccion_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.direccion),
        e.cuil_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.cuil),
        e.email_personal_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.email_personal),
        e.email_empresarial_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.email_empresarial),
        e.turno_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.turno),
        e.rol_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.rol),
        e.area_enc = ENCRYPTBYPASSPHRASE(@passphrase, i.area)
    FROM Persona.Empleado e
    INNER JOIN inserted i ON e.id_empleado = i.id_empleado;

    -- Eliminar los datos visibles
    UPDATE e
    SET 
        e.nombre = NULL,
        e.apellido = NULL,
        e.dni = NULL,
        e.direccion = NULL,
        e.cuil = NULL,
        e.email_personal = NULL,
        e.email_empresarial = NULL,
        e.turno = NULL,
        e.rol = NULL,
        e.area = NULL 
    FROM Persona.Empleado e
    INNER JOIN inserted i ON e.id_empleado = i.id_empleado;
END;
GO



-- PRUEBAS

DELETE FROM Persona.Empleado

INSERT INTO Persona.Empleado (
	id_empleado, nombre, apellido, dni, direccion, cuil, 
	email_personal, email_empresarial, turno, rol, area
)
VALUES (
	1, 'Juan', 'Pérez', 30123456, 'Av. Siempre Viva 742', '20-30123456-3',
	'juan.perez@gmail.com', 'jperez@solnorte.com', 'Mañana', 'Tesorería', 'Jefe de Tesorería'
);

select * FROM Persona.Empleado

-- Desencriptar

DECLARE @passphrase NVARCHAR(100) = 'Xg7#pV@1zK$9mTqW';

SELECT
    CAST(DECRYPTBYPASSPHRASE(@passphrase, nombre_enc) AS VARCHAR(100)) AS nombre_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, apellido_enc) AS VARCHAR(100)) AS apellido_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, dni_enc) AS INT) AS dni_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, direccion_enc) AS VARCHAR(255)) AS direccion_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, cuil_enc) AS VARCHAR(200)) AS cuil_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, email_personal_enc) AS VARCHAR(255)) AS email_personal_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, email_empresarial_enc) AS VARCHAR(255)) AS email_empresarial_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, turno_enc) AS VARCHAR(50)) AS turno_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, rol_enc) AS VARCHAR(50)) AS rol_desenc,
    CAST(DECRYPTBYPASSPHRASE(@passphrase, area_enc) AS VARCHAR(50)) AS area_desenc
FROM
    Persona.Empleado;
GO