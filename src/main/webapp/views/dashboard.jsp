<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Session guard — redirect to login if not authenticated
    Object loggedInUser = session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard – OceanView Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f4f8;
            min-height: 100vh;
        }

        /* ---- Top Nav ---- */
        .navbar {
            background: linear-gradient(135deg, #004a7c, #0089d6);
            color: white;
            padding: 0 30px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 3px 12px rgba(0,0,0,0.2);
        }

        .nav-brand {
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .nav-brand span {
            background: rgba(255,255,255,0.18);
            border-radius: 8px;
            padding: 4px 10px;
            font-size: 11px;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .user-info {
            text-align: right;
        }

        .user-info .name { font-size: 14px; font-weight: 600; }
        .user-info .role-badge {
            font-size: 11px;
            background: rgba(255,255,255,0.2);
            border-radius: 20px;
            padding: 2px 9px;
            letter-spacing: 0.5px;
        }

        .btn-logout {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.35);
            color: white;
            padding: 8px 18px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: background 0.2s;
        }

        .btn-logout:hover { background: rgba(255,255,255,0.28); }

        /* ---- Main Content ---- */
        .main {
            padding: 40px 36px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .welcome-banner {
            background: linear-gradient(135deg, #004a7c, #0089d6);
            color: white;
            border-radius: 16px;
            padding: 34px 36px;
            margin-bottom: 36px;
            position: relative;
            overflow: hidden;
        }

        .welcome-banner::after {
            content: '';
            position: absolute;
            right: -40px;
            top: -40px;
            width: 220px;
            height: 220px;
            border-radius: 50%;
            background: rgba(255,255,255,0.07);
        }

        .welcome-banner h1 { font-size: 26px; margin-bottom: 6px; }
        .welcome-banner p  { font-size: 14px; opacity: 0.82; }

        /* ---- Cards ---- */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
            gap: 24px;
            margin-bottom: 36px;
        }

        .stat-card {
            background: white;
            border-radius: 14px;
            padding: 28px 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.07);
            border-left: 4px solid #0089d6;
        }

        .stat-card .label {
            font-size: 13px;
            color: #7a9ab5;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .stat-card .value {
            font-size: 32px;
            font-weight: 700;
            color: #0a2e4a;
        }

        .stat-card .sub {
            font-size: 12px;
            color: #aabccc;
            margin-top: 6px;
        }

        .stat-card:nth-child(2) { border-left-color: #27ae60; }
        .stat-card:nth-child(3) { border-left-color: #e67e22; }
        .stat-card:nth-child(4) { border-left-color: #8e44ad; }

        /* ---- Section titles ---- */
        .section-title {
            font-size: 16px;
            font-weight: 700;
            color: #0a2e4a;
            margin-bottom: 16px;
        }

        /* ---- Quick action buttons ---- */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 16px;
        }

        .action-btn {
            background: white;
            border: none;
            border-radius: 12px;
            padding: 22px 18px;
            text-align: center;
            cursor: pointer;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            transition: transform 0.2s, box-shadow 0.2s;
            color: #344a5f;
        }

        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }

        .action-btn .icon {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .action-btn .label { font-size: 13px; font-weight: 600; }

        /* Toast */
        #toast {
            position: fixed;
            bottom: 28px;
            right: 28px;
            background: #0a2e4a;
            color: white;
            padding: 14px 22px;
            border-radius: 10px;
            font-size: 14px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.25);
            display: none;
            z-index: 9999;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="nav-brand">
        &#127754; OceanView Resort
        <span>Management System</span>
    </div>
    <div class="nav-right">
        <div class="user-info">
            <div class="name"><%= fullName != null ? fullName : username %></div>
            <div class="role-badge"><%= role %></div>
        </div>
        <button class="btn-logout" onclick="logout()">Sign Out</button>
    </div>
</nav>

<!-- Main Content -->
<div class="main">

    <div class="welcome-banner">
        <h1>Welcome back, <%= fullName != null ? fullName : username %>!</h1>
        <p>Here's a quick overview of your resort operations for today.</p>
    </div>

    <div class="cards-grid">
        <div class="stat-card">
            <div class="label">Total Reservations</div>
            <div class="value">—</div>
            <div class="sub">Coming soon</div>
        </div>
        <div class="stat-card">
            <div class="label">Available Rooms</div>
            <div class="value">—</div>
            <div class="sub">Coming soon</div>
        </div>
        <div class="stat-card">
            <div class="label">Check-ins Today</div>
            <div class="value">—</div>
            <div class="sub">Coming soon</div>
        </div>
        <div class="stat-card">
            <div class="label">Active Staff</div>
            <div class="value">—</div>
            <div class="sub">Coming soon</div>
        </div>
    </div>

    <div class="section-title">Quick Actions</div>
    <div class="actions-grid">
        <div class="action-btn"><div class="icon">&#128716;</div><div class="label">New Booking</div></div>
        <div class="action-btn"><div class="icon">&#128100;</div><div class="label">Guest Check-In</div></div>
        <div class="action-btn"><div class="icon">&#127968;</div><div class="label">Room Status</div></div>
        <div class="action-btn"><div class="icon">&#128203;</div><div class="label">Reports</div></div>
        <div class="action-btn"><div class="icon">&#9881;</div><div class="label">Settings</div></div>
    </div>

</div>

<div id="toast"></div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    function showToast(msg) {
        const $t = $('#toast');
        $t.text(msg).fadeIn(300);
        setTimeout(() => $t.fadeOut(400), 3000);
    }

    function logout() {
        $.ajax({
            url:  '${pageContext.request.contextPath}/api/logout',
            type: 'POST',
            success: function(res) {
                if (res.success) {
                    window.location.href = res.redirect;
                }
            },
            error: function() {
                // Fallback
                window.location.href = '${pageContext.request.contextPath}/views/login.jsp';
            }
        });
    }

    $(document).ready(function() {
        showToast('Logged in successfully! Welcome to OceanView Resort.');
    });
</script>

</body>
</html>
