## Lifestyle

Lifestyle tips.

- [Blood Pressure Diet](bp-diet.md): Blood pressure diet cheat-sheet.
- [Columbo](columbo/index.md): Listing of all 69 TV Episodes of Columbo.

### Home Videos Via Apple TV

Share MP4 videos on your **Mac** with your **Apple TV** via the *Apple TV* **App**:

- Launch the Apple TV app and click on *File -> Import...* option and add the specific directory with your videos.
- Click on your Mac's *System Settings -> General -> Sharing* and enable **Media Sharing**
- Click on the **(i)** icon to configure settings
- Make sure your Mac and Apple TV are on the **same** Wi-Fi network
- Sign in with your Apple ID if prompted
- **REMINDER**: Your Mac must remain powered ON in order to serve the content

### Cropping Videos

How-to crop the sides of a 5-second video clip and convert it from **widescreen** format (e.g., 16:9) to an old-style movie format (e.g., 4:3) using a CLI program. Use `ffmpeg`:

```bash
ffmpeg -i input.mp4 -vf "crop=ih*4/3:ih:(iw-ih*4/3)/2:0" -t 5 -c:a copy output.mp4
```

- `-i input.mp4`: Specifies the input video file.
- `-vf "crop=ih*4/3:ih"`: This applies a video filter to crop the video.
  - `ih` refers to the input height.
  - `ih*4/3` calculates the new width based on the height to maintain a 4:3 aspect ratio.
- `-t 5`: Optionally, limit the output video to 5 seconds.
- `-c:a copy`: This copies the audio stream without re-encoding it.
- `output.mp4`: Specifies the name of the output video file.

### Converting iPhone Ringtones

- Convert ringtone M4R to MP3: `ffmpeg -i input.m4r -acodec libmp3lame -ab 256k output.mp3`
- Convert MP3 to ringtone M4R (must be 40s or less): `ffmpeg -i input.mp3 -t 40 -acodec aac -b:a 256k -f ipod output.m4r`
- Convert WAV to ringtone M4R (must be 40s or less): `ffmpeg -i input.wav -acodec aac -b:a 256k -f ipod output.m4r`
- Read M4R metadata: `ffmpeg -i yourfile.m4r` or `ffprobe -v quiet -print_format json -show_format -show_streams yourfile.m4r`
- Modify M4R metadata (without re-encoding). You can ddd multiple '-metadata' entries: `ffmpeg -i yourfile.m4r -metadata title="My Ringtone" -c copy -f ipod output.m4r`

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


## Baseball
Very useful reference for baseball related hacking:
<https://github.com/baseballhackday/data-and-resources/wiki/Resources-and-ideas>


## Poker
Games cheat-sheet patterns:

- Cash game
```
  $40 buy-in
  4  green/25c =   1.00
  8  blue/50c  =   4.00
  10 white/$1  =  10.00
  5  red/$5    =  25.00
  Total        = $40.00
```

- Tournament game
```
  Each player gets $2000 in chips:
  4 green/$25   =   100
  8 blue/$50    =   400
  5 white/$100  =   500  (or 5 black/$100)
  2 purple/$500 =  1000  (or 1 yellow/$1000)
  Total         =  2000
  BLIND SCHEDULE
  LEVEL      SMALL     BIG
  Level 1      25       50
  Level 2      50      100
  Level 3     100      200
  Level 4     200      400
  Level 5     300      600
  Level 6     500    1,000
  Level 7   1,000    2,000
  Level 8   2,000    4,000
  Level 9   4,000    8,000
  Level 10  5,000   10,000
  SAMPLE PAYOUTS
  $40 buy-in
    6 Players
      Total = 240  1st=200  2nd=40
      Additional buy-ins are split between 1st & 2nd 4:1 ratio
    8 Players
      Total = 320  1st=200  2nd=80  3rd=40
      Additional buy-ins are split between 1st & 2nd 3:2 ratio
  $20 buy-in
    6 Players
      Total = 120  1st=100  2nd=20
      Additional buy-ins are split between 1st & 2nd 4:1 ratio
    8 Players
      Total = 160  1st=100  2nd=40  3rd=20
      Additional buy-ins are split between 1st & 2nd 3:2 ratio
```
