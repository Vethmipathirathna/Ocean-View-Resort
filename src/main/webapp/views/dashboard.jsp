<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object loggedInUser = session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    String displayName = (fullName != null && !fullName.isEmpty()) ? fullName : username;
    String initials = displayName != null && displayName.length() > 0
        ? displayName.substring(0,1).toUpperCase() : "A";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard  OceanView Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary:   #2563eb;
            --primary-d: #1d4ed8;
            --sidebar:   #0f172a;
            --sidebar-h: #1e293b;
            --accent:    #38bdf8;
            --success:   #22c55e;
            --warning:   #f59e0b;
            --danger:    #ef4444;
            --text:      #0f172a;
            --muted:     #64748b;
            --border:    #e2e8f0;
            --bg:        #f8fafc;
            --card:      #ffffff;
        }
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Inter',sans-serif; background:var(--bg); color:var(--text); display:flex; min-height:100vh; }

        /* ===== SIDEBAR ===== */
        .sidebar {
            width: 240px;
            background: var(--sidebar);
            color: #e2e8f0;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 100;
        }
        .sidebar-logo {
            padding: 24px 20px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.07);
        }
        .sidebar-logo .brand {
            font-size: 17px; font-weight: 700; color: #fff;
            display: flex; align-items: center; gap: 10px;
        }
        .sidebar-logo .brand .logo-icon {
            width: 34px; height: 34px; background: var(--primary);
            border-radius: 9px; display: flex; align-items: center; justify-content: center;
            font-size: 18px;
        }
        .sidebar-logo .sub { font-size: 11px; color: #64748b; margin-top: 3px; margin-left: 44px; letter-spacing: .4px; }

        .sidebar-nav { flex: 1; padding: 16px 12px; display: flex; flex-direction: column; gap: 4px; }
        .nav-section-label {
            font-size: 10px; font-weight: 600; color: #475569;
            text-transform: uppercase; letter-spacing: 1px;
            padding: 10px 8px 6px;
        }
        .nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 10px 12px; border-radius: 8px;
            font-size: 13.5px; font-weight: 500; color: #94a3b8;
            cursor: pointer; transition: all .15s; text-decoration: none;
        }
        .nav-item:hover { background: var(--sidebar-h); color: #e2e8f0; }
        .nav-item.active { background: var(--primary); color: #fff; }
        .nav-item .ni { font-size: 16px; width: 20px; text-align: center; }

        .sidebar-footer {
            padding: 16px 12px;
            border-top: 1px solid rgba(255,255,255,0.07);
        }
        .sidebar-user {
            display: flex; align-items: center; gap: 10px;
            padding: 10px; border-radius: 8px;
            background: rgba(255,255,255,0.05);
        }
        .avatar {
            width: 34px; height: 34px; border-radius: 50%;
            background: var(--primary); color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 700; flex-shrink: 0;
        }
        .sidebar-user .user-detail .uname { font-size: 13px; font-weight: 600; color: #e2e8f0; }
        .sidebar-user .user-detail .urole {
            font-size: 10px; color: #64748b; text-transform: uppercase; letter-spacing: .5px;
        }
        .btn-signout-side {
            margin-top: 8px; width: 100%;
            background: rgba(239,68,68,0.12); border: 1px solid rgba(239,68,68,0.25);
            color: #fca5a5; padding: 8px; border-radius: 7px; cursor: pointer;
            font-size: 12px; font-weight: 600; transition: background .2s;
        }
        .btn-signout-side:hover { background: rgba(239,68,68,0.25); }

        /* ===== MAIN ===== */
        .main-wrap { margin-left: 240px; flex: 1; display: flex; flex-direction: column; }

        /* Top bar */
        .topbar {
            height: 62px; background: var(--card);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 32px; position: sticky; top: 0; z-index: 50;
        }
        .topbar h1 { font-size: 18px; font-weight: 700; color: var(--text); }
        .topbar .date { font-size: 13px; color: var(--muted); }

        /* Page content */
        .page { padding: 28px 32px; }

        /* ===== STAT CARDS ===== */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(210px,1fr));
            gap: 20px;
            margin-bottom: 32px;
        }
        .stat {
            background: var(--card);
            border-radius: 14px;
            padding: 22px 20px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
            display: flex; align-items: center; gap: 16px;
        }
        .stat-icon {
            width: 48px; height: 48px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; flex-shrink: 0;
        }
        .si-blue   { background: #dbeafe; }
        .si-green  { background: #dcfce7; }
        .si-amber  { background: #fef3c7; }
        .si-purple { background: #f3e8ff; }
        .stat-info .s-label { font-size: 12px; color: var(--muted); font-weight: 500; margin-bottom: 3px; }
        .stat-info .s-value { font-size: 26px; font-weight: 700; color: var(--text); line-height: 1; }
        .stat-info .s-sub   { font-size: 11px; color: var(--muted); margin-top: 3px; }

        /* ===== QUICK ACTIONS ===== */
        .section-hd { font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 14px; margin-top: 4px; }
        .actions-row {
            display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 36px;
        }
        .act-btn {
            background: var(--card); border: 1px solid var(--border);
            border-radius: 11px; padding: 14px 20px;
            display: flex; align-items: center; gap: 10px;
            cursor: pointer; transition: all .15s; font-size: 13px;
            font-weight: 600; color: var(--text);
            box-shadow: 0 1px 3px rgba(0,0,0,.05);
        }
        .act-btn:hover { border-color: var(--primary); color: var(--primary); background: #eff6ff; transform: translateY(-1px); }
        .act-btn .ai { font-size: 18px; }

        /* ===== RECEPTIONIST TABLE ===== */
        .panel {
            background: var(--card);
            border-radius: 14px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
            overflow: hidden;
        }
        .panel-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 18px 22px;
            border-bottom: 1px solid var(--border);
        }
        .panel-header h2 { font-size: 15px; font-weight: 700; color: var(--text); }
        .btn-add-new {
            background: var(--primary); color: #fff; border: none;
            padding: 8px 18px; border-radius: 8px; cursor: pointer;
            font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 6px;
            transition: background .15s;
        }
        .btn-add-new:hover { background: var(--primary-d); }

        table { width: 100%; border-collapse: collapse; }
        thead tr { background: #f8fafc; }
        thead th {
            padding: 11px 16px; text-align: left; font-size: 11.5px;
            font-weight: 600; color: var(--muted); text-transform: uppercase;
            letter-spacing: .5px; border-bottom: 1px solid var(--border);
        }
        tbody tr { border-bottom: 1px solid var(--border); transition: background .1s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f8fafc; }
        tbody td { padding: 13px 16px; font-size: 13.5px; color: var(--text); }

        .chip { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:11.5px; font-weight:600; }
        .chip-active   { background: #dcfce7; color: #15803d; }
        .chip-inactive { background: #fee2e2; color: #b91c1c; }

        .tbl-edit, .tbl-del {
            border: none; border-radius: 7px; padding: 5px 14px;
            font-size: 12px; font-weight: 600; cursor: pointer;
            transition: all .15s; margin-right: 4px;
        }
        .tbl-edit     { background: #eff6ff; color: var(--primary); }
        .tbl-edit:hover   { background: #dbeafe; }
        .tbl-del      { background: #fef2f2; color: var(--danger); }
        .tbl-del:hover    { background: #fee2e2; }

        /* ===== MODAL ===== */
        .overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(15,23,42,.5); backdrop-filter: blur(3px);
            z-index: 200; align-items: center; justify-content: center;
        }
        .overlay.open { display: flex; }
        .modal {
            background: var(--card); border-radius: 16px;
            padding: 32px; width: 460px; max-width: 95vw;
            box-shadow: 0 20px 60px rgba(0,0,0,.18);
            animation: popIn .15s ease;
        }
        @keyframes popIn { from { transform:scale(.94); opacity:0; } to { transform:scale(1); opacity:1; } }
        .modal-hd { display:flex; align-items:center; justify-content:space-between; margin-bottom:22px; }
        .modal-hd h3 { font-size:17px; font-weight:700; color:var(--text); }
        .modal-close { background:none; border:none; font-size:20px; cursor:pointer; color:var(--muted); line-height:1; }
        .modal-close:hover { color:var(--danger); }

        .fg { margin-bottom:16px; }
        .fg label { display:block; font-size:12.5px; font-weight:600; color:var(--muted); margin-bottom:5px; }
        .fg input {
            width:100%; padding:9px 13px; border:1px solid var(--border);
            border-radius:9px; font-size:14px; outline:none; font-family:inherit;
            transition: border-color .15s, box-shadow .15s;
        }
        .fg input:focus { border-color:var(--primary); box-shadow:0 0 0 3px rgba(37,99,235,.1); }
        .fg input:disabled { background:#f8fafc; color:var(--muted); cursor:not-allowed; }

        .modal-foot { display:flex; gap:10px; justify-content:flex-end; margin-top:24px; }
        .btn-cancel {
            background: #f1f5f9; color: var(--muted); border: none;
            padding: 9px 22px; border-radius: 9px; cursor: pointer;
            font-size: 13px; font-weight: 600; font-family:inherit;
        }
        .btn-cancel:hover { background: var(--border); }
        .btn-save {
            background: var(--primary); color: #fff; border: none;
            padding: 9px 22px; border-radius: 9px; cursor: pointer;
            font-size: 13px; font-weight: 600; font-family:inherit;
            transition: background .15s;
        }
        .btn-save:hover { background: var(--primary-d); }

        /* ===== MANAGE BUTTON ===== */
        .btn-manage {
            background: #f1f5f9; color: var(--text); border: 1px solid var(--border);
            padding: 6px 16px; border-radius: 7px; font-size: 12px; font-weight: 600;
            cursor: pointer; transition: all .15s;
        }
        .btn-manage:hover { background: #e2e8f0; border-color: #94a3b8; }

        /* ===== GUEST SEARCH AUTOCOMPLETE ===== */
        .guest-search-wrap { position: relative; }
        .guest-search-wrap input {
            width: 100%; padding: 9px 13px 9px 36px;
            border: 1px solid var(--border); border-radius: 9px;
            font-size: 14px; outline: none; font-family: inherit;
            transition: border-color .15s, box-shadow .15s;
        }
        .guest-search-wrap input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(37,99,235,.1); }
        .guest-search-icon {
            position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
            font-size: 15px; color: var(--muted); pointer-events: none;
        }
        .guest-selected-card {
            display: none; align-items: center; gap: 12px;
            padding: 10px 13px; border: 1.5px solid var(--primary);
            border-radius: 9px; background: #eff6ff;
        }
        .guest-selected-card .gsc-avatar {
            width: 36px; height: 36px; border-radius: 50%;
            background: var(--primary); color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 700; flex-shrink: 0;
        }
        .guest-selected-card .gsc-info .gsc-name { font-size: 14px; font-weight: 700; color: var(--text); }
        .guest-selected-card .gsc-info .gsc-sub  { font-size: 12px; color: var(--muted); }
        .gsc-clear {
            margin-left: auto; background: none; border: none;
            font-size: 18px; color: var(--muted); cursor: pointer; line-height: 1;
        }
        .gsc-clear:hover { color: var(--danger); }
        .guest-results {
            display: none; position: absolute; top: calc(100% + 4px); left: 0; right: 0;
            background: var(--card); border: 1px solid var(--border);
            border-radius: 10px; box-shadow: 0 8px 24px rgba(0,0,0,.12);
            z-index: 9999; max-height: 220px; overflow-y: auto;
        }
        .guest-results.open { display: block; }
        .guest-result-item {
            display: flex; align-items: center; gap: 11px;
            padding: 10px 14px; cursor: pointer; transition: background .1s;
        }
        .guest-result-item:hover { background: #f0f9ff; }
        .guest-result-item .gri-avatar {
            width: 32px; height: 32px; border-radius: 50%;
            background: var(--primary); color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px; font-weight: 700; flex-shrink: 0;
        }
        .guest-result-item .gri-name  { font-size: 13.5px; font-weight: 600; color: var(--text); }
        .guest-result-item .gri-sub   { font-size: 11.5px; color: var(--muted); }
        .guest-result-empty { padding: 14px; text-align: center; color: var(--muted); font-size: 13px; }

        /* ===== RESERVATION FILTERS ===== */
        .res-filters {
            display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
            padding: 14px 22px; border-bottom: 1px solid var(--border);
            background: #f8fafc;
        }
        .filter-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 20px;
            font-size: 12.5px; font-weight: 600; cursor: pointer;
            border: 1.5px solid var(--border); background: var(--card); color: var(--muted);
            transition: all .15s;
        }
        .filter-pill:hover { border-color: var(--primary); color: var(--primary); background: #eff6ff; }
        .filter-pill.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .filter-pill .fp-count {
            background: rgba(255,255,255,0.3); color: inherit;
            padding: 1px 7px; border-radius: 10px; font-size: 11px;
        }
        .filter-pill:not(.active) .fp-count { background: #e2e8f0; color: var(--muted); }
        .res-summary {
            padding: 14px 22px 0;
            font-size: 12.5px; color: var(--muted);
        }
        .res-summary span { font-weight: 700; color: var(--text); }

        /* ===== TOAST ===== */
        #toast {
            position: fixed; bottom: 24px; right: 24px;
            background: #1e293b; color: #f1f5f9;
            padding: 12px 20px; border-radius: 10px;
            font-size: 13.5px; font-weight: 500;
            box-shadow: 0 8px 24px rgba(0,0,0,.2);
            display: none; z-index: 9999; max-width: 320px;
            border-left: 3px solid var(--primary);
        }
    </style>
</head>
<body>

<!-- ===== SIDEBAR ===== -->
<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="brand">
            <div class="logo-icon">&#127754;</div>
            OceanView
        </div>
        <div class="sub">Resort Management</div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Main</div>
        <a class="nav-item active" data-page="dashboard" href="#" onclick="showPage('dashboard');return false;">
            <span class="ni">&#9707;</span> Dashboard
        </a>
        <% if ("admin".equalsIgnoreCase(role)) { %>
        <a class="nav-item" data-page="receptionists" href="#" onclick="showPage('receptionists');return false;">
            <span class="ni">&#128101;</span> Receptionists
        </a>
        <a class="nav-item" data-page="guests" href="#" onclick="showPage('guests');return false;">
            <span class="ni">&#128100;</span> Guests
        </a>
        <% } %>

        <div class="nav-section-label" style="margin-top:12px;">Operations</div>
        <a class="nav-item" data-page="reservations" href="#" onclick="showPage('reservations');return false;"><span class="ni">&#128716;</span> Bookings</a>
        <a class="nav-item" data-page="rooms" href="#" onclick="showPage('rooms');return false;"><span class="ni">&#127968;</span> Rooms</a>
        <a class="nav-item" href="#"><span class="ni">&#128203;</span> Reports</a>
        <a class="nav-item" href="#"><span class="ni">&#9881;</span> Settings</a>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-user">
            <div class="avatar"><%= initials %></div>
            <div class="user-detail">
                <div class="uname"><%= displayName %></div>
                <div class="urole"><%= role %></div>
            </div>
        </div>
        <button class="btn-signout-side" onclick="logout()">&#x2192; Sign Out</button>
    </div>
</aside>

<!-- ===== MAIN WRAP ===== -->
<div class="main-wrap">

    <!-- Top Bar -->
    <div class="topbar">
        <h1 id="topbarTitle">Dashboard</h1>
        <span class="date" id="currentDate"></span>
    </div>

    <!-- Page -->
    <div class="page">

    <!-- ===== VIEW: DASHBOARD ===== -->
    <div id="page-dashboard">

        <!-- Stat Cards -->
        <div class="stats-row">
            <div class="stat" style="cursor:pointer" onclick="showPage('reservations')">
                <div class="stat-icon si-blue">&#128716;</div>
                <div class="stat-info">
                    <div class="s-label">Total Reservations</div>
                    <div class="s-value" id="statReservations">0</div>
                    <div class="s-sub">All bookings</div>
                </div>
            </div>
            <div class="stat" style="cursor:pointer" onclick="showPage('rooms')">
                <div class="stat-icon si-green">&#127968;</div>
                <div class="stat-info">
                    <div class="s-label">Available Rooms</div>
                    <div class="s-value" id="statRooms">0</div>
                    <div class="s-sub">Total available</div>
                </div>
            </div>
            <div class="stat">
                <div class="stat-icon si-amber">&#128100;</div>
                <div class="stat-info">
                    <div class="s-label">Check-ins Today</div>
                    <div class="s-value"></div>
                    <div class="s-sub">Coming soon</div>
                </div>
            </div>
            <div class="stat" style="cursor:pointer" onclick="showPage('guests')">
                <div class="stat-icon si-purple">&#128106;</div>
                <div class="stat-info">
                    <div class="s-label">Registered Guests</div>
                    <div class="s-value" id="statGuests">0</div>
                    <div class="s-sub">Total registered</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="section-hd">Quick Actions</div>
        <div class="actions-row">
            <button class="act-btn" onclick="showPage('reservations')"><span class="ai">&#128716;</span> New Booking</button>
            <button class="act-btn"><span class="ai">&#128100;</span> Guest Check-In</button>
            <button class="act-btn"><span class="ai">&#127968;</span> Room Status</button>
            <button class="act-btn"><span class="ai">&#128203;</span> Reports</button>
            <button class="act-btn"><span class="ai">&#9881;</span> Settings</button>
        </div>

    </div><!-- /#page-dashboard -->

    <!-- ===== VIEW: RECEPTIONISTS ===== -->
    <% if ("admin".equalsIgnoreCase(role)) { %>
    <div id="page-receptionists" style="display:none;">
        <div class="panel">
            <div class="panel-header">
                <h2>All Receptionists</h2>
                <button class="btn-add-new" onclick="openAddModal()">&#43; Add Receptionist</button>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Full Name</th>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="receptionistBody">
                    <tr><td colspan="6" style="text-align:center;padding:28px;color:#94a3b8;">Loading&hellip;</td></tr>
                </tbody>
            </table>
        </div>
    </div><!-- /#page-receptionists -->
    <% } %>

    <!-- ===== VIEW: ROOMS ===== -->
    <div id="page-rooms" style="display:none;">
        <div class="panel">
            <div class="panel-header">
                <h2>All Rooms</h2>
                <% if ("admin".equalsIgnoreCase(role)) { %>
                <button class="btn-add-new" onclick="openAddRoomModal()">&#43; Add Room</button>
                <% } %>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Room No.</th>
                        <th>Type</th>
                        <th>Price / Night</th>
                        <th>Capacity</th>
                        <th>Status</th>
                        <% if ("admin".equalsIgnoreCase(role)) { %>
                        <th>Actions</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody id="roomBody">
                    <tr><td colspan="7" style="text-align:center;padding:28px;color:#94a3b8;">Loading&hellip;</td></tr>
                </tbody>
            </table>
        </div>
    </div><!-- /#page-rooms -->

    <!-- ===== VIEW: GUESTS ===== -->
    <% if ("admin".equalsIgnoreCase(role)) { %>
    <div id="page-guests" style="display:none;">
        <div class="panel">
            <div class="panel-header">
                <h2>Registered Guests</h2>
                <button class="btn-add-new" onclick="openAddGuestModal()">&#43; Register Guest</button>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>ID Type</th>
                        <th>ID Number</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="guestBody">
                    <tr><td colspan="7" style="text-align:center;padding:28px;color:#94a3b8;">Loading&hellip;</td></tr>
                </tbody>
            </table>
        </div>
    </div><!-- /#page-guests -->
    <% } %>

    <!-- ===== VIEW: RESERVATIONS ===== -->
    <div id="page-reservations" style="display:none;">
        <div class="panel">
            <div class="panel-header">
                <h2>Reservation Management</h2>
                <% if ("admin".equalsIgnoreCase(role)) { %>
                <button class="btn-add-new" onclick="openNewReservationModal()">&#43; New Reservation</button>
                <% } %>
            </div>

            <!-- Filter Pills -->
            <div class="res-filters">
                <button class="filter-pill active" id="rpill-all"       onclick="setResFilter('all')">&#128221; All <span class="fp-count" id="rc-all">0</span></button>
                <button class="filter-pill"        id="rpill-today_in"  onclick="setResFilter('today_in')">&#128100; Today Check-In <span class="fp-count" id="rc-today_in">0</span></button>
                <button class="filter-pill"        id="rpill-today_out" onclick="setResFilter('today_out')">&#128682; Today Check-Out <span class="fp-count" id="rc-today_out">0</span></button>
                <button class="filter-pill"        id="rpill-upcoming"  onclick="setResFilter('upcoming')">&#128197; Upcoming <span class="fp-count" id="rc-upcoming">0</span></button>
                <button class="filter-pill"        id="rpill-checked_in"  onclick="setResFilter('checked_in')">&#127981; Checked In <span class="fp-count" id="rc-checked_in">0</span></button>
                <button class="filter-pill"        id="rpill-checked_out" onclick="setResFilter('checked_out')">&#128682; Checked Out <span class="fp-count" id="rc-checked_out">0</span></button>
                <button class="filter-pill"        id="rpill-cancelled" onclick="setResFilter('cancelled')">&#10060; Cancelled <span class="fp-count" id="rc-cancelled">0</span></button>
            </div>

            <div class="res-summary">Showing <span id="resShownCount">0</span> reservation(s)</div>

            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Guest</th>
                        <th>Room</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                        <th>Nights</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody id="reservationBody">
                    <tr><td colspan="9" style="text-align:center;padding:28px;color:#94a3b8;">Loading&hellip;</td></tr>
                </tbody>
            </table>
        </div>
    </div><!-- /#page-reservations -->

    </div><!-- /.page -->
</div><!-- /.main-wrap -->

<!-- Add / Edit Modal -->
<div class="overlay" id="modalOverlay">
    <div class="modal">
        <div class="modal-hd">
            <h3 id="modalTitle">Add Receptionist</h3>
            <button class="modal-close" onclick="closeModal()">&#215;</button>
        </div>
        <input type="hidden" id="editId">
        <div class="fg">
            <label for="inputFullName">Full Name</label>
            <input type="text" id="inputFullName" placeholder="e.g. Jane Doe">
        </div>
        <div class="fg" id="groupUsername">
            <label for="inputUsername">Username</label>
            <input type="text" id="inputUsername" placeholder="e.g. janedoe">
        </div>
        <div class="fg">
            <label for="inputEmail">Email</label>
            <input type="email" id="inputEmail" placeholder="e.g. jane@resort.com">
        </div>
        <div class="fg">
            <label for="inputPassword" id="labelPassword">Password</label>
            <input type="password" id="inputPassword" placeholder="Enter password">
        </div>
        <div class="modal-foot">
            <button class="btn-cancel" onclick="closeModal()">Cancel</button>
            <button class="btn-save"   onclick="saveReceptionist()">Save</button>
        </div>
    </div>
</div>

<!-- Room Add / Edit Modal -->
<div class="overlay" id="roomModalOverlay">
    <div class="modal">
        <div class="modal-hd">
            <h3 id="roomModalTitle">Add Room</h3>
            <button class="modal-close" onclick="closeRoomModal()">&#215;</button>
        </div>
        <input type="hidden" id="roomEditId">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:0 16px;">
            <div class="fg">
                <label for="inputRoomNumber">Room Number</label>
                <input type="text" id="inputRoomNumber" placeholder="e.g. 101">
            </div>
            <div class="fg">
                <label for="inputRoomType">Type</label>
                <select id="inputRoomType" style="width:100%;padding:9px 13px;border:1px solid var(--border);border-radius:9px;font-size:14px;outline:none;font-family:inherit;">
                    <option value="Single">Single</option>
                    <option value="Double">Double</option>
                    <option value="Suite">Suite</option>
                    <option value="Deluxe">Deluxe</option>
                </select>
            </div>
            <div class="fg">
                <label for="inputRoomPrice">Price / Night ($)</label>
                <input type="number" id="inputRoomPrice" placeholder="e.g. 120" min="0" step="0.01">
            </div>
            <div class="fg">
                <label for="inputRoomCapacity">Capacity (guests)</label>
                <input type="number" id="inputRoomCapacity" placeholder="e.g. 2" min="1">
            </div>
        </div>
        <div class="fg">
            <label for="inputRoomStatus">Status</label>
            <select id="inputRoomStatus" style="width:100%;padding:9px 13px;border:1px solid var(--border);border-radius:9px;font-size:14px;outline:none;font-family:inherit;">
                <option value="available">Available</option>
                <option value="occupied">Occupied</option>
                <option value="maintenance">Maintenance</option>
            </select>
        </div>
        <div class="fg">
            <label for="inputRoomDesc">Description (optional)</label>
            <input type="text" id="inputRoomDesc" placeholder="e.g. Ocean view, king bed">
        </div>
        <div class="modal-foot">
            <button class="btn-cancel" onclick="closeRoomModal()">Cancel</button>
            <button class="btn-save" id="btnDeleteRoom" onclick="deleteRoomFromModal()" style="background:var(--danger);display:none;">Delete</button>
            <button class="btn-save"   onclick="saveRoom()">Save Changes</button>
        </div>
    </div>
</div>

<!-- Guest Register / Manage Modal -->
<div class="overlay" id="guestModalOverlay">
    <div class="modal">
        <div class="modal-hd">
            <h3 id="guestModalTitle">Register Guest</h3>
            <button class="modal-close" onclick="closeGuestModal()">&#215;</button>
        </div>
        <input type="hidden" id="guestEditId">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:0 16px;">
            <div class="fg">
                <label>First Name</label>
                <input type="text" id="inputGuestFirst" placeholder="e.g. John">
            </div>
            <div class="fg">
                <label>Last Name</label>
                <input type="text" id="inputGuestLast" placeholder="e.g. Smith">
            </div>
            <div class="fg">
                <label>Email</label>
                <input type="email" id="inputGuestEmail" placeholder="e.g. john@email.com">
            </div>
            <div class="fg">
                <label>Phone</label>
                <input type="text" id="inputGuestPhone" placeholder="e.g. +94 77 123 4567">
            </div>
            <div class="fg">
                <label>ID Type</label>
                <select id="inputGuestIdType" style="width:100%;padding:9px 13px;border:1px solid var(--border);border-radius:9px;font-size:14px;outline:none;font-family:inherit;">
                    <option value="Passport">Passport</option>
                    <option value="NIC">NIC</option>
                    <option value="Driver's License">Driver&#39;s License</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            <div class="fg">
                <label>ID Number</label>
                <input type="text" id="inputGuestIdNumber" placeholder="e.g. N1234567">
            </div>
        </div>
        <div class="fg">
            <label>Address</label>
            <input type="text" id="inputGuestAddress" placeholder="e.g. 12 Main St, Colombo">
        </div>
        <div class="modal-foot">
            <button class="btn-cancel" onclick="closeGuestModal()">Cancel</button>
            <button class="btn-save" id="btnDeleteGuest" onclick="deleteGuestFromModal()" style="background:var(--danger);display:none;">Delete</button>
            <button class="btn-save" onclick="saveGuest()" id="btnSaveGuest">Register</button>
        </div>
    </div>
</div>

<!-- New Reservation Modal -->
<div class="overlay" id="reservationModalOverlay">
    <div class="modal" style="width:520px;">
        <div class="modal-hd">
            <h3 id="reservationModalTitle">New Reservation</h3>
            <button class="modal-close" onclick="closeReservationModal()">&#215;</button>
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:0 16px;">

            <!-- Guest Search -->
            <div class="fg" style="grid-column:1/-1;">
                <label>Guest</label>
                <input type="hidden" id="inputResGuestId">
                <!-- Search box (shown when no guest selected) -->
                <div class="guest-search-wrap" id="guestSearchWrap">
                    <span class="guest-search-icon">&#128269;</span>
                    <input type="text" id="inputGuestSearch"
                           placeholder="Search by name, phone or email&hellip;"
                           autocomplete="off"
                           oninput="filterGuestResults(this.value)"
                           onfocus="filterGuestResults(this.value)">
                    <div class="guest-results" id="guestResults"></div>
                </div>
                <!-- Selected guest card (shown after selection) -->
                <div class="guest-selected-card" id="guestSelectedCard">
                    <div class="gsc-avatar" id="gscAvatar">?</div>
                    <div class="gsc-info">
                        <div class="gsc-name" id="gscName"></div>
                        <div class="gsc-sub"  id="gscSub"></div>
                    </div>
                    <button class="gsc-clear" onclick="clearGuestSelection()" title="Change guest">&#215;</button>
                </div>
            </div>

            <div class="fg" style="grid-column:1/-1;">
                <label>Room</label>
                <select id="inputResRoom" style="width:100%;padding:9px 13px;border:1px solid var(--border);border-radius:9px;font-size:14px;outline:none;font-family:inherit;" onchange="calcTotalPrice()">
                    <option value="" data-price="0">-- Select Room --</option>
                </select>
            </div>
            <div class="fg">
                <label>Check-In Date</label>
                <input type="date" id="inputResCheckIn" onchange="calcTotalPrice()">
            </div>
            <div class="fg">
                <label>Check-Out Date</label>
                <input type="date" id="inputResCheckOut" onchange="calcTotalPrice()">
            </div>
            <div class="fg">
                <label>Total Price ($)</label>
                <input type="number" id="inputResTotalPrice" placeholder="Auto-calculated" min="0" step="0.01">
            </div>
        </div>
        <div class="fg">
            <label>Notes (optional)</label>
            <input type="text" id="inputResNotes" placeholder="e.g. Late arrival, extra bed requested">
        </div>
        <div class="modal-foot">
            <button class="btn-cancel" onclick="closeReservationModal()">Cancel</button>
            <button class="btn-save" onclick="saveReservation()">Create Reservation</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    const CTX = '${pageContext.request.contextPath}';
    const USER_ROLE = '<%= role %>'.toLowerCase();

    // Date in topbar
    (function(){
        const d = new Date();
        const opts = { weekday:'long', year:'numeric', month:'long', day:'numeric' };
        document.getElementById('currentDate').textContent = d.toLocaleDateString('en-US', opts);
    })();

    /* ---- Sidebar tab navigation ---- */
    const PAGE_TITLES = { dashboard: 'Dashboard', receptionists: 'Receptionist Management', rooms: 'Room Management', guests: 'Guest Management', reservations: 'Reservation Management' };

    function showPage(name) {
        // Hide all page views
        document.querySelectorAll('[id^="page-"]').forEach(el => el.style.display = 'none');
        // Show requested view
        const target = document.getElementById('page-' + name);
        if (target) target.style.display = '';
        // Update topbar title
        document.getElementById('topbarTitle').textContent = PAGE_TITLES[name] || name;
        // Update active nav item
        document.querySelectorAll('.nav-item[data-page]').forEach(el => {
            el.classList.toggle('active', el.dataset.page === name);
        });
        // Scroll main wrap to top
        document.querySelector('.main-wrap').scrollTop = 0;
        // Load data when switching to receptionists / rooms
        if (name === 'receptionists') loadReceptionists();
        if (name === 'rooms') loadRooms();
        if (name === 'guests') loadGuests();
        if (name === 'reservations') loadReservations();
    }

    function showToast(msg) {
        const $t = $('#toast');
        $t.text(msg).fadeIn(250);
        setTimeout(()=> $t.fadeOut(400), 3200);
    }

    function logout() {
        $.ajax({
            url: CTX + '/api/logout', type: 'POST',
            success: function(res) { if (res.success) window.location.href = res.redirect; },
            error:   function()    { window.location.href = CTX + '/views/login.jsp'; }
        });
    }

    /* ---- Receptionist table ---- */
    function loadReceptionists() {
        $.getJSON(CTX + '/api/receptionist', function(list) {
            const tbody = $('#receptionistBody');
            tbody.empty();
            $('#statReceptionists').text(list ? list.length : 0);
            if (!list || list.length === 0) {
                tbody.append('<tr><td colspan="6" style="text-align:center;padding:28px;color:#94a3b8;">No receptionists found.</td></tr>');
                return;
            }
            $.each(list, function(i, r) {
                const badge = r.active
                    ? '<span class="chip chip-active">&#10003; Active</span>'
                    : '<span class="chip chip-inactive">&#215; Inactive</span>';
                tbody.append(
                    '<tr>' +
                    '<td style="color:#94a3b8;font-size:12px;">' + (i+1) + '</td>' +
                    '<td style="font-weight:600;">' + escHtml(r.fullName) + '</td>' +
                    '<td style="color:#475569;">' + escHtml(r.username) + '</td>' +
                    '<td style="color:#475569;">' + escHtml(r.email || '') + '</td>' +
                    '<td>' + badge + '</td>' +
                    '<td>' +
                      '<button class="tbl-edit" onclick="openEditModal('+r.id+',\''+escHtml(r.fullName)+'\',\''+escHtml(r.username)+'\',\''+escHtml(r.email||'')+'\')">Edit</button>' +
                      '<button class="tbl-del"  onclick="deleteReceptionist('+r.id+')">Delete</button>' +
                    '</td>' +
                    '</tr>'
                );
            });
        }).fail(function() {
            $('#receptionistBody').html('<tr><td colspan="6" style="text-align:center;padding:28px;color:var(--danger);">Failed to load data.</td></tr>');
        });
    }

    function escHtml(str) {
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }

    function openAddModal() {
        $('#modalTitle').text('Add Receptionist');
        $('#editId').val('');
        $('#inputFullName').val('');
        $('#inputUsername').val('').prop('disabled', false);
        $('#inputEmail').val('');
        $('#inputPassword').val('');
        $('#labelPassword').text('Password');
        $('#groupUsername').show();
        $('#modalOverlay').addClass('open');
    }

    function openEditModal(id, fullName, username, email) {
        $('#modalTitle').text('Edit Receptionist');
        $('#editId').val(id);
        $('#inputFullName').val(fullName);
        $('#inputUsername').val(username).prop('disabled', true);
        $('#inputEmail').val(email);
        $('#inputPassword').val('');
        $('#labelPassword').text('New Password (leave blank to keep current)');
        $('#groupUsername').show();
        $('#modalOverlay').addClass('open');
    }

    function closeModal() { $('#modalOverlay').removeClass('open'); }

    function saveReceptionist() {
        const id       = $('#editId').val();
        const fullName = $('#inputFullName').val().trim();
        const username = $('#inputUsername').val().trim();
        const email    = $('#inputEmail').val().trim();
        const password = $('#inputPassword').val();
        if (!fullName) { showToast('Full name is required.'); return; }
        if (id) {
            $.ajax({
                url: CTX + '/api/receptionist', type: 'PUT',
                data: { id, fullName, email, password },
                success: function(res) {
                    if (res.success) { showToast(res.message || 'Updated.'); closeModal(); loadReceptionists(); }
                    else showToast(res.message || 'Update failed.');
                },
                error: function() { showToast('Server error.'); }
            });
        } else {
            if (!username) { showToast('Username is required.'); return; }
            if (!password) { showToast('Password is required.'); return; }
            $.ajax({
                url: CTX + '/api/receptionist', type: 'POST',
                data: { username, fullName, email, password },
                success: function(res) {
                    if (res.success) { showToast(res.message || 'Added.'); closeModal(); loadReceptionists(); }
                    else showToast(res.message || 'Could not add.');
                },
                error: function() { showToast('Server error.'); }
            });
        }
    }

    function deleteReceptionist(id) {
        if (!confirm('Delete this receptionist? This cannot be undone.')) return;
        $.ajax({
            url: CTX + '/api/receptionist', type: 'DELETE',
            data: { id },
            success: function(res) {
                if (res.success) { showToast(res.message || 'Deleted.'); loadReceptionists(); }
                else showToast(res.message || 'Delete failed.');
            },
            error: function() { showToast('Server error.'); }
        });
    }

    $(document).ready(function() {
        showToast('Welcome back, <%= displayName %>!');
        <% if ("admin".equalsIgnoreCase(role)) { %>
        loadReceptionists();
        loadRoomsCount();
        loadGuestsCount();
        loadReservationsCount();
        <% } %>
    });

    /* ---- Room management ---- */
    function loadRoomsCount() {
        $.getJSON(CTX + '/api/room', function(list) {
            const available = list ? list.filter(r => r.status === 'available').length : 0;
            $('#statRooms').text(available);
        });
    }

    function loadRooms() {
        $.getJSON(CTX + '/api/room', function(list) {
            const tbody = $('#roomBody');
            tbody.empty();
            const available = list ? list.filter(r => r.status === 'available').length : 0;
            $('#statRooms').text(available);
            if (!list || list.length === 0) {
                tbody.append('<tr><td colspan="7" style="text-align:center;padding:28px;color:#94a3b8;">No rooms found.</td></tr>');
                return;
            }
            $.each(list, function(i, r) {
                const statusColors = { available:'chip-active', occupied:'#fef3c7;color:#92400e', maintenance:'#fee2e2;color:#b91c1c' };
                let badgeStyle = '';
                let badgeClass = '';
                if (r.status === 'available')   { badgeClass = 'chip chip-active'; }
                else if (r.status === 'occupied')    { badgeStyle = 'background:#fef3c7;color:#92400e;'; }
                else                                 { badgeStyle = 'background:#fee2e2;color:#b91c1c;'; }
                const badge = badgeClass
                    ? '<span class="chip ' + badgeClass + '">' + escHtml(r.status) + '</span>'
                    : '<span class="chip" style="' + badgeStyle + '">' + escHtml(r.status) + '</span>';
                const actions = USER_ROLE === 'admin'
                    ? '<button class="btn-manage" onclick="openManageRoomModal('+r.id+',\''+escHtml(r.roomNumber)+'\',\''+escHtml(r.type)+'\','+r.pricePerNight+','+r.capacity+',\''+escHtml(r.status)+'\',\''+escHtml(r.description||'')+'\')">Manage</button>'
                    : '';
                tbody.append(
                    '<tr>'
                    + '<td style="color:#94a3b8;font-size:12px;">' + (i+1) + '</td>'
                    + '<td style="font-weight:700;">' + escHtml(r.roomNumber) + '</td>'
                    + '<td>' + escHtml(r.type) + '</td>'
                    + '<td>$' + parseFloat(r.pricePerNight).toFixed(2) + '</td>'
                    + '<td style="text-align:center;">' + r.capacity + '</td>'
                    + '<td>' + badge + '</td>'
                    + (USER_ROLE === 'admin' ? '<td>' + actions + '</td>' : '')
                    + '</tr>'
                );
            });
        }).fail(function() {
            $('#roomBody').html('<tr><td colspan="7" style="text-align:center;padding:28px;color:var(--danger);">Failed to load rooms.</td></tr>');
        });
    }

    function openAddRoomModal() {
        $('#roomModalTitle').text('Add Room');
        $('#roomEditId').val('');
        $('#inputRoomNumber').val('').prop('disabled', false);
        $('#inputRoomType').val('Single');
        $('#inputRoomPrice').val('');
        $('#inputRoomCapacity').val('');
        $('#inputRoomStatus').val('available');
        $('#inputRoomDesc').val('');
        $('#btnDeleteRoom').hide();
        $('#roomModalOverlay').addClass('open');
    }

    function openManageRoomModal(id, roomNumber, type, price, capacity, status, desc) {
        $('#roomModalTitle').text('Manage Room — ' + roomNumber);
        $('#roomEditId').val(id);
        $('#inputRoomNumber').val(roomNumber).prop('disabled', false);
        $('#inputRoomType').val(type);
        $('#inputRoomPrice').val(price);
        $('#inputRoomCapacity').val(capacity);
        $('#inputRoomStatus').val(status);
        $('#inputRoomDesc').val(desc);
        $('#btnDeleteRoom').show();
        $('#roomModalOverlay').addClass('open');
    }

    function closeRoomModal() { $('#roomModalOverlay').removeClass('open'); }

    function deleteRoomFromModal() {
        const id = $('#roomEditId').val();
        if (!id) return;
        if (!confirm('Delete this room? This cannot be undone.')) return;
        $.ajax({
            url: CTX + '/api/room', type: 'DELETE',
            data: { id },
            success: function(res) {
                if (res.success) { showToast(res.message || 'Room deleted.'); closeRoomModal(); loadRooms(); }
                else showToast(res.message || 'Delete failed.');
            },
            error: function() { showToast('Server error.'); }
        });
    }

    function saveRoom() {
        const id          = $('#roomEditId').val();
        const roomNumber  = $('#inputRoomNumber').val().trim();
        const type        = $('#inputRoomType').val();
        const pricePerNight = $('#inputRoomPrice').val();
        const capacity    = $('#inputRoomCapacity').val();
        const status      = $('#inputRoomStatus').val();
        const description = $('#inputRoomDesc').val().trim();

        if (!roomNumber) { showToast('Room number is required.'); return; }
        if (!type)       { showToast('Room type is required.'); return; }

        if (id) {
            $.ajax({
                url: CTX + '/api/room', type: 'PUT',
                data: { id, roomNumber, type, pricePerNight, capacity, status, description },
                success: function(res) {
                    if (res.success) { showToast(res.message || 'Room updated.'); closeRoomModal(); loadRooms(); }
                    else showToast(res.message || 'Update failed.');
                },
                error: function() { showToast('Server error.'); }
            });
        } else {
            $.ajax({
                url: CTX + '/api/room', type: 'POST',
                data: { roomNumber, type, pricePerNight, capacity, status, description },
                success: function(res) {
                    if (res.success) { showToast(res.message || 'Room added.'); closeRoomModal(); loadRooms(); }
                    else showToast(res.message || 'Could not add room.');
                },
                error: function() { showToast('Server error.'); }
            });
        }
    }

    /* ---- Manage dropdown toggle (removed) ---- */

    /* ---- Guest management ---- */
    function loadGuestsCount() {
        $.getJSON(CTX + '/api/guest', function(list) {
            $('#statGuests').text(list ? list.length : 0);
        });
    }

    function loadGuests() {
        $.getJSON(CTX + '/api/guest', function(list) {
            const tbody = $('#guestBody');
            tbody.empty();
            $('#statGuests').text(list ? list.length : 0);
            if (!list || list.length === 0) {
                tbody.append('<tr><td colspan="7" style="text-align:center;padding:28px;color:#94a3b8;">No guests registered yet.</td></tr>');
                return;
            }
            $.each(list, function(i, g) {
                tbody.append(
                    '<tr>'
                    + '<td style="color:#94a3b8;font-size:12px;">' + (i+1) + '</td>'
                    + '<td style="font-weight:600;">' + escHtml(g.fullName) + '</td>'
                    + '<td style="color:#475569;">' + escHtml(g.email || '') + '</td>'
                    + '<td style="color:#475569;">' + escHtml(g.phone || '') + '</td>'
                    + '<td>' + escHtml(g.idType || '') + '</td>'
                    + '<td style="color:#475569;">' + escHtml(g.idNumber || '') + '</td>'
                    + '<td><button class="btn-manage" onclick="openManageGuestModal('+g.id+',\''+escHtml(g.firstName)+'\',\''+escHtml(g.lastName)+'\',\''+escHtml(g.email||'')+'\',\''+escHtml(g.phone||'')+'\',\''+escHtml(g.address||'')+'\',\''+escHtml(g.idType||'')+'\',\''+escHtml(g.idNumber||'')+'\')">Manage</button></td>'
                    + '</tr>'
                );
            });
        }).fail(function() {
            $('#guestBody').html('<tr><td colspan="7" style="text-align:center;padding:28px;color:var(--danger);">Failed to load guests.</td></tr>');
        });
    }

    function openAddGuestModal() {
        $('#guestModalTitle').text('Register Guest');
        $('#guestEditId').val('');
        $('#inputGuestFirst').val('');
        $('#inputGuestLast').val('');
        $('#inputGuestEmail').val('');
        $('#inputGuestPhone').val('');
        $('#inputGuestAddress').val('');
        $('#inputGuestIdType').val('Passport');
        $('#inputGuestIdNumber').val('');
        $('#btnDeleteGuest').hide();
        $('#btnSaveGuest').text('Register');
        $('#guestModalOverlay').addClass('open');
    }

    function openManageGuestModal(id, firstName, lastName, email, phone, address, idType, idNumber) {
        $('#guestModalTitle').text('Manage Guest');
        $('#guestEditId').val(id);
        $('#inputGuestFirst').val(firstName);
        $('#inputGuestLast').val(lastName);
        $('#inputGuestEmail').val(email);
        $('#inputGuestPhone').val(phone);
        $('#inputGuestAddress').val(address);
        $('#inputGuestIdType').val(idType);
        $('#inputGuestIdNumber').val(idNumber);
        $('#btnDeleteGuest').show();
        $('#btnSaveGuest').text('Save Changes');
        $('#guestModalOverlay').addClass('open');
    }

    function closeGuestModal() { $('#guestModalOverlay').removeClass('open'); }

    function saveGuest() {
        const id        = $('#guestEditId').val();
        const firstName = $('#inputGuestFirst').val().trim();
        const lastName  = $('#inputGuestLast').val().trim();
        const email     = $('#inputGuestEmail').val().trim();
        const phone     = $('#inputGuestPhone').val().trim();
        const address   = $('#inputGuestAddress').val().trim();
        const idType    = $('#inputGuestIdType').val();
        const idNumber  = $('#inputGuestIdNumber').val().trim();
        if (!firstName || !lastName) { showToast('First and last name are required.'); return; }
        if (id) {
            $.ajax({
                url: CTX + '/api/guest', type: 'PUT',
                data: { id, firstName, lastName, email, phone, address, idType, idNumber },
                success: function(res) {
                    if (res.success) { showToast(res.message || 'Guest updated.'); closeGuestModal(); loadGuests(); }
                    else showToast(res.message || 'Update failed.');
                },
                error: function() { showToast('Server error.'); }
            });
        } else {
            $.ajax({
                url: CTX + '/api/guest', type: 'POST',
                data: { firstName, lastName, email, phone, address, idType, idNumber },
                success: function(res) {
                    if (res.success) { showToast(res.message || 'Guest registered.'); closeGuestModal(); loadGuests(); }
                    else showToast(res.message || 'Failed to register guest.');
                },
                error: function() { showToast('Server error.'); }
            });
        }
    }

    function deleteGuestFromModal() {
        const id = $('#guestEditId').val();
        if (!id) return;
        if (!confirm('Delete this guest? This cannot be undone.')) return;
        $.ajax({
            url: CTX + '/api/guest', type: 'DELETE',
            data: { id },
            success: function(res) {
                if (res.success) { showToast(res.message || 'Guest deleted.'); closeGuestModal(); loadGuests(); }
                else showToast(res.message || 'Delete failed.');
            },
            error: function() { showToast('Server error.'); }
        });
    }

    /* ---- Reservation management ---- */
    let _allReservations = [];
    let _activeResFilter = 'all';

    const RES_STATUS_STYLES = {
        confirmed:   'background:#dcfce7;color:#15803d;',
        pending:     'background:#fef3c7;color:#92400e;',
        cancelled:   'background:#fee2e2;color:#b91c1c;',
        checked_in:  'background:#dbeafe;color:#1e40af;',
        checked_out: 'background:#f3e8ff;color:#6b21a8;'
    };

    function loadReservationsCount() {
        $.getJSON(CTX + '/api/reservation', function(list) {
            $('#statReservations').text(list ? list.length : 0);
        });
    }

    function loadReservations() {
        $.getJSON(CTX + '/api/reservation', function(list) {
            _allReservations = list || [];
            $('#statReservations').text(_allReservations.length);
            _updateFilterCounts();
            applyReservationFilter(_activeResFilter);
        }).fail(function() {
            $('#reservationBody').html('<tr><td colspan="9" style="text-align:center;padding:28px;color:var(--danger);">Failed to load reservations.</td></tr>');
        });
    }

    function _updateFilterCounts() {
        const today = new Date().toISOString().split('T')[0];
        const counts = {
            all:         _allReservations.length,
            today_in:    _allReservations.filter(r => r.checkInDate  === today).length,
            today_out:   _allReservations.filter(r => r.checkOutDate === today).length,
            upcoming:    _allReservations.filter(r => r.checkInDate > today && r.status !== 'cancelled').length,
            confirmed:   _allReservations.filter(r => r.status === 'confirmed').length,
            pending:     _allReservations.filter(r => r.status === 'pending').length,
            checked_in:  _allReservations.filter(r => r.status === 'checked_in').length,
            checked_out: _allReservations.filter(r => r.status === 'checked_out').length,
            cancelled:   _allReservations.filter(r => r.status === 'cancelled').length
        };
        $.each(counts, function(key, val) {
            $('#rc-' + key).text(val);
        });
    }

    function setResFilter(name) {
        _activeResFilter = name;
        // Update pill active state
        $('.filter-pill').removeClass('active');
        $('#rpill-' + name).addClass('active');
        applyReservationFilter(name);
    }

    function applyReservationFilter(name) {
        const today = new Date().toISOString().split('T')[0];
        let filtered;
        switch (name) {
            case 'today_in':    filtered = _allReservations.filter(r => r.checkInDate  === today); break;
            case 'today_out':   filtered = _allReservations.filter(r => r.checkOutDate === today); break;
            case 'upcoming':    filtered = _allReservations.filter(r => r.checkInDate > today && r.status !== 'cancelled'); break;
            case 'confirmed':   filtered = _allReservations.filter(r => r.status === 'confirmed');   break;
            case 'pending':     filtered = _allReservations.filter(r => r.status === 'pending');     break;
            case 'checked_in':  filtered = _allReservations.filter(r => r.status === 'checked_in');  break;
            case 'checked_out': filtered = _allReservations.filter(r => r.status === 'checked_out'); break;
            case 'cancelled':   filtered = _allReservations.filter(r => r.status === 'cancelled');   break;
            default:            filtered = _allReservations;
        }
        _renderReservationTable(filtered);
    }

    function _renderReservationTable(list) {
        const tbody = $('#reservationBody');
        tbody.empty();
        $('#resShownCount').text(list.length);
        if (list.length === 0) {
            tbody.append('<tr><td colspan="9" style="text-align:center;padding:28px;color:#94a3b8;">No reservations match this filter.</td></tr>');
            return;
        }
        $.each(list, function(i, r) {
            const style = RES_STATUS_STYLES[r.status] || 'background:#f1f5f9;color:#475569;';
            const rawStatus = r.status ? r.status.replace('_', ' ') : '';
            const badge = '<span class="chip" style="' + style + '">' + escHtml(rawStatus) + '</span>';
            const checkIn  = r.checkInDate  || '';
            const checkOut = r.checkOutDate || '';
            const created  = r.createdAt ? r.createdAt.substring(0,10) : '';
            // Highlight today's check-ins / check-outs
            const today = new Date().toISOString().split('T')[0];
            let rowStyle = '';
            if (checkIn === today)  rowStyle = 'background:#f0fdf4;';
            if (checkOut === today) rowStyle = 'background:#fff7ed;';
            // Nights
            let nights = '';
            if (checkIn && checkOut) {
                nights = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
            }
            tbody.append(
                '<tr style="' + rowStyle + '">'
                + '<td style="color:#94a3b8;font-size:12px;">' + (i+1) + '</td>'
                + '<td style="font-weight:600;">' + escHtml(r.guestName) + '</td>'
                + '<td style="font-weight:700;color:var(--primary);">' + escHtml(r.roomNumber) + '</td>'
                + '<td style="color:#475569;">' + escHtml(checkIn) + '</td>'
                + '<td style="color:#475569;">' + escHtml(checkOut) + '</td>'
                + '<td style="text-align:center;color:var(--muted);">' + (nights || '—') + '</td>'
                + '<td style="font-weight:600;">$' + parseFloat(r.totalPrice || 0).toFixed(2) + '</td>'
                + '<td>' + badge + '</td>'
                + '<td style="color:#94a3b8;font-size:12px;">' + escHtml(created) + '</td>'
                + '</tr>'
            );
        });
    }

    function openNewReservationModal() {
        // Reset guest search
        clearGuestSelection();
        // Load all guests into memory for search
        $.getJSON(CTX + '/api/guest', function(guests) {
            _resGuestList = guests || [];
        });
        // Populate available room dropdown
        $.getJSON(CTX + '/api/room', function(rooms) {
            const $sel = $('#inputResRoom').empty().append('<option value="" data-price="0">-- Select Room --</option>');
            $.each(rooms || [], function(i, r) {
                if (r.status === 'available') {
                    $sel.append('<option value="' + r.id + '" data-price="' + r.pricePerNight + '">' +
                        'Room ' + escHtml(r.roomNumber) + ' (' + escHtml(r.type) + ') — $' + parseFloat(r.pricePerNight).toFixed(2) + '/night' +
                        '</option>');
                }
            });
        });
        // Set default dates (today and tomorrow)
        const today = new Date();
        const tomorrow = new Date(); tomorrow.setDate(today.getDate() + 1);
        $('#inputResCheckIn').val(today.toISOString().split('T')[0]);
        $('#inputResCheckOut').val(tomorrow.toISOString().split('T')[0]);
        $('#inputResTotalPrice').val('');
        $('#inputResNotes').val('');
        calcTotalPrice();
        $('#reservationModalOverlay').addClass('open');
        setTimeout(function(){ $('#inputGuestSearch').focus(); }, 150);
    }

    /* ---- Guest search in reservation modal ---- */
    let _resGuestList = [];

    function filterGuestResults(term) {
        const $results = $('#guestResults');
        $results.empty();
        const q = term.trim().toLowerCase();
        const matches = q.length === 0
            ? _resGuestList.slice(0, 8)          // show first 8 when input is empty
            : _resGuestList.filter(function(g) {
                const name  = ((g.firstName || '') + ' ' + (g.lastName || '')).toLowerCase();
                const email = (g.email  || '').toLowerCase();
                const phone = (g.phone  || '').toLowerCase();
                return name.includes(q) || email.includes(q) || phone.includes(q);
            });

        if (matches.length === 0) {
            $results.append('<div class="guest-result-empty">No guests found.</div>');
        } else {
            $.each(matches, function(i, g) {
                const fullName = (g.firstName || '') + ' ' + (g.lastName || '');
                const initials = fullName.trim().charAt(0).toUpperCase();
                const sub = [g.phone, g.email].filter(Boolean).join(' • ');
                const $item = $('<div class="guest-result-item">'
                    + '<div class="gri-avatar">' + escHtml(initials) + '</div>'
                    + '<div><div class="gri-name">' + escHtml(fullName.trim()) + '</div>'
                    + '<div class="gri-sub">' + escHtml(sub) + '</div></div>'
                    + '</div>');
                $item.on('mousedown', function(e) {
                    e.preventDefault(); // prevent blur before click fires
                    selectGuest(g);
                });
                $results.append($item);
            });
        }
        $results.addClass('open');
    }

    function selectGuest(g) {
        const fullName = ((g.firstName || '') + ' ' + (g.lastName || '')).trim();
        const sub = [g.phone, g.email].filter(Boolean).join(' • ');
        $('#inputResGuestId').val(g.id);
        $('#gscAvatar').text(fullName.charAt(0).toUpperCase());
        $('#gscName').text(fullName);
        $('#gscSub').text(sub);
        $('#guestSelectedCard').css('display','flex');
        $('#guestSearchWrap').hide();
        $('#guestResults').removeClass('open').empty();
    }

    function clearGuestSelection() {
        $('#inputResGuestId').val('');
        $('#inputGuestSearch').val('');
        $('#guestSelectedCard').hide();
        $('#guestSearchWrap').show();
        $('#guestResults').removeClass('open').empty();
    }

    // Close guest results when clicking outside
    $(document).on('click', function(e) {
        if (!$(e.target).closest('#guestSearchWrap').length) {
            $('#guestResults').removeClass('open');
        }
    });

    function closeReservationModal() { $('#reservationModalOverlay').removeClass('open'); }

    function calcTotalPrice() {
        const $roomOpt = $('#inputResRoom option:selected');
        const price = parseFloat($roomOpt.data('price')) || 0;
        const checkIn  = $('#inputResCheckIn').val();
        const checkOut = $('#inputResCheckOut').val();
        if (price > 0 && checkIn && checkOut) {
            const nights = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
            $('#inputResTotalPrice').val((price * nights).toFixed(2));
        }
    }

    function saveReservation() {
        const guestId    = $('#inputResGuestId').val();
        const roomId     = $('#inputResRoom').val();
        const checkIn    = $('#inputResCheckIn').val();
        const checkOut   = $('#inputResCheckOut').val();
        const totalPrice = $('#inputResTotalPrice').val();
        const status     = 'confirmed';
        const notes      = $('#inputResNotes').val().trim();
        if (!guestId)  { showToast('Please select a guest.');       return; }
        if (!roomId)   { showToast('Please select a room.');        return; }
        if (!checkIn)  { showToast('Check-in date is required.');   return; }
        if (!checkOut) { showToast('Check-out date is required.');  return; }
        if (new Date(checkOut) <= new Date(checkIn)) { showToast('Check-out must be after check-in.'); return; }
        $.ajax({
            url: CTX + '/api/reservation', type: 'POST',
            data: { guestId, roomId, checkInDate: checkIn, checkOutDate: checkOut, totalPrice, status, notes },
            success: function(res) {
                if (res.success) {
                    showToast(res.message || 'Reservation created.');
                    closeReservationModal();
                    loadReservations();
                } else {
                    showToast(res.message || 'Failed to create reservation.');
                }
            },
            error: function() { showToast('Server error.'); }
        });
    }

    function deleteRoom(id) {
        if (!confirm('Delete this room? This cannot be undone.')) return;
        $.ajax({
            url: CTX + '/api/room', type: 'DELETE',
            data: { id },
            success: function(res) {
                if (res.success) { showToast(res.message || 'Room deleted.'); loadRooms(); }
                else showToast(res.message || 'Delete failed.');
            },
            error: function() { showToast('Server error.'); }
        });
    }
</script>
</body>
</html>