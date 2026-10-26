package com.example.servletstudy2.controller;

import com.example.servletstudy2.exception.DuplicatedException;
import com.example.servletstudy2.model.User;
import com.example.servletstudy2.service.UserService;
import tools.jackson.databind.ObjectMapper;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@WebServlet("/api/users")
public class UserApiController extends HttpServlet {
    private UserService userService;

    @Override
    public void init(ServletConfig config) throws ServletException {
        userService = UserService.getInstance();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, RuntimeException, IOException {
        req.setCharacterEncoding("UTF-8"); //이건 요청들어올때 한글인코딩 저번에는 보낼때 인코딩
        ObjectMapper objectMapper = new ObjectMapper(); //ObjectMapper 자바에서 제이슨 해석해주는애
        User user = objectMapper.readValue(req.getInputStream(), User.class);// 값을 바로 유저클래스로 형변환해서 주입
        System.out.println("사용자 등록 요청 들어옴");
        System.out.println(user);
        try {
            userService.register(user);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.setStatus(200);        //디폴트값이라 지워도 상관없다
            resp.getWriter().println(objectMapper.writeValueAsString(Map.of(
                    "message", "사용자 등록 성공"
            )));
        } catch (DuplicatedException e){
            resp.setContentType("application/json"); //응답을 제이슨으로 해줘라
            resp.setCharacterEncoding("UTF-8");
            resp.setStatus(400);
            resp.getWriter().println(objectMapper.writeValueAsString(Map.of(
                    "message", e.getMessage()
            )));
            return;
        }

    }
}
