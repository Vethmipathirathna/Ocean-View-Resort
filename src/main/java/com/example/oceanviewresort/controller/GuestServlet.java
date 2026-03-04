package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.GuestDAO;
import com.example.oceanviewresort.model.Guest;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST API for guest management.
 * GET    /api/guest  -> list all guests (JSON)
 * POST   /api/guest  -> register new guest
 * PUT    /api/guest  -> update guest
 * DELETE /api/guest  -> delete guest
 */
@WebServlet(name = "GuestServlet", urlPatterns = "/api/guest")
public class GuestServlet extends HttpServlet {

    private final GuestDAO guestDAO = new GuestDAO();

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("loggedInUser") != null;
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        String role = (String) s.getAttribute("role");
        return "admin".equalsIgnoreCase(role);
    }

    private Map<String, String> parseBody(HttpServletRequest req) throws IOException {
        Map<String, String> params = new HashMap<>();
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        for (String pair : sb.toString().split("&")) {
            String[] kv = pair.split("=", 2);
            if (kv.length == 2) {
                params.put(
                    URLDecoder.decode(kv[0], StandardCharsets.UTF_8),
                    URLDecoder.decode(kv[1], StandardCharsets.UTF_8)
                );
            }
        }
        return params;
    }

    private void json(HttpServletResponse resp) {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
    }

    // ---- GET: list all guests ----
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        if (!isLoggedIn(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        List<Guest> guests = guestDAO.findAll();
        JsonArray arr = new JsonArray();
        for (Guest g : guests) {
            JsonObject o = new JsonObject();
            o.addProperty("id",          g.getId());
            o.addProperty("firstName",   g.getFirstName());
            o.addProperty("lastName",    g.getLastName());
            o.addProperty("fullName",    g.getFullName());
            o.addProperty("email",       g.getEmail()    != null ? g.getEmail()    : "");
            o.addProperty("phone",       g.getPhone()    != null ? g.getPhone()    : "");
            o.addProperty("address",     g.getAddress()  != null ? g.getAddress()  : "");
            o.addProperty("idType",      g.getIdType()   != null ? g.getIdType()   : "");
            o.addProperty("idNumber",    g.getIdNumber() != null ? g.getIdNumber() : "");
            arr.add(o);
        }
        resp.getWriter().write(arr.toString());
    }

    // ---- POST: register guest ----
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        PrintWriter out = resp.getWriter();
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"success\":false,\"message\":\"Admin access required.\"}");
            return;
        }
        String firstName = req.getParameter("firstName");
        String lastName  = req.getParameter("lastName");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phone");
        String address   = req.getParameter("address");
        String idType    = req.getParameter("idType");
        String idNumber  = req.getParameter("idNumber");

        if (firstName == null || firstName.isBlank() || lastName == null || lastName.isBlank()) {
            out.write("{\"success\":false,\"message\":\"First name and last name are required.\"}");
            return;
        }
        Guest g = new Guest(firstName.trim(), lastName.trim(),
                            email != null ? email.trim() : "",
                            phone != null ? phone.trim() : "",
                            address != null ? address.trim() : "",
                            idType != null ? idType.trim() : "",
                            idNumber != null ? idNumber.trim() : "");
        boolean ok = guestDAO.createGuest(g);
        if (ok) out.write("{\"success\":true,\"message\":\"Guest registered successfully.\"}");
        else    out.write("{\"success\":false,\"message\":\"Failed to register guest.\"}");
    }

    // ---- PUT: update guest ----
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        PrintWriter out = resp.getWriter();
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"success\":false,\"message\":\"Admin access required.\"}");
            return;
        }
        Map<String, String> p = parseBody(req);
        String idStr     = p.get("id");
        String firstName = p.get("firstName");
        String lastName  = p.get("lastName");

        if (idStr == null || idStr.isBlank()) {
            out.write("{\"success\":false,\"message\":\"Guest ID is required.\"}"); return;
        }
        if (firstName == null || firstName.isBlank() || lastName == null || lastName.isBlank()) {
            out.write("{\"success\":false,\"message\":\"First name and last name are required.\"}"); return;
        }
        int id;
        try { id = Integer.parseInt(idStr.trim()); }
        catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"Invalid guest ID.\"}"); return;
        }
        Guest g = new Guest();
        g.setId       (id);
        g.setFirstName(firstName.trim());
        g.setLastName (lastName.trim());
        g.setEmail    (p.getOrDefault("email",    "").trim());
        g.setPhone    (p.getOrDefault("phone",    "").trim());
        g.setAddress  (p.getOrDefault("address",  "").trim());
        g.setIdType   (p.getOrDefault("idType",   "").trim());
        g.setIdNumber (p.getOrDefault("idNumber", "").trim());

        boolean ok = guestDAO.updateGuest(g);
        if (ok) out.write("{\"success\":true,\"message\":\"Guest updated successfully.\"}");
        else    out.write("{\"success\":false,\"message\":\"Failed to update guest.\"}");
    }

    // ---- DELETE: delete guest ----
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        PrintWriter out = resp.getWriter();
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"success\":false,\"message\":\"Admin access required.\"}"); return;
        }
        Map<String, String> p = parseBody(req);
        String idStr = p.get("id");
        if (idStr == null || idStr.isBlank()) {
            out.write("{\"success\":false,\"message\":\"Guest ID is required.\"}"); return;
        }
        int id;
        try { id = Integer.parseInt(idStr.trim()); }
        catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"Invalid guest ID.\"}"); return;
        }
        boolean ok = guestDAO.deleteGuest(id);
        if (ok) out.write("{\"success\":true,\"message\":\"Guest deleted.\"}");
        else    out.write("{\"success\":false,\"message\":\"Failed to delete guest.\"}");
    }
}
