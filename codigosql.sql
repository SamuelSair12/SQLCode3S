DROP DATABASE IF EXISTS smart_grid;
CREATE DATABASE smart_grid;
USE smart_grid;

CREATE TABLE Subestacion (
    id_subestacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    ciudad VARCHAR(100),
    direccion VARCHAR(255),
    capacidad_maxima DECIMAL(10,2)
);
CREATE TABLE Tarifa (
    id_tarifa INT AUTO_INCREMENT PRIMARY KEY,
    tipo_cliente VARCHAR(50),
    costo_por_kwh DECIMAL(10,2),
    fecha_inicio_vigencia DATE
);

-- NUEVA TABLA: Gestión de cuadrillas de mantenimiento
CREATE TABLE Cuadrilla (
    id_cuadrilla INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    estado ENUM('Disponible','Ocupada','En ruta','Fuera de servicio')
);

-- NUEVA TABLA: Técnicos especializados
CREATE TABLE Tecnico (
    id_tecnico INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150),
    especialidad VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE Zona (
    id_zona INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    id_subestacion INT,
    FOREIGN KEY (id_subestacion) REFERENCES Subestacion(id_subestacion)
);

CREATE TABLE Transformador (
    id_transformador INT AUTO_INCREMENT PRIMARY KEY,
    id_subestacion INT,
    codigo VARCHAR(50),
    capacidad_kva DECIMAL(10,2),
    nivel_aceite DECIMAL(5,2),
    estado_operativo VARCHAR(50),
    FOREIGN KEY (id_subestacion) REFERENCES Subestacion(id_subestacion)
);
-- NUEVA TABLA: Permite identificar barrios dentro de cada zona
CREATE TABLE Barrio (
    id_barrio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    id_zona INT,
    FOREIGN KEY (id_zona) REFERENCES Zona(id_zona)
);
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150),
    documento VARCHAR(20)unique,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(255),
    id_tarifa INT,-- NUEVO: tarifa asignada al cliente
    id_barrio INT,-- NUEVO: barrio donde reside el cliente
    FOREIGN KEY (id_tarifa) REFERENCES Tarifa(id_tarifa),
    FOREIGN KEY (id_barrio) REFERENCES Barrio(id_barrio)
);
CREATE TABLE Medidor (
    id_medidor INT AUTO_INCREMENT PRIMARY KEY,
    codigo_serial VARCHAR(100)unique,
    tipo VARCHAR(50),
    fecha_instalacion DATE,
    estado VARCHAR(30),
    id_cliente INT,
    id_transformador INT,-- NUEVO: transformador que alimenta el medidor
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador)
);
CREATE TABLE Mantenimiento (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_transformador INT,
    id_cuadrilla INT,-- NUEVO: cuadrilla asignada
    id_tecnico INT,-- NUEVO: técnico responsable
    fecha_inicio DATETIME,
    fecha_fin DATETIME,
    tipo VARCHAR(50),
    descripcion TEXT,
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador),
    FOREIGN KEY (id_cuadrilla) REFERENCES Cuadrilla(id_cuadrilla),
    FOREIGN KEY (id_tecnico) REFERENCES Tecnico(id_tecnico)
);
CREATE TABLE Alerta (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_transformador INT,
    fecha_hora DATETIME,
    descripcion TEXT,
    tipo_alerta VARCHAR(50),

    nivel_criticidad ENUM('Baja','Media','Alta','Critica'),
    estado ENUM('Activa','En proceso','Resuelta'),
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador)
);

-- NUEVA TABLA: Registro de fallas eléctricas
CREATE TABLE Falla (
    id_falla INT AUTO_INCREMENT PRIMARY KEY,
    id_transformador INT,
    fecha_hora DATETIME,
    descripcion TEXT,
    gravedad ENUM('Baja','Media','Alta','Critica'),
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador)
);

CREATE TABLE Consumo (
    id_consumo INT AUTO_INCREMENT PRIMARY KEY,
    id_medidor INT,
    fecha_hora DATETIME,
    valor_kwh DECIMAL(10,2),
    voltaje DECIMAL(6,2),
    corriente DECIMAL(6,2),
    temperatura_ambiente DECIMAL(4,1),
    FOREIGN KEY (id_medidor) REFERENCES Medidor(id_medidor)
);

INSERT INTO Subestacion(nombre, ciudad, direccion, capacidad_maxima)VALUES
('Subestacion Central Sincelejo','Sincelejo','Calle 20 #25-40',5000),
('Subestacion Norte Sincelejo','Sincelejo','Carrera 4 #38-10',3500);

INSERT INTO Tarifa(tipo_cliente,costo_por_kwh,fecha_inicio_vigencia)VALUES
('Residencial',650.50,'2026-01-01'),
('Comercial',820.30,'2026-01-01');

INSERT INTO Cuadrilla(nombre,estado)VALUES
('Cuadrilla Centro','Disponible'),
('Cuadrilla Norte','Ocupada');

INSERT INTO Tecnico(nombre,especialidad,telefono)VALUES
('Jorge Luis Perez','Transformadores','3004567890'),
('Maria Fernanda Ruiz','Redes Electricas','3016549870');

INSERT INTO Zona(nombre,id_subestacion)VALUES
('Zona Centro',1),
('Zona Norte',2);

INSERT INTO Transformador(id_subestacion,codigo,capacidad_kva,nivel_aceite,estado_operativo)VALUES
(1,'TR-01-CENTRO',150,95.5,'Activo'),
(2,'TR-02-NORTE',112.5,88,'Activo');

INSERT INTO Barrio(nombre,id_zona)VALUES
('Majagual',1),
('Centro',1),
('Venecia',2),
('Las Peñitas',2);

INSERT INTO Cliente(nombre,documento,telefono,correo,direccion,id_tarifa,id_barrio)VALUES
('Carlos Mendoza','11002233','3001234567','carlos.mendoza@email.com','Calle 15 #12-20',1,1),
('Ana Rodriguez','11004455','3019876543','ana.rodriguez@email.com','Carrera 22 #9-15',2,3);

INSERT INTO Medidor(codigo_serial,tipo,fecha_instalacion,estado,id_cliente,id_transformador)VALUES
('M-998811','Monofasico','2026-02-10','Activo',1,1),
('M-998822','Trifasico','2026-03-15','Activo',2,2);

INSERT INTO Mantenimiento(id_transformador,id_cuadrilla,id_tecnico,fecha_inicio,fecha_fin,tipo,descripcion)VALUES
(1,1,1,'2026-04-10 08:00:00','2026-04-10 11:30:00','Preventivo','Cambio de aceite y limpieza general de bornes');

INSERT INTO Alerta(id_transformador,fecha_hora,descripcion,tipo_alerta,nivel_criticidad,estado)VALUES
(2,'2026-05-20 14:15:22','Temperatura elevada detectada en horas pico','Sobrecarga','Alta','Activa');

INSERT INTO Falla(id_transformador,fecha_hora,descripcion,gravedad)VALUES
(2,'2026-05-20 14:00:00','Incremento anormal de temperatura','Alta');

INSERT INTO Consumo(id_medidor,fecha_hora,valor_kwh,voltaje,corriente,temperatura_ambiente)VALUES
(1,'2026-06-04 08:00:00',1.25,118.5,10.4,28.5),
(1,'2026-06-04 09:00:00',1.40,119.0,11.2,29.0),
(2,'2026-06-04 08:00:00',4.50,215.0,20.8,28.5),
(2,'2026-06-04 09:00:00',5.10,212.4,22.1,29.2);
