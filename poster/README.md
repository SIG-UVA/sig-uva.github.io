# Editable hackathon poster

Open `index.html` in a browser. All text, colors, spacing, and layout are editable in that file; the generated background and QR code live in `assets/`.

The canvas is print-sized at 11 × 17 inches. Build and verify both outputs from anywhere in the repository:

```sh
./poster/build.sh
```

To replace the QR code, build, and verify that the final PNG and PDF both decode to the supplied URL:

```sh
./poster/build.sh --qr 'FINAL_URL'
```

The script requires Google Chrome, Poppler (`pdfinfo` and `pdftoppm`), `qpdf`, `uv`, and—only with `--qr`—`qrencode`. Set `CHROME_BIN` if Chrome is installed elsewhere. The QR currently points to `https://sig-uva.github.io/`. PDF metadata is normalized so rebuilding unchanged inputs does not change the PDF.

## Image directions considered

- Current: custom-generated, text-free "model internals" background. It is tailored to the layout and avoids stock-photo licensing constraints.
- [Google DeepMind neural-network abstraction on Pexels](https://www.pexels.com/photo/an-artist-s-illustration-of-artificial-intelligence-ai-this-image-was-inspired-by-neural-networks-used-in-deep-learning-it-was-created-by-novoto-studio-as-part-of-the-visualising-ai-pr-17483874/): free-to-use alternative with a more organic network treatment.
- [Google DeepMind input/output abstraction on Pexels](https://www.pexels.com/photo/an-artist-s-illustration-of-artificial-intelligence-ai-this-illustration-visualises-the-input-and-output-of-neural-networks-and-how-ai-systems-perceive-data-it-was-created-by-rose-pilkington-17485706/): free-to-use alternative with modular 3D blocks.
- [AI-generated neural-network image on Wikimedia Commons](https://commons.wikimedia.org/wiki/File%3ANeural_network_-_Midjourney_and_Grok.png): public-domain fallback.

The palette uses official UVA Blue `#232D4B` and UVA Orange `#E57200`. Keep logos on a clean, high-contrast field if official logo assets are added.

## Logos

- `assets/uva-sds-logo.png`: official primary color logo from the [School of Data Science brand-resources page](https://datascience.virginia.edu/pages/school-brand-resources).
- `assets/vaisi-logo.png`: full VAISI logo image served by the [VAISI homepage](https://vaisi.org/).

Both are displayed unmodified on white cards. Do not recolor, crop, or add effects.

## Background generation

Generated with Codex's built-in image-generation tool. The attached original poster was used only as a portrait-format and palette reference.

```text
Use case: ads-marketing
Asset type: text-free portrait poster background for an academic AI safety hackathon
Primary request: Create a stunning, sophisticated visual metaphor for mechanistic interpretability: a dark machine-learning system opened into translucent computational layers, with fine neural filaments and a few exposed signal pathways glowing through the layers. It should feel like looking inside a model, not a generic robot or human brain.
Scene/backdrop: Deep near-black UVA navy field with dimensional translucent planes, circuit-like threads, sparse particles, and one focused path of warm light moving through the system.
Style/medium: Cinematic scientific visualization; precise, elegant, contemporary, editorial-quality 3D render; believable optical depth; subtle glass and fiber textures.
Composition/framing: Portrait composition suitable for an 11 × 17 poster. Put the most luminous structure in the upper-right and lower-right thirds; preserve calm dark negative space across the upper-left and central-left for editable headline and event details. Keep the bottom band relatively quiet for a QR code and institutional wordmarks.
Lighting/mood: Controlled luminous contrast, intellectually exciting, mysterious but credible, not dystopian.
Color palette: Dominant UVA Blue #232D4B and near-black navy; selective UVA Orange #E57200 highlights; small touches of cool cyan only where useful for depth; orange should be an accent, not half the canvas.
Constraints: Background image only. No typography, letters, numbers, logos, emblems, QR codes, people, faces, or watermark.
Avoid: Literal brain silhouettes, robot heads, padlocks, shields, binary-code rain, neon cyberpunk cityscapes, stock-photo handshake imagery, clutter, oversaturated orange.
```
