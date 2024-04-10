#import csv
import os
import pandas as pd
#import numpy as np
global power_data
#print(os.getcwd())
power_data = pd.read_excel('data/NFLFut22.xlsx')
power_data.set_index('Team',inplace=True)
print(power_data)
print(power_data.at['Bills','Off'], power_data.at['Bills','Def'])
#power_teams = power_data['Team']
#print(power_data[power_teams) #['Bills']) #['Bills']], power_teams['Def'['Bills']])
#encoding = 'cp1252'
#with open('data/NFLFut22a.csv', 'r', encoding=encoding, newline='') as power_file:
# with open('data/NFLFut22b.csv', 'r') as power_file:
#     power_data = csv.DictReader(power_file)
#     for row in  power_data:
#         print(row)
#print(power_data['offense'])