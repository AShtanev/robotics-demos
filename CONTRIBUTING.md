# Adding a video

Folder layout:

```
videos/    full clips, H.264 mp4, each under 10 MB
previews/  GIF preview, generated locally, not committed
thumbs/    still frame, generated locally, not committed
images/    screenshots and diagrams
scripts/   add_video.sh
```

1. Run the helper. It compresses the source to under 10 MB, makes the GIF preview and thumbnail, and prints a ready-to-paste card:

   ```bash
   scripts/add_video.sh ~/Downloads/new_clip.mp4 g1-warehouse-pick 5
   ```

   The last argument is the second at which the GIF preview starts (default 3).

2. Paste the printed `<td>` card into the matching topic table in `README.md`, or start a new `## Topic` section with the same table layout. Portrait clips use `width="280"` in a 3-column table, landscape clips `width="440"` in a 2-column table.

3. Turn the card into an inline player: while signed in to GitHub, drag the mp4 into any issue comment box, copy the `https://github.com/user-attachments/assets/…` link it produces, and replace the `<a><img></a>` pair with `<video src="THAT_LINK" controls playsinline width="280"></video>`. The issue does not need to be created.

4. Commit and push.
