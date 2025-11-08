<%-- 
    Document   : list_students
    Created on : Nov 8, 2025, 2:19:42 PM
    Author     : THIS PC
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.SM.Student" %>
<%-- Assuming the Student model class is located in com.yourcompany.model --%>

<%!
// Define JDBC Connection Constants (REPLACE with your actual DB info)
private final String JDBC_URL = "jdbc:mysql://localhost:3306/student_db";
private final String JDBC_USER = "root";
private final String JDBC_PASSWORD = "Tienanh0108!";
private final String QUERY_ALL = "SELECT id, student_code, full_name, email, major, created_at FROM students";

// Utility function to close database resources
private void closeResources(ResultSet rs, Statement stmt, Connection conn) {
    try {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        // Log error while closing
        System.err.println("Error closing database resources: " + e.getMessage());
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        table { border-collapse: collapse; width: 80%; margin: 20px auto; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2 style="text-align: center;">Student Management</h2>

    <%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    List<Student> studentList = new ArrayList<>();
    String errorMessage = null;

    try {
        // 1. Database Connection (JDBC)
        Class.forName("com.mysql.cj.jdbc.Driver"); // Load the JDBC Driver
        conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
        
        // 2. Query all students
        stmt = conn.createStatement();
        rs = stmt.executeQuery(QUERY_ALL);

        // 3. Process ResultSet and map to Student objects
        while (rs.next()) {
            Student student = new Student();
            student.setId(rs.getInt("id"));
            student.setStudentCode(rs.getString("student_code"));
            student.setFullName(rs.getString("full_name"));
            student.setEmail(rs.getString("email"));
            student.setMajor(rs.getString("major"));
            student.setCreatedAt(rs.getTimestamp("created_at"));
            studentList.add(student);
        }

    } catch (ClassNotFoundException e) {
        errorMessage = "Error: JDBC Driver not found. Please check your Maven dependency.";
        System.err.println(errorMessage + ": " + e.getMessage());
    } catch (SQLException e) {
        // Handle database errors gracefully
        errorMessage = "Database Connection/Query Error: " + e.getMessage();
        System.err.println(errorMessage);
    } finally {
        // 4. Close all database resources properly
        closeResources(rs, stmt, conn);
    }
    %>

    <% if (errorMessage != null) { %>
        <p style="color: red; text-align: center;">
            Error: <%= errorMessage %>
        </p>
    <% } else if (studentList.isEmpty()) { %>
        <p style="text-align: center;">No students found in the database.</p>
    <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student Code</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Major</th>
                    <th>Created At</th>
                </tr>
            </thead>
            <tbody>
                <% for (Student student : studentList) { %>
                    <tr>
                        <td><%= student.getId() %></td>
                        <td><%= student.getStudentCode() %></td>
                        <td><%= student.getFullName() %></td>
                        <td><%= student.getEmail() %></td>
                        <td><%= student.getMajor() %></td>
                        <td><%= student.getCreatedAt() %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>

</body>
</html>
