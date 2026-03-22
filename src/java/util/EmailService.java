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
}
