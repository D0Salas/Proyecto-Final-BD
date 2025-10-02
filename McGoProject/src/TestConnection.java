public class TestConnection {
    public static void main(String[] args) {
        try {
            java.sql.Connection conn = DatabaseConnection.getConnection();
            System.out.println("CONEXION EXITOSA a la base de datos McGo");
            conn.close();
        } catch (Exception e) {
            System.out.println("ERROR de conexion: " + e.getMessage());
        }
    }
}