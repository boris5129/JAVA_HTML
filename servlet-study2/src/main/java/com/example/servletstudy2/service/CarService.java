package com.example.servletstudy2.service;

import com.example.servletstudy2.exception.DuplicatedException;
import com.example.servletstudy2.model.Car;
import com.example.servletstudy2.repository.CarRepository;

import java.util.List;

public class CarService {
    private static CarService instance;
    private CarRepository carRepository;

    private CarService(CarRepository carRepository){
        this.carRepository = carRepository;
    }

    public static CarService getInstance(){
        if(instance == null){
            instance = new CarService(CarRepository.getInstance());
        }return instance;
    }

    public void register(Car car) throws RuntimeException{
        if(isDuplicatedCarNumber(car.getCarNumber())){
            throw new DuplicatedException("이미 존재하는 차량입니다.");
        }
        carRepository.insert(car);
    }

    public boolean isDuplicatedCarNumber(String carNumber){

        return carRepository.findByCarNumber(carNumber) != null;
    }

    public List<Car> getCarAll(){
        return carRepository.findAll();
    }

    public void remove(Car car) throws RuntimeException {
        if(!(isDuplicatedCarNumber(car.getCarNumber()))){
            throw new DuplicatedException("등록되지 않은 차량입니다.");
        }carRepository.remove(car.getCarNumber());
    }

}
