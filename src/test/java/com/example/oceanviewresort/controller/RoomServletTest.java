package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.model.Room;
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
class RoomServletTest {

    private RoomServlet servlet;

    @Mock RoomDAO roomDAO;
    @Mock HttpServletRequest req;
    @Mock HttpServletResponse resp;
    @Mock HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new RoomServlet();
        Field f = RoomServlet.class.getDeclaredField("roomDAO");
        f.setAccessible(true);
        f.set(servlet, roomDAO);
    }

    private StringWriter captureResponse() throws Exception {
        StringWriter sw = new StringWriter();
        when(resp.getWriter()).thenReturn(new PrintWriter(sw));
        return sw;
    }

    /** Stubs a logged-in admin session. */
    private void asAdmin() {
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("role")).thenReturn("admin");
        when(session.getAttribute("loggedInUser")).thenReturn(new Object());
    }

    @Test
    void doGet_noSession_returns401() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(sw.toString().contains("Unauthorized"));
    }

    @Test
    void doGet_loggedIn_returnsJsonArray() throws Exception {
        asAdmin();
        Room room = new Room("101", "Deluxe", 150.0, 2, "available", "Nice room");
        when(roomDAO.findAll()).thenReturn(List.of(room));
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        assertTrue(sw.toString().contains("\"roomNumber\":\"101\""));
    }

    @Test
    void doPost_nonAdmin_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doPost_adminValidData_createsRoom() throws Exception {
        asAdmin();
        when(req.getParameter("roomNumber")).thenReturn("202");
        when(req.getParameter("type")).thenReturn("Suite");
        when(req.getParameter("pricePerNight")).thenReturn("300");
        when(req.getParameter("capacity")).thenReturn("3");
        when(req.getParameter("status")).thenReturn("available");
        when(req.getParameter("description")).thenReturn("Luxury");
        when(roomDAO.createRoom(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(roomDAO).createRoom(any());
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doPut_nonAdmin_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doPut(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doPut_adminValidData_updatesRoom() throws Exception {
        asAdmin();
        String body = "id=1&roomNumber=101&type=Deluxe&pricePerNight=200.0&capacity=2&status=available&description=Nice";
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader(body)));
        when(roomDAO.updateRoom(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPut(req, resp);

        verify(roomDAO).updateRoom(any());
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
    void doDelete_adminValidId_deletesRoom() throws Exception {
        asAdmin();
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader("id=1")));
        when(roomDAO.deleteRoom(1)).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doDelete(req, resp);

        verify(roomDAO).deleteRoom(1);
        assertTrue(sw.toString().contains("\"success\":true"));
    }
}
