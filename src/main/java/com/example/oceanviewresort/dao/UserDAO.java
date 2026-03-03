package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.Optional;

/**
 * Data Access Object for the users table.
 */
public class UserDAO {

    /**
     * Finds a user by username.
     * Returns Optional.empty() if not found.
     */
    public Optional<User> findByUsername(String username) {
        String sql = "SELECT id, username, password, full_name, email, role, is_active, created_at " +
                     "FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] findByUsername error: " + e.getMessage());
        }
        return Optional.empty();
    }

    /**
     * Returns true if at least one user row exists.
     */
    public boolean hasAnyUser() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] hasAnyUser error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Inserts a new user into the database.
     * The password field should already be BCrypt-hashed before calling this method.
     */
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, password, full_name, email, role, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getRole());
            ps.setBoolean(6, user.isActive());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO] createUser error: " + e.getMessage());
            return false;
        }
    }

    // ---- Private Helpers ----

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setRole(rs.getString("role"));
        u.setActive(rs.getBoolean("is_active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            u.setCreatedAt(ts.toLocalDateTime());
        }
        return u;
    }
}
