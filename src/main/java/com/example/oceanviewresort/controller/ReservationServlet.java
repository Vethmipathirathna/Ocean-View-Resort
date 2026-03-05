package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.model.Reservation;
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
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST API for reservation management.
 * GET  /api/reservation  -> list all reservations (JSON) — any logged-in user
 * POST /api/reservation  -> create reservation         — admin only
 * PUT  /api/reservation  -> update reservation         — admin only
 * DELETE /api/reservation -> delete reservation        — admin only
 */
@WebServlet(name = "ReservationServlet", urlPatterns = "/api/reservation")
public class ReservationServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();

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

    // ---- GET: list all reservations ----
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        if (!isLoggedIn(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        List<Reservation> list = reservationDAO.findAll();
        JsonArray arr = new JsonArray();
        for (Reservation r : list) {
            JsonObject o = new JsonObject();
            o.addProperty("id",            r.getId());
            o.addProperty("guestId",       r.getGuestId());
            o.addProperty("roomId",        r.getRoomId());
            o.addProperty("guestName",     r.getGuestName() != null ? r.getGuestName() : "");
            o.addProperty("roomNumber",    r.getRoomNumber() != null ? r.getRoomNumber() : "");
            o.addProperty("guestEmail",    r.getGuestEmail() != null ? r.getGuestEmail() : "");
            o.addProperty("guestPhone",    r.getGuestPhone() != null ? r.getGuestPhone() : "");
            o.addProperty("checkInDate",   r.getCheckInDate()  != null ? r.getCheckInDate().toString()  : "");
            o.addProperty("checkOutDate",  r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "");
            o.addProperty("totalPrice",    r.getTotalPrice() != null ? r.getTotalPrice().toPlainString() : "0");
            o.addProperty("status",        r.getStatus() != null ? r.getStatus() : "");
            o.addProperty("notes",         r.getNotes() != null ? r.getNotes() : "");
            o.addProperty("createdAt",     r.getCreatedAt() != null ? r.getCreatedAt().toString() : "");
            arr.add(o);
        }
        resp.getWriter().write(arr.toString());
    }

    // ---- POST: create reservation ----
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"success\":false,\"message\":\"Admin only\"}");
            return;
        }

        String guestIdStr    = req.getParameter("guestId");
        String roomIdStr     = req.getParameter("roomId");
        String checkInStr    = req.getParameter("checkInDate");
        String checkOutStr   = req.getParameter("checkOutDate");
        String totalPriceStr = req.getParameter("totalPrice");
        String status        = req.getParameter("status");
        String notes         = req.getParameter("notes");

        if (guestIdStr == null || guestIdStr.isBlank() ||
            roomIdStr  == null || roomIdStr.isBlank()  ||
            checkInStr == null || checkInStr.isBlank() ||
            checkOutStr == null || checkOutStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Guest, room, and dates are required.\"}");
            return;
        }

        try {
            Reservation r = new Reservation();
            r.setGuestId(Integer.parseInt(guestIdStr.trim()));
            r.setRoomId(Integer.parseInt(roomIdStr.trim()));
            r.setCheckInDate(LocalDate.parse(checkInStr.trim()));
            r.setCheckOutDate(LocalDate.parse(checkOutStr.trim()));
            r.setTotalPrice(totalPriceStr != null && !totalPriceStr.isBlank()
                ? new BigDecimal(totalPriceStr.trim()) : BigDecimal.ZERO);
            r.setStatus(status != null && !status.isBlank() ? status.trim() : "confirmed");
            r.setNotes(notes != null ? notes.trim() : null);

            int newId = reservationDAO.createReservation(r);
            if (newId > 0) {
                roomDAO.updateRoomStatus(r.getRoomId(), "occupied");
                resp.getWriter().write("{\"success\":true,\"message\":\"Reservation created.\",\"id\":" + newId + "}");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("{\"success\":false,\"message\":\"Failed to create reservation.\"}");
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid input: " + e.getMessage() + "\"}");
        }
    }

    // ---- PUT: update reservation ----
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"success\":false,\"message\":\"Admin only\"}");
            return;
        }
        Map<String, String> p = parseBody(req);
        String idStr         = p.get("id");
        String roomIdStr     = p.get("roomId");
        String checkInStr    = p.get("checkInDate");
        String checkOutStr   = p.get("checkOutDate");
        String totalPriceStr = p.get("totalPrice");
        String status        = p.get("status");
        String notes         = p.get("notes");
        if (idStr == null || idStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Reservation id is required.\"}");
            return;
        }
        try {
            Reservation r = new Reservation();
            r.setId(Integer.parseInt(idStr.trim()));
            if (roomIdStr != null && !roomIdStr.isBlank()) r.setRoomId(Integer.parseInt(roomIdStr.trim()));
            r.setCheckInDate(LocalDate.parse(checkInStr.trim()));
            r.setCheckOutDate(LocalDate.parse(checkOutStr.trim()));
            r.setTotalPrice(totalPriceStr != null && !totalPriceStr.isBlank()
                ? new BigDecimal(totalPriceStr.trim()) : BigDecimal.ZERO);
            r.setStatus(status != null && !status.isBlank() ? status.trim() : "confirmed");
            r.setNotes(notes != null ? notes.trim() : null);
            boolean ok = reservationDAO.updateReservation(r);
            if (ok) {
                String newStatus = r.getStatus();
                if ("checked_out".equals(newStatus) || "cancelled".equals(newStatus)) {
                    roomDAO.updateRoomStatus(r.getRoomId(), "available");
                } else {
                    roomDAO.updateRoomStatus(r.getRoomId(), "occupied");
                }
            }
            resp.getWriter().write(ok
                ? "{\"success\":true,\"message\":\"Reservation updated.\"}"
                : "{\"success\":false,\"message\":\"Update failed.\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid input: " + e.getMessage() + "\"}");
        }
    }

    // ---- DELETE: remove reservation ----
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        json(resp);
        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"success\":false,\"message\":\"Admin only\"}");
            return;
        }
        Map<String, String> p = parseBody(req);
        String idStr = p.get("id");
        if (idStr == null || idStr.isBlank()) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Reservation id is required.\"}");
            return;
        }
        try {
            boolean ok = reservationDAO.deleteReservation(Integer.parseInt(idStr.trim()));
            resp.getWriter().write(ok
                ? "{\"success\":true,\"message\":\"Reservation deleted.\"}"
                : "{\"success\":false,\"message\":\"Delete failed.\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"success\":false,\"message\":\"Invalid id.\"}");
        }
    }
}
