-- FireRed Tilesheet Importer Prototype
--
-- Evidence-backed tilesheet-first importer. Every write resolves one FireRed
-- 8x8 source cell into an explicitly approved existing Red target slot. It
-- never replaces map grids, block tables, collision, warps, or semantic IDs.

local GameVersion = require("src.core.GameVersion")
local Cache = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.cache")
local Patch = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch")
local Decoder = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.firered_sheet_decoder")
local Plan = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.source_plan")

local GENERATED_PATHS = {
  OVERWORLD = "firered_tilesheet/generated/prototype/overworld-pallet-grass.png",
  REDS_HOUSE_1 = "firered_tilesheet/generated/prototype/reds-house-1-compatible-floor.png",
  REDS_HOUSE_2 = "firered_tilesheet/generated/prototype/reds-house-2-compatible-floor.png",
}

return function(mod)
  if GameVersion.get() ~= "red" then return end

  -- `firered.gba` is available only through the manifest's verified import
  -- declaration. Every decoded result remains in memory and is never written.
  local rom = assert(mod:read("baseroms/firered.gba"),
    "FireRed tilesheet prototype: import verified FireRed English v1.0 in Gen1Recomp's Imported Files panel")
  local Assets = require("src.render.Assets")
  Cache.install()

  local applied = {}
  for targetTileset, generatedPath in pairs(GENERATED_PATHS) do
    local plan = assert(Plan.tilesets[targetTileset],
      "FireRed tilesheet prototype: missing approved plan for " .. targetTileset)
    local base = assert(mod.content.tilesets:get(targetTileset),
      "FireRed tilesheet prototype: Red " .. targetTileset .. " tileset is unavailable")
    local baseImageData = Assets.imageData(base.image)
    local generatedSheet = Decoder.buildSheet(rom, base, Plan.FIRERED_EN_V10, plan, baseImageData)

    Cache.put(generatedPath, generatedSheet)
    -- Image metadata only. The patch supplies no blocks, map data, collision
    -- fields, role lists, or grass/warp/door/water semantics.
    mod.content.tilesets:patch(targetTileset, Patch.imageOnlyPatch(generatedPath, base))
    applied[#applied + 1] = targetTileset
  end

  mod.events:on("game.ready", function(event)
    if event and event.game then
      event.game.fireredTilesheetPrototype = {
        phase = "evidence-backed-8x8-ledger",
        targetTilesets = applied,
        sourceContexts = "LAYOUT_PALLET_TOWN and LAYOUT_PALLET_TOWN_PLAYERS_HOUSE_1F",
        approvedTargets = {
          OVERWORLD = { 82 },
          REDS_HOUSE_1 = { 1 },
          REDS_HOUSE_2 = { 1 },
        },
        blocksPreserved = true,
        semanticsPreserved = true,
      }
    end
  end)
end
