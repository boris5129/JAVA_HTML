package com.example.servletstudy2.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;

@WebFilter("/api/*")
public class Utf8EncodingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("1");
        request.setCharacterEncoding("UTF-8"); // 인코딩은 전처리다 후처리시는 이미 닫혀 인코딩불가
        response.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response); //서블릿을 호출한다
        System.out.println("3");
    }
}
