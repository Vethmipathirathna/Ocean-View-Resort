package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.AuthService;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Optional;

/**
 * REST-style LoginServlet.
 *
 * POST /api/login
 *  Body (form params): username, password
 *  Response (JSON):
 *    { "success": true,  "message": "...", "role": "ADMIN", "redirect": "/views/dashboard.jsp" }
 *    { "success": false, "message": "..." }
 */
@WebServlet(name = "LoginServlet", urlPatterns = "/api/login")
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    /** GET — redirect to login page */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
    }

    /** POST — authenticate and return JSON */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        JsonObject json = new JsonObject();

        Optional<User> result = authService.authenticate(username, password);

        if (result.isPresent()) {
            User user = result.get();

            // Store user info in session
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", user);
            session.setAttribute("username",     user.getUsername());
            session.setAttribute("fullName",     user.getFullName());
            session.setAttribute("role",         user.getRole());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            json.addProperty("success",  true);
            json.addProperty("message",  "Login successful. Welcome, " + user.getFullName() + "!");
            json.addProperty("role",     user.getRole());
            json.addProperty("redirect", req.getContextPath() + "/views/dashboard.jsp");

        } else {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("message", "Invalid username or password. Please try again.");
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(json.toString());
            out.flush();
        }
    }
}
