package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.GuestDAO;
import com.example.oceanviewresort.model.Guest;
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
class GuestServletTest {

    private GuestServlet servlet;

    @Mock GuestDAO guestDAO;
    @Mock HttpServletRequest req;
    @Mock HttpServletResponse resp;
    @Mock HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new GuestServlet();
        Field f = GuestServlet.class.getDeclaredField("guestDAO");
        f.setAccessible(true);
        f.set(servlet, guestDAO);
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
    void doGet_loggedIn_returnsGuestList() throws Exception {
        asAdmin();
        Guest g = new Guest("Jane", "Doe", "jane@test.com", "555-1234", "", "", "");
        when(guestDAO.findAll()).thenReturn(List.of(g));
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        assertTrue(sw.toString().contains("\"firstName\":\"Jane\""));
    }

    @Test
    void doPost_noAccess_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doPost_validData_createsGuest() throws Exception {
        asAdmin();
        when(req.getParameter("firstName")).thenReturn("Jane");
        when(req.getParameter("lastName")).thenReturn("Doe");
        when(req.getParameter("email")).thenReturn("jane@test.com");
        when(req.getParameter("phone")).thenReturn("555-1234");
        when(req.getParameter("address")).thenReturn("");
        when(req.getParameter("idType")).thenReturn("");
        when(req.getParameter("idNumber")).thenReturn("");
        when(guestDAO.createGuest(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(guestDAO).createGuest(any());
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doPut_validData_updatesGuest() throws Exception {
        asAdmin();
        String body = "id=1&firstName=Jane&lastName=Smith&email=j@test.com&phone=555&address=&idType=&idNumber=";
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader(body)));
        when(guestDAO.updateGuest(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPut(req, resp);

        verify(guestDAO).updateGuest(any());
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doDelete_validId_deletesGuest() throws Exception {
        asAdmin();
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader("id=1")));
        when(guestDAO.deleteGuest(1)).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doDelete(req, resp);

        verify(guestDAO).deleteGuest(1);
        assertTrue(sw.toString().contains("\"success\":true"));
    }
}
