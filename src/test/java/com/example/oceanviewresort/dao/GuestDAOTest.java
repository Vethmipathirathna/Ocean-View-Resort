package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Guest;
import com.example.oceanviewresort.util.DBConnection;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

import java.io.PrintStream;
import java.sql.*;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class GuestDAOTest {

    // ---- helper ----------------------------------------------------------

    private void stubGuestRow(ResultSet rs) throws SQLException {
        when(rs.getInt("id")).thenReturn(1);
        when(rs.getString("first_name")).thenReturn("John");
        when(rs.getString("last_name")).thenReturn("Doe");
        when(rs.getString("email")).thenReturn("john@test.com");
        when(rs.getString("phone")).thenReturn("0771234567");
        when(rs.getString("address")).thenReturn("123 Main St");
        when(rs.getString("id_type")).thenReturn("NIC");
        when(rs.getString("id_number")).thenReturn("NIC123");
        when(rs.getTimestamp("registered_at")).thenReturn(null);
    }

    // ---- findAll ----------------------------------------------------------

    @Test
    void findAll_returnsGuests() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        stubGuestRow(rs);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            List<Guest> guests = new GuestDAO().findAll();
            assertEquals(1, guests.size());
            assertEquals("John", guests.get(0).getFirstName());
            assertEquals("Doe",  guests.get(0).getLastName());
            assertEquals("John Doe", guests.get(0).getFullName());
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
            assertTrue(new GuestDAO().findAll().isEmpty());
        }
    }

    // ---- findById ---------------------------------------------------------

    @Test
    void findById_found_returnsGuest() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        stubGuestRow(rs);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            Optional<Guest> result = new GuestDAO().findById(1);
            assertTrue(result.isPresent());
            assertEquals("John Doe", result.get().getFullName());
            assertEquals("john@test.com", result.get().getEmail());
        }
    }

    @Test
    void findById_notFound_returnsEmpty() throws Exception {
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
            assertTrue(new GuestDAO().findById(999).isEmpty());
        }
    }

    // ---- createGuest ------------------------------------------------------

    @Test
    void createGuest_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        Guest g = new Guest("Alice", "Brown", "alice@x.com", "0789999999", "Beach Rd", "Passport", "PP123");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new GuestDAO().createGuest(g));
        }
    }

    @Test
    void createGuest_failure_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        Guest g = new Guest("Bob", "Smith", "", "", "", "", "");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new GuestDAO().createGuest(g));
        }
    }

    // ---- updateGuest ------------------------------------------------------

    @Test
    void updateGuest_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        Guest g = new Guest("John", "Doe", "john@x.com", "0771111111", "New Addr", "NIC", "NIC999");
        g.setId(1);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new GuestDAO().updateGuest(g));
        }
    }

    @Test
    void updateGuest_notFound_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        Guest g = new Guest("X", "Y", "", "", "", "", "");
        g.setId(999);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new GuestDAO().updateGuest(g));
        }
    }

    // ---- sqlException -----------------------------------------------------

    @Test
    void findAll_sqlException_returnsEmptyList() throws Exception {
        Connection conn = mock(Connection.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);
        when(conn.prepareStatement(anyString())).thenThrow(new SQLException("DB down"));

        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(PrintStream.nullOutputStream()));
        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new GuestDAO().findAll().isEmpty());
        } finally {
            System.setErr(originalErr);
        }
    }
}
