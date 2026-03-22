package util;

import java.util.regex.Pattern;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.ResultSetMetaData;

public class Validator {

    public static boolean isValidPassword(String password) {
        if (password == null) {
            return false;
        }
        Pattern pattern = Pattern.compile(Constant.PASSWORD_PATTERN);
        return pattern.matcher(password).matches();
    }

    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        Pattern pattern = Pattern.compile(Constant.EMAIL_PATTERN);
        return pattern.matcher(email.trim()).matches();
    }

    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        Pattern pattern = Pattern.compile(Constant.USERNAME_PATTERN);
        return pattern.matcher(username.trim()).matches();
    }

    public static boolean isValidFullName(String name) {
        return name != null && name.trim().length() >= 2 && name.trim().length() <= 100;
    }

    public static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData(); //
        int columns = rsmd.getColumnCount(); //
        for (int x = 1; x <= columns; x++) {
            if (columnName.equalsIgnoreCase(rsmd.getColumnLabel(x))) {
                return true;
            }
        }
        return false;
    }
}
