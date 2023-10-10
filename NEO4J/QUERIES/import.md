
// creation de movie 
LOAD CSV WITH HEADERS FROM "file:/titles.csv" as titles

CREATE (movie:Movie{id:titles.id, title:titles.title, type:titles.type,
movie_description:titles.movie_description,release_year:toInteger(titles.release_year),runtime:toInteger(titles.runtime),seasons:toFloat(titles.seasons),imdb_id:titles.imdb_id,imdb_score:titles.imdb_score,imdb_votes:titles.imdb_votes,tmdb_popularity:titles.tmdb_popularity,tmdb_score:titles.tmdb_score})

WITH movie, split(substring(titles.genres, 1, size(titles.genres)-2), ",") AS genres //with genres where genres[0] <> ""
UNWIND RANGE(0,SIZE(genres)-1) AS i
// creation de genre
MERGE (genre:Genre{name:trim(genres[i])})
MERGE (movie) - [:belongs_to_genre] -> (genre);

// // Supprimer les guillemets
MERGE (g:Genre)
set g.name = substring(g.name, 1, size(g.name)-2)
return g;


// creation de Country
LOAD CSV WITH HEADERS FROM "file:/titles.csv" as titles
MATCH (movie:Movie{id:titles.id})
with movie, split(substring(titles.production_countries, 1, size(titles.production_countries)-2), ",") AS countries
UNWIND RANGE(0,SIZE(countries)-1) AS i
MERGE (country:Country{name:trim(countries[i])})
MERGE (country) <-[from:from]- (movie);

// remove quote
MERGE (c:Country)
set c.name = substring(c.name, 1, size(c.name)-2)
return c;


// add Age_certification
LOAD CSV WITH HEADERS FROM "file:/titles.csv" as titles with titles where titles.age_certification is not null
MATCH (movie:Movie{id:titles.id})
MERGE (age:Age_certification{age_certif:titles.age_certification})
MERGE (age) <-[:holds_certification]- (movie);


// Création de Actor
:auto LOAD CSV WITH HEADERS FROM "file:/credits.csv" as credits
MERGE (movie:Movie{id:credits.id})
MERGE (actor:Actor{actor:toInteger(credits.person_id), name:credits.name});



// Création de la relation Has_Role
:auto LOAD CSV WITH HEADERS FROM "file:/credits.csv" as credits with credits where credits.character is not null
MATCH (movie:Movie{id:credits.id})
MERGE (actor:Actor{actor:toInteger(credits.person_id)})
MERGE (actor) -[role:Has_Role{name:credits.character}]-> (movie);

// Création de la relation has_directed
:auto LOAD CSV WITH HEADERS FROM "file:/credits.csv" as credits with credits where credits.role = "DIRECTOR"
MATCH (movie:Movie{id:credits.id})
MERGE (actor:Actor{actor:toInteger(credits.person_id)})
MERGE (actor) -[r:has_directed]-> (movie);


MATCH m1 = (a1:Movie) - [:Has_Role] - (actor1:Actor)
MATCH m2 = (actor2:Actor)  - [:Has_Role] - (a2:Movie{id:a1.id})
WHERE actor1.actor <> actor2.actor
MERGE (actor1) - [:knows] - (actor2);

// Création de la relation ACTED_IN_WITH
MATCH (a1:Actor)-[:Has_Role]->(m:Movie)<-[:Has_Role]-(a2:Actor)
CREATE (a1)-[:ACTED_IN_WITH]->(a2);

// Index creation

CREATE INDEX actor FOR (n:Actor) ON (n.name);
CREATE INDEX movies FOR (n:Movie) ON (n.title);
CREATE INDEX genres FOR (n:Genre) ON (n.name);
CREATE INDEX country FOR (n:Country) ON (n.name);
