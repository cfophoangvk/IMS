package util;

import io.github.cdimascio.dotenv.Dotenv;
import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailService {

    public static boolean sendAccountCredentials(String toEmail, String username, String rawPassword) {
        try {
            Dotenv dotenv = Dotenv.load();
            String SMTP_HOST = dotenv.get("SMTP_HOST");
            String SMTP_PORT = dotenv.get("SMTP_PORT");
            String SMTP_USERNAME = dotenv.get("SMTP_USERNAME");
            String SMTP_PASSWORD = dotenv.get("SMTP_PASSWORD");
            
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_USERNAME, "IMS System"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("IMS - Thông tin tài khoản của bạn", "UTF-8");

            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>"
                    + "<div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;'>"
                    + "<h1 style='color: white; margin: 0; text-align: center;'>IMS System</h1>"
                    + "<p style='color: #e0e0e0; text-align: center; margin-top: 5px;'>Hệ thống quản lý kho</p>"
                    + "</div>"
                    + "<div style='background: #ffffff; padding: 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px;'>"
                    + "<h2 style='color: #333;'>Xin chào,</h2>"
                    + "<p style='color: #555;'>Tài khoản của bạn đã được tạo trên hệ thống IMS. Dưới đây là thông tin đăng nhập:</p>"
                    + "<div style='background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea;'>"
                    + "<p style='margin: 5px 0;'><strong>Tên đăng nhập:</strong> " + username + "</p>"
                    + "<p style='margin: 5px 0;'><strong>Mật khẩu:</strong> " + rawPassword + "</p>"
                    + "</div>"
                    + "<p style='color: #e74c3c; font-weight: bold;'>⚠ Vui lòng đổi mật khẩu ngay sau khi đăng nhập lần đầu tiên.</p>"
                    + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>"
                    + "<p style='color: #999; font-size: 12px; text-align: center;'>Email này được gửi tự động từ hệ thống IMS. Vui lòng không trả lời.</p>"
                    + "</div>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean sendDailyClosingNotification(java.util.List<String> emails, String warehouseName,
            String closingDate, java.util.List<model.InventoryTransaction> transactions) {
        if (emails == null || emails.isEmpty()) return true;
        try {
            Dotenv dotenv = Dotenv.load();
            String SMTP_HOST = dotenv.get("SMTP_HOST");
            String SMTP_PORT = dotenv.get("SMTP_PORT");
            String SMTP_USERNAME = dotenv.get("SMTP_USERNAME");
            String SMTP_PASSWORD = dotenv.get("SMTP_PASSWORD");

            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
                }
            });

            // Build transaction rows
            StringBuilder rows = new StringBuilder();
            int idx = 1;
            for (model.InventoryTransaction t : transactions) {
                String typeName;
                switch (t.getTransactionType()) {
                    case 1: typeName = "Nhập - NCC"; break;
                    case 2: typeName = "Xuất - NCC"; break;
                    default: typeName = "Nội bộ"; break;
                }
                String status;
                switch (t.getApprovalStatus()) {
                    case 0: status = "Chờ duyệt"; break;
                    case 1: status = "Đã duyệt"; break;
                    default: status = "Từ chối"; break;
                }
                rows.append("<tr>")
                    .append("<td style='padding:8px;border:1px solid #ddd;text-align:center;'>").append(idx++).append("</td>")
                    .append("<td style='padding:8px;border:1px solid #ddd;'>").append(t.getTransactionCode()).append("</td>")
                    .append("<td style='padding:8px;border:1px solid #ddd;text-align:center;'>").append(typeName).append("</td>")
                    .append("<td style='padding:8px;border:1px solid #ddd;text-align:center;'>").append(status).append("</td>")
                    .append("</tr>");
            }

            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 700px; margin: 0 auto;'>"
                    + "<div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;'>"
                    + "<h1 style='color: white; margin: 0; text-align: center;'>IMS System</h1>"
                    + "<p style='color: #e0e0e0; text-align: center; margin-top: 5px;'>Thông báo chốt sổ</p>"
                    + "</div>"
                    + "<div style='background: #ffffff; padding: 30px; border: 1px solid #e0e0e0; border-radius: 0 0 10px 10px;'>"
                    + "<h2 style='color: #333;'>Chốt sổ ngày " + closingDate + "</h2>"
                    + "<p style='color: #555;'>Kho <strong>" + warehouseName + "</strong> đã được chốt sổ ngày <strong>" + closingDate + "</strong>.</p>"
                    + "<h3 style='color: #333; margin-top: 20px;'>Danh sách phiếu nhập/xuất</h3>"
                    + "<table style='width:100%;border-collapse:collapse;margin:10px 0;'>"
                    + "<thead><tr style='background:#f8f9fa;'>"
                    + "<th style='padding:8px;border:1px solid #ddd;'>STT</th>"
                    + "<th style='padding:8px;border:1px solid #ddd;'>Mã phiếu</th>"
                    + "<th style='padding:8px;border:1px solid #ddd;'>Loại</th>"
                    + "<th style='padding:8px;border:1px solid #ddd;'>Trạng thái</th>"
                    + "</tr></thead>"
                    + "<tbody>" + rows.toString() + "</tbody>"
                    + "</table>"
                    + (transactions.isEmpty() ? "<p style='color:#999;text-align:center;'>Không có phiếu nào.</p>" : "")
                    + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>"
                    + "<p style='color: #999; font-size: 12px; text-align: center;'>Email này được gửi tự động từ hệ thống IMS.</p>"
                    + "</div></div>";

            for (String email : emails) {
                try {
                    MimeMessage message = new MimeMessage(session);
                    message.setFrom(new InternetAddress(SMTP_USERNAME, "IMS System"));
                    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
                    message.setSubject("IMS - Thông báo chốt sổ kho " + warehouseName + " ngày " + closingDate, "UTF-8");
                    message.setContent(htmlContent, "text/html; charset=UTF-8");
                    Transport.send(message);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
