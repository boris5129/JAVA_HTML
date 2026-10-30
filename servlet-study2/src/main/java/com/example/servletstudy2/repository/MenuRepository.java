package com.example.servletstudy2.repository;

import com.example.servletstudy2.database.DatabaseProvider;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
public class MenuRepository implements Repository<com.example.servletstudy2.entity.Menu> {
    //JPA 자동으로 세팅해주는거 나중에 배움
    private static MenuRepository instance;

    private DatabaseProvider databaseProvider;

    private MenuRepository() {
        this.databaseProvider = DatabaseProvider.getInstance();
    }

    public static MenuRepository getInstance() {
        if (instance == null) instance = new MenuRepository();
        return instance;
    }

    @Override
    public List<com.example.servletstudy2.entity.Menu> findAll() {

        String sql = """
                select
                    *
                from
                    menus""";

        try {
            return select(databaseProvider.getConnection(), sql, null)
                    .stream()
                    .map(com.example.servletstudy2.entity.Menu::new)
                    .toList();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return List.of();
    }

    @Override
    public com.example.servletstudy2.entity.Menu findById(int id) {
        String sql = """
                select
                    *
                from
                    menus
                where
                    menu_id = ?
                """;

        try {
            Map<String, Object> row = selectOne(databaseProvider.getConnection(), sql, List.of(id));
            return new com.example.servletstudy2.entity.Menu(row);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static void main(String[] args) {
        System.out.println(MenuRepository.getInstance().findAll());
        System.out.println(MenuRepository.getInstance().findById(1));
    }
}
