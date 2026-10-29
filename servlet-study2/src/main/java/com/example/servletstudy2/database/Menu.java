package com.example.servletstudy2.database;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Menu {
    private int menuID;
    private int restaurantId;
    private String name;
    private int price;
    private String description;
    private boolean isSignature;
    private boolean osSoldOut;
}
