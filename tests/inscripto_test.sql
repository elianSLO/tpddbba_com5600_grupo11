-- PRUEBAS DE STORED PROCEDURES PARA TABLA INSCRIPTO

USE Com5600G11;
GO

--- Se insertan los datos previos requeridos

-- Tabla Socio

DELETE FROM psn.Socio 

 INSERT INTO psn.Socio (cod_socio, dni, nombre, apellido, fecha_nac, email, tel, tel_emerg, estado, saldo) VALUES
 ('SN-00001', '12345678', 'Juan', 'P�rez', '1990-05-15', 'juan.perez@mail.com', '1122334455', '1133445566', 1, 0),
 ('SN-00002', '23456789', 'Mar�a', 'G�mez', '1995-08-22', 'maria.gomez@mail.com', '1144556677', '1166778899', 1, 0),
 ('SN-00003', '34567890', 'Lucas', 'Fern�ndez', '2002-03-10', 'lucas.fernandez@mail.com', '1155667788', '1177889900', 1, 0);

 -- Tabla Actividad
 DELETE FROM psn.Actividad
 DBCC CHECKIDENT ('psn.Actividad', RESEED, 0);

 INSERT INTO psn.Actividad (nombre, valor_mensual, vig_valor) VALUES
('Futsal', 25000, '2025-12-31'),
('V�ley', 30000, '2025-12-31'),
('Taekwondo', 25000, '2025-12-31'),
('Baile art�stico', 30000, '2025-12-31'),
('Nataci�n', 45000, '2025-12-31'),
('Ajedrez', 2000, '2025-12-31');

-- Tabla Profesor

DELETE FROM psn.Profesor
DBCC CHECKIDENT ('psn.Profesor', RESEED, 0);

INSERT INTO psn.Profesor (dni, nombre, apellido, email, tel)
VALUES 
    ('12345678', 'Ana', 'Garc�a', 'ana.garcia@mail.com', '1134567890'),
    ('23456789', 'Luis', 'Mart�nez', 'luis.martinez@mail.com', '11 2345 6789'),
    ('34567890', 'Mar�a', 'L�pez', 'maria.lopez@mail.com', '11-9876-5432');


-- Tabla Clase

DELETE FROM psn.Clase
DBCC CHECKIDENT ('psn.Clase', RESEED, 0);

INSERT INTO psn.Clase (categoria, cod_actividad, cod_prof, dia, horario)
VALUES 
    (1, 1, 1, 'Lunes', '18:00'),       -- Ejemplo: Mayor, Futsal, Prof. 3
    (2, 2, 2, 'Miercoles', '17:30'),   -- Ejemplo: Cadete, V�ley, Prof. 2
    (3, 3, 3, 'Viernes', '19:15');     -- Ejemplo: Menor, Taekwondo, Prof. 1

-- Limpio tabla Inscripto
DELETE FROM psn.Inscripto

----------------------------------------------------------------- PRUEBAS PARA insertarInscripto

--- CASO 1: Inserci�n v�lida 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-01',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
-- Esperado: Inserci�n exitosa

--- CASO 2: Repetici�n exacta (mismo socio, clase y fecha) 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-01',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;
-- Esperado: Error por duplicado

--- CASO 3: Fecha futura 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-12-01',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
-- Esperado: Error por fecha futura

--- CASO 4: Estado vac�o 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-02',
    @estado = '',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
-- Esperado: Error por estado vac�o

--- CASO 5: C�digo de socio con formato inv�lido 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-02',
    @estado = 'Inscripto',
    @cod_socio = 'SOC-00002',
    @cod_clase = 2;
-- Esperado: Error por formato incorrecto de c�digo de socio

--- CASO 6: C�digo de clase inv�lido (cero) 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-03',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00003',
    @cod_clase = 0;
-- Esperado: Error por c�digo de clase inv�lido

--- CASO 7: Inserci�n v�lida distinta (otro socio y clase) 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-03',
    @estado = 'No Inscripto',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;
-- Esperado: Inserci�n exitosa

--- CASO 8: Inserci�n v�lida para mismo socio pero distinta clase 
EXEC stp.insertarInscripto 
    @fecha_inscripcion = '2025-06-03',
    @estado = 'Inscripto',
    @cod_socio = 'SN-00001',
    @cod_clase = 3;
-- Esperado: Inserci�n exitosa

-- Verificacion final
SELECT * FROM psn.Inscripto

----------------------------------------------------------------- PRUEBAS PARA modificarInscripto

DELETE FROM psn.Inscripto;

INSERT INTO psn.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES
    ('2025-06-01', 'Inscripto', 'SN-00001', 1),
    ('2025-06-02', 'Inscripto', 'SN-00002', 2),
    ('2025-06-03', 'No Inscripto', 'SN-00003', 3);


--- CASO 1: Modificaci�n v�lida de estado y fecha 
EXEC stp.modificarInscripto
    @fecha_original     = '2025-06-01',
    @cod_socio_original = 'SN-00001',
    @cod_clase_original = 1,
    @nueva_fecha        = '2025-06-10',
    @nuevo_estado       = 'No Inscripto',
    @nuevo_cod_socio    = 'SN-00001',
    @nuevo_cod_clase    = 1;

--- CASO 2: Registro original no existe 
EXEC stp.modificarInscripto
    @fecha_original     = '2025-01-01',
    @cod_socio_original = 'SN-99999',
    @cod_clase_original = 5,
    @nueva_fecha        = '2025-06-11',
    @nuevo_estado       = 'Inscripto',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;

--- CASO 3: Nueva fecha futura 
EXEC stp.modificarInscripto
    @fecha_original     = '2025-06-02',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2026-01-01',
    @nuevo_estado       = 'Inscripto',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;

--- CASO 4: Estado inv�lido 
EXEC stp.modificarInscripto
    @fecha_original     = '2025-06-03',
    @cod_socio_original = 'SN-00003',
    @cod_clase_original = 3,
    @nueva_fecha        = '2025-06-05',
    @nuevo_estado       = 'Activo',  -- <- Inv�lido
    @nuevo_cod_socio    = 'SN-00003',
    @nuevo_cod_clase    = 3;

--- CASO 5: Duplicado con nuevos datos existentes 
EXEC stp.modificarInscripto
    @fecha_original     = '2025-06-03',
    @cod_socio_original = 'SN-00003',
    @cod_clase_original = 3,
    @nueva_fecha        = '2025-06-02',
    @nuevo_estado       = 'Inscripto',
    @nuevo_cod_socio    = 'SN-00002',
    @nuevo_cod_clase    = 2;

--- CASO 6: Modificaci�n completa v�lida 
EXEC stp.modificarInscripto
    @fecha_original     = '2025-06-02',
    @cod_socio_original = 'SN-00002',
    @cod_clase_original = 2,
    @nueva_fecha        = '2025-06-06',
    @nuevo_estado       = 'No Inscripto',
    @nuevo_cod_socio    = 'SN-00003',
    @nuevo_cod_clase    = 3;

-- Verificaci�n final
SELECT * FROM psn.Inscripto;


---------------------------------------------------------- PRUEBAS PARA borrarInscripto

-- Reinsertamos datos de prueba para asegurar el contexto
DELETE FROM psn.Inscripto;

INSERT INTO psn.Inscripto (fecha_inscripcion, estado, cod_socio, cod_clase)
VALUES
    ('2025-06-01', 'Inscripto', 'SN-00001', 1),
    ('2025-06-02', 'Inscripto', 'SN-00002', 2),
    ('2025-06-03', 'No Inscripto', 'SN-00003', 3);

--- CASO 1: Eliminaci�n exitosa 
EXEC stp.borrarInscripto
    @fecha_inscripcion = '2025-06-01',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;

--- CASO 2: Intento de borrar inscripci�n que ya no existe 
EXEC stp.borrarInscripto
    @fecha_inscripcion = '2025-06-01',
    @cod_socio = 'SN-00001',
    @cod_clase = 1;

--- CASO 3: C�digo de socio inv�lido 
EXEC stp.borrarInscripto
    @fecha_inscripcion = '2025-06-02',
    @cod_socio = 'SN-99999',
    @cod_clase = 2;

--- CASO 4: Eliminaci�n con fecha incorrecta 
EXEC stp.borrarInscripto
    @fecha_inscripcion = '2024-01-01',
    @cod_socio = 'SN-00002',
    @cod_clase = 2;

--- CASO 5: Eliminaci�n correcta de inscripci�n restante 
EXEC stp.borrarInscripto
    @fecha_inscripcion = '2025-06-03',
    @cod_socio = 'SN-00003',
    @cod_clase = 3;

-- Verificaci�n final
--- Registros restantes en psn.Inscripto (Solamente queda inscripto el socio SN-00002) 
SELECT * FROM psn.Inscripto;




