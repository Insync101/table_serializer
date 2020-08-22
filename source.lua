type = (typeof or type)
local function compare(o, ...)
    for i, v in next, {...} do
        if o == v then
            return true
        end
    end

    return false
end

local function countTable(t)
    local counter = 0
    for i,v in next, t do
        counter = counter + 1
    end

    return counter
end

local function stringRet(v)
    local mt = (getrawmetatable or getmetatable)(v)
    local tostring_meta, addr

    if not mt then
        return tostring(v)
    end

    tostring_meta = mt.__tostring
    setreadonly(mt, false)

    mt.__tostring = nil
    addr = tostring(v)

    mt.__tostring = tostring_meta
    setreadonly(mt, true)

    return addr
end

local function formatValue(val)
    local data, ret = type(val)

    if compare(data, 'number', 'boolean', 'function', 'thread', 'nil') then
        ret = tostring(val)
    elseif compare(data, 'userdata', 'table') then
        ret = stringRet(val)
    elseif data == 'string' then
        ret = '"' .. val .. '"'
    elseif data == 'Instance' then
        ret = val:GetFullName()
    else
        ret = data .. '.new(' .. tostring(val) .. ')'
    end

    return ret
end

local function serializeTable(t, p, c)
    local s, counter = countTable(t), 1
    local c = c or {}
    local p = p or 1
    local r = s > 0
    local b = ''

    local function format(v, d)
        if d == 'table' then
            return serializeTable(v, p + 1, c)
        end

        return formatValue(v)
    end

    for i, v in next, t do
        local d, e = type(v), c[v]

        if d == 'table' and (e and e[2] < p and e[1] == v or v == t) and p ~= 1 then
            return formatValue(e[1])
        end

        c[v] = {v, p}
        b = b .. string.rep('  ', p) .. ('[' .. format(i, type(i)) .. '] = ') .. format(v, d) .. (s ~= counter and ',\n' or '\n')
        counter = counter + 1
    end

    return '{' .. (r and '\n' or '') .. b .. string.rep('  ', (p and r) and p-1 or 0) ..'}'
end

return serializeTable
