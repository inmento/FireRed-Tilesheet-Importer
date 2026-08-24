-- Private in-memory generated-sheet bridge for the tilesheet-first prototype.
--
-- Generated ImageData remains local to the player process. Nothing decoded from
-- FireRed is written to disk, committed, or included in the mod package.

local Cache = {}

local PREFIX = "firered_tilesheet/generated/"
local atlasCache = {}
local imageCache = {}

local function owns(path)
  return type(path) == "string" and path:sub(1, #PREFIX) == PREFIX
end

function Cache.put(path, imageData)
  assert(owns(path), "FireRed tilesheet prototype: generated image path is outside its namespace")
  assert(imageData, "FireRed tilesheet prototype: generated image is missing ImageData")
  atlasCache[path] = imageData
  imageCache[path] = nil
end

function Cache.install()
  local Assets = require("src.render.Assets")
  local bridge = Assets._fireredTilesheetPrototypeBridge
  if bridge then
    bridge.atlasCache, bridge.imageCache = atlasCache, imageCache
    return
  end

  bridge = { atlasCache = atlasCache, imageCache = imageCache }
  Assets._fireredTilesheetPrototypeBridge = bridge

  local oldImage, oldImageData, oldExists = Assets.image, Assets.imageData, Assets.exists
  Assets.imageData = function(path)
    if owns(path) then
      local imageData = bridge.atlasCache[path]
      assert(imageData, "FireRed tilesheet prototype: missing generated sheet " .. tostring(path))
      return imageData
    end
    return oldImageData(path)
  end
  Assets.image = function(path)
    if owns(path) then
      local image = bridge.imageCache[path]
      if not image then
        local imageData = bridge.atlasCache[path]
        assert(imageData, "FireRed tilesheet prototype: missing generated sheet " .. tostring(path))
        image = love.graphics.newImage(imageData)
        image:setFilter("nearest", "nearest")
        bridge.imageCache[path] = image
      end
      return image
    end
    return oldImage(path)
  end
  Assets.exists = function(path)
    if owns(path) then return bridge.atlasCache[path] ~= nil end
    return oldExists(path)
  end
end

return Cache
