-- local serpent = require("_local.serpent") --TODO DEBUG
local mod_gui = require("mod-gui")
local player_data = require("lib.player_data")
local blueprint = require("lib.blueprint")
local gui_modal = require("gui.modal")

local top_button_name = "mod-blueprint-editor-toolbar-button"

local function get_event_player(event)
    return event ~= nil and event.player_index ~= nil and game.get_player(event.player_index) or nil
end

local function draw_toolbar_button(player)
    if player ~= nil then
        local top_container = mod_gui.get_button_flow(player)

        if top_container[top_button_name] ~= nil then
            top_container[top_button_name].destroy()
        end

        top_container.add({
            type = "sprite-button",
            name = top_button_name,
            sprite = "item/blueprint",
            style = "icon_button",
            tooltip = { "blueprint-editor.top-button-tooltip" }
        })
    end
end

local function on_configuration_changed(event)
    if game ~= nil then
        for _, player in pairs(game.players) do
            draw_toolbar_button(player)
        end
    end
end

local function on_player_init(event)
    local player = get_event_player(event)
    if player ~= nil then
        draw_toolbar_button(player)
    end
end

local function on_gui_click(event)
    if not (event and event.element and event.element.valid) then
		return
	end

    local player = get_event_player(event)

    if event.element.name == top_button_name then
        if gui_modal.is_open(player) then
            gui_modal.close(player)
        end

        if player.cursor_stack.valid_for_read and player.cursor_stack.is_blueprint and player.cursor_stack.is_blueprint_setup() then
            local export_stack = player.cursor_stack.export_stack()
            local blueprint_icons = util.table.deepcopy(player.cursor_stack.blueprint_icons)
            local entities = player.cursor_stack.get_blueprint_entities()

            -- log("IMPORTED ENTITIES " .. serpent.block(entities)) -- TODO DEBUG

            if player.clean_cursor() then
                player_data.set_blueprint_data(
                    player,
                    export_stack,
                    blueprint_icons,
                    entities
                )

                gui_modal.open(player)
            end
        end
    else
        gui_modal.on_gui_click(player, event.element, event)
    end
end

local function on_gui_elem_changed(event)
    gui_modal.on_gui_elem_changed(get_event_player(event), event.element, event)
end

local function on_gui_value_changed(event)
    gui_modal.on_gui_value_changed(get_event_player(event), event.element, event)
end

local function on_gui_text_changed(event)
    -- game.print("on_gui_text_changed " .. event.element.name .. " = " .. (event.element.type == "textfield" and event.element.text or "(no text)"))
    local player = get_event_player(event)
    gui_modal.on_gui_text_changed(player, event.element, event)
end

script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_init)
script.on_event(defines.events.on_player_joined_game, on_player_init)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)
script.on_event(defines.events.on_gui_value_changed, on_gui_value_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
