package com.example.servletstudy2.controller;

import com.example.servletstudy2.model.User;
import com.example.servletstudy2.service.UserService;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/user/list")
public class UserListController extends HttpServlet {

    private UserService userService;    //현재는 nill

    @Override
    public void init(ServletConfig config) throws ServletException {
        userService = UserService.getInstance();
        userService.register(new User(0, "user1", "1234", "김준일"));
        userService.register(new User(0, "user2", "5678", "김준이"));
    }
    //init 생성될때 한번 호출이 일어난다.
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("userList", userService.getUserAll());
        //req에 userList라는 key값으로 List 통으로 넣는다.
        req.getRequestDispatcher("/WEB-INF/views/user-list.jsp").forward(req, resp);
    }
}
