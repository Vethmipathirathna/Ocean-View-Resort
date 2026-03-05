<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("loggedInUser") != null) {
        response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OceanView Resort – Login</title>
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            min-height: 100vh;
            background: linear-gradient(160deg, #062d5f 0%, #0a4d8c 45%, #1178c8 80%, #3ab0e8 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        /* ── Animated wave at bottom ── */
        .wave-bg {
            position: fixed; bottom: 0; left: 0;
            width: 200%; height: 160px;
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 160'%3E%3Cpath fill='rgba(255,255,255,0.08)' d='M0,80 C180,140 360,20 540,80 C720,140 900,20 1080,80 C1260,140 1440,40 1440,80 L1440,160 L0,160Z'/%3E%3C/svg%3E") repeat-x;
            animation: waveSlide 10s linear infinite;
            pointer-events: none; z-index: 0;
        }
        .wave-bg.w2 {
            height: 120px; bottom: 0;
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 120'%3E%3Cpath fill='rgba(255,255,255,0.05)' d='M0,60 C240,110 480,10 720,60 C960,110 1200,10 1440,60 L1440,120 L0,120Z'/%3E%3C/svg%3E") repeat-x;
            animation: waveSlide 15s linear infinite reverse;
        }
        @keyframes waveSlide {
            from { transform: translateX(0); }
            to   { transform: translateX(-50%); }
        }

        /* ── Floating bubbles ── */
        .bubbles { position: fixed; inset: 0; pointer-events: none; z-index: 0; }
        .bubble {
            position: absolute; bottom: -120px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.15);
            animation: floatUp linear infinite;
        }
        .bubble:nth-child(1)  { width:20px;  height:20px;  left:8%;   animation-duration:9s;  animation-delay:0s;   }
        .bubble:nth-child(2)  { width:35px;  height:35px;  left:18%;  animation-duration:13s; animation-delay:2s;   }
        .bubble:nth-child(3)  { width:14px;  height:14px;  left:30%;  animation-duration:8s;  animation-delay:4s;   }
        .bubble:nth-child(4)  { width:50px;  height:50px;  left:42%;  animation-duration:16s; animation-delay:1s;   }
        .bubble:nth-child(5)  { width:22px;  height:22px;  left:55%;  animation-duration:10s; animation-delay:3s;   }
        .bubble:nth-child(6)  { width:40px;  height:40px;  left:65%;  animation-duration:14s; animation-delay:0.5s; }
        .bubble:nth-child(7)  { width:16px;  height:16px;  left:74%;  animation-duration:7s;  animation-delay:5s;   }
        .bubble:nth-child(8)  { width:28px;  height:28px;  left:83%;  animation-duration:11s; animation-delay:2.5s; }
        .bubble:nth-child(9)  { width:12px;  height:12px;  left:92%;  animation-duration:9s;  animation-delay:6s;   }
        .bubble:nth-child(10) { width:44px;  height:44px;  left:3%;   animation-duration:18s; animation-delay:1.5s; }
        @keyframes floatUp {
            0%   { transform: translateY(0)   scale(1);   opacity: 0;   }
            10%  { opacity: 1; }
            90%  { opacity: 0.6; }
            100% { transform: translateY(-110vh) scale(1.1); opacity: 0; }
        }

        /* ── Glowing orbs ── */
        .orb {
            position: fixed; border-radius: 50%; filter: blur(80px);
            pointer-events: none; z-index: 0; animation: orbPulse ease-in-out infinite alternate;
        }
        .orb1 { width:340px; height:340px; top:-80px;  left:-80px;  background:rgba(17,120,200,0.35); animation-duration:7s; }
        .orb2 { width:280px; height:280px; bottom:-60px; right:-60px; background:rgba(26,158,224,0.3); animation-duration:9s; }
        @keyframes orbPulse {
            from { transform: scale(1);   opacity: 0.7; }
            to   { transform: scale(1.15); opacity: 1;   }
        }

        .card {
            position: relative; z-index: 1;
            background: rgba(255,255,255,0.97);
            border-radius: 20px;
            box-shadow: 0 24px 60px rgba(5,30,80,0.45), 0 0 0 1px rgba(255,255,255,0.15);
            padding: 48px 44px 40px;
            width: 100%;
            max-width: 400px;
        }

        .logo {
            text-align: center;
            margin-bottom: 28px;
        }
        .logo-circle {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 64px; height: 64px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0a4d8c, #1a9ee0);
            margin-bottom: 14px;
            box-shadow: 0 6px 18px rgba(10,77,140,0.3);
        }
        .logo h2 {
            font-size: 20px;
            font-weight: 800;
            color: #0a2340;
        }
        .logo p {
            font-size: 13px;
            color: #90afc8;
            margin-top: 3px;
        }

        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #344a60;
            margin-bottom: 7px;
        }
        .input-wrap { position: relative; }
        .input-wrap .ico {
            position: absolute; left: 13px; top: 50%;
            transform: translateY(-50%);
            color: #a0bcd4; pointer-events: none; display: flex;
        }
        .input-wrap input {
            width: 100%;
            padding: 12px 40px 12px 40px;
            border: 1.8px solid #d0e0ee;
            border-radius: 10px;
            font-size: 14px;
            color: #1a2f42;
            background: #f7fafd;
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }
        .input-wrap input:focus {
            border-color: #1178c8;
            background: #fff;
            box-shadow: 0 0 0 3px rgba(17,120,200,0.11);
        }
        .input-wrap input::placeholder { color: #b8cfe0; }
        .eye-btn {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #a0bcd4; display: flex; padding: 3px;
        }
        .eye-btn:hover { color: #1178c8; }

        .check-row {
            display: flex; align-items: center; gap: 8px;
            margin-bottom: 24px;
        }
        .check-row input { accent-color: #1178c8; cursor: pointer; }
        .check-row label { font-size: 13px; color: #6b8aaa; cursor: pointer; }

        .btn-login {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #0a4d8c, #1a9ee0);
            color: #fff;
            font-size: 15px;
            font-weight: 700;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            box-shadow: 0 6px 20px rgba(10,77,140,0.32);
            transition: transform .18s, box-shadow .18s;
        }
        .btn-login:hover { transform: translateY(-2px); box-shadow: 0 10px 26px rgba(10,77,140,0.4); }
        .btn-login:active { transform: translateY(0); }
        .btn-login.loading { opacity: .75; cursor: not-allowed; }

        .alert {
            padding: 10px 14px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 16px;
            display: none;
        }
        .alert-error   { background: #fff0f0; color: #c0392b; border: 1.5px solid #f5c6c6; }
        .alert-success { background: #eafaf1; color: #1e8449; border: 1.5px solid #a9dfbf; }

        .footer-note {
            text-align: center;
            margin-top: 22px;
            font-size: 12px;
            color: #a0bcd4;
        }
    </style>
</head>
<body>

<!-- background layers -->
<div class="orb orb1"></div>
<div class="orb orb2"></div>
<div class="bubbles">
    <div class="bubble"></div><div class="bubble"></div><div class="bubble"></div>
    <div class="bubble"></div><div class="bubble"></div><div class="bubble"></div>
    <div class="bubble"></div><div class="bubble"></div><div class="bubble"></div>
    <div class="bubble"></div>
</div>
<div class="wave-bg"></div>
<div class="wave-bg w2"></div>

<div class="card">

    <div class="logo">
        <div class="logo-circle">
            <svg width="30" height="30" viewBox="0 0 64 64" fill="none">
                <path d="M6 36 C14 24,22 48,32 36 C42 24,50 48,58 36" stroke="white" stroke-width="4.5" stroke-linecap="round"/>
                <path d="M6 50 C14 38,22 62,32 50 C42 38,50 62,58 50" stroke="rgba(255,255,255,0.5)" stroke-width="3" stroke-linecap="round"/>
                <path d="M24 28 L32 8 L40 28" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                <circle cx="32" cy="8" r="3.5" fill="white"/>
            </svg>
        </div>
        <h2>OceanView Resort</h2>
        <p>Management System</p>
    </div>

    <form id="loginForm">
        <div id="alertBox" class="alert"></div>

        <div class="form-group">
            <label for="username">Username</label>
            <div class="input-wrap">
                <span class="ico">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
                    </svg>
                </span>
                <input type="text" id="username" name="username" placeholder="Enter username" autocomplete="username" required />
            </div>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <div class="input-wrap">
                <span class="ico">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                </span>
                <input type="password" id="password" name="password" placeholder="Enter password" autocomplete="current-password" required />
                <button type="button" class="eye-btn" id="eyeBtn">
                    <svg id="eyeIcon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                    </svg>
                </button>
            </div>
        </div>

        <div class="check-row">
            <input type="checkbox" id="remember" name="remember" />
            <label for="remember">Remember me</label>
        </div>

        <button type="submit" id="btnLogin" class="btn-login">Sign In</button>
    </form>

    <div class="footer-note">Contact your administrator for account access.</div>
</div>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    $(document).ready(function () {

        $('#eyeBtn').on('click', function () {
            const $pw = $('#password');
            const show = $pw.attr('type') === 'password';
            $pw.attr('type', show ? 'text' : 'password');
            $('#eyeIcon').html(show
                ? '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/>'
                : '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>');
        });

        $('#loginForm').on('submit', function (e) {
            e.preventDefault();

            const username = $.trim($('#username').val());
            const password = $('#password').val();

            if (!username || !password) {
                showAlert('error', 'Please enter both username and password.');
                return;
            }

            const $btn = $('#btnLogin');
            $btn.addClass('loading').prop('disabled', true).text('Signing in...');
            hideAlert();

            $.ajax({
                url:  '${pageContext.request.contextPath}/api/login',
                type: 'POST',
                data: { username, password },
                dataType: 'json',
                success: function (res) {
                    if (res.success) {
                        showAlert('success', res.message);
                        setTimeout(() => window.location.href = res.redirect, 600);
                    } else {
                        showAlert('error', res.message);
                        resetButton($btn);
                    }
                },
                error: function (xhr) {
                    let msg = 'Invalid username or password. Please try again.';
                    if (xhr.responseJSON && xhr.responseJSON.message) msg = xhr.responseJSON.message;
                    showAlert('error', msg);
                    resetButton($btn);
                }
            });
        });

        function showAlert(type, message) {
            $('#alertBox').removeClass('alert-error alert-success')
                .addClass(type === 'error' ? 'alert-error' : 'alert-success')
                .text(message).show();
        }
        function hideAlert() { $('#alertBox').hide(); }
        function resetButton($btn) { $btn.removeClass('loading').prop('disabled', false).text('Sign In'); }
    });
</script>

</body>
</html>