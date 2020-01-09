local proto_util = require("lib.proto")
local blueprint = require("lib.blueprint")
local player_data = require("lib.player_data")
local modal_defines = require("./defines")
local mod_util = require("lib.util")
local text_util = require("lib.text")

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

function screen_recipes.build(player, modal_frame, blueprint_data)
    local container = modal_frame.tabbed_pane.tab_recipes_content
    container.clear()

    local inner_content = container.add({
        type = "frame",
        name = "inner_content",
        direction = "vertical",
        style = "blueprint_editor_tab_content",
    })
    inner_content.style.horizontally_stretchable = true

    local inner_content_scroll = inner_content.add({
        type = "scroll-pane",
        name = "inner_content_scroll",
        direction = "vertical",
        style = "blueprint_editor_scroll_pane",
    })

    local has_content = false

    if #blueprint_data.references.recipes > 0 then
        has_content = true

        local group_frame = inner_content_scroll.add({
            type = "flow",
            direction = "vertical",
            name = "frame_recipes"
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-recipes"},
            style = "caption_label",
        })

        for _, entity_name in ipairs(blueprint_data.references.recipes_entity_names) do
            local recipe_names = blueprint_data.references.recipes_by_entity[entity_name]
            local group_table = group_frame.add({
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
    end

    if not has_content then
        inner_content_scroll.add({
            type = "label",
            caption = {"blueprint-editor.screen-recipes-no-content"},
        })
    else
        local recipe_controls = container.add({
            type = "frame",
            name = "recipe_controls",
            direction = "vertical",
            style = "blueprint_editor_controls_content",
        })
        recipe_controls.style.vertically_stretchable = true
        recipe_controls.style.horizontally_stretchable = false
        recipe_controls.style.width = 430
    end
end

function screen_recipes.update(player, modal_frame, blueprint_data, event_element_name)
    local container = modal_frame.tabbed_pane.tab_recipes_content
    local inner_content_scroll = container.inner_content.inner_content_scroll
    local recipe_controls = container.recipe_controls

    if #blueprint_data.references.recipes > 0 then
        for entity_name, recipe_names in pairs(blueprint_data.references.recipes_by_entity) do
            local table_recipes = inner_content_scroll.frame_recipes["group_table--" .. entity_name].recipes_table

            for _, recipe_name in ipairs(recipe_names) do
                local recipe_key = entity_name .. "." .. recipe_name
                local recipe_change = blueprint_data.changes.recipes[recipe_key] or nil
                local button = table_recipes[modal_defines.button_prefix .. "recipe--" .. recipe_key]
                local is_changed = recipe_change ~= nil and recipe_change ~= recipe_name
                local is_selected = blueprint_data.selection.recipe == recipe_key

                button.style = "blueprint_editor_" .. (is_selected and "selected_" or "") .. (is_changed and "green_" or "") .. "slot_button"
                button.sprite = "recipe." .. (recipe_change or recipe_name)
                button.tooltip = get_recipe_tooltip(recipe_name, recipe_change or recipe_name)
            end
        end
    end

    if recipe_controls ~= nil then
        local entity_name, recipe_name = string.match(blueprint_data.selection.recipe, "^(.+)%.(.+)$")
        local change_recipe_name = blueprint_data.changes.recipes[blueprint_data.selection.recipe] or recipe_name
        local inner_scroll = recipe_controls["scroll_" .. entity_name]

        if inner_scroll == nil then
            recipe_controls.visible = true
            recipe_controls.clear()

            inner_scroll = recipe_controls.add({
                type = "scroll-pane",
                name = "scroll_" .. entity_name,
                direction = "vertical",
                style = "blueprint_editor_scroll_pane",
            })

            local valid_recipes = {}
            local valid_groups = {}
            local entity_proto = game.entity_prototypes[entity_name]

            if entity_proto ~= nil then
                for _, recipe in pairs(player.force.recipes) do
                    if recipe.enabled and not recipe.hidden and entity_proto.crafting_categories[recipe.category] then
                        table.insert(valid_recipes, recipe)
                    end
                end

                table.sort(valid_recipes, proto_util.order_comparator)
            end

            local subgroup_table = nil

            for _, recipe in ipairs(valid_recipes) do
                local subgroup_key = "subgroup_" .. recipe.subgroup.name
                local is_selected = recipe.name == change_recipe_name

                if subgroup_table == nil or subgroup_table.name ~= subgroup_key then
                    subgroup_table = inner_scroll.add({
                        type = "table",
                        name = subgroup_key,
                        column_count = modal_defines.max_recipes_per_row,
                    })
                end

                local button = subgroup_table.add({
                    type = "choose-elem-button",
                    elem_type = "recipe",
                    resize_to_sprite = false,
                    name = modal_defines.button_prefix .. "recipe_change--" .. recipe.name,
                    style = is_selected and "blueprint_editor_selected_recipe_button" or "blueprint_editor_recipe_button",
                })

                button.locked = true
                button.elem_value = recipe.name
            end
        else
            for _, subgroup_table in pairs(inner_scroll.children) do
                for _, button in pairs(subgroup_table.children) do
                    local is_selected = string.sub(button.name, string.len(modal_defines.button_prefix .. "recipe_change--") + 1) == change_recipe_name
                    button.style = is_selected and "blueprint_editor_selected_recipe_button" or "blueprint_editor_recipe_button"
                end
            end
        end
    end
end

return screen_recipes
