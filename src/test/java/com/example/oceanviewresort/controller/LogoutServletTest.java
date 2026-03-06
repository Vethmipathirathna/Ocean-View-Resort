package com.example.oceanviewresort.controller;

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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class LogoutServletTest {

    private LogoutServlet servlet;

    @Mock HttpServletRequest req;
    @Mock HttpServletResponse resp;
    @Mock HttpSession session;

    @BeforeEach
    void setUp() {
        servlet = new LogoutServlet();
    }

    private StringWriter captureResponse() throws Exception {
        StringWriter sw = new StringWriter();
        when(resp.getWriter()).thenReturn(new PrintWriter(sw));
        return sw;
    }

    @Test
    void doPost_withSession_invalidatesSessionAndReturnsSuccess() throws Exception {
        when(req.getSession(false)).thenReturn(session);
        when(req.getContextPath()).thenReturn("/app");
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        verify(session).invalidate();
        assertTrue(sw.toString().contains("\"success\":true"));
        assertTrue(sw.toString().contains("/views/login.jsp"));
    }

    @Test
    void doPost_noSession_returnsSuccessWithoutError() throws Exception {
        when(req.getSession(false)).thenReturn(null);
        when(req.getContextPath()).thenReturn("/app");
        StringWriter sw = captureResponse();

        servlet.doPost(req, resp);

        assertTrue(sw.toString().contains("\"success\":true"));
    }

    @Test
    void doGet_withSession_invalidatesAndRedirects() throws Exception {
        when(req.getSession(false)).thenReturn(session);
        when(req.getContextPath()).thenReturn("/app");

        servlet.doGet(req, resp);

        verify(session).invalidate();
        verify(resp).sendRedirect("/app/views/login.jsp");
    }
}
