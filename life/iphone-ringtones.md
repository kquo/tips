---
type: howto
---
## Converting iPhone Ringtones

Every conversion below is one [FFmpeg](https://en.wikipedia.org/wiki/FFmpeg) command; an iPhone [ringtone](https://en.wikipedia.org/wiki/Ringtone) is an M4R file of 40 seconds or less.

- Convert ringtone M4R to MP3: `ffmpeg -i input.m4r -acodec libmp3lame -ab 256k output.mp3`
- Convert MP3 to ringtone M4R (must be 40s or less): `ffmpeg -i input.mp3 -t 40 -acodec aac -b:a 256k -f ipod output.m4r`
- Convert WAV to ringtone M4R (must be 40s or less): `ffmpeg -i input.wav -acodec aac -b:a 256k -f ipod output.m4r`
- Read M4R metadata: `ffmpeg -i yourfile.m4r` or `ffprobe -v quiet -print_format json -show_format -show_streams yourfile.m4r`
- Change M4R metadata without re-encoding, repeating `-metadata` as needed: `ffmpeg -i yourfile.m4r -metadata title="My Ringtone" -c copy -f ipod output.m4r`
