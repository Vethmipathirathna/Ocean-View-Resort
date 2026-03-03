<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // If already logged in, go straight to dashboard
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
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #0a2e4a 0%, #0d5c8a 40%, #1e90c8 70%, #64c8f0 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        /* Animated wave background */
        body::before {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 200%;
            height: 220px;
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 220'%3E%3Cpath fill='%23ffffff10' d='M0,128L60,122.7C120,117,240,107,360,117.3C480,128,600,160,720,160C840,160,960,128,1080,112C1200,96,1320,96,1380,96L1440,96L1440,220L1380,220C1320,220,1200,220,1080,220C960,220,840,220,720,220C600,220,480,220,360,220C240,220,120,220,60,220L0,220Z'/%3E%3C/svg%3E") repeat-x;
            animation: wave 8s linear infinite;
        }

        body::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 200%;
            height: 180px;
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 180'%3E%3Cpath fill='%23ffffff18' d='M0,96L80,85.3C160,75,320,53,480,58.7C640,64,800,96,960,101.3C1120,107,1280,85,1360,74.7L1440,64L1440,180L1360,180C1280,180,1120,180,960,180C800,180,640,180,480,180C320,180,160,180,80,180L0,180Z'/%3E%3C/svg%3E") repeat-x;
            animation: wave 12s linear infinite reverse;
        }

        @keyframes wave {
            0%   { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }

        /* Card container */
        .login-wrapper {
            display: flex;
            width: 900px;
            max-width: 95vw;
            min-height: 520px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 30px 80px rgba(0, 0, 0, 0.4);
            position: relative;
            z-index: 10;
        }

        /* Left branding panel */
        .brand-panel {
            flex: 1;
            background: linear-gradient(170deg, #004a7c 0%, #006aad 60%, #0089d6 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 50px 35px;
            position: relative;
            overflow: hidden;
        }

        .brand-panel::before {
            content: '';
            position: absolute;
            top: -60px;
            right: -60px;
            width: 220px;
            height: 220px;
            border-radius: 50%;
            background: rgba(255,255,255,0.06);
        }

        .brand-panel::after {
            content: '';
            position: absolute;
            bottom: -80px;
            left: -50px;
            width: 280px;
            height: 280px;
            border-radius: 50%;
            background: rgba(255,255,255,0.05);
        }

        .brand-logo {
            width: 90px;
            height: 90px;
            background: rgba(255, 255, 255, 0.15);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 28px;
            border: 2px solid rgba(255,255,255,0.3);
        }

        .brand-logo svg {
            width: 50px;
            height: 50px;
        }

        .brand-name {
            color: #ffffff;
            font-size: 28px;
            font-weight: 700;
            letter-spacing: 1px;
            text-align: center;
            line-height: 1.2;
            margin-bottom: 12px;
        }

        .brand-tagline {
            color: rgba(255, 255, 255, 0.75);
            font-size: 13px;
            text-align: center;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 40px;
        }

        .brand-divider {
            width: 50px;
            height: 2px;
            background: rgba(255,255,255,0.35);
            border-radius: 2px;
            margin-bottom: 30px;
        }

        .brand-features {
            list-style: none;
            width: 100%;
        }

        .brand-features li {
            color: rgba(255,255,255,0.8);
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 14px;
        }

        .brand-features li span.dot {
            width: 7px;
            height: 7px;
            background: #64c8f0;
            border-radius: 50%;
            flex-shrink: 0;
        }

        /* Right login form panel */
        .form-panel {
            flex: 1;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 55px 50px;
        }

        .form-title {
            font-size: 26px;
            font-weight: 700;
            color: #0a2e4a;
            margin-bottom: 6px;
        }

        .form-subtitle {
            font-size: 14px;
            color: #7a9ab5;
            margin-bottom: 38px;
        }

        .form-group {
            margin-bottom: 22px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #344a5f;
            margin-bottom: 8px;
            letter-spacing: 0.4px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #7a9ab5;
            pointer-events: none;
        }

        .form-group input {
            width: 100%;
            padding: 13px 14px 13px 42px;
            border: 1.8px solid #d0dde8;
            border-radius: 10px;
            font-size: 14px;
            color: #1a2f42;
            background: #f7fafc;
            transition: border-color 0.25s, box-shadow 0.25s, background 0.25s;
            outline: none;
        }

        .form-group input:focus {
            border-color: #0089d6;
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(0, 137, 214, 0.12);
        }

        .form-group input::placeholder {
            color: #aabccc;
        }

        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
            margin-top: -6px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
        }

        .remember-me input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: #0089d6;
            cursor: pointer;
        }

        .remember-me span {
            font-size: 13px;
            color: #5a7a93;
        }

        .forgot-link {
            font-size: 13px;
            color: #0089d6;
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-link:hover {
            text-decoration: underline;
            color: #006aad;
        }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #006aad, #0089d6);
            color: #ffffff;
            font-size: 15px;
            font-weight: 600;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            letter-spacing: 0.5px;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 6px 20px rgba(0, 137, 214, 0.35);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 28px rgba(0, 137, 214, 0.45);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .register-link {
            text-align: center;
            margin-top: 24px;
            font-size: 13px;
            color: #7a9ab5;
        }

        .register-link a {
            color: #0089d6;
            font-weight: 600;
            text-decoration: none;
        }

        .register-link a:hover {
            text-decoration: underline;
        }

        /* Error / Success Alert */
        .alert {
            padding: 11px 16px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 20px;
            display: none;
        }
        .alert-error {
            background: #fef0f0;
            color: #c0392b;
            border: 1.5px solid #f5c6c6;
        }
        .alert-success {
            background: #eafaf1;
            color: #1e8449;
            border: 1.5px solid #a9dfbf;
        }

        /* Spinner on button */
        .btn-login.loading {
            opacity: 0.75;
            cursor: not-allowed;
        }

        /* Responsive */
        @media (max-width: 650px) {
            .brand-panel {
                display: none;
            }
            .form-panel {
                padding: 40px 30px;
            }
            .login-wrapper {
                border-radius: 16px;
            }
        }
    </style>
</head>
<body>

<div class="login-wrapper">

    <!-- Left Branding Panel -->
    <div class="brand-panel">
        <div class="brand-logo">
            <!-- Wave / ocean icon -->
            <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8 40 C14 32, 22 48, 32 40 C42 32, 50 48, 56 40" stroke="white" stroke-width="3.5" stroke-linecap="round" fill="none"/>
                <path d="M8 50 C14 42, 22 58, 32 50 C42 42, 50 58, 56 50" stroke="rgba(255,255,255,0.55)" stroke-width="2.5" stroke-linecap="round" fill="none"/>
                <path d="M22 30 L32 10 L42 30" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                <circle cx="32" cy="10" r="3" fill="white"/>
            </svg>
        </div>

        <div class="brand-name">OceanView<br>Resort</div>
        <div class="brand-tagline">Where the ocean meets luxury</div>
        <div class="brand-divider"></div>

        <ul class="brand-features">
            <li><span class="dot"></span> Manage reservations & bookings</li>
            <li><span class="dot"></span> Guest check-in &amp; check-out</li>
            <li><span class="dot"></span> Room availability &amp; pricing</li>
            <li><span class="dot"></span> Staff &amp; service management</li>
        </ul>
    </div>

    <!-- Right Form Panel -->
    <div class="form-panel">
        <div class="form-title">Welcome Back</div>
        <div class="form-subtitle">Sign in to your resort management account</div>

        <form id="loginForm">

            <!-- Alert box for error/success messages -->
            <div id="alertBox" class="alert"></div>

            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrapper">
                    <span class="input-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </span>
                    <input type="text" id="username" name="username" placeholder="Enter your username" required />
                </div>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <span class="input-icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </span>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required />
                </div>
            </div>

            <div class="form-options">
                <label class="remember-me">
                    <input type="checkbox" name="remember" />
                    <span>Remember me</span>
                </label>
                <a href="#" class="forgot-link">Forgot password?</a>
            </div>

            <button type="submit" id="btnLogin" class="btn-login">Sign In</button>

        </form>

        <div class="register-link">
            Don't have an account? <a href="#">Contact Administrator</a>
        </div>
    </div>

</div>

<!-- jQuery CDN -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
    $(document).ready(function () {

        $('#loginForm').on('submit', function (e) {
            e.preventDefault();

            const username = $.trim($('#username').val());
            const password = $('#password').val();

            // Basic client-side validation
            if (!username || !password) {
                showAlert('error', 'Please enter both username and password.');
                return;
            }

            // Disable button and show loading state
            const $btn = $('#btnLogin');
            $btn.addClass('loading').prop('disabled', true).text('Signing in...');
            hideAlert();

            $.ajax({
                url:  '${pageContext.request.contextPath}/api/login',
                type: 'POST',
                data: {
                    username: username,
                    password: password
                },
                dataType: 'json',
                success: function (res) {
                    if (res.success) {
                        showAlert('success', res.message);
                        // Short delay so user sees the success message, then redirect
                        setTimeout(function () {
                            window.location.href = res.redirect;
                        }, 600);
                    } else {
                        showAlert('error', res.message);
                        resetButton($btn);
                    }
                },
                error: function (xhr) {
                    let msg = 'Invalid username or password. Please try again.';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        msg = xhr.responseJSON.message;
                    }
                    showAlert('error', msg);
                    resetButton($btn);
                }
            });
        });

        function showAlert(type, message) {
            const $box = $('#alertBox');
            $box.removeClass('alert-error alert-success')
                .addClass(type === 'error' ? 'alert-error' : 'alert-success')
                .text(message)
                .show();
        }

        function hideAlert() {
            $('#alertBox').hide();
        }

        function resetButton($btn) {
            $btn.removeClass('loading').prop('disabled', false).text('Sign In');
        }
    });
</script>

</body>
</html>
