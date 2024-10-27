# pip install error pip3 install
import mysql.connector
import pandas as pd
import numpy as np

# Step 1: Establish connection to MySQL database
connection = mysql.connector.connect(
    host='localhost',      # Replace with your host
    user='root',            # Your MySQL username
    password='your_password',    # Your MySQL password
    database='netflix_db'   # Replace with your database name
)

cursor = connection.cursor()

# Step 2: Read the CSV file using pandas
df = pd.read_csv('C:/Users/user1/Desktop/SQL/netflix/netflix_titles.csv') # Replace with your csv file location 

# Step 3: Replace NaN with None (Python's NULL equivalent)
df = df.replace({np.nan: None})

# Step 4: Convert 'date_added' to datetime format if not None
def parse_date(date_str):
    if pd.isnull(date_str):
        return None  # Keep as None for MySQL NULL handling
    try:
        return pd.to_datetime(date_str).date()  # Extract just the date part
    except Exception as e:
        print(f"Error parsing date: {date_str} - {e}")
        return None

df['date_added'] = df['date_added'].apply(parse_date)

# Step 5: Define the SQL query to insert data into the netflix table
sql = """
INSERT INTO netflix (show_id, type, title, director, casts, country, 
                     date_added, release_year, rating, duration, 
                     listed_in, description) 
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

# Step 6: Iterate through the DataFrame and insert each row into the table
for index, row in df.iterrows():
    cursor.execute(sql, tuple(row))

# Step 7: Commit the changes and close the connection
connection.commit()
cursor.close()
connection.close()

print("Data imported successfully!")
