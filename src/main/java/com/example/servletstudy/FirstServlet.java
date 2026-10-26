package com.example.servletstudy;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class FirstServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("GET 요청 들어옴");

        resp.setStatus(400);
        resp.setContentType("text/plain");
        resp.setCharacterEncoding(("UTF-8"));       //UTF-8 한글인코딩
        resp.getWriter().println("응답데이터");      //응답하는거 getWriter().println(   여기가 실제 응답하는 글자 )
    }
    //req  => requset 요청하는거


//    @Override         void service 이게 우선 순위가 높아서 하나만 나옴
//    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
//        System.out.println("서비스 호출");
//        System.out.println(req.getMethod());    //getMethod HTTP 메서드가 들어올수있다.
//
//
//        if(req.getMethod().equalsIgnoreCase("GET")){                //이게 doGet이랑 같은거 모듈화했다
//            System.out.println("GET 요청 들어옴");
//        }
//    }

    @Override
    public void init(ServletConfig config) throws ServletException {
        System.out.println("FirstServlet 초기화");
    }
}
//주소값을 적으면 wep.xml에서 주소를 가면 거기를 찾아가라
//ex) first가 한번 요청(URL에 한번 입력하면 처음에 한번 생성)들어오면 com.example.servletstudy.FirstServlet이 객체를 생성new 한다.
//웹에서 first 들어갈떄 한번만 생성 그이후는 같은애 계속 호출