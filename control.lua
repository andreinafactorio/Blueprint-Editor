-- local serpent = require("_local.serpent") --TODO DEBUG
local mod_gui = require("mod-gui")
local mod_util = require("lib.util")
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
            sprite = "blueprint-editor_blueprint-white",
            style = "blueprint_editor_top_button",
            tooltip = { "blueprint-editor.top-button-tooltip" }
        })
    end
end

-- local function on_configuration_changed(event)
--     if game ~= nil then
--         for _, player in pairs(game.players) do
--             draw_toolbar_button(player)
--         end
--     end
-- end

local function handle_shortcut(player)
    -- Do nothing if the player is a spectator.
    if player.cursor_stack == nil then
        player.print("Cannot use blueprint editor as a spectator.")
        return
    end

    local is_holding_blueprint = mod_util.is_player_holding_blueprint(player)

    if gui_modal.is_open(player) then
        gui_modal.close(player)

        -- Just close the modal if the player isn't dropping another blueprint.
        if not is_holding_blueprint then
            return
        end
    end

    if is_holding_blueprint then
        player_data.load_from_item_stack(player, player.cursor_stack)
        player.clear_cursor()
    end

    gui_modal.open(player)
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
        handle_shortcut(player)
    else
        gui_modal.on_gui_click(player, event.element, event)
    end
end

local function on_gui_value_changed(event)
    gui_modal.on_gui_value_changed(get_event_player(event), event.element, event)
end

local function on_gui_text_changed(event)
    -- game.print("on_gui_text_changed " .. event.element.name .. " = " .. (event.element.type == "textfield" and event.element.text or "(no text)"))
    local player = get_event_player(event)
    gui_modal.on_gui_text_changed(player, event.element, event)
end

local function on_lua_shortcut(event)
    local player = get_event_player(event)

    if event.prototype_name == "blueprint-editor-shortcut" then
        handle_shortcut(player)
    end
end

local function on_runtime_mod_setting_changed(event)
    local player = get_event_player(event)

    if event.setting == "hide-top-button" and event.setting_type == "runtime-per-user" then
        local hide_top_button = settings.get_player_settings(player)["hide-top-button"].value or false

        if hide_top_button then
            local top_button = mod_gui.get_button_flow(player)[top_button_name]
            if top_button ~= nil then   
                top_button.destroy()
            end
        else
            draw_toolbar_button(player)
        end
    end
end

local function pcall_event(event_handler)
    return function(event)
        xpcall(
            function() event_handler(event) end,
            function(err)
                err = err or "??"
                log(err .. "\n" .. debug.traceback())

                local player = get_event_player(event)
                if player ~= nil then
                    player.print("Blueprint Editor Error: " .. err .. "\nMore detail is available in the game's log file. See wiki.factorio.com/log_file")
                end
            end
        )
    end
end

-- script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, pcall_event(on_player_init))
script.on_event(defines.events.on_player_joined_game, pcall_event(on_player_init))
script.on_event(defines.events.on_gui_click, pcall_event(on_gui_click))
script.on_event(defines.events.on_gui_value_changed, pcall_event(on_gui_value_changed))
script.on_event(defines.events.on_gui_text_changed, pcall_event(on_gui_text_changed))
script.on_event(defines.events.on_lua_shortcut, pcall_event(on_lua_shortcut))
script.on_event(defines.events.on_runtime_mod_setting_changed, pcall_event(on_runtime_mod_setting_changed))