local source = assert(os.getenv("FIRERED_TILESET_PATCH"), "FIRERED_TILESET_PATCH is required")

local PixelData = {}
PixelData.__index = PixelData
function PixelData.new(width, height)
  return setmetatable({ width = width, height = height, pixels = {} }, PixelData)
end
function PixelData:getWidth() return self.width end
function PixelData:getHeight() return self.height end
function PixelData:getPixel(x, y)
  local pixel = self.pixels[y * self.width + x] or { 0, 0, 0, 1 }
  return pixel[1], pixel[2], pixel[3], pixel[4]
end
function PixelData:setPixel(x, y, r, g, b, a)
  self.pixels[y * self.width + x] = { r, g, b, a }
end

love = { image = { newImageData = PixelData.new } }
local Patch = assert(loadfile(source))()

local base = {
  image = "assets/generated/tilesets/overworld.png",
  imageWidth = 16,
  imageHeight = 16,
  tilesPerRow = 2,
  blocks = {
    { 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3 },
  },
  walkable = { 0, 1 },
  doorTiles = { 2 },
  warpTiles = { 2 },
  grassTile = 3,
}

local original = PixelData.new(16, 16)
for y = 0, 15 do
  for x = 0, 15 do
    original:setPixel(x, y, x / 15, y / 15, 0.25, 1)
  end
end

local sheet = Patch.cloneBase(base, original)
assert(sheet:getWidth() == 16 and sheet:getHeight() == 16)
assert(Patch.tileCount(base) == 4)
local x, y = Patch.tileOrigin(base, 3)
assert(x == 8 and y == 8, "tile 3 must occupy the native bottom-right 8x8 slot")

Patch.writeTile(base, sheet, 3, function(px, py)
  return px / 7, py / 7, 1, 1
end)
local r, g, b, a = sheet:getPixel(8, 8)
assert(r == 0 and g == 0 and b == 1 and a == 1)
r, g, b, a = sheet:getPixel(7, 7)
assert(r == 7 / 15 and g == 7 / 15 and b == 0.25 and a == 1,
  "writing one target ID must not resize or alter another 8x8 slot")

local patch = Patch.imageOnlyPatch("firered_tilesheet/generated/test.png", base)
assert(patch.image == "firered_tilesheet/generated/test.png")
assert(patch.imageWidth == base.imageWidth and patch.imageHeight == base.imageHeight)
assert(patch.tilesPerRow == base.tilesPerRow and patch.trueColor == true)
assert(patch.blocks == nil and patch.walkable == nil and patch.doorTiles == nil
  and patch.warpTiles == nil and patch.grassTile == nil,
  "the tilesheet-first patch must not replace block or semantic fields")

local ok = pcall(Patch.writeTile, base, sheet, 4, function() return 0, 0, 0, 1 end)
assert(not ok, "the patch must reject a target tile outside the original sheet")

print("tilesheet-first patch contract: passed")
