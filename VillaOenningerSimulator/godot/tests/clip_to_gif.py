import os
import sys

from PIL import Image

SRC = os.path.join("build", "clip")
DST_DIR = os.path.join("build", "preview")
DST = os.path.join(DST_DIR, "collapse.gif")
SIZE = (480, 270)
FPS = 16
COLORS = 128
DROP = 5


def main() -> int:
    names = sorted(n for n in os.listdir(SRC) if n.startswith("frame_") and n.endswith(".png"))
    if not names:
        print("no frames in", SRC)
        return 1

    os.makedirs(DST_DIR, exist_ok=True)
    frames = [Image.open(os.path.join(SRC, n)).convert("RGB").resize(SIZE, Image.LANCZOS) for n in names]
    if DROP > 1:
        frames = [frame for i, frame in enumerate(frames) if i % DROP != 0]

    step = max(1, len(frames) // 12)
    strip = Image.new("RGB", (SIZE[0], SIZE[1] * len(frames[::step])))
    for i, frame in enumerate(frames[::step]):
        strip.paste(frame, (0, SIZE[1] * i))
    pal = strip.quantize(colors=COLORS, method=Image.MEDIANCUT)

    quantized = [frame.quantize(palette=pal, dither=Image.FLOYDSTEINBERG) for frame in frames]
    quantized[0].save(
        DST,
        save_all=True,
        append_images=quantized[1:],
        duration=int(1000 / FPS),
        loop=0,
        optimize=False,
        disposal=1,
    )

    print("frames", len(quantized), "fps", FPS, "size", SIZE)
    print("gif", DST, round(os.path.getsize(DST) / 1048576, 2), "MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
