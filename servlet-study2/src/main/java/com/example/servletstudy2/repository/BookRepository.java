package com.example.servletstudy2.repository;

import com.example.servletstudy2.model.Book;

import java.util.ArrayList;
import java.util.List;

public class BookRepository {
    private static BookRepository instance;
    private int lastId;
    private List<Book> books;

    private BookRepository(){
        lastId = 1;
        books = new ArrayList<>();
    }

    public static BookRepository getInstance(){
        if(instance == null) {
            instance = new BookRepository();
        }return instance;
    }

    public void insert(Book book){
        book.setId(lastId++);
        books.add(book);
    }

    public Book findByBookname(String bookname){
        for (Book book : books){
            if(book.getBookName().equalsIgnoreCase(bookname)){
                return book;
            }
        }return null;
    }

    public List<Book> findAll(){
        return books.stream().map(book -> new Book(book)).toList();
    }

}
