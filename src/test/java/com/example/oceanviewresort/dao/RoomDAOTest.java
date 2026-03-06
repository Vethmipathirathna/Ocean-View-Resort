package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.util.DBConnection;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

import java.io.PrintStream;
import java.sql.*;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class RoomDAOTest {

    // ---- helper ----------------------------------------------------------

    private void stubRoomRow(ResultSet rs) throws SQLException {
        when(rs.getInt("id")).thenReturn(1);
        when(rs.getString("room_number")).thenReturn("101");
        when(rs.getString("type")).thenReturn("Deluxe");
        when(rs.getDouble("price_per_night")).thenReturn(150.0);
        when(rs.getInt("capacity")).thenReturn(2);
        when(rs.getString("status")).thenReturn("available");
        when(rs.getString("description")).thenReturn("Sea view");
    }

    // ---- findAll ----------------------------------------------------------

    @Test
    void findAll_returnsRooms() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        stubRoomRow(rs);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            List<Room> rooms = new RoomDAO().findAll();
            assertEquals(1, rooms.size());
            assertEquals("101", rooms.get(0).getRoomNumber());
            assertEquals("Deluxe", rooms.get(0).getType());
            assertEquals(150.0, rooms.get(0).getPricePerNight(), 0.001);
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
            assertTrue(new RoomDAO().findAll().isEmpty());
        }
    }

    // ---- findById ---------------------------------------------------------

    @Test
    void findById_found_returnsRoom() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        stubRoomRow(rs);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            Optional<Room> result = new RoomDAO().findById(1);
            assertTrue(result.isPresent());
            assertEquals(1, result.get().getId());
            assertEquals("101", result.get().getRoomNumber());
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
            assertTrue(new RoomDAO().findById(99).isEmpty());
        }
    }

    // ---- createRoom -------------------------------------------------------

    @Test
    void createRoom_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        Room room = new Room("202", "Suite", 300.0, 4, "available", "Garden view");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new RoomDAO().createRoom(room));
        }
    }

    @Test
    void createRoom_failure_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        Room room = new Room("303", "Standard", 80.0, 1, "available", "");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new RoomDAO().createRoom(room));
        }
    }

    // ---- updateRoom -------------------------------------------------------

    @Test
    void updateRoom_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        Room room = new Room("101", "Deluxe", 175.0, 2, "occupied", "Updated");
        room.setId(1);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new RoomDAO().updateRoom(room));
        }
    }

    @Test
    void updateRoom_notFound_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        Room room = new Room("999", "Suite", 200.0, 2, "available", "");
        room.setId(999);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new RoomDAO().updateRoom(room));
        }
    }

    // ---- sqlException on findAll ------------------------------------------

    @Test
    void findAll_sqlException_returnsEmptyList() throws Exception {
        Connection conn = mock(Connection.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);
        when(conn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(PrintStream.nullOutputStream()));
        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new RoomDAO().findAll().isEmpty());
        } finally {
            System.setErr(originalErr);
        }
    }
}
