package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.model.Room;
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
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST API for room management (admin only for write operations).
 * GET    /api/room  -> list all rooms (JSON)
 * POST   /api/room  -> add new room
 * PUT    /api/room  -> update room
 * DELETE /api/room  -> delete room
 */
@WebServlet(name = "RoomServlet", urlPatterns = "/api/room")
public class RoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    /** Only admin can mutate rooms */
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        String role = (String) session.getAttribute("role");
        return "admin".equalsIgnoreCase(role);
    }

    /** Parses URL-encoded body for PUT/DELETE (getParameter() doesn't read body for those). */
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

    // ---- GET: list all rooms ----
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);

        // Must be logged in
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        List<Room> rooms;
        String checkInStr  = req.getParameter("checkIn");
        String checkOutStr = req.getParameter("checkOut");
        String excludeStr  = req.getParameter("excludeRes");

        if (checkInStr != null && !checkInStr.isEmpty() && checkOutStr != null && !checkOutStr.isEmpty()) {
            int excludeId = (excludeStr != null && !excludeStr.isEmpty()) ? Integer.parseInt(excludeStr) : -1;
            rooms = roomDAO.findAvailableForDates(
                    LocalDate.parse(checkInStr), LocalDate.parse(checkOutStr), excludeId);
        } else {
            rooms = roomDAO.findAll();
        }

        JsonArray arr = new JsonArray();
        for (Room r : rooms) {
            JsonObject o = new JsonObject();
            o.addProperty("id",            r.getId());
            o.addProperty("roomNumber",    r.getRoomNumber());
            o.addProperty("type",          r.getType());
            o.addProperty("pricePerNight", r.getPricePerNight());
            o.addProperty("capacity",      r.getCapacity());
            o.addProperty("status",        r.getStatus());
            o.addProperty("description",   r.getDescription() != null ? r.getDescription() : "");
            arr.add(o);
        }
        resp.getWriter().write(arr.toString());
    }

    // ---- POST: add room ----
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

        String roomNumber = req.getParameter("roomNumber");
        String type       = req.getParameter("type");
        String priceStr   = req.getParameter("pricePerNight");
        String capStr     = req.getParameter("capacity");
        String status     = req.getParameter("status");
        String desc       = req.getParameter("description");

        if (roomNumber == null || roomNumber.isBlank() || type == null || type.isBlank()) {
            out.write("{\"success\":false,\"message\":\"Room number and type are required.\"}");
            return;
        }

        double price = 0;
        int capacity = 1;
        try { price    = Double.parseDouble(priceStr); } catch (Exception ignored) {}
        try { capacity = Integer.parseInt(capStr);     } catch (Exception ignored) {}

        Room room = new Room(roomNumber.trim(), type.trim(), price, capacity,
                             status != null ? status : "available",
                             desc != null ? desc.trim() : "");

        boolean ok = roomDAO.createRoom(room);
        if (ok) {
            out.write("{\"success\":true,\"message\":\"Room added successfully.\"}");
        } else {
            out.write("{\"success\":false,\"message\":\"Failed to add room. Room number may already exist.\"}");
        }
    }

    // ---- PUT: update room ----
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
        String idStr      = p.get("id");
        String roomNumber = p.get("roomNumber");
        String type       = p.get("type");
        String priceStr   = p.get("pricePerNight");
        String capStr     = p.get("capacity");
        String status     = p.get("status");
        String desc       = p.get("description");

        if (idStr == null || idStr.isBlank()) {
            out.write("{\"success\":false,\"message\":\"Room ID is required.\"}");
            return;
        }

        int id;
        try { id = Integer.parseInt(idStr.trim()); }
        catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"Invalid room ID.\"}");
            return;
        }

        double price = 0;
        int capacity = 1;
        try { price    = Double.parseDouble(priceStr); } catch (Exception ignored) {}
        try { capacity = Integer.parseInt(capStr);     } catch (Exception ignored) {}

        Room room = new Room();
        room.setId(id);
        room.setRoomNumber  (roomNumber != null ? roomNumber.trim() : "");
        room.setType        (type       != null ? type.trim()       : "");
        room.setPricePerNight(price);
        room.setCapacity    (capacity);
        room.setStatus      (status     != null ? status            : "available");
        room.setDescription (desc       != null ? desc.trim()       : "");

        boolean ok = roomDAO.updateRoom(room);
        if (ok) {
            out.write("{\"success\":true,\"message\":\"Room updated successfully.\"}");
        } else {
            out.write("{\"success\":false,\"message\":\"Failed to update room.\"}");
        }
    }

    // ---- DELETE: delete room ----
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        PrintWriter out = resp.getWriter();

        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.write("{\"success\":false,\"message\":\"Admin access required.\"}");
            return;
        }

        Map<String, String> p = parseBody(req);
        String idStr = p.get("id");

        if (idStr == null || idStr.isBlank()) {
            out.write("{\"success\":false,\"message\":\"Room ID is required.\"}");
            return;
        }

        int id;
        try { id = Integer.parseInt(idStr.trim()); }
        catch (NumberFormatException e) {
            out.write("{\"success\":false,\"message\":\"Invalid room ID.\"}");
            return;
        }

        boolean ok = roomDAO.deleteRoom(id);
        if (ok) {
            out.write("{\"success\":true,\"message\":\"Room deleted successfully.\"}");
        } else {
            out.write("{\"success\":false,\"message\":\"Failed to delete room.\"}");
        }
    }
}
