package com.example.servletstudy2.database;

import com.example.servletstudy2.entity.Customer;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DBConnectionTest02 {
    public static void main(String[] args) {

        String protocol = "jdbc:mysql";
        String host = "localhost";
        String post = "3308";
        String databaseName = "hanip_delivery02";
        String userName = "root";
        String password = "1q2w3e4r!";

        String url = String.format("%s://%s:%s/%s", protocol, host, post, databaseName);

        List<Customer> customers = new ArrayList<>();

        try (Connection connection = DriverManager.getConnection(url, userName, password)) {
            PreparedStatement preparedStatement = connection.prepareStatement("""
        select *
            from
        customers""");
            ResultSet rs = preparedStatement.executeQuery();
            while(rs.next()){
                Customer customer = new Customer(
                        rs.getInt("customer_id"),
                        rs.getString("name"),
                        rs.getString("phone"),
                        rs.getString("email"),
                        rs.getString("birth_date"),
                        rs.getString("district"),
                        rs.getString("address"),
                        rs.getString("grade"),
                        rs.getBoolean("marketing_agreed"),
                        rs.getString("joined_at")
                );

                customers.add(customer);
            }
        } catch (SQLException e){
            System.out.println("데이터연결실패");
            e.printStackTrace();
        }  customers.forEach(System.out::println);

    }
}