# Editors
Handy editor tips.

## vi
Common commands:
```
CTRL-V    u                  Change case
SHIFT-I   spaces             Indent

INDENT BLOCK
Go to line, and press v then jj, selecting all the lines you want
:le 4   for 4 spaces

UNIDENT ENTIRE FILE
:gg=G

SET AUTOINDENT
:set ai

SEARCH/REPLACE g multiple instances per line, c confirm
:%s/OLD/NEW/gc             

```

## VS Codium / Code
Change foreground color:

1. CMD + ,
2. Click on "Open Settings (JSON)" icon (top-right-hand corner, 3rd from left)
3. Add:

```json
    "workbench.colorCustomizations": {
      // Enter you choice below. Remember JSON doesn't accept these comments.
      "editor.foreground": "#d4d4d4",    // grayish text OR
      "editor.foreground": "#6688cc",    // blueish text
    }
```
