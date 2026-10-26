package com.example.servletstudy2.controller;

import com.example.servletstudy2.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/users")
public class UserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = new User(1, "user1", "1234","김준일");
        req.setAttribute("user", user);     //키,벨류 (map)    리퀘스트라는 객체에 속성추가
        req.setAttribute("id", user.getId());
        req.setAttribute("username", user.getUsername());
        req.setAttribute("password", user.getPassword());
        req.setAttribute("name", user.getName());
        //데이터관리를 하는곳
        req.getRequestDispatcher("/user2.jsp").forward(req, resp);
        //해당 JSP가 열리곘금 넘겨준다 그리고 user2.jsp가 받아서 해준다
    }
}
