package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.util.DBConnection;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

import java.io.PrintStream;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ReservationDAOTest {

    // ---- helper ----------------------------------------------------------

    private void stubReservationRow(ResultSet rs) throws SQLException {
        when(rs.getInt("id")).thenReturn(1);
        when(rs.getInt("guest_id")).thenReturn(10);
        when(rs.getInt("room_id")).thenReturn(5);
        when(rs.getDate("check_in_date")).thenReturn(Date.valueOf(LocalDate.of(2025, 8, 1)));
        when(rs.getDate("check_out_date")).thenReturn(Date.valueOf(LocalDate.of(2025, 8, 5)));
        when(rs.getBigDecimal("total_price")).thenReturn(new BigDecimal("600.00"));
        when(rs.getString("status")).thenReturn("confirmed");
        when(rs.getString("notes")).thenReturn("VIP guest");
        when(rs.getTimestamp("created_at")).thenReturn(null);
        when(rs.getString("guest_name")).thenReturn("John Doe");
        when(rs.getString("room_number")).thenReturn("101");
        when(rs.getString("guest_email")).thenReturn("john@test.com");
        when(rs.getString("guest_phone")).thenReturn("0771234567");
    }

    // ---- createReservation ------------------------------------------------

    @Test
    void createReservation_success_returnsGeneratedId() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet keys = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS))).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);
        when(ps.getGeneratedKeys()).thenReturn(keys);
        when(keys.next()).thenReturn(true);
        when(keys.getInt(1)).thenReturn(42);

        Reservation r = new Reservation();
        r.setGuestId(10);
        r.setRoomId(5);
        r.setCheckInDate(LocalDate.of(2025, 8, 1));
        r.setCheckOutDate(LocalDate.of(2025, 8, 5));
        r.setTotalPrice(new BigDecimal("600.00"));
        r.setStatus("confirmed");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            int id = new ReservationDAO().createReservation(r);
            assertEquals(42, id);
        }
    }

    @Test
    void createReservation_sqlException_returnsMinusOne() throws Exception {
        Connection conn = mock(Connection.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);
        when(conn.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS)))
                .thenThrow(new SQLException("DB error"));

        Reservation r = new Reservation();
        r.setGuestId(1);
        r.setRoomId(1);
        r.setCheckInDate(LocalDate.now());
        r.setCheckOutDate(LocalDate.now().plusDays(2));
        r.setTotalPrice(BigDecimal.ZERO);
        r.setStatus("confirmed");

        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(PrintStream.nullOutputStream()));
        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            int id = new ReservationDAO().createReservation(r);
            assertEquals(-1, id);
        } finally {
            System.setErr(originalErr);
        }
    }

    // ---- findAll ----------------------------------------------------------

    @Test
    void findAll_returnsReservations() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        stubReservationRow(rs);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            List<Reservation> list = new ReservationDAO().findAll();
            assertEquals(1, list.size());
            Reservation res = list.get(0);
            assertEquals(1,  res.getId());
            assertEquals(10, res.getGuestId());
            assertEquals(5,  res.getRoomId());
            assertEquals("confirmed",   res.getStatus());
            assertEquals("John Doe",    res.getGuestName());
            assertEquals("101",         res.getRoomNumber());
            assertEquals(LocalDate.of(2025, 8, 1), res.getCheckInDate());
            assertEquals(LocalDate.of(2025, 8, 5), res.getCheckOutDate());
            assertEquals(0, new BigDecimal("600.00").compareTo(res.getTotalPrice()));
        }
    }

    @Test
    void findAll_emptyTable_returnsEmptyList() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(false);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new ReservationDAO().findAll().isEmpty());
        }
    }

    // ---- count ------------------------------------------------------------

    @Test
    void count_returnsCorrectNumber() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true);
        when(rs.getInt(1)).thenReturn(7);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertEquals(7, new ReservationDAO().count());
        }
    }

    @Test
    void count_sqlException_returnsZero() throws Exception {
        Connection conn = mock(Connection.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);
        when(conn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(PrintStream.nullOutputStream()));
        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertEquals(0, new ReservationDAO().count());
        } finally {
            System.setErr(originalErr);
        }
    }

    // ---- updateReservation ------------------------------------------------

    @Test
    void updateReservation_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        Reservation r = new Reservation();
        r.setId(1);
        r.setRoomId(5);
        r.setCheckInDate(LocalDate.of(2025, 9, 1));
        r.setCheckOutDate(LocalDate.of(2025, 9, 3));
        r.setTotalPrice(new BigDecimal("300.00"));
        r.setStatus("checked_in");
        r.setNotes("Updated notes");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new ReservationDAO().updateReservation(r));
        }
    }

    @Test
    void updateReservation_notFound_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        Reservation r = new Reservation();
        r.setId(999);
        r.setRoomId(1);
        r.setCheckInDate(LocalDate.now());
        r.setCheckOutDate(LocalDate.now().plusDays(1));
        r.setTotalPrice(BigDecimal.ZERO);
        r.setStatus("pending");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new ReservationDAO().updateReservation(r));
        }
    }

    // ---- deleteReservation ------------------------------------------------

    @Test
    void deleteReservation_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new ReservationDAO().deleteReservation(1));
        }
    }

    @Test
    void deleteReservation_notFound_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new ReservationDAO().deleteReservation(999));
        }
    }
}
