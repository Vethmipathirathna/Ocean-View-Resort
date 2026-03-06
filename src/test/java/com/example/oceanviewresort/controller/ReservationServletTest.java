package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.model.Reservation;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class ReservationServletTest {

    private ReservationServlet servlet;

    @Mock ReservationDAO reservationDAO;
    @Mock RoomDAO roomDAO;
    @Mock HttpServletRequest req;
    @Mock HttpServletResponse resp;
    @Mock HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new ReservationServlet();
        Field f1 = ReservationServlet.class.getDeclaredField("reservationDAO");
        f1.setAccessible(true);
        f1.set(servlet, reservationDAO);
        Field f2 = ReservationServlet.class.getDeclaredField("roomDAO");
        f2.setAccessible(true);
        f2.set(servlet, roomDAO);
    }

    private StringWriter captureResponse() throws Exception {
        StringWriter sw = new StringWriter();
        when(resp.getWriter()).thenReturn(new PrintWriter(sw));
        return sw;
    }

    private void asAdmin() {
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("role")).thenReturn("admin");
        when(session.getAttribute("loggedInUser")).thenReturn(new Object());
    }

    @Test
    void doGet_notLoggedIn_returns401() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    }

    @Test
    void doGet_loggedIn_returnsReservationList() throws Exception {
        asAdmin();
        Reservation r = new Reservation();
        r.setId(1);
        r.setGuestName("Jane Doe");
        when(reservationDAO.findAll()).thenReturn(List.of(r));
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        assertTrue(sw.toString().contains("\"id\":1"));
    }

    @Test
    void doPost_noAccess_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doPost_validData_createsReservation() throws Exception {
        asAdmin();
        when(req.getParameter("guestId")).thenReturn("1");
        when(req.getParameter("roomId")).thenReturn("2");
        when(req.getParameter("checkInDate")).thenReturn("2026-04-01");
        when(req.getParameter("checkOutDate")).thenReturn("2026-04-05");
        when(req.getParameter("totalPrice")).thenReturn("400");
        when(req.getParameter("status")).thenReturn("confirmed");
        when(req.getParameter("notes")).thenReturn("");
        when(reservationDAO.createReservation(any())).thenReturn(10);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(reservationDAO).createReservation(any());
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doPut_validData_updatesReservation() throws Exception {
        asAdmin();
        String body = "id=1&roomId=2&checkInDate=2026-04-01&checkOutDate=2026-04-05&totalPrice=400&status=confirmed&notes=";
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader(body)));
        when(reservationDAO.updateReservation(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPut(req, resp);

        verify(reservationDAO).updateReservation(any());
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doDelete_nonAdmin_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doDelete(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doDelete_adminValidId_deletesReservation() throws Exception {
        asAdmin();
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader("id=1")));
        when(reservationDAO.deleteReservation(1)).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doDelete(req, resp);

        verify(reservationDAO).deleteReservation(1);
        assertTrue(sw.toString().contains("\"success\":true"));
    }
}
