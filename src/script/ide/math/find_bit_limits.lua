-- bitlib test suite
-- (c) Reuben Thomas 2007-2008
-- See README for license
-- NPL.load("(gl)script/ide/math/find_bit_limits.lua");


-- Prepend a binary 1 to a hex constant
function prepend_one (s)
  if s == "0" then
    return "1"
  elseif string.sub (s, 1, 1) == "1" then
    return "3" .. string.sub (s, 2)
  elseif string.sub (s, 1, 1) == "3" then
    return "7" .. string.sub (s, 2)
  elseif string.sub (s, 1, 1) == "7" then
    return "f" .. string.sub (s, 2)
  else
    return "1" .. s
  end
end

-- Invert a hex constant
local inverted = {
  ["0"] = "f", ["1"] = "e", ["2"] = "d", ["3"] = "c",
  ["4"] = "b", ["5"] = "a", ["6"] = "9", ["7"] = "8",
  ["8"] = "7", ["9"] = "6", ["a"] = "5", ["b"] = "4",
  ["c"] = "3", ["d"] = "2", ["e"] = "1", ["f"] = "0",
}
function invert_hex (s)
  for i = 1, #s do
    s = string.sub (s, 1, i - 1) .. inverted[string.sub (s, i, i)] .. string.sub (s, i + 1)
  end
  if string.sub (s, 1, 1) == "0" then
    s = "1" .. s
  end
  return s
end

-- Calculate number of bits in a float mantissa
local float_bits = 0
local float_max = "0"
local float_umax = "0"
local f = 1
repeat
  f = f * 2
  float_bits = float_bits + 1
  if f < f + 1 then
    float_max = prepend_one (float_max)
  end
  float_umax = prepend_one (float_umax)
until f >= f + 1
local float_min = invert_hex (float_max)
print ("#define BITLIB_FLOAT_BITS " .. float_bits)
print ("#define BITLIB_FLOAT_MAX  0x" .. float_max .. "L")
print ("#define BITLIB_FLOAT_MIN  (-0x" .. float_min .. "L)")
print ("#define BITLIB_FLOAT_UMAX 0x" .. float_umax .. "UL")
