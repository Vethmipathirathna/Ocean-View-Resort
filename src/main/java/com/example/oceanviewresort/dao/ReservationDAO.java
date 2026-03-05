package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for reservations table.
 *
 * DDL:
 * CREATE TABLE IF NOT EXISTS reservations (
 *     id             INT AUTO_INCREMENT PRIMARY KEY,
 *     guest_id       INT NOT NULL,
 *     room_id        INT NOT NULL,
 *     check_in_date  DATE NOT NULL,
 *     check_out_date DATE NOT NULL,
 *     total_price    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
 *     status         VARCHAR(20) NOT NULL DEFAULT 'confirmed',
 *     notes          TEXT,
 *     created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 *     FOREIGN KEY (guest_id) REFERENCES guests(id),
 *     FOREIGN KEY (room_id)  REFERENCES rooms(id)
 * );
 */
public class ReservationDAO {

    /** Create a new reservation. Returns generated id or -1 on failure. */
    public int createReservation(Reservation r) {
        String sql = "INSERT INTO reservations (guest_id, room_id, check_in_date, check_out_date, " +
                     "total_price, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, r.getGuestId());
            ps.setInt(2, r.getRoomId());
            ps.setDate(3, Date.valueOf(r.getCheckInDate()));
            ps.setDate(4, Date.valueOf(r.getCheckOutDate()));
            ps.setBigDecimal(5, r.getTotalPrice());
            ps.setString(6, r.getStatus() != null ? r.getStatus() : "confirmed");
            ps.setString(7, r.getNotes());

            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Return all reservations joined with guest and room info, newest first. */
    public List<Reservation> findAll() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT rv.id, rv.guest_id, rv.room_id, rv.check_in_date, rv.check_out_date, " +
                     "rv.total_price, rv.status, rv.notes, rv.created_at, " +
                     "CONCAT(g.first_name,' ',g.last_name) AS guest_name, " +
                     "g.email AS guest_email, g.phone AS guest_phone, " +
                     "rm.room_number " +
                     "FROM reservations rv " +
                     "JOIN guests g  ON rv.guest_id = g.id " +
                     "JOIN rooms  rm ON rv.room_id  = rm.id " +
                     "ORDER BY rv.created_at DESC";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Count total reservations. */
    public int count() {
        String sql = "SELECT COUNT(*) FROM reservations";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Update an existing reservation. Returns true on success. */
    public boolean updateReservation(Reservation r) {
        String sql = "UPDATE reservations SET room_id=?, check_in_date=?, check_out_date=?, total_price=?, status=?, notes=? WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, r.getRoomId());
            ps.setDate(2, Date.valueOf(r.getCheckInDate()));
            ps.setDate(3, Date.valueOf(r.getCheckOutDate()));
            ps.setBigDecimal(4, r.getTotalPrice());
            ps.setString(5, r.getStatus());
            ps.setString(6, r.getNotes());
            ps.setInt(7, r.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Delete a reservation by id. Returns true on success. */
    public boolean deleteReservation(int id) {
        String sql = "DELETE FROM reservations WHERE id=?";
        try (Connection conn = DBConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getInt("id"));
        r.setGuestId(rs.getInt("guest_id"));
        r.setRoomId(rs.getInt("room_id"));

        Date cin = rs.getDate("check_in_date");
        if (cin != null) r.setCheckInDate(cin.toLocalDate());
        Date cout = rs.getDate("check_out_date");
        if (cout != null) r.setCheckOutDate(cout.toLocalDate());

        r.setTotalPrice(rs.getBigDecimal("total_price"));
        r.setStatus(rs.getString("status"));
        r.setNotes(rs.getString("notes"));

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) r.setCreatedAt(ts.toLocalDateTime());

        r.setGuestName(rs.getString("guest_name"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setGuestEmail(rs.getString("guest_email"));
        r.setGuestPhone(rs.getString("guest_phone"));
        return r;
    }
}
