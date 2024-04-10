import json
import os
global ranks_data
print(os.getcwd())
with open('data/ranks.json', 'r') as ranks_file:
    ranks_data = json.load(ranks_file)
print(ranks_data)
print(ranks_data['offense'])
