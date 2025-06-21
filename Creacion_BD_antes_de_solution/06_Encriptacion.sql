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


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Com5600G11.psn.Empleado') AND type = N'U')
	BEGIN
		CREATE TABLE psn.Empleado (
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

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'nombre_enc')
    ALTER TABLE psn.Empleado ADD nombre_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'apellido_enc')
    ALTER TABLE psn.Empleado ADD apellido_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'dni_enc')
    ALTER TABLE psn.Empleado ADD dni_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'direccion_enc')
    ALTER TABLE psn.Empleado ADD direccion_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'cuil_enc')
    ALTER TABLE psn.Empleado ADD cuil_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'email_personal_enc')
    ALTER TABLE psn.Empleado ADD email_personal_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'email_empresarial_enc')
    ALTER TABLE psn.Empleado ADD email_empresarial_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'turno_enc')
    ALTER TABLE psn.Empleado ADD turno_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'rol_enc')
    ALTER TABLE psn.Empleado ADD rol_enc VARBINARY(MAX);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'psn' AND TABLE_NAME = 'Empleado' AND COLUMN_NAME = 'area_enc')
    ALTER TABLE psn.Empleado ADD area_enc VARBINARY(MAX);

GO

--TRIGGER PARA QUE CADA VEZ QUE SE INGRESA UN REGISTRO A LA TABLA, LOS DATOS SENSIBLES SEAN ENCRIPTADOS (SE ENCUENTRA DESACTIVADO)
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name='trg_Empleado_Encrypt')
    DROP TRIGGER psn.trg_Empleado_Encrypt;
GO
CREATE TRIGGER psn.trg_Empleado_Encrypt
ON psn.Empleado 
AFTER INSERT
AS
BEGIN
		-- Encriptar y actualizar las columnas encriptadas
		UPDATE e
		SET 
			e.nombre_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.nombre),
			e.apellido_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.apellido),
			e.dni_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', CAST(i.dni AS VARCHAR)),
			e.direccion_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.direccion),
			e.cuil_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.cuil),
			e.email_personal_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.email_personal),
			e.email_empresarial_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.email_empresarial),
			e.turno_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.turno),
			e.rol_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.rol),
			e.area_enc = ENCRYPTBYPASSPHRASE('Xg7#pV@1zK$9mTqW', i.area)
			
		FROM psn.Empleado e
		INNER JOIN inserted i ON e.id_empleado = i.id_empleado;

		-- Eliminar los datos visibles o ponerlos en NULL (si no se van a necesitar)
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
		FROM psn.Empleado e
		INNER JOIN inserted i ON e.id_empleado = i.id_empleado;
END;
PRINT 'TRIGGER CREADO CORRECTAMENTE';
GO


-- PRUEBAS

DELETE FROM psn.Empleado

INSERT INTO psn.Empleado (
	id_empleado, nombre, apellido, dni, direccion, cuil, 
	email_personal, email_empresarial, turno, rol, area
)
VALUES (
	1, 'Juan', 'Pérez', 30123456, 'Av. Siempre Viva 742', '20-30123456-3',
	'juan.perez@gmail.com', 'jperez@solnorte.com', 'Mañana', 'Tesorería', 'Jefe de Tesorería'
);

select * FROM psn.Empleado