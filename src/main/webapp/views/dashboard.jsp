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
        <% } %>

        <div class="nav-section-label" style="margin-top:12px;">Operations</div>
        <a class="nav-item" href="#"><span class="ni">&#128716;</span> Bookings</a>
        <a class="nav-item" href="#"><span class="ni">&#127968;</span> Rooms</a>
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
            <div class="stat">
                <div class="stat-icon si-blue">&#128716;</div>
                <div class="stat-info">
                    <div class="s-label">Total Reservations</div>
                    <div class="s-value"></div>
                    <div class="s-sub">Coming soon</div>
                </div>
            </div>
            <div class="stat">
                <div class="stat-icon si-green">&#127968;</div>
                <div class="stat-info">
                    <div class="s-label">Available Rooms</div>
                    <div class="s-value"></div>
                    <div class="s-sub">Coming soon</div>
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
            <div class="stat">
                <div class="stat-icon si-purple">&#128101;</div>
                <div class="stat-info">
                    <div class="s-label">Receptionists</div>
                    <div class="s-value" id="statReceptionists"></div>
                    <div class="s-sub">Total registered</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="section-hd">Quick Actions</div>
        <div class="actions-row">
            <button class="act-btn"><span class="ai">&#128716;</span> New Booking</button>
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

<div id="toast"></div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    const CTX = '${pageContext.request.contextPath}';

    // Date in topbar
    (function(){
        const d = new Date();
        const opts = { weekday:'long', year:'numeric', month:'long', day:'numeric' };
        document.getElementById('currentDate').textContent = d.toLocaleDateString('en-US', opts);
    })();

    /* ---- Sidebar tab navigation ---- */
    const PAGE_TITLES = { dashboard: 'Dashboard', receptionists: 'Receptionist Management' };

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
        // Load data when switching to receptionists
        if (name === 'receptionists') loadReceptionists();
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
        loadReceptionists(); // pre-fetch for the stat card count
        <% } %>
    });
</script>
</body>
</html>