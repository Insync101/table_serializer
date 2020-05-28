type = (typeof or type)
local function compare(o, ...)
	for i, v in next, {...} do
		if o == v then
			return true
		end
	end

	return false
end

local function count_table(t)
	local counter = 0
	for i,v in next, t do
		counter = counter + 1
	end

	return counter
end

local function format_value(val)
	local data = type(val)

	if compare(data, 'number', 'boolean', 'function', 'userdata', 'table', 'nil') then
		return tostring(val)
	elseif data == 'string' then
		return '"' .. val .. '"'
	elseif data == 'Instance' then
		return val:GetFullName()
	else
		return data .. '.new(' .. tostring(val) .. ')'
	end
end

local function serialize_table(t, p, c)
    local s, counter = count_table(t), 1
	local c = c or {}
	local p = p or 1
	local r = s > 0
	local b = ''

	local function format(v, d)
		if d == 'table' then
			return serialize_table(v, p + 1, c)
		end

		return format_value(v)
	end

	for i, v in next, t do
		local d, e = type(v), c[v]

		if d == 'table' and (e and e[2] < p and e[1] == v or v == t) and p ~= 1 then
			return format_value(e[1])
		end

		c[v] = {v, p}
		b = b .. string.rep('  ', p) .. ('[' .. format(i, type(i)) .. '] = ') .. format(v, d) .. (s ~= counter and ',\n' or '\n')
		counter = counter + 1
	end

	return '{' .. (r and '\n' or '') .. b .. string.rep('  ', (p and r) and p-1 or 0) ..'}'
end

return serialize_table
