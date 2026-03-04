package com.example.oceanviewresort.model;

/**
 * Model representing a hotel room.
 */
public class Room {

    private int    id;
    private String roomNumber;   // e.g. "101", "202A"
    private String type;         // Single | Double | Suite | Deluxe
    private double pricePerNight;
    private int    capacity;     // max guests
    private String status;       // available | occupied | maintenance
    private String description;

    public Room() {}

    public Room(String roomNumber, String type, double pricePerNight, int capacity, String status, String description) {
        this.roomNumber    = roomNumber;
        this.type          = type;
        this.pricePerNight = pricePerNight;
        this.capacity      = capacity;
        this.status        = status;
        this.description   = description;
    }

    // ---- Getters ----
    public int    getId()             { return id; }
    public String getRoomNumber()     { return roomNumber; }
    public String getType()           { return type; }
    public double getPricePerNight()  { return pricePerNight; }
    public int    getCapacity()       { return capacity; }
    public String getStatus()         { return status; }
    public String getDescription()    { return description; }

    // ---- Setters ----
    public void setId(int id)                        { this.id = id; }
    public void setRoomNumber(String roomNumber)     { this.roomNumber = roomNumber; }
    public void setType(String type)                 { this.type = type; }
    public void setPricePerNight(double price)       { this.pricePerNight = price; }
    public void setCapacity(int capacity)            { this.capacity = capacity; }
    public void setStatus(String status)             { this.status = status; }
    public void setDescription(String description)   { this.description = description; }

    @Override
    public String toString() {
        return "Room{id=" + id + ", roomNumber='" + roomNumber + "', type='" + type + "', status='" + status + "'}";
    }
}
