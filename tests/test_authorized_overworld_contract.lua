local sourcePath = "/home/ubuntu/gym_refs/red/tilesets.lua"
local tilesets = assert(loadfile(sourcePath))()
local overworld = assert(tilesets.OVERWORLD)

assert(overworld.image == "assets/generated/tilesets/overworld.png")
assert(overworld.imageWidth == 128 and overworld.imageHeight == 48 and overworld.tilesPerRow == 16)
assert(#overworld.blocks == 128)
assert(overworld.grassTile == 82)
assert(type(overworld.blocks[1]) == "table" and #overworld.blocks[1] == 16)

local walkable = {}
for _, tile in ipairs(overworld.walkable) do walkable[tile] = true end
assert(walkable[overworld.grassTile], "the existing grass tile must remain walkable")
assert(overworld.doorTiles[1] == 27 and overworld.warpTiles[1] == 27)

print("authorized Red OVERWORLD contract: passed")
