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
  </head>
  <body>
    <input placeholder="차종" onkeyup="handleCarModelInputOnKeyUp(event)">
    <input placeholder="색상" onkeyup="handleCarColorInputOnKeyUp(event)">
    <input placeholder="가격" onkeyup="handleCarPriceInputOnKeyUp(event)">
    <button onclick="handleRegisterOnClick(event)">등록</button>


    <script>
        let Car = {
            carModel: "",
            carColor: "",
            carPrice: 0,
        }

        function handleCarModelInputOnKeyUp(event){
            console.log(event.target.value);
            Car = {
            ...Car,
                carModel: event.target.value,
            }
        }

        function handleCarColorInputOnKeyUp(event){
            console.log(event.target.value);
            Car = {
                ...Car,
                carColor: event.target.value,
            }
        }

        function handleCarPriceInputOnKeyUp(event){
            console.log(event.target.value);
            Car = {
                ...Car,
              carPrice: event.target.value,
            }
        }
        function handleRegisterOnClick(event) {
            console.log(JSON.stringify(Car));

            fetch("http://192.168.2.8:8080/api/cars", {
                method: "POST",
                body: JSON.stringify(Car),
                headers: {
                    "Content-Type": "application/json",
                }
            });
        }
    </script>
  </body>
</html>
