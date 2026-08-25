-- Explicit manual-to-runtime ledger for evidence-approved image-only writes.
--
-- This is not a block map, a layout replacement, or a numerical tileset-ID
-- pairing. Every source cell must be approved against the complete unchanged
-- Gen 1 reuse set of its native 8x8 destination slot.

local Plan = {}

Plan.FIRERED_EN_V10 = {
  romSize = 0x01000000,
  romBase = 0x08000000,
  md5 = "e26ee0d44e809351c8ce2d73c7400cdd",
  layouts = {
    palletTown = {
      address = 0x082DD4C0,       -- LAYOUT_PALLET_TOWN
      width = 24,
      height = 20,
      primaryHeader = 0x082D4A94, -- gTileset_General
      secondaryHeader = 0x082D4AAC, -- gTileset_PalletTown
      label = "Pallet Town",
    },
    playersHouse1F = {
      address = 0x082D5200,       -- LAYOUT_PALLET_TOWN_PLAYERS_HOUSE_1F
      width = 13,
      height = 10,
      primaryHeader = 0x082D4BB4, -- gTileset_Building
      secondaryHeader = 0x082D4C74, -- gTileset_GenericBuilding1
      label = "Pallet Town Player's House 1F",
    },
  },
}

Plan.tilesets = {
  OVERWORLD = {
    -- Each key is a target 8x8 slot, not a source metatile. A nearby FireRed
    -- cell is never authorization: the complete unchanged target reuse set
    -- must have a recorded visual decision.
    approvedTargets = {
      [82] = {
        requiredBaseRole = "grass",
        evidence = "Red OVERWORLD grassTile; all 16 uses occur in one grass block row; FireRed PalletTown secondary metatile 38 cell 0 was locally resolved and compared at native 8x8 geometry.",
      },
    },
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

  -- Red's House 1F and 2F intentionally retain their separate native
  -- tileset records even though both use the same base image. Slot 1 is the
  -- repeated neutral interior-floor cell in both unchanged block tables.
  REDS_HOUSE_1 = {
    approvedTargets = {
      [1] = {
        requiredBaseRole = "interior-floor",
        evidence = "Red REDS_HOUSE_1 target slot 1 is the repeated neutral floor cell (104 uses across its unchanged house block rows) and is visually compatible with FireRed Player's House 1F Building primary metatile 1 cell 0; it is not a stair, exit, door, furnishing, wall edge, or gameplay-semantic target.",
      },
    },
    writes = {
      {
        targetTile = 1,
        requiredBaseRole = "interior-floor",
        source = {
          layout = "playersHouse1F",
          x = 2,
          y = 3,
          cell = 0,
          expectedMapEntry = 0x3001,
          expectedBank = "primary",
          expectedMetatile = 1,
        },
      },
    },
  },

  REDS_HOUSE_2 = {
    approvedTargets = {
      [1] = {
        requiredBaseRole = "interior-floor",
        evidence = "Red REDS_HOUSE_2 uses the identical repeated neutral floor target slot 1 (104 uses in the same unchanged block rows); the FireRed Player's House 1F Building primary metatile 1 cell 0 is a generic wood-floor visual compatible with that full reuse set.",
      },
    },
    writes = {
      {
        targetTile = 1,
        requiredBaseRole = "interior-floor",
        source = {
          layout = "playersHouse1F",
          x = 2,
          y = 3,
          cell = 0,
          expectedMapEntry = 0x3001,
          expectedBank = "primary",
          expectedMetatile = 1,
        },
      },
    },
  },
}

return Plan
