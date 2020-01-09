local mod_util = require("lib.util")
local proto_util = require("lib.proto")

local blueprint = {}

local text_tag_find_pattern = "%[[^=]+=[^=]+%]"
local text_tag_match_pattern = "%[([^=]+)=([^=]+)%]"

local function foreach_logic_references(logic_data, cb)
    for _, constant_prop in pairs({ "constant", "first_constant", "second_constant" }) do
        if logic_data[constant_prop] ~= nil then
            cb(logic_data[constant_prop])
        end
    end

    for _, signal_prop in pairs({
        "first_signal",
        "second_signal",
        "output_signal",
        "stack_control_input_signal",
        "train_stopped_signal",
        "output_signal",
        "green_output_signal",
        "orange_output_signal",
        "red_output_signal",
        "blue_output_signal",
        "available_construction_output_signal",
        "available_logistic_output_signal",
        "total_construction_output_signal",
        "total_logistic_output_signal",
    }) do
        if logic_data[signal_prop] ~= nil then
            cb(logic_data[signal_prop])
        end
    end
end

local function item_name_comparator(item_a_name, item_b_name)
    local item_a = game.item_prototypes[item_a_name]
    local item_b = game.item_prototypes[item_b_name]

    if item_a == nil and item_b == nil then
        return item_a_name < item_b_name
    elseif item_a == nil or item_b == nil then
        return item_a ~= nil
    end

    return proto_util.order_comparator(item_a, item_b)
end

local function fluid_name_comparator(fluid_a_name, fluid_b_name)
    local fluid_a = game.fluid_prototypes[fluid_a_name]
    local fluid_b = game.fluid_prototypes[fluid_b_name]

    if fluid_a == nil and fluid_b == nil then
        return false
    elseif fluid_a == nil or fluid_b == nil then
        return fluid_a ~= nil
    end

    return proto_util.order_comparator(fluid_a, fluid_b)
end

local function color_hsl_comparator(color_a, color_b)
    color_a = blueprint.parse_color(color_a)
    color_b = blueprint.parse_color(color_b)

    local color_a_hue, color_a_saturation, color_a_lightness = mod_util.rgb_to_hsl(color_a.red, color_a.green, color_a.blue)
    local color_b_hue, color_b_saturation, color_b_lightness = mod_util.rgb_to_hsl(color_b.red, color_b.green, color_b.blue)

    if color_a_saturation == 0 and color_b_saturation ~= 0 then
        return true
    elseif color_a_saturation ~= 0 and color_b_saturation == 0 then
        return false
    elseif color_a_hue > color_b_hue then
        return true
    elseif color_a_hue < color_b_hue then
        return false
    elseif color_a_saturation > color_b_saturation then
        return true
    elseif color_a_saturation < color_b_saturation then
        return false
    elseif color_a_lightness > color_b_lightness then
        return true
    elseif color_a_lightness < color_b_lightness then
        return false
    else
        return false
    end
end

local function color_comparator(color_a, color_b)
    color_a = blueprint.parse_color(color_a)
    color_b = blueprint.parse_color(color_b)

    if color_a.red < color_b.red then
        return true
    elseif color_a.red > color_b.red then
        return false
    elseif color_a.blue < color_b.blue then
        return true
    elseif color_a.blue > color_b.blue then
        return false
    elseif color_a.green < color_b.green then
        return true
    elseif color_a.green > color_b.green then
        return false
    elseif color_a.alpha < color_b.alpha then
        return true
    elseif color_a.alpha > color_b.alpha then
        return false
    else
        return false
    end
end

local function virtual_signal_name_comparator(virtual_a_name, virtual_b_name)
    local virtual_a = game.virtual_signal_prototypes[virtual_a_name]
    local virtual_b = game.virtual_signal_prototypes[virtual_b_name]

    if virtual_a == nil and virtual_b == nil then
        return false
    elseif virtual_a == nil or virtual_b == nil then
        return virtual_a ~= nil
    end

    return virtual_a.order < virtual_b.order
end

local function recipe_name_comparator(recipe_a_name, recipe_b_name)
    local recipe_a = game.recipe_prototypes[recipe_a_name]
    local recipe_b = game.recipe_prototypes[recipe_b_name]

    if recipe_a == nil and recipe_b == nil then
        return false
    elseif recipe_a == nil or recipe_b == nil then
        return recipe_a ~= nil
    end

    return proto_util.order_comparator(recipe_a, recipe_b)
end

local function signal_comparator(signal_a, signal_b)
    local signal_a_type, signal_a_name = string.match(signal_a, "^(.+)%.(.+)$")
    local signal_b_type, signal_b_name = string.match(signal_b, "^(.+)%.(.+)$")


    if signal_a_type == "item" and signal_b_type == "item" then
        return item_name_comparator(signal_a_name, signal_b_name)
    end

    if signal_a_type == "fluid" and signal_b_type == "fluid" then
        return fluid_name_comparator(signal_a_name, signal_b_name)
    end

    if signal_a_type == "virtual" and signal_b_type == "virtual" then
        return virtual_signal_name_comparator(signal_a_name, signal_b_name)
    end

    if signal_a_type == "item" and signal_b_type ~= "item" then
        return true
    elseif signal_a_type ~= "item" and signal_b_type == "item" then
        return false
    end

    if signal_a_type == "fluid" and signal_b_type ~= "fluid" then
        return true
    elseif signal_a_type ~= "fluid" and signal_b_type == "fluid" then
        return false
    end

    return false
end

local function entity_name_comparator(entity_name_a, entity_name_b)
    local entity_a = game.entity_prototypes[entity_name_a]
    local entity_b = game.entity_prototypes[entity_name_b]

    if entity_a ~= nil and entity_b ~= nil then
        return proto_util.order_comparator(entity_a, entity_b)
    else
        return entity_a ~= nil and entity_b == nil
    end
end

function blueprint.build_color(r, g, b, a)
    if type(r) == "table" then
        local t = r
        if t.red ~= nil then
            r = t.red or 0
            g = t.green or 0
            b = t.blue or 0
            a = t.alpha or 0
        else
            r = t.r or 0
            g = t.g or 0
            b = t.b or 0
            a = t.a or 0
        end
    end

    return r .. ":" .. g .. ":" .. b -- .. ":" .. a
end

function blueprint.parse_color(color)
    local red, green, blue, alpha = string.match(color, "^(.+):(.+):(.+)$") -- "^(.+):(.+):(.+):(.+)$"
    red = tonumber(red or 0)
    green = tonumber(green or 0)
    blue = tonumber(blue or 0)
    alpha = tonumber(alpha or 0)

    local hue, saturation, lightness = mod_util.rgb_to_hsl(red, green, blue)

    return {
        red = red,
        green = green,
        blue = blue,
        alpha = alpha,
        hue = hue,
        saturation = saturation * 10,
        lightness = lightness * 10,
    }
end

function blueprint.group_recipes_by_entity(recipes)
    local by_entity = {}

    for _, entity_recipe_pair in ipairs(recipes) do
        local entity_name, recipe_name = string.match(entity_recipe_pair, "^([^.]+)%.(.+)$")

        if by_entity[entity_name] == nil then
            by_entity[entity_name] = {}
        end

        table.insert(by_entity[entity_name], recipe_name)
    end

    return by_entity
end

local function get_sorted_entity_sources(sources)
    local ret = {}

    for key, entity_names in pairs(sources) do
        entity_names = mod_util.get_table_keys(entity_names)
        table.sort(entity_names, function(a, b)
            if a == "" and b ~= "" then
                return true
            elseif a ~= "" and b == "" then
                return false
            else
                return entity_name_comparator(a, b)
            end
        end)
        ret[key] = entity_names
    end

    return ret;
end

function blueprint.get_references(entities, blueprint_icons)
    local items = {}
    local items_sources = {}
    local fluids = {}
    local fluids_sources = {}
    local recipes = {}
    local colors = {}
    local colors_sources = {}
    local stations = {}
    local alert_messages = {}
    local signals = {}
    local signals_sources = {}
    local constants = {}
    local constants_sources = {}

    for _, blueprint_icon in ipairs(blueprint_icons) do
        if blueprint_icon.signal ~= nil then
            signals[blueprint_icon.signal.type .. "." .. blueprint_icon.signal.name] = true

            if signals_sources[blueprint_icon.signal.type .. "." .. blueprint_icon.signal.name] == nil then
                signals_sources[blueprint_icon.signal.type .. "." .. blueprint_icon.signal.name] = {}
            end
            signals_sources[blueprint_icon.signal.type .. "." .. blueprint_icon.signal.name][""] = true
        end
    end

    for _, entity in pairs(entities) do

        local entity_proto = game.entity_prototypes[entity.name]

        -- Item requests by this entity, this is what defines the item-request-proxy when the blueprint is placed.
        -- if entity.items ~= nil then
        --     for item_name, count in pairs(entity.items) do
        --         items[item_name] = true

        --         if items_sources[item_name] == nil then
        --             items_sources[item_name] = {}
        --         end
        --         items_sources[item_name][entity.name] = true
        --     end
        -- end

        -- Name of the recipe prototype this assembling machine is set to.
        if entity.recipe ~= nil and (entity_proto == nil or entity_proto.fixed_recipe == nil) then
            recipes[entity.name .. "." .. entity.recipe] = true
        end

        -- Cargo wagon inventory configuration.
        if entity.inventory ~= nil and entity.inventory.filters ~= nil then
            for _, filter in pairs(entity.inventory.filters) do
                items[filter.name] = true

                if items_sources[filter.name] == nil then
                    items_sources[filter.name] = {}
                end
                items_sources[filter.name][entity.name] = true
            end
        end

        -- Filter of the splitter, optional. Name of the item prototype the filter is set to, string.
        if entity.filter ~= nil then
            items[entity.filter] = true

            if items_sources[entity.filter] == nil then
                items_sources[entity.filter] = {}
            end
            items_sources[entity.filter][entity.name] = true
        end

        -- Filters of the filter inserter or loader.
        if entity.filters ~= nil then
            for _, filter in pairs(entity.filters) do
                items[filter.name] = true

                if items_sources[filter.name] == nil then
                    items_sources[filter.name] = {}
                end
                items_sources[filter.name][entity.name] = true
            end
        end

        -- Used by Prototype/LogisticContainer.
        if entity.request_filters ~= nil then
            for _, request_filter in pairs(entity.request_filters) do
                items[request_filter.name] = true

                if items_sources[request_filter.name] == nil then
                    items_sources[request_filter.name] = {}
                end
                items_sources[request_filter.name][entity.name] = true
            end
        end

        -- Used by Programmable speaker.
        if entity.alert_parameters ~= nil then
            if entity.alert_parameters.alert_message ~= nil and entity.alert_parameters.alert_message ~= "" then
                alert_messages[entity.alert_parameters.alert_message] = true

                for type, value in string.gmatch(entity.alert_parameters.alert_message, text_tag_match_pattern) do
                    if type == "item" then
                        items[value] = true

                        if items_sources[value] == nil then
                            items_sources[value] = {}
                        end
                        items_sources[value][entity.name] = true

                    elseif type == "fluid" then
                        fluids[value] = true

                        if fluids_sources[value] == nil then
                            fluids_sources[value] = {}
                        end
                        fluids_sources[value][entity.name] = true

                    elseif type == "recipe" then
                        recipes[value] = true

                    elseif type == "virtual-signal" then
                        signals["virtual." .. value] = true

                        if signals_sources["virtual." .. value] == nil then
                            signals_sources["virtual." .. value] = {}
                        end
                        signals_sources["virtual." .. value][entity.name] = true
                    end
                end
            end

            if entity.alert_parameters.icon_signal_id ~= nil then
                signals[entity.alert_parameters.icon_signal_id.type .. "." .. entity.alert_parameters.icon_signal_id.name] = true

                if signals_sources[entity.alert_parameters.icon_signal_id.type .. "." .. entity.alert_parameters.icon_signal_id.name] == nil then
                    signals_sources[entity.alert_parameters.icon_signal_id.type .. "." .. entity.alert_parameters.icon_signal_id.name] = {}
                end
                signals_sources[entity.alert_parameters.icon_signal_id.type .. "." .. entity.alert_parameters.icon_signal_id.name][entity.name] = true
            end
        end

        -- Color of the Prototype/SimpleEntityWithForce, Prototype/SimpleEntityWithOwner, or train station.
        if entity.color ~= nil then
            local red = math.floor(entity.color.r * 255)
            local green = math.floor(entity.color.g * 255)
            local blue = math.floor(entity.color.b * 255)
            local alpha = math.floor(entity.color.a * 255)
            colors[blueprint.build_color(red, green, blue, alpha)] = true

            if colors_sources[blueprint.build_color(red, green, blue, alpha)] == nil then
                colors_sources[blueprint.build_color(red, green, blue, alpha)] = {}
            end
            colors_sources[blueprint.build_color(red, green, blue, alpha)][entity.name] = true
        end

        -- The name of the train station.
        if entity.station ~= nil and entity.station ~= "" then
            stations[entity.station] = true

            for type, value in string.gmatch(entity.station, text_tag_match_pattern) do
                if type == "item" then
                    items[value] = true

                    if items_sources[value] == nil then
                        items_sources[value] = {}
                    end
                    items_sources[value][entity.name] = true

                elseif type == "fluid" then
                    fluids[value] = true

                    if fluids_sources[value] == nil then
                        fluids_sources[value] = {}
                    end
                    fluids_sources[value][entity.name] = true

                elseif type == "recipe" then
                    recipes[value] = true

                elseif type == "virtual-signal" then
                    signals["virtual." .. value] = true

                    if signals_sources["virtual." .. value] == nil then
                        signals_sources["virtual." .. value] = {}
                    end
                    signals_sources["virtual." .. value][entity.name] = true
                end
            end
        end

        if entity.control_behavior ~= nil then
            local control_behavior = entity.control_behavior

            for _, conditions_prop in pairs({
                "circuit_condition",
                "logistic_condition",
                "decider_conditions",
                "arithmetic_conditions",
            }) do
                if control_behavior[conditions_prop] ~= nil then
                    foreach_logic_references(control_behavior[conditions_prop], function(value)
                        if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                            signals[value.type .. "." .. value.name] = true

                            if signals_sources[value.type .. "." .. value.name] == nil then
                                signals_sources[value.type .. "." .. value.name] = {}
                            end
                            signals_sources[value.type .. "." .. value.name][entity.name] = true

                        elseif type(value) == "number" then
                            constants[value] = true

                            if constants_sources[value] == nil then
                                constants_sources[value] = {}
                            end
                            constants_sources[value][entity.name] = true
                        end
                    end)
                end
            end

            if control_behavior.filters ~= nil then
                for _, filter in pairs(control_behavior.filters) do
                    if filter.signal ~= nil then
                        signals[filter.signal.type .. "." .. filter.signal.name] = true

                        if signals_sources[filter.signal.type .. "." .. filter.signal.name] == nil then
                            signals_sources[filter.signal.type .. "." .. filter.signal.name] = {}
                        end
                        signals_sources[filter.signal.type .. "." .. filter.signal.name][entity.name] = true
                    end
                end
            end

            foreach_logic_references(control_behavior, function(value)
                if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                    signals[value.type .. "." .. value.name] = true

                    if signals_sources[value.type .. "." .. value.name] == nil then
                        signals_sources[value.type .. "." .. value.name] = {}
                    end
                    signals_sources[value.type .. "." .. value.name][entity.name] = true

                elseif type(value) == "number" then
                    constants[value] = true

                    if constants_sources[value] == nil then
                        constants_sources[value] = {}
                    end
                    constants_sources[value][entity.name] = true
                end
            end)
        end

        if entity.schedule ~= nil then
            for _, schedule_stop in pairs(entity.schedule) do
                if schedule_stop.station ~= nil and schedule_stop.station ~= "" then
                    stations[schedule_stop.station] = true
                end

                if schedule_stop.wait_conditions ~= nil then
                    for _, wait_condition in pairs(schedule_stop.wait_conditions) do
                        if wait_condition.condition ~= nil then
                            if wait_condition.type == "item_count" then
                                foreach_logic_references(wait_condition.condition, function(value)
                                    if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                                        items[value.name] = true

                                        if items_sources[value.name] == nil then
                                            items_sources[value.name] = {}
                                        end
                                        items_sources[value.name][entity.name] = true

                                    elseif type(value) == "number" then
                                        constants[value] = true

                                        if constants_sources[value] == nil then
                                            constants_sources[value] = {}
                                        end
                                        constants_sources[value][entity.name] = true
                                    end
                                end)
                            elseif wait_condition.type == "fluid_count" then
                                foreach_logic_references(wait_condition.condition, function(value)
                                    if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                                        fluids[value.name] = true

                                        if fluids_sources[value.name] == nil then
                                            fluids_sources[value.name] = {}
                                        end
                                        fluids_sources[value.name][entity.name] = true

                                    elseif type(value) == "number" then
                                        constants[value] = true

                                        if constants_sources[value] == nil then
                                            constants_sources[value] = {}
                                        end
                                        constants_sources[value][entity.name] = true
                                    end
                                end)
                            elseif wait_condition.type == "circuit" then
                                foreach_logic_references(wait_condition.condition, function(value)
                                    if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                                        signals[value.type .. "." .. value.name] = true

                                        if signals_sources[value.type .. "." .. value.name] == nil then
                                            signals_sources[value.type .. "." .. value.name] = {}
                                        end
                                        signals_sources[value.type .. "." .. value.name][entity.name] = true

                                    elseif type(value) == "number" then
                                        constants[value] = true

                                        if constants_sources[value] == nil then
                                            constants_sources[value] = {}
                                        end
                                        constants_sources[value][entity.name] = true
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    items = mod_util.get_table_keys(items)
    table.sort(items, item_name_comparator)
    items_sources = get_sorted_entity_sources(items_sources)

    fluids = mod_util.get_table_keys(fluids)
    table.sort(fluids, fluid_name_comparator)
    fluids_sources = get_sorted_entity_sources(fluids_sources)

    recipes = mod_util.get_table_keys(recipes)

    local recipes_by_entity = blueprint.group_recipes_by_entity(recipes)
    for _, recipe_names in pairs(recipes_by_entity) do
        table.sort(recipe_names, recipe_name_comparator)
    end

    local recipes_entity_names = mod_util.get_table_keys(recipes_by_entity)
    table.sort(recipes_entity_names, entity_name_comparator)

    colors = mod_util.get_table_keys(colors)
    table.sort(colors, color_hsl_comparator)
    colors_sources = get_sorted_entity_sources(colors_sources)

    stations = mod_util.get_table_keys(stations)
    table.sort(stations)

    signals = mod_util.get_table_keys(signals)
    table.sort(signals, signal_comparator)
    signals_sources = get_sorted_entity_sources(signals_sources)

    constants = mod_util.get_table_keys(constants)
    table.sort(constants)
    constants_sources = get_sorted_entity_sources(constants_sources)

    alert_messages = mod_util.get_table_keys(alert_messages)
    table.sort(alert_messages)

    return {
        items = items,
        items_sources = items_sources,
        fluids = fluids,
        fluids_sources = fluids_sources,
        recipes = recipes,
        recipes_by_entity = recipes_by_entity,
        recipes_entity_names = recipes_entity_names,
        colors = colors,
        colors_sources = colors_sources,
        stations = stations,
        signals = signals,
        signals_sources = signals_sources,
        constants = constants,
        constants_sources = constants_sources,
        alert_messages = alert_messages,
    }
end

function blueprint.replace_text_references(text, cb)
    local new_text = ""
    local next_idx = 1

    local start_idx, end_idx = string.find(text, text_tag_find_pattern, next_idx)

    while start_idx ~= nil do
        if start_idx > next_idx then
            new_text = new_text .. string.sub(text, next_idx, start_idx - 1)
        end

        local type, name = string.match(string.sub(text, start_idx, end_idx), text_tag_match_pattern)
        local replacement_type, replacement_value = cb(type, name)
        new_text = new_text .. "[" .. replacement_type .. "=" .. replacement_value .. "]"

        next_idx = end_idx + 1
        start_idx, end_idx = string.find(text, text_tag_find_pattern, next_idx)
    end

    new_text = new_text .. string.sub(text, next_idx)

    return new_text
end

function blueprint.apply_changes_to_entity(entity, changes)

    -- Item requests by this entity, this is what defines the item-request-proxy when the blueprint is placed.
    -- if entity.items ~= nil then
    --     local new_items = {}
    --     for item_name, count in pairs(entity.items) do
    --         if changes.items[item_name] ~= nil then
    --             new_items[changes.items[item_name]] = count
    --         else
    --             new_items[item_name] = count
    --         end
    --     end
    -- end

    -- Name of the recipe prototype this assembling machine is set to.
    if entity.recipe ~= nil and changes.recipes[entity.name .. "." .. entity.recipe] ~= nil then
        entity.recipe = changes.recipes[entity.name .. "." .. entity.recipe]
    end

    -- Cargo wagon inventory configuration.
    if entity.inventory ~= nil and entity.inventory.filters ~= nil then
        for _, filter in pairs(entity.inventory.filters) do
            if changes.items[filter.name] ~= nil then
                filter.name = changes.items[filter.name]
            end
        end
    end

    -- Filter of the splitter, optional. Name of the item prototype the filter is set to, string.
    if entity.filter ~= nil then
        if changes.items[entity.filter] ~= nil then
            entity.filter = changes.items[entity.filter]
        end
    end

    -- Filters of the filter inserter or loader.
    if entity.filters ~= nil then
        for _, filter in pairs(entity.filters) do
            if changes.items[filter.name] ~= nil then
                filter.name = changes.items[filter.name]
            end
        end
    end

    -- Used by Prototype/LogisticContainer.
    if entity.request_filters ~= nil then
        local new_request_filters = {}
        local request_filters_by_name = {}

        for _, request_filter in pairs(entity.request_filters) do
            if changes.items[request_filter.name] ~= nil then
                request_filter.name = changes.items[request_filter.name]
            end

            if request_filters_by_name[request_filter.name] == nil then
                request_filters_by_name[request_filter.name] = request_filter
                table.insert(new_request_filters, request_filter)
            else
                request_filters_by_name[request_filter.name].count = request_filters_by_name[request_filter.name].count + request_filter.count
            end
        end

        entity.request_filters = new_request_filters
    end

    -- Used by Programmable speaker.
    if entity.alert_parameters ~= nil then
        if entity.alert_parameters.alert_message ~= nil and entity.alert_parameters.alert_message ~= "" then
            if changes.alert_messages[entity.alert_parameters.alert_message] ~= nil then
                entity.alert_parameters.alert_message = changes.alert_messages[entity.alert_parameters.alert_message]
            else
                entity.alert_parameters.alert_message = blueprint.replace_text_references(entity.alert_parameters.alert_message, function(type, value)
                    return blueprint.get_text_tag_replacment(changes, type, value)
                end)
            end
        end

        if entity.alert_parameters.icon_signal_id ~= nil then
            local signal_key = entity.alert_parameters.icon_signal_id.type .. "." .. entity.alert_parameters.icon_signal_id.name
            if changes.signals[signal_key] ~= nil then
                local signal_type, signal_name = string.match(changes.signals[signal_key], "^(.+)%.(.+)$")
                entity.alert_parameters.icon_signal_id.type = signal_type
                entity.alert_parameters.icon_signal_id.name = signal_name
            end
        end
    end

    -- Color of the Prototype/SimpleEntityWithForce, Prototype/SimpleEntityWithOwner, or train station.
    if entity.color ~= nil then
        local red = math.floor(entity.color.r * 255)
        local green = math.floor(entity.color.g * 255)
        local blue = math.floor(entity.color.b * 255)
        local alpha = math.floor(entity.color.a * 255)
        local color = blueprint.build_color(red, green, blue, alpha)

        if changes.colors[color] ~= nil then
            local color_values = blueprint.parse_color(changes.colors[color])
            entity.color.r = color_values.red / 255
            entity.color.g = color_values.green / 255
            entity.color.b = color_values.blue / 255

            if color_values.alpha ~= nil then
                entity.color.a = color_values.alpha / 255
            end
        end
    end

    -- The name of the train station.
    if entity.station ~= nil and entity.station ~= "" then
        if changes.stations[entity.station] ~= nil and changes.stations[entity.station] ~= "" then
            entity.station = changes.stations[entity.station]
        else
            entity.station = blueprint.replace_text_references(entity.station, function(type, value)
                return blueprint.get_text_tag_replacment(changes, type, value)
            end)
        end
    end

    if entity.control_behavior ~= nil then
        local control_behavior = entity.control_behavior

        for _, conditions_prop in pairs({
            "circuit_condition",
            "logistic_condition",
            "decider_conditions",
            "arithmetic_conditions",
        }) do
            if control_behavior[conditions_prop] ~= nil then
                foreach_logic_references(control_behavior[conditions_prop], function(value)
                    if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                        if changes.signals[value.type .. "." .. value.name] ~= nil then
                            local signal_type, signal_name = string.match(changes.signals[value.type .. "." .. value.name], "^(.+)%.(.+)$")
                            value.type = signal_type
                            value.name = signal_name
                        end
                    elseif type(value) == "number" then
                        -- constants[value] = true
                    end
                end)
            end
        end

        if control_behavior.filters ~= nil then
            for _, filter in pairs(control_behavior.filters) do
                if filter.signal ~= nil then
                    if changes.signals[filter.signal.type .. "." .. filter.signal.name] ~= nil then
                        local signal_type, signal_name = string.match(changes.signals[filter.signal.type .. "." .. filter.signal.name], "^(.+)%.(.+)$")
                        filter.signal.type = signal_type
                        filter.signal.name = signal_name
                    end
                end
            end
        end

        foreach_logic_references(control_behavior, function(value)
            if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                if changes.signals[value.type .. "." .. value.name] ~= nil then
                    local signal_type, signal_name = string.match(changes.signals[value.type .. "." .. value.name], "^(.+)%.(.+)$")
                    value.type = signal_type
                    value.name = signal_name
                end
            elseif type(value) == "number" then
                -- constants[value] = true
            end
        end)
    end

    if entity.schedule ~= nil then
        for _, schedule_stop in pairs(entity.schedule) do
            if schedule_stop.station ~= nil and schedule_stop.station ~= "" then
                if changes.stations[schedule_stop.station] ~= nil and changes.stations[schedule_stop.station] ~= "" then
                    schedule_stop.station = changes.stations[schedule_stop.station]
                else
                    schedule_stop.station = blueprint.replace_text_references(schedule_stop.station, function(type, value)
                        return blueprint.get_text_tag_replacment(changes, type, value)
                    end)
                end
            end

            if schedule_stop.wait_conditions ~= nil then
                for _, wait_condition in pairs(schedule_stop.wait_conditions) do
                    if wait_condition.condition ~= nil then
                        if wait_condition.type == "item_count" then
                            foreach_logic_references(wait_condition.condition, function(value)
                                if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                                    if changes.items[value.name] ~= nil then
                                        value.name = changes.items[value.name]
                                    end
                                elseif type(value) == "number" then
                                    -- constants[value] = true
                                end
                            end)
                        elseif wait_condition.type == "fluid_count" then
                            foreach_logic_references(wait_condition.condition, function(value)
                                if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                                    if changes.fluids[value.name] ~= nil then
                                        value.name = changes.fluids[value.name]
                                    end
                                elseif type(value) == "number" then
                                    -- constants[value] = true
                                end
                            end)
                        elseif wait_condition.type == "circuit" then
                            foreach_logic_references(wait_condition.condition, function(value)
                                if type(value) == "table" and value.type ~= nil and value.name ~= nil then
                                    if changes.signals[value.type .. "." .. value.name] ~= nil then
                                        local signal_type, signal_name = string.match(changes.signals[value.type .. "." .. value.name], "^(.+)%.(.+)$")
                                        value.type = signal_type
                                        value.name = signal_name
                                    end
                                elseif type(value) == "number" then
                                    -- constants[value] = true
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end

function blueprint.get_text_tag_replacment(changes, type, value)
    local items = changes.items
    local fluids = changes.fluids
    local recipes = changes.recipes
    local signals = changes.signals

    if type == "item" and items[value] ~= nil then
        return type, items[value]
    elseif type == "fluid" and fluids[value] ~= nil then
        return type, fluids[value]
    elseif type == "recipe" and recipes[value] ~= nil then
        return type, recipes[value]
    elseif type == "virtual-signal" and signals["virtual." .. value] then
        local signal_type, signal_value = string.match(signals["virtual." .. value], "^(.+)%.(.+)$")
        if signal_type == "virtual" then
            return "virtual-signal", signal_value
        else
            return signal_type, signal_value
        end
    end

    return type, value
end

return blueprint
