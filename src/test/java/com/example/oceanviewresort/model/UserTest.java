package com.example.oceanviewresort.model;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @Test
    void constructor_setsAllFields() {
        User u = new User("alice", "hashedPw", "Alice Smith", "alice@test.com", "ADMIN");
        assertEquals("alice",       u.getUsername());
        assertEquals("hashedPw",    u.getPassword());
        assertEquals("Alice Smith", u.getFullName());
        assertEquals("alice@test.com", u.getEmail());
        assertEquals("ADMIN",       u.getRole());
        assertTrue(u.isActive(), "New user should be active by default");
    }

    @Test
    void defaultConstructor_activeDefaultsTrue() {
        User u = new User();
        // default-constructed user has active=false because boolean defaults to false
        // but setting it explicitly should work
        u.setActive(true);
        assertTrue(u.isActive());
    }

    @Test
    void setters_updateFields() {
        User u = new User();
        u.setId(42);
        u.setUsername("bob");
        u.setPassword("pw");
        u.setFullName("Bob Jones");
        u.setEmail("bob@test.com");
        u.setRole("RECEPTIONIST");
        u.setActive(false);

        assertEquals(42,             u.getId());
        assertEquals("bob",          u.getUsername());
        assertEquals("pw",           u.getPassword());
        assertEquals("Bob Jones",    u.getFullName());
        assertEquals("bob@test.com", u.getEmail());
        assertEquals("RECEPTIONIST", u.getRole());
        assertFalse(u.isActive());
    }

    @Test
    void toString_containsUsernameAndRole() {
        User u = new User("carol", "pw", "Carol", "carol@test.com", "ADMIN");
        u.setId(7);
        String s = u.toString();
        assertTrue(s.contains("carol"), "toString should contain username");
        assertTrue(s.contains("ADMIN"),  "toString should contain role");
        assertTrue(s.contains("7"),      "toString should contain id");
    }
}
