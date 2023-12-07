<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="javax.sql.DataSource"%>
<%@page import="javax.naming.InitialContext"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>smpl</title>
</head>
<body>
<%
  InitialContext initialContext = new InitialContext();
  DataSource ds = (DataSource) initialContext.lookup("java:comp/env/oracle/smplDS");
  Connection conn = null;
  Statement stmt = null;
  try {
    conn = ds.getConnection();
    stmt = conn.createStatement();
    stmt.execute("SELECT SYSDATE FROM DUAL");
    ResultSet rs = stmt.getResultSet();
    out.println("by jndi, ");
    if (rs.next()) {
      out.println(rs.getString(1));
    }
    stmt.close();
    conn.close();
  } catch (SQLException se) {
    out.println(se.toString()); 
  } catch (Exception e) {
    out.println(e.toString());
  } finally {
    try { if (stmt != null) stmt.close(); } catch (Exception e) {} 
    try { if (conn != null) conn.close(); } catch (Exception e) {} 
  }
%>
</body>
</html>