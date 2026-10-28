<%--
  Created by IntelliJ IDEA.
  User: GwanWoo
  Date: 26. 10. 28.
  Time: 오전 10:17
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <STYLE>
        table {
            border: 1px solid #222;
            border-collapse: collapse;
        }

        th, td {
            border: 1px solid #222;
            width: 200px;
        }
    </STYLE>
</head>
<body>
<table>
    <thead>
    <tr>
        <th>번호</th>
        <th>차종</th>
        <th>색상</th>
        <th>가격</th>
    </tr>
    </thead>
    <tbody>

    </tbody>
</table>
<script>
    async function getCarList(){
        const response = await fetch("http://192.168.2.8:8080/api/cars" , {
        method: "get",
            headers: {
            "Content-Type": "application/json"
            }
        });
        const responseJson = await response.json();
        console.log(response);
        const tbody = document.querySelector("tbody");
        tbody.innerHTML = responseJson.map((car, index) => (
            `<tr>
                <td>\${index + 1}</td>
                <td>\${car.carModel}</td>
                <td>\${car.carColor}</td>
                <td>\${car.carPrice}</td>
              </tr>
            `
        )).join("");

    }
    getCarList();
</script>

</body>
</html>
