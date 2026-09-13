#!/usr/bin/env bash
# Prepare a new demo video for this repo:
#   videos/<name>.mp4   - H.264, <= 9 MB (fits GitHub's 10 MB attachment limit), 30 fps
#   thumbs/<name>.jpg   - still frame at 25%
#   previews/<name>.gif - 8-second looping preview that autoplays in the README
#
# Usage:  scripts/add_video.sh path/to/source.mp4 my-video-name [gif_start_seconds]
# Then paste the printed HTML card into README.md under the right topic.
set -euo pipefail
SRC="$1"; NAME="$2"; GIF_START="${3:-3}"
cd "$(dirname "$0")/.."
mkdir -p videos thumbs previews
DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$SRC")
read -r W H <<< "$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$SRC" | tr ',' ' ')"
VK=$(python3 -c "b=(9.0*8*1024)/$DUR-96; print(int(min(max(b,350),2500)))")
if [ "$H" -gt "$W" ]; then VF="scale=-2:'min(960,ih)',fps=30"; GW=260; CARD_W=280; else VF="scale='min(1280,iw)':-2,fps=30"; GW=480; CARD_W=440; fi
echo ">> $NAME  ${DUR%.*}s  ${W}x${H}  video bitrate ${VK}k"
ffmpeg -v error -y -i "$SRC" -vf "$VF" -c:v libx264 -preset slow -b:v ${VK}k -pass 1 -passlogfile "/tmp/pass_$NAME" -an -f mp4 /dev/null
ffmpeg -v error -y -i "$SRC" -vf "$VF" -c:v libx264 -preset slow -b:v ${VK}k -pass 2 -passlogfile "/tmp/pass_$NAME" -pix_fmt yuv420p -c:a aac -b:a 96k -ac 2 -movflags +faststart "videos/$NAME.mp4"
ffmpeg -v error -y -ss "$(python3 -c "print($DUR*0.25)")" -i "videos/$NAME.mp4" -frames:v 1 -q:v 3 "thumbs/$NAME.jpg"
ffmpeg -v error -y -ss "$GIF_START" -t 8 -i "videos/$NAME.mp4" -vf "fps=10,scale=$GW:-2:flags=lanczos,split[a][b];[a]palettegen=max_colors=96:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" "previews/$NAME.gif"
rm -f /tmp/pass_$NAME*
M=$(python3 -c "d=int($DUR); print(f'{d//60}:{d%60:02d}')")
ls -lh "videos/$NAME.mp4" "thumbs/$NAME.jpg" "previews/$NAME.gif"
cat <<CARD

Paste this card into README.md:

    <td align="center" valign="top" width="33%">
      <a href="videos/$NAME.mp4"><img src="previews/$NAME.gif" width="$CARD_W" alt="$NAME"></a>
      <br><b>TITLE HERE</b>
      <br><sub>Caption here · <a href="videos/$NAME.mp4">full video ($M)</a></sub>
    </td>

To get a real inline player instead of the GIF: drag videos/$NAME.mp4 into any GitHub issue
comment box, copy the https://github.com/user-attachments/assets/... link it produces and replace
the <a><img></a> with:  <video src="THAT_LINK" controls playsinline width="$CARD_W"></video>
CARD
