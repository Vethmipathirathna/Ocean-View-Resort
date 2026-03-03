package com.example.oceanviewresort.controller;

import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * LogoutServlet — invalidates the current session and returns JSON.
 *
 * POST /api/logout
 * Response: { "success": true, "redirect": "/views/login.jsp" }
 */
@WebServlet(name = "LogoutServlet", urlPatterns = "/api/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Invalidate session
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JsonObject json = new JsonObject();
        json.addProperty("success",  true);
        json.addProperty("message",  "You have been logged out successfully.");
        json.addProperty("redirect", req.getContextPath() + "/views/login.jsp");

        try (PrintWriter out = resp.getWriter()) {
            out.print(json.toString());
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Support direct GET logout too
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
    }
}
