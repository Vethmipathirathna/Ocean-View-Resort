package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.AuthService;
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

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class LoginServletTest {

    private LoginServlet servlet;

    @Mock AuthService authService;
    @Mock HttpServletRequest req;
    @Mock HttpServletResponse resp;
    @Mock HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new LoginServlet();
        Field f = LoginServlet.class.getDeclaredField("authService");
        f.setAccessible(true);
        f.set(servlet, authService);
    }

    private StringWriter captureResponse() throws Exception {
        StringWriter sw = new StringWriter();
        when(resp.getWriter()).thenReturn(new PrintWriter(sw));
        return sw;
    }

    @Test
    void doGet_redirectsToLoginPage() throws Exception {
        when(req.getContextPath()).thenReturn("/app");
        servlet.doGet(req, resp);
        verify(resp).sendRedirect("/app/views/login.jsp");
    }

    @Test
    void doPost_validCredentials_setsSessionAndReturnsSuccess() throws Exception {
        User user = new User();
        user.setUsername("admin");
        user.setRole("admin");
        user.setFullName("Admin User");
        when(req.getParameter("username")).thenReturn("admin");
        when(req.getParameter("password")).thenReturn("pass");
        when(authService.authenticate("admin", "pass")).thenReturn(Optional.of(user));
        when(req.getSession(true)).thenReturn(session);
        when(req.getContextPath()).thenReturn("/app");
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(session).setAttribute("loggedInUser", user);
        verify(session).setAttribute("role", "admin");
        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doPost_invalidCredentials_returns401AndFailureMessage() throws Exception {
        when(req.getParameter("username")).thenReturn("bad");
        when(req.getParameter("password")).thenReturn("wrong");
        when(authService.authenticate("bad", "wrong")).thenReturn(Optional.empty());
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(resp).setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        assertTrue(sw.toString().contains("\"success\":false"));
    }
}
