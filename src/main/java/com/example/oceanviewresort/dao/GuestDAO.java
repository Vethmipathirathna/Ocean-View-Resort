package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Guest;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for the guests table.
 *
 * CREATE TABLE IF NOT EXISTS guests (
 *   id            INT AUTO_INCREMENT PRIMARY KEY,
 *   first_name    VARCHAR(80)  NOT NULL,
 *   last_name     VARCHAR(80)  NOT NULL,
 *   email         VARCHAR(120),
 *   phone         VARCHAR(30),
 *   address       TEXT,
 *   id_type       VARCHAR(40),
 *   id_number     VARCHAR(60),
 *   registered_at DATETIME DEFAULT CURRENT_TIMESTAMP
 * );
 */
public class GuestDAO {

    public List<Guest> findAll() {
        List<Guest> list = new ArrayList<>();
        String sql = "SELECT id, first_name, last_name, email, phone, address, id_type, id_number, registered_at " +
                     "FROM guests ORDER BY registered_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[GuestDAO] findAll error: " + e.getMessage());
        }
        return list;
    }

    public Optional<Guest> findById(int id) {
        String sql = "SELECT id, first_name, last_name, email, phone, address, id_type, id_number, registered_at " +
                     "FROM guests WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[GuestDAO] findById error: " + e.getMessage());
        }
        return Optional.empty();
    }

    public boolean createGuest(Guest g) {
        String sql = "INSERT INTO guests (first_name, last_name, email, phone, address, id_type, id_number) " +
                     "VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, g.getFirstName());
            ps.setString(2, g.getLastName());
            ps.setString(3, g.getEmail());
            ps.setString(4, g.getPhone());
            ps.setString(5, g.getAddress());
            ps.setString(6, g.getIdType());
            ps.setString(7, g.getIdNumber());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[GuestDAO] createGuest error: " + e.getMessage());
            return false;
        }
    }

    public boolean updateGuest(Guest g) {
        String sql = "UPDATE guests SET first_name=?, last_name=?, email=?, phone=?, address=?, id_type=?, id_number=? " +
                     "WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, g.getFirstName());
            ps.setString(2, g.getLastName());
            ps.setString(3, g.getEmail());
            ps.setString(4, g.getPhone());
            ps.setString(5, g.getAddress());
            ps.setString(6, g.getIdType());
            ps.setString(7, g.getIdNumber());
            ps.setInt   (8, g.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[GuestDAO] updateGuest error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteGuest(int id) {
        try (Connection conn = DBConnection.getInstance().getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM reservations WHERE guest_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM guests WHERE id=?")) {
                    ps.setInt(1, id);
                    int rows = ps.executeUpdate();
                    conn.commit();
                    return rows > 0;
                }
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[GuestDAO] deleteGuest error: " + e.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[GuestDAO] deleteGuest connection error: " + e.getMessage());
            return false;
        }
    }

    public int count() {
        String sql = "SELECT COUNT(*) FROM guests";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[GuestDAO] count error: " + e.getMessage());
        }
        return 0;
    }

    private Guest mapRow(ResultSet rs) throws SQLException {
        Guest g = new Guest();
        g.setId        (rs.getInt   ("id"));
        g.setFirstName (rs.getString("first_name"));
        g.setLastName  (rs.getString("last_name"));
        g.setEmail     (rs.getString("email"));
        g.setPhone     (rs.getString("phone"));
        g.setAddress   (rs.getString("address"));
        g.setIdType    (rs.getString("id_type"));
        g.setIdNumber  (rs.getString("id_number"));
        Timestamp ts = rs.getTimestamp("registered_at");
        if (ts != null) g.setRegisteredAt(ts.toLocalDateTime());
        return g;
    }
}
