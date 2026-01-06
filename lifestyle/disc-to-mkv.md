## Decrypt Disc to MKV File

1. How do I decrypt a source Blu-ray to an MKV file?
   The easiest way is to use the MakeMKV GUI Application. Download/install with `brew`.
   The MKV file is identical in quality to the disc. This is the cleanest archival format.

2. Convert the resulting MKV file to MP4, to be played as Home Video via Apple TV HD: 

```bash
ffmpeg -i input.mkv -map 0:v:0 -map 0:a:0 -c:v copy -c:a ac3 -b:a 640k output.mp4
```
