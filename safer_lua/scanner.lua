--[[

	SaferLua [safer_lua]
	====================

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	scanner.lua:

]]--

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function safer_lua:word(ch, pttrn)
	local word = ""
	while ch:match(pttrn) do
		word = word .. ch
		self.pos = self.pos + 1
		ch = self.line:sub(self.pos, self.pos)
	end
	return word
end

function safer_lua:string(pttrn)
	self.pos = self.pos + 1
	local ch = self.line:sub(self.pos, self.pos)
	while not ch:match(pttrn) and self.pos < #self.line do
		if ch == "\\" then
			self.pos = self.pos + 1
		end
		self.pos = self.pos + 1
		ch = self.line:sub(self.pos, self.pos)
	end
	self.pos = self.pos + 1
	-- result is not needed
end

local function lines(str)
   local t = {}
   local function helper(line)
	  table.insert(t, line)
	  return ""
   end
   helper((str:gsub("(.-)\r?\n", helper)))
   return t
end

function safer_lua:scanner(text)
	local lToken = {}
	for idx, line in ipairs(lines(text)) do
		self.line = line
		self.pos = 1
		self.line = trim(self.line)
		self.line = self.line:split("--", true)[1]
		table.insert(lToken, idx)  -- line number
		if self.line then
			-- devide line in tokens
			while true do
				if self.pos > #self.line then break end
				local ch = self.line:sub(self.pos, self.pos)
				if ch:match("[%u%l_]") then                       -- identifier?
					table.insert(lToken, self:word(ch, "[%w_]"))
				elseif ch:match("[%d]") then  -- number?
					table.insert(lToken, self:word(ch, "[%d%xx]"))
				elseif ch:match("'") then                         -- string?
					self:string("'")
				elseif ch:match('"') then                         -- string?
					self:string('"')
				elseif ch:match("[%s]") then                      -- Space?
					self.pos = self.pos + 1
				elseif ch:match("[:{}]") then                     -- critical tokens?
					table.insert(lToken,ch)
					self.pos = self.pos + 1
				else
					self.pos = self.pos + 1
				end
			end
		end
	end
	return lToken
end

local InvalidKeywords = {
	["while"] = true, 
	["repeat"] = true, 
	["until"] = true, 
	["for"] = true, 
	["range"] = true, 
	--["function"] = true,
	["_G"] = true,
	["__load"] = true,
	["__dump"] = true,
}

local InvalidChars = {
	[":"] = true,
	["{"] = true,
	["["] = true,
	["]"] = true,
	["}"] = true,
}

function safer_lua:check(pos, text, label, err_clbk)
	local lToken = self:scanner(text)
	local lineno = 0
	local errno = 0
	for idx,token in ipairs(lToken) do
		if type(token) == "number" then
			lineno = token
		elseif InvalidKeywords[token] then
			if token == "for" then
				 -- invalid for statement?
				if lToken[idx + 3] == "in" and lToken[idx + 5] == "next" then
					--
				elseif lToken[idx + 2] == "in" and lToken[idx + 3] == "range" then
					--
				else
					err_clbk(pos, label..":"..lineno..": Invalid use of 'for'")
					errno = errno + 1
				end
			elseif token == "range" then
				if lToken[idx - 1] ~= "in" then
					err_clbk(pos, label..":"..lineno..": Invalid use of 'range'")
					errno = errno + 1
				end
			else
				err_clbk(pos, label..":"..lineno..": Invalid keyword '"..token.."'")
				errno = errno + 1
			end
		elseif InvalidChars[token] then
			err_clbk(pos, label..":"..lineno..": Invalid character '"..token.."'")
			errno = errno + 1
		end
	end
	return errno
end
