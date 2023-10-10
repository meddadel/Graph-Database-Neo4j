\COPY Actors(id_Actors, name) FROM 'CSV/actors.csv' DELIMITER ',' CSV HEADER;
\COPY Movies(id_Movies, title, show_type, seasons, runtime, release_year, age_cert, descr) FROM 'CSV/movies.csv' DELIMITER ',' CSV HEADER;
\COPY Country(id_country) FROM 'CSV/country.csv' DELIMITER ',' CSV HEADER;
\COPY Genres(genre) FROM 'CSV/genres.csv' DELIMITER ',' CSV HEADER;
\COPY Roles(id_role) FROM 'CSV/roles.csv' DELIMITER ',' CSV HEADER;
\COPY Rating(id_Movies, imdb_id, imdb_score, imdb_votes, tmdb_popularity, tmdb_score) FROM 'CSV/rating.csv' DELIMITER ',' CSV HEADER;
\COPY MovieGenre(id_Movies, genre) FROM 'CSV/movieGenre.csv' DELIMITER ',' CSV HEADER;
\COPY Casted(id_Movies, id_Actors, id_role, voice) FROM 'CSV/casted.csv' DELIMITER ',' CSV HEADER;