<%--
  Created by IntelliJ IDEA.
  User: GwanWoo
  Date: 26. 10. 27.
  Time: 오후 5:04
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
            <th>상품명</th>
            <th>가격</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td>번호</td>
            <td>상품명</td>
            <td>가격</td>
        </tr>
        <tr>
            <td>번호</td>
            <td>상품명</td>
            <td>가격</td>
        </tr>
        </tbody>
    </table>
    <script>
        async function getProductList(){
            const response = await fetch("http://localhost:8080/api/products", {
                method: "GET",      //post는 데이터 집어넣을때 get은 가져올떄
                headers: {
                    "Content-Type": "application/json"
                }
            });
           // const responseText = await response.text(); // json문자열로받는다
            //const responseJson = JSON.parse(responseText); // json오브젝트로 변환해서 받는다.
            const responseJson = await response.json(); // json오브젝트로 변환해서 받는다. 한번에
            console.log(response);
           // console.log(responseText);
            console.log(responseJson);
            const tbody = document.querySelector("tbody");
            tbody.innerHTML = responseJson.map((product, index) => (
                "<tr><td>" + (index + 1) + "</td><td>" + product.productName + "</td><td>" + product.price + "</td></tr>"
            )).join("");
            <%--tbody.innerHTML = responseJson.map((value, index) => (--%>
            <%--    '<tr><td>${index + 1}</td><td>${product.productName}</td><td>${product.productPrice}</td></tr>'--%>
            <%--)).join("");--%>
            // tbody.innerHTML = responseJson.map((product, index) => (
            //     // 2. 양 끝을 백틱(`)으로 감싸기
            //     // 3. $ 기호 앞에 백슬래시(\) 붙이기
            //     `<tr><td>\${index + 1}</td><td>\${product.productName}</td><td>\${product.productPrice}</td></tr>`
            // )).join("");  이거확인

        }
        getProductList();
    </script>
</body>
</html>
