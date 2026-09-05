---
type: howto
---
## Decrypt Disc to MKV File

1. Rip the Blu-ray or DVD with the [MakeMKV](https://www.makemkv.com/) desktop app, installed with `brew`. The resulting [MKV](https://en.wikipedia.org/wiki/Matroska) file keeps the disc's full quality, which makes it the cleanest archival format.
2. Convert the MKV to MP4 so the Apple TV app plays it as a [home video](appletv-videos.md):

```bash
ffmpeg -i input.mkv -map 0:v:0 -map 0:a:0 -c:v copy -c:a ac3 -b:a 640k output.mp4
```
