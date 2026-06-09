<%@ page import="java.sql.*,javax.naming.*,javax.sql.*" %>
<html>
<head><title>Global Bank Terminal</title></head>
<body style="font-family: sans-serif; padding: 20px;">
<h1 style="color: #2c3e50;">Welcome to Global Bank</h1>
<hr>
<%
Connection conn = null;
try {
    Context ctx = new InitialContext();
    DataSource ds = (DataSource)ctx.lookup("jdbc/BankDB");
    conn = ds.getConnection();
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT BALANCE FROM ACCOUNTS WHERE NAME='User_Admin'");
    if(rs.next()) {
        double bal = rs.getDouble("BALANCE");
        out.println("<div style='background: #ecf0f1; padding: 20px; border-radius: 10px;'>");
        out.println("<h3>Account: User_Admin</h3>");
        out.println("<h2 style='color: #27ae60;'>Your Current Balance is: $" + bal + "</h2>");
        out.println("</div>");
    }
} catch(Exception e) {
    out.println("<p style='color: red;'>Database Error: " + e.getMessage() + "</p>");
} finally {
    if(conn != null) conn.close();
}
%>
</body>
</html>
