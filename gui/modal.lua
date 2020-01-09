-- local serpent = require("_local.serpent") --TODO DEBUG
local blueprint = require("lib.blueprint")
local player_data = require("lib.player_data")
local util = require("util")
local mod_util = require("lib/util")
local modal_defines = require("./defines")
local build_frame = require('./modal-frame')
local screen_protos = require('./modal-protos')
local screen_colors = require('./modal-colors')
local screen_strings = require('./modal-strings')
local screen_recipes = require('./modal-recipes')

local modal = {}

local function update_screens(player, modal_frame, blueprint_data, event_element_name)
    screen_protos.update(player, modal_frame, blueprint_data, event_element_name)
    screen_colors.update(player, modal_frame, blueprint_data, event_element_name)
    screen_strings.update(player, modal_frame, blueprint_data, event_element_name)
    screen_recipes.update(player, modal_frame, blueprint_data, event_element_name)
end

local function get_modal_container(player)
    return player.gui.screen
end

local function get_modal_frame(player)
    return get_modal_container(player)[modal_defines.modal_name] or nil
end

function modal.open(player)
    if modal.is_open(player) then
        return
    end

    local modal_frame = build_frame(player, get_modal_container(player))
    local blueprint_data = player_data.get_blueprint_data(player)

    screen_protos.build(player, modal_frame, blueprint_data)
    screen_colors.build(player, modal_frame, blueprint_data)
    screen_strings.build(player, modal_frame, blueprint_data)
    screen_recipes.build(player, modal_frame, blueprint_data)

    update_screens(player, modal_frame, blueprint_data, nil)

    modal_frame.tabbed_pane.selected_tab_index = 4
    modal_frame.tabbed_pane.selected_tab_index = 3
    modal_frame.tabbed_pane.selected_tab_index = 2
    modal_frame.tabbed_pane.selected_tab_index = 1

    local modal_location = player_data.get_modal_location(player)

    if modal_location == nil then
        modal_frame.force_auto_center()
    else
        modal_frame.location = {
            x = modal_location.x >= 0 and modal_location.x or 0,
            y = modal_location.y >= 0 and modal_location.y or 0,
        }
    end
end

function modal.is_open(player)
    return get_modal_container(player)[modal_defines.modal_name] ~= nil
end

function modal.close(player)
    if modal.is_open(player) then
        local modal_frame = get_modal_container(player)[modal_defines.modal_name]

        if modal_frame.location ~= nil then
            player_data.set_modal_location(player, modal_frame.location)
        end

        modal_frame.destroy()

        player_data.clear_blueprint_data(player)
    end
end

function modal.on_gui_click(player, element, event)
    if element.name == modal_defines.button_modal_close then
        modal.close(player)

    elseif element.name == "REFRESH" then
        local selected_tab_index = get_modal_frame(player).tabbed_pane.selected_tab_index or 1

        local modal_frame = get_modal_frame(player)

        if modal_frame.location ~= nil then
            player_data.set_modal_location(player, modal_frame.location)
        end
        
        modal_frame.destroy()
        modal.open(player)

        get_modal_frame(player).tabbed_pane.selected_tab_index = selected_tab_index

    elseif element.name == modal_defines.button_export_name then
        local blueprint_data = player_data.get_blueprint_data(player)
        local blueprint_icons = util.table.deepcopy(blueprint_data.blueprint_icons)
        local entities = util.table.deepcopy(blueprint_data.entities)
        local changes = blueprint_data.changes

        for _, blueprint_icon in ipairs(blueprint_icons) do
            if blueprint_icon.signal ~= nil then
                if changes.signals[blueprint_icon.signal.type .. "." .. blueprint_icon.signal.name] ~= nil then
                    local signal_type, signal_name = string.match(changes.signals[blueprint_icon.signal.type .. "." .. blueprint_icon.signal.name], "^(.+)%.(.+)$")
                    blueprint_icon.signal.type = signal_type
                    blueprint_icon.signal.name = signal_name
                end
            end
        end

        for _, entity in pairs(entities) do
            blueprint.apply_changes_to_entity(entity, blueprint_data.changes)
        end

        if player.clean_cursor() then
            -- log("EXPORTED ENTITIES " .. serpent.block(entities)) -- TODO
            if player.cursor_stack.import_stack(blueprint_data.export_string) == 0 then
                player.cursor_stack.set_blueprint_entities(entities)
                player.cursor_stack.blueprint_icons = blueprint_icons
            end

            modal.close(player)
        end

    elseif util.string_starts_with(element.name, modal_defines.button_prefix) then
        local metadata = string.sub(element.name, string.len(modal_defines.button_prefix) + 1)
        local reference_type, reference_data = string.match(metadata, "^([a-z_]+)%-%-(.+)$")

        if reference_type ~= nil then
            local modal_frame = get_modal_frame(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "colors" then
                if (event.button == 4) then
                    blueprint_data.changes.colors[reference_data] = nil
                else
                    blueprint_data.selection.color = reference_data
                end

                update_screens(player, modal_frame, blueprint_data)

            elseif reference_type == "stations_reset" then
                blueprint_data.changes.stations[reference_data] = nil
                update_screens(player, modal_frame, blueprint_data)

            elseif reference_type == "alert_messages_reset" then
                blueprint_data.changes.alert_messages[reference_data] = nil
                update_screens(player, modal_frame, blueprint_data)
                
            elseif reference_type == "recipe" then
                if event.button == 4 then
                    blueprint_data.changes.recipes[reference_data] = nil
                else
                    blueprint_data.selection.recipe = reference_data
                end

                update_screens(player, modal_frame, blueprint_data)
                
            elseif reference_type == "recipe_change" then
                local entity_name, recipe_name = string.match(blueprint_data.selection.recipe, "^(.+)%.(.+)$")

                if recipe_name == reference_data then
                    blueprint_data.changes.recipes[blueprint_data.selection.recipe] = nil
                else
                    blueprint_data.changes.recipes[blueprint_data.selection.recipe] = reference_data
                end

                update_screens(player, modal_frame, blueprint_data)
            end
        end

    elseif type(element.name) == "string" and element.name ~= "" then
        -- game.print("on_gui_click " .. element.name)
    end
end

function modal.on_gui_elem_changed(player, element)
    if util.string_starts_with(element.name, modal_defines.button_prefix) then
        local metadata = string.sub(element.name, string.len(modal_defines.button_prefix) + 1)
        local reference_type, reference_data = string.match(metadata, "^([a-z]+)%-%-(.+)$")

        if reference_type ~= nil then
            local modal_frame = get_modal_frame(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "items" then
                blueprint_data.changes.items[reference_data] = element.elem_value
                update_screens(player, modal_frame, blueprint_data, element.name)

            elseif reference_type == "fluids" then
                blueprint_data.changes.fluids[reference_data] = element.elem_value
                update_screens(player, modal_frame, blueprint_data, element.name)

            elseif reference_type == "signals" then
                blueprint_data.changes.signals[reference_data] = element.elem_value ~= nil and (element.elem_value.type .. "." .. element.elem_value.name) or nil
                update_screens(player, modal_frame, blueprint_data, element.name)
            end
        end
    end
end

function modal.on_gui_value_changed(player, element)
    if util.string_starts_with(element.name, modal_defines.slider_prefix) then
        local metadata = string.sub(element.name, string.len(modal_defines.slider_prefix) + 1)
        local reference_type, reference_data = string.match(metadata, "^([a-z]+)%-%-(.+)$")

        if reference_type ~= nil then
            local modal_frame = get_modal_frame(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "colors" then
                local color_change = blueprint_data.changes.colors[blueprint_data.selection.color] or nil
                local color_values = blueprint.parse_color(color_change or blueprint_data.selection.color)

                if reference_data == "saturation" or reference_data == "lightness" then
                    color_values[reference_data] = element.slider_value
                else
                    color_values[reference_data] = element.slider_value
                end

                if reference_data == "hue" or reference_data == "saturation" or reference_data == "lightness" then
                    local red, green, blue = mod_util.hsl_to_rgb(color_values.hue, color_values.saturation / 10, color_values.lightness / 10)
                    color_values.red = red
                    color_values.green = green
                    color_values.blue = blue
                end

                blueprint_data.changes.colors[blueprint_data.selection.color] = blueprint.build_color(color_values)

                update_screens(player, modal_frame, blueprint_data, element.name)
            end
        end
    end
end

function modal.on_gui_text_changed(player, element)
    if util.string_starts_with(element.name, modal_defines.textfield_prefix) then
        local metadata = string.sub(element.name, string.len(modal_defines.textfield_prefix) + 1)
        local reference_type, reference_data = string.match(metadata, "^([a-z_]+)%-%-(.+)$")

        if reference_type ~= nil then
            local modal_frame = get_modal_frame(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "colors" then
                local color_change = blueprint_data.changes.colors[blueprint_data.selection.color] or nil
                local color_values = blueprint.parse_color(color_change or blueprint_data.selection.color)

                if string.match(element.text, "^[0-9]+$") then
                    local num_value = tonumber(element.text)

                    if num_value >= 0 and num_value <= 255 then
                        color_values[reference_data] = num_value
                        blueprint_data.changes.colors[blueprint_data.selection.color] = blueprint.build_color(color_values)

                        update_screens(player, modal_frame, blueprint_data, element.name)
                    end
                end
            elseif reference_type == "stations" then
                local replaced_text = blueprint.replace_text_references(reference_data, function(type, value)
                    return blueprint.get_text_tag_replacment(blueprint_data.changes, type, value)
                end)

                if replaced_text == element.text then
                    blueprint_data.changes.stations[reference_data] = nil
                else
                    blueprint_data.changes.stations[reference_data] = element.text
                end
                update_screens(player, modal_frame, blueprint_data, element.name)

            elseif reference_type == "alert_messages" then
                local replaced_text = blueprint.replace_text_references(reference_data, function(type, value)
                    return blueprint.get_text_tag_replacment(blueprint_data.changes, type, value)
                end)

                if replaced_text == element.text then
                    blueprint_data.changes.alert_messages[reference_data] = nil
                else
                    blueprint_data.changes.alert_messages[reference_data] = element.text
                end
                update_screens(player, modal_frame, blueprint_data, element.name)
            end
        end
    end
end

return modal