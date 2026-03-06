package com.example.oceanviewresort.model;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;

import static org.junit.jupiter.api.Assertions.*;

class RoomTest {

    @Test
    void constructor_setsAllFields() {
        Room r = new Room("101", "Deluxe", 150.0, 2, "available", "Sea view");
        assertEquals("101",       r.getRoomNumber());
        assertEquals("Deluxe",    r.getType());
        assertEquals(150.0,       r.getPricePerNight(), 0.001);
        assertEquals(2,           r.getCapacity());
        assertEquals("available", r.getStatus());
        assertEquals("Sea view",  r.getDescription());
    }

    @Test
    void defaultConstructor_noExceptions() {
        assertDoesNotThrow((Executable) Room::new);
    }

    @Test
    void setters_updateFields() {
        Room r = new Room();
        r.setId(5);
        r.setRoomNumber("202");
        r.setType("Suite");
        r.setPricePerNight(300.50);
        r.setCapacity(4);
        r.setStatus("occupied");
        r.setDescription("Garden view");

        assertEquals(5,           r.getId());
        assertEquals("202",       r.getRoomNumber());
        assertEquals("Suite",     r.getType());
        assertEquals(300.50,      r.getPricePerNight(), 0.001);
        assertEquals(4,           r.getCapacity());
        assertEquals("occupied",  r.getStatus());
        assertEquals("Garden view", r.getDescription());
    }

    @Test
    void pricePerNight_acceptsDecimalPrecision() {
        Room r = new Room("103", "Standard", 99.99, 1, "available", "");
        assertEquals(99.99, r.getPricePerNight(), 0.001);
    }

    @Test
    void capacity_zeroIsAllowed() {
        Room r = new Room();
        r.setCapacity(0);
        assertEquals(0, r.getCapacity());
    }

    @Test
    void statusValues_matchExpectedConstants() {
        String[] validStatuses = {"available", "occupied", "maintenance"};
        for (String status : validStatuses) {
            Room r = new Room("100", "Standard", 80.0, 2, status, "");
            assertEquals(status, r.getStatus());
        }
    }

    @Test
    void toString_containsRoomNumber() {
        Room r = new Room("305", "Suite", 250.0, 3, "available", "Top floor");
        r.setId(9);
        String s = r.toString();
        assertTrue(s.contains("305"),  "toString should contain room number");
        assertTrue(s.contains("Suite"), "toString should contain type");
    }
}
