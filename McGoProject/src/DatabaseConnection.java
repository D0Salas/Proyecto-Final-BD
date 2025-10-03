package mcgo;

// DatabaseConnection.java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/McGo";
    private static String Usuario = "";
    private static String Contraseña = "";
    
    public static void setCredentials(String username, String pwd) {
        Usuario = username;
        Contraseña = pwd;
    }
    
    public static Connection getConnection() throws SQLException {
        if (Usuario.isEmpty() || Contraseña.isEmpty()) {
            throw new SQLException("Credenciales no configuradas. Ejecute el login primero.");
        }
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver no encontrado", e);
        }
        return DriverManager.getConnection(URL, Usuario, Contraseña);
    }
}
