-- Tilesheet-first visual patch core.
--
-- This module intentionally knows nothing about map grids, block tables, or
-- collision semantics. It clones an existing 8×8 target sheet and permits a
-- caller to write selected 8×8 visual cells into the same existing tile IDs.
-- The supported tileset patch contains image metadata only, leaving the base
-- block definitions and all semantic fields owned by Gen1Recomp unchanged.

local Patch = {}

local TILE_SIZE = 8

local function fail(message)
  error("FireRed tilesheet prototype: " .. message, 2)
end

local function assertBase(base)
  if type(base) ~= "table" or type(base.image) ~= "string" then
    fail("a base tileset with an image path is required")
  end
  if type(base.imageWidth) ~= "number" or type(base.imageHeight) ~= "number"
      or type(base.tilesPerRow) ~= "number" then
    fail("the base tileset has incomplete image metadata")
  end
  if base.imageWidth % TILE_SIZE ~= 0 or base.imageHeight % TILE_SIZE ~= 0
      or base.tilesPerRow ~= base.imageWidth / TILE_SIZE then
    fail("the base tileset image is not an 8x8-aligned sheet")
  end
end

local function tileCount(base)
  return (base.imageWidth / TILE_SIZE) * (base.imageHeight / TILE_SIZE)
end

local function tileOrigin(base, tileId)
  if type(tileId) ~= "number" or tileId % 1 ~= 0 or tileId < 0 or tileId >= tileCount(base) then
    fail("target tile ID " .. tostring(tileId) .. " is outside the base image")
  end
  return (tileId % base.tilesPerRow) * TILE_SIZE,
    math.floor(tileId / base.tilesPerRow) * TILE_SIZE
end

local function copyPixels(from, to, sourceX, sourceY, targetX, targetY)
  for y = 0, TILE_SIZE - 1 do
    for x = 0, TILE_SIZE - 1 do
      to:setPixel(targetX + x, targetY + y, from:getPixel(sourceX + x, sourceY + y))
    end
  end
end

function Patch.cloneBase(base, sourceImageData)
  assertBase(base)
  if not sourceImageData or sourceImageData:getWidth() ~= base.imageWidth
      or sourceImageData:getHeight() ~= base.imageHeight then
    fail("the base ImageData dimensions do not match its tileset metadata")
  end
  if not (love and love.image and love.image.newImageData) then
    fail("the image runtime is unavailable")
  end

  local sheet = love.image.newImageData(base.imageWidth, base.imageHeight)
  for tileId = 0, tileCount(base) - 1 do
    local x, y = tileOrigin(base, tileId)
    copyPixels(sourceImageData, sheet, x, y, x, y)
  end
  return sheet
end

-- `draw` receives (x, y) for every native destination pixel and must return
-- r, g, b, a. It is deliberately local to one 8×8 target slot; it cannot alter
-- a block definition, reuse a different target ID, or resize source pixels.
function Patch.writeTile(base, sheet, targetTileId, draw)
  assertBase(base)
  if not sheet or sheet:getWidth() ~= base.imageWidth or sheet:getHeight() ~= base.imageHeight then
    fail("generated sheet dimensions do not match the base tileset")
  end
  if type(draw) ~= "function" then fail("a native 8x8 draw function is required") end
  local originX, originY = tileOrigin(base, targetTileId)
  for y = 0, TILE_SIZE - 1 do
    for x = 0, TILE_SIZE - 1 do
      local r, g, b, a = draw(x, y)
      sheet:setPixel(originX + x, originY + y, r, g, b, a)
    end
  end
end

-- Image-only patch contract. No blocks, map data, collision fields, or role
-- lists are supplied. Registry merge retains every existing base definition.
function Patch.imageOnlyPatch(generatedPath, base)
  assertBase(base)
  if type(generatedPath) ~= "string" or generatedPath == "" then
    fail("a generated image path is required")
  end
  return {
    image = generatedPath,
    imageWidth = base.imageWidth,
    imageHeight = base.imageHeight,
    tilesPerRow = base.tilesPerRow,
    trueColor = true,
  }
end

function Patch.tileCount(base)
  assertBase(base)
  return tileCount(base)
end

function Patch.tileOrigin(base, tileId)
  assertBase(base)
  return tileOrigin(base, tileId)
end

return Patch
