package com.mclaren.poc.dao.impl;

import org.neo4j.helpers.collection.IteratorUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mclaren.poc.dao.CypherExecutor;
import com.mclaren.poc.pojo.DataPOJO;
import com.mclaren.poc.pojo.MappingDataPOJO;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.*;

import static org.neo4j.helpers.collection.MapUtil.map;

public class ScreenServiceDAO{

	private final CypherExecutor cypher;
	private Gson gson = new GsonBuilder().disableHtmlEscaping().create();

	public ScreenServiceDAO(String uri) {
		cypher = createCypherExecutor(uri);
	}

	private CypherExecutor createCypherExecutor(String uri) {
		try {
			String auth = new URL(uri).getUserInfo();
			if (auth != null) {
				String[] parts = auth.split(":");
				return new JdbcCypherExecutor(uri, parts[0], parts[1]);

			}
			return new JdbcCypherExecutor(uri);
		} catch (MalformedURLException e) {
			throw new IllegalArgumentException("Invalid Neo4j-ServerURL " + uri);
		}
	}

	@SuppressWarnings("unchecked")
	public Iterable<Map<String, Object>> search(String query) {
		if (query == null || query.trim().isEmpty())
			return Collections.emptyList();		
		System.out.println("Returns Search results");
		return IteratorUtil.asCollection(
				cypher.query("START bp = node(*) WHERE bp.name =~ {1} RETURN DISTINCT bp.name as bp  ", map("1", "(?i).*" + query + ".*")));

	}
		
		@SuppressWarnings("unchecked")
		public Iterable<Map<String, Object>> getAllRelations() {
			
			System.out.println("Returns Relations");
			return IteratorUtil.asCollection(
					cypher.queryWithoutparams("MATCH (n:RELATIONS) Return n.name as n"));

		}

	@SuppressWarnings("unchecked")
	public MappingDataPOJO findNodesData(String query) {
		Iterator<Map<String, Object>> result = cypher
				.query(" MATCH (n)-[r]->(m) where n.name={1} RETURN n.name,n.id, m.name, m.id", map("1", query));
		List nodes = new ArrayList();
		List rels = new ArrayList();
		
		while (result.hasNext()) {
			Map<String, Object> row = result.next();
			Map<String, Object> actorsource = (map("name", row.get("n.name"),"rel", row.get("n.id")));
			Map<String, Object> targetactorsource = (map("name", row.get("m.name"),"rel", row.get("m.id")));
			if (row.get("n.name") != null) {
				int source = nodes.indexOf(actorsource);
				if (source == -1) {
					nodes.add(actorsource);
				}
			}
			if (row.get("m.name") != null) {
				int target = rels.indexOf(targetactorsource);
				if (target == -1) {
					rels.add(targetactorsource);
				}
			}
			System.out.println("children" + rels);
		}
		MappingDataPOJO dp = new MappingDataPOJO();
		dp.setName(query);
		dp.setRel("eks");
		dp.setChildren(rels);
		System.out.println("GSON DATA " + gson.toJson(dp));
		return dp;
	}

	@SuppressWarnings("unchecked")
	public MappingDataPOJO findSubSelectedSyatem(String query,List<String> list) {
		
		List nodes = new ArrayList();
		List rels = new ArrayList();
		for(String res:list){

	         Iterator<Map<String, Object>> result = cypher
					.query("MATCH (n)-[*1]-(m)where n.name={1} AND m.id=~{2} RETURN n.name,n.id, m.name, m.id", map("1", query,"2","(?i).*" + res + ".*"));

			String relation=null;
			
			while (result.hasNext()) {
				Map<String, Object> row = result.next();
				Map<String, Object> actorsource = (map("name", row.get("n.name"),"rel", row.get("n.id")));
				Map<String, Object> targetactorsource = (map("name", row.get("m.name"),"rel", row.get("m.id")));
				if (row.get("n.name") != null) {
					int source = nodes.indexOf(actorsource);
					if (source == -1) {
						nodes.add(actorsource);
					}
				}
				if (row.get("m.name") != null) {
					int target = rels.indexOf(targetactorsource);
					if (target == -1) {
						rels.add(targetactorsource);
					}
				}
				System.out.println("children" + rels);
			}
			
		}
		
		MappingDataPOJO dp = new MappingDataPOJO();
		dp.setName(query);
		dp.setRel("test");
		dp.setChildren(rels);
		System.out.println("GSON DATA " + gson.toJson(dp));
		return dp;
	}


}
