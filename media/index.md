## Media

Tips on all things related to media, including audio, photos, video, and streaming.

### Streaming

Rerences on all content one can stream.

- [Columbo](columbo/index.md): Everyone's all-time favorite TV detective.

### Home Videos via Apple TV

Share MP4 videos on your **Mac** with your **Apple TV** via the *Apple TV* **App**:

- Launch the Apple TV app and click on *File -> Import...* option and add the specific directory with your videos.
- Click on your Mac's *System Settings -> General -> Sharing* and enable **Media Sharing**
- Click on the **(i)** icon to configure settings
- Make sure your Mac and Apple TV are on the **same** Wi-Fi network
- Sign in with your Apple ID if prompted
- **REMINDER**: Your Mac must remain powered ON in order to serve the content

### Crop

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

### iPhone Ringtones

- Convert ringtone M4R to MP3: `ffmpeg -i input.m4r -acodec libmp3lame -ab 256k output.mp3`
- Convert MP3 to ringtone M4R (must be 40s or less): `ffmpeg -i input.mp3 -t 40 -acodec aac -b:a 256k -f ipod output.m4r`
- Convert WAV to ringtone M4R (must be 40s or less): `ffmpeg -i input.wav -acodec aac -b:a 256k -f ipod output.m4r`
- Read M4R metadata: `ffmpeg -i yourfile.m4r` or `ffprobe -v quiet -print_format json -show_format -show_streams yourfile.m4r`
- Modify M4R metadata (without re-encoding). You can ddd multiple '-metadata' entries: `ffmpeg -i yourfile.m4r -metadata title="My Ringtone" -c copy -f ipod output.m4r`
