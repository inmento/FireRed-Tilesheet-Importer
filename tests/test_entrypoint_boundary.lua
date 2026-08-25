local mainPath = assert(os.getenv("FIRERED_TILESET_MAIN"), "FIRERED_TILESET_MAIN is required")

local version = "red"
local bases = {
  OVERWORLD = {
    id = "OVERWORLD",
    image = "assets/generated/tilesets/overworld.png",
    imageWidth = 128,
    imageHeight = 48,
    tilesPerRow = 16,
    blocks = { { 0, 1, 2, 3 } },
    walkable = { 0 },
    grassTile = 3,
  },
  REDS_HOUSE_1 = {
    id = "REDS_HOUSE_1",
    image = "assets/generated/tilesets/reds_house.png",
    imageWidth = 128,
    imageHeight = 40,
    tilesPerRow = 16,
    blocks = { { 0, 1, 2, 3 } },
    walkable = { 0 },
  },
  REDS_HOUSE_2 = {
    id = "REDS_HOUSE_2",
    image = "assets/generated/tilesets/reds_house.png",
    imageWidth = 128,
    imageHeight = 40,
    tilesPerRow = 16,
    blocks = { { 0, 1, 2, 3 } },
    walkable = { 0 },
  },
}
local patches, generatedPaths, eventHandler

package.preload["src.core.GameVersion"] = function()
  return { get = function() return version end }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.cache"] = function()
  return {
    install = function() end,
    put = function(path, imageData) generatedPaths[path] = imageData; assert(imageData == "generated") end,
  }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch"] = function()
  return {
    imageOnlyPatch = function(path, base)
      return {
        image = path,
        imageWidth = base.imageWidth,
        imageHeight = base.imageHeight,
        tilesPerRow = base.tilesPerRow,
        trueColor = true,
      }
    end,
  }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.source_plan"] = function()
  return {
    FIRERED_EN_V10 = "revision",
    tilesets = { OVERWORLD = "overworld-plan", REDS_HOUSE_1 = "house1-plan", REDS_HOUSE_2 = "house2-plan" },
  }
end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.firered_sheet_decoder"] = function()
  return {
    buildSheet = function(rom, base, revision, plan, imageData)
      assert(rom == "verified-rom" and revision == "revision")
      assert(base == bases[base.id])
      assert(plan == ({ OVERWORLD = "overworld-plan", REDS_HOUSE_1 = "house1-plan", REDS_HOUSE_2 = "house2-plan" })[base.id])
      if base.id == "OVERWORLD" then
        assert(imageData == "base-image:OVERWORLD")
      else
        assert(imageData == "base-image:REDS_HOUSE_1" or imageData == "base-image:REDS_HOUSE_2")
      end
      return "generated"
    end,
  }
end
package.preload["src.render.Assets"] = function()
  return { imageData = function(path)
    for id, base in pairs(bases) do if path == base.image then return "base-image:" .. id end end
    error("unexpected base image path")
  end }
end

local function makeMod()
  return {
    content = {
      tilesets = {
        get = function(_, id) assert(bases[id], "unexpected target tileset"); return bases[id] end,
        patch = function(_, id, value) patches[id] = value end,
      },
      maps = setmetatable({}, { __index = function() error("maps must not be accessed") end }),
    },
    read = function(_, path) assert(path == "baseroms/firered.gba"); return "verified-rom" end,
    events = { on = function(_, name, callback) assert(name == "game.ready"); eventHandler = callback end },
  }
end

local init = assert(loadfile(mainPath))()
patches, generatedPaths, eventHandler = {}, {}, nil
init(makeMod())
local expected = {
  OVERWORLD = "firered_tilesheet/generated/prototype/overworld-pallet-grass.png",
  REDS_HOUSE_1 = "firered_tilesheet/generated/prototype/reds-house-1-compatible-floor.png",
  REDS_HOUSE_2 = "firered_tilesheet/generated/prototype/reds-house-2-compatible-floor.png",
}
for id, path in pairs(expected) do
  assert(generatedPaths[path] == "generated")
  assert(patches[id] and patches[id].image == path)
  assert(patches[id].blocks == nil and patches[id].walkable == nil and patches[id].grassTile == nil,
    "entrypoint must not replace base block or semantic fields")
end
assert(eventHandler)
local game = {}
eventHandler({ game = game })
assert(game.fireredTilesheetPrototype.blocksPreserved == true)
assert(game.fireredTilesheetPrototype.semanticsPreserved == true)
assert(game.fireredTilesheetPrototype.phase == "evidence-backed-8x8-ledger")
assert(game.fireredTilesheetPrototype.approvedTargets.OVERWORLD[1] == 82)
assert(game.fireredTilesheetPrototype.approvedTargets.REDS_HOUSE_1[1] == 1)
assert(game.fireredTilesheetPrototype.approvedTargets.REDS_HOUSE_2[1] == 1)

version = "blue"
patches, generatedPaths, eventHandler = {}, {}, nil
init(makeMod())
assert(next(patches) == nil and next(generatedPaths) == nil and eventHandler == nil,
  "the experimental proof must remain Red-only")

print("tilesheet-first entrypoint boundary: passed")
