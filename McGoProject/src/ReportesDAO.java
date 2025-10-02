import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportesDAO {
    
    public List<String> getVentasPorCategoria() throws SQLException {
        List<String> ventas = new ArrayList<>();
        String sql = "SELECT i.Categoria, SUM(pp.Cantidad) as TotalVendido, " +
                    "SUM(pp.Cantidad * i.Precio) as IngresosTotales " +
                    "FROM PedidosProducto pp " +
                    "JOIN Inventario i ON pp.Producto_ID = i.Producto_ID " +
                    "GROUP BY i.Categoria " +
                    "ORDER BY IngresosTotales DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                String info = String.format("Categoria: %s | Vendidos: %d | Ingresos: $%.2f",
                    rs.getString("Categoria"),
                    rs.getInt("TotalVendido"),
                    rs.getDouble("IngresosTotales")
                );
                ventas.add(info);
            }
        }
        return ventas;
    }
    
    public List<String> getReporteVentasDiarias(String fecha) throws SQLException {
        List<String> reporte = new ArrayList<>();
        String sql = "CALL ReporteVentasDiarias(?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setString(1, fecha);
            boolean hasResults = stmt.execute();
            
            if (hasResults) {
                try (ResultSet rs = stmt.getResultSet()) {
                    while (rs.next()) {
                        String info = String.format("Pedido: %d | Cliente: %s | Metodo: %s | Total: $%.2f | Fecha: %s",
                            rs.getInt("PedidoID"),
                            rs.getString("Cliente"),
                            rs.getString("MetodoEntrega"),
                            rs.getDouble("Total"),
                            rs.getTimestamp("Fecha")
                        );
                        reporte.add(info);
                    }
                }
                hasResults = stmt.getMoreResults();
            }
            
            if (hasResults) {
                try (ResultSet rs = stmt.getResultSet()) {
                    if (rs.next()) {
                        reporte.add("=== RESUMEN DEL DIA ===");
                        reporte.add(String.format("Fecha: %s", rs.getDate("Fecha")));
                        reporte.add(String.format("Total Pedidos: %d", rs.getInt("TotalPedidos")));
                        reporte.add(String.format("Ventas Totales: $%.2f", rs.getDouble("VentasTotales")));
                        reporte.add(String.format("Clientes Atendidos: %d", rs.getInt("ClientesAtendidos")));
                    }
                }
            }
        }
        return reporte;
    }
}