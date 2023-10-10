
/*
1. Les Movies dont le genre est sport et qui possède une certification TV-PG
2,535 ms
*/

SELECT M.id_Movies
FROM Movies M
JOIN OfGenre OG ON M.id_Movies = OG.id_Movies
WHERE OG.genre = 'sport'
  AND M.age_cert = 'TV-PG';

/*

Les Movies non sportifs
10,608 ms
*/

 SELECT Movies.title
FROM Movies
WHERE id_Movies NOT IN (
    SELECT id_Movies
    FROM OfGenre
    WHERE genre = 'sport'
);



/*
TOP 5 des acteurs ayant joué dans le plus de Movies
11,287 ms
*/

SELECT A.name, COUNT(C.id_Movies) AS nombre_de_films_joues
FROM Actors A
JOIN Casted C ON A.id_Actors = C.id_Actors
GROUP BY A.name
ORDER BY nombre_de_films_joues DESC
LIMIT 5;






/*
requête recherche des films du genre "action" ainsi que leurs acteurs associés
5,368 ms
*/
SELECT M.title AS movie_title, A.name AS actor_name
FROM Movies M
JOIN Casted C ON M.id_Movies = C.id_Movies
JOIN Actors A ON C.id_Actors = A.id_Actors
JOIN OfGenre OG ON M.id_Movies = OG.id_Movies
WHERE OG.genre = 'action'
ORDER BY M.title, A.name;





/*
la requête calcule le score IMDb moyen des films pour chaque 
 genre de film et présente les résultats regroupés par genre.
11,116 ms
*/
SELECT OG.genre AS genre,
       AVG(R.imdb_score) AS score_moyen_imdb
FROM OfGenre OG
JOIN Movies M ON OG.id_Movies = M.id_Movies
LEFT JOIN Rating R ON M.id_Movies = R.id_Movies
GROUP BY OG.genre
ORDER BY score_moyen_imdb DESC;



/*

Pour les années dans la liste year, dire si il y a un Movie de cette année
3,613 ms
*/

SELECT year AS Année,
       CASE WHEN EXISTS (
           SELECT 1
           FROM Movies
           WHERE release_year = year
       ) THEN 'Oui' ELSE 'Non' END AS Existe_Movie
FROM (
    SELECT 2000 AS year
    UNION
    SELECT 1999 AS year
) AS Years;





/*Creer la table de Knows
*/
CREATE TEMP TABLE knows(ActorStart VARCHAR(50), ActorTo VARCHAR(50));
WITH knows(ActorStart,ActorTo) AS
(SELECT Act1.name, Act2.name
FROM (Actors AS A1 NATURAL JOIN Casted c1) AS Act1,
    (Actors AS A2 NATURAL JOIN Casted c2) AS Act2
WHERE Act1.id_Movies = Act2.id_Movies AND Act1.id_Actors <> Act2.id_Actors)
INSERT INTO knows(ActorStart, ActorTo) SELECT ActorStart, ActorTo FROM wknows;
SELECT * FROM knows;

/*Trouver toutes les Actors accessible pour Yohan Lee*/
WITH RECURSIVE knows_actor(ActorStart,ActorTo) AS
(
        SELECT * FROM knows
    UNION
        SELECT k.ActorStart, ka.ActorTo
        FROM knows k, knows_actor ka
        WHERE k.ActorTo = ka.ActorStart
)


SELECT  * FROM knows_actor WHERE ActorStart = 'Yohan Lee' LIMIT 2000;





/*cette requête vise à trouver une chaîne d'acteurs qui se connaissent les uns les autres grâce à la relation "Knows", 
en partant de 'Yohan Lee' et en aboutissant à 'Chika Horikawa'. Elle utilise la récursion pour parcourir le graphe 
et explorer tous les chemins possibles dans la limite spécifiée (2000 itérations). Si un tel chemin existe, 
la requête renverra les détails des acteurs présents dans le chemin*/


WITH RECURSIVE c AS (
        SELECT ActorStart, ActorTo FROM knows
    UNION
        SELECT ActorTo, ActorStart FROM knows
), knows_path AS (
        (SELECT ARRAY[ActorStart, ActorTo]::varchar[] AS path
        FROM c
        WHERE ActorTo = 'Chika Horikawa' LIMIT 2000)
    UNION ALL
        (SELECT c.ActorStart::varchar || p.path
        FROM c
        JOIN knows_path AS p
        ON c.ActorTo = (p.path)[1]
        WHERE c.ActorStart <> ALL (p.path) LIMIT 2000)
)


WITH
  knows_actor AS (
    SELECT
      p1.ActorStart,
      p1.ActorTo
    FROM knows p1
    UNION
    SELECT
      p1.ActorTo,
      p1.ActorStart
    FROM knows p1
  )
SELECT *
FROM knows_actor as ActorStart
INNER JOIN knows_actor ka2 ON ka2.ActorStart = psActorStart.ActorTo
INNER JOIN knows_actor ka3 ON ka3.ActorStart = ka2.ActorTo
WHERE
  psActorStart.ActorStart = 'Yohan Lee' AND
  ka3.ActorTo = 'Chika Horikawa';
