import pandas as pd
import pymongo
import json

# Load Excel spreadsheet into a Pandas dataframe
df = pd.read_excel('example.xlsx')

# Convert the dataframe to a dictionary with the first row as keys
data = df.to_dict(orient='list')
keys = data.keys()

# Create a list of dictionaries where each dictionary represents a row of data
rows = []
for i in range(len(df)):
    row = {}
    for key in keys:
        row[key] = data[key][i]
    rows.append(row)

# Convert the list of dictionaries to a JSON document
json_data = json.dumps(rows)

# Save the JSON document to a file
with open('example.json', 'w') as f:
    f.write(json_data)

# Load the JSON document
with open('example.json') as f:
    json_data = json.load(f)

# Connect to the MongoDB database
client = pymongo.MongoClient('mongodb://localhost:27017/')
db = client['example_database']
collection = db['example_collection']

# Insert the JSON data into the collection
collection.insert_many(json_data)
