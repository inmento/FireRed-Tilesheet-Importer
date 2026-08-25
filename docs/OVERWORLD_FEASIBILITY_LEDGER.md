# Red OVERWORLD 8×8 Feasibility Ledger — Initial Audit

This is an evidence-based **first-pass constraint ledger**, not a claim that every listed tile has already been visually matched. It is derived from Red’s existing `OVERWORLD` sheet geometry and unchanged 4×4 block table. The accompanying `overworld_target_slot_audit.tsv` records every target slot’s block reuse and behavior membership.

## Current verified result

| Target slot | Existing Gen 1 role | Verified FireRed source | Classification |
|---:|---|---|---|
| `82` | `grass`, `walkable` | Pallet Town layout cell `(2,2)`, PalletTown secondary metatile `38`, native cell `0` | **Direct import verified** |

Within the `OVERWORLD` sheet, tile `82` is the only presently approved runtime slot. Separately, the compatible-interior audit approves Red’s House target slot `1` in both `REDS_HOUSE_1` and `REDS_HOUSE_2`; it is documented in the runtime ledger because it is not an `OVERWORLD` target. Every source is resolved locally from the player’s verified FireRed ROM; no image asset is stored in the project.

## Slots that are not automatically safe to replace

| Group | Target slots | Why it is constrained | Current treatment |
|---|---|---|---|
| Door/warp slots | `27`, `88` | The existing behavior remains correct only if the replacement image still visually reads as a door at the original Gen 1 warp location. | Retain until an explicit visual/position audit is complete. |
| Water/flower animation slots | `20` water, `3` flower | Red’s `OVERWORLD` animation callback modifies these existing 8×8 slots at runtime. A static imported cell alone is not a complete replacement. | Retain for the baseline; design compatible animation support later if wanted. |
| Ledge components | `10`, `15`, `16`, `18`, `20`, `23`, `26`, `35`, `44`, `50`, `51`, `64`, `65`, `75`, `78`, `80`, `81`, `83` | Red’s ledge blocks `13`, `29`, `39`, `54`, and `55` reuse every one of these 8×8 components in unrelated `OVERWORLD` block rows. FireRed jump-ledge source metatiles exist, but no one target component is ledge-exclusive. | **Do not map in the image-only importer.** |
| High-reuse slots | `44` (257 uses / 32 block rows), `20` (184 / 20), `35` (138 / 18), `57` (125 / 17), `17` (108 / 13) | One visual written to the target slot appears everywhere the original block rows reuse it. A source choice must fit every use, not merely one map location. | Require visual reuse audit before mapping. |
| Other role-bearing active slots | `16`, `32`, `33`, `35`, `44`, `45`, `46`, `48`, `49`, `51`, `57`, `60`, `62`, `84`, `91` | Their existing walkability behavior is preserved by the image-only design, but the replacement must visually agree with the player’s old movement expectations. | Candidate only after explicit visual mapping and play test. |
| Unused slots | `0`, `94`, `95` | They are not currently drawn by the imported OVERWORLD block rows. | Safe space for future original custom art only if a later block-table project explicitly uses them; irrelevant to the image-only baseline. |

## Active nonsemantic candidate slots

The following 74 active slots have no listed walkability, door, warp, grass, water, shore, or counter membership in the imported target record. They are **not automatically FireRed matches**, but they are the best candidates for the next manual visual review because the baseline has fewer behavior constraints:

```text
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 19 20 21 22 23 24 25 26 28 29 30 31 34 36 37 38 39 40 41 42 43 47 50 52 53 54 55 56 58 59 61 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 83 85 86 87 89 90 92 93
```

Slots `3` and `20` appear in this list because the imported semantic record does not list them, but the renderer’s existing `TILEANIM_WATER_FLOWER` behavior still makes them animation-constrained. They are therefore not baseline candidates.

## Verified FireRed source inventory for the first audit

The locally verified FireRed `LAYOUT_PALLET_TOWN` context supplies a General primary tileset plus a PalletTown secondary tileset. Its 24×20 source layout uses 98 distinct metatiles: 24 General-primary IDs and 74 PalletTown-secondary IDs. The decoded context exposes 640 General raw 8×8 graphic cells and 76 PalletTown raw 8×8 graphic cells.

The locally inspected source map visibly contains these categories: repeating grass/ground texture, border trees, path edges, house roof/wall/window/door pieces, fences, signs, flowers, water, shoreline pieces, and laboratory/building-specific details. This means **FireRed source material exists** for many outdoor visual categories. It does not establish that any particular Red target slot is safe to replace: source availability and target-slot compatibility are separate checks.

| Source category visibly available in the verified Pallet context | First-pass target feasibility |
|---|---|
| Repeating grass/ground texture | Strong candidate; tile `82` is verified. |
| Repeating tree, path-edge, fence, flower, and water/shore detail | Candidate only after target-slot reuse and animation review. |
| House roof/wall/window/door pieces and laboratory-specific pieces | Not a broad shared-sheet baseline candidate. They require a map- or town-specific target context and door/warp position review. |
| Signs and small unique props | Usually custom-art or retain-as-Gen-1 candidates unless an existing target slot is consistently the same prop. |

## What “can” and “cannot” mean here

A target slot is **directly importable** only when all of the following are true:

1. The same one resolved FireRed 8×8 result visually fits every place the unchanged Gen 1 block rows use that slot.
2. The source context is declared: FireRed map layout, primary/secondary tilesets, metatile, 8×8 cell, palette, flip state, and layer composition.
3. The slot is not a special animation case, or its animation is explicitly handled.
4. Its image still makes sense at the unchanged Gen 1 movement/door/warp/grass behavior locations.

A target slot is **not directly importable** when it needs a different visual in different uses, has no single FireRed visual equivalent, or is a special animated/interaction tile. Such a gap can later be addressed by retaining Gen 1 art, by creating an original compatible 8×8 replacement, or—only after the tilesheet-first baseline is stable—by introducing a separate generated-block design.

The audit therefore does not yet identify a permanent “FireRed cannot supply this” list. It identifies the exact slots that require a manual visual decision before any full-game remap claim can be made.
