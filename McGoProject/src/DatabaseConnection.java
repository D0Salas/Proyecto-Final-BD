// DatabaseConnection.java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/McGo";
    private static final String USER = "root"; // Tu usuario MySQL
    private static final String PASSWORD = "MASTERROOT"; // Tu contraseña MySQL
    
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver no encontrado", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}