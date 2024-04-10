from posixpath import split
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

leagues =['EPL', 'NCAAF', 'NFL', 'NBA', 'NCAAB']
oubets = ['OVER' 'UNDER', 'DRAW']
print(*leagues)
league = ''

def get_barnes(file):
    with open(file, 'r') as bb:
        return bb.readlines()

lines = get_barnes('data/2022/week0.txt')

for l in lines:
    words = make_printable(l).upper().split(' ')
    halfpoint = 0
    contest = 'GAME'
    team = ''
    oppo = ''
    #print(words[0])
    if words[0] in leagues:
        league = words.pop(0)
    n = max(words.index('1/2'), words.index('+1/2'))
    if n:
        halfpoint = 0.5
        words.pop(n)
    n = max(words.index('1ST'), words.index('1H')) # 1ST HALF or 1H
    if n:
        contest = 'HALF_1'
        words.pop(n)
        if words[n+1] == 'HALF':
            words.pop(n+1)
    team = words.pop(0)
    if words.index('DRAW'):
        team, oppo = words[0].split('-')


    
    