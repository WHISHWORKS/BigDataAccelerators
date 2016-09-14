package com.mclaren.poc.pojo;

import java.util.List;

public class MappingDataPOJO {
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	private String name;
	public String getRel() {
		return rel;
	}
	public void setRel(String rel) {
		this.rel = rel;
	}
	private String rel;
	
	
	public List<String> getChildren() {
		return children;
	}
	public void setChildren(List<String> child) {
		this.children = child;
	}
	private List<String> children;

}
