package com.example.servletstudy2.entity;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Customer {
    private int customerId;
    private String name;
    private String phone;
    private String email;
    private String birthDate;
    private String district;
    private String address;
    private String grade;
    private int marketingAgreed;
    private String joinedAt;

    public Customer(Map<String, Object> map) {
        this.customerId = (int) map.get("customerId");
        this.name = (String) map.get(name);
        this.phone = (String)map.get(phone);
         this.email = (String)map.get(email);
        this.birthDate = (String)map.get(birthDate);
        this.district = (String)map.get(district);
        this.address = (String)map.get(address);
        this.grade = (String)map.get(grade);
        this.marketingAgreed = (int)map.get(marketingAgreed);
        this.joinedAt = (String)map.get(joinedAt);
    }
}
