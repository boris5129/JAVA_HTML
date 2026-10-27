<%--
  Created by IntelliJ IDEA.
  User: GwanWoo
  Date: 26. 10. 26.
  Time: 오후 12:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <form method="post" onsubmit="handleOnSubmit(event)">
    <div>
        <input type="text" name="username" placeholder="사용자이름" onkeyup="handleOnChange(event)">
    </div>
    <div>
        <input type="password" name="password" placeholder="비밀번호" onkeyup="handleOnChange(event)">
    </div>
    <div>
        <input type="text" name="name" placeholder="이름" onkeyup="handleOnChange(event)">
    </div>
    <button>등록하기</button>
    </form>

    <script>
        let user = {
            username: "",
            password: "",
            name: "",

        }

        function handleOnChange(event){
            const name = event.target.name;
            //target에서 username, password, name 받는다 여기 name은 key값  username, password, name 다
            const value = event.target.value;
            user = {
                ...user,
                [name]: value,
            };

            console.log(user);
        }

        async function registerApi(data){
            const jsonData = JSON.stringify(data);      //제이슨자료(문자열)형으로 변환
           const  response = await fetch("http://localhost:8080/api/users", {
                method: "post",
                headers: {
                    "Content-Type": "application/json", //이건 제이슨이다 라고 꼬리표 붙여주는거
                },
                body: jsonData,         //body는 전송에 사용되는 주 데이터
            });

           console.log(response)

           const responseBody = await response.json();
           console.log(responseBody);
            alert(responseBody.message);
           if(response.status !== 200){
               return;
           }
            location.replace("/user/list"); //replace href 페이지 이동  뒤로가기에 href는 history를 남김
        }

        function handleOnSubmit(event) {
            event.preventDefault();         //preventDefault 기존 전달된 이벤트(행동) 제거
            registerApi(user);
        }
    </script>
</body>
</html>
