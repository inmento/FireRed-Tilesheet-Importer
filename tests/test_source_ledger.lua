local decoderPath = assert(os.getenv("FIRERED_SHEET_DECODER"), "FIRERED_SHEET_DECODER is required")

package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.reader"] = function() return {} end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.lz77"] = function() return {} end
package.preload["mods.FIRERED_TILESET_SHEET_PROTOTYPE.lib.tilesheet_patch"] = function()
  return { tileCount = function() return 96 end }
end

local Decoder = assert(loadfile(decoderPath))()
local base = { grassTile = 82 }

local function write(target, role, source)
  return {
    targetTile = target,
    requiredBaseRole = role,
    source = source or {
      layout = "palletTown",
      x = 2,
      y = 2,
      cell = 0,
      expectedMapEntry = 0x32A6,
      expectedBank = "secondary",
      expectedMetatile = 38,
    },
  }
end

local function plan(writes, approvals)
  return { writes = writes, approvedTargets = approvals }
end

local approved = {
  [82] = { requiredBaseRole = "grass", evidence = "verified full grass reuse set" },
}

assert(Decoder.validateLedger(base, plan({ write(82, "grass") }, approved)) == nil)

local function rejects(expected, value)
  local ok, err = pcall(Decoder.validateLedger, base, value)
  assert(not ok, "expected ledger validation to reject")
  assert(tostring(err):find(expected, 1, true), "expected '" .. expected .. "', got '" .. tostring(err) .. "'")
end

rejects("no explicit target-slot approval", plan({ write(81, "grass") }, approved))
rejects("more than once", plan({ write(82, "grass"), write(82, "grass") }, approved))
rejects("does not match its approved base role", plan({ write(82, "terrain") }, approved))
rejects("outside the base sheet", plan({ write(96, "grass") }, approved))
rejects("incomplete source declaration", plan({ write(82, "grass", { layout = "palletTown" }) }, approved))
rejects("invalid 8x8 source cell", plan({ write(82, "grass", {
  layout = "palletTown", x = 2, y = 2, cell = 4, expectedMapEntry = 0x32A6,
  expectedBank = "secondary", expectedMetatile = 38,
}) }, approved))

print("FireRed tilesheet source ledger: passed")
