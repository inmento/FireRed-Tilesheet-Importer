# Full Visual Remap Rebuild Plan

## Objective

The goal is a **full visual facelift**, not a claim that every Red 8×8 target slot has a direct FireRed twin. The rebuilt importer should preserve Red map grids, map IDs, dimensions, warps, scripts, encounters, saves, NPCs, progression, and core mechanics while replacing as much visual content as can be validated safely.

The private source/target review confirms the central limitation: both systems use 8×8 pixels, but neither their tile IDs nor their visual roles form a one-to-one dictionary. A full remap therefore needs three visual sources rather than only one.

| Visual source | When used | Distribution rule |
|---|---|---|
| Locally decoded FireRed cell | A target slot has a compatible FireRed visual in every reuse context. | Generate locally from the player’s verified FireRed v1.0 ROM; never package the derived pixel data. |
| New original custom 8×8 cell | A target slot has no single compatible FireRed equivalent, or needs a connector/transition that FireRed does not provide in the target’s reuse pattern. | May be packaged after a separate originality and style review. |
| Retained Gen 1 cell | The slot is animated, interaction-sensitive, unresolved, or visually unsafe to replace. | Keep the original target image cell until dedicated support exists. |

## Rebuild passes

### Pass 1 — Manual ledger and image-only proof

The current prototype belongs here. It retains Red’s existing `OVERWORLD` 128 block rows and all role fields, then writes one resolved FireRed 8×8 result into existing grass tile `82`. Every future image-only entry must be added to an explicit ledger and pass the same native-size and gameplay checks.

This pass is the right place for generic repeating terrain: grass, ground, selected tree detail, simple path texture, and other source cells that remain correct wherever the existing target slot appears.

### Pass 2 — Compatible-sheet coverage

Expand the ledger one target slot at a time. Each proposed slot needs: its Red target ID; all existing target block-row uses; any semantic/animation membership; a declared FireRed source context; the source map layout; primary and secondary tilesets; source metatile/cell; palette and layer composition; and a gameplay/visual test result.

A target cell should be classified as **direct import**, **custom-original candidate**, or **retain**. It must never be classified from matching numeric IDs alone.

### Pass 3 — Map or tileset-family-specific sheets

The broad `OVERWORLD` target tileset is shared by many Red maps, while FireRed has town-specific secondary tilesets. Generic terrain may be shared, but Pallet-specific house, lab, sign, and façade pieces cannot safely become one global `OVERWORLD` sheet.

For a fuller visual remap, the importer must create a separate generated tileset record for each compatible map or map family. The existing map block grid can remain unchanged; only that map’s visual tileset reference changes. Each generated tileset begins as a copy of its base Red sheet, base block rows, and base semantic fields.

### Pass 4 — Original custom gap tiles

The private audit already identifies gap classes: repeated target slots whose usages need different imagery, building/sign/lettering fragments with no safe FireRed counterpart, connector/transition cells, and context-specific props. These are appropriate candidates for newly created original 8×8 pixel art inspired by the desired cohesive visual direction.

Original custom cells should be allocated only after an explicit target-slot or generated-block plan identifies where they will appear. They should be kept as separate original assets and never mixed with FireRed-derived extraction output.

### Pass 5 — Optional expanded visual block layer

A strict image-only approach cannot make one heavily reused target slot display different images in different existing blocks. If that is required, the later solution is **not automatically to rewrite Red maps**. The importer can keep the original map block grid and existing block IDs, but construct a new visual block table with the same number of rows and preserved semantic anchor positions. It can then point each block row at additional generated visual tile IDs in an expanded sheet.

This is a separate, higher-risk phase. It requires explicit semantic testing for every affected 16×16 movement cell and should begin only after the image-only ledger is stable. It exists to support true per-block visual variety; it is not needed for the first grass/terrain proof.

## Special rules discovered in the first audit

| Target condition | Current rule |
|---|---|
| Grass tile `82` | Direct-import proof is approved. |
| Door/warp tiles `27`, `88` | Preserve base semantics. Change art only after visual doorway placement is checked at every affected location. |
| Water/flower renderer slots `20`, `3` | Retain until compatible animation handling is designed. |
| Highly reused slots such as `44`, `20`, `35`, `57`, `17` | Do not replace from one sample until every reuse context has been reviewed. |
| Unused `OVERWORLD` slots `0`, `94`, `95` | Reserve for later original art only if an expanded-block phase uses them. |

## Acceptance criteria

A production expansion is accepted only if it remains native 8×8 detail, does not ship FireRed-derived artwork, applies the source through the verified local-ROM path, preserves Red gameplay data, passes an explicit map/tileset test matrix, and documents every visual source class. A map does not need to become a literal FireRed layout to receive a coherent FireRed-inspired visual facelift.
