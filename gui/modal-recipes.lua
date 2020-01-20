local constants = require("state.constants")
local proto_util = require("lib.proto")
local blueprint = require("lib.blueprint")
local player_data = require("lib.player_data")
local modal_defines = require("defines")
local mod_util = require("lib.util")
local text_util = require("lib.text")
local proto_select = require("gui.components.proto-select")

local screen_recipes = {}

local function get_recipe_tooltip(default_name, value_name)
    local localised_name = proto_util.get_recipe_localised_name(value_name)
    local tooltip = text_util.font("default-bold", localised_name)

    if default_name ~= value_name then
        local default_localised_name = proto_util.get_recipe_localised_name(default_name)

        tooltip = text_util.two_lines(
            tooltip,
            text_util.ctooltip(
                {
                    "blueprint-editor.right-click-reset",
                    text_util.font("default-bold", text_util.cmousebutton({ "control-keys.mouse-button-2" })),
                    text_util.cwhite(text_util.icon_text(
                        "recipe",
                        default_name,
                        default_localised_name
                    )),
                }
            )
        )
    end

    return tooltip
end

function screen_recipes.build(player, modal_flow, blueprint_data)
    local inner_scroll = modal_flow.modal_frame.inner_content.inner_scroll
    local controls_flow = modal_flow.controls_flow

    if #blueprint_data.references.recipes > 0 then
        local recipes_flow = inner_scroll.add({
            type = "flow",
            direction = "vertical",
            name = "recipes_flow",
        })

        recipes_flow.style.horizontally_stretchable = true
        recipes_flow.style.margin = 4

        recipes_flow.add({
            type = "label",
            caption = {"blueprint-editor.group-title-recipes"},
            style = "large_caption_label",
        })

        for _, entity_name in ipairs(blueprint_data.references.recipes_entity_names) do
            local recipe_names = blueprint_data.references.recipes_by_entity[entity_name]
            local group_table = recipes_flow.add({
                type = "table",
                name = "group_table--" .. entity_name,
                column_count = 2,
                vertical_centering = false
            })

            local entity_sprite = group_table.add({
                type = "sprite",
                sprite = "entity." .. entity_name,
            })
            entity_sprite.tooltip = proto_util.get_entity_localised_name(entity_name)
            entity_sprite.style.right_margin = 8
            entity_sprite.style.top_margin = 2
   
            local recipes_table = group_table.add({
                type = "table",
                name = "recipes_table",
                column_count = modal_defines.max_recipes_per_row - 1
            })

            for _, recipe_name in ipairs(recipe_names) do
                recipes_table.add({
                    type = "sprite-button",
                    name = modal_defines.button_prefix .. "recipe--" .. entity_name .. "." .. recipe_name,
                })
            end
        end

        -- Create the controls frame for changing the value.
        local control_frame = proto_select.build_frame(
            modal_flow,
            controls_flow,
            "recipes_controls",
            {"blueprint-editor.controls-title-recipes"}
        )
        control_frame.style.maximal_height = math.min(modal_defines.frame_maximal_height, player.display_resolution.height - 400)
        proto_select.build(control_frame)
    end
end

function screen_recipes.update(player, modal_flow, prev_blueprint_data, blueprint_data, action, element)
    local selected_value = blueprint_data.selection ~= nil and blueprint_data.selection.type == "recipes" and blueprint_data.selection.value or nil
    local inner_scroll = modal_flow.modal_frame.inner_content.inner_scroll
    local control_frame = modal_flow.controls_flow.recipes_controls
    local button_name_prefix = modal_defines.button_prefix .. "recipes_change--"
    local group_name_prefix = modal_defines.button_prefix .. "proto_group--"

    if #blueprint_data.references.recipes > 0 then
        for entity_name, recipe_names in pairs(blueprint_data.references.recipes_by_entity) do
            local table_recipes = inner_scroll.recipes_flow["group_table--" .. entity_name].recipes_table

            for _, recipe_name in ipairs(recipe_names) do
                local recipe_key = entity_name .. "." .. recipe_name
                local recipe_change = blueprint_data.changes.recipes[recipe_key] or nil
                local button = table_recipes[modal_defines.button_prefix .. "recipe--" .. recipe_key]
                local is_changed = recipe_change ~= nil and recipe_change ~= recipe_name
                local is_selected = selected_value == recipe_key

                button.style = "blueprint_editor_" .. (is_selected and "selected_" or "") .. (is_changed and "green_" or "") .. "slot_button"
                button.sprite = "recipe." .. (recipe_change or recipe_name)
                button.tooltip = get_recipe_tooltip(recipe_name, recipe_change or recipe_name)
            end
        end
    end

    if selected_value ~= nil then
        if not control_frame.visible then
            control_frame.visible = true
        end

        local entity_name, recipe_name = string.match(selected_value, "^(.+)%.(.+)$")
        local change_recipe_name = blueprint_data.changes.recipes[selected_value] or recipe_name
        local entity_proto = game.entity_prototypes[entity_name]

        if action ~= nil then
            local recipe_groups = {}

            -- Recreate the recipe icons if the view has changed.
            if action.type == constants.REFERENCE_SELECTION or action.type == constants.PROTO_GROUP_SELECTION then

                local recipes = {}
                for _, recipe in pairs(player.force.recipes) do
                    if recipe_name == recipe.name or not recipe.hidden and recipe.enabled and recipe.enabled and not recipe.hidden and entity_proto.crafting_categories[recipe.category] then
                        recipe_groups[recipe.group.name] = recipe.group

                        if recipe.group.name == blueprint_data.selection.group then
                            table.insert(recipes, {
                                type = "recipe",
                                proto = recipe,
                            })
                        end
                    end
                end

                table.sort(recipes, function(a, b) return proto_util.order_comparator(a.proto, b.proto) end)
                recipe_groups = mod_util.get_table_values(recipe_groups)
                table.sort(recipe_groups, proto_util.group_comparator)

                proto_select.populate_buttons(
                    control_frame,
                    recipes,
                    "recipe",
                    button_name_prefix,
                    10
                )
            end

            -- Recreate the recipe group icons if the selected recipe has changed.
            if action.type == constants.REFERENCE_SELECTION then
                proto_select.populate_groups(
                    control_frame,
                    recipe_groups,
                    group_name_prefix,
                    6
                )
            end
        end

        proto_select.update_selections(
            control_frame,
            group_name_prefix .. blueprint_data.selection.group,
            button_name_prefix .. change_recipe_name,
            nil --prev_selected_button_name
        )
    elseif control_frame ~= nil and control_frame.visible then
        control_frame.visible = false
        proto_select.clear(control_frame)
    end
end

return screen_recipes
