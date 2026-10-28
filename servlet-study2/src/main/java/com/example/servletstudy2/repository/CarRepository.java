package com.example.servletstudy2.repository;

import com.example.servletstudy2.model.Car;

import java.util.ArrayList;
import java.util.List;

public class CarRepository {
    private static CarRepository instance;
    private int lastId;
    private List<Car> cars;

    private CarRepository() {
        lastId = 0;
        cars = new ArrayList<>();
    }

    public static CarRepository getInstance() {
        if (instance == null) {
            instance = new CarRepository();
        }
        return instance;
    }

    public void insert(Car car) {
        lastId++;
        cars.add(car);
    }

    public void remove(String carNumber) {
        for(int i = 0; i < cars.size(); i++){
            if(cars.get(i).getCarNumber().equalsIgnoreCase(carNumber)){
                cars.remove(i);
                break;
            }
        }
    }

    public Car findByCarNumber(String carNumber){
        for (Car car : cars){
            if (car.getCarNumber().equalsIgnoreCase(carNumber)){
                return car;
            }
        }return null;
    }

    public List<Car> findAll(){
        return cars.stream().map(car -> new Car(car)).toList();
    }


}
