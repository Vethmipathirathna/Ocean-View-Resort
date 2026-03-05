package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
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

    /** Deletes a room by id (cascades to reservations). Returns true on success. */
    public boolean deleteRoom(int id) {
        try (Connection conn = DBConnection.getInstance().getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM reservations WHERE room_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM rooms WHERE id=?")) {
                    ps.setInt(1, id);
                    int rows = ps.executeUpdate();
                    conn.commit();
                    return rows > 0;
                }
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[RoomDAO] deleteRoom error: " + e.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[RoomDAO] deleteRoom connection error: " + e.getMessage());
            return false;
        }
    }

    /** Updates the status column of a room. */
    public void updateRoomStatus(int id, String status) {
        String sql = "UPDATE rooms SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[RoomDAO] updateRoomStatus error: " + e.getMessage());
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

    /**
     * Returns rooms that are 'available' AND have no overlapping confirmed reservations.
     * @param checkIn  requested check-in date
     * @param checkOut requested check-out date
     * @param excludeReservationId reservation id to exclude from the overlap check; pass -1 to skip
     */
    public List<Room> findAvailableForDates(LocalDate checkIn, LocalDate checkOut, int excludeReservationId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.id, r.room_number, r.type, r.price_per_night, r.capacity, r.status, r.description " +
                     "FROM rooms r " +
                     "WHERE r.status = 'available' " +
                     "AND r.id NOT IN (" +
                     "  SELECT rv.room_id FROM reservations rv " +
                     "  WHERE rv.status NOT IN ('cancelled','checked_out') " +
                     "  AND rv.check_in_date < ? AND rv.check_out_date > ? AND rv.id != ?" +
                     ") ORDER BY r.room_number";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(checkOut));  // overlap: check_in_date < checkOut
            ps.setDate(2, java.sql.Date.valueOf(checkIn));   // overlap: check_out_date > checkIn
            ps.setInt (3, excludeReservationId);            // exclude current reservation
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RoomDAO] findAvailableForDates error: " + e.getMessage());
        }
        return list;
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
