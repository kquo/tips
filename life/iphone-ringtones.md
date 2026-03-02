## Converting iPhone Ringtones

- Convert ringtone M4R to MP3: `ffmpeg -i input.m4r -acodec libmp3lame -ab 256k output.mp3`
- Convert MP3 to ringtone M4R (must be 40s or less): `ffmpeg -i input.mp3 -t 40 -acodec aac -b:a 256k -f ipod output.m4r`
- Convert WAV to ringtone M4R (must be 40s or less): `ffmpeg -i input.wav -acodec aac -b:a 256k -f ipod output.m4r`
- Read M4R metadata: `ffmpeg -i yourfile.m4r` or `ffprobe -v quiet -print_format json -show_format -show_streams yourfile.m4r`
- Modify M4R metadata (without re-encoding). You can ddd multiple '-metadata' entries: `ffmpeg -i yourfile.m4r -metadata title="My Ringtone" -c copy -f ipod output.m4r`
