package com.mclaren.poc.servlets;

import java.io.IOException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mclaren.poc.dao.impl.ScreenServiceDAO;
import com.mclaren.poc.utils.Util;
/**
 * Servlet implementation class SreenServlet
 */

@WebServlet("/test")
public class SreenServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private Gson gson = new GsonBuilder().disableHtmlEscaping().create();
    ScreenServiceDAO service;
    /**
     * @see HttpServlet#HttpServlet()
     */
	
	public void init(ServletConfig config) throws ServletException {
	   service = new ScreenServiceDAO(Util.getNeo4jUrl());
	}
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("Executed Succesfully");
	    response.setContentType("application/json");
	    System.out.println("SearchValue" + request.getParameter("searchValue")); 
		String action = request.getParameter("action");
		if(action != null && action.equalsIgnoreCase("1")){
			System.out.println("Search Data"+gson.toJson(service.search(request.getParameter("searchValue"))));
			response.getWriter().write(gson.toJson(service.search(request.getParameter("searchValue"))));
		} if(action != null && action.equalsIgnoreCase("2")){
			System.out.println("Search Data"+gson.toJson(service.findNodesData(request.getParameter("searchValue"))));
			response.getWriter().write(gson.toJson(service.findNodesData(request.getParameter("searchValue"))));
		}if(action != null && action.equalsIgnoreCase("3")){
			List<String> list = new ArrayList<String>();
			list.add("TS");
			System.out.println("Search Data"+gson.toJson(service.findSubSelectedSyatem(request.getParameter("searchValue"),list)));
			response.getWriter().write(gson.toJson(service.findSubSelectedSyatem(request.getParameter("searchValue"),list)));
		}if(action != null && action.equalsIgnoreCase("4")){
			
			System.out.println("Get all the Relations"+ gson.toJson(service.getAllRelations()));
			response.getWriter().write(gson.toJson(service.getAllRelations()));
		}if(action != null && action.equalsIgnoreCase("5")){
			List<String> myList = new ArrayList<String>(Arrays.asList(request.getParameter("searchItem").split(",")));
			System.out.println("Search Checked Data"+request.getParameter("searchValue"));
			System.out.println("Search Data"+gson.toJson(service.findSubSelectedSyatem(request.getParameter("searchValue"),myList)));
			response.getWriter().write(gson.toJson(service.findSubSelectedSyatem(request.getParameter("searchValue"),myList)));
		}
	}
}
