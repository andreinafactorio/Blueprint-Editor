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
        selection = nil,
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

function player_data.update_blueprint_data(player, selection, changes)
    local has_changed = false
    local blueprint_data = player_data.get_blueprint_data(player)

    if blueprint_data ~= nil then
        if blueprint_data.selection ~= selection then
            has_changed = true
            blueprint_data.selection = selection
        end

        if blueprint_data.changes ~= changes then
            has_changed = true
            blueprint_data.changes = changes
        end
    end

    return has_changed
end

function player_data.clear_blueprint_data(player)
    player_data.get_data(player).blueprint_data = nil
end

function player_data.load_from_item_stack(player, item_stack)
    local export_stack = item_stack.export_stack()
    local blueprint_icons = util.table.deepcopy(item_stack.blueprint_icons)
    local entities = item_stack.get_blueprint_entities()

    -- log("IMPORTED ENTITIES " .. serpent.block(entities)) -- TODO DEBUG

    player_data.set_blueprint_data(
        player,
        export_stack,
        blueprint_icons,
        entities
    )
end

return player_data
