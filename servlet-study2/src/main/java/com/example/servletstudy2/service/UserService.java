package com.example.servletstudy2.service;

import com.example.servletstudy2.exception.DuplicatedException;
import com.example.servletstudy2.model.User;
import com.example.servletstudy2.repository.UserRepository;

import java.util.List;

public class UserService {
    private static UserService instance;
    private UserRepository userRepository;

    private UserService(UserRepository userRepository) {
        this.userRepository = userRepository;

    }

    public static UserService getInstance() {
        if(instance == null) {
            instance = new UserService(UserRepository.getInstance());
        }           //종속성주입 - 생성될떄 바로준다 (조립방식)
        return instance;
    }

    public void register(User user) throws RuntimeException {
        if(isDuplicatedUsername(user.getUsername())){
            throw new DuplicatedException("이미 존재하는 사용자 이름입니다.");
        }//if에서 예외 터지면 밑으로 안감
        userRepository.insert(user);
    }

    public boolean isDuplicatedUsername(String username) {
        return userRepository.findByUsername(username) != null; //null이 아니면 중복이다
    }       //boolean 리턴일떄 is, has 이런거 들어간다 '이다'  라서

    public List<User> getUserAll(){
        return userRepository.findAll();
        //control 에서 바로 repository로 못가서 걸쳐서 간다.
    }
}
