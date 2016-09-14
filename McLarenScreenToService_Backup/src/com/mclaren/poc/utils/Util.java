package com.mclaren.poc.utils;

public class Util {
    public static final String DEFAULT_URL = "http://localhost:7474";
  
    public static String getNeo4jUrl() {
        String urlVar = System.getenv("NEO4J_REST_URL");
        if (urlVar==null) urlVar = "NEO4J_URL";
        String url =  System.getenv(urlVar);
        if(url == null || url.isEmpty()) {
            return DEFAULT_URL;
        }
        return url;
    }
}
