package com.example.servletstudy2.controller;

import com.example.servletstudy2.exception.DuplicatedException;
import com.example.servletstudy2.model.Book;
import com.example.servletstudy2.service.BookService;
import tools.jackson.databind.ObjectMapper;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.Objects;

@WebServlet("/api/book")
public class BookApiController extends HttpServlet {
    private BookService bookService;

    @Override
    public void init(ServletConfig config) throws ServletException {
        bookService = BookService.getInstance();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UFT-8");
        ObjectMapper objectMapper = new ObjectMapper();
        Book book = objectMapper.readValue(req.getInputStream(), Book.class);
        System.out.println("책 확인 요청 들어옴");
        System.out.println(book);
        try{
            bookService.register(book);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.setStatus(200);
            resp.getWriter().println(objectMapper.writeValueAsString(Map.of("message", "책 등록 성공"
            )));
        }catch (DuplicatedException e){
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.setStatus(400);
            resp.getWriter().println(objectMapper.writeValueAsString(Map.of("message", e.getMessage()
            )));    //왜 여기는 e.getmessage인지 확인
        }return;
    }
}
