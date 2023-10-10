# pip3 install neo4j-driver
# python3 project.py

import time
from neo4j import GraphDatabase
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# Connect to the database
uri = "bolt://localhost:7687"
username = "username"
password = "password"

driver = GraphDatabase.driver(uri, auth=(username, password))


#Creating Nodes and Relationships
with driver.session() as session:
    session.write_transaction(create_node, "Movie", {"title": "Inception"})
    session.write_transaction(create_node, "Actor", {"name": "Leonardo DiCaprio"})
    session.write_transaction(create_relationship, "Leonardo DiCaprio", "ACTED_IN", "Inception")


# Running Queries
with driver.session() as session:
    result = session.run("MATCH (m:Movie) RETURN m.title AS title")
    for record in result:
        print(record["title"])


# Updating Data

with driver.session() as session:
    session.write_transaction(update_node_properties, "Movie", {"title": "Inception"}, {"year": 2010})

# Deleting Data  
with driver.session() as session:
    session.write_transaction(delete_node, "Movie", {"title": "Inception"})


# Advanced Queries

with driver.session() as session:
    result = session.run(
        "MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(d:Director) RETURN a, m, d"
    )
    for record in result:
        print(record["a"]["name"], "acted in", record["m"]["title"], "directed by", record["d"]["name"])

# Retrieve Data from Neo4j

from neo4j import GraphDatabase

def get_imdb_scores(driver):
    with driver.session() as session:
        result = session.run("MATCH (m:Movie) RETURN m.title AS title, m.imdb_score AS imdb_score")
        return result.data()


# Data Manipulation with Pandas
import pandas as pd

neo4j_data = get_imdb_scores(driver)
df = pd.DataFrame(neo4j_data)        


#Data Analysis with NumPy

import numpy as np

average_imdb_score = np.mean(df['imdb_score'])


# Data Visualization with Matplotlib

import matplotlib.pyplot as plt

# Create a histogram
plt.hist(df['imdb_score'], bins=20, color='blue', edgecolor='black')
plt.xlabel('IMDb Score')
plt.ylabel('Number of Movies')
plt.title('Distribution of IMDb Scores')
plt.show()