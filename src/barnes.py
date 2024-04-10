from posixpath import split
import re
import sys
import pandas as pd

NOPRINT_TRANS_TABLE = {
    i: None for i in range(0, sys.maxunicode + 1) if not chr(i).isprintable()
}

def make_printable(s):
    """Replace non-printable characters in a string."""

    # the translate method on str removes characters
    # that map to None from the string
    return s.translate(NOPRINT_TRANS_TABLE)

leagues =['EPL', 'CFB', 'NFL', 'NBA', 'CBB']
oubets = ['OVER' 'UNDER', 'DRAW']
halfpoints = ['1/2', '+1/2', '-1/2']
print(*leagues)
league = ''

def get_barnes(file):
    with open(file, 'r') as bb:
        return bb.readlines()

lines = get_barnes('data/2022/week5.txt')

for l in lines:
    
    csplit = make_printable(l).upper().split('(')
    if not csplit[0].strip():
        continue
    #words = re.split(r'([-+[0-9]+:[0-9]+])', csplit[0])
    words = csplit[0].split()
    print(words)
    halfpoint = 0
    contest = 'GAME'
    team = ''
    oppo = ''
    #print(words[0])
    if words[0] in leagues:
        league = words.pop(0)
        continue
    #try:
    if (any(True for x in halfpoints if x in words)):
        halfpoint = 0.5
        n = max(words.index('1/2'), words.index('+1/2'), words.index('-1/2'))
        if n == 2:
            halfpoint = halfpoint -1
        words.pop(n)
    #except:
    #    pass
    print(halfpoint)
    if 1==1:
        continue
    n = max(words.index('1ST'), words.index('1H')) # 1ST HALF or 1H
    if n:
        contest = 'HALF_1'
        words.pop(n)
        if words[n+1] == 'HALF':
            words.pop(n+1)
    team = words.pop(0)
    if words.index('DRAW'):
        team, oppo = words[0].split('-')


    
    