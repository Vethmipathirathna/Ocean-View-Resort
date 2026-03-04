package com.example.oceanviewresort.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Singleton Database Connection Utility.
 * Reads connection settings from /db.properties on the classpath.
 */
public class DBConnection {

    private static DBConnection instance;

    private final String url;
    private final String username;
    private final String password;
    private final String driverClass;

    private DBConnection() {
        // Environment variables take priority (used in CI/CD)
        String envUrl      = System.getenv("DB_URL");
        String envUser     = System.getenv("DB_USERNAME");
        String envPassword = System.getenv("DB_PASSWORD");

        if (envUrl != null && envUser != null) {
            this.url         = envUrl;
            this.username    = envUser;
            this.password    = envPassword != null ? envPassword : "";
            this.driverClass = "com.mysql.cj.jdbc.Driver";
        } else {
            // Fall back to db.properties for local development
            Properties props = new Properties();
            try (InputStream is = getClass().getClassLoader().getResourceAsStream("db.properties")) {
                if (is == null) {
                    throw new RuntimeException("db.properties not found on classpath.");
                }
                props.load(is);
            } catch (IOException e) {
                throw new RuntimeException("Failed to load db.properties: " + e.getMessage(), e);
            }
            this.url         = props.getProperty("db.url");
            this.username    = props.getProperty("db.username");
            this.password    = props.getProperty("db.password");
            this.driverClass = props.getProperty("db.driver");
        }

        try {
            Class.forName(driverClass);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found: " + e.getMessage(), e);
        }
    }

    /** Returns the singleton instance. */
    public static DBConnection getInstance() {
        if (instance == null) {
            synchronized (DBConnection.class) {
                if (instance == null) {
                    instance = new DBConnection();
                }
            }
        }
        return instance;
    }

    /** Opens and returns a new JDBC connection. Caller is responsible for closing it. */
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}
