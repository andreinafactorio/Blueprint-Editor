local constants = require("state.constants")
local blueprint = require("lib.blueprint")
local mod_util = require("lib.util")

local reducers = {}

function reducers.selection(player, blueprint_data, action)
    local selection = blueprint_data.selection

    if action.type == constants.REFERENCE_SELECTION then
        if selection == nil or
            selection.type ~= action.selection_type or
            selection.value ~= action.selection_value then

            selection = {
                type = action.selection_type,
                value = action.selection_value,
                group = action.selection_group or nil,
            }
        end

    elseif action.type == constants.PROTO_GROUP_SELECTION then
        if selection.group ~= action.group then
            has_changed = true
            selection = mod_util.table_shallow_copy(selection)
            selection.group = action.group
        end
    end

    return selection
end

function reducers.changes(player, blueprint_data, action)
    local changes = blueprint_data.changes

    if action.type == constants.REFERENCE_CHANGE then
        if blueprint_data.selection.value == action.value then
            changes = mod_util.table_shallow_copy_path(changes, { action.reference_name })
            changes[action.reference_name][blueprint_data.selection.value] = nil
        elseif changes[action.reference_name][blueprint_data.selection.value] ~= action.value then
            changes = mod_util.table_shallow_copy_path(changes, { action.reference_name })
            changes[action.reference_name][blueprint_data.selection.value] = action.value
        end

    elseif action.type == constants.REFERENCE_RESET then
        if changes[action.reference_name][action.value] ~= nil then
            changes = mod_util.table_shallow_copy_path(changes, { action.reference_name })
            changes[action.reference_name][action.value] = nil
        end

    elseif action.type == constants.COLOR_CHANGE then
        local color_change = changes.colors[blueprint_data.selection.value] or nil
        local color_values = blueprint.parse_color(color_change or blueprint_data.selection.value)

        color_values[action.color_type] = action.color_value

        if action.color_type == "hue" or action.color_type == "saturation" or action.color_type == "lightness" then
            local red, green, blue = mod_util.hsl_to_rgb(color_values.hue, color_values.saturation / 10, color_values.lightness / 10)
            color_values.red = red
            color_values.green = green
            color_values.blue = blue
        end

        changes = mod_util.table_shallow_copy_path(changes, { "colors" })
        changes.colors[blueprint_data.selection.value] = blueprint.build_color(color_values)

    elseif action.type == constants.STATION_CHANGE then
        local replaced_text = blueprint.replace_text_references(action.station, function(type, value)
            return blueprint.get_text_tag_replacment(changes, type, value)
        end)

        local changed_value = action.text

        -- If the value would be the same as the original (with any replacements),
        -- then set it to nil so it is no longer marked as changed.
        if replaced_text == action.text then
            changed_value = nil
        end

        if changes.stations[action.station] ~= changed_value then
            changes = mod_util.table_shallow_copy_path(changes, { "stations" })
            changes.stations[action.station] = changed_value
        end

    elseif action.type == constants.ALERT_MESSAGE_CHANGE then
        local replaced_text = blueprint.replace_text_references(action.alert_message, function(type, value)
            return blueprint.get_text_tag_replacment(changes, type, value)
        end)

        local changed_value = action.text

        -- If the value would be the same as the original (with any replacements),
        -- then set it to nil so it is no longer marked as changed.
        if replaced_text == action.text then
            changed_value = nil
        end

        if changes.alert_messages[action.alert_message] ~= changed_value then
            changes = mod_util.table_shallow_copy_path(changes, { "alert_messages" })
            changes.alert_messages[action.alert_message] = changed_value
        end
    end

    return changes
end

return reducers
