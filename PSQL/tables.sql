DROP DATABASE IF EXISTS bdspe;

DROP TABLE IF EXISTS Actors cascade;
DROP TABLE IF EXISTS Movies cascade;
DROP TABLE IF EXISTS Country cascade;
DROP TABLE IF EXISTS Genres cascade;
DROP TABLE IF EXISTS Roles cascade;
DROP TABLE IF EXISTS Rating cascade;
DROP TABLE IF EXISTS Casted cascade;
DROP TABLE IF EXISTS MovieGenre cascade;


CREATE TABLE Actors (
    id_Actors INTEGER NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_Actors)
);

CREATE INDEX Actors
ON Actors USING HASH(id_Actors);


CREATE TABLE Movies (
    id_Movies VARCHAR(10) NOT NULL,
    title VARCHAR(100) NOT NULL,
    show_type VARCHAR,
    seasons NUMERIC,
    runtime INTEGER NOT NULL,
    release_year INTEGER NOT NULL,
    age_cert VARCHAR(10),
    descr TEXT,
    PRIMARY KEY (id_Movies)
);

CREATE INDEX Movies
ON Movies USING HASH(id_Movies);


CREATE TABLE Rating (
    id_Movies VARCHAR(10) NOT NULL,
    imdb_id VARCHAR(10),
    imdb_score NUMERIC(3, 1),
    imdb_votes NUMERIC,
    tmdb_popularity NUMERIC(7, 3),
    tmdb_score NUMERIC(3, 1),
    UNIQUE (id_Movies, imdb_id),
    FOREIGN KEY (id_Movies) REFERENCES Movies (id_Movies)
);



CREATE TABLE Genres (
    genre VARCHAR(20),
    PRIMARY KEY (genre)
);

CREATE TABLE Roles (
    id_role VARCHAR(10),
    PRIMARY KEY (id_role)
);

CREATE TABLE Casted (
    id INTEGER PRIMARY KEY,
    id_Movies VARCHAR(10) NOT NULL,
    id_Actors INTEGER NOT NULL,
    id_role VARCHAR(10) NOT NULL,
    Voice VARCHAR(100),
    FOREIGN KEY (id_Movies) REFERENCES Movies (id_Movies),
    FOREIGN KEY (id_Actors) REFERENCES Actors (id_Actors),
    FOREIGN KEY (id_role) REFERENCES Roles (id_role)
);

CREATE TABLE Country (
    id_country VARCHAR(2),
    PRIMARY KEY (id_country)
);

CREATE TABLE MovieGenre (
    id_Movies VARCHAR(10) NOT NULL,
    genre VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_Movies, genre),
    FOREIGN KEY (id_Movies) REFERENCES Movies (id_Movies),
    FOREIGN KEY (genre) REFERENCES Genres (genre)
);




