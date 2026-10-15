DROP DATABASE IF EXISTS smart_grid;
CREATE DATABASE smart_grid;
USE smart_grid;

-- 1. INFRAESTRUCTURA Y TOPOLOGÍA
CREATE TABLE Subestacion (
    id_subestacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ciudad VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    capacidad_maxima DECIMAL(10,2) NOT NULL CHECK (capacidad_maxima > 0)
);

CREATE TABLE Zona (
    id_zona INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_subestacion INT NOT NULL,
    FOREIGN KEY (id_subestacion) REFERENCES Subestacion(id_subestacion) ON DELETE RESTRICT
);

CREATE TABLE Barrio (
    id_barrio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_zona INT NOT NULL,
    FOREIGN KEY (id_zona) REFERENCES Zona(id_zona) ON DELETE RESTRICT,
    UNIQUE (nombre, id_zona)
);

CREATE TABLE Transformador (
    id_transformador INT AUTO_INCREMENT PRIMARY KEY,
    id_subestacion INT NOT NULL,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    capacidad_kva DECIMAL(10,2) NOT NULL CHECK (capacidad_kva > 0),
    nivel_aceite DECIMAL(5,2) CHECK (nivel_aceite BETWEEN 0 AND 100),
    estado_operativo ENUM('Activo', 'Inactivo', 'Mantenimiento', 'Falla') DEFAULT 'Activo',
    FOREIGN KEY (id_subestacion) REFERENCES Subestacion(id_subestacion) ON DELETE RESTRICT
);

-- 2. CLIENTES Y EQUIPOS
CREATE TABLE Tarifa (
    id_tarifa INT AUTO_INCREMENT PRIMARY KEY,
    tipo_cliente ENUM('Residencial', 'Comercial', 'Industrial') NOT NULL,
    costo_por_kwh DECIMAL(10,4) NOT NULL CHECK (costo_por_kwh >= 0),
    fecha_inicio_vigencia DATE NOT NULL
);

CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(255) NOT NULL,
    id_tarifa INT NOT NULL,
    id_barrio INT NOT NULL,
    FOREIGN KEY (id_tarifa) REFERENCES Tarifa(id_tarifa),
    FOREIGN KEY (id_barrio) REFERENCES Barrio(id_barrio)
);

CREATE TABLE Medidor (
    id_medidor INT AUTO_INCREMENT PRIMARY KEY,
    codigo_serial VARCHAR(100) NOT NULL UNIQUE,
    tipo ENUM('Monofasico', 'Bifasico', 'Trifasico') NOT NULL,
    fecha_instalacion DATE NOT NULL,
    estado ENUM('Activo', 'Inactivo', 'Suspendido') DEFAULT 'Activo',
    id_cliente INT,
    id_transformador INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE SET NULL,
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador)
);

-- 3. MANTENIMIENTO Y CUADRILLAS
CREATE TABLE Cuadrilla (
    id_cuadrilla INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    estado ENUM('Disponible', 'Ocupada', 'En ruta', 'Fuera de servicio') DEFAULT 'Disponible'
);

CREATE TABLE Tecnico (
    id_tecnico INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    telefono VARCHAR(20)
);

-- Tabla intermedia N:M para asignar técnicos a cuadrillas
CREATE TABLE Cuadrilla_Tecnico (
    id_cuadrilla INT NOT NULL,
    id_tecnico INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    PRIMARY KEY (id_cuadrilla, id_tecnico),
    FOREIGN KEY (id_cuadrilla) REFERENCES Cuadrilla(id_cuadrilla),
    FOREIGN KEY (id_tecnico) REFERENCES Tecnico(id_tecnico)
);

CREATE TABLE Mantenimiento (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_transformador INT NOT NULL,
    id_cuadrilla INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME,
    tipo ENUM('Preventivo', 'Correctivo', 'Emergencia') NOT NULL,
    descripcion TEXT,
    CONSTRAINT chk_fechas_mantenimiento CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador),
    FOREIGN KEY (id_cuadrilla) REFERENCES Cuadrilla(id_cuadrilla)
);

-- 4. EVENTOS Y ALERTAS
CREATE TABLE Falla (
    id_falla INT AUTO_INCREMENT PRIMARY KEY,
    id_transformador INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    descripcion TEXT NOT NULL,
    gravedad ENUM('Baja', 'Media', 'Alta', 'Critica') NOT NULL,
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador)
);

CREATE TABLE Alerta (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_transformador INT NOT NULL,
    id_falla INT NULL, -- Opcional: vincula alerta con una falla directa si aplica
    fecha_hora DATETIME NOT NULL,
    descripcion TEXT NOT NULL,
    tipo_alerta VARCHAR(50) NOT NULL,
    nivel_criticidad ENUM('Baja', 'Media', 'Alta', 'Critica') NOT NULL,
    estado ENUM('Activa', 'En proceso', 'Resuelta') DEFAULT 'Activa',
    FOREIGN KEY (id_transformador) REFERENCES Transformador(id_transformador),
    FOREIGN KEY (id_falla) REFERENCES Falla(id_falla)
);

-- 5. MEDIDAS E HISTÓRICOS (Consumos de Alta Frecuencia)
CREATE TABLE Consumo (
    id_consumo BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_medidor INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    valor_kwh DECIMAL(12,4) NOT NULL CHECK (valor_kwh >= 0),
    voltaje DECIMAL(6,2) CHECK (voltaje >= 0),
    corriente DECIMAL(6,2) CHECK (corriente >= 0),
    temperatura_ambiente DECIMAL(3,1),
    FOREIGN KEY (id_medidor) REFERENCES Medidor(id_medidor),
    INDEX idx_medidor_fecha (id_medidor, fecha_hora)
);
