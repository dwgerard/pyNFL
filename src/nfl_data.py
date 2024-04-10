import pandas as pd
import json

#global ranks_data
with open('data/ranks.json', 'r') as ranks_file:
    ranks_json = json.load(ranks_file)
print(ranks_json)
with open('data/Teams_NFL.json', 'r') as Teams_NFL_file:
    Teams_NFL_json = json.load(Teams_NFL_file)
print(Teams_NFL_json)
ranks_data = pd.json_normalize(ranks_json) #, record_path=['offense','defense'])
ranks_data.set_index('rank',inplace=True)
print(ranks_data)
power_data = pd.read_excel('data/NFLFut22.xlsx')
power_data.set_index('Team',inplace=True)
print(power_data)

class Team:
    def __init__(self, name):
        self.name = name
        offrate = power_data.at[name,'Off']
        defrate = power_data.at[name,'Def']
        self.rating_off = power_data.at[name,'Off']
        self.rating_def = power_data.at[name,'Def']
        self.points_off = ranks_data.at['offense',offrate.lower()]
        self.points_def = ranks_data.at['defense',defrate.lower()]   