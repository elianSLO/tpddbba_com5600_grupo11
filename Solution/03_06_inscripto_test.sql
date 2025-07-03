-- PRUEBAS DE STORED PROCEDURES PARA TABLA INSCRIPTO

USE Com5600G11;
GO

--- Se insertan los datos previos requeridos

-- Tabla Socio

DELETE FROM Actividad.Inscripto
DELETE FROM Actividad.Clase
DELETE FROM Persona.Socio 
DELETE FROM Persona.Profesor
DELETE FROM Finanzas.Factura
DELETE FROM Club.Actividad


DBCC CHECKIDENT ('Finanzas.Factura', RESEED, 0);
DBCC CHECKIDENT ('Persona.Profesor', RESEED, 0);
DBCC CHECKIDENT ('Club.Actividad', RESEED, 0);
DBCC CHECKIDENT ('Actividad.Clase', RESEED, 0);

 INSERT INTO Persona.Socio (cod_socio, dni, nombre, apellido, fecha_nac, email, tel, tel_emerg, estado, saldo) VALUES
 ('SN-00001', '12345678', 'Juan', 'Pérez', '1990-05-15', 'juan.perez@mail.com', '1122334455', '1133445566', 1, 0),
 ('SN-00002', '23456789', 'María', 'Gómez', '1995-08-22', 'maria.gomez@mail.com', '1144556677', '1166778899', 1, 0),
 ('SN-00003', '34567890', 'Lucas', 'Fernández', '2002-03-10', 'lucas.fernandez@mail.com', '1155667788', '1177889900', 1, 0);

 -- Tabla Actividad
 

 INSERT INTO Club.Actividad (nombre, valor_mensual, vig_valor) VALUES
('Futsal', 25000, '2025-12-31'),
('Vóley', 30000, '2025-12-31'),
('Taekwondo', 25000, '2025-12-31'),
('Baile artístico', 30000, '2025-12-31'),
('Natación', 45000, '2025-12-31'),
('Ajedrez', 2000, '2025-12-31');

-- Tabla Profesor

INSERT INTO Persona.Profesor (dni, nombre, apellido, email, tel)
VALUES 
    ('12345678', 'Ana', 'García', 'ana.garcia@mail.com', '1134567890'),
    ('23456789', 'Luis', 'Martínez', 'luis.martinez@mail.com', '11 2345 6789'),
    ('34567890', 'María', 'López', 'maria.lopez@mail.com', '11-9876-5432');


-- Tabla Clase

INSERT INTO Actividad.Clase (categoria, cod_actividad, cod_prof, dia, horario)
VALUES 
    (1, 1, 1, 'Lunes', '18:00'),       -- Ejemplo: Mayor, Futsal, Prof. 3
    (2, 2, 2, 'Miercoles', '17:30'),   -- Ejemplo: Cadete, Vóley, Prof. 2
    (3, 3, 3, 'Viernes', '19:15');     -- Ejemplo: Menor, Taekwondo, Prof. 1

----------------------------------------------------------------- PRUEBAS PARA insertarInscripto

--- CASO 1: Inserción válida 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-01',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
-- Esperado: Inserción exitosa

--- CASO 2: Repetición exacta (mismo socio, clase y fecha) 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-01',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
-- Esperado: Error por duplicado

--- CASO 3: Fecha futura 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-12-01',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
-- Esperado: Error por fecha futura

--- CASO 4: Estado vacío 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-02',
    @estado = '',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
-- Esperado: Error por estado vacío

--- CASO 5: Código de socio con formato inválido 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-02',
    @estado = 'Inscripto',
    @cod_socio = 'SOC-00002',
    @cod_clase = 2;
-- Esperado: Error por formato incorrecto de código de socio

--- CASO 6: Código de clase inválido (cero) 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-03',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00003',
    @cod_clase = 0;
-- Esperado: Error por código de clase inválido

--- CASO 7: Inserción válida distinta (otro socio y clase) 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-03',
    @estado = 'No Inscripto',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
-- Esperado: Inserción exitosa

--- CASO 8: Inserción válida para mismo socio pero distinta clase 
EXEC Actividad.insertarInscripto 
    @fecha_inscripcion = '2025-06-03',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00001',
    @cod_clase = 3;
-- Esperado: Inserción exitosa

-- Verificacion final
SELECT * FROM Actividad.Inscripto

----------------------------------------------------------------- PRUEBAS PARA modificarInscripto

DELETE FROM Actividad.Inscripto;

INSERT INTO Actividad.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES
    ('2025-06-01', 'Inscripto', 'SN-00001', 1),
    ('2025-06-02', 'Inscripto', 'SN-00002', 2),
    ('2025-06-03', 'No Inscripto', 'SN-00003', 3);


--- CASO 1: Modificación válida de estado y fecha 
EXEC Actividad.modificarInscripto
    @fecha_original     = '2025-06-01',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 1,
    @nueva_fecha        = '2025-06-10',
    @nuevo_estado       = 'No Inscripto',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_cod_clase    = 1;

--- CASO 2: Registro original no existe 
EXEC Actividad.modificarInscripto
    @fecha_original     = '2025-01-01',
    @cod_socio_original = 'SN-99999',
    @cod_clase_original = 5,
    @nueva_fecha        = '2025-06-11',
    @nuevo_estado       = 'Inscripto',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;

--- CASO 3: Nueva fecha futura 
EXEC Actividad.modificarInscripto
    @fecha_original     = '2025-06-02',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2026-01-01',
    @nuevo_estado       = 'Inscripto',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;

--- CASO 4: Estado inválido 
EXEC Actividad.modificarInscripto
    @fecha_original     = '2025-06-03',
    @cod_socio_original = 'SN-00003',
    @cod_clase_original = 3,
    @nueva_fecha        = '2025-06-05',
    @nuevo_estado       = NULL, 
    @nuevo_cod_socio    = 'SN-00003',
    @nuevo_cod_clase    = 3;

--- CASO 5: Duplicado con nuevos datos existentes 
EXEC Actividad.modificarInscripto
    @fecha_original     = '2025-06-03',
    @cod_socio_original = 'SN-00003',
    @cod_clase_original = 3,
    @nueva_fecha        = '2025-06-02',
    @nuevo_estado       = 'Inscripto',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;

--- CASO 6: Modificación completa válida 
EXEC Actividad.modificarInscripto
    @fecha_original     = '2025-06-02',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-06',
    @nuevo_estado       = 'No Inscripto',
    @nuevo_cod_socio    = 'SN-00003',
    @nuevo_cod_clase    = 3;


---------------------------------------------------------- PRUEBAS PARA borrarInscripto

-- Reinsertamos datos de prueba para asegurar el contexto
DELETE FROM Actividad.Inscripto;

INSERT INTO Actividad.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES
    ('2025-06-01', 'Inscripto', 'SN-00001', 1),
    ('2025-06-02', 'Inscripto', 'SN-00002', 2),
    ('2025-06-03', 'No Inscripto', 'SN-00003', 3);

--- CASO 1: Eliminación exitosa 
EXEC Actividad.borrarInscripto
    @fecha_inscripcion = '2025-06-01',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;

--- CASO 2: Intento de borrar inscripción que ya no existe 
EXEC Actividad.borrarInscripto
    @fecha_inscripcion = '2025-06-01',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;

--- CASO 3: Código de socio inválido 
EXEC Actividad.borrarInscripto
    @fecha_inscripcion = '2025-06-02',
    @cod_socio = 'SN-99999',
    @cod_clase = 2;

--- CASO 4: Eliminación con fecha incorrecta 
EXEC Actividad.borrarInscripto
    @fecha_inscripcion = '2024-01-01',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;

--- CASO 5: Eliminación correcta de inscripción restante 
EXEC Actividad.borrarInscripto
    @fecha_inscripcion = '2025-06-03',
    @cod_socio = 'SN-00003',
    @cod_clase = 3;

-- Verificación final
--- Registros restantes en Actividad.Inscripto (Solamente queda inscripto el socio SN-00002) 
SELECT * FROM Actividad.Inscripto;




