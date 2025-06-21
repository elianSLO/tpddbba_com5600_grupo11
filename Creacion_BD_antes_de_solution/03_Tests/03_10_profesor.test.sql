Use Com5600G11
GO

--- CASO 3: TABLA PROFESOR

-- 3.1 INSERCION EN LA TABLA PROFESOR

-- Asegúrate de que la tabla psn.Profesor existe antes de ejecutar las pruebas

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- 3.1.1. Inserción exitosa
EXEC stp.insertarProfesor 
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @email = 'juan.perez@email.com',
    @tel = '9876114321';

-- 3.1.2. DNI duplicado
EXEC stp.insertarProfesor 
    @dni = '12345678',
    @nombre = 'Carlos',
    @apellido = 'Ramírez',
    @email = 'carlos.ramirez@email.com',
    @tel = '12345678';

-- 3.1.3. DNI inválido (menos de 8 caracteres)
EXEC stp.insertarProfesor 
    @dni = '12345',
    @nombre = 'Ana',
    @apellido = 'López',
    @email = 'ana.lopez@email.com',
    @tel = '987654321';

-- 3.1.4. Email inválido
EXEC stp.insertarProfesor 
    @dni = '87654321',
    @nombre = 'Lucía',
    @apellido = 'Gómez',
    @email = 'lucia#correo',
    @tel = '987654321';

-- 3.1.5. Teléfono con caracteres no numéricos
EXEC stp.insertarProfesor 
    @dni = '23456789',
    @nombre = 'Mario',
    @apellido = 'Torres',
    @email = 'mario.torres@email.com',
    @tel = '9876ABCD';

-- 6. Teléfono demasiado corto
EXEC stp.insertarProfesor 
    @dni = '34567890',
    @nombre = 'Laura',
    @apellido = 'Martínez',
    @email = 'laura.martinez@email.com',
    @tel = '123456';

-- 7. Campo NULL
EXEC stp.insertarProfesor 
    @dni = NULL,
    @nombre = 'Pedro',
    @apellido = 'Jiménez',
    @email = 'pedro.jimenez@email.com',
    @tel = '12345678';

-- Verifica los registros insertados

SELECT * FROM psn.Profesor;


----- CASO 3.2 MODIFICACION DE TABLA PROFESOR

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- CREAR UN PROFESOR BASE PARA MODIFICACIONES
EXEC stp.insertarProfesor
    @dni = '87654322',
    @nombre = 'Juan',
    @apellido = 'Perez',
    @email = 'juan.perez@correo.com',
    @tel = '1134667890';

-- CASO 3.2.1: Modificación válida

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654321',
    @nombre = 'Carlos',
    @apellido = 'Ramirez',
    @email = 'carlos.ramirez@correo.com',
    @tel = '1134567890';

-- CASO 3.2.2: Profesor no existente (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 999,
    @dni = '12345678',
    @nombre = 'Roberto',
    @apellido = 'García',
    @email = 'roberto.garcia@correo.com',
    @tel = '1122334455';

-- CASO 3.2.3: DNI inválido (menos de 8 dígitos, debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '1234567', -- 7 dígitos
    @nombre = 'Laura',
    @apellido = 'Martinez',
    @email = 'laura.martinez@correo.com',
    @tel = '1134567891';

-- CASO 3.2.4: Nombre con caracteres inválidos (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654322',
    @nombre = 'An@',
    @apellido = 'Ramirez',
    @email = 'ana.ramirez@correo.com',
    @tel = '1134567892';

-- CASO 3.2.5: Apellido con números (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654323',
    @nombre = 'Lucía',
    @apellido = 'Rami2ez',
    @email = 'lucia.ramirez@correo.com',
    @tel = '1134567893';

-- CASO 3.2.6: Email inválido (sin arroba, debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654324',
    @nombre = 'Diego',
    @apellido = 'Sosa',
    @email = 'diego.sosaemail.com', -- inválido
    @tel = '1134567894';

-- CASO 3.2.7: Teléfono con letras (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654325',
    @nombre = 'Paula',
    @apellido = 'Fernández',
    @email = 'paula.fernandez@correo.com',
    @tel = '11345ABCD'; -- inválido

-- CASO 3.2.8: Teléfono muy corto (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = '87654326',
    @nombre = 'Martín',
    @apellido = 'López',
    @email = 'martin.lopez@correo.com',
    @tel = '123456'; -- menos de 10 dígitos

-- CASO 3.2.9: Campo obligatorio NULL (debe fallar)

EXEC stp.modificarProfesor
    @cod_prof = 1,
    @dni = NULL, -- campo nulo
    @nombre = 'Verónica',
    @apellido = 'Suárez',
    @email = 'veronica.suarez@correo.com',
    @tel = '1134567895';

-- CONSULTA FINAL: Ver estado del profesor base

SELECT * FROM psn.Profesor WHERE cod_prof = 1;

---------------- CASO 3.3 BORRADO DE TABLA PROFESOR

-- Limpiar la tabla para pruebas (solo si es seguro)
DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

-- Insertar profesor para borrar

EXEC stp.insertarProfesor
	@dni = '99887236',
	@nombre = 'Laura',
	@apellido = 'Martínez',
	@email = 'laura.martinez@email.com',
	@tel = '1123456789'

-- Verificar inserción correcta

SELECT * FROM psn.Profesor

-- CASO 3.3.1: Borrado de socio existente

EXEC stp.borrarProfesor @cod_prof = 1;

-- Verificar que se borró

SELECT * FROM psn.Profesor WHERE cod_prof = 1;

-- CASO 3.3.2: Borrado de socio inexistente

EXEC stp.borrarProfesor @cod_prof = 9999;
