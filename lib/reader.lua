-- Bounded reader for the player-imported FireRed English v1.0 ROM.
-- All GBA pointers are converted to file offsets only after bounds checks.

local Reader = {}
Reader.__index = Reader

local function fail(message)
  error("FireRed tilesheet prototype: " .. message, 3)
end

function Reader.new(data, romBase)
  if type(data) ~= "string" then fail("ROM source is not readable") end
  return setmetatable({ data = data, size = #data, romBase = romBase or 0x08000000 }, Reader)
end

function Reader:check(offset, count, label)
  if type(offset) ~= "number" or type(count) ~= "number" or offset < 0 or count < 0
      or offset + count > self.size then
    fail((label or "ROM read") .. " is outside the verified source")
  end
  return offset
end

function Reader:offset(address, label)
  if type(address) ~= "number" then fail("invalid GBA pointer for " .. (label or "read")) end
  local offset = address - self.romBase
  self:check(offset, 1, label or "GBA pointer")
  return offset
end

function Reader:u8(offset, label)
  self:check(offset, 1, label)
  return self.data:byte(offset + 1)
end

function Reader:u16(offset, label)
  self:check(offset, 2, label)
  local lo, hi = self.data:byte(offset + 1, offset + 2)
  return lo + hi * 0x100
end

function Reader:u24(offset, label)
  self:check(offset, 3, label)
  local a, b, c = self.data:byte(offset + 1, offset + 3)
  return a + b * 0x100 + c * 0x10000
end

function Reader:u32(offset, label)
  self:check(offset, 4, label)
  local a, b, c, d = self.data:byte(offset + 1, offset + 4)
  return a + b * 0x100 + c * 0x10000 + d * 0x1000000
end

function Reader:bytes(offset, count, label)
  self:check(offset, count, label)
  return self.data:sub(offset + 1, offset + count)
end

return Reader
