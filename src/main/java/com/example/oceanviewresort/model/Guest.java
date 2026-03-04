package com.example.oceanviewresort.model;

import java.time.LocalDateTime;

/**
 * Model representing a hotel guest.
 */
public class Guest {

    private int    id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String address;
    private String idType;       // Passport | NIC | Driver's License
    private String idNumber;
    private LocalDateTime registeredAt;

    public Guest() {}

    public Guest(String firstName, String lastName, String email,
                 String phone, String address, String idType, String idNumber) {
        this.firstName = firstName;
        this.lastName  = lastName;
        this.email     = email;
        this.phone     = phone;
        this.address   = address;
        this.idType    = idType;
        this.idNumber  = idNumber;
    }

    // ---- Getters ----
    public int    getId()              { return id; }
    public String getFirstName()       { return firstName; }
    public String getLastName()        { return lastName; }
    public String getFullName()        { return firstName + " " + lastName; }
    public String getEmail()           { return email; }
    public String getPhone()           { return phone; }
    public String getAddress()         { return address; }
    public String getIdType()          { return idType; }
    public String getIdNumber()        { return idNumber; }
    public LocalDateTime getRegisteredAt() { return registeredAt; }

    // ---- Setters ----
    public void setId(int id)                          { this.id = id; }
    public void setFirstName(String firstName)         { this.firstName = firstName; }
    public void setLastName(String lastName)           { this.lastName = lastName; }
    public void setEmail(String email)                 { this.email = email; }
    public void setPhone(String phone)                 { this.phone = phone; }
    public void setAddress(String address)             { this.address = address; }
    public void setIdType(String idType)               { this.idType = idType; }
    public void setIdNumber(String idNumber)           { this.idNumber = idNumber; }
    public void setRegisteredAt(LocalDateTime t)       { this.registeredAt = t; }

    @Override
    public String toString() {
        return "Guest{id=" + id + ", name='" + getFullName() + "', email='" + email + "'}";
    }
}
