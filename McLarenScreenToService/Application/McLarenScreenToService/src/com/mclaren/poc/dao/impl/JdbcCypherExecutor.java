package com.mclaren.poc.dao.impl;

import java.sql.*;
import java.util.*;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import com.mclaren.poc.constants.Constants;
import com.mclaren.poc.dao.CypherExecutor;


public class JdbcCypherExecutor implements CypherExecutor {

     Connection conn;

	Context ctx = null;
	
	Statement stmt = null;
	ResultSet rs = null;
	DataSource ds=null;
		

    public JdbcCypherExecutor(String url) {
        this(url,null,null);
    }
    public JdbcCypherExecutor(String url,String username, String password) {
        try {
        	try {
				Class.forName(Constants.NEO4JDRIVER);
				System.out.println("Connecting to Neo4j Driver");
			} catch (ClassNotFoundException e) {

				e.printStackTrace();
			}
            conn = DriverManager.getConnection(Constants.URL,Constants.USERNAME,Constants.PASSWORD);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    /*public  JdbcCypherExecutor() {
        try {
        	
        	 Context initContext = new InitialContext();
             Context envContext  = (Context)initContext.lookup("java:/comp/env");
             DataSource ds = (DataSource)envContext.lookup("jdbc/test");
             conn = ds.getConnection();
        		System.out.println("SUCCESS Connecting to Neo4j Driver");
        		
        	} catch (SQLException e) {
            throw new RuntimeException(e);
        } catch (NamingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    }*/
    
    
    
    
    @Override
    public Iterator<Map<String, Object>> query(String query, Map<String, Object> params) {
        try {
            final PreparedStatement statement = conn.prepareStatement(query);
            setParameters(statement, params);
            final ResultSet result = statement.executeQuery();
            return new Iterator<Map<String, Object>>() {
             boolean hasNext = result.next();
             public List<String> columns;
                @Override
                public boolean hasNext() {
                    return hasNext;
                }

                private List<String> getColumns() throws SQLException {
                    if (columns != null) return columns;
                    ResultSetMetaData metaData = result.getMetaData();
                    int count = metaData.getColumnCount();
                    List<String> cols = new ArrayList<>(count);
                    for (int i = 1; i <= count; i++) cols.add(metaData.getColumnName(i));
                    return columns = cols;
                }

                @Override
                public Map<String, Object> next() {
                    try {
                        if (hasNext) {
                            Map<String, Object> map = new LinkedHashMap<>();
                            for (String col : getColumns()) map.put(col, result.getObject(col));
                            hasNext = result.next();
                            if (!hasNext) {
                                result.close();
                                statement.close();
                            }
                            return map;
                        } else throw new NoSuchElementException();
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                }

                @Override
                public void remove() {
                }
            };
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    
    @Override
    public Iterator<Map<String, Object>> queryWithoutparams(String query) {
        try {
            final PreparedStatement statement = conn.prepareStatement(query);
          //  setParameters(statement, params);
            final ResultSet result = statement.executeQuery();
            return new Iterator<Map<String, Object>>() {

                boolean hasNext = result.next();
                public List<String> columns;

                @Override
                public boolean hasNext() {
                    return hasNext;
                }

                private List<String> getColumns() throws SQLException {
                    if (columns != null) return columns;
                    ResultSetMetaData metaData = result.getMetaData();
                    int count = metaData.getColumnCount();
                    List<String> cols = new ArrayList<>(count);
                    for (int i = 1; i <= count; i++) cols.add(metaData.getColumnName(i));
                    return columns = cols;
                }

                @Override
                public Map<String, Object> next() {
                    try {
                        if (hasNext) {
                            Map<String, Object> map = new LinkedHashMap<>();
                            for (String col : getColumns()) map.put(col, result.getObject(col));
                            hasNext = result.next();
                            if (!hasNext) {
                                result.close();
                                statement.close();
                            }
                            return map;
                        } else throw new NoSuchElementException();
                    } catch (SQLException e) {
                        throw new RuntimeException(e);
                    }
                }

                @Override
                public void remove() {
                }
            };
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private void setParameters(PreparedStatement statement, Map<String, Object> params) throws SQLException {
        for (Map.Entry<String, Object> entry : params.entrySet()) {
            int index = Integer.parseInt(entry.getKey());
            statement.setObject(index, entry.getValue());
        }
    }
}
