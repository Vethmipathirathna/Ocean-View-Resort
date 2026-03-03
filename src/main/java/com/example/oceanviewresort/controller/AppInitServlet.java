package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.service.AuthService;
import com.example.oceanviewresort.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.sql.Connection;
import java.sql.Statement;

/**
 * Runs at application startup (load-on-startup = 1).
 * 1. Creates the users table if it does not exist.
 * 2. Seeds the default admin account if no users exist.
 */
@WebServlet(name = "AppInitServlet", urlPatterns = "/app-init", loadOnStartup = 1)
public class AppInitServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    public void init() throws ServletException {
        System.out.println("[AppInitServlet] Application starting — initializing database schema...");
        try {
            createSchemaIfNeeded();
            authService.createDefaultAdminIfNeeded();
            System.out.println("[AppInitServlet] Database initialization complete.");
        } catch (Exception e) {
            System.err.println("[AppInitServlet] ERROR during initialization: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Creates the users table if it does not already exist.
     * The JDBC URL already handles auto-creating the database via createDatabaseIfNotExist=true.
     */
    private void createSchemaIfNeeded() throws Exception {
        String createUsersTable =
            "CREATE TABLE IF NOT EXISTS users (" +
            "  id         INT AUTO_INCREMENT PRIMARY KEY," +
            "  username   VARCHAR(50)  NOT NULL UNIQUE," +
            "  password   VARCHAR(255) NOT NULL," +
            "  full_name  VARCHAR(100)," +
            "  email      VARCHAR(100)," +
            "  role       ENUM('ADMIN','STAFF','RECEPTIONIST') DEFAULT 'STAFF'," +
            "  is_active  BOOLEAN DEFAULT TRUE," +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
            ")";

        try (Connection conn = DBConnection.getInstance().getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(createUsersTable);
            System.out.println("[AppInitServlet] users table ready.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, java.io.IOException {
        resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
    }
}
