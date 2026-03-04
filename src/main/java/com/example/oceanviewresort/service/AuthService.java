package com.example.oceanviewresort.service;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.util.Optional;

/**
 * Authentication service — handles login validation and password hashing.
 */
public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    /** Package-private constructor for unit testing — allows injecting a mock UserDAO. */
    AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Validates the supplied plain-text password against the stored BCrypt hash.
     *
     * @param username  plain-text username
     * @param plainPass plain-text password entered by the user
     * @return the matching User if credentials are valid and account is active,
     *         otherwise Optional.empty()
     */
    public Optional<User> authenticate(String username, String plainPass) {
        if (username == null || username.isBlank() || plainPass == null || plainPass.isBlank()) {
            return Optional.empty();
        }

        Optional<User> userOpt = userDAO.findByUsername(username.trim());

        if (userOpt.isEmpty()) {
            return Optional.empty();
        }

        User user = userOpt.get();

        if (!user.isActive()) {
            return Optional.empty();
        }

        // BCrypt password check
        if (!BCrypt.checkpw(plainPass, user.getPassword())) {
            return Optional.empty();
        }

        return Optional.of(user);
    }

    /**
     * Hashes a plain-text password using BCrypt (cost factor 12).
     */
    public String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    /**
     * Creates the initial admin user if no users exist in the database.
     */
    public void createDefaultAdminIfNeeded() {
        if (!userDAO.hasAnyUser()) {
            String hashed = hashPassword("admin123");
            User admin = new User("admin", hashed, "System Administrator", "admin@oceanviewresort.com", "ADMIN");
            boolean created = userDAO.createUser(admin);
            if (created) {
                System.out.println("[AuthService] Default admin user created successfully.");
            } else {
                System.err.println("[AuthService] Failed to create default admin user.");
            }
        }
    }
}
