package com.example.servletstudy2.model;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {
    private int id;
    private String bookName;
    private int price;

    public Book(Book other){
        this.id = other.id;
        this.bookName = other.bookName;
        this.price = other.price;
    }
}
