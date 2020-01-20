local mod_util = {}

function mod_util.is_player_holding_blueprint(player)
    return player.cursor_stack ~= nil
        and player.cursor_stack.valid_for_read
        and player.cursor_stack.is_blueprint
        and player.cursor_stack.is_blueprint_setup()
end

function mod_util.get_table_keys(data)
    local keys = {}
    for key, value in pairs(data) do
        table.insert(keys, key)
    end
    return keys
end

function mod_util.get_table_values(data)
    local values = {}
    for key, value in pairs(data) do
        table.insert(values, value)
    end
    return values
end

function mod_util.table_shallow_copy(data)
    local copy = {}
    for key, value in pairs(data) do
        copy[key] = value
    end
    return copy
end

function mod_util.table_shallow_copy_path(data, props)
    data = mod_util.table_shallow_copy(data)

    if props ~= nil then
        local parent = data
        for _, prop in ipairs(props) do
            parent[prop] = mod_util.table_shallow_copy(parent[prop])
            parent = parent[prop]
        end
    end

    return data
end

function mod_util.string_starts_with(text, starts_with)
    return string.sub(text, 1, string.len(starts_with)) == starts_with
end

-- Source: Emmanuel Oga @ https://github.com/EmmanuelOga/columns/blob/836312be76b85b7f85e0cb2c31f5f22624c62d3e/utils/color.lua
function mod_util.rgb_to_hsl(r, g, b)
    r, g, b = r / 255, g / 255, b / 255

    local cmax, cmin = math.max(r, g, b), math.min(r, g, b)
    local delta = cmax - cmin
    local h, s = 0, 0
    local l = (cmax + cmin) / 2

    -- No difference
    if (delta == 0) then
        h = 0

    -- Red is max
    elseif (cmax == r) then
        h = ((g - b) / delta) % 6

    -- Green is max
    elseif (cmax == g) then
        h = (b - r) / delta + 2

    -- Blue is max
    else
        h = (r - g) / delta + 4
    end

    h = math.floor(h * 60 + 0.5)

    -- Make negative hues positive behind 360°
    if (h < 0) then
        h = h + 360
    end

    -- Calculate saturation
    if delta ~= 0 then
        s = delta / (1 - math.abs(2 * l - 1))
    end

    s = math.floor(s * 1000 + 0.5) / 10
    l = math.floor(l * 1000 + 0.5) / 10

    return h, s, l
end

function mod_util.hsl_to_rgb(h, s, l)
    -- Must be fractions of 1
    s = s / 100
    l = l / 100

    local c = (1 - math.abs(2 * l - 1)) * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = l - c / 2
    local r, g, b = 0, 0, 0

    if 0 <= h and h < 60 then
        r = c
        g = x
        b = 0
    elseif 60 <= h and h < 120 then
        r = x
        g = c
        b = 0
    elseif 120 <= h and h < 180 then
        r = 0
        g = c
        b = x
    elseif 180 <= h and h < 240 then
        r = 0
        g = x
        b = c
    elseif 240 <= h and h < 300 then
        r = x
        g = 0
        b = c
    elseif 300 <= h and h < 360 then
        r = c
        g = 0
        b = x
    end

    r = math.floor((r + m) * 255 + 0.5)
    g = math.floor((g + m) * 255 + 0.5)
    b = math.floor((b + m) * 255 + 0.5)

    return r, g, b
end

return mod_util
