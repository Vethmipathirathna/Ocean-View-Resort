package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.model.User;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Handles admin receptionist management.
 * GET    /api/receptionist -> list all receptionists (JSON)
 * POST   /api/receptionist -> add new receptionist
 * PUT    /api/receptionist -> update receptionist
 * DELETE /api/receptionist -> delete receptionist
 */
@WebServlet(name = "ReceptionistServlet", urlPatterns = "/api/receptionist")
public class ReceptionistServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /** Only admin can call these endpoints */
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        String role = (String) session.getAttribute("role");
        return "admin".equalsIgnoreCase(role);
    }

    /**
     * Parses application/x-www-form-urlencoded body for methods like PUT/DELETE
     * where getParameter() does not read the body.
     */
    private Map<String, String> parseBody(HttpServletRequest req) throws IOException {
        Map<String, String> params = new HashMap<>();
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String body = sb.toString();
        if (body == null || body.isEmpty()) return params;
        for (String pair : body.split("&")) {
            String[] kv = pair.split("=", 2);
            if (kv.length == 2) {
                String key   = URLDecoder.decode(kv[0], StandardCharsets.UTF_8);
                String value = URLDecoder.decode(kv[1], StandardCharsets.UTF_8);
                params.put(key, value);
            } else if (kv.length == 1) {
                params.put(URLDecoder.decode(kv[0], StandardCharsets.UTF_8), "");
            }
        }
        return params;
    }

    private void writeJson(HttpServletResponse resp, JsonObject json) throws IOException {
        try (PrintWriter out = resp.getWriter()) {
            out.print(json.toString());
        }
    }

    // ---- GET: list receptionists ----------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().print("{\"error\":\"Access denied\"}");
            return;
        }
        List<User> list = userDAO.findAllByRole("receptionist");
        JsonArray arr = new JsonArray();
        for (User u : list) {
            JsonObject o = new JsonObject();
            o.addProperty("id",       u.getId());
            o.addProperty("username", u.getUsername());
            o.addProperty("fullName", u.getFullName());
            o.addProperty("email",    u.getEmail() != null ? u.getEmail() : "");
            o.addProperty("role",     u.getRole());
            o.addProperty("active",   u.isActive());
            arr.add(o);
        }
        try (PrintWriter out = resp.getWriter()) {
            out.print(arr.toString());
        }
    }

    // ---- POST: add receptionist -----------------------------------------

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject json = new JsonObject();

        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            json.addProperty("success", false);
            json.addProperty("message", "Access denied");
            writeJson(resp, json);
            return;
        }

        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (isBlank(username) || isBlank(fullName) || isBlank(password)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Username, full name, and password are required.");
            writeJson(resp, json);
            return;
        }

        if (userDAO.findByUsername(username.trim()).isPresent()) {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            json.addProperty("success", false);
            json.addProperty("message", "Username already exists.");
            writeJson(resp, json);
            return;
        }

        User newUser = new User();
        newUser.setUsername(username.trim());
        newUser.setFullName(fullName.trim());
        newUser.setEmail(email != null ? email.trim() : "");
        newUser.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        newUser.setRole("receptionist");
        newUser.setActive(true);

        boolean created = userDAO.createUser(newUser);
        if (created) {
            json.addProperty("success", true);
            json.addProperty("message", "Receptionist added successfully.");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            json.addProperty("success", false);
            json.addProperty("message", "Failed to save receptionist. Try again.");
        }
        writeJson(resp, json);
    }

    // ---- PUT: update receptionist ---------------------------------------

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject json = new JsonObject();

        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            json.addProperty("success", false);
            json.addProperty("message", "Access denied");
            writeJson(resp, json);
            return;
        }

        // jQuery sends PUT body as form-encoded  must parse manually
        Map<String, String> params = parseBody(req);
        String idStr    = params.get("id");
        String fullName = params.get("fullName");
        String email    = params.get("email");
        String password = params.get("password");

        if (isBlank(idStr)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Missing receptionist ID.");
            writeJson(resp, json);
            return;
        }

        int id;
        try { id = Integer.parseInt(idStr.trim()); }
        catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Invalid ID.");
            writeJson(resp, json);
            return;
        }

        User existing = userDAO.findById(id).orElse(null);
        if (existing == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            json.addProperty("success", false);
            json.addProperty("message", "Receptionist not found.");
            writeJson(resp, json);
            return;
        }

        if (!isBlank(fullName)) existing.setFullName(fullName.trim());
        if (!isBlank(email))    existing.setEmail(email.trim());
        if (!isBlank(password)) existing.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
        // Clear hashed password field so updateUser only changes what's needed
        else                    existing.setPassword(null);

        boolean updated = userDAO.updateUser(existing);
        json.addProperty("success", updated);
        json.addProperty("message", updated ? "Receptionist updated." : "Update failed.");
        writeJson(resp, json);
    }

    // ---- DELETE: remove receptionist ------------------------------------

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject json = new JsonObject();

        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            json.addProperty("success", false);
            json.addProperty("message", "Access denied");
            writeJson(resp, json);
            return;
        }

        // jQuery sends DELETE body as form-encoded  must parse manually
        Map<String, String> params = parseBody(req);
        String idStr = params.get("id");

        // Also accept id as query param (fallback)
        if (isBlank(idStr)) idStr = req.getParameter("id");

        if (isBlank(idStr)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Missing ID.");
            writeJson(resp, json);
            return;
        }

        int id;
        try { id = Integer.parseInt(idStr.trim()); }
        catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Invalid ID.");
            writeJson(resp, json);
            return;
        }

        boolean deleted = userDAO.deleteUser(id);
        json.addProperty("success", deleted);
        json.addProperty("message", deleted ? "Receptionist deleted." : "Delete failed.");
        writeJson(resp, json);
    }

    // ---- Helper ---------------------------------------------------------

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}