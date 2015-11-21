--[[
Title: TEA-1.0
Author(s): LiXizhi, code is based on http://www.wowace.com/wiki/TEA-1.0
Desc: Tiny Encryption Algorythm implementation
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/TEA.lua");
local TEA = commonlib.LibStub("TEA")
local s0 = 'message digest'
local s3 = '12345678901234567890123456789012345678901234567890123456789012345678901234567890'
local k3 = TEA:GenerateKey(s3)
assert(TEA:Decrypt(TEA:Encrypt(s0, k3), k3) == s0)
-------------------------------------------------------
]]

local major, minor = "TEA", "$Rev: 61643 $"

NPL.load("(gl)script/ide/math/MD5.lua");
local md5 = commonlib.LibStub("MD5")

local lib, oldMinor = commonlib.LibStub:NewLibrary(major, minor)
if not lib then return end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function StringToIntArray(text)
	local a, l = {}, string.len(text)

	for i = 1, l, 4 do
		local acc = 0

		if l >= i + 3 then
			acc = acc + string.byte(text, i + 3) + string.byte(text, i + 2) * 256 + string.byte(text, i + 1) * 65536 + string.byte(text, i + 0) * 16777216
		elseif l >= i + 2 then
			acc = acc + string.byte(text, i + 2) * 256 + string.byte(text, i + 1) * 65536 + string.byte(text, i + 0) * 16777216
		elseif l >= i + 1 then
			acc = acc + string.byte(text, i + 1) * 65536 + string.byte(text, i + 0) * 16777216
		elseif l >= i + 0 then
			acc = acc + string.byte(text, i + 0) * 16777216
		end

		table.insert(a, acc)
	end

	if (math.fmod(#(a), 2) == 1) then
		table.insert(a, 0)
	end

	return a
end

local function IntArrayToString(array)
	local a = {}

	for i = 1, #(array) do
		for j = 3, 0, -1 do
			local b = bit.band(bit.rshift(array[i], j * 8), 255)

			table.insert(a, string.char(b))
		end
	end

	while true do
		local n = #(a)

		if n > 0 and string.byte(a[n]) == 0 then
			table.remove(a, n)
		else
			break
		end
	end

	return table.concat(a)
end

function lib:GenerateKey(key)
	return md5:MD5AsTable(key)
end

local maxint = tonumber('ffffffff', 16)
local delta = tonumber('9e3779b9', 16)
function lib:Encrypt(text, key)
	local a, b, c, d = key[1], key[2], key[3], key[4]
	local ia = StringToIntArray(text)

	local oa = {}

	for i = 1, #(ia), 2 do
		local y, z = ia[i + 0], ia[i + 1]
		local sum, n = 0, 32

		while (n > 0) do
			sum = bit.band(sum + delta, maxint)
			y = bit.band(y + bit.bxor(bit.lshift(z, 4) + a, z + sum, bit.rshift(z, 5) + b), maxint)
			z = bit.band(z + bit.bxor(bit.lshift(y, 4) + c, y + sum, bit.rshift(y, 5) + d), maxint)
			n = n - 1
		end

		table.insert(oa, y)
		table.insert(oa, z)
	end

	return oa
end

function lib:Decrypt(ia, key)
	local a, b, c, d = key[1], key[2], key[3], key[4]

	local oa = {}

	for i = 1, #(ia), 2 do
		local y, z = ia[i + 0], ia[i + 1]
		local sum, n = tonumber('c6ef3720', 16), 32

		while (n > 0) do
			z = bit.band(z - bit.bxor(bit.lshift(y, 4) + c, y + sum, bit.rshift(y, 5) + d), maxint)
			y = bit.band(y - bit.bxor(bit.lshift(z, 4) + a, z + sum, bit.rshift(z, 5) + b), maxint)
			sum = bit.band(sum - delta, maxint)
			n = n - 1
		end

		table.insert(oa, y)
		table.insert(oa, z)
	end

	return IntArrayToString(oa)
end

