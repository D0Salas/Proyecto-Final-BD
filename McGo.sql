SET SQL_SAFE_UPDATES = 0;

-- CREATE DATABASE McGo;
USE McGo;

DROP TABLE IF EXISTS SeguimientoClientes;
DROP TABLE IF EXISTS PedidosCombo;
DROP TABLE IF EXISTS PedidosProducto;
DROP TABLE IF EXISTS Pedidos;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS DetallesCombos;
DROP TABLE IF EXISTS Combos;
DROP TABLE IF EXISTS Inventario;
DROP TABLE IF EXISTS Horarios;
DROP TABLE IF EXISTS Empleados;
DROP TABLE IF EXISTS Puestos;


CREATE TABLE Puestos(
Puesto_ID INT(10) NOT NULL,
Puesto VARCHAR(100) NOT NULL,
PRIMARY KEY (Puesto_ID),
UNIQUE KEY Codigo_Puesto (Puesto_ID)
);

CREATE TABLE Empleados (
ID INT(10) NOT NULL,
Nombre VARCHAR(100) NOT NULL,
Apellido VARCHAR(100) NOT NULL,
Telefono VARCHAR(100) NOT NULL,
Email VARCHAR(100) NOT NULL,
Puesto_ID INT(10) NOT NULL,
PRIMARY KEY (ID),
UNIQUE KEY Matricula_Empleado (ID),
KEY fk_Empleados_Puestos (Puesto_ID),
  CONSTRAINT fk_Empleados_Puestos
     FOREIGN KEY (Puesto_ID) 
     REFERENCES Puestos (Puesto_ID)
);

CREATE TABLE Horarios (
ID_Empleado INT(10) NOT NULL,
Horario_Inicio TIME NOT NULL,
Horario_Fin TIME NOT NULL,
Dias SET('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo') NOT NULL,
PRIMARY KEY (ID_Empleado),
  CONSTRAINT fk_Horarios_Empleados
     FOREIGN KEY (ID_Empleado) 
     REFERENCES Empleados (ID)
);

CREATE TABLE Inventario (
Producto_ID INT(10) NOT NULL,
Producto VARCHAR(100) NOT NULL,
Categoria VARCHAR(100) NOT NULL,
Precio FLOAT(10,2) NOT NULL,
PRIMARY KEY (Producto_ID),
UNIQUE KEY Codigo_Producto (Producto_ID)
);

CREATE TABLE Combos (
Combo_ID INT(10) NOT NULL,
Combo VARCHAR(100) NOT NULL,
Precio FLOAT(10,2) NOT NULL,
PRIMARY KEY (Combo_ID),
UNIQUE KEY Codigo_Combos (Combo_ID)
);

CREATE TABLE DetallesCombos(
Combo_ID INT(10) NOT NULL,
Producto_ID INT(10) NOT NULL,
Cantidad INT(10) NOT NULL,
PRIMARY KEY (Combo_ID, Producto_ID),
KEY fk_DetallesCombos_Combos (Combo_ID),
  CONSTRAINT fk_DetallesCombos_Combos
     FOREIGN KEY (Combo_ID) 
     REFERENCES Combos (Combo_ID),
KEY fk_DetallesCombos_Inventario (Producto_ID),
  CONSTRAINT fk_DetallesCombos_Inventario
     FOREIGN KEY (Producto_ID) 
     REFERENCES Inventario (Producto_ID)
);

CREATE TABLE IF NOT EXISTS Clientes (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Telefono VARCHAR(20),
    FechaRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Pedidos (
PedidoID INT(10) NOT NULL,
ClienteID INT (10) NOT NULL,
Fecha TIMESTAMP,
MetodoEntrega VARCHAR(100) NOT NULL,
Total DOUBLE(10,2) NOT NULL,
PRIMARY KEY (PedidoID),
UNIQUE KEY Codigo_Pedido (PedidoID),
KEY fk_pedidos_clientes(ClienteID),
	CONSTRAINT fk_pedidos_clientes
	FOREIGN KEY (ClienteID)
    REFERENCES Clientes(ClienteID)
);

CREATE TABLE PedidosCombo (
DetalleID INT(10) NOT NULL AUTO_INCREMENT,
PedidoID INT(10) NOT NULL,
Combo_ID INT(10) NOT NULL,
Cantidad INT(10) NOT NULL,
PRIMARY KEY (DetalleID),
KEY fk_PedidosCombos_Pedidos (PedidoID),
  CONSTRAINT fk_PedidosCombos_Pedidos
     FOREIGN KEY (PedidoID) 
     REFERENCES Pedidos (PedidoID),
KEY fk_PedidosCombos_Combos (Combo_ID),
  CONSTRAINT fk_PedidosCombos_Combos
     FOREIGN KEY (Combo_ID) 
     REFERENCES Combos (Combo_ID)
);

CREATE TABLE PedidosProducto (
DetalleID INT(10) NOT NULL AUTO_INCREMENT,
PedidoID INT(10) NOT NULL,
Producto_ID INT(10) NOT NULL,
Cantidad INT(10) NOT NULL,
PRIMARY KEY (DetalleID),
KEY fk_PedidosProducto_Pedidos (PedidoID),
  CONSTRAINT fk_PedidosProducto_Pedidos
     FOREIGN KEY (PedidoID) 
     REFERENCES Pedidos (PedidoID),
KEY fk_PedidosProducto_Inventario (Producto_ID),
  CONSTRAINT fk_PedidosProducto_Inventario
     FOREIGN KEY (Producto_ID) 
     REFERENCES Inventario (Producto_ID)
);

-- Tabla para el seguimiento de clientes
CREATE TABLE SeguimientoClientes (
    SeguimientoID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT NOT NULL,
    NombreCliente VARCHAR(100) NOT NULL,
    EmailCliente VARCHAR(100),
    PedidoID INT NOT NULL,
    FechaCompra TIMESTAMP,
    MetodoCompra VARCHAR(50) DEFAULT 'Online',
    TipoSeguimiento VARCHAR(50) DEFAULT 'Nueva compra online',
    FechaSeguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    EstadoSeguimiento ENUM('Pendiente', 'En proceso', 'Completado') DEFAULT 'Pendiente',
    Observaciones TEXT,
    KEY fk_seguimiento_clientes (ClienteID),
    KEY fk_seguimiento_pedidos (PedidoID),
    CONSTRAINT fk_seguimiento_clientes 
        FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
    CONSTRAINT fk_seguimiento_pedidos 
        FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID)
);

INSERT INTO Puestos (Puesto_ID, Puesto) 
VALUES
(1, 'Gerente'),
(2, 'Drive Tru'),
(3, 'Gerente'),
(4, 'Limpieza');

INSERT INTO Empleados (ID, Nombre, Apellido, Telefono, Email, Puesto_ID) 
VALUES
(1, 'Guillermo', 'López', '811-234-5678', 'ramirez.lopez@empresa.com', 1),
(2, 'Gabriel', 'Pérez', '812-345-6789', 'gonzalez.perez@empresa.com', 2),
(3, 'Helena', 'Morales', '813-456-7890', 'hernandez.morales@empresa.com', 3),
(4, 'Tatiana', 'Aguilar', '814-567-8901', 'torres.aguilar@empresa.com', 3),
(5, 'Mario', 'Castillo', '815-678-9012', 'mailto:martinez.castillo@empresa.com', 3),
(6, 'Camilo', 'Sánchez', '816-789-0123', 'cruz.sanchez@empresa.com', 4),
(7, 'Reynaldo', 'Domínguez', '817-890-1234', 'reyes.dominguez@empresa.com', 4),
(8, 'Nadia', 'Ortega', '818-901-2345', 'mailto:navarro.ortega@empresa.com', 4),
(9, 'Julio', 'Jiménez', '819-012-3456', 'mailto:vargas.jimenez@empresa.com', 4),
(10, 'Maria', 'Bautista', '810-123-4567', 'mailto:morales.bautista@empresa.com', 4)
;

INSERT INTO Horarios(ID_Empleado, Horario_Inicio, Horario_Fin, Dias)
VALUES
(1, '09:00:00', '18:00:00', 'Lunes,Martes,Miercoles,Jueves,Viernes,Sabado'),
(2, '09:00:00', '18:00:00', 'Lunes,Miercoles,Viernes'),
(3, '09:00:00', '18:00:00', 'Martes,Jueves,Sabado'),
(4, '09:00:00', '18:00:00', 'Lunes,Martes,Sabado'),
(5, '09:00:00', '18:00:00', 'Miercoles,Jueves,Viernes'),
(6, '09:00:00', '18:00:00', 'Lunes,Miercoles'),
(7, '09:00:00', '18:00:00', 'Martes,Jueves'),
(8, '09:00:00', '18:00:00', 'Viernes,Sabado'),
(9, '09:00:00', '18:00:00', 'Lunes,Miercoles,Viernes'),
(10,'09:00:00', '18:00:00', 'Martes,Jueves,Sabado');

INSERT INTO Inventario (Producto_ID, Producto, Categoria, Precio) 
VALUES
(1, 'Big Mac', 'Hamburguesa', 75.00),
(2, 'Cuarto de Ib', 'Hamburguesa', 80.00),
(3, 'McPollo', 'Hamburguesa', 70.00),
(4, 'McNífica', 'Hamburguesa', 85.00),
(5, 'McDoble', 'Hamburguesa', 60.00),
(6, 'Papas Ch', 'Guarnicion', 35.00),
(7, 'Papas Md', 'Guarnicion', 45.00),
(8, 'Papas Gd', 'Guarnicion', 55.00),
(9, 'Nuggets 6pz', 'Guarnicion', 65.00),
(10, 'Nuggets 10pz', 'Guarnicion', 85.00),
(11, 'Sundae Caramelo', 'Postre', 30.00),
(12, 'Sundae Chocolate', 'Postre', 30.00),
(13, 'McFlurry Oreo', 'Postre', 45.00),
(14, 'Cono Vainilla', 'Postre', 15.00),
(15, 'Cafe Americano', 'Bebida', 25.00),
(16, 'Cafe Capuchino', 'Bebida', 40.00),
(17, 'Refresco Ch', 'Bebida', 25.00),
(18, 'Refresco Md', 'Bebida', 35.00),
(19, 'Refresco Gd', 'Bebida', 45.00),
(20, 'Jugo de Naranja', 'Bebida', 30.00);

INSERT INTO Combos (Combo_ID, Combo, Precio) 
VALUES
(1, 'Combo Big Mac', 160.00),
(2, 'Combo Doble', 130.00),
(3, 'Combo familiar', 320.00),
(4, 'Combo party', 430.00),
(5, 'Combo individual', 105.00),
(6, 'Combo Cono', 85.00),
(7, 'Combo Mañanero', 85.00),
(8, 'Combo Pollo', 120.00),
(9, 'Combo McDoble', 150.00),
(10, 'Combo cuarto de lb', 120.00);

INSERT INTO DetallesCombos (Combo_ID, Producto_ID, Cantidad) VALUES
(1, 1, 1),
(1, 7, 1),
(1, 17, 1),
(2, 5, 1),
(2, 7, 1),
(2, 17, 1),
(3, 2, 2),
(3, 4, 2),
(3, 8, 2),
(3, 19, 4),
(4, 1, 2),
(4, 3, 2),
(4, 10, 1),
(4, 8, 2),
(4, 19, 4),
(5, 1, 1),
(5, 7, 1),
(5, 17, 1),
(6, 14, 1),
(7, 15, 1),
(7, 13, 1),
(8, 3, 1),
(8, 7, 1),
(8, 17, 1),
(9, 5, 2),
(9, 8, 2),
(9, 19, 2),
(10, 2, 1),
(10, 7, 1),
(10, 17, 1);

INSERT INTO Clientes (Nombre, Email, Telefono) VALUES
( 'Juan Pérez', 'juan.perez@email.com', '811-100-2000'),
('Ana Torres', 'ana.torres@email.com', '812-200-3000'),
('Pedro Gómez', 'pedro.gomez@email.com', '813-300-4000'),
('Carla Jiménez', 'carla.jimenez@email.com', '814-400-5000'),
('Luis García', 'luis.garcia@gmail.com', '815-500-6000'),
('María Rodríguez', 'maria.rodriguez@email.com', '816-600-7000'),
('Carlos Hernández', 'carlos.hernandez@gmail.com', '817-700-8000'),
('Laura Martínez', 'laura.martinez@email.com', '818-800-9000'),
('Roberto Silva', 'roberto.silva@email.com', '819-900-1000'),
('Ana López', 'ana.lopez@email.com', '820-110-1200'),
('Miguel Ángel', 'miguel.angel@email.com', '821-120-1300'),
('Sofía Castro', 'sofia.castro@email.com', '822-130-1400');

INSERT INTO Pedidos (PedidoID, ClienteID, Fecha, MetodoEntrega, Total) 
VALUES
(1, 1,'2025-09-28 13:15:00', 'McDelivery', 320.00),
(2, 2,'2025-09-28 14:45:00', 'Auto-Mac', 150.00),
(3, 3,'2025-09-28 17:30:00', 'McDelivery', 125.00),
(4, 4,'2025-09-28 18:20:00', 'Auto-Mac', 430.00),
(5, 5,'2025-01-15 12:30:00','McDelivery', 280.00),
(6, 6,'2025-02-20 14:45:00', 'Auto-Mac', 190.00),
(7, 7,'2025-03-10 18:20:00','McDelivery', 420.00),
(8, 8,'2025-01-30 13:15:00', 'Auto-Mac', 150.00),
(9, 9,'2025-02-05 19:20:00', 'McDelivery', 320.00),
(10, 10,'2025-03-25 11:45:00', 'Auto-Mac', 210.00),
(11, 11,'2025-01-10 17:30:00', 'McDelivery', 180.00),
(12, 12,'2025-02-28 16:15:00', 'Auto-Mac', 390.00);

INSERT INTO PedidosCombo (PedidoID, Combo_ID, Cantidad) 
VALUES
(1, 3, 1),
(2, 9, 1),
(3, 8, 2),
(3, 2, 1),
(4, 4, 1),
(5, 1, 2),
(6, 5, 1),
(7, 3, 1),
(8, 8, 1),
(9, 2, 2),
(10, 10, 1),
(11, 7, 1),
(12, 4, 1);

INSERT INTO PedidosProducto (PedidoID, Producto_ID, Cantidad) 
VALUES
(1, 7, 1),
(2, 5, 1),
(3, 7, 2),
(3, 17, 1),
(4, 2, 1),
(5, 6, 1),
(6, 11, 2),
(7, 9, 1),
(8, 17, 1),
(9, 8, 1),
(10, 13, 1),
(11, 15, 2),
(12, 10, 1);


SELECT * FROM Empleados;
SELECT * FROM Horarios;
SELECT * FROM Puestos;
SELECT * FROM DetallesCombos;
SELECT * FROM PedidosCombo;
SELECT * FROM PedidosProducto;
SELECT * FROM Pedidos;
SELECT * FROM Combos;
SELECT * FROM Inventario;


