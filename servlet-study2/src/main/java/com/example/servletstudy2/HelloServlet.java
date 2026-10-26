package com.example.servletstudy2;

import java.io.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@WebServlet(name = "helloServlet", value = "/hello")
public class HelloServlet extends HttpServlet {
    private String message;

    public void init() {
        message = "Hello World!";
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        String[] names= {"김준일, 김준이"};

        // Hello
            PrintWriter out = response.getWriter();//out 변수에 response.getWriter();이거 담기
        out.println("""
            <html>
                <head>
                    <title>탭제목</title>
                </head>
                <body>
                    <h1>김준일</h1>
                    <h1>김준이</h1>
                </body>
                </html>""");

    }

    public void destroy() {
    }
}