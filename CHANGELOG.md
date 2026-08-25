# Changelog

## 0.1.0-prototype.3 — Compatible house-floor proof

This update extends the evidence-backed importer to one additional fully compatible interior visual only. It resolves FireRed Player’s House 1F Building primary metatile `1`, native top-left 8×8 cell, and writes it only to Red’s existing repeated neutral-floor target slot `1` in both `REDS_HOUSE_1` and `REDS_HOUSE_2`. The decoder now supports separately declared, verified FireRed layout contexts while preserving the same target-slot approval guardrail.

The interior scope is deliberately narrow. The approved floor target is used as a neutral floor across the complete unchanged Red’s House reuse set; no stairs, exit mats, doors, furniture, walls, edge tiles, or other interior components are changed. The audited Red ledge components are all shared with unrelated `OVERWORLD` blocks, so **no ledge mapping is included**. Other interior sheets remain unchanged unless their full native reuse set is separately verified compatible.

The patch still supplies image metadata only. It does not alter blocks, map grids, collision, warps, encounters, scripts, saves, or gameplay semantics. No FireRed ROM, extracted graphics, generated image, or downloaded/reposted tilesheet is included in the repository or release package.

## 0.1.0-prototype.2 — Evidence-backed target-slot ledger

This update applies the current Gen1Recomp tileset-sheet contract to the importer’s runtime mapping boundary. Every proposed FireRed source-to-Red target write must now be explicitly approved for that exact existing 8×8 target slot, include reuse-set evidence, match the approved base role, declare a complete verified source context, remain in the native target-sheet bounds, and occur only once. Invalid entries are rejected before source pixels are decoded or a generated sheet is written.

The approved visual scope is intentionally unchanged: the only current mapping remains FireRed Pallet Town secondary metatile `38`, top-left 8×8 cell to Red `OVERWORLD` grass tile `82`. The update does not bulk-copy FireRed 16×16 metatiles, add building/tree/water/door replacements, resize a sheet, change map grids or block rows, or alter collision, warps, encounters, scripts, saves, or progression.

No FireRed ROM, extracted graphics, generated image, or downloaded/reposted tilesheet is included in the repository or release package.

## 0.1.0-prototype.1 — Manual-first 8×8 tilesheet proof

This first isolated prototype rebuilds the visual-import approach from the manual image-editor-equivalent workflow outward. It defines a documented process for resolving FireRed raw 8×8 source graphics through the selected map’s primary/secondary tilesets, metatile entries, palettes, flips, and two visual layers, then writing a result into an existing compatible Gen 1 8×8 tilesheet slot.

The runtime proof is intentionally limited to Red `OVERWORLD` tile ID `82`, the existing base grass tile. It reads the player-imported verified FireRed English v1.0 source locally, resolves the documented Pallet Town source cell, and creates one in-memory true-color sheet. The patch provides image metadata only; it does not replace the target `blocks` table, any map record, existing tile IDs, or movement/collision/door/warp/grass/water semantics.

No FireRed ROM, extracted graphics, generated image, or downloaded/reposted tilesheet is included in the repository or release package.
