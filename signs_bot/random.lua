--[[

	Signs Bot
	=========

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Signs Bot: Random Series 

]]--

-- generate a table of unique pseudo random numbers
local function gen_serie(inv_size)
	local tbl = {}
	local offs = inv_size/2
	if offs % 2 == 1 then
		offs = offs + 1
	end
	local index = 1
	
	for n = 1, (inv_size*2) do
		tbl[#tbl + 1] = index
		index = ((index + offs) % inv_size) + 1
	end
	return tbl
end

-- Pseudo numbers series to iterate "randomly" through inventories
local InvRandomSeries = {}

local function get_serie(inv_size)
	if not InvRandomSeries[inv_size] then
		InvRandomSeries[inv_size] = gen_serie(inv_size)
	end
	return InvRandomSeries[inv_size]
end

local function random(inv_size)
	local t = get_serie(inv_size)
	local i = 0
	local n = #t/2
	local offs = math.random(n)
	return function ()
		i = i + 1
		if i <= n then return t[i+offs] end
	end
end


--
--  API
--
-- func signs_bot.random(inv_size)
--   random iterator providing 'inv_size' possible bot inventory stack numbers
--   inv_size must be even and between 4 and 64
signs_bot.random = random


--
-- Test
--

--for size = 4,64,2 do
--	local tbl = {}
--	for idx in random(size) do
--		tbl[#tbl + 1] = idx
--	end
--	print(table.concat(tbl, ", "))
--end