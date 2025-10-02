import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO {
    
    // Obtener todos los clientes
    public List<String> getClientes() throws SQLException {
        List<String> clientes = new ArrayList<>();
        String sql = "SELECT ClienteID, Nombre, Email, Telefono, FechaRegistro FROM Clientes ORDER BY FechaRegistro DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                String info = String.format("ID: %d | %s | Email: %s | Tel: %s | Registro: %s",
                    rs.getInt("ClienteID"),
                    rs.getString("Nombre"),
                    rs.getString("Email"),
                    rs.getString("Telefono"),
                    rs.getTimestamp("FechaRegistro")
                );
                clientes.add(info);
            }
        }
        return clientes;
    }
    
    // Usar el procedimiento almacenado para nuevo cliente
    public String agregarCliente(String nombre, String email, String telefono) throws SQLException {
        String sql = "CALL NuevoCliente(?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setString(1, nombre);
            stmt.setString(2, email);
            stmt.setString(3, telefono);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("Resultado");
            }
            return "Cliente agregado exitosamente";
        }
    }
}