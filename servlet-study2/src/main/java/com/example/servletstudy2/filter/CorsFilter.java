package com.example.servletstudy2.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter("/api/*")        //* 모든 요청 /여기서는 API붙은 모든거
public class CorsFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("전처리");
        System.out.println("11");
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String method = req.getMethod();
        //request자료형이 ServletRequest라 method가 없다  (HttpServletRequest) request;  다운캐스팅해서 생김
        System.out.println(method);

        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");

        if("OPTIONS".equals(method)) {               //옵션즈가 아니면 이게 안걸린다. 시큐릿티는 전처리다
            resp.setStatus(200);
            return;
        }
        chain.doFilter(request, response);      //여기까지가면 servlet으로 간다
        System.out.println("22");
        System.out.println("후처리");
    }
    //dofilter를 기준으로 전에실행되는걸 전체리하고한다
    //servlet에서는 순서를 줄수없다 현재순서는 클래스순서대로
    //options 는 크로스오리진이 되었는지 확인된다.
}
