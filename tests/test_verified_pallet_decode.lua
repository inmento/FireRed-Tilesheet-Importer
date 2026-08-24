local decoderPath = assert(os.getenv("FIRERED_SHEET_DECODER"), "FIRERED_SHEET_DECODER is required")
local readerPath = assert(os.getenv("FIRERED_SHEET_READER"), "FIRERED_SHEET_READER is required")
local lzPath = assert(os.getenv("FIRERED_SHEET_LZ77"), "FIRERED_SHEET_LZ77 is required")
local patchPath = assert(os.getenv("FIRERED_SHEET_PATCH"), "FIRERED_SHEET_PATCH is required")
local planPath = assert(os.getenv("FIRERED_SHEET_PLAN"), "FIRERED_SHEET_PLAN is required")
local romPath = assert(os.getenv("FIRERED_AUTHORIZED_ROM"), "FIRERED_AUTHORIZED_ROM is required")

local PixelData = {}
PixelData.__index = PixelData
function PixelData.new(width, height)
  return setmetatable({ width = width, height = height, pixels = {} }, PixelData)
end
function PixelData:getWidth() return self.width end
function PixelData:getHeight() return self.height end
function PixelData:getPixel(x, y)
  local p = self.pixels[y * self.width + x] or { 0, 0, 0, 1 }
  return p[1], p[2], p[3], p[4]
end
function PixelData:setPixel(x, y, r, g, b, a)
  self.pixels[y * self.width + x] = { r, g, b, a }
end

love = { image = { newImageData = PixelData.new } }
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.reader"] = function() return assert(loadfile(readerPath))() end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.lz77"] = function() return assert(loadfile(lzPath))() end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch"] = function() return assert(loadfile(patchPath))() end
local Decoder = assert(loadfile(decoderPath))()
local Plan = assert(loadfile(planPath))()

local file = assert(io.open(romPath, "rb"))
local rom = assert(file:read("*a"))
file:close()
assert(#rom == 0x1000000)

local base = {
  image = "assets/generated/tilesets/overworld.png",
  imageWidth = 128,
  imageHeight = 48,
  tilesPerRow = 16,
  grassTile = 82,
  blocks = { { 82, 82, 82, 82 } },
  walkable = { 82 },
}
local original = PixelData.new(128, 48)
for y = 0, 47 do
  for x = 0, 127 do original:setPixel(x, y, 1, 0, 1, 1) end
end

local sheet = Decoder.buildSheet(rom, base, Plan.FIRERED_EN_V10, Plan.tilesets.OVERWORLD, original)
assert(sheet:getWidth() == 128 and sheet:getHeight() == 48)
local originX, originY = (82 % 16) * 8, math.floor(82 / 16) * 8
local changed = 0
for y = 0, 47 do
  for x = 0, 127 do
    local r, g, b, a = sheet:getPixel(x, y)
    local inTarget = x >= originX and x < originX + 8 and y >= originY and y < originY + 8
    if inTarget then
      if not (r == 1 and g == 0 and b == 1 and a == 1) then changed = changed + 1 end
    else
      assert(r == 1 and g == 0 and b == 1 and a == 1,
        "verified-ROM decoder must not write outside its approved target slot")
    end
  end
end
assert(changed > 0 and changed <= 64, "approved source must modify only the target grass 8x8 slot")
assert(base.blocks[1][1] == 82 and base.walkable[1] == 82 and base.grassTile == 82,
  "decoder must not alter base block or semantic data")

print("verified Pallet 8x8 source decode: passed")
