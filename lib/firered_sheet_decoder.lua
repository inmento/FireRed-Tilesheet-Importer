-- Verified-ROM FireRed 8×8 source decoder for the tilesheet-first proof.
--
-- It resolves FireRed's raw 4bpp tiles through the selected map layout,
-- primary/secondary tilesets, metatile entries, palettes, flips, and two visual
-- layers. Its only output is a native 8×8 pixel function for a ledger-approved
-- existing Gen 1 target tile slot.

local Reader = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.reader")
local Lz77 = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.lz77")
local Patch = require("mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch")

local Decoder = {}

local PRIMARY_METATILES = 640
local SECONDARY_METATILES = 384
local PRIMARY_PALETTES = 7
local TILE_BYTES = 32

local function fail(message)
  error("FireRed tilesheet prototype: " .. message, 2)
end

local function color15(value)
  return (value % 32) / 31,
    (math.floor(value / 32) % 32) / 31,
    (math.floor(value / 1024) % 32) / 31,
    1
end

local function decodeHeader(reader, address, expectedSecondary, paletteCount, label)
  local offset = reader:offset(address, label .. " header")
  local compressed = reader:u8(offset, label .. " compression") ~= 0
  local secondary = reader:u8(offset + 1, label .. " secondary flag") ~= 0
  if secondary ~= expectedSecondary then fail(label .. " has an unexpected primary/secondary flag") end

  local tilesAddress = reader:u32(offset + 4, label .. " tiles pointer")
  local palettesAddress = reader:u32(offset + 8, label .. " palette pointer")
  local metatilesAddress = reader:u32(offset + 12, label .. " metatile pointer")
  local tilesOffset = reader:offset(tilesAddress, label .. " tiles")
  local paletteOffset = reader:offset(palettesAddress, label .. " palettes")
  local metatileOffset = reader:offset(metatilesAddress, label .. " metatiles")
  local tiles
  if compressed then
    tiles = Lz77.decode(reader, tilesOffset, label .. " tiles")
  else
    fail(label .. " uses unsupported uncompressed tiles for this narrow proof")
  end
  if #tiles < TILE_BYTES or #tiles % TILE_BYTES ~= 0 then
    fail(label .. " decoded to an invalid 4bpp tile sheet")
  end

  local palettes = {}
  for palette = 0, paletteCount - 1 do
    palettes[palette] = {}
    for index = 0, 15 do
      local r, g, b, a = color15(reader:u16(paletteOffset + (palette * 16 + index) * 2,
        label .. " palette color"))
      palettes[palette][index] = { r, g, b, a }
    end
  end

  return {
    tiles = tiles,
    tileCount = #tiles / TILE_BYTES,
    palettes = palettes,
    metatileOffset = metatileOffset,
    metatileCount = expectedSecondary and SECONDARY_METATILES or PRIMARY_METATILES,
  }
end

local function entryParts(value)
  return {
    tile = value % 0x400,
    hflip = math.floor(value / 0x400) % 2 == 1,
    vflip = math.floor(value / 0x800) % 2 == 1,
    palette = math.floor(value / 0x1000) % 16,
  }
end

local function decodeLayout(reader, plan)
  local layout = plan.palletLayout
  local offset = reader:offset(layout.address, "Pallet Town layout")
  local width, height = reader:u32(offset, "Pallet Town width"), reader:u32(offset + 4, "Pallet Town height")
  if width ~= layout.width or height ~= layout.height then
    fail("Pallet Town layout dimensions do not match the approved ledger")
  end
  local mapAddress = reader:u32(offset + 12, "Pallet Town map block pointer")
  local primaryHeader = reader:u32(offset + 16, "Pallet Town primary tileset pointer")
  local secondaryHeader = reader:u32(offset + 20, "Pallet Town secondary tileset pointer")
  if primaryHeader ~= layout.primaryHeader or secondaryHeader ~= layout.secondaryHeader then
    fail("Pallet Town tileset pairing does not match the approved ledger")
  end
  return { width = width, height = height, mapOffset = reader:offset(mapAddress, "Pallet Town block data") }
end

local function layoutEntry(reader, layout, x, y)
  if x < 0 or y < 0 or x >= layout.width or y >= layout.height then
    fail("approved source cell is outside the declared FireRed layout")
  end
  return reader:u16(layout.mapOffset + (y * layout.width + x) * 2, "Pallet Town map entry")
end

local function metatileBank(primary, secondary, mapEntry)
  local id = mapEntry % 0x400
  if id < PRIMARY_METATILES then return primary, id, "primary" end
  if id < PRIMARY_METATILES + SECONDARY_METATILES then return secondary, id - PRIMARY_METATILES, "secondary" end
  fail("source map entry references an unavailable metatile")
end

local function paletteBank(primary, secondary, paletteId)
  return paletteId < PRIMARY_PALETTES and primary or secondary
end

local function tileColor(primary, secondary, tileId, x, y)
  -- FireRed stores primary graphics in VRAM slots 0..639 and secondary
  -- graphics after them. Palette selection is a separate metatile-entry field;
  -- it must not decide which raw graphics bank the tile reference reads from.
  local bank, localTile
  if tileId < PRIMARY_METATILES then
    bank, localTile = primary, tileId
  else
    bank, localTile = secondary, tileId - PRIMARY_METATILES
  end
  if localTile < 0 or localTile >= bank.tileCount then
    fail("source metatile references a tile outside its decoded sheet")
  end
  local byte = bank.tiles:byte(localTile * TILE_BYTES + y * 4 + math.floor(x / 2) + 1)
  if not byte then fail("source tile pixel is unavailable") end
  return x % 2 == 0 and byte % 16 or math.floor(byte / 16) % 16
end

-- The runtime plan is a safety boundary, not just a convenience list. Each
-- target tile must have a separate approval record explaining why its complete
-- unchanged Gen 1 reuse set accepts one FireRed 8×8 visual. This keeps a
-- future broad importer from treating nearby source cells as an automatic
-- 16×16-to-8×8 remap.
local function validateLedger(base, tilesetPlan)
  if type(tilesetPlan) ~= "table" or type(tilesetPlan.writes) ~= "table" then
    fail("the target tileset has no approved source ledger")
  end
  if type(tilesetPlan.approvedTargets) ~= "table" then
    fail("the target tileset has no approved target-slot ledger")
  end

  local targetCount = Patch.tileCount(base)
  local seen = {}
  for index, write in ipairs(tilesetPlan.writes) do
    if type(write) ~= "table" then fail("ledger write " .. index .. " is invalid") end
    local target = write.targetTile
    if type(target) ~= "number" or target % 1 ~= 0 or target < 0 or target >= targetCount then
      fail("ledger target tile " .. tostring(target) .. " is outside the base sheet")
    end
    if seen[target] then fail("ledger writes target tile " .. target .. " more than once") end
    seen[target] = true

    local approval = tilesetPlan.approvedTargets[target]
    if type(approval) ~= "table" then
      fail("ledger target tile " .. target .. " has no explicit target-slot approval")
    end
    if type(approval.evidence) ~= "string" or approval.evidence == "" then
      fail("ledger target tile " .. target .. " has no visual-reuse evidence")
    end
    if write.requiredBaseRole ~= approval.requiredBaseRole then
      fail("ledger target tile " .. target .. " does not match its approved base role")
    end
    if write.requiredBaseRole == "grass" and base.grassTile ~= target then
      fail("approved target tile is no longer the base grass semantic tile")
    end

    local source = write.source
    if type(source) ~= "table" then fail("ledger target tile " .. target .. " has no source declaration") end
    if type(source.layout) ~= "string" or type(source.x) ~= "number" or type(source.y) ~= "number"
        or type(source.cell) ~= "number" or type(source.expectedMapEntry) ~= "number"
        or type(source.expectedBank) ~= "string" or type(source.expectedMetatile) ~= "number" then
      fail("ledger target tile " .. target .. " has an incomplete source declaration")
    end
    if source.cell % 1 ~= 0 or source.cell < 0 or source.cell > 3 then
      fail("ledger target tile " .. target .. " has an invalid 8x8 source cell")
    end
  end
end

local function resolveCell(primary, secondary, tileset, metatileId, cell)
  if cell < 0 or cell > 3 then fail("approved source metatile cell must be 0 through 3") end
  if metatileId < 0 or metatileId >= tileset.metatileCount then
    fail("approved source metatile is outside its selected bank")
  end
  local pixels = {}
  for layer = 0, 1 do
    local entry = entryParts(primary._reader:u16(tileset.metatileOffset +
      (metatileId * 8 + layer * 4 + cell) * 2, "FireRed metatile cell"))
    local bank = paletteBank(primary, secondary, entry.palette)
    local palette = bank.palettes[entry.palette]
    if not palette then fail("source palette is unavailable") end
    for y = 0, 7 do
      for x = 0, 7 do
        local sx = entry.hflip and 7 - x or x
        local sy = entry.vflip and 7 - y or y
        local colorIndex = tileColor(primary, secondary, entry.tile, sx, sy)
        if layer == 0 or colorIndex ~= 0 then
          pixels[y * 8 + x + 1] = palette[colorIndex]
        end
      end
    end
  end
  return pixels
end

function Decoder.buildSheet(rom, base, revision, tilesetPlan, baseImageData)
  if type(rom) ~= "string" or #rom ~= revision.romSize then
    fail("the verified FireRed source does not have the expected 16 MiB size")
  end
  if rom:byte(0xBD) ~= 0 then fail("only FireRed English v1.0 is supported") end
  validateLedger(base, tilesetPlan)

  local reader = Reader.new(rom, revision.romBase)
  local primary = decodeHeader(reader, revision.headers.general, false, PRIMARY_PALETTES, "General")
  local secondary = decodeHeader(reader, revision.headers.palletTown, true, 16, "Pallet Town")
  primary._reader, secondary._reader = reader, reader
  local layout = decodeLayout(reader, revision)
  local sheet = Patch.cloneBase(base, baseImageData)

  for _, write in ipairs(tilesetPlan.writes) do
    local source = write.source
    if source.layout ~= "palletTown" then fail("the narrow proof supports only the declared Pallet layout") end
    local mapEntry = layoutEntry(reader, layout, source.x, source.y)
    if mapEntry ~= source.expectedMapEntry then fail("source map entry does not match the approved ledger") end
    local bank, metatileId, bankName = metatileBank(primary, secondary, mapEntry)
    if bankName ~= source.expectedBank or metatileId ~= source.expectedMetatile then
      fail("source metatile does not match the approved ledger")
    end
    local pixels = resolveCell(primary, secondary, bank, metatileId, source.cell)
    Patch.writeTile(base, sheet, write.targetTile, function(x, y)
      local pixel = pixels[y * 8 + x + 1]
      return pixel[1], pixel[2], pixel[3], pixel[4]
    end)
  end

  return sheet
end

Decoder.validateLedger = validateLedger

return Decoder
