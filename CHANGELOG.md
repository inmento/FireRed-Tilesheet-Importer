# Changelog

## 0.1.0-prototype.1 — Manual-first 8×8 tilesheet proof

This first isolated prototype rebuilds the visual-import approach from the manual image-editor-equivalent workflow outward. It defines a documented process for resolving FireRed raw 8×8 source graphics through the selected map’s primary/secondary tilesets, metatile entries, palettes, flips, and two visual layers, then writing a result into an existing compatible Gen 1 8×8 tilesheet slot.

The runtime proof is intentionally limited to Red `OVERWORLD` tile ID `82`, the existing base grass tile. It reads the player-imported verified FireRed English v1.0 source locally, resolves the documented Pallet Town source cell, and creates one in-memory true-color sheet. The patch provides image metadata only; it does not replace the target `blocks` table, any map record, existing tile IDs, or movement/collision/door/warp/grass/water semantics.

No FireRed ROM, extracted graphics, generated image, or downloaded/reposted tilesheet is included in the repository or release package.
