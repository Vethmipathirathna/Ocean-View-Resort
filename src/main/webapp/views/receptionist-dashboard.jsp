<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Receptionists now use the unified dashboard
    response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receptionist Dashboard  OceanView Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
               background: #f0f4f8; min-height: 100vh; }

        /* ---- Navbar ---- */
        .navbar {
            background: linear-gradient(135deg, #1a3a4a 0%, #0d6efd 100%);
            color: #fff; display: flex; align-items: center;
            justify-content: space-between; padding: 0 2rem; height: 64px;
            box-shadow: 0 2px 8px rgba(0,0,0,.3);
        }
        .navbar .brand { font-size: 1.4rem; font-weight: 700; letter-spacing: 1px; }
        .navbar .nav-right { display: flex; align-items: center; gap: 1.5rem; }
        .navbar .nav-right span { font-size: .95rem; }
        .btn-signout {
            background: rgba(255,255,255,.15); border: 1px solid rgba(255,255,255,.4);
            color: #fff; padding: .4rem 1.1rem; border-radius: 6px; cursor: pointer;
            font-size: .9rem; transition: background .2s;
        }
        .btn-signout:hover { background: rgba(255,255,255,.3); }

        /* ---- Main area ---- */
        .main { max-width: 1100px; margin: 2.5rem auto; padding: 0 1.5rem; }

        .welcome-banner {
            background: linear-gradient(135deg, #1a3a4a, #0d6efd);
            color: #fff; border-radius: 14px; padding: 2rem 2.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(13,110,253,.3);
        }
        .welcome-banner h1 { font-size: 1.8rem; margin-bottom: .3rem; }
        .welcome-banner p  { opacity: .85; }

        /* ---- Info cards ---- */
        .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                 gap: 1.3rem; margin-bottom: 2rem; }
        .card {
            background: #fff; border-radius: 12px; padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,.08); text-align: center;
        }
        .card .icon { font-size: 2.2rem; margin-bottom: .5rem; }
        .card h3   { font-size: .9rem; color: #6c757d; text-transform: uppercase;
                     letter-spacing: .5px; margin-bottom: .3rem; }
        .card p    { font-size: 1.6rem; font-weight: 700; color: #1a3a4a; }

        /* ---- Tasks panel ---- */
        .panel {
            background: #fff; border-radius: 12px; padding: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,.08);
        }
        .panel h2 { font-size: 1.2rem; margin-bottom: 1.2rem;
                    color: #1a3a4a; border-bottom: 2px solid #e9ecef; padding-bottom: .6rem; }
        .task-list { list-style: none; }
        .task-list li {
            padding: .75rem 0; border-bottom: 1px solid #f0f4f8;
            display: flex; align-items: center; gap: .75rem; color: #444;
        }
        .task-list li:last-child { border-bottom: none; }
        .task-list .dot {
            width: 10px; height: 10px; border-radius: 50%;
            background: #0d6efd; flex-shrink: 0;
        }

        /* ---- Toast ---- */
        #toast {
            position: fixed; bottom: 2rem; right: 2rem;
            background: #1a3a4a; color: #fff; padding: .9rem 1.5rem;
            border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,.3);
            display: none; z-index: 9999; font-size: .95rem;
        }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">&#127754; OceanView Resort</div>
    <div class="nav-right">
        <span>Welcome, <%= fullName != null ? fullName : "Receptionist" %></span>
        <button class="btn-signout" id="signOutBtn">Sign Out</button>
    </div>
</nav>

<div class="main">
    <div class="welcome-banner">
        <h1>Receptionist Dashboard</h1>
        <p>Manage guest check-ins, reservations, and front-desk operations.</p>
    </div>

    <div class="cards">
        <div class="card">
            <div class="icon">&#128203;</div>
            <h3>Check-Ins Today</h3>
            <p>--</p>
        </div>
        <div class="card">
            <div class="icon">&#127968;</div>
            <h3>Available Rooms</h3>
            <p>--</p>
        </div>
        <div class="card">
            <div class="icon">&#128222;</div>
            <h3>Pending Requests</h3>
            <p>--</p>
        </div>
    </div>

    <div class="panel">
        <h2>Today's Tasks</h2>
        <ul class="task-list">
            <li><span class="dot"></span>Greet arriving guests and verify reservations.</li>
            <li><span class="dot"></span>Process early check-outs and billing.</li>
            <li><span class="dot"></span>Coordinate room-service requests with housekeeping.</li>
            <li><span class="dot"></span>Answer guest inquiries regarding resort facilities.</li>
            <li><span class="dot"></span>Update daily occupancy report before end of shift.</li>
        </ul>
    </div>
</div>

<div id="toast"></div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    const CTX = "${pageContext.request.contextPath}";

    function showToast(msg) {
        $("#toast").text(msg).fadeIn(300);
        setTimeout(function () { $("#toast").fadeOut(400); }, 3000);
    }

    $("#signOutBtn").on("click", function () {
        $.ajax({
            url: CTX + "/api/logout",
            type: "POST",
            success: function () {
                showToast("Signed out successfully.");
                setTimeout(function () { window.location.href = CTX + "/views/login.jsp"; }, 1000);
            },
            error: function () { window.location.href = CTX + "/views/login.jsp"; }
        });
    });
</script>
</body>
</html>
