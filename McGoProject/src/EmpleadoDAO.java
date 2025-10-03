import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmpleadoDAO {
    
    // Obtener todos los empleados con sus puestos y horarios
    public List<String> getEmpleadosCompletos() throws SQLException {
        List<String> empleados = new ArrayList<>();
        String sql = "SELECT e.ID, e.Nombre, e.Apellido, p.Puesto, " +
                    "h.Horario_Inicio, h.Horario_Fin, h.Dias " +
                    "FROM Empleados e " +
                    "JOIN Puestos p ON e.Puesto_ID = p.Puesto_ID " +
                    "JOIN Horarios h ON e.ID = h.ID_Empleado";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                String info = String.format("ID: %d | %s %s | %s | Horario: %s-%s | Días: %s",
                    rs.getInt("ID"),
                    rs.getString("Nombre"),
                    rs.getString("Apellido"),
                    rs.getString("Puesto"),
                    rs.getTime("Horario_Inicio"),
                    rs.getTime("Horario_Fin"),
                    rs.getString("Dias")
                );
                empleados.add(info);
            }
        }
        return empleados;
    }
    
    // Agregar nuevo empleado
    public boolean agregarEmpleado(int id, String nombre, String apellido, 
                                  String telefono, String email, int puestoId) throws SQLException {
        String sql = "INSERT INTO Empleados (ID, Nombre, Apellido, Telefono, Email, Puesto_ID) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.setString(2, nombre);
            stmt.setString(3, apellido);
            stmt.setString(4, telefono);
            stmt.setString(5, email);
            stmt.setInt(6, puestoId);
            
            return stmt.executeUpdate() > 0;
        }
    }
}