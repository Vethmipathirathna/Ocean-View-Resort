package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

import java.io.PrintStream;
import java.sql.*;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserDAOTest {

    // ---- findByUsername ---------------------------------------------------

    @Test
    void findByUsername_found_returnsUser() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        when(rs.getInt("id")).thenReturn(1);
        when(rs.getString("username")).thenReturn("admin");
        when(rs.getString("password")).thenReturn("hashed");
        when(rs.getString("full_name")).thenReturn("Admin User");
        when(rs.getString("email")).thenReturn("admin@test.com");
        when(rs.getString("role")).thenReturn("ADMIN");
        when(rs.getBoolean("is_active")).thenReturn(true);
        when(rs.getTimestamp("created_at")).thenReturn(null);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            Optional<User> result = new UserDAO().findByUsername("admin");

            assertTrue(result.isPresent());
            assertEquals("admin", result.get().getUsername());
            assertEquals("ADMIN", result.get().getRole());
            assertTrue(result.get().isActive());
        }
    }

    @Test
    void findByUsername_notFound_returnsEmpty() throws Exception {
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
            assertTrue(new UserDAO().findByUsername("nobody").isEmpty());
        }
    }

    @Test
    void findByUsername_sqlException_returnsEmpty() throws Exception {
        Connection conn = mock(Connection.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);
        when(conn.prepareStatement(anyString())).thenThrow(new SQLException("DB down"));

        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(PrintStream.nullOutputStream()));
        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new UserDAO().findByUsername("admin").isEmpty());
        } finally {
            System.setErr(originalErr);
        }
    }

    // ---- hasAnyUser -------------------------------------------------------

    @Test
    void hasAnyUser_returnsTrue_whenCountGreaterThanZero() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true);
        when(rs.getInt(1)).thenReturn(3);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new UserDAO().hasAnyUser());
        }
    }

    @Test
    void hasAnyUser_returnsFalse_whenCountIsZero() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true);
        when(rs.getInt(1)).thenReturn(0);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new UserDAO().hasAnyUser());
        }
    }

    // ---- createUser -------------------------------------------------------

    @Test
    void createUser_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        User user = new User("bob", "hashed", "Bob", "bob@x.com", "RECEPTIONIST");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new UserDAO().createUser(user));
        }
    }

    @Test
    void createUser_failure_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        User user = new User("bob", "hashed", "Bob", "bob@x.com", "RECEPTIONIST");

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new UserDAO().createUser(user));
        }
    }

    // ---- findById ---------------------------------------------------------

    @Test
    void findById_found_returnsUser() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        when(rs.getInt("id")).thenReturn(5);
        when(rs.getString("username")).thenReturn("carol");
        when(rs.getString("password")).thenReturn("pw");
        when(rs.getString("full_name")).thenReturn("Carol");
        when(rs.getString("email")).thenReturn("carol@x.com");
        when(rs.getString("role")).thenReturn("RECEPTIONIST");
        when(rs.getBoolean("is_active")).thenReturn(true);
        when(rs.getTimestamp("created_at")).thenReturn(null);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            Optional<User> result = new UserDAO().findById(5);
            assertTrue(result.isPresent());
            assertEquals(5, result.get().getId());
            assertEquals("carol", result.get().getUsername());
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
            assertTrue(new UserDAO().findById(999).isEmpty());
        }
    }

    // ---- deleteUser -------------------------------------------------------

    @Test
    void deleteUser_success_returnsTrue() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(1);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertTrue(new UserDAO().deleteUser(1));
        }
    }

    @Test
    void deleteUser_notFound_returnsFalse() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeUpdate()).thenReturn(0);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);
            assertFalse(new UserDAO().deleteUser(999));
        }
    }

    // ---- findAllByRole ----------------------------------------------------

    @Test
    void findAllByRole_returnsListOfUsers() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        DBConnection db = mock(DBConnection.class);
        when(db.getConnection()).thenReturn(conn);

        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true, false);
        when(rs.getInt("id")).thenReturn(2);
        when(rs.getString("username")).thenReturn("rec1");
        when(rs.getString("password")).thenReturn("pw");
        when(rs.getString("full_name")).thenReturn("Receptionist One");
        when(rs.getString("email")).thenReturn("r1@x.com");
        when(rs.getString("role")).thenReturn("RECEPTIONIST");
        when(rs.getBoolean("is_active")).thenReturn(true);
        when(rs.getTimestamp("created_at")).thenReturn(null);

        try (MockedStatic<DBConnection> mocked = mockStatic(DBConnection.class)) {
            mocked.when(DBConnection::getInstance).thenReturn(db);

            List<User> users = new UserDAO().findAllByRole("RECEPTIONIST");
            assertEquals(1, users.size());
            assertEquals("rec1", users.get(0).getUsername());
        }
    }

    @Test
    void findAllByRole_emptyTable_returnsEmptyList() throws Exception {
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
            assertTrue(new UserDAO().findAllByRole("ADMIN").isEmpty());
        }
    }
}
