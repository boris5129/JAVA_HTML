package com.example.servletstudy2.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Car {
    private String carName;     //차종
    private String carNumber;   //차번호
    private String owner;        //차주

    public Car (Car other){
        this.carName = other.carName;
        this.carNumber = other.carNumber;
        this.owner = other.owner;
    }

}
