package com.example.servletstudy2.model;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {
    private int id;
    private String bookname;
    private int price;

    public Book(Book other){
        this.id = other.id;
        this.bookname = other.bookname;
        this.price = other.price;
    }
}
