package com.mclaren.poc.services;

import static spark.Spark.get;

import java.net.URLDecoder;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mclaren.poc.dao.impl.ScreenServiceDAO;

import spark.Request;
import spark.Response;
import spark.Route;
import spark.servlet.SparkApplication;

public class SalesRouteService implements SparkApplication {

    private Gson gson = new GsonBuilder().disableHtmlEscaping().create();
    private ScreenServiceDAO service;
    public SalesRouteService(ScreenServiceDAO service) {
        this.service = service;
    }

    public void init() {
        get(new Route("/bp/:name") {
            public Object handle(Request request, Response response) {
            	System.out.println("-----------Search Selection------------");
            	System.out.println("Request Parameter--- name--" + request.params("name"));
            	System.out.println(gson.toJson(service.findNodesData(URLDecoder.decode(request.params("name")))));
                return gson.toJson(service.findNodesData(URLDecoder.decode(request.params("name"))));
            }
        });
        get(new Route("/search") {
            public Object handle(Request request, Response response) {
            	System.out.println("------------search-----------");
            	System.out.println("Request Parameter--- q--" + request.queryParams("q"));
            	System.out.println(gson.toJson(service.search(request.queryParams("q"))));
                return gson.toJson(service.search(request.queryParams("q")));
            }
        });
        /*get(new Route("/graph") {
            public Object handle(Request request, Response response) {
                int limit = request.queryParams("limit") != null ? Integer.valueOf(request.queryParams("limit")) : 100;
            	System.out.println("-------------graph---------------");
            	//System.out.println(service.graph(limit));
                System.out.println(gson.toJson(service.graph(limit)));
                return gson.toJson(service.graph(limit));
            }
        });*/
    }
}
