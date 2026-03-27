# tải tomcat
FROM tomcat:10.1.18-jdk17
# xóa trang home của tomcat (xóa đường dẫn /)
RUN rm -rf /usr/local/tomcat/webapps/ROOT
# copy file war vào trong đường dẫn của tomcat để nó chạy (/ims)
COPY target/ims.war /usr/local/tomcat/webapps/ims.war
# mở cổng 8080 trong container
EXPOSE 8080
# chạy lệnh run
CMD ["catalina.sh", "run"]