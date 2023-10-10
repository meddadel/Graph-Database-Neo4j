# EXISTS predicat function
# 1. Les Movies dont le genre est sport et qui possède une certification TV-PG
# avec index : 5 ms     sans index: 9 ms.
MATCH p = (a:Movie)-[:belongs_to_genre]-(g:Genre{name:'sport'})
WHERE EXISTS((a)-->(:Age_certification{age_certif:'TV-PG'}))
return a.title LIMIT 50





# Data and Topology
# 2. Graph des Acteur qui se connaissent dont le nom contient  B
# avec index : 111 ms.   sans index : 132 ms.
MATCH p = (p1:Actor)-[:knows]-(p2:Actor)
WHERE ALL(path in nodes(p) WHERE path.name CONTAINS 'B')
return p

# Graph des Acteur qui se connaissent dont le nom contient B et ont le meme nom
# avec index:88 ms.  sans index :55 ms.
MATCH p = (p1:Actor)-[:knows]-(p2:Actor)
WHERE ALL(path IN nodes(p) WHERE path.name CONTAINS 'A') AND p1.name = p2.name
RETURN p



# Negative filter
# 4. Les Movies non sportifs
# avec index: 7 ms.    sans index: 10 ms,
MATCH (a:Movie) - [:belongs_to_genre] - (g:Genre)
WHERE NOT EXISTS((a)--(:Genre{name:'sport'}))
RETURN a







# OPTIONAL MATCH
# 5. TOP 5 des acteurs ayant joué dans le plus de Movies
# avec index:16 ms.    snas index: 55 ms.
MATCH (p:Actor)
OPTIONAL MATCH (p)-[:Has_Role]->(a:Movie)
WITH p, COUNT(a) AS nb_Movie
RETURN p.name, nb_Movie
ORDER BY nb_Movie DESC
LIMIT 5

# use WITH
# 5. Cette requête recherche des films du genre "action" ainsi que leurs acteurs associés en utilisant la clause WITH pour passer les résultats intermédiaires entre les différentes parties de la requête.
# avec index :17 ms.      sans index:14 ms.

MATCH (genre:Genre{name: 'action'})<-[:belongs_to_genre]-(movie:Movie)
WITH genre, movie
MATCH (actor:Actor)-[:Has_Role]->(movie)
RETURN genre.name AS Genre, movie.title AS Movie, COLLECT(actor.name) AS Actors
LIMIT 10





# REDUCE, UNWIND and COLLECT
# 6. la requête calcule le score IMDb moyen des films pour chaque 
# genre de film et présente les résultats regroupés par genre.
# avec index: 80ms      sans index: 1000 ms 
MATCH (genre:Genre)<-[:belongs_to_genre]-(movie:Movie)
WITH genre, COLLECT(movie) AS movies
UNWIND movies AS movie
WITH genre, movies, REDUCE(total = 0.0, m IN movies | 
    CASE 
        WHEN m.imdb_score IS NOT NULL THEN total + toFloat(m.imdb_score) 
        ELSE total 
    END) AS totalIMDbScore
RETURN genre.name AS Genre, 
       CASE 
           WHEN SIZE(movies) > 0 THEN totalIMDbScore / SIZE(movies) 
           ELSE 0.0 
       END AS AverageIMDbScore
ORDER BY AverageIMDbScore DESC




# UNWIND and COLLECT
# 8. Pour les années dans la liste year, dire si il y a un Movie de cette année
# avec index :7 ms.     sans index 10 ms.
WITH [2000, 1999] as year
UNWIND year as y
WITH y
MATCH (a:Movie)
return y ,(y IN collect(toInteger(a.release_year))) as answer









# shortestPath
# 9. la requête permet de trouver le chemin le plus court entre 
# deux acteurs dont les noms commencent par "A" dans le graphique de données.
# avec index: 21 ms.     sans index: 20ms.

MATCH (start:Actor)
WHERE start.name STARTS WITH 'A'
WITH start
MATCH (end:Actor)
WHERE end.name STARTS WITH 'A' AND end <> start
MATCH path = shortestPath((start)-[:knows*]-(end))
RETURN path

# shortestPath
# 10. la requête trouve le chemin le plus court entre deux films dont 
# les titres commencent par des préfixes spécifiques en se basant sur des acteurs communs
# avec index: 39 ms.     sans index:  92 ms.

MATCH (startMovie:Movie)
WHERE startMovie.title STARTS WITH "D"
MATCH (endMovie:Movie)
WHERE endMovie.title STARTS WITH "Y"
MATCH path = shortestPath((startMovie)-[:ACTED_IN_WITH*]-(endMovie))
RETURN path



# CALL and UNION
# 11. Les acteurs ayant le name qui commence par A ou B
# avec index: 200 ms.     sans index:  198 ms.

CALL {
  MATCH (a:Actor)
  WHERE a.name STARTS WITH 'A'
  RETURN a.name AS name
  LIMIT 5

  UNION

  MATCH (a:Actor)
  WHERE a.name STARTS WITH 'B'
  RETURN a.name AS name
  LIMIT 5
}
RETURN name




# Obtenir les Movies les plus similaires en utilisant le Genre
# 12. get most similar Movie using Genre


CALL gds.graph.project(
    'myGraph',
    ['Genre', 'Movie'],
    {
        has_genre: {
        }
    }
);

# avec index: 52 ms.     sans index:  92 ms.
CALL gds.nodeSimilarity.stream('myGraph')
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).title AS Movie1, gds.util.asNode(node2).title AS Movie2, similarity
ORDER BY similarity DESC, Movie1, Movie2;


# Cette requête permet essentiellement de trouver des paires de films dans mon graph
# et de calculer leur similarité de Jaccard en fonction des genres partagés. 
# Ensuite, elle répertorie ces paires, affiche les titres des films et leurs scores de similarité, 
# le tout trié par similarité. La procédure gds.nodeSimilarity.stream est un moyen de mesurer à 
# quel point les films sont similaires les uns aux autres en fonction de leurs relations de genre.
# avec index: 34ms     sans index:  92 ms.

// Project your graph
CALL gds.graph.project(
  'myGraph2',
  ['Movie', 'Genre'],
  {
    BELONGS_TO_GENRE: {
      type: 'belongs_to_genre',
      orientation: 'UNDIRECTED'
    }
  }
);
 
# avec index: 34 ms.     sans index:  45 ms.
// Calculate node similarity
CALL gds.nodeSimilarity.stream('myGraph2')
YIELD node1, node2, similarity

// Get node properties
WITH gds.util.asNode(node1) AS movie1, gds.util.asNode(node2) AS movie2, similarity
RETURN movie1.title AS Movie1, movie2.title AS Movie2, similarity
ORDER BY similarity DESC, Movie1, Movie2;




# 13. Recommendation d'Movie similaire à Lupin the Third
# avec index: 243 ms.     sans index:  896 ms.

MATCH (a:Movie {title:'Lupin the Third'} )-[*2]-(b:Movie)
WHERE a <> b
WITH DISTINCT a,b
RETURN a.title as title, b.title as recommendation, gds.alpha.linkprediction.adamicAdar(a, b) AS score
ORDER BY score DESC
LIMIT 10