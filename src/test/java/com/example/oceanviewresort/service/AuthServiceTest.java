package com.example.oceanviewresort.service;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mindrot.jbcrypt.BCrypt;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserDAO userDAO;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(userDAO);
    }

    // ---- hashPassword tests ----

    @Test
    void hashPassword_returnsNonNullHash() {
        String hash = authService.hashPassword("mySecret");
        assertNotNull(hash);
    }

    @Test
    void hashPassword_producesValidBCryptHash() {
        String plain = "password123";
        String hash = authService.hashPassword(plain);
        assertTrue(BCrypt.checkpw(plain, hash), "Hash should verify against the original password");
    }

    @Test
    void hashPassword_differentCallsProduceDifferentHashes() {
        String hash1 = authService.hashPassword("samePassword");
        String hash2 = authService.hashPassword("samePassword");
        assertNotEquals(hash1, hash2, "BCrypt should produce unique salts each time");
    }

    // ---- authenticate: null / blank guard tests ----

    @Test
    void authenticate_nullUsername_returnsEmpty() {
        Optional<User> result = authService.authenticate(null, "password");
        assertTrue(result.isEmpty());
        verifyNoInteractions(userDAO);
    }

    @Test
    void authenticate_blankUsername_returnsEmpty() {
        Optional<User> result = authService.authenticate("   ", "password");
        assertTrue(result.isEmpty());
        verifyNoInteractions(userDAO);
    }

    @Test
    void authenticate_nullPassword_returnsEmpty() {
        Optional<User> result = authService.authenticate("admin", null);
        assertTrue(result.isEmpty());
        verifyNoInteractions(userDAO);
    }

    @Test
    void authenticate_blankPassword_returnsEmpty() {
        Optional<User> result = authService.authenticate("admin", "");
        assertTrue(result.isEmpty());
        verifyNoInteractions(userDAO);
    }

    // ---- authenticate: user not found ----

    @Test
    void authenticate_unknownUser_returnsEmpty() {
        when(userDAO.findByUsername("unknown")).thenReturn(Optional.empty());
        Optional<User> result = authService.authenticate("unknown", "anyPass");
        assertTrue(result.isEmpty());
    }

    // ---- authenticate: inactive user ----

    @Test
    void authenticate_inactiveUser_returnsEmpty() {
        User inactive = new User("jane", BCrypt.hashpw("pass", BCrypt.gensalt(4)), "Jane", "jane@example.com", "receptionist");
        inactive.setActive(false);
        when(userDAO.findByUsername("jane")).thenReturn(Optional.of(inactive));

        Optional<User> result = authService.authenticate("jane", "pass");
        assertTrue(result.isEmpty());
    }

    // ---- authenticate: wrong password ----

    @Test
    void authenticate_wrongPassword_returnsEmpty() {
        User user = new User("john", BCrypt.hashpw("correctPass", BCrypt.gensalt(4)), "John", "john@example.com", "receptionist");
        when(userDAO.findByUsername("john")).thenReturn(Optional.of(user));

        Optional<User> result = authService.authenticate("john", "wrongPass");
        assertTrue(result.isEmpty());
    }

    // ---- authenticate: valid credentials ----

    @Test
    void authenticate_validCredentials_returnsUser() {
        String plain = "securePass1";
        String hash = BCrypt.hashpw(plain, BCrypt.gensalt(4));
        User user = new User("admin", hash, "Admin User", "admin@resort.com", "ADMIN");

        when(userDAO.findByUsername("admin")).thenReturn(Optional.of(user));

        Optional<User> result = authService.authenticate("admin", plain);
        assertTrue(result.isPresent());
        assertEquals("admin", result.get().getUsername());
        assertEquals("ADMIN", result.get().getRole());
    }

    @Test
    void authenticate_trimsUsernameWhitespace() {
        String plain = "pass";
        String hash = BCrypt.hashpw(plain, BCrypt.gensalt(4));
        User user = new User("admin", hash, "Admin", "admin@resort.com", "ADMIN");

        when(userDAO.findByUsername("admin")).thenReturn(Optional.of(user));

        Optional<User> result = authService.authenticate("  admin  ", plain);
        assertTrue(result.isPresent());
    }
}
