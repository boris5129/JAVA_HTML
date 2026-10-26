<%@ page import="java.util.List" %>
<%@ page import="com.example.servletstudy2.model.User" %><%--
  Created by IntelliJ IDEA.
  User: GwanWoo
  Date: 26. 10. 26.
  Time: 오후 12:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<User> userList = (List<User>) request.getAttribute("userList");//getAttribute할때 업캐스팅되서 다운캐스팅한다.
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
    <button onclick="location.href='http://localhost:8080/user/register'">등록</button>
    <div>
        <table>
            <thead>
                <tr>
                    <th>번호</th>
                    <th>사용자이름</th>
                    <th>비밀번호</th>
                    <th>성명</th>
               </tr>
            </thead>
            <TBODY>
                <%
                    for (User user : userList){
                %>
                <tr>
                    <td><%=user.getId()%></td>
                    <td><%=user.getUsername()%></td>
                    <td><%=user.getPassword()%></td>
                    <td><%=user.getName()%></td>
                </tr>
                <%
                    }
                %>
            </TBODY>
        </table>
    </div>
</body>
</html>
