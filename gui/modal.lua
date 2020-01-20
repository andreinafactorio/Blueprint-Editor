-- local serpent = require("_local.serpent") --TODO DEBUG
local constants = require("state.constants")
local reduce_blueprint_data = require("state.reduce_blueprint_data")
local blueprint = require("lib.blueprint")
local player_data = require("lib.player_data")
local util = require("util")
local mod_util = require("lib/util")
local modal_defines = require("defines")
local build_frame = require("modal-frame")
local screen_protos = require("modal-protos")
local screen_colors = require("modal-colors")
local screen_strings = require("modal-strings")
local screen_recipes = require("modal-recipes")

local modal = {}

local function get_modal_container(player)
    return player.gui.screen
end

local function get_modal_flow(player)
    return get_modal_container(player)[modal_defines.modal_name] or nil
end

local function update_screens(player, modal_flow, prev, blueprint_data, action, element)
    -- local profiler = game.create_profiler()

    -- log("screen_protos.update")
    screen_protos.update(player, modal_flow, prev, blueprint_data, action, element)
    -- log(profiler)
    -- profiler.reset()

    -- log("screen_recipes.update")
    screen_recipes.update(player, modal_flow, prev, blueprint_data, action, element)
    -- log(profiler)
    -- profiler.reset()

    -- log("screen_colors.update")
    screen_colors.update(player, modal_flow, prev, blueprint_data, action, element)
    -- log(profiler)
    -- profiler.reset()

    -- log("screen_strings.update")
    screen_strings.update(player, modal_flow, prev, blueprint_data, action, element)
    -- log(profiler)
    -- profiler.reset()

    -- profiler.stop()
end

local function dispatch_action(player, action)
    local blueprint_data = player_data.get_blueprint_data(player)

    local prev = {
        selection = blueprint_data.selection,
        changes = blueprint_data.changes,
    }

    local selection = reduce_blueprint_data.selection(player, blueprint_data, action)
    local changes = reduce_blueprint_data.changes(player, blueprint_data, action)

    if player_data.update_blueprint_data(player, selection, changes) then
        update_screens(
            player,
            get_modal_flow(player),
            prev,
            player_data.get_blueprint_data(player),
            action
        )
    end
end

function modal.open(player)
    if modal.is_open(player) then
        return
    end

    local blueprint_data = player_data.get_blueprint_data(player)
    local modal_flow = build_frame(player, get_modal_container(player), blueprint_data ~= nil)

    if blueprint_data then
        screen_protos.build(player, modal_flow, blueprint_data)
        screen_recipes.build(player, modal_flow, blueprint_data)
        screen_colors.build(player, modal_flow, blueprint_data)
        screen_strings.build(player, modal_flow, blueprint_data)

        update_screens(player, modal_flow, nil, blueprint_data, nil)
    else
        local modal_frame = modal_flow.modal_frame

        local drop_button = modal_frame.add({
            type = "button",
            caption = {"blueprint-editor.blueprint-drop-target"},
            name = modal_defines.button_drop_target,
            style = "drop_target_button",
        })
        drop_button.style.horizontally_stretchable = true
        drop_button.style.height = 200
        drop_button.style.top_margin = 8

        local label = modal_frame.add({
            type = "label",
            caption = "... or import from blueprint string",
        })
        label.style.horizontally_stretchable = true
        label.style.top_margin = 12

        local textbox = modal_frame.add({
            type = "text-box",
            name = modal_defines.textbox_blueprint_string,
            style = "blueprint_editor_import_textbox",
        })
        textbox.word_wrap = true

        local button = modal_frame.add({
            type = "button",
            caption = "Import",
            name = modal_defines.button_import_blueprint_string,
        })
        button.style.top_margin = 2
        button.style.bottom_margin = 2
        button.style.padding = 4

        -- Import string error message
        local error_message = modal_frame.add({
            type = "label",
            name = modal_defines.label_invalid_blueprint_string,
            caption = {"blueprint-editor.invalid-blueprint-string"},
            style = "bold_label"
        })
        error_message.visible = false
        error_message.style.top_margin = 4
        error_message.style.bottom_margin = 4
        error_message.style.font_color = {r = 1, b = 0.35, g = 0.35}
    end

    local modal_location = player_data.get_modal_location(player)

    if modal_location == nil then
        modal_flow.force_auto_center()
    else
        modal_flow.location = {
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
        local modal_flow = get_modal_container(player)[modal_defines.modal_name]

        if modal_flow.location ~= nil then
            player_data.set_modal_location(player, modal_flow.location)
        end

        modal_flow.destroy()

        player_data.clear_blueprint_data(player)
    end
end

function modal.on_gui_click(player, element, event)
    if element.name == modal_defines.button_modal_close then
        modal.close(player)

    elseif element.name == "REFRESH" then
        local modal_flow = get_modal_flow(player)

        if modal_flow.location ~= nil then
            player_data.set_modal_location(player, modal_flow.location)
        end
        
        modal_flow.destroy()
        modal.open(player)

    elseif element.name == modal_defines.button_drop_target then
        if mod_util.is_player_holding_blueprint(player) then
            modal.close(player)
            player_data.load_from_item_stack(player, player.cursor_stack)
            player.clean_cursor()
            modal.open(player)
        end

    elseif element.name == modal_defines.button_import_blueprint_string then
        if player.cursor_stack ~= nil and player.clean_cursor() then
            local modal_flow = get_modal_container(player)[modal_defines.modal_name]
            local blueprint_string = modal_flow.modal_frame[modal_defines.textbox_blueprint_string].text
            if player.cursor_stack.import_stack(blueprint_string) <= 0 then
                modal.close(player)
                player_data.load_from_item_stack(player, player.cursor_stack)
                modal.open(player)
                player.cursor_stack.clear()
            else
                local label = modal_flow.modal_frame[modal_defines.label_invalid_blueprint_string]
                if label ~= nil then
                    label.visible = true
                else
                    player.print({ "blueprint-editor.invalid-blueprint-string" })
                end
            end
        end

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

        if player.cursor_stack ~= nil and player.clean_cursor() then
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
            local modal_flow = get_modal_flow(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "colors" then
                if event.button == 4 then
                    dispatch_action(player, {
                        type = constants.REFERENCE_RESET,
                        value = reference_data,
                        reference_name = "colors",
                        element = element,
                    })
                else
                    dispatch_action(player, {
                        type = constants.REFERENCE_SELECTION,
                        selection_type = "colors",
                        selection_value = reference_data,
                        element = element,
                    })
                end

            elseif reference_type == "stations_reset" then
                dispatch_action(player, {
                    type = constants.REFERENCE_RESET,
                    value = reference_data,
                    reference_name = "stations",
                    element = element,
                })

            elseif reference_type == "alert_messages_reset" then
                dispatch_action(player, {
                    type = constants.REFERENCE_RESET,
                    value = reference_data,
                    reference_name = "alert_messages",
                    element = element,
                })

            elseif reference_type == "items" then
                if event.button == 4 then
                    dispatch_action(player, {
                        type = constants.REFERENCE_RESET,
                        value = reference_data,
                        reference_name = "items",
                        element = element,
                    })
                else
                    local change_value = blueprint_data.changes.items[reference_data]

                    dispatch_action(player, {
                        type = constants.REFERENCE_SELECTION,
                        selection_type = "items",
                        selection_value = reference_data,
                        selection_group = game.item_prototypes[change_value or reference_data].group.name,
                        element = element,
                    })
                end

            elseif reference_type == "items_change" then
                dispatch_action(player, {
                    type = constants.REFERENCE_CHANGE,
                    reference_name = "items",
                    value = reference_data,
                    element = element,
                })

            elseif reference_type == "fluids" then
                if event.button == 4 then
                    dispatch_action(player, {
                        type = constants.REFERENCE_RESET,
                        value = reference_data,
                        reference_name = "fluids",
                        element = element,
                    })
                else
                    local change_value = blueprint_data.changes.fluids[reference_data]

                    dispatch_action(player, {
                        type = constants.REFERENCE_SELECTION,
                        selection_type = "fluids",
                        selection_value = reference_data,
                        selection_group = game.fluid_prototypes[change_value or reference_data].group.name,
                        element = element,
                    })
                end

            elseif reference_type == "fluids_change" then
                dispatch_action(player, {
                    type = constants.REFERENCE_CHANGE,
                    reference_name = "fluids",
                    value = reference_data,
                    element = element,
                })

            elseif reference_type == "signals" then
                if event.button == 4 then
                    dispatch_action(player, {
                        type = constants.REFERENCE_RESET,
                        value = reference_data,
                        reference_name = "signals",
                        element = element,
                    })
                else
                    local change_value = blueprint_data.changes.signals[reference_data] or reference_data
                    local change_type, change_name = string.match(change_value, "^(.+)%.(.+)$")

                    local selection_group = nil
                    if change_type == "item" then
                        selection_group = game.item_prototypes[change_name].group.name
                    elseif change_type == "fluid" then
                        selection_group = game.fluid_prototypes[change_name].group.name
                    elseif change_type == "virtual" or change_type == "virtual-signal" then
                        selection_group = game.virtual_signal_prototypes[change_name].subgroup.group.name
                    end

                    dispatch_action(player, {
                        type = constants.REFERENCE_SELECTION,
                        selection_type = "signals",
                        selection_value = reference_data,
                        selection_group = selection_group,
                        element = element,
                    })
                end

            elseif reference_type == "signals_change" then
                dispatch_action(player, {
                    type = constants.REFERENCE_CHANGE,
                    reference_name = "signals",
                    value = reference_data,
                    element = element,
                })

            elseif reference_type == "recipe" then
                if event.button == 4 then
                    dispatch_action(player, {
                        type = constants.REFERENCE_RESET,
                        value = reference_data,
                        reference_name = "recipes",
                        element = element,
                    })
                else
                    local selected_entity, selected_recipe = string.match(reference_data, "^(.+)%.(.+)$")
                    local change_recipe = blueprint_data.changes.recipes[reference_data] or selected_recipe

                    dispatch_action(player, {
                        type = constants.REFERENCE_SELECTION,
                        selection_type = "recipes",
                        selection_value = reference_data,
                        selection_group = game.recipe_prototypes[change_recipe].group.name,
                        element = element,
                    })
                end

            elseif reference_type == "recipes_change" then
                dispatch_action(player, {
                    type = constants.REFERENCE_CHANGE,
                    reference_name = "recipes",
                    value = reference_data,
                    element = element,
                })

            elseif reference_type == "proto_group" then
                dispatch_action(player, {
                    type = constants.PROTO_GROUP_SELECTION,
                    group = reference_data,
                    element = element,
                })
            end
        end

    elseif type(element.name) == "string" and element.name ~= "" then
        -- game.print("on_gui_click " .. element.name)
    end
end

function modal.on_gui_value_changed(player, element)
    if util.string_starts_with(element.name, modal_defines.slider_prefix) then
        local metadata = string.sub(element.name, string.len(modal_defines.slider_prefix) + 1)
        local reference_type, reference_data = string.match(metadata, "^([a-z]+)%-%-(.+)$")

        if reference_type ~= nil then
            local modal_flow = get_modal_flow(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "colors" then
                dispatch_action(player, {
                    type = constants.COLOR_CHANGE,
                    color_type = reference_data,
                    color_value = element.slider_value,
                    element = element,
                })
            end
        end
    end
end

function modal.on_gui_text_changed(player, element)
    if element.name == modal_defines.textbox_blueprint_string then
        local modal_frame = get_modal_flow(player).modal_frame
        local label = modal_frame[modal_defines.label_invalid_blueprint_string]
        if label ~= nil then
            label.visible = false
        end

    elseif util.string_starts_with(element.name, modal_defines.textfield_prefix) then
        local metadata = string.sub(element.name, string.len(modal_defines.textfield_prefix) + 1)
        local reference_type, reference_data = string.match(metadata, "^([a-z_]+)%-%-(.+)$")

        if reference_type ~= nil then
            local modal_flow = get_modal_flow(player)
            local blueprint_data = player_data.get_blueprint_data(player)

            if reference_type == "colors" then
                local color_change = blueprint_data.changes.colors[blueprint_data.selection.value] or nil
                local color_values = blueprint.parse_color(color_change or blueprint_data.selection.value)

                if string.match(element.text, "^[0-9]+$") then
                    local num_value = tonumber(element.text)

                    if num_value >= 0 and num_value <= 255 then
                        dispatch_action(player, {
                            type = constants.COLOR_CHANGE,
                            color_type = reference_data,
                            color_value = num_value,
                            element = element,
                        })
                    end
                end
            elseif reference_type == "stations" then
                dispatch_action(player, {
                    type = constants.STATION_CHANGE,
                    station = reference_data,
                    text = element.text,
                    element = element,
                })

            elseif reference_type == "alert_messages" then
                dispatch_action(player, {
                    type = constants.ALERT_MESSAGE_CHANGE,
                    alert_message = reference_data,
                    text = element.text,
                    element = element,
                })
            end
        end
    end
end

return modal