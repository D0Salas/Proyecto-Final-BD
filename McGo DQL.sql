USE McGo;

-- 1.- Consulta que muestra empleados con sus puestos y horarios
SELECT 
    e.ID,
    e.Nombre,
    e.Apellido,
    p.Puesto,
    h.Horario_Inicio,
    h.Horario_Fin,
    h.Dias
FROM Empleados e
JOIN Puestos p ON e.Puesto_ID = p.Puesto_ID
JOIN Horarios h ON e.ID = h.ID_Empleado;

-- 2.- Pedidos ordenados por fecha de más reciente a más antiguo
SELECT 
    ClienteID,
    Nombre,
    Email,
    FechaRegistro
FROM Clientes
ORDER BY FechaRegistro DESC;

-- 3.- Pedidos ordenados por fecha de más antiguo a más reciente
SELECT 
    p.PedidoID,
    c.Nombre as Cliente,
    p.Total,
    p.Fecha
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
ORDER BY p.Total DESC;

-- 4.- Ventas totales por categoría de producto
SELECT 
    i.Categoria,
    SUM(pp.Cantidad) as TotalVendido,
    SUM(pp.Cantidad * i.Precio) as IngresosTotales
FROM PedidosProducto pp
JOIN Inventario i ON pp.Producto_ID = i.Producto_ID
GROUP BY i.Categoria
ORDER BY IngresosTotales DESC;

-- 5.- Total de ventas por método de entrega
SELECT 
    c.Nombre as Cliente,
    p.MetodoEntrega,
    COUNT(*) as VecesUtilizado
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
GROUP BY c.ClienteID, c.Nombre, p.MetodoEntrega
ORDER BY c.Nombre, VecesUtilizado DESC;

-- 6.- Combinar información de productos individuales y combos vendidos
SELECT 
    'Producto Individual' as Tipo,
    i.Producto as Descripcion,
    pp.Cantidad,
    (pp.Cantidad * i.Precio) as Subtotal
FROM PedidosProducto pp
JOIN Inventario i ON pp.Producto_ID = i.Producto_ID

UNION ALL

SELECT 
    'Combo' as Tipo,
    c.Combo as Descripcion,
    pc.Cantidad,
    (pc.Cantidad * c.Precio) as Subtotal
FROM PedidosCombo pc
JOIN Combos c ON pc.Combo_ID = c.Combo_ID

ORDER BY Subtotal DESC;

-- 7.- Extraer información específica de fechas
SELECT 
    YEAR(FechaRegistro) as Año,
    MONTH(FechaRegistro) as Mes,
    COUNT(*) as NuevosClientes
FROM Clientes
GROUP BY YEAR(FechaRegistro), MONTH(FechaRegistro)
ORDER BY Año DESC, Mes DESC;

/* 8.- Análisis detallado de ventas por empleado (si tuvieras relación empleado-pedido)
Esta consulta muestra los productos más vendidos en combos*/
SELECT 
    c.Combo,
    i.Producto,
    SUM(dc.Cantidad) as TotalIncluidoEnCombos,
    COUNT(pc.PedidoID) as VecesVendido
FROM Combos c
JOIN DetallesCombos dc ON c.Combo_ID = dc.Combo_ID
JOIN Inventario i ON dc.Producto_ID = i.Producto_ID
JOIN PedidosCombo pc ON c.Combo_ID = pc.Combo_ID
GROUP BY c.Combo_ID, i.Producto_ID
ORDER BY VecesVendido DESC, TotalIncluidoEnCombos DESC;

-- 9.- Ventas por día de la semana
SELECT 
    DAYNAME(Fecha) as DiaSemana,
    COUNT(*) as TotalPedidos,
    SUM(Total) as IngresosTotales,
    AVG(Total) as PromedioPorPedido
FROM Pedidos
GROUP BY DAYNAME(Fecha), DAYOFWEEK(Fecha)
ORDER BY DAYOFWEEK(Fecha);

-- 10.- Empleados que trabajan en días específicos (ejemplo: fin de semana)
SELECT 
    e.Nombre,
    e.Apellido,
    p.Puesto,
    h.Dias
FROM Empleados e
JOIN Puestos p ON e.Puesto_ID = p.Puesto_ID
JOIN Horarios h ON e.ID = h.ID_Empleado
WHERE h.Dias LIKE '%Sabado%' OR h.Dias LIKE '%Domingo%'

UNION

-- 12.- Empleados que trabajan solo entre semana
SELECT 
    e.Nombre,
    e.Apellido,
    p.Puesto,
    h.Dias
FROM Empleados e
JOIN Puestos p ON e.Puesto_ID = p.Puesto_ID
JOIN Horarios h ON e.ID = h.ID_Empleado
WHERE h.Dias NOT LIKE '%Sabado%' AND h.Dias NOT LIKE '%Domingo%';

/*Procedimiento almacenado para realizar el calculo de ventas diarias*/
DROP PROCEDURE IF EXISTS ReporteVentasDiarias;
DELIMITER //

CREATE PROCEDURE ReporteVentasDiarias(IN fecha_consulta DATE)
BEGIN
    -- Ventas del día con información de clientes
    SELECT 
        p.PedidoID,
        c.Nombre as Cliente,
        p.MetodoEntrega,
        p.Total,
        p.Fecha
    FROM Pedidos p
    JOIN Clientes c ON p.ClienteID = c.ClienteID
    WHERE DATE(p.Fecha) = fecha_consulta
    ORDER BY p.Fecha;
    
    -- Resumen del día
    SELECT 
        fecha_consulta as Fecha,
        COUNT(*) as TotalPedidos,
        SUM(p.Total) as VentasTotales,
        COUNT(DISTINCT p.ClienteID) as ClientesAtendidos
    FROM Pedidos p
    WHERE DATE(p.Fecha) = fecha_consulta;
    
END //

DELIMITER ;

DELIMITER ;

/*Consultas para checar datos del procedimiento*/
-- Para usar el procedimiento completo
CALL ReporteVentasDiarias('2025-09-28');

-- Para usar el procedimiento simplificado
CALL ReporteVentasDiarias('2025-01-15');

-- Para consultar las ventas de hoy
CALL ReporteVentasDiarias(CURDATE());

-- Para consultar las ventas de ayer
CALL ReporteVentasDiarias(DATE_SUB(CURDATE(), INTERVAL 1 DAY));

/*Procedimiento para generer un reporte de los clientes vigentes del primer semestre*/
DROP PROCEDURE IF EXISTS ReporteClientesTrimestre1;
DELIMITER //

CREATE PROCEDURE ReporteClientesTrimestre1(IN anio INT)
BEGIN
    -- Clientes con pedidos en el primer trimestre
    SELECT 
        c.ClienteID,
        c.Nombre,
        c.Email,
        c.Telefono,
        COUNT(p.PedidoID) as PedidosEnTrimestre,
        SUM(p.Total) as TotalGastado,
        MIN(p.Fecha) as PrimeraCompraTrimestre,
        MAX(p.Fecha) as UltimaCompraTrimestre
    FROM Clientes c
    JOIN Pedidos p ON c.ClienteID = p.ClienteID
    WHERE YEAR(p.Fecha) = anio 
        AND MONTH(p.Fecha) BETWEEN 1 AND 3
    GROUP BY c.ClienteID, c.Nombre, c.Email, c.Telefono
    ORDER BY TotalGastado DESC;
    
    -- Estadísticas del trimestre
    SELECT 
        CONCAT('Primer Trimestre ', anio) as Periodo,
        COUNT(DISTINCT c.ClienteID) as TotalClientesUnicos,
        COUNT(p.PedidoID) as TotalPedidos,
        SUM(p.Total) as VentasTotales,
        ROUND(AVG(p.Total), 2) as TicketPromedio
    FROM Pedidos p
    JOIN Clientes c ON p.ClienteID = c.ClienteID
    WHERE YEAR(p.Fecha) = anio 
        AND MONTH(p.Fecha) BETWEEN 1 AND 3;
        
END //

DELIMITER ;

-- Consulta para ver el resultado del procedimiento
CALL ReporteClientesTrimestre1(2025);

/*Try/Catch que sirve para registrar nuevos clientes a la tabla Clientes con la excepci*/
DROP PROCEDURE IF EXISTS NuevoCliente;
DELIMITER //

CREATE PROCEDURE NuevoCliente(
    IN p_Nombre VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_Telefono VARCHAR(20)
)
BEGIN
    -- CATCH: Maneja CUALQUIER error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    SELECT 'No se pudo registrar el cliente, intentelo de nuevo' as Resultado;
    
    -- TRY: Solo insertar
    INSERT INTO Clientes (Nombre, Email, Telefono) 
    VALUES (p_Nombre, p_Email, p_Telefono);
    
    SELECT 'El cliente se ha agregado correctamente' as Resultado;
    
END //

DELIMITER ;

-- Probar con cliente nuevo (debe funcionar)
CALL NuevoCliente('María González', 'maria.gonzalez@email.com', '811-555-1234');

-- Probar con email duplicado (debe mostrar error)
CALL NuevoCliente('Otro María', 'maria.gonzalez@email.com', '811-999-8888');

-- Ver clientes registrados
SELECT * FROM Clientes ORDER BY ClienteID DESC;

-- Este Trigger se activa antes de insertar algo nuevo en el Inventario
DROP TRIGGER IF EXISTS evitarDuplicadosInventario;
DELIMITER //

CREATE TRIGGER evitarDuplicadosInventario
BEFORE INSERT ON Inventario
FOR EACH ROW
BEGIN
    DECLARE productoExistente INT DEFAULT 0;
    
    -- Verificar si ya existe un producto con el mismo nombre
    SELECT COUNT(*) INTO productoExistente 
    FROM Inventario 
    WHERE Producto = NEW.Producto;
    
    -- Si existe, generar error (EXCEPCIÓN)
    IF productoExistente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede insertar. El producto ya existe en el inventario.';
    END IF;
END //

DELIMITER ;

-- Este Trigger evita los datos duplicados al actualizar
DROP TRIGGER IF EXISTS DeteccionDuplicadoInventario;
DELIMITER //

CREATE TRIGGER DeteccionDuplicadoInventario
BEFORE UPDATE ON Inventario
FOR EACH ROW
BEGIN
    DECLARE productoExistente INT DEFAULT 0;
    
    -- Verificar si ya existe otro producto con el mismo nombre (excluyendo el actual)
    SELECT COUNT(*) INTO productoExistente 
    FROM Inventario 
    WHERE Producto = NEW.Producto AND Producto_ID != OLD.Producto_ID;
    
    -- Si existe, generar error
    IF productoExistente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'EXCEPCIÓN: No se puede actualizar. Ya existe otro producto con ese nombre.';
    END IF;
END //

DELIMITER ;

-- Este Trigger sirve para controlar el stock cuando se hacen pedidos
DROP TRIGGER IF EXISTS controlStockPedidos;
DELIMITER //

CREATE TRIGGER controlStockPedidos
BEFORE INSERT ON PedidosProducto
FOR EACH ROW
BEGIN
    DECLARE stockActual INT DEFAULT 0;
    DECLARE productoNombre VARCHAR(100);
    
    -- Obtener nombre del producto y stock (simulado)
    SELECT Producto INTO productoNombre 
    FROM Inventario 
    WHERE Producto_ID = NEW.Producto_ID;
    
    -- Simular stock (en una base real tendrías columna de stock)
    SET stockActual = 50; -- Stock por defecto
    
    -- Verificar si hay suficiente stock
    IF NEW.Cantidad > stockActual THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sin Stock.';
    END IF;
END //

DELIMITER ;

-- Querys para revisar sus funciones
-- Esto debería funcionar (cantidad menor a stock)
INSERT INTO PedidosProducto (PedidoID, Producto_ID, Cantidad) 
VALUES (1, 1, 10);

-- Esto debería fallar (cantidad mayor a stock)
INSERT INTO PedidosProducto (PedidoID, Producto_ID, Cantidad) 
VALUES (1, 1, 60);

-- Este Trigger sirve para dar seguimiento a las compras de todos los clientes
DROP TRIGGER IF EXISTS seguimientoComprasOnline;
DELIMITER //

CREATE TRIGGER seguimientoComprasOnline
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    DECLARE cliente_nombre VARCHAR(100);
    DECLARE cliente_email VARCHAR(100);
    DECLARE metodo_compra VARCHAR(50);
    
    -- Obtener información del cliente
    SELECT Nombre, Email INTO cliente_nombre, cliente_email
    FROM Clientes 
    WHERE ClienteID = NEW.ClienteID;
    
    -- Determinar el método de compra
    IF NEW.MetodoEntrega = 'McDelivery' THEN
        SET metodo_compra = 'App Móvil';
    ELSE
        SET metodo_compra = 'Sitio Web';
    END IF;
    
    -- Insertar en la tabla de seguimiento
    INSERT INTO SeguimientoClientes (
        ClienteID, 
        NombreCliente, 
        EmailCliente, 
        PedidoID, 
        FechaCompra, 
        MetodoCompra,
        TipoSeguimiento,
        Observaciones
    ) VALUES (
        NEW.ClienteID,
        cliente_nombre,
        cliente_email,
        NEW.PedidoID,
        NEW.Fecha,
        metodo_compra,
        'Nueva compra online',
        CONCAT('Compra realizada por ', metodo_compra, '. Total: $', NEW.Total)
    );
    
END //

DELIMITER ;

-- QUERY para insertar un nuevo pedido
INSERT INTO Pedidos (PedidoID, ClienteID, Fecha, MetodoEntrega, Total) 
VALUES (13, 1, NOW(), 'McDelivery', 250.00);

SELECT * FROM SeguimientoClientes ORDER BY FechaSeguimiento DESC;