package com.example.oceanviewresort.model;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class GuestTest {

    @Test
    void constructor_setsAllFields() {
        Guest g = new Guest("John", "Doe", "john@test.com", "0771234567",
                "123 Main St", "NIC", "NIC123456");
        assertEquals("John",         g.getFirstName());
        assertEquals("Doe",          g.getLastName());
        assertEquals("john@test.com",g.getEmail());
        assertEquals("0771234567",   g.getPhone());
        assertEquals("123 Main St",  g.getAddress());
        assertEquals("NIC",          g.getIdType());
        assertEquals("NIC123456",    g.getIdNumber());
    }

    @Test
    void getFullName_concatenatesFirstAndLastName() {
        Guest g = new Guest("Jane", "Smith", "", "", "", "", "");
        assertEquals("Jane Smith", g.getFullName());
    }

    @Test
    void getFullName_singleWordFirstName() {
        Guest g = new Guest("Madonna", "", "", "", "", "", "");
        assertEquals("Madonna ", g.getFullName());
    }

    @Test
    void setters_updateFields() {
        Guest g = new Guest();
        g.setId(10);
        g.setFirstName("Alice");
        g.setLastName("Brown");
        g.setEmail("alice@example.com");
        g.setPhone("0789999999");
        g.setAddress("456 Ocean Blvd");
        g.setIdType("Passport");
        g.setIdNumber("PP987654");

        assertEquals(10,                  g.getId());
        assertEquals("Alice",             g.getFirstName());
        assertEquals("Brown",             g.getLastName());
        assertEquals("alice@example.com", g.getEmail());
        assertEquals("0789999999",        g.getPhone());
        assertEquals("456 Ocean Blvd",    g.getAddress());
        assertEquals("Passport",          g.getIdType());
        assertEquals("PP987654",          g.getIdNumber());
        assertEquals("Alice Brown",       g.getFullName());
    }

    @Test
    void toString_containsFullName() {
        Guest g = new Guest("Tom", "Hardy", "tom@test.com", "0761234567",
                "789 Resort Rd", "NIC", "NIC999");
        g.setId(3);
        String s = g.toString();
        assertTrue(s.contains("Tom"),   "toString should contain first name");
        assertTrue(s.contains("Hardy"), "toString should contain last name");
    }
}
