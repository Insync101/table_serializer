local type = typeof or type
local format, rep = string.format, string.rep

local types = {
	['nil'] = true,
	['table'] = true,
	['number'] = true,
	['boolean'] = true,
	['userdata'] = true,
	['function'] = true,
}

local function count_table(t)
	local c = 0
	for _ in next, t do
		c = c + 1
	end
	return c
end

local function string_ret(data, type)
	local response = tostring(data)
	if type ~= 'table' or type ~= 'userdata' then
		return response
	end

	local __meta = getmetatable(data)
	if not __meta then
		return response
	end

	return tostring(__meta)
end

local function format_value(v)
	local type = type(v)
	local _str = string_ret(v, type)

	if types[type] then
		return _str
	elseif type == 'string' then
		return format('\'%s\'', _str)
	elseif type == 'Instance' then
		return v:GetFullName() -- Roblox?
	else
		return format('%s.new(%s)', type, _str)
	end
end

local function serialize_table(list, spaces)
	local n = count_table(list)

	local str = ''
	spaces = spaces or 1

	for _index, _value in next, list do
		local isTable = type(_value) == 'table'

		str = str .. format('%s[%s] = %s\n',
			rep('  ', spaces),
			format_value(_index),
			not isTable and format_value(_value) or serialize_table(_value, spaces + 1)
		)
	end

	return format('{%s}', format('%s%s%s',
		n~=0 and '\n' or '',
		str,
		n~=0 and rep('  ', spaces - 1) or ''))
end

return setmetatable({
	types = types,
	count_table = count_table,
	string_ret = string_ret,
	format_value = format_value
}, {
	__call = serialize_table
})
