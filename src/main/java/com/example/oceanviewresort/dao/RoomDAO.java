package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for the rooms table.
 *
 * Expected table DDL:
 * CREATE TABLE IF NOT EXISTS rooms (
 *   id              INT AUTO_INCREMENT PRIMARY KEY,
 *   room_number     VARCHAR(10)  NOT NULL UNIQUE,
 *   type            VARCHAR(30)  NOT NULL,
 *   price_per_night DECIMAL(10,2) NOT NULL DEFAULT 0,
 *   capacity        INT          NOT NULL DEFAULT 1,
 *   status          VARCHAR(20)  NOT NULL DEFAULT 'available',
 *   description     TEXT
 * );
 */
public class RoomDAO {

    /** Returns all rooms ordered by room number. */
    public List<Room> findAll() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT id, room_number, type, price_per_night, capacity, status, description " +
                     "FROM rooms ORDER BY room_number";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[RoomDAO] findAll error: " + e.getMessage());
        }
        return list;
    }

    /** Finds a room by primary key. */
    public Optional<Room> findById(int id) {
        String sql = "SELECT id, room_number, type, price_per_night, capacity, status, description " +
                     "FROM rooms WHERE id = ?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RoomDAO] findById error: " + e.getMessage());
        }
        return Optional.empty();
    }

    /** Inserts a new room. Returns true on success. */
    public boolean createRoom(Room room) {
        String sql = "INSERT INTO rooms (room_number, type, price_per_night, capacity, status, description) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getType());
            ps.setDouble(3, room.getPricePerNight());
            ps.setInt   (4, room.getCapacity());
            ps.setString(5, room.getStatus() != null ? room.getStatus() : "available");
            ps.setString(6, room.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[RoomDAO] createRoom error: " + e.getMessage());
            return false;
        }
    }

    /** Updates an existing room. Returns true on success. */
    public boolean updateRoom(Room room) {
        String sql = "UPDATE rooms SET room_number=?, type=?, price_per_night=?, capacity=?, status=?, description=? " +
                     "WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getType());
            ps.setDouble(3, room.getPricePerNight());
            ps.setInt   (4, room.getCapacity());
            ps.setString(5, room.getStatus());
            ps.setString(6, room.getDescription());
            ps.setInt   (7, room.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[RoomDAO] updateRoom error: " + e.getMessage());
            return false;
        }
    }

    /** Deletes a room by id. Returns true on success. */
    public boolean deleteRoom(int id) {
        String sql = "DELETE FROM rooms WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[RoomDAO] deleteRoom error: " + e.getMessage());
            return false;
        }
    }

    /** Counts rooms by status. */
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM rooms WHERE status=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[RoomDAO] countByStatus error: " + e.getMessage());
        }
        return 0;
    }

    // ---- private helper ----
    private Room mapRow(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setId           (rs.getInt   ("id"));
        r.setRoomNumber   (rs.getString("room_number"));
        r.setType         (rs.getString("type"));
        r.setPricePerNight(rs.getDouble("price_per_night"));
        r.setCapacity     (rs.getInt   ("capacity"));
        r.setStatus       (rs.getString("status"));
        r.setDescription  (rs.getString("description"));
        return r;
    }
}
