Use Com5600G11
GO

-- 9. RESERVA

-- Limpiar la tabla psn.Reserva para pruebas
DELETE FROM psn.Reserva;
DBCC CHECKIDENT ('psn.Reserva', RESEED, 0);

-- Vaciar tablas y Preparar tablas
DELETE FROM psn.Socio;
DELETE FROM psn.Invitado;
-- responsable
EXEC stp.insertarInvitado
	@dni = '87654429',
    @cod_invitado = 'NS-0001',
	@nombre = 'Carlos',
	@apellido = 'Gutiérrez',
	@fecha_nac = '1980-10-15',
	@email = 'carlos.gutierrez@email.com',
	@tel = '1130000001',
	@tel_emerg = '1140000001',
	@estado = 1,
	@saldo = 300.00,
	@nombre_cobertura = 'OSDE',
	@nro_afiliado = 'X12345',
	@tel_cobertura = '1150000001',
	@cod_responsable = NULL;
EXEC stp.insertarSocio
    @cod_socio = 'SN-12345',
    @dni = '12345678',
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @fecha_nac = '1990-05-15',
    @email = 'juan@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL;
EXEC stp.insertarSocio
    @cod_socio = 'SN-56789',
    @dni = '12333378',
    @nombre = 'Maria',
    @apellido = 'Garcia',
    @fecha_nac = '1990-05-15',
    @email = 'maria@mail.com',
    @tel = '1122334455',
    @tel_emerg = '1133445566',
    @estado = 1,
    @saldo = 0,
    @nombre_cobertura = 'OSDE',
    @nro_afiliado = 'OS12345678',
    @tel_cobertura = '1144556677',
    @cod_responsable = NULL;

--9.1 INSERCIÓN DE RESERVAS

-- 9.1.1 INSERCIÓN VÁLIDA (Reserva de Socio)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 500.00,
    @fechahoraInicio = '2025-07-01 10:00:00',
    @fechahoraFin = '2025-07-01 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- Verificación de inserción
SELECT * FROM psn.Reserva WHERE cod_socio = 'SN-12345';

-- 9.1.2 INSERCIÓN VÁLIDA (Reserva de Invitado)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-0001',
    @monto = 750.00,
    @fechahoraInicio = '2025-07-02 14:00:00',
    @fechahoraFin = '2025-07-02 15:30:00',
    @piletaSUMColonia = 'SUM';

-- Verificación de inserción
SELECT * FROM psn.Reserva WHERE cod_invitado = 'NS-0001';

-- 9.1.3 Error: Ni cod_socio ni cod_invitado especificados (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = '2025-07-03 09:00:00',
    @fechahoraFin = '2025-07-03 10:00:00',
    @piletaSUMColonia = 'Colonia';

-- 9.1.4 Error: Ambos cod_socio y cod_invitado especificados (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = 'NS-0001',
    @monto = 200.00,
    @fechahoraInicio = '2025-07-04 11:00:00',
    @fechahoraFin = '2025-07-04 12:00:00',
    @piletaSUMColonia = 'Pileta Niños';

-- 9.1.5 Error: Formato de cod_socio erróneo (menos de 4 dígitos) (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-123',
    @cod_invitado = NULL,
    @monto = 300.00,
    @fechahoraInicio = '2025-07-05 13:00:00',
    @fechahoraFin = '2025-07-05 14:00:00',
    @piletaSUMColonia = 'Cancha Futbol';

-- 9.1.6 Error: Formato de cod_invitado erróneo (más de 4 dígitos, según SP) (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-00001', -- El SP solo acepta 4 dígitos para invitado
    @monto = 300.00,
    @fechahoraInicio = '2025-07-05 13:00:00',
    @fechahoraFin = '2025-07-05 14:00:00',
    @piletaSUMColonia = 'Cancha Futbol';

-- 9.1.7 Error: cod_socio no existente (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-9999',
    @cod_invitado = NULL,
    @monto = 400.00,
    @fechahoraInicio = '2025-07-06 10:00:00',
    @fechahoraFin = '2025-07-06 11:00:00',
    @piletaSUMColonia = 'Gimnasio';

-- 9.1.8 Error: cod_invitado no existente (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-9999',
    @monto = 500.00,
    @fechahoraInicio = '2025-07-07 14:00:00',
    @fechahoraFin = '2025-07-07 15:00:00',
    @piletaSUMColonia = 'Salón Eventos';

-- 9.1.9 Error: Monto NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = NULL, -- Inválido
    @fechahoraInicio = '2025-07-08 10:00:00',
    @fechahoraFin = '2025-07-08 11:00:00',
    @piletaSUMColonia = 'Cancha Tenis';

-- 9.1.10 Error: fechainicio NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = NULL, -- Inválido
    @fechahoraFin = '2025-07-09 11:00:00',
    @piletaSUMColonia = 'Cancha Tenis';

-- 9.1.11 Error: fechafin NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = '2025-07-09 10:00:00',
    @fechahoraFin = NULL, -- Inválido
    @piletaSUMColonia = 'Cancha Tenis';

-- 9.1.12 Error: piletaSUMColonia NULL (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 100.00,
    @fechahoraInicio = '2025-07-10 10:00:00',
    @fechahoraFin = '2025-07-10 11:00:00',
    @piletaSUMColonia = NULL; -- Inválido

-- 9.1.13 Error: Fecha y hora de inicio en el pasado (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 600.00,
    @fechahoraInicio = '2024-01-01 09:00:00', -- Pasado
    @fechahoraFin = '2024-01-01 10:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.14 Error: Fecha y hora de inicio es igual o posterior a la de fin (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 700.00,
    @fechahoraInicio = '2025-07-11 10:00:00',
    @fechahoraFin = '2025-07-11 10:00:00', -- Igual
    @piletaSUMColonia = 'Pileta Principal';

EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 700.00,
    @fechahoraInicio = '2025-07-11 11:00:00',
    @fechahoraFin = '2025-07-11 10:00:00', -- Inicio posterior a fin
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.15 Error: Duración de reserva menor a 60 minutos (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 800.00,
    @fechahoraInicio = '2025-07-12 10:00:00',
    @fechahoraFin = '2025-07-12 10:45:00', -- 45 minutos
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.16 Error: Monto de reserva menor o igual a cero (debe dar error)
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 0.00, -- Inválido
    @fechahoraInicio = '2025-07-13 10:00:00',
    @fechahoraFin = '2025-07-13 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.1.17 Error: Solapamiento de reserva para el mismo recurso (debe dar error)
-- Insertar una reserva base para generar solapamiento
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 500.00,
    @fechahoraInicio = '2025-08-01 10:00:00',
    @fechahoraFin = '2025-08-01 12:00:00',
    @piletaSUMColonia = 'SUM';

-- Intento de solapamiento total
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 550.00,
    @fechahoraInicio = '2025-08-01 10:30:00',
    @fechahoraFin = '2025-08-01 11:30:00',
    @piletaSUMColonia = 'SUM';

-- Intento de solapamiento al inicio
EXEC stp.insertarReserva
    @cod_socio = 'SN-56789', -- Se cambió el socio para evitar la misma persona
    @cod_invitado = NULL,
    @monto = 550.00,
    @fechahoraInicio = '2025-08-01 09:30:00',
    @fechahoraFin = '2025-08-01 10:30:00',
    @piletaSUMColonia = 'SUM';

-- Intento de solapamiento al final
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 550.00,
    @fechahoraInicio = '2025-08-01 11:30:00',
    @fechahoraFin = '2025-08-01 12:30:00',
    @piletaSUMColonia = 'SUM';

---

-- 9.2 MODIFICACIÓN DE RESERVAS

-- Insertar una reserva para modificar
DECLARE @codReservaModificar INT;
EXEC stp.insertarReserva
    @cod_socio = 'SN-56789',
    @cod_invitado = NULL,
    @monto = 900.00,
    @fechahoraInicio = '2025-09-01 08:00:00',
    @fechahoraFin = '2025-09-01 09:30:00',
    @piletaSUMColonia = 'Colonia',
    @return_cod_reserva = @codReservaModificar OUTPUT; -- Obtener el ID de la reserva recién insertada

-- 9.2.1 MODIFICACIÓN VÁLIDA
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345', -- Cambiando socio
    @cod_invitado = NULL,
    @monto = 950.00,
    @fechahoraInicio = '2025-09-01 10:00:00', -- Cambiando horario
    @fechahoraFin = '2025-09-01 11:30:00',
    @piletaSUMColonia = 'Colonia';

-- Verificación de modificación
-- SELECT * FROM psn.Reserva WHERE cod_reserva = @codReservaModificar;

-- Insertar otra reserva para modificar (con invitado)
DECLARE @codReservaModificar2 INT;
EXEC stp.insertarReserva
    @cod_socio = NULL,
    @cod_invitado = 'NS-0002',
    @monto = 600.00,
    @fechahoraInicio = '2025-09-02 16:00:00',
    @fechahoraFin = '2025-09-02 17:00:00',
    @piletaSUMColonia = 'Gimnasio',
    @return_cod_reserva = @codReservaModificar2 OUTPUT;

-- 9.2.2 MODIFICACIÓN VÁLIDA (cambiando de invitado a socio)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar2,
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 620.00,
    @fechahoraInicio = '2025-09-02 16:00:00',
    @fechahoraFin = '2025-09-02 17:00:00',
    @piletaSUMColonia = 'Gimnasio';

-- Verificación de modificación
-- SELECT * FROM psn.Reserva WHERE cod_reserva = @codReservaModificar2;

-- 9.2.3 Error: Código de reserva no existente (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = 9999, -- No existe
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-01 10:00:00',
    @fechahoraFin = '2025-10-01 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.4 Error: Ni cod_socio ni cod_invitado especificados (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = NULL,
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-02 10:00:00',
    @fechahoraFin = '2025-10-02 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.5 Error: Ambos cod_socio y cod_invitado especificados (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345',
    @cod_invitado = 'NS-0001',
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-03 10:00:00',
    @fechahoraFin = '2025-10-03 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.6 Error: Formato de cod_socio erróneo (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-ABC',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-04 10:00:00',
    @fechahoraFin = '2025-10-04 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.7 Error: cod_socio no existente (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-9999',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2025-10-05 10:00:00',
    @fechahoraFin = '2025-10-05 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.8 Error: Fecha de inicio en el pasado (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 1000.00,
    @fechahoraInicio = '2024-01-01 10:00:00', -- Pasada
    @fechahoraFin = '2025-10-06 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.9 Error: Monto menor o igual a cero (debe dar error)
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 0.00, -- Inválido
    @fechahoraInicio = '2025-10-07 10:00:00',
    @fechahoraFin = '2025-10-07 11:00:00',
    @piletaSUMColonia = 'Pileta Principal';

-- 9.2.10 Error: Solapamiento con otra reserva existente (debe dar error)
-- Insertar una tercera reserva para causar solapamiento
DECLARE @codReservaSolapada INT;
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 400.00,
    @fechahoraInicio = '2025-11-01 14:00:00',
    @fechahoraFin = '2025-11-01 16:00:00',
    @piletaSUMColonia = 'Pileta Niños',
    @return_cod_reserva = @codReservaSolapada OUTPUT;
PRINT 'Código de Reserva Solapada (esperado): ' + CAST(@codReservaSolapada AS VARCHAR(10));

-- Intentar modificar @codReservaModificar para que se solape con @codReservaSolapada
EXEC stp.modificarReserva
    @cod_reserva = @codReservaModificar,
    @cod_socio = 'SN-56789', -- Se cambió el socio para evitar la misma persona
    @cod_invitado = NULL,
    @monto = 900.00,
    @fechahoraInicio = '2025-11-01 15:00:00', -- Se solapa con @codReservaSolapada
    @fechahoraFin = '2025-11-01 17:00:00',
    @piletaSUMColonia = 'Pileta Niños';

---

-- 9.3 ELIMINACIÓN DE RESERVAS

-- Insertar una reserva para eliminar exitosamente
DECLARE @codReservaEliminar INT;
EXEC stp.insertarReserva
    @cod_socio = 'SN-12345',
    @cod_invitado = NULL,
    @monto = 150.00,
    @fechahoraInicio = '2025-12-01 09:00:00',
    @fechahoraFin = '2025-12-01 10:00:00',
    @piletaSUMColonia = 'SUM',
    @return_cod_reserva = @codReservaEliminar OUTPUT;

-- 9.3.1 Eliminación Exitosa
EXEC stp.borrarReserva @cod_reserva = @codReservaEliminar;

-- Verificación de eliminación
-- SELECT * FROM psn.Reserva WHERE cod_reserva = @codReservaEliminar; -- Debe retornar 0 filas

-- 9.3.2 Eliminación Fallida (Reserva no existente)
EXEC stp.borrarReserva @cod_reserva = 99999; -- No existe