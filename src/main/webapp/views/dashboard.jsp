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
        /* ---- Bill / Invoice ---- */
        #billOverlay {
            position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:3000;
            display:none;align-items:center;justify-content:center;
        }
        #billOverlay.open { display:flex; }
        #billBox {
            background:#fff;width:420px;max-width:96vw;
            border-radius:12px;overflow:hidden;
            box-shadow:0 12px 40px rgba(0,0,0,.25);
            font-family:'Segoe UI',system-ui,sans-serif;color:#1e293b;
        }
        #billHead {
            background:#1d4ed8;color:#fff;
            padding:22px 28px;text-align:center;
        }
        #billHead h2 { margin:0 0 2px;font-size:18px;font-weight:700; }
        #billHead p  { margin:0;font-size:12px;opacity:.8; }
        #billBody { padding:22px 28px; }
        #billBody .b-row {
            display:flex;justify-content:space-between;
            padding:7px 0;border-bottom:1px solid #f1f5f9;
            font-size:13.5px;
        }
        #billBody .b-row .b-lbl { color:#64748b; }
        #billBody .b-row .b-val { font-weight:600;text-align:right; }
        #billBody .b-total {
            display:flex;justify-content:space-between;
            padding:12px 0 0;margin-top:6px;
            border-top:2px solid #1d4ed8;
            font-size:16px;font-weight:800;color:#1d4ed8;
        }
        #billBody .b-notes {
            margin-top:14px;font-size:12.5px;color:#64748b;
            background:#f8fafc;border-radius:6px;padding:8px 12px;
        }
        #billActions {
            display:flex;gap:10px;justify-content:flex-end;
            padding:12px 16px;border-top:1px solid #e2e8f0;background:#f8fafc;
        }
        /* ===== REPORTS PAGE ===== */
        .rpt-kpi-row {
            display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:18px;margin-bottom:28px;
        }
        .rpt-kpi {
            background:var(--card);border-radius:14px;padding:20px 18px;
            box-shadow:0 1px 4px rgba(0,0,0,.06);
            display:flex;align-items:center;gap:14px;
        }
        .rpt-kpi-icon {
            width:46px;height:46px;border-radius:12px;
            display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0;
        }
        .rpt-kpi-info .rk-lbl { font-size:11.5px;color:var(--muted);font-weight:500;margin-bottom:2px; }
        .rpt-kpi-info .rk-val { font-size:26px;font-weight:700;color:var(--text);line-height:1; }
        .rpt-kpi-info .rk-sub { font-size:11px;color:var(--muted);margin-top:3px; }

        .rpt-filter-bar {
            background:var(--card);border-radius:12px;padding:16px 20px;
            margin-bottom:22px;display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;
            box-shadow:0 1px 4px rgba(0,0,0,.05);
        }
        .rpt-filter-bar .fg { margin:0;min-width:140px; }
        .rpt-filter-bar .fg label { font-size:11.5px;font-weight:600;color:var(--muted);margin-bottom:4px;display:block; }
        .rpt-filter-bar .fg input,
        .rpt-filter-bar .fg select {
            padding:8px 12px;border:1px solid var(--border);border-radius:8px;
            font-size:13px;font-family:inherit;outline:none;width:100%;
            background:var(--card);color:var(--text);
            transition:border-color .15s;
        }
        .rpt-filter-bar .fg input:focus,
        .rpt-filter-bar .fg select:focus { border-color:var(--primary); }
        .btn-rpt-apply {
            background:var(--primary);color:#fff;border:none;
            padding:9px 22px;border-radius:8px;cursor:pointer;
            font-size:13px;font-weight:600;font-family:inherit;
            transition:background .15s;align-self:flex-end;
        }
        .btn-rpt-apply:hover { background:var(--primary-d); }
        .btn-rpt-print {
            margin-left:auto;background:#f0fdf4;color:#15803d;
            border:1px solid #86efac;padding:9px 20px;border-radius:8px;
            cursor:pointer;font-size:13px;font-weight:600;font-family:inherit;
            display:flex;align-items:center;gap:7px;transition:all .15s;
        }
        .btn-rpt-print:hover { background:#dcfce7; }

        .rpt-section-hd { font-size:14px;font-weight:700;color:var(--text);margin:28px 0 14px; }

        /* Monthly bar chart */
        .rpt-bar-grid {
            display:grid;grid-template-columns:repeat(12,1fr);gap:8px;
            align-items:flex-end;height:140px;margin-bottom:8px;
        }
        .rpt-bar-col { display:flex;flex-direction:column;align-items:center;gap:4px; }
        .rpt-bar {
            width:100%;background:var(--primary);border-radius:5px 5px 0 0;
            min-height:4px;transition:height .4s;
        }
        .rpt-bar-lbl { font-size:10px;color:var(--muted);white-space:nowrap; }
        .rpt-bar-val { font-size:11px;font-weight:700;color:var(--text); }
        .rpt-chart-wrap {
            background:var(--card);border-radius:12px;
            padding:20px 22px 14px;margin-bottom:28px;
            box-shadow:0 1px 4px rgba(0,0,0,.05);
        }
        .rpt-chart-legend {
            display:flex;gap:20px;font-size:11.5px;color:var(--muted);
            margin-top:6px;padding-top:10px;border-top:1px solid var(--border);
        }
        .rpt-chart-legend span { display:inline-flex;align-items:center;gap:5px; }
        .rpt-chart-legend .dot { width:10px;height:10px;border-radius:50%;background:var(--primary); }
        .rpt-chart-legend .dot-rev { background:#10b981; }

        /* History table wrapper */
        .rpt-table-wrap {
            background:var(--card);border-radius:12px;
            box-shadow:0 1px 4px rgba(0,0,0,.05);overflow:hidden;
        }
        .rpt-table-hd {
            display:flex;align-items:center;justify-content:space-between;
            padding:14px 20px;border-bottom:1px solid var(--border);
        }
        .rpt-table-hd h3 { font-size:14px;font-weight:700;color:var(--text); }
        .rpt-table-hd small { font-size:12px;color:var(--muted); }

        @media print {
            /* === Bill printing (body.print-bill) === */
            body.print-bill > *:not(#billOverlay) { display:none !important; }
            body.print-bill #billOverlay { position:static !important;background:none !important;display:block !important; }
            body.print-bill #billBox { box-shadow:none !important;border-radius:0 !important;width:100% !important; }
            body.print-bill #billHead { padding:36px 48px !important; }
            body.print-bill #billHead h2 { font-size:30px !important; }
            body.print-bill #billHead p  { font-size:16px !important; }
            body.print-bill #billBody { padding:36px 48px !important; }
            body.print-bill #billBody .b-row { font-size:18px !important;padding:10px 0 !important; }
            body.print-bill #billBody .b-total { font-size:24px !important;padding-top:16px !important; }
            body.print-bill #billBody .b-notes { font-size:16px !important; }
            body.print-bill #billBody #billDate { font-size:14px !important; }
            body.print-bill #billActions { display:none !important; }

            /* === Report printing (body.print-report) === */
            body.print-report .sidebar,
            body.print-report .topbar,
            body.print-report #billOverlay,
            body.print-report .rpt-filter-bar,
            body.print-report .btn-rpt-print { display:none !important; }
            body.print-report .main-wrap { margin-left:0 !important; }
            body.print-report #page-reports { display:block !important; }
            body.print-report .rpt-kpi-info .rk-val { font-size:22px !important; }
            body.print-report table { font-size:11px !important; }
            body.print-report thead th { font-size:10px !important; }
            body.print-report tbody td { padding:6px 10px !important; }

            @page { size:A4;margin:1.5cm; }
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
        <% if ("admin".equalsIgnoreCase(role) || "receptionist".equalsIgnoreCase(role)) { %>
        <a class="nav-item" data-page="guests" href="#" onclick="showPage('guests');return false;">
            <span class="ni">&#128100;</span> Guests
        </a>
        <% } %>

        <div class="nav-section-label" style="margin-top:12px;">Operations</div>
        <a class="nav-item" data-page="reservations" href="#" onclick="showPage('reservations');return false;"><span class="ni">&#128716;</span> Bookings</a>
        <a class="nav-item" data-page="rooms" href="#" onclick="showPage('rooms');return false;"><span class="ni">&#127968;</span> Rooms</a>
        <% if ("admin".equalsIgnoreCase(role) || "receptionist".equalsIgnoreCase(role)) { %>
        <a class="nav-item" data-page="reports" href="#" onclick="showPage('reports');return false;"><span class="ni">&#128203;</span> Reports</a>
        <% } %>
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
                    <div class="s-sub">Available right now</div>
                </div>
            </div>
            <div class="stat" style="cursor:pointer" onclick="showPage('reservations');setResFilter('today_in')">
                <div class="stat-icon si-amber">&#128100;</div>
                <div class="stat-info">
                    <div class="s-label">Checked In Today</div>
                    <div class="s-value" id="statCheckInsToday">0</div>
                    <div class="s-sub" id="statCheckInsSub">Loading&hellip;</div>
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
            <% if ("admin".equalsIgnoreCase(role)) { %>
            <button class="act-btn" onclick="showPage('reports')"><span class="ai">&#128203;</span> Reports</button>
            <% } %>
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

        <!-- Availability Summary Cards -->
        <div class="stats-row" style="margin-bottom:20px;">
            <div class="stat">
                <div class="stat-icon si-blue">&#127968;</div>
                <div class="stat-info">
                    <div class="s-label">Total Rooms</div>
                    <div class="s-value" id="roomStatTotal">0</div>
                    <div class="s-sub">All rooms</div>
                </div>
            </div>
            <div class="stat">
                <div class="stat-icon si-green">&#9989;</div>
                <div class="stat-info">
                    <div class="s-label">Available</div>
                    <div class="s-value" id="roomStatAvailable" style="color:#16a34a;">0</div>
                    <div class="s-sub">Ready to book</div>
                </div>
            </div>
            <div class="stat">
                <div class="stat-icon si-amber">&#128716;</div>
                <div class="stat-info">
                    <div class="s-label">Occupied</div>
                    <div class="s-value" id="roomStatOccupied" style="color:#d97706;">0</div>
                    <div class="s-sub">Currently in use</div>
                </div>
            </div>
            <div class="stat">
                <div class="stat-icon" style="background:#fee2e2;">&#128295;</div>
                <div class="stat-info">
                    <div class="s-label">Maintenance</div>
                    <div class="s-value" id="roomStatMaintenance" style="color:#dc2626;">0</div>
                    <div class="s-sub">Under service</div>
                </div>
            </div>
        </div>

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
    <% if ("admin".equalsIgnoreCase(role) || "receptionist".equalsIgnoreCase(role)) { %>
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
                <% if ("admin".equalsIgnoreCase(role) || "receptionist".equalsIgnoreCase(role)) { %>
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
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="reservationBody">
                    <tr><td colspan="10" style="text-align:center;padding:28px;color:#94a3b8;">Loading&hellip;</td></tr>
                </tbody>
            </table>
        </div>
    </div><!-- /#page-reservations -->

    <!-- ===== VIEW: REPORTS ===== -->
    <% if ("admin".equalsIgnoreCase(role) || "receptionist".equalsIgnoreCase(role)) { %>
    <div id="page-reports" style="display:none;">

        <!-- KPI Cards -->
        <div class="rpt-kpi-row">
            <div class="rpt-kpi">
                <div class="rpt-kpi-icon si-blue">&#128716;</div>
                <div class="rpt-kpi-info">
                    <div class="rk-lbl">Total Reservations</div>
                    <div class="rk-val" id="rptTotal">0</div>
                    <div class="rk-sub" id="rptTotalSub">in selected period</div>
                </div>
            </div>
            <div class="rpt-kpi">
                <div class="rpt-kpi-icon si-green">&#128176;</div>
                <div class="rpt-kpi-info">
                    <div class="rk-lbl">Total Revenue</div>
                    <div class="rk-val" id="rptRevenue">$0</div>
                    <div class="rk-sub">from completed stays</div>
                </div>
            </div>
            <div class="rpt-kpi">
                <div class="rpt-kpi-icon si-amber">&#127769;</div>
                <div class="rpt-kpi-info">
                    <div class="rk-lbl">Avg Stay</div>
                    <div class="rk-val" id="rptAvgNights">0</div>
                    <div class="rk-sub">nights per reservation</div>
                </div>
            </div>
            <div class="rpt-kpi">
                <div class="rpt-kpi-icon si-purple">&#10060;</div>
                <div class="rpt-kpi-info">
                    <div class="rk-lbl">Cancellation Rate</div>
                    <div class="rk-val" id="rptCancelRate">0%</div>
                    <div class="rk-sub">of all reservations</div>
                </div>
            </div>
        </div>

        <!-- Filter Bar -->
        <div class="rpt-filter-bar">
            <div class="fg" style="min-width:220px;flex:1;">
                <label>&#128269; Search Guest (name / ID / phone / email)</label>
                <input type="text" id="rptSearch" placeholder="e.g. John, #12, 077..." oninput="applyReportFilter()">
            </div>
            <div class="fg">
                <label>From Date</label>
                <input type="date" id="rptFrom">
            </div>
            <div class="fg">
                <label>To Date</label>
                <input type="date" id="rptTo">
            </div>
            <div class="fg">
                <label>Status</label>
                <select id="rptStatus" onchange="applyReportFilter()">
                    <option value="all">All Statuses</option>
                    <option value="confirmed">Confirmed</option>
                    <option value="checked_in">Checked In</option>
                    <option value="checked_out">Checked Out</option>
                    <option value="cancelled">Cancelled</option>
                    <option value="pending">Pending</option>
                </select>
            </div>
            <button class="btn-rpt-apply" onclick="applyReportFilter()">Apply Filter</button>
            <button class="btn-rpt-print" onclick="printReport()">&#128438; Print Report</button>
        </div>

        <!-- Monthly Breakdown Chart -->
        <div class="rpt-section-hd">Monthly Breakdown (Last 12 Months)</div>
        <div class="rpt-chart-wrap">
            <div class="rpt-bar-grid" id="rptBarGrid"></div>
            <div class="rpt-chart-legend">
                <span><i class="dot"></i> Reservations per month</span>
                <span id="rptChartPeak"></span>
            </div>
        </div>

        <!-- History Table -->
        <div class="rpt-table-wrap">
            <div class="rpt-table-hd">
                <h3>Reservation History</h3>
                <small id="rptHistoryCount">0 records</small>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Guest</th>
                        <th>ID#</th>
                        <th>Phone</th>
                        <th>Email</th>
                        <th>Room</th>
                        <th>Check-In</th>
                        <th>Check-Out</th>
                        <th>Nights</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <tbody id="rptHistoryBody">
                    <tr><td colspan="12" style="text-align:center;padding:28px;color:#94a3b8;">Apply a filter to load history.</td></tr>
                </tbody>
            </table>
        </div>

    </div><!-- /#page-reports -->
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
                <input type="date" id="inputResCheckIn" onchange="refreshNewResRooms()">
            </div>
            <div class="fg">
                <label>Check-Out Date</label>
                <input type="date" id="inputResCheckOut" onchange="refreshNewResRooms()">
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

<!-- Manage Reservation Modal -->
<div class="overlay" id="manageResModalOverlay">
    <div class="modal" style="width:500px;">
        <div class="modal-hd">
            <h3 id="manageResTitle">Manage Reservation</h3>
            <button class="modal-close" onclick="closeManageResModal()">&#215;</button>
        </div>
        <input type="hidden" id="manageResId">
        <input type="hidden" id="manageResStatus">
        <div class="fg" style="grid-column:1/-1;">
            <label>Room</label>
            <select id="manageResRoom" style="width:100%;padding:9px 13px;border:1px solid var(--border);border-radius:9px;font-size:14px;outline:none;font-family:inherit;" onchange="recalcManageTotalPrice()">
            </select>
        </div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:0 16px;">
            <div class="fg">
                <label>Check-In Date</label>
                <input type="date" id="manageResCheckIn" onchange="refreshManageResRooms()">
            </div>
            <div class="fg">
                <label>Check-Out Date</label>
                <input type="date" id="manageResCheckOut" onchange="refreshManageResRooms()">
            </div>
        </div>
        <div class="fg">
            <label>Notes</label>
            <input type="text" id="manageResNotes" placeholder="Optional notes">
        </div>
        <div class="modal-foot">
            <button class="btn-cancel" onclick="closeManageResModal()">Cancel</button>
            <button class="btn-save" onclick="deleteReservationFromModal()" style="background:var(--danger);">Delete</button>
            <button id="btnManageCancelRes" class="btn-save" style="background:#dc2626;" onclick="quickStatusChange($('#manageResId').val(),'cancelled')">&#10007; Cancel Reservation</button>
            <button class="btn-save" onclick="saveReservationChanges()">Save Changes</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<!-- Bill / Invoice -->
<div id="billOverlay">
    <div id="billBox">
        <div id="billHead">
            <h2>&#127754; OceanView Resort</h2>
            <p>Reservation Invoice &nbsp;&bull;&nbsp; #<span id="billResId"></span></p>
        </div>
        <div id="billBody">
            <div class="b-row"><span class="b-lbl">Guest</span><span class="b-val" id="billGuest"></span></div>
            <div class="b-row"><span class="b-lbl">Room</span><span class="b-val" id="billRoom"></span></div>
            <div class="b-row"><span class="b-lbl">Check-In</span><span class="b-val" id="billCheckIn"></span></div>
            <div class="b-row"><span class="b-lbl">Check-Out</span><span class="b-val" id="billCheckOut"></span></div>
            <div class="b-row"><span class="b-lbl">Nights</span><span class="b-val" id="billNights"></span></div>
            <div class="b-row"><span class="b-lbl">Rate / Night</span><span class="b-val" id="billRate"></span></div>
            <div class="b-total"><span>Total</span><span id="billTotal"></span></div>
            <div class="b-notes" id="billNotesWrap"><strong>Notes:</strong> <span id="billNotes"></span></div>
            <div style="text-align:center;margin-top:14px;font-size:11.5px;color:#94a3b8;" id="billDate"></div>
        </div>
        <div id="billActions">
            <button class="btn-cancel" onclick="document.getElementById('billOverlay').classList.remove('open')">Close</button>
            <button class="btn-save" onclick="var t=document.title;document.title='OceanView Resort - Invoice';document.body.classList.add('print-bill');window.print();document.body.classList.remove('print-bill');document.title=t;">&#128438;&nbsp; Print</button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    const CTX = '${pageContext.request.contextPath}';
    const USER_ROLE = '<%= role %>'.toLowerCase();
    $.ajaxSetup({ cache: false }); // always fetch fresh data, never use browser-cached GET responses

    // Returns local date string YYYY-MM-DD (avoids UTC offset issues with toISOString)
    function localDate(d) {
        return d.getFullYear() + '-'
            + String(d.getMonth() + 1).padStart(2, '0') + '-'
            + String(d.getDate()).padStart(2, '0');
    }

    // Date in topbar
    (function(){
        const d = new Date();
        const opts = { weekday:'long', year:'numeric', month:'long', day:'numeric' };
        document.getElementById('currentDate').textContent = d.toLocaleDateString('en-US', opts);
    })();

    /* ---- Sidebar tab navigation ---- */
    const PAGE_TITLES = { dashboard: 'Dashboard', receptionists: 'Receptionist Management', rooms: 'Room Management', guests: 'Guest Management', reservations: 'Reservation Management', reports: 'Reports & History' };

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
        if (name === 'reports')      loadReport();
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
        if (USER_ROLE === 'admin') {
            loadReceptionists();
            loadRoomsCount();
            loadGuestsCount();
            loadReservationsCount();
        }
    });

    /* ---- Room management ---- */
    function loadRoomsCount() {
        const today    = localDate(new Date());
        const tomorrow = localDate(new Date(Date.now() + 86400000));
        $.getJSON(CTX + '/api/room?checkIn=' + today + '&checkOut=' + tomorrow + '&excludeRes=-1', function(list) {
            $('#statRooms').text(list ? list.length : 0);
        });
    }

    function loadRooms() {
        $.getJSON(CTX + '/api/room', function(list) {
            const tbody = $('#roomBody');
            tbody.empty();
            loadRoomsCount(); // use date-aware count
            if (!list || list.length === 0) {
                tbody.append('<tr><td colspan="7" style="text-align:center;padding:28px;color:#94a3b8;">No rooms found.</td></tr>');
                $('#roomStatTotal').text(0);
                $('#roomStatAvailable').text(0);
                $('#roomStatOccupied').text(0);
                $('#roomStatMaintenance').text(0);
                return;
            }
            // Availability summary
            const avail = list.filter(function(r){ return r.status === 'available'; }).length;
            const occup = list.filter(function(r){ return r.status === 'occupied'; }).length;
            const maint = list.filter(function(r){ return r.status === 'maintenance'; }).length;
            $('#roomStatTotal').text(list.length);
            $('#roomStatAvailable').text(avail);
            $('#roomStatOccupied').text(occup);
            $('#roomStatMaintenance').text(maint);
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
            const arr = list || [];
            $('#statReservations').text(arr.length);
            const today = localDate(new Date());
            const actuallyCheckedIn = arr.filter(r => r.checkInDate === today && r.status === 'checked_in').length;
            const expectedToday     = arr.filter(r => r.checkInDate === today && r.status !== 'cancelled').length;
            $('#statCheckInsToday').text(actuallyCheckedIn);
            $('#statCheckInsSub').text(actuallyCheckedIn + ' of ' + expectedToday + ' arrived today');
        });
    }

    function loadReservations() {
        $.getJSON(CTX + '/api/reservation', function(list) {
            _allReservations = list || [];
            $('#statReservations').text(_allReservations.length);
            // Today's check-ins stat
            const today = localDate(new Date());
            const actuallyCheckedIn = _allReservations.filter(r => r.checkInDate === today && r.status === 'checked_in').length;
            const expectedToday     = _allReservations.filter(r => r.checkInDate === today && r.status !== 'cancelled').length;
            $('#statCheckInsToday').text(actuallyCheckedIn);
            $('#statCheckInsSub').text(actuallyCheckedIn + ' of ' + expectedToday + ' arrived today');
            _updateFilterCounts();
            applyReservationFilter(_activeResFilter);
            loadRoomsCount(); // refresh available-room count after reservation changes
        }).fail(function() {
            $('#reservationBody').html('<tr><td colspan="9" style="text-align:center;padding:28px;color:var(--danger);">Failed to load reservations.</td></tr>');
        });
    }

    function _updateFilterCounts() {
        const today = localDate(new Date());
        const counts = {
            all:         _allReservations.length,
            today_in:    _allReservations.filter(r => r.checkInDate  === today && r.status !== 'cancelled').length,
            today_out:   _allReservations.filter(r => r.checkOutDate === today && r.status !== 'cancelled').length,
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
        const today = localDate(new Date());
        let filtered;
        switch (name) {
            case 'today_in':    filtered = _allReservations.filter(r => r.checkInDate  === today && r.status !== 'cancelled'); break;
            case 'today_out':   filtered = _allReservations.filter(r => r.checkOutDate === today && r.status !== 'cancelled'); break;
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
            const today = localDate(new Date());
            let rowStyle = '';
            if (checkIn === today)  rowStyle = 'background:#f0fdf4;';
            if (checkOut === today) rowStyle = 'background:#fff7ed;';
            // Nights
            let nights = '';
            if (checkIn && checkOut) {
                nights = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
            }
            // Manage button (admin + receptionist)
            const manageBtn = (USER_ROLE === 'admin' || USER_ROLE === 'receptionist')
                ? '<button class="btn-manage" onclick="openManageResModal(' + r.id + ')">Manage</button>'
                : '';
            const printBillBtn = '<button class="btn-manage" style="background:#f0fdf4;color:#15803d;border:1px solid #86efac;" onclick="printBill(' + r.id + ')">&#128438; Bill</button> ';
            const isStaff = (USER_ROLE === 'admin' || USER_ROLE === 'receptionist');
            const checkInBtn  = (isStaff && (r.status === 'confirmed' || r.status === 'pending'))
                ? '<button class="btn-manage" style="background:#dcfce7;color:#16a34a;border:1px solid #86efac;" onclick="quickStatusChange(' + r.id + ',\'checked_in\')">Check In</button> '
                : '';
            const checkOutBtn = (isStaff && r.status === 'checked_in')
                ? '<button class="btn-manage" style="background:#dbeafe;color:#0369a1;border:1px solid #93c5fd;" onclick="quickStatusChange(' + r.id + ',\'checked_out\')">Check Out</button> '
                : '';
            const cancelResBtn = (isStaff && r.status !== 'cancelled' && r.status !== 'checked_out')
                ? '<button class="btn-manage" style="background:#fee2e2;color:#dc2626;border:1px solid #fca5a5;" onclick="quickStatusChange(' + r.id + ',\'cancelled\')">Cancel</button> '
                : '';
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
                + '<td>' + checkInBtn + checkOutBtn + cancelResBtn + printBillBtn + manageBtn + '</td>'
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
        // Set default dates (today and tomorrow)
        const today = new Date();
        const tomorrow = new Date(); tomorrow.setDate(today.getDate() + 1);
        $('#inputResCheckIn').val(localDate(today));
        $('#inputResCheckOut').val(localDate(tomorrow));
        $('#inputResTotalPrice').val('');
        $('#inputResNotes').val('');
        refreshNewResRooms(); // loads rooms filtered by selected dates, then recalcs price
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

    // Re-fetches the room dropdown for the New Reservation modal based on selected dates.
    function refreshNewResRooms() {
        const checkIn  = $('#inputResCheckIn').val();
        const checkOut = $('#inputResCheckOut').val();
        const currentRoomId = parseInt($('#inputResRoom').val()) || 0;
        if (!checkIn || !checkOut) {
            // No dates yet — load all available rooms without date filter
            $.getJSON(CTX + '/api/room', function(rooms) {
                const $sel = $('#inputResRoom').empty()
                    .append('<option value="" data-price="0">-- Select Room --</option>');
                $.each(rooms || [], function(i, r) {
                    if (r.status !== 'available') return;
                    const $opt = $('<option>').val(r.id)
                        .text('Room ' + escHtml(r.roomNumber) + ' (' + escHtml(r.type) + ') \u2014 $' + parseFloat(r.pricePerNight).toFixed(2) + '/night')
                        .attr('data-price', r.pricePerNight);
                    if (r.id === currentRoomId) $opt.prop('selected', true);
                    $sel.append($opt);
                });
                calcTotalPrice();
            });
            return;
        }
        $.getJSON(CTX + '/api/room?checkIn=' + checkIn + '&checkOut=' + checkOut + '&excludeRes=-1', function(rooms) {
            const $sel = $('#inputResRoom').empty()
                .append('<option value="" data-price="0">-- Select Room --</option>');
            $.each(rooms || [], function(i, r) {
                const $opt = $('<option>').val(r.id)
                    .text('Room ' + escHtml(r.roomNumber) + ' (' + escHtml(r.type) + ') \u2014 $' + parseFloat(r.pricePerNight).toFixed(2) + '/night')
                    .attr('data-price', r.pricePerNight);
                if (r.id === currentRoomId) $opt.prop('selected', true);
                $sel.append($opt);
            });
            calcTotalPrice();
        });
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
                    closeReservationModal();
                    loadReservations();
                    // Build and show bill
                    const guestName = $('#gscName').text() || 'Guest';
                    const $roomOpt  = $('#inputResRoom option:selected');
                    const roomLabel = $roomOpt.text().split(' \u2014 ')[0].trim();
                    const rate      = parseFloat($roomOpt.data('price')) || 0;
                    const nights    = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
                    const total     = parseFloat(totalPrice) || (rate * nights);
                    $('#billResId').text(res.id || '-');
                    $('#billGuest').text(guestName);
                    $('#billRoom').text(roomLabel);
                    $('#billCheckIn').text(checkIn);
                    $('#billCheckOut').text(checkOut);
                    $('#billNights').text(nights);
                    $('#billRate').text('$' + rate.toFixed(2));
                    $('#billTotal').text('$' + total.toFixed(2));
                    $('#billDate').text('Issued: ' + new Date().toLocaleDateString('en-US',{year:'numeric',month:'long',day:'numeric'}));
                    if (notes) { $('#billNotes').text(notes); $('#billNotesWrap').show(); }
                    else        { $('#billNotesWrap').hide(); }
                    $('#billOverlay').addClass('open');
                } else {
                    showToast(res.message || 'Failed to create reservation.');
                }
            },
            error: function() { showToast('Server error.'); }
        });
    }

    /* ---- Manage (edit/delete) reservation ---- */
    let _manageResCurrentId     = 0;
    let _manageResCurrentRoomId = 0;

    function openManageResModal(id) {
        const r = _allReservations.find(function(x){ return x.id === id; });
        if (!r) { showToast('Reservation not found.'); return; }
        _manageResCurrentId     = r.id;
        _manageResCurrentRoomId = r.roomId;
        $('#manageResId').val(r.id);
        $('#manageResStatus').val(r.status || 'confirmed');
        $('#manageResCheckIn').val(r.checkInDate || '');
        $('#manageResCheckOut').val(r.checkOutDate || '');
        $('#manageResNotes').val(r.notes || '');
        $('#manageResTitle').text('Manage Reservation \u2014 ' + (r.guestName || '') + ' / Room ' + (r.roomNumber || ''));
        $('#btnManageCancelRes').toggle(r.status !== 'cancelled' && r.status !== 'checked_out');
        refreshManageResRooms(); // loads rooms available for the reservation's dates
        $('#manageResModalOverlay').addClass('open');
    }

    // Re-fetches the room dropdown for the Manage modal based on current date inputs.
    function refreshManageResRooms() {
        const checkIn  = $('#manageResCheckIn').val();
        const checkOut = $('#manageResCheckOut').val();
        if (!checkIn || !checkOut) return;
        const prevRoomId = parseInt($('#manageResRoom').val()) || _manageResCurrentRoomId;
        $.getJSON(CTX + '/api/room?checkIn=' + checkIn + '&checkOut=' + checkOut + '&excludeRes=' + _manageResCurrentId, function(rooms) {
            const $sel = $('#manageResRoom').empty();
            $.each(rooms || [], function(i, rm) {
                const isCurrent = rm.id === _manageResCurrentRoomId;
                const label = 'Room ' + escHtml(rm.roomNumber) + ' (' + escHtml(rm.type) + ')'
                    + ' \u2014 $' + parseFloat(rm.pricePerNight).toFixed(2) + '/night'
                    + (isCurrent ? ' [current]' : '');
                const $opt = $('<option>').val(rm.id).text(label).attr('data-price', rm.pricePerNight);
                if (rm.id === prevRoomId) $opt.prop('selected', true);
                $sel.append($opt);
            });
            recalcManageTotalPrice();
        });
    }

    function recalcManageTotalPrice() {
        const price = parseFloat($('#manageResRoom option:selected').data('price')) || 0;
        const checkIn  = $('#manageResCheckIn').val();
        const checkOut = $('#manageResCheckOut').val();
        if (price > 0 && checkIn && checkOut) {
            const nights = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
            $('#manageResTotalPrice').val((price * nights).toFixed(2));
        }
    }

    function closeManageResModal() { $('#manageResModalOverlay').removeClass('open'); }

    // Quick Check In / Check Out / Cancel — changes only the status field
    function quickStatusChange(id, newStatus) {
        if (!id) return;
        const r = _allReservations.find(function(x){ return x.id == id; });
        if (!r) { showToast('Reservation not found.'); return; }
        const labels = { checked_in: 'Check In', checked_out: 'Check Out', cancelled: 'Cancel Reservation' };
        const label  = labels[newStatus] || newStatus;
        const msg    = newStatus === 'cancelled'
            ? 'Cancel reservation for ' + (r.guestName || 'Guest') + '? This cannot be undone.'
            : 'Mark reservation for ' + (r.guestName || 'Guest') + ' as ' + label + '?';
        if (!confirm(msg)) return;
        $.ajax({
            url: CTX + '/api/reservation', type: 'PUT',
            data: {
                id:          r.id,
                roomId:      r.roomId,
                checkInDate:  r.checkInDate,
                checkOutDate: r.checkOutDate,
                totalPrice:  r.totalPrice,
                status:      newStatus,
                notes:       r.notes || ''
            },
            success: function(res) {
                if (res.success) {
                    const toastMsg = newStatus === 'cancelled' ? 'Reservation cancelled.' : label + ' successful.';
                    showToast(toastMsg);
                    closeManageResModal();
                    loadReservations();
                } else {
                    showToast(res.message || 'Update failed.');
                }
            },
            error: function() { showToast('Server error.'); }
        });
    }

    /* ===== REPORTS ===== */
    let _rptFiltered = [];

    function loadReport() {
        // Default filter: current year
        const now = new Date();
        const y = now.getFullYear();
        if (!$('#rptFrom').val()) $('#rptFrom').val(y + '-01-01');
        if (!$('#rptTo').val())   $('#rptTo').val(y + '-12-31');
        applyReportFilter();
    }

    function applyReportFilter() {
        const from   = $('#rptFrom').val();
        const to     = $('#rptTo').val();
        const status = $('#rptStatus').val();
        const search = $('#rptSearch').val();

        // Reload reservations from server if not yet loaded
        if (_allReservations.length === 0) {
            $.getJSON(CTX + '/api/reservations', function(data) {
                _allReservations = data || [];
                _buildReport(from, to, status, search);
            });
        } else {
            _buildReport(from, to, status, search);
        }
    }

    function _buildReport(from, to, status, search) {
        let list = _allReservations.slice();

        // Date range filter (by checkInDate)
        if (from) list = list.filter(function(r){ return r.checkInDate >= from; });
        if (to)   list = list.filter(function(r){ return r.checkInDate <= to;   });
        if (status && status !== 'all') list = list.filter(function(r){ return r.status === status; });

        // Guest search: name, id, phone, email
        if (search && search.trim() !== '') {
            const q = search.trim().toLowerCase().replace(/^#/, '');
            list = list.filter(function(r) {
                return (r.guestName  || '').toLowerCase().indexOf(q) >= 0
                    || String(r.guestId || '').indexOf(q) >= 0
                    || String(r.id    || '').indexOf(q) >= 0
                    || (r.guestPhone  || '').toLowerCase().indexOf(q) >= 0
                    || (r.guestEmail  || '').toLowerCase().indexOf(q) >= 0;
            });
        }

        _rptFiltered = list;

        // --- KPI Cards ---
        const total    = list.length;
        const revenue  = list.reduce(function(s,r){ return s + (parseFloat(r.totalPrice)||0); }, 0);
        const cancelled = list.filter(function(r){ return r.status === 'cancelled'; }).length;
        const cancelRate = total > 0 ? Math.round(cancelled / total * 100) : 0;
        const totalNights = list.reduce(function(s,r){
            if (!r.checkInDate || !r.checkOutDate) return s;
            return s + Math.max(1, Math.round((new Date(r.checkOutDate) - new Date(r.checkInDate)) / 86400000));
        }, 0);
        const avgNights = total > 0 ? (totalNights / total).toFixed(1) : '0';

        $('#rptTotal').text(total);
        $('#rptTotalSub').text('from ' + (from||'all') + ' to ' + (to||'all'));
        $('#rptRevenue').text('$' + revenue.toLocaleString('en-US', {minimumFractionDigits:2, maximumFractionDigits:2}));
        $('#rptAvgNights').text(avgNights);
        $('#rptCancelRate').text(cancelRate + '%');

        // --- Monthly Bar Chart (last 12 months within filter) ---
        const monthCounts = {};
        const today = new Date();
        const months = [];
        for (let i = 11; i >= 0; i--) {
            const d = new Date(today.getFullYear(), today.getMonth() - i, 1);
            const key = d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0');
            const lbl = d.toLocaleDateString('en-US',{month:'short', year:'2-digit'});
            months.push({ key: key, lbl: lbl });
            monthCounts[key] = 0;
        }
        list.forEach(function(r) {
            if (!r.checkInDate) return;
            const mk = r.checkInDate.substring(0,7);
            if (monthCounts.hasOwnProperty(mk)) monthCounts[mk]++;
        });
        const maxVal = Math.max(1, Math.max.apply(null, months.map(function(m){ return monthCounts[m.key]; })));
        const peakMonth = months.reduce(function(best,m){ return monthCounts[m.key] > monthCounts[best.key] ? m : best; }, months[0]);

        const $grid = $('#rptBarGrid').empty();
        months.forEach(function(m) {
            const cnt = monthCounts[m.key];
            const pct = Math.round(cnt / maxVal * 100);
            const barH = Math.max(4, Math.round(pct * 1.1)) + 'px';
            $grid.append(
                '<div class="rpt-bar-col">' +
                  '<div class="rpt-bar-val">' + (cnt > 0 ? cnt : '') + '</div>' +
                  '<div class="rpt-bar" style="height:' + barH + ';opacity:' + (0.4 + pct/100*0.6).toFixed(2) + '"></div>' +
                  '<div class="rpt-bar-lbl">' + m.lbl + '</div>' +
                '</div>'
            );
        });
        $('#rptChartPeak').text(peakMonth && monthCounts[peakMonth.key] > 0
            ? 'Peak: ' + peakMonth.lbl + ' (' + monthCounts[peakMonth.key] + ' reservations)' : '');

        // --- History Table ---
        const STATUS_LABELS = {
            confirmed:   '<span class="chip" style="background:#dbeafe;color:#1d4ed8;">Confirmed</span>',
            pending:     '<span class="chip" style="background:#fef3c7;color:#92400e;">Pending</span>',
            checked_in:  '<span class="chip" style="background:#dcfce7;color:#15803d;">Checked In</span>',
            checked_out: '<span class="chip" style="background:#e0e7ff;color:#3730a3;">Checked Out</span>',
            cancelled:   '<span class="chip" style="background:#fee2e2;color:#b91c1c;">Cancelled</span>'
        };

        const $tbody = $('#rptHistoryBody').empty();
        $('#rptHistoryCount').text(list.length + ' record' + (list.length===1?'':'s'));
        if (list.length === 0) {
            $tbody.html('<tr><td colspan="12" style="text-align:center;padding:28px;color:#94a3b8;">No records found for this filter.</td></tr>');
            return;
        }
        list.forEach(function(r) {
            const nights = (r.checkInDate && r.checkOutDate)
                ? Math.max(1, Math.round((new Date(r.checkOutDate) - new Date(r.checkInDate)) / 86400000)) : '-';
            const total  = parseFloat(r.totalPrice||0);
            const statusHtml = STATUS_LABELS[r.status] ||
                '<span class="chip" style="background:#f1f5f9;color:#64748b;">' + (r.status||'-') + '</span>';
            $tbody.append(
                '<tr>' +
                  '<td style="color:var(--muted);font-size:12px;">#' + r.id + '</td>' +
                  '<td>' + (r.guestName||'-') + '</td>' +
                  '<td style="color:var(--muted);font-size:12px;">#' + (r.guestId||'-') + '</td>' +
                  '<td style="font-size:12.5px;">' + (r.guestPhone||'—') + '</td>' +
                  '<td style="font-size:12px;color:var(--muted);">' + (r.guestEmail||'—') + '</td>' +
                  '<td>' + (r.roomNumber ? 'Room '+r.roomNumber : '-') + '</td>' +
                  '<td>' + (r.checkInDate||'-') + '</td>' +
                  '<td>' + (r.checkOutDate||'-') + '</td>' +
                  '<td style="text-align:center;">' + nights + '</td>' +
                  '<td style="font-weight:600;">$' + total.toFixed(2) + '</td>' +
                  '<td>' + statusHtml + '</td>' +
                  '<td style="color:var(--muted);font-size:12px;">' + (r.notes||'') + '</td>' +
                '</tr>'
            );
        });
    }

    function printReport() {
        const prev = document.title;
        document.title = 'OceanView Resort - Report';
        document.body.classList.add('print-report');
        window.print();
        document.body.classList.remove('print-report');
        document.title = prev;
    }

    function printBill(id) {
        const r = _allReservations.find(function(x){ return x.id === id; });
        if (!r) { showToast('Reservation not found.'); return; }
        const checkIn  = r.checkInDate  || '';
        const checkOut = r.checkOutDate || '';
        let nights = 1;
        if (checkIn && checkOut) {
            nights = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
        }
        const rate  = nights > 0 ? (parseFloat(r.totalPrice || 0) / nights) : 0;
        const total = parseFloat(r.totalPrice || 0);
        $('#billResId').text(r.id);
        $('#billGuest').text(r.guestName || '-');
        $('#billRoom').text(r.roomNumber ? 'Room ' + r.roomNumber : '-');
        $('#billCheckIn').text(checkIn);
        $('#billCheckOut').text(checkOut);
        $('#billNights').text(nights);
        $('#billRate').text('$' + rate.toFixed(2));
        $('#billTotal').text('$' + total.toFixed(2));
        $('#billDate').text('Issued: ' + new Date().toLocaleDateString('en-US',{year:'numeric',month:'long',day:'numeric'}));
        if (r.notes) { $('#billNotes').text(r.notes); $('#billNotesWrap').show(); }
        else          { $('#billNotesWrap').hide(); }
        $('#billOverlay').addClass('open');
    }

    function saveReservationChanges() {
        const id       = $('#manageResId').val();
        const roomId   = $('#manageResRoom').val();
        const checkIn  = $('#manageResCheckIn').val();
        const checkOut = $('#manageResCheckOut').val();
        const status   = $('#manageResStatus').val();
        const notes    = $('#manageResNotes').val().trim();
        if (!roomId)   { showToast('Please select a room.');        return; }
        if (!checkIn)  { showToast('Check-in date is required.');   return; }
        if (!checkOut) { showToast('Check-out date is required.');  return; }
        if (new Date(checkOut) <= new Date(checkIn)) { showToast('Check-out must be after check-in.'); return; }
        const price = parseFloat($('#manageResRoom option:selected').data('price')) || 0;
        const nights = Math.max(1, Math.round((new Date(checkOut) - new Date(checkIn)) / 86400000));
        const totalPrice = (price * nights).toFixed(2);
        $.ajax({
            url: CTX + '/api/reservation', type: 'PUT',
            data: { id, roomId, checkInDate: checkIn, checkOutDate: checkOut, totalPrice, status, notes },
            success: function(res) {
                if (res.success) {
                    showToast(res.message || 'Reservation updated.');
                    closeManageResModal();
                    loadReservations();
                } else {
                    showToast(res.message || 'Update failed.');
                }
            },
            error: function() { showToast('Server error.'); }
        });
    }

    function deleteReservationFromModal() {
        const id = $('#manageResId').val();
        if (!id) return;
        if (!confirm('Delete this reservation? This cannot be undone.')) return;
        $.ajax({
            url: CTX + '/api/reservation', type: 'DELETE',
            data: { id },
            success: function(res) {
                if (res.success) {
                    showToast(res.message || 'Reservation deleted.');
                    closeManageResModal();
                    loadReservations();
                } else {
                    showToast(res.message || 'Delete failed.');
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