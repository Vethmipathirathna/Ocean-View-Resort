package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.model.User;
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
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class ReceptionistServletTest {

    private ReceptionistServlet servlet;

    @Mock UserDAO userDAO;
    @Mock HttpServletRequest req;
    @Mock HttpServletResponse resp;
    @Mock HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new ReceptionistServlet();
        Field f = ReceptionistServlet.class.getDeclaredField("userDAO");
        f.setAccessible(true);
        f.set(servlet, userDAO);
    }

    private StringWriter captureResponse() throws Exception {
        StringWriter sw = new StringWriter();
        when(resp.getWriter()).thenReturn(new PrintWriter(sw));
        return sw;
    }

    private void asAdmin() {
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("role")).thenReturn("admin");
    }

    @Test
    void doGet_nonAdmin_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doGet_admin_returnsReceptionistList() throws Exception {
        asAdmin();
        User u = new User();
        u.setId(1);
        u.setUsername("rec1");
        u.setFullName("Reception One");
        u.setRole("receptionist");
        when(userDAO.findAllByRole("receptionist")).thenReturn(List.of(u));
        StringWriter sw = captureResponse();

        servlet.doGet(req, resp);

        assertTrue(sw.toString().contains("\"username\":\"rec1\""));
    }

    @Test
    void doPost_nonAdmin_returns403() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_FORBIDDEN);
    }

    @Test
    void doPost_adminValidData_createsReceptionist() throws Exception {
        asAdmin();
        when(req.getParameter("username")).thenReturn("rec_new");
        when(req.getParameter("fullName")).thenReturn("New Receptionist");
        when(req.getParameter("email")).thenReturn("rec@hotel.com");
        when(req.getParameter("password")).thenReturn("pass123");
        when(userDAO.findByUsername("rec_new")).thenReturn(Optional.empty());
        when(userDAO.createUser(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(userDAO).createUser(any());
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doPut_adminValidData_updatesReceptionist() throws Exception {
        asAdmin();
        User existing = new User();
        existing.setId(1);
        existing.setUsername("rec1");
        existing.setFullName("Old Name");
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader(
                "id=1&fullName=New+Name&email=new@hotel.com&password=")));
        when(userDAO.findById(1)).thenReturn(Optional.of(existing));
        when(userDAO.updateUser(any())).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doPut(req, resp);

        verify(userDAO).updateUser(any());
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
    void doDelete_adminValidId_deletesReceptionist() throws Exception {
        asAdmin();
        when(req.getReader()).thenReturn(new BufferedReader(new StringReader("id=1")));
        when(userDAO.deleteUser(1)).thenReturn(true);
        StringWriter sw = captureResponse();

        servlet.doDelete(req, resp);

        verify(userDAO).deleteUser(1);
        assertTrue(sw.toString().contains("\"success\":true"));
    }
}
