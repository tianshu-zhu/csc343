import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;

public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
    		connection = DriverManager.getConnection(url, username, password);
            PreparedStatement ps = connection.prepareStatement("SET SEARCH_PATH to parlgov;");
            ps.executeUpdate();
    		return true;
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception." + "<Message>:" + se.getMessage());
    		return false;
    	}
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            return true;
        }
        catch (SQLException se) {
            System.err.println("SQL Exception." + "<Message>:" + se.getMessage());
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        return null;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        // initialize some variables
        List<Integer> similarPresidentIds = new ArrayList<>();
        Connection connection = this.connection;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        ResultSet infos = null;
        ResultSet allinfos = null;

        try {
            Class.forName("org.postgresql.Driver");
        }
        catch (ClassNotFoundException e) {
            System.out.println("Failed to find the JDBC driver");
        }

        try {
            // get information of given president
            String queryString1 = "select comment || ' ' || description as info " +
                "from politician_president where id = ?";
            ps1 = connection.prepareStatement(queryString1);
            ps1.setInt(1, politicianName);
            infos = ps1.executeQuery();
            infos.next();
            String this_info = infos.getString("info");

            // get information of all other presidents and compare similarities
            String queryString2 = "select id, comment || ' ' || description as info " +
                "from politician_president where id != ?";
            ps2 = connection.prepareStatement(queryString2);
            ps2.setInt(1, politicianName);
            allinfos = ps2.executeQuery();
            while (allinfos.next()) {
                int id = allinfos.getInt("id");
                String that_info = allinfos.getString("info");
                if(similarity(this_info, that_info) >= threshold) {
                    similarPresidentIds.add(id);
                }
            }

        } catch (SQLException se) {
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
        }
        return similarPresidentIds;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
        try {
            // q1
            Assignment2 assignment2 = new Assignment2();
            String url = "jdbc:postgresql://localhost:5432/csc343h-zhutians";
            String username = "zhutians";
            String password = "";
            Boolean connected = assignment2.connectDB(url, username, password);
            System.out.println(connected);

            //q4
            List<Integer> array = assignment2.findSimilarPoliticians(148, (float)0.9);
            System.out.println(array);

            // q2
            Boolean disconnected = assignment2.disconnectDB();
            System.out.println(disconnected);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

}
