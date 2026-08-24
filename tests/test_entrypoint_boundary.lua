local mainPath = assert(os.getenv("FIRERED_TILESET_MAIN"), "FIRERED_TILESET_MAIN is required")

local version = "red"
local base = {
  id = "OVERWORLD",
  image = "assets/generated/tilesets/overworld.png",
  imageWidth = 128,
  imageHeight = 48,
  tilesPerRow = 16,
  blocks = { { 0, 1, 2, 3 } },
  walkable = { 0 },
  grassTile = 3,
}
local patch, generatedPath, eventHandler

package.preload["src.core.GameVersion"] = function()
  return { get = function() return version end }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.cache"] = function()
  return {
    install = function() end,
    put = function(path, imageData) generatedPath = path; assert(imageData == "generated") end,
  }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch"] = function()
  return {
    imageOnlyPatch = function(path, receivedBase)
      assert(receivedBase == base)
      return { image = path, imageWidth = 128, imageHeight = 48, tilesPerRow = 16, trueColor = true }
    end,
    tileCount = function() return 96 end,
  }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.source_plan"] = function()
  return { FIRERED_EN_V10 = "revision", tilesets = { OVERWORLD = "plan" } }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.firered_sheet_decoder"] = function()
  return {
    buildSheet = function(rom, receivedBase, revision, plan, imageData)
      assert(rom == "verified-rom" and receivedBase == base and revision == "revision" and plan == "plan")
      assert(imageData == "base-image")
      return "generated"
    end,
  }
end
package.preload["src.render.Assets"] = function()
  return { imageData = function(path) assert(path == base.image); return "base-image" end }
end

local function makeMod()
  return {
    content = {
      tilesets = {
        get = function(_, id) assert(id == "OVERWORLD"); return base end,
        patch = function(_, id, value) assert(id == "OVERWORLD"); patch = value end,
      },
      maps = setmetatable({}, { __index = function() error("maps must not be accessed") end }),
    },
    read = function(_, path) assert(path == "baseroms/firered.gba"); return "verified-rom" end,
    events = { on = function(_, name, callback) assert(name == "game.ready"); eventHandler = callback end },
  }
end

local init = assert(loadfile(mainPath))()
init(makeMod())
assert(generatedPath == "firered_tilesheet/generated/prototype/overworld-pallet-grass.png")
assert(patch and patch.image == generatedPath)
assert(patch.blocks == nil and patch.walkable == nil and patch.grassTile == nil,
  "entrypoint must not replace base block or semantic fields")
assert(eventHandler)
local game = {}
eventHandler({ game = game })
assert(game.fireredTilesheetPrototype.blocksPreserved == true)
assert(game.fireredTilesheetPrototype.semanticsPreserved == true)
assert(game.fireredTilesheetPrototype.tileCount == 96)
assert(game.fireredTilesheetPrototype.phase == "verified-pallet-grass-8x8-proof")
assert(game.fireredTilesheetPrototype.targetTile == 82)

version = "blue"
patch, generatedPath, eventHandler = nil, nil, nil
init(makeMod())
assert(patch == nil and generatedPath == nil and eventHandler == nil,
  "the experimental proof must remain Red-only")

print("tilesheet-first entrypoint boundary: passed")
