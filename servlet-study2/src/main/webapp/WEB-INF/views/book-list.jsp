<%@ page import="com.example.servletstudy2.model.Book" %>
<%@ page import="java.util.List" %><%--
  Created by IntelliJ IDEA.
  User: GwanWoo
  Date: 26. 10. 26.
  Time: 오후 4:49
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Book> bookList = (List<Book>) request.getAttribute("bookList");//getAttribute할때 업캐스팅되서 다운캐스팅한다.
%>

<html>
<head>
    <title>Title</title>
    <STYLE>
        table {
            border: 1px solid #222;
            border-collapse: collapse;
        }

        th, td{
            border: 1px solid #222;
            width: 300px;
            height: 40px;
        }
    </STYLE>
</head>
<body>
<button onclick="location.href='http://localhost:8080/book/register'">등록</button>
<div>
    <table>
        <thead>
        <tr>
            <th>Id</th>
            <th>책제목</th>
            <th>가격</th>
        </tr>
        </thead>
        <TBODY>
        <%
            for (Book book : bookList){
        %>
        <tr>
            <td><%=book.getId()%></td>
            <td><%=book.getBookname()%></td>
            <td><%=book.getPrice()%></td>
        </tr>
        <%
            }
        %>
        </TBODY>
    </table>
</div>
</body>
</html>
