-- FireRed Tilesheet Importer Prototype
--
-- Narrow tilesheet-first proof. It locally decodes one ledger-approved native
-- FireRed 8x8 cell and writes it into the existing Red OVERWORLD grass slot.
-- It does not replace a map grid, a block table, or any gameplay semantic ID.

local GameVersion = require("src.core.GameVersion")
local Cache = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.cache")
local Patch = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch")
local Decoder = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.firered_sheet_decoder")
local Plan = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.source_plan")

local TARGET_TILESET = "OVERWORLD"
local GENERATED_PATH = "firered_tilesheet/generated/prototype/overworld-pallet-grass.png"

return function(mod)
  if GameVersion.get() ~= "red" then return end

  local base = assert(mod.content.tilesets:get(TARGET_TILESET),
    "FireRed tilesheet prototype: Red OVERWORLD tileset is unavailable")
  local Assets = require("src.render.Assets")
  local baseImageData = Assets.imageData(base.image)

  -- `firered.gba` is available only through the manifest's verified import
  -- declaration. The decoded result remains in memory and is never written.
  local rom = assert(mod:read("baseroms/firered.gba"),
    "FireRed tilesheet prototype: import verified FireRed English v1.0 in Gen1Recomp's Imported Files panel")
  local generatedSheet = Decoder.buildSheet(rom, base, Plan.FIRERED_EN_V10,
    assert(Plan.tilesets[TARGET_TILESET]), baseImageData)

  Cache.install()
  Cache.put(GENERATED_PATH, generatedSheet)

  -- Image metadata only: no `blocks`, map records, collision lists, role lists,
  -- or grass/warp/door/water fields are present in this patch.
  mod.content.tilesets:patch(TARGET_TILESET, Patch.imageOnlyPatch(GENERATED_PATH, base))

  mod.events:on("game.ready", function(event)
    if event and event.game then
      event.game.fireredTilesheetPrototype = {
        phase = "verified-pallet-grass-8x8-proof",
        targetTileset = TARGET_TILESET,
        sourceContext = "LAYOUT_PALLET_TOWN / General + PalletTown",
        targetTile = 82,
        tileCount = Patch.tileCount(base),
        blocksPreserved = true,
        semanticsPreserved = true,
      }
    end
  end)
end
