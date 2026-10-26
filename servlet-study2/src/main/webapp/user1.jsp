<%@ page import="com.example.servletstudy2.model.User" %><%--
  Created by IntelliJ IDEA.
  User: GwanWoo
  Date: 26. 10. 26.
  Time: 오전 11:41
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    User user = new User(1, "user1","1234","김준일");

%>


<html>
  <head>
    <title>Title</title>
  </head>
  <body>
    <h1><%=user.getId()%></h1>
    <h1><%=user.getUsername()%></h1>
    <h1><%=user.getPassword()%></h1>
  </body>
</html>
