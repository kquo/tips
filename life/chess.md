---
type: reference
---
## Chess

Openings I want to master, each linked to its [chess opening](https://en.wikipedia.org/wiki/Chess_opening) page.

For White:

- [King's Gambit](https://en.wikipedia.org/wiki/King%27s_Gambit), especially the [Muzio Gambit](https://en.wikipedia.org/wiki/Muzio_Gambit)
- [Danish Gambit](https://en.wikipedia.org/wiki/Danish_Gambit)
- [Fried Liver Attack](https://en.wikipedia.org/wiki/Fried_Liver_Attack)
- [Cochrane Gambit](https://en.wikipedia.org/wiki/Petrov%27s_Defence#Classical_Variation:_3.Nxe5)
- [Scotch Gambit](https://en.wikipedia.org/wiki/Scotch_Gambit)
- [Halloween Gambit](https://en.wikipedia.org/wiki/Halloween_Gambit)
- [Monkey's Bum](https://en.wikipedia.org/wiki/Modern_Defense#Monkey%27s_Bum), the spiciest of the lot
- [Hillbilly Attack](https://en.wikipedia.org/wiki/Caro%E2%80%93Kann_Defence#Hillbilly_Attack) against the Caro-Kann
- [Ponziani Opening](https://en.wikipedia.org/wiki/Ponziani_Opening)

For Black:

- [Latvian Gambit](https://en.wikipedia.org/wiki/Latvian_Gambit)

### PGN cleanup

Strip the clock stamps and repeated move numbers from a [PGN](https://en.wikipedia.org/wiki/Portable_Game_Notation) file exported from chess.com:

```bash
pgnconv() {
    cat $1 | sed  "s/ \[%timestamp null\]//g" | sed "s/ [0-9]*\.\.\.//g" > ${1%.*}_2.pgn
}
```
