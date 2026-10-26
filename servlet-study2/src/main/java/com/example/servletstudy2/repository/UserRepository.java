package com.example.servletstudy2.repository;

import com.example.servletstudy2.model.User;

import java.util.ArrayList;
import java.util.List;

public class UserRepository {
    private static UserRepository instance;
    private int lastId;
    private List<User> users;               //인스턴스필드

    private UserRepository() {              //인스턴스 초기화
        lastId = 1;
        users = new ArrayList<>();
    }

    public static UserRepository getInstance() {
        if (instance == null) {
            instance = new UserRepository();
        }
        return instance;
    }

    public void insert(User user) {              //인스턴스 매서드
        user.setId(lastId++);
        users.add(user);
    }

    //List안에서 찾아서 같은 유저네임 동일하면 리턴 동일 없으면 널
    public User findByUsername(String username) {
        for (User user : users) {
            if (user.getUsername().equalsIgnoreCase(username)) {
                return user;
            }
        }
        return null;
//        for (int i = 0; i < users.size(); i++){               //자주나오니깐 외우기 찾는 코드
//            if(users.get(i).getUsername().equals(username)){
//                return users.get(i);
//            }
//        }return null;
    }

    public User findById(int userId) {      //중복체크하려고  있으면 가입된사용자
        for (User user : users) {
            if (user.getId() == userId) {
                return user;
            }
        }
        return null;
//        for (int i = 0; i < users.size(); i++) {
//            if (users.get(i).getId() == userId) {
//                return users.get(i);
//            }
//        }return null;
//        return users.stream().filter(user -> user.getId() == userid)
//                .findFirst()
//                .orElseGet(() -> null);       //리턴쪽 다른방법 찾아서 처음이 없으면 널/ 처음을 찾으면 리턴해줌
    }

    public List<User> findAll(){
        return users.stream().map(user -> new User(user)).toList();//내용이 똑같은 새로운 유저 만듬
    }   //R -> S로 갈때 리스트의 주소를줌 가서 set해버리면 원본이 바뀌니깐 리스트안에 유저가 변경되는걸 방지
}
