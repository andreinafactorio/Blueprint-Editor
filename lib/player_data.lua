local blueprint = require("lib.blueprint")
local player_data = {}

function player_data.get_data(player)
    if not global.player_data then
        global.player_data = {}
    end

    if not global.player_data[player.name] then
        global.player_data[player.name] = {}
    end

    return global.player_data[player.name]
end

function player_data.get_modal_location(player)
    return player_data.get_data(player).modal_location or nil
end

function player_data.set_modal_location(player, location)
    player_data.get_data(player).modal_location = {
        x = location.x ~= nil and location.x or location[1],
        y = location.y ~= nil and location.y or location[2],
    }
end

function player_data.get_blueprint_data(player)
    return player_data.get_data(player).blueprint_data or nil
end

function player_data.set_blueprint_data(player, export_string, blueprint_icons, entities)
    local references = blueprint.get_references(entities, blueprint_icons)

    player_data.get_data(player).blueprint_data = {
        export_string = export_string,
        blueprint_icons = blueprint_icons,
        entities = entities,
        references = references,
        selection = {
            color = references.colors[1] or nil,
            recipe = references.recipes_entity_names[1] and (references.recipes_entity_names[1] .. "." .. references.recipes_by_entity[references.recipes_entity_names[1]][1]) or nil,
        },
        changes = {
            items = {},
            fluids = {},
            signals = {},
            colors = {},
            stations = {},
            alert_messages = {},
            recipes = {},
        },
    }
end

function player_data.clear_blueprint_data(player)
    player_data.get_data(player).blueprint_data = nil
end

return player_data
