package com.mclaren.poc.dao.impl;

import org.neo4j.helpers.collection.IteratorUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mclaren.poc.dao.CypherExecutor;
import com.mclaren.poc.pojo.DataPOJO;

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
				cypher.query("START bp = node(*) WHERE bp.name =~ {1} AND bp.action = 'search' RETURN DISTINCT bp.name as bp  ", map("1", "(?i).*" + query + ".*")));

		/*return IteratorUtil.asCollection(
				cypher.query("START bp = node(*) WHERE bp.name =~ {1} RETURN DISTINCT bp.name as bp  ", map("1", "(?i).*" + query + ".*")));
*/
	}

	@SuppressWarnings("unchecked")
	public DataPOJO findOrg(String query) {
	
		Iterator<Map<String, Object>> result = cypher
				.query("START n=node(*) where n.name={1} MATCH (n)-[r]->(m) RETURN n.name,m.name", map("1", query));

		System.out.println(">>>>>>>>>>>>>>" + result);
		List nodes = new ArrayList();
		List rels = new ArrayList();
		int i = 0;
		int j = 0;
		while (result.hasNext()) {
			Map<String, Object> row = result.next();
			Map<String, Object> actorsource = (map("name", row.get("n.name")));
			Map<String, Object> targetactorsource = (map("name", row.get("m.name")));
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
		DataPOJO dp = new DataPOJO();
		dp.setName(query);
		dp.setChildren(rels);
		System.out.println("GSON DATA " + gson.toJson(dp));
		return dp;
	}

	

}
