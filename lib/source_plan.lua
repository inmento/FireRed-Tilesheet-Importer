-- Explicit manual-to-runtime ledger for the first narrow proof.
--
-- This is not a block map, a layout replacement, or a numerical tileset-ID
-- pairing. It records one semantically stable existing Gen 1 target slot and
-- the declared FireRed map context needed to resolve one native 8×8 source
-- cell. It is deliberately small enough to audit before expansion.

local Plan = {}

Plan.FIRERED_EN_V10 = {
  romSize = 0x01000000,
  romBase = 0x08000000,
  md5 = "e26ee0d44e809351c8ce2d73c7400cdd",
  headers = {
    general = 0x082D4A94,       -- gTileset_General
    palletTown = 0x082D4AAC,    -- gTileset_PalletTown
  },
  palletLayout = {
    address = 0x082DD4C0,       -- LAYOUT_PALLET_TOWN
    width = 24,
    height = 20,
    primaryHeader = 0x082D4A94,
    secondaryHeader = 0x082D4AAC,
  },
}

Plan.tilesets = {
  OVERWORLD = {
    -- Target tile 82 is Red OVERWORLD's base grassTile. The source was
    -- observed locally only at Pallet layout cell (2,2), which resolves to
    -- secondary metatile 38. Cell 0 is its native top-left 8×8 output cell.
    -- This entry is intentionally a visual proof rather than a claim that all
    -- Gen 1 grass variants have a one-to-one FireRed equivalent.
    writes = {
      {
        targetTile = 82,
        requiredBaseRole = "grass",
        source = {
          layout = "palletTown",
          x = 2,
          y = 2,
          cell = 0,
          expectedMapEntry = 0x32A6,
          expectedBank = "secondary",
          expectedMetatile = 38,
        },
      },
    },
  },
}

return Plan
