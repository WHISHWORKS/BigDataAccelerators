package com.mclaren.poc.pojo;

import java.util.List;

public class DataPOJO {
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	private String name;
	
	
	public List<String> getChildren() {
		return children;
	}
	public void setChildren(List<String> child) {
		this.children = child;
	}
	private List<String> children;

}
