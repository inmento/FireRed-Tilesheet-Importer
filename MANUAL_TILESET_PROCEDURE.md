# Manual Tilesheet-First Procedure

## Purpose and boundary

This document specifies the manual process that the importer must automate. It is deliberately a **tilesheet-only** procedure. It changes the image drawn by existing Gen 1 tile IDs; it does not change a map grid, block table, collision table, warp, door, encounter, script, save, NPC, or progression record.

> **Local-only source boundary.** Any FireRed-derived pixel reference used to follow this procedure must be decoded locally from the player-authorized, verified FireRed English v1.0 ROM. A derived tilesheet is a development-only local artifact. It must not be committed, packaged, uploaded, or distributed. Online or reposted FireRed tilesheets are not an input to this project.

The first proof uses the Red `OVERWORLD` tileset. Its existing target image is `assets/generated/tilesets/overworld.png`, which is **128×48 pixels**: 16 columns by 6 rows, or 96 indexed 8×8 target slots. Its 128 existing block rows remain exactly as imported by Gen1Recomp. Every row remains a 4×4 list of those target IDs.

## The manual editor model

An image editor is only a useful mental model. The equivalent operation is:

1. Open a local copy of the target Gen 1 tilesheet at native pixels. Turn off interpolation and use an 8×8 grid.
2. Do **not** edit the target map block grid or `blocks` table. Do **not** renumber the existing target tile IDs.
3. For a selected target tile ID, identify every 4×4 block position that references it. This is its visual reuse set.
4. Assign the target ID a single visual meaning only when its full reuse set is compatible. For example, a tile consistently used as grass texture may receive one FireRed grass 8×8 cell. A tile that appears in incompatible contexts is left unchanged in the first proof.
5. Select a corresponding FireRed source **8×8 output cell** from one declared FireRed map/tileset context. Resolve that cell through the FireRed tile reference, palette, horizontal/vertical flip flags, bottom layer, and transparent upper layer.
6. Paint the resolved 8×8 pixels into the existing target sheet slot with no scaling. The destination is exactly `tile_id % 16 * 8` by `floor(tile_id / 16) * 8` in the OVERWORLD sheet.
7. Repeat only for a small, semantically coherent set of target IDs. The first proof should favor visible, non-interactive terrain texture rather than doors, ledges, water animation tiles, warp tiles, or building entrances.
8. Save the resulting local-only sheet only for visual inspection. The runtime prototype instead keeps the same generated `ImageData` in memory.

## Source selection rules

FireRed field data has a different internal organization from the target sheet. The source must be resolved before a target slot is painted.

| Source layer | Manual operation | Automation equivalent |
|---|---|---|
| Primary/base tileset | Select the map’s declared primary source data. | Read the map layout/header’s primary tileset pointer. |
| Secondary/map-specific tileset | Select the map’s declared secondary source data. | Read the map layout/header’s secondary tileset pointer. |
| Raw graphic tile | Read the 4bpp pixels for the referenced 8×8 FireRed tile. | Decode the 32-byte tile with its selected palette. |
| Metatile entry | Resolve one 8×8 cell, including tile ID and flip flags. | Read the entry from the chosen 16×16 metatile’s 2×2 cell definition. |
| Two visual layers | Draw the lower cell, then draw a non-transparent upper cell over it. | Compose lower and upper layers per 8×8 output cell. |
| Palette | Apply the palette named by the source entry. | Convert FireRed’s 15-bit palette colors to true-color output pixels. |

A FireRed 16×16 metatile is a **source-layout convenience**, not a target image unit. The target operation always ends by writing one resolved source 8×8 cell into one existing Gen 1 8×8 slot.

## Mapping ledger

Before altering a target slot, record the mapping in a local ledger. This makes the procedure reproducible and exposes unsafe tile reuse early.

| Target tileset | Target tile ID | Target use/context | FireRed map context | FireRed metatile/cell | Layer result | Safe for first proof? |
|---|---:|---|---|---|---|---|
| `OVERWORLD` | `<id>` | `<all known block contexts>` | `<declared map>` | `<metatile>, <x>, <y>` | `<resolved 8×8 cell>` | `<yes/no>` |

The first automation stage uses the same ledger as data. It must refuse any entry that:

- refers to a target ID outside the existing target image;
- changes a target block row or semantic field;
- refers to an unavailable FireRed tileset/metatile/cell;
- attempts to apply two different source visuals to the same target tile ID in one generated sheet;
- requests a target tile that is marked unsafe for the narrow proof.

## What remains unchanged

The tilesheet-first proof deliberately preserves the following base-owned data verbatim:

- the Gen 1 map’s `blocks` grid and border block;
- the target tileset’s `blocks` table, including all 4×4 tile-ID rows;
- `walkable`, `doorTiles`, `warpTiles`, `counterTiles`, `grassTile`, `waterTiles`, and `shoreTiles`;
- map dimensions, warps, events, scripts, NPCs, encounters, saves, and progression;
- the original target tile IDs used by water/flower/spinner animation rules.

This is why the first proof is intentionally smaller than a literal FireRed map reconstruction. It validates that a local generated 8×8 image sheet can be substituted safely while the existing game behavior remains owned by Gen 1.

## Completion criteria for the first proof

The proof is complete only when all of the following are true:

1. The generated image has the same width, height, and `tilesPerRow` as its base Gen 1 target tileset.
2. The patched tileset uses the original `blocks` table object/value without alteration.
3. Every semantic field is preserved exactly.
4. The generated pixels are native 8×8 output pixels; no 2× scaling occurs.
5. The proof touches only ledger-approved terrain slots.
6. The map loads, the player moves normally, doors/warps still work, grass behavior remains correct, and no source-derived image exists in the repository or release archive.

Only after this manual-equivalent proof is stable should the project expand the ledger, add a second tileset, or automate broader per-map source selection.
