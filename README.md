# FireRed Tilesheet Importer Prototype

This is a **new, isolated Red-only experiment** that restarts the FireRed visual-import work from the renderer contract outward. It does not modify the older FireRed Kanto Visual Importer, the FireRed Broad Overworld Importer, the foliage importer, the battle-sprite importer, or the personal mod index.

> **Current scope: two manual-equivalent compatible 8×8 visual proofs.** The prototype locally resolves FireRed Pallet Town grass into Red `OVERWORLD` tile ID `82`, and FireRed Player’s House flooring into tile ID `1` of Red `REDS_HOUSE_1` and `REDS_HOUSE_2`. Every base block definition and gameplay semantic remains intact.

## Why this prototype exists

The earlier experiments attempted source decoding, map/layout correspondence, generated block definitions, visual composition, cache behavior, and semantic remapping at the same time. This prototype intentionally removes most of that surface area.

The target model is simple:

```text
Existing Red Gen1Recomp tileset image
  + unchanged existing 8×8 tile IDs
  + unchanged existing 4×4 / 32×32 block rows
  + unchanged existing behavior fields
        ↓
locally generated replacement 8×8 image sheet
        ↓
existing Red maps render through their existing block definitions
```

Both the target slots and FireRed raw graphics cells are **8×8 pixels**. They are not, however, numerically or semantically interchangeable. The importer uses an explicit mapping ledger rather than assuming that a FireRed tile ID equals the same-numbered Gen 1 tile ID.

## Manual-first procedure

The automation follows the documented image-editor-equivalent process in [MANUAL_TILESET_PROCEDURE.md](MANUAL_TILESET_PROCEDURE.md). In summary, a manual test would:

1. Open the existing Gen1Recomp target sheet with an 8×8 grid and leave the existing block table unchanged.
2. Choose one target tile ID whose visual meaning is consistent across its uses.
3. Resolve a source FireRed 8×8 cell through the declared map’s primary/secondary tileset pairing, metatile entry, palette, flip flags, and two layers.
4. Paint the resulting native-size 8×8 pixels into that existing target slot only.
5. Test the game while retaining the original map grid, block rows, collision, doors, warps, encounters, scripts, saves, and progression.

The approved ledger remains deliberately narrow:

| Native Red target | Verified FireRed source | Why it is allowed |
|---|---|---|
| `OVERWORLD` tile `82` | Pallet Town `(2,2)`, secondary metatile `38`, cell `0` | Existing base grass tile with a documented compatible grass reuse set. |
| `REDS_HOUSE_1` tile `1` | Player’s House 1F `(2,3)`, Building primary metatile `1`, cell `0` | Repeated neutral-floor target across the unchanged Red’s House block rows. |
| `REDS_HOUSE_2` tile `1` | Player’s House 1F `(2,3)`, Building primary metatile `1`, cell `0` | The same repeated neutral-floor target and unchanged block reuse as `REDS_HOUSE_1`. |

These are visual proofs, not a claim that every grass, terrain, building, or interior variant is mapped.

### Target-slot approval guardrail

Version `0.1.0-prototype.4` retains the mapping ledger as an enforced runtime boundary and changes only the supported Gen1Recomp engine floor to `>=0.2.18`. Every write must name a target slot that is explicitly approved with its reuse-set evidence, use the approved Gen 1 role, provide a complete FireRed source declaration, remain inside the existing 8×8 target-sheet bounds, and appear only once. The decoder rejects an unapproved, duplicate, incomplete, out-of-range, or role-mismatched entry **before it decodes source pixels or writes the generated sheet**.

This implements the engine’s tileset-sheet rule directly: a FireRed 16×16 metatile is only a source convenience; each approved result is one resolved FireRed 8×8 cell written to one existing Gen 1 8×8 slot. No building, tree, water, door, fence, stair, furniture, wall edge, or neighboring terrain slot is added merely because it appears visually close.

The ledge audit specifically found that every 8×8 component used by Red’s ledge blocks is also reused by unrelated `OVERWORLD` block rows. A global ledge image write would therefore mislabel unrelated terrain or require semantic block/map changes. **No ledge mapping is included.**

## Required source and asset boundary

The mod requires the player to import exactly **Pokémon FireRed English v1.0**, 16 MiB, MD5 `e26ee0d44e809351c8ce2d73c7400cdd`, through Gen1Recomp’s protected import flow.

The code decodes source pixels only in memory. It does not write a FireRed-derived image to disk, commit one to this repository, or include one in a release archive. Do not add downloaded or reposted FireRed tilesheets to this project.

## What remains unchanged

The runtime patch supplies only the generated image path and its existing image geometry. It does **not** patch:

| Base-owned data | Prototype behavior |
|---|---|
| Map block grids and border blocks | Unchanged |
| `blocks` table / 4×4 rows | Unchanged |
| Existing tile IDs | Unchanged |
| Walkability, doors, warps, counters, grass, water, and shore semantics | Unchanged |
| Map events, scripts, NPCs, encounters, saves, and progression | Unchanged |
| FireRed ROM or derived artwork in the package | Not included |

## First test plan

Install this prototype alone with the prior map importer, broad-overworld importer, and foliage importer disabled. Import the verified FireRed source, start or load Red, and test Pallet Town, Route 1, and both floors of Red’s House.

Verify that the visible grass/ground and house floor use native 8×8 detail rather than enlarged source metatiles; movement remains normal; grass encounters still trigger; doors, exits, and stairs still work; saving/loading remains normal; and no unrelated tile class changes. This proof intentionally affects only the listed compatible visual slots; it is not yet a broad replacement.

## Development validation

The project includes tests that verify the 8×8 same-slot contract, the enforced target-slot approval ledger, the absence of map/block/semantic patch fields, the Red-only multi-sheet entrypoint boundary, and the player-authorized FireRed Pallet and Player’s House source decodes. Private verified-ROM tests do not emit an image artifact.
