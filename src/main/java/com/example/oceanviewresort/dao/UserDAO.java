package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
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

    /**
     * Returns all users that match the given role.
     */
    public List<User> findAllByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, username, password, full_name, email, role, is_active, created_at " +
                     "FROM users WHERE role = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] findAllByRole error: " + e.getMessage());
        }
        return users;
    }

    /**
     * Finds a user by their numeric ID.
     */
    public Optional<User> findById(int id) {
        String sql = "SELECT id, username, password, full_name, email, role, is_active, created_at " +
                     "FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] findById error: " + e.getMessage());
        }
        return Optional.empty();
    }

    /**
     * Updates the full_name, email, and optionally password (if non-null/non-empty)
     * for the given user.
     */
    public boolean updateUser(User user) {
        String sql;
        boolean updatePassword = user.getPassword() != null && !user.getPassword().isEmpty();
        if (updatePassword) {
            sql = "UPDATE users SET full_name = ?, email = ?, password = ? WHERE id = ?";
        } else {
            sql = "UPDATE users SET full_name = ?, email = ? WHERE id = ?";
        }
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            if (updatePassword) {
                ps.setString(3, user.getPassword());
                ps.setInt(4, user.getId());
            } else {
                ps.setInt(3, user.getId());
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] updateUser error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Permanently removes the user with the given ID.
     */
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] deleteUser error: " + e.getMessage());
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