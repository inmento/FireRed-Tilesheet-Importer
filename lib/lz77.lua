-- Bounded decoder for standard GBA type-0x10 compressed graphics streams.

local Lz77 = {}

local function fail(message)
  error("FireRed tilesheet prototype: invalid LZ77 stream: " .. message, 3)
end

function Lz77.decode(reader, offset, label)
  label = label or "compressed graphics"
  if reader:u8(offset, label .. " header") ~= 0x10 then
    fail(label .. " does not use type-0x10 compression")
  end
  local outputSize = reader:u24(offset + 1, label .. " size")
  if outputSize < 1 or outputSize > 0x20000 then
    fail(label .. " declares an unsafe output size")
  end

  local out, length, cursor = {}, 0, offset + 4
  local function emit(byte)
    length = length + 1
    if length > outputSize then fail(label .. " expands beyond its declared size") end
    out[length] = string.char(byte)
  end

  while length < outputSize do
    local flags = reader:u8(cursor, label .. " flags")
    cursor = cursor + 1
    for bit = 7, 0, -1 do
      if length >= outputSize then break end
      if math.floor(flags / 2 ^ bit) % 2 == 0 then
        emit(reader:u8(cursor, label .. " literal"))
        cursor = cursor + 1
      else
        local a, b = reader:u8(cursor, label .. " copy"), reader:u8(cursor + 1, label .. " copy")
        cursor = cursor + 2
        local count = math.floor(a / 16) + 3
        local distance = (a % 16) * 0x100 + b + 1
        if distance > length then fail(label .. " has an invalid copy distance") end
        for _ = 1, count do
          local source = out[length - distance + 1]
          if not source then fail(label .. " has an unavailable copy source") end
          emit(source:byte())
          if length >= outputSize then break end
        end
      end
    end
  end
  return table.concat(out), cursor
end

return Lz77
