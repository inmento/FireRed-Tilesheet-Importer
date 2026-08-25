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

local function assertPlan(tilesetName)
  local base = {
    image = "assets/generated/tilesets/reds_house.png",
    imageWidth = 128,
    imageHeight = 40,
    tilesPerRow = 16,
    blocks = { { 1, 1, 1, 1 } },
    walkable = { 1 },
  }
  local original = PixelData.new(128, 40)
  for y = 0, 39 do
    for x = 0, 127 do original:setPixel(x, y, 1, 0, 1, 1) end
  end

  local sheet = Decoder.buildSheet(rom, base, Plan.FIRERED_EN_V10, Plan.tilesets[tilesetName], original)
  assert(sheet:getWidth() == 128 and sheet:getHeight() == 40)
  local originX, originY = 8, 0 -- Native target slot 1 in a 16-column 8×8 sheet.
  local changed = 0
  for y = 0, 39 do
    for x = 0, 127 do
      local r, g, b, a = sheet:getPixel(x, y)
      local inTarget = x >= originX and x < originX + 8 and y >= originY and y < originY + 8
      if inTarget then
        if not (r == 1 and g == 0 and b == 1 and a == 1) then changed = changed + 1 end
      else
        assert(r == 1 and g == 0 and b == 1 and a == 1,
          "verified-ROM house decoder must not write outside its approved floor target slot")
      end
    end
  end
  assert(changed > 0 and changed <= 64, "approved house source must modify only one target 8x8 slot")
  assert(base.blocks[1][1] == 1 and base.walkable[1] == 1,
    "house decoder must not alter base block or semantic data")
end

assertPlan("REDS_HOUSE_1")
assertPlan("REDS_HOUSE_2")
print("verified Player's House compatible floor source decode: passed")
