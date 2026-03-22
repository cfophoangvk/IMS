package util;

import java.sql.*;

public class DBContext {

    private static Connection con = null;

    static {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=IMS;trustServerCertificate=true";
        String user = "sa";
        String pass = "123456";
        
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {
        return con;
    }
}