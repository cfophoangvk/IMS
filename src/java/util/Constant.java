package util;

public class Constant {

    public static final String SESSION_ACCOUNT = "account";
    public static final String DEFAULT_PASSWORD = "12345678Aa@";

    public static final int ROLE_IT_ADMIN = 1;
    public static final int ROLE_SYSTEM_ADMIN = 2;
    public static final int ROLE_EMPLOYEE = 3;
    public static final int ROLE_MANAGER = 4;
    public static final int ROLE_BUSINESS_OWNER = 5;

    public static final int PAGE_SIZE = 10;

    public static final String PASSWORD_PATTERN = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!*]).{8,50}$";
    public static final String EMAIL_PATTERN = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    public static final String USERNAME_PATTERN = "^[a-zA-Z0-9_]{3,50}$";
    public static final String WAREHOUSE_CODE_PATTERN = "^[A-Za-z0-9\\-_]{1,20}$";
    public static final String PRODUCT_CODE_PATTERN = "^[A-Za-z0-9\\-]{1,50}$";

    public static final int[] PRODUCT_VIEWER_ROLES = {ROLE_SYSTEM_ADMIN, ROLE_EMPLOYEE, ROLE_MANAGER, ROLE_BUSINESS_OWNER};
    public static final int[] PRODUCT_EDITOR_ROLES = {ROLE_SYSTEM_ADMIN, ROLE_MANAGER};
    /*
        PASSWORD_PATTERN:
        (?=.*[0-9]): Phải chứa ít nhất một chữ số (0-9).
        (?=.*[a-z]): Phải chứa ít nhất một chữ cái thường (a-z).
        (?=.*[A-Z]): Phải chứa ít nhất một chữ cái viết hoa (A-Z).
        (?=.*[@#$%^&+=!*]): Phải chứa ít nhất một ký tự đặc biệt trong tập hợp @#$%^&+=!*.
        .{8,50}: Mật khẩu phải có từ 8 ký tự đến 50 ký tự.

        USERNAME_PATTERN:
        [a-zA-Z0-9_]{3,50}: Chỉ chứa chữ cái, số, gạch dưới. Từ 3-50 ký tự.

        EMAIL_PATTERN:
        Kiểm tra định dạng email cơ bản.
     */
}
