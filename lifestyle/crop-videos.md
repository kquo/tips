## Cropping Videos

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

