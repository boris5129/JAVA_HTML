package com.example.servletstudy2.database;

import com.example.servletstudy2.entity.Menu;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DBConnectionTest {
    public static void main(String[] args) {
        String protocol = "jdbc:mysql";
        String host = "localhost";
        String port = "3308";
        String databaseName = "hanip_delivery02";
        String username = "root";
        String password = "1q2w3e4r!";


        String url = String.format("%s://%s:%s/%s", protocol, host, port, databaseName);
        // jdbc:mysql://localhost:3308/

        List<Menu> menus = new ArrayList<>();
        try(Connection connection = DriverManager.getConnection(url, username, password)){
            PreparedStatement pstmt = connection.prepareStatement("""
select
    *
from
    menus""");      //sql 은 sql 쿼리문 넣는곳
            ResultSet rs = pstmt.executeQuery(); //쿼리문 결과가 rs에 담김
            while(rs.next()){
                Menu menu = new Menu(
                        rs.getInt("menu_id"),
                        rs.getInt("restaurant_id"),
                        rs.getString("name"),
                        rs.getInt("price"),
                        rs.getString("description"),
                        rs.getBoolean("is_signature"),
                rs.getBoolean("is_sold_out")
                );

                menus.add(menu);
//                System.out.println(rs.getInt("menu_id"));
//                System.out.println(rs.getInt("restaurant_id"));
//                System.out.println(rs.getString("name"));
//                System.out.println(rs.getInt("price"));
//                System.out.println(rs.getString("description"));
//                System.out.println(rs.getBoolean("is_signature"));
//                System.out.println(rs.getBoolean("is_sold_out"));
            }
        }catch (SQLException e){
            System.out.println("데이터연결 실패");
            e.printStackTrace();
        }
        //Connection 연결하곘다. Connection 뒤에는 Connection을 끊어줘야한다 그래야 연결이가능
        //Connection 소멸을 해준다. try catch인데 안에서 finally 후에 Connection이 자동으로 close 해줌
        //try with resource
        menus.forEach(System.out::println); //람다식 변현

    }
}
