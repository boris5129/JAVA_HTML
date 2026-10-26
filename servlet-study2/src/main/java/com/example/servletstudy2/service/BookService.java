package com.example.servletstudy2.service;

import com.example.servletstudy2.exception.DuplicatedException;
import com.example.servletstudy2.model.Book;
import com.example.servletstudy2.repository.BookRepository;

import java.util.List;

public class BookService {
    private static BookService instance;
    private BookRepository bookRepository;

    private BookService(BookRepository bookRepository){
        this.bookRepository = bookRepository;
    }

    public static BookService getInstance(){
        if(instance == null){
            instance = new BookService(BookRepository.getInstance());
        }return instance;
    }

    public void register(Book book) throws RuntimeException{
        if(isDuplicatedUsername(book.getBookName())){
            throw new DuplicatedException("이미 존재하는 책이름 입니다.");
        }
    }

    public boolean isDuplicatedUsername(String bookname){
        return bookRepository.findByBookname(bookname) != null;
    }

    public List<Book> getBookAll(){

        return bookRepository.findAll();
    }



}
