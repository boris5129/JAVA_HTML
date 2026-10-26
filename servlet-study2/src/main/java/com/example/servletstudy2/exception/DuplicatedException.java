package com.example.servletstudy2.exception;

public class DuplicatedException extends  RuntimeException {

    public DuplicatedException(String message) {
        super(message);
    }
}
