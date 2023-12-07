<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>smpl</title>
</head>
<body>
<%
String url = "jdbc:oracle:thin:@172.28.200.31:1521:ORCLCDB";
String userId = "SYSTEM";
String userPwd = "1";
String driver = "oracle.jdbc.driver.OracleDriver";

Class.forName(driver);
Connection conn = DriverManager.getConnection(url, userId, userPwd);
Statement stmt = null;
try {
  stmt = conn.createStatement();
  stmt.execute("SELECT SYSDATE FROM DUAL");
  ResultSet rs = stmt.getResultSet();
  
  if (rs.next()) {
    out.println("by jdbc, " + rs.getString(1));
  }
  stmt.close();
  conn.close();
} catch (Exception e) {
  e.printStackTrace();
} finally {
  try { if (stmt != null) stmt.close(); } catch (Exception e) {}
  try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>
</body>
</html>