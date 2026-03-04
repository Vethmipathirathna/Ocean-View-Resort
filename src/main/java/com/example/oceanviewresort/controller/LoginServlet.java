package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.AuthService;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Optional;

/**
 * POST /api/login  - authenticates user and returns JSON with redirect URL.
 * Admin   -> /views/dashboard.jsp
 * Receptionist -> /views/receptionist-dashboard.jsp
 */
@WebServlet(name = "LoginServlet", urlPatterns = "/api/login")
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
    }

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

            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", user);
            session.setAttribute("username",     user.getUsername());
            session.setAttribute("fullName",     user.getFullName());
            session.setAttribute("role",         user.getRole());
            session.setMaxInactiveInterval(30 * 60);

            // Choose redirect page based on role
            String redirectPage;
            if ("receptionist".equalsIgnoreCase(user.getRole())) {
                redirectPage = req.getContextPath() + "/views/receptionist-dashboard.jsp";
            } else {
                redirectPage = req.getContextPath() + "/views/dashboard.jsp";
            }

            json.addProperty("success",  true);
            json.addProperty("message",  "Login successful. Welcome, " + user.getFullName() + "!");
            json.addProperty("role",     user.getRole());
            json.addProperty("redirect", redirectPage);

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
