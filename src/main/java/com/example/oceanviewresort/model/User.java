package com.example.oceanviewresort.model;

import java.time.LocalDateTime;

public class User {

    private int id;
    private String username;
    private String password;   // BCrypt hash
    private String fullName;
    private String email;
    private String role;
    private boolean active;
    private LocalDateTime createdAt;

    public User() {}

    public User(String username, String password, String fullName, String email, String role) {
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email    = email;
        this.role     = role;
        this.active   = true;
    }

    // ---- Getters ----
    public int getId()                  { return id; }
    public String getUsername()         { return username; }
    public String getPassword()         { return password; }
    public String getFullName()         { return fullName; }
    public String getEmail()            { return email; }
    public String getRole()             { return role; }
    public boolean isActive()           { return active; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    // ---- Setters ----
    public void setId(int id)                          { this.id = id; }
    public void setUsername(String username)           { this.username = username; }
    public void setPassword(String password)           { this.password = password; }
    public void setFullName(String fullName)           { this.fullName = fullName; }
    public void setEmail(String email)                 { this.email = email; }
    public void setRole(String role)                   { this.role = role; }
    public void setActive(boolean active)              { this.active = active; }
    public void setCreatedAt(LocalDateTime createdAt)  { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', role='" + role + "'}";
    }
}
