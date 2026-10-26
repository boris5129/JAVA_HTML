package com.example.servletstudy2.controller;

import com.example.servletstudy2.model.Book;
import com.example.servletstudy2.service.BookService;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/book/list")
public class BookListController extends HttpServlet {

    private BookService bookService;

    @Override
    public void init(ServletConfig config) throws ServletException {
        bookService = BookService.getInstance();
        bookService.register(new Book(0, "자바책",0));
        bookService.register(new Book(0, "자바스프린트책",0));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("booklist", bookService.getBookAll());
        req.getRequestDispatcher("/WEB-INF/views/book-list.jsp").forward(req, resp);
    }
}
