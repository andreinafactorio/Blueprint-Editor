local proto = {}

local function get_proto_localised_name(collection, proto, default_locale_prefix)
    local proto_name = nil
    local localised_name = nil

    if type(proto) == "string" and collection[proto] ~= nil then
        proto_name = proto
        localised_name = collection[proto_name].localised_name
    elseif type(proto) == "table" then
        proto_name = proto.name
        localised_name = proto.localised_name
    end

    if localised_name == nil then
        localised_name = { default_locale_prefix .. "." .. proto_name }
    end

    return localised_name
end

function proto.get_entity_localised_name(entity)
    return get_proto_localised_name(game.entity_prototypes, entity, "entity-name")
end

function proto.get_item_localised_name(item)
    return get_proto_localised_name(game.item_prototypes, item, "item-name")
end

function proto.get_fluid_localised_name(fluid)
    return get_proto_localised_name(game.fluid_prototypes, fluid, "fluid-name")
end

function proto.get_recipe_localised_name(recipe)
    return get_proto_localised_name(game.recipe_prototypes, recipe, "recipe-name")
end

function proto.get_virtual_signal_localised_name(signal)
    return get_proto_localised_name(game.virtual_signal_prototypes, signal, "virtual-signal-name")
end

function proto.order_comparator(proto_a, proto_b)
    -- Compare existance of a group prop.
    if proto_a.group ~= nil and proto_b.group == nil then
        return true
    elseif proto_a.group == nil and proto_b.group ~= nil then
        return false
    end

    -- Compare group order, if both have a value for the prop.
    if proto_a.group ~= nil and proto_b.group ~= nil then
        if proto_a.group.order < proto_b.group.order then
            return true
        elseif proto_a.group.order > proto_b.group.order then
            return false
        end
    end
    
    -- Compare existance of a subgroup prop.
    if proto_a.subgroup ~= nil and proto_b.subgroup == nil then
        return true
    elseif proto_a.subgroup == nil and proto_b.subgroup ~= nil then
        return false
    end

    -- Compare subgroup order, if both have a value for the prop.
    if proto_a.subgroup ~= nil and proto_b.group ~= nil then
        if proto_a.subgroup.order < proto_b.subgroup.order then
            return true
        elseif proto_a.subgroup.order > proto_b.subgroup.order then
            return false
        end
    end

    -- Compare existance of an order prop.
    if proto_a.order == nil and proto_b.order ~= nil then
        return true
    elseif proto_a.order ~= nil and proto_b.order == nil then
        return false
    end

    -- Compare orders, if both have a value for the prop.
    if proto_a.order ~= nil and proto_b.order ~= nil then
        if proto_a.order < proto_b.order then
            return true
        elseif proto_a.order > proto_b.order then
            return false
        end
    end

    if proto_a.name < proto_b.name then
        return true
    elseif proto_a.name > proto_b.name then
        return false
    end

    return false
end

return proto