type = typeof or type
local str_types = {
    ['boolean'] = true,
    ['table'] = true,
    ['userdata'] = true,
    ['table'] = true,
    ['function'] = true,
    ['number'] = true,
    ['nil'] = true
}

local rawequal = rawequal or function(a, b)
    return a == b
end

local function count_table(t)
    local c = 0
    for i, v in next, t do
        c = c + 1
    end

    return c
end

local function string_ret(o, typ)
    local ret, mt, old_func
    if not (typ == 'table' or type == 'userdata') then
        return tostring(o)
    end
    mt = (getrawmetatable or getmetatable)(o)
    if not mt then 
        return tostring(o)
    end

    old_func = rawget(mt, '__tostring')
    rawset(mt, '__tostring', nil)
    ret = tostring(o)
    rawset(mt, '__tostring', old_func)
    return ret
end

local function format_value(v)
    local typ = type(v)

    if str_types[typ] then
        return string_ret(v, typ)
    elseif typ == 'string' then
        return '"'..v..'"'
    elseif typ == 'Instance' then
        return v:GetFullName()
    else
        return typ..'.new(' .. tostring(v) .. ')'
    end
end

local function serialize_table(t, p, c, s)
    local str = ""
    local n = count_table(t)
    local e = n > 0

    c = c or {}
    p = p or 1
    s = s or string.rep

    local function is_recursive(v, e)
        return (e[2] < p and e[1] == v or rawequal and rawequal(v, t)) and p ~= 1
    end

    local function localized_format(v, typ)
        return (typ == 'table' and not is_recursive(v, c[v])) and serialize_table(v, p + 1, c) or format_value(v)
    end

    for i, v in next, t do
        local typ_i, typ_v = type(i), type(v)
        c[i], c[v] = typ_i == 'table' and {i, p}, typ_v == 'table' and {v, p}

        str = str .. s('  ', p) .. '[' .. localized_format(i, typ_i) .. ']' .. ' = ' .. localized_format(v, typ_v) .. '\n'
    end

    return ('{' .. (e and '\n' or '')) .. str .. (e and s('  ', p - 1) or '') .. '}'
end

return serialize_table
