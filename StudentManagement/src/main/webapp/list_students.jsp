<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Objects" %>
<%-- Import Objects for safer null/empty checks --%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student List</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            h1 {
                color: #333;
            }
            .message {
                padding: 10px;
                margin-bottom: 20px;
                border-radius: 5px;
            }
            .success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            .error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
            .btn {
                display: inline-block;
                padding: 10px 20px;
                margin-bottom: 20px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background-color: white;
            }
            th {
                background-color: #007bff;
                color: white;
                padding: 12px;
                text-align: left;
            }
            td {
                padding: 10px;
                border-bottom: 1px solid #ddd;
            }
            tr:hover {
                background-color: #f8f9fa;
            }
            .action-link {
                color: #007bff;
                text-decoration: none;
                margin-right: 10px;
            }
            .delete-link {
                color: #dc3545;
            }
            /* Styling for the search form */
            .search-form {
                display: flex;
                gap: 10px;
                margin-bottom: 20px;
            }
            .search-form input[type="text"] {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
                flex-grow: 1;
            }
            .search-form button {
                padding: 8px 15px;
                background-color: #28a745;
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
            }
            .search-form a {
                padding: 8px 15px;
                background-color: #6c757d;
                color: white;
                border: none;
                border-radius: 4px;
                text-decoration: none;
            }
        </style>
    </head>
    <body>
        <h1>📚 Student Management System</h1>

        <%-- Display Success/Error Messages --%>
        <% if (request.getParameter("message") != null) {%>
        <div class="message success">
            <%= request.getParameter("message")%>
        </div>
        <% } %>

        <% if (request.getParameter("error") != null) {%>
        <div class="message error">
            <%= request.getParameter("error")%>
        </div>
        <% }%>

        <form action="list_students.jsp" method="GET" class="search-form">
            <input type="text" name="keyword" placeholder="Search by name or code..." 
                   value="<%= Objects.toString(request.getParameter("keyword"), "")%>">
            <button type="submit">Search</button>
            <a href="list_students.jsp">Clear</a>
        </form>

        <a href="add_student.jsp" class="btn">➕ Add New Student</a>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student Code</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Major</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    Connection conn = null;
                    PreparedStatement pstmt = null; // Use PreparedStatement for security
                    ResultSet rs = null;

                    // Task 5.2: Implement Search Logic
                    String keyword = request.getParameter("keyword");
                    String sql;
                    boolean isSearching = false;

                    if (keyword != null && !keyword.trim().isEmpty()) {
                        isSearching = true;
                        sql = "SELECT * FROM students WHERE UPPER(full_name) LIKE ? OR UPPER(student_code) LIKE ? OR UPPER(major) LIKE ?";
                    } else {
                        // Normal query
                        sql = "SELECT * FROM students ORDER BY id DESC";
                    }

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");

                        conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_management",
                                "root",
                                "Tienanh0108!"
                        );

                        pstmt = conn.prepareStatement(sql);

                        if (isSearching) {
                            String searchParam = "%" + keyword.toUpperCase() + "%";

                            pstmt.setString(1, searchParam);
                            pstmt.setString(2, searchParam);
                            pstmt.setString(3, searchParam);
                        }

                        rs = pstmt.executeQuery(); // Execute the query

                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String studentCode = rs.getString("student_code");
                            String fullName = rs.getString("full_name");
                            String email = rs.getString("email");
                            String major = rs.getString("major");
                            Timestamp createdAt = rs.getTimestamp("created_at");
                %>
                <tr>
                    <td><%= id%></td>
                    <td><%= studentCode%></td>
                    <td><%= fullName%></td>
                    <td><%= email != null ? email : "N/A"%></td>
                    <td><%= major != null ? major : "N/A"%></td>
                    <td><%= createdAt%></td>
                    <td>
                        <a href="edit_student.jsp?id=<%= id%>" class="action-link">✏️ Edit</a>
                        <a href="delete_student.jsp?id=<%= id%>" 
                           class="action-link delete-link"
                           onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                    </td>
                </tr>
                <%
                        }
                    } catch (ClassNotFoundException e) {
                        out.println("<tr><td colspan='7'><div class='message error'>Error: JDBC Driver not found!</div></td></tr>");
                        e.printStackTrace();
                    } catch (SQLException e) {
                        out.println("<tr><td colspan='7'><div class='message error'>Database Error: " + e.getMessage() + "</div></td></tr>");
                        e.printStackTrace();
                    } finally {
                        // Close resources properly
                        try {
                            if (rs != null) {
                                rs.close();
                            }
                            if (pstmt != null) { // Close PreparedStatement instead of Statement
                                pstmt.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </tbody>
        </table>
    </body>
</html>