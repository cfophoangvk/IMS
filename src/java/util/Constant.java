package util;

import java.util.HashMap;
import java.util.Map;
import static java.util.Map.entry;

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
    public static final int[] PRODUCT_VIEWER_ROLES = {ROLE_SYSTEM_ADMIN, ROLE_EMPLOYEE, ROLE_MANAGER, ROLE_BUSINESS_OWNER};
    public static final int[] PRODUCT_EDITOR_ROLES = {ROLE_SYSTEM_ADMIN, ROLE_MANAGER};

    public static final int TX_TYPE_IMPORT = 1;
    public static final int TX_TYPE_EXPORT = 2;
    public static final int TX_TYPE_TRANSFER = 3;

    public static final int APPROVAL_PENDING = 0;
    public static final int APPROVAL_APPROVED = 1;
    public static final int APPROVAL_REJECTED = 2;

    public static final int[] TX_CREATE_ROLES = {ROLE_EMPLOYEE, ROLE_MANAGER};
    public static final int[] TX_VIEW_ROLES = {ROLE_EMPLOYEE, ROLE_MANAGER, ROLE_BUSINESS_OWNER};

    public static final HashMap<Integer, String> PARTNER_LIST = new HashMap<>(Map.ofEntries(
            entry(1, "Công ty TNHH Giải pháp Công nghệ NextGen"),
            entry(2, "Tập đoàn Điện tử Quang Anh"),
            entry(3, "Nhà cung cấp Linh kiện Bách Khoa"),
            entry(4, "Công ty Cổ phần Số hóa Toàn Cầu"),
            entry(5, "Xưởng Nội thất Văn phòng Hiện Đại"),
            entry(6, "Công ty VPP Sao Mai"),
            entry(7, "Nhà phân phối Giấy và Thiết bị in ấn Thành Công"),
            entry(8, "Nông trại Xanh Đà Lạt"),
            entry(9, "Công ty Thực phẩm Sạch An Bình"),
            entry(10, "Tổng kho Sỉ Hàng tiêu dùng Minh Long"),
            entry(11, "Công ty Vận tải Thần Tốc"),
            entry(12, "Dịch vụ Bảo trì & Vệ sinh Công nghiệp 247"),
            entry(13, "Đơn vị Cung cấp Nhân sự Á Châu")
    ));
}
