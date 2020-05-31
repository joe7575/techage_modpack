--[[

	SaferLua [safer_lua]
	====================

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	data_struct.lua:
	
	see https://github.com/joe7575/techpack/wiki/Data-Structures

]]--

safer_lua.DataStructHelp = [[
 Data structures as a secure shell over the LUA table type.
 see https://github.com/joe7575/techpack/wiki/Data-Structures
 
 'Arrays' are lists of elements, which can be addressed 
 by means of an index:
 
  a = Array(1,2,3,4)     --> {1,2,3,4}
  a.add(6)               --> {1,2,3,4,6}
  a.set(2, 8)            --> {1,8,3,4,6}
  a.insert(5,7)          --> {1,8,3,4,7,6}
  a.remove(3)            --> {1,8,4,7,6}
  a.insert(1, "hello")   --> {"hello",1,8,4,7,6}
  a.size()               --> function returns 6
  a.memsize() 			 --> return returns 10
  a.next()               --> for loop iterator function  
  a.sort(reverse)        --> sort the array elements in place  

 Unlike arrays, which are indexed by a range of numbers, 
 'stores' are indexed by keys:
 
  s = Store("a",4,"b",5) --> {a = 4, b = 5}
  s.set("val", 12)       --> {a = 4, b = 5, val = 12}
  s.get("val")           --> returns 12
  s.set(0, "hello")      --> {a = 4, b = 5, val = 12, [0] = "hello"}
  s.del("val")           --> {[0] = "hello"}
  s.size()               --> function returns 4
  s.memsize()            --> function returns 8
  s.next()               --> for loop iterator function  
  s.keys(order)          --> return an array with the keys  

 A 'set' is an unordered collection with no duplicate 
 elements.
 
  s = Set("Tom", "Lucy")     
                     --> {Tom = true, Lucy = true}
  s.del("Tom")       --> {Lucy = true}
  s.add("Susi")      --> {Lucy = true, Susi = true}
  s.has("Susi")      --> function returns `true`
  s.has("Mike")      --> function returns `false`
  s.size()           --> function returns 2
  s.memsize()        --> function returns 8
  s.next()           --> for loop iterator function  
]]

local function var_count(v)
	if type(v) == "number" then
		return 1
	elseif type(v) == "boolean" then
		return 1
	elseif v == nil then
		return 0
	elseif type(v) == "string" then
		return #v
	elseif type(v) == "table" then
		return v.memsize()
	else
		return nil
	end
end


function safer_lua.Store(...)

    local new_t = {}
    local mt = {}
	
    local MemSize = 0
	local Size = 0
	local Data = {}

    mt.__newindex = function(t, k, v) return end
	
	mt.count = var_count
	
	new_t.set = function(k,v)
		if type(k) == "number" then
			if rawget(Data, k) then  -- has entry?
				MemSize = MemSize - mt.count(rawget(Data, k))
			else
				Size = Size + 1
			end
			MemSize = MemSize + mt.count(v)
			rawset(Data, k, v)
		elseif type(k) == "string" then
			if rawget(Data, k) then  -- has entry?
				MemSize = MemSize - mt.count(rawget(Data, k))
			else
				MemSize = MemSize + mt.count(k)
				Size = Size + 1
			end
			MemSize = MemSize + mt.count(v)
			rawset(Data, k, v)
		end
	end
 
	new_t.get = function(k)
		return rawget(Data, k)
	end
	
	new_t.del = function(k)
		if rawget(Data, k) then  -- has entry?
			MemSize = MemSize - mt.count(k)
			MemSize = MemSize - mt.count(rawget(Data, k))
			rawset(Data, k, nil)
			Size = Size - 1
		end
	end
	
	new_t.memsize = function(t)
		return MemSize
	end
 
	new_t.size = function(t)
		return Size
	end
 
	new_t.next = function(t)
		local n = nil
		return function ()
			n = next(Data, n)
			if n then return n, Data[n] end
		end
	end
	
	new_t.keys = function(order)
		local keyset = {}
		local n = 0
		local size = 0

		for k,v in pairs(Data) do
			n = n + 1
			keyset[n] = k
			size = size + var_count(k)
		end
		
		if order == "up" then
			table.sort(keyset, function(a,b) return a > b end)
		elseif order == "down" then
			table.sort(keyset)
		end
		local a = safer_lua.Array()
		a.__load(size, keyset)
		return a
	end
	
	new_t.__dump = function()
		-- remove the not serializable meta data
		return {Type = "Store", Size = Size, MemSize = MemSize, Data = Data}
	end
	
	new_t.__load = function(size, memsize, data)
		Size = size
		MemSize = memsize
		Data = data
	end
	
	for idx = 1,select('#',...),2 do
		local k,v = select(idx,...),select(idx+1,...)
		new_t.set(k,v)
	end
	
	return setmetatable(new_t, mt)
end


function safer_lua.Array(...)

    local new_t = {}
    local mt = {}
	
    local MemSize = 0
	local Data = {}

    mt.__newindex = function(t, k, v) return end
	
	mt.count = var_count
	
	for idx = 1,select('#',...) do
		local v = select(idx,...)
		local cnt = mt.count(v)
		if cnt then
			MemSize = MemSize + cnt
			rawset(Data, idx, v)
		end
	end
	
	new_t.add = function(v)
		MemSize = MemSize + mt.count(v)
		local i = #Data + 1
		table.insert(Data, i, v)
	end
	
	new_t.set = function(i,v)
		i = math.min(#Data, i) 
		MemSize = MemSize - mt.count(rawget(Data, i))
		MemSize = MemSize + mt.count(v)
		rawset(Data, i, v)
	end
 
	new_t.get = function(i)
		return Data[i]
	end
 
	new_t.insert = function(i, v)
		MemSize = MemSize + mt.count(v)
		i = math.min(#Data, i) 
		table.insert(Data, i, v)
	end
	
	new_t.remove = function(i)
		local v = table.remove(Data, i)
		MemSize = MemSize - mt.count(v)
		return v
	end
	
	new_t.sort = function(reverse)
		if reverse then
			table.sort(Data, function(a,b) return a > b end)
		else
			table.sort(Data)
		end
	end
 
	new_t.memsize = function(t)
		return MemSize
	end
 
	new_t.size = function(t)
		return #Data
	end
 
	new_t.next = function(t)
		local i = 0
		local n = #Data
		return function ()
			i = i + 1
			if i <= n then return i, Data[i] end
		end
	end
 
	new_t.__dump = function()
		-- remove the not serializable meta data
		return {Type = "Array", MemSize = MemSize, Data = Data}
	end
	
	new_t.__load = function(memsize, data)
		MemSize = memsize
		Data = data
	end
	
	return setmetatable(new_t, mt)
end


function safer_lua.Set(...)

    local new_t = {}
    local mt = {}
	
    local MemSize = 0
	local Size = 0
	local Data = {}

    mt.__newindex = function(t, k, v) return end
	
	mt.count = var_count
	
	for idx = 1,select('#',...) do
		local v = select(idx,...)
		local cnt = mt.count(v)
		if cnt then
			MemSize = MemSize + cnt
			Size = Size + 1
			rawset(Data, v, true)
		end
	end
	
	new_t.add = function(k)
		MemSize = MemSize + mt.count(k)
		rawset(Data, k, true)
		Size = Size + 1
	end
	
	new_t.del = function(k)
		MemSize = MemSize - mt.count(k)
		rawset(Data, k, nil)
		Size = Size - 1
	end
	
	new_t.has = function(k)
		return rawget(Data, k) == true
	end
	
	new_t.memsize = function(t)
		return MemSize
	end
 
	new_t.size = function(t)
		return Size
	end
 
	new_t.next = function(t)
		local i = 0
		local n = nil
		return function ()
			i = i + 1
			n = next(Data, n)
			if n then return i, n end
		end
	end
 
	new_t.__dump = function()
		-- remove the not serializable meta data
		return {Type = "Set", Size = Size, MemSize = MemSize, Data = Data}
	end
	
	new_t.__load = function(size, memsize, data)
		Size = size
		MemSize = memsize
		Data = data
	end
	
	return setmetatable(new_t, mt)
end


-- remove the not serializable meta data
function safer_lua.datastruct_to_table(ds)
	return ds.__dump()
end	
	
-- add the not serializable meta data again
function safer_lua.table_to_datastruct(tbl)
	if tbl.Type == "Store" then
		local s = safer_lua.Store()
		s.__load(tbl.Size, tbl.MemSize, tbl.Data)
		return s
	elseif tbl.Type == "Set" then
		local s = safer_lua.Set()
		s.__load(tbl.Size, tbl.MemSize, tbl.Data)
		return s
	elseif tbl.Type == "Array" then
		local a = safer_lua.Array()
		a.__load(tbl.MemSize, tbl.Data)
		return a
	end
end