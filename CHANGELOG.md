# Changelog

## 0.1.0-prototype.2 — Evidence-backed target-slot ledger

This update applies the current Gen1Recomp tileset-sheet contract to the importer’s runtime mapping boundary. Every proposed FireRed source-to-Red target write must now be explicitly approved for that exact existing 8×8 target slot, include reuse-set evidence, match the approved base role, declare a complete verified source context, remain in the native target-sheet bounds, and occur only once. Invalid entries are rejected before source pixels are decoded or a generated sheet is written.

The approved visual scope is intentionally unchanged: the only current mapping remains FireRed Pallet Town secondary metatile `38`, top-left 8×8 cell to Red `OVERWORLD` grass tile `82`. The update does not bulk-copy FireRed 16×16 metatiles, add building/tree/water/door replacements, resize a sheet, change map grids or block rows, or alter collision, warps, encounters, scripts, saves, or progression.

No FireRed ROM, extracted graphics, generated image, or downloaded/reposted tilesheet is included in the repository or release package.

## 0.1.0-prototype.1 — Manual-first 8×8 tilesheet proof

This first isolated prototype rebuilds the visual-import approach from the manual image-editor-equivalent workflow outward. It defines a documented process for resolving FireRed raw 8×8 source graphics through the selected map’s primary/secondary tilesets, metatile entries, palettes, flips, and two visual layers, then writing a result into an existing compatible Gen 1 8×8 tilesheet slot.

The runtime proof is intentionally limited to Red `OVERWORLD` tile ID `82`, the existing base grass tile. It reads the player-imported verified FireRed English v1.0 source locally, resolves the documented Pallet Town source cell, and creates one in-memory true-color sheet. The patch provides image metadata only; it does not replace the target `blocks` table, any map record, existing tile IDs, or movement/collision/door/warp/grass/water semantics.

No FireRed ROM, extracted graphics, generated image, or downloaded/reposted tilesheet is included in the repository or release package.
