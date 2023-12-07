<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
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
<title>jndi-oracle</title>
</head>
<body>
<%
  InitialContext initialContext = new InitialContext();
  DataSource ds = (DataSource) initialContext.lookup("java:comp/env/jdbc/smplDS");
  Connection conn = null;
  Statement stmt = null;
  try {
    conn = ds.getConnection();
    stmt = conn.createStatement();
    stmt.execute("SELECT TABLE_NAME FROM ALL_TABLES");
    ResultSet rs = stmt.getResultSet();
    out.println("TABLES: ");
    List<String> list = new ArrayList<String>();
    while (rs.next()) {
      list.add(rs.getString(1));
    }
    out.println(list.toString());
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