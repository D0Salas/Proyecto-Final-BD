import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class McGoAdminApp extends JFrame {
    private JTabbedPane tabbedPane;
    
    // DAOs
    private EmpleadoDAO empleadoDAO;
    private ClienteDAO clienteDAO;
    private ReportesDAO reportesDAO;
    
    // TextAreas separados para cada pestaña
    private JTextArea empleadosArea;
    private JTextArea clientesArea;
    private JTextArea reportesArea;
    private JTextArea pedidosArea;
    
    public McGoAdminApp() {
        empleadoDAO = new EmpleadoDAO();
        clienteDAO = new ClienteDAO();
        reportesDAO = new ReportesDAO();
        
        initializeUI();
    }
    
    private void initializeUI() {
        setTitle("McGo - Sistema Administrativo");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 600);
        setLocationRelativeTo(null);
        
        // Inicializar las areas de texto
        empleadosArea = createTextArea();
        clientesArea = createTextArea();
        reportesArea = createTextArea();
        pedidosArea = createTextArea();
        
        // Panel principal con pestañas
        tabbedPane = new JTabbedPane();
        tabbedPane.addTab("Empleados", createEmpleadosPanel());
        tabbedPane.addTab("Clientes", createClientesPanel());
        tabbedPane.addTab("Reportes", createReportesPanel());
        tabbedPane.addTab("Pedidos", createPedidosPanel());
        
        add(tabbedPane);
    }
    
    private JTextArea createTextArea() {
        JTextArea area = new JTextArea();
        area.setEditable(false);
        area.setFont(new Font("Consolas", Font.PLAIN, 12));
        return area;
    }
    
    private JPanel createEmpleadosPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        // Botones superiores
        JPanel buttonPanel = new JPanel();
        JButton verEmpleadosBtn = new JButton("Ver Todos los Empleados");
        JButton agregarEmpleadoBtn = new JButton("Agregar Empleado");
        
        buttonPanel.add(verEmpleadosBtn);
        buttonPanel.add(agregarEmpleadoBtn);
        
        // Area de texto para empleados
        JScrollPane scrollPane = new JScrollPane(empleadosArea);
        
        panel.add(buttonPanel, BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        // Listeners
        verEmpleadosBtn.addActionListener(e -> {
            try {
                List<String> empleados = empleadoDAO.getEmpleadosCompletos();
                empleadosArea.setText("=== LISTA DE EMPLEADOS ===\n\n");
                for (String emp : empleados) {
                    empleadosArea.append(emp + "\n");
                }
            } catch (SQLException ex) {
                empleadosArea.setText("Error: " + ex.getMessage());
            }
        });
        
        agregarEmpleadoBtn.addActionListener(e -> 
            JOptionPane.showMessageDialog(this, "Funcionalidad para agregar empleados - Por implementar")
        );
        
        return panel;
    }
    
    private JPanel createClientesPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        JPanel buttonPanel = new JPanel();
        JButton verClientesBtn = new JButton("Ver Todos los Clientes");
        JButton agregarClienteBtn = new JButton("Agregar Cliente");
        
        buttonPanel.add(verClientesBtn);
        buttonPanel.add(agregarClienteBtn);
        
        // Area de texto para clientes
        JScrollPane scrollPane = new JScrollPane(clientesArea);
        
        panel.add(buttonPanel, BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        verClientesBtn.addActionListener(e -> {
            try {
                List<String> clientes = clienteDAO.getClientes();
                clientesArea.setText("=== LISTA DE CLIENTES ===\n\n");
                for (String cli : clientes) {
                    clientesArea.append(cli + "\n");
                }
            } catch (SQLException ex) {
                clientesArea.setText("Error: " + ex.getMessage());
            }
        });
        
        agregarClienteBtn.addActionListener(e -> mostrarDialogoAgregarCliente());
        
        return panel;
    }
    
    private JPanel createReportesPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        JPanel buttonPanel = new JPanel(new GridLayout(2, 2));
        
        JButton ventasCategoriaBtn = new JButton("Ventas por Categoria");
        JButton ventasDiariasBtn = new JButton("Reporte Ventas Diarias");
        JButton clientesTrimestreBtn = new JButton("Clientes 1er Trimestre");
        JButton ventasDiaSemanaBtn = new JButton("Ventas por Dia de Semana");
        
        buttonPanel.add(ventasCategoriaBtn);
        buttonPanel.add(ventasDiariasBtn);
        buttonPanel.add(clientesTrimestreBtn);
        buttonPanel.add(ventasDiaSemanaBtn);
        
        // Area de texto para reportes
        JScrollPane scrollPane = new JScrollPane(reportesArea);
        
        panel.add(buttonPanel, BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        // Listeners para reportes
        ventasCategoriaBtn.addActionListener(e -> {
            try {
                List<String> ventas = reportesDAO.getVentasPorCategoria();
                reportesArea.setText("=== VENTAS POR CATEGORIA ===\n\n");
                for (String venta : ventas) {
                    reportesArea.append(venta + "\n");
                }
            } catch (SQLException ex) {
                reportesArea.setText("Error: " + ex.getMessage());
            }
        });
        
        ventasDiariasBtn.addActionListener(e -> {
            String fecha = JOptionPane.showInputDialog("Ingrese la fecha (YYYY-MM-DD):");
            if (fecha != null && !fecha.trim().isEmpty()) {
                try {
                    List<String> reporte = reportesDAO.getReporteVentasDiarias(fecha);
                    reportesArea.setText("=== REPORTE VENTAS DIARIAS ===\n\n");
                    for (String linea : reporte) {
                        reportesArea.append(linea + "\n");
                    }
                } catch (SQLException ex) {
                    reportesArea.setText("Error: " + ex.getMessage());
                }
            }
        });
        
        clientesTrimestreBtn.addActionListener(e -> {
            try {
                reportesArea.setText("Funcionalidad de Clientes 1er Trimestre - Por implementar\n");
                reportesArea.append("Usaria: CALL ReporteClientesTrimestre1(2025)");
            } catch (Exception ex) {
                reportesArea.setText("Error: " + ex.getMessage());
            }
        });
        
        ventasDiaSemanaBtn.addActionListener(e -> {
            try {
                reportesArea.setText("Funcionalidad de Ventas por Dia de Semana - Por implementar\n");
                reportesArea.append("Consulta: SELECT DAYNAME(Fecha) as DiaSemana, COUNT(*) as TotalPedidos FROM Pedidos GROUP BY DAYNAME(Fecha)");
            } catch (Exception ex) {
                reportesArea.setText("Error: " + ex.getMessage());
            }
        });
        
        return panel;
    }
    
    private JPanel createPedidosPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        
        JPanel buttonPanel = new JPanel();
        JButton verSeguimientoBtn = new JButton("Ver Seguimiento Clientes");
        
        buttonPanel.add(verSeguimientoBtn);
        
        // Area de texto para pedidos
        JScrollPane scrollPane = new JScrollPane(pedidosArea);
        
        panel.add(buttonPanel, BorderLayout.NORTH);
        panel.add(scrollPane, BorderLayout.CENTER);
        
        verSeguimientoBtn.addActionListener(e -> {
            try {
                mostrarSeguimientoClientes();
            } catch (SQLException ex) {
                pedidosArea.setText("Error: " + ex.getMessage());
            }
        });
        
        return panel;
    }
    
    private void mostrarDialogoAgregarCliente() {
        JDialog dialog = new JDialog(this, "Agregar Nuevo Cliente", true);
        dialog.setLayout(new GridLayout(4, 2));
        
        JTextField nombreField = new JTextField();
        JTextField emailField = new JTextField();
        JTextField telefonoField = new JTextField();
        
        dialog.add(new JLabel("Nombre:"));
        dialog.add(nombreField);
        dialog.add(new JLabel("Email:"));
        dialog.add(emailField);
        dialog.add(new JLabel("Telefono:"));
        dialog.add(telefonoField);
        
        JButton agregarBtn = new JButton("Agregar");
        JButton cancelarBtn = new JButton("Cancelar");
        
        dialog.add(agregarBtn);
        dialog.add(cancelarBtn);
        
        agregarBtn.addActionListener(e -> {
            try {
                String resultado = clienteDAO.agregarCliente(
                    nombreField.getText(),
                    emailField.getText(),
                    telefonoField.getText()
                );
                JOptionPane.showMessageDialog(dialog, resultado);
                dialog.dispose();
            } catch (SQLException ex) {
                JOptionPane.showMessageDialog(dialog, "Error: " + ex.getMessage());
            }
        });
        
        cancelarBtn.addActionListener(e -> dialog.dispose());
        
        dialog.pack();
        dialog.setLocationRelativeTo(this);
        dialog.setVisible(true);
    }
    
    private void mostrarSeguimientoClientes() throws SQLException {
        String sql = "SELECT * FROM SeguimientoClientes ORDER BY FechaSeguimiento DESC LIMIT 20";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            pedidosArea.setText("=== SEGUIMIENTO DE CLIENTES (Ultimos 20) ===\n\n");
            while (rs.next()) {
                String info = String.format(
                    "SeguimientoID: %d | Cliente: %s | Pedido: %d | Estado: %s\n   Metodo: %s | Fecha: %s\n   Observaciones: %s\n\n",
                    rs.getInt("SeguimientoID"),
                    rs.getString("NombreCliente"),
                    rs.getInt("PedidoID"),
                    rs.getString("EstadoSeguimiento"),
                    rs.getString("MetodoCompra"),
                    rs.getTimestamp("FechaSeguimiento"),
                    rs.getString("Observaciones")
                );
                pedidosArea.append(info);
            }
        }
    }
    
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new McGoAdminApp().setVisible(true);
        });
    }
}