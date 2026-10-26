package com.example.servletstudy2.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private int id;
    private String username;
    private String password;
    private String name;

    // copy 생성자 용도
    public User(User other) {       // 현재 아래는 생성자(깊은복사?) 기존 유저의 값을 복사해서 새로운 유저만든다
        this.id = other.id;
        this.username = other.username;
        this.password = other.password;
        this.name = other.name;
    }
}
