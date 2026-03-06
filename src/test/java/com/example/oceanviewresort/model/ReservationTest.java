package com.example.oceanviewresort.model;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class ReservationTest {

    @Test
    void defaultConstructor_noExceptions() {
        assertDoesNotThrow((Executable) Reservation::new);
    }

    @Test
    void setters_andGetters_forCoreFields() {
        Reservation r = new Reservation();
        r.setId(1);
        r.setGuestId(10);
        r.setRoomId(5);
        r.setStatus("confirmed");
        r.setNotes("Late check-in");
        r.setTotalPrice(new BigDecimal("450.00"));

        assertEquals(1,                     r.getId());
        assertEquals(10,                    r.getGuestId());
        assertEquals(5,                     r.getRoomId());
        assertEquals("confirmed",           r.getStatus());
        assertEquals("Late check-in",       r.getNotes());
        assertEquals(new BigDecimal("450.00"), r.getTotalPrice());
    }

    @Test
    void setCheckInDate_andGetCheckInDate() {
        Reservation r = new Reservation();
        LocalDate checkIn = LocalDate.of(2025, 7, 15);
        r.setCheckInDate(checkIn);
        assertEquals(checkIn, r.getCheckInDate());
    }

    @Test
    void setCheckOutDate_andGetCheckOutDate() {
        Reservation r = new Reservation();
        LocalDate checkOut = LocalDate.of(2025, 7, 20);
        r.setCheckOutDate(checkOut);
        assertEquals(checkOut, r.getCheckOutDate());
    }

    @Test
    void checkOut_isAfterCheckIn() {
        Reservation r = new Reservation();
        LocalDate checkIn  = LocalDate.of(2025, 8, 1);
        LocalDate checkOut = LocalDate.of(2025, 8, 5);
        r.setCheckInDate(checkIn);
        r.setCheckOutDate(checkOut);
        assertTrue(r.getCheckOutDate().isAfter(r.getCheckInDate()));
    }

    @Test
    void totalPrice_acceptsBigDecimalPrecision() {
        Reservation r = new Reservation();
        BigDecimal price = new BigDecimal("1234.56");
        r.setTotalPrice(price);
        assertEquals(0, price.compareTo(r.getTotalPrice()));
    }

    @Test
    void statusValues_coverAllExpectedStates() {
        String[] statuses = {"pending", "confirmed", "cancelled", "checked_in", "checked_out"};
        Reservation r = new Reservation();
        for (String s : statuses) {
            r.setStatus(s);
            assertEquals(s, r.getStatus());
        }
    }

    @Test
    void displayFields_forJoinedData() {
        Reservation r = new Reservation();
        r.setGuestName("John Doe");
        r.setRoomNumber("205");
        r.setGuestEmail("john@test.com");
        r.setGuestPhone("0771234567");

        assertEquals("John Doe",       r.getGuestName());
        assertEquals("205",            r.getRoomNumber());
        assertEquals("john@test.com",  r.getGuestEmail());
        assertEquals("0771234567",     r.getGuestPhone());
    }

    @Test
    void createdAt_setterAndGetter() {
        Reservation r = new Reservation();
        LocalDateTime now = LocalDateTime.of(2025, 6, 1, 12, 0);
        r.setCreatedAt(now);
        assertEquals(now, r.getCreatedAt());
    }
}
