## Chess

Great Chess Openings to master.

- For White
  - King's Gambit (Muzio Gambit)
  - Danish Gambit
  - Fried Liver Attack
  - Cochrane Gambit
  - Scotch Gambit
  - Halloween Gambit
  - Spicy Gambits: The Monkey's Bum
  - Caro-Kann Defense, Hillbilly Attack
  - The Ponziani Opening

- For Black
  - Latvian Gambit

**Convert portable naming notation (PGN) from chess.com**:
```
pgnconv() {
    cat $1 | sed  "s/ \[%timestamp null\]//g" | sed "s/ [0-9]*\.\.\.//g" > ${1%.*}_2.pgn
}
```
