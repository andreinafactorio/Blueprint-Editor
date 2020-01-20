local proto_util = require("lib.proto")
local mod_util = require("lib.util")

local component = {}

function component.build_frame(drag_target, container, frame_name, header_caption)
    local frame = container.add({
        type = "frame",
        name = frame_name,
        style = "frame",
        direction = "vertical",
    })

    frame.visible = false
    frame.style.width = 450

    -- Header row
    local header = frame.add({
        type = "flow",
        direction = "horizontal",
    })
    header.drag_target = drag_target
    header.style.vertical_align = "center"

    -- Header title
    local header_title = header.add({
        type = "label",
        caption = header_caption,
        style = "frame_title",
    })
    header_title.drag_target = drag_target

    -- Drag handle filler
    local drag_filler = header.add({
        type = "empty-widget",
        style = "draggable_space_header",
    })
    drag_filler.style.height = 26
    drag_filler.style.horizontally_stretchable = true
    drag_filler.drag_target = drag_target

    return frame
end

function component.build(container)
    local groups_table = container.add({
        type = "table",
        name = "groups_table",
        column_count = 6,
        style = "blueprint_editor_slot_table",
    })

    local buttons_scroll = container.add({
        type = "scroll-pane",
        name = "buttons_scroll",
        direction = "vertical",
        style = "blueprint_editor_scroll_pane",
    })
    buttons_scroll.style.top_padding = 1
    buttons_scroll.style.bottom_padding = 1
    buttons_scroll.style.left_padding = 0
end

function component.populate_groups(container, groups, name_prefix, max_per_row)
    local groups_table = container.groups_table
    groups_table.clear()

    for _, group in ipairs(groups) do
        groups_table.add({
            type = "sprite-button",
            sprite = "item-group." .. group.name,
            name = name_prefix .. group.name,
            style = "image_tab_slot",
            tooltip = group.localised_name,
        })
    end
end

function component.populate_buttons(container, protos, elem_type, name_prefix, max_per_row)
    local buttons_scroll = container.buttons_scroll
    buttons_scroll.clear()

    local subgroup_table = nil

    for _, proto_data in ipairs(protos) do
        local proto_type = proto_data.type
        local proto = proto_data.proto
        local subgroup_key = "subgroup_" .. proto.subgroup.name

        if subgroup_table == nil or subgroup_table.name ~= subgroup_key then
            subgroup_table = buttons_scroll.add({
                type = "table",
                name = subgroup_key,
                column_count = max_per_row,
                style = "blueprint_editor_slot_table",
            })
        end

        local button = subgroup_table.add({
            type = "choose-elem-button",
            elem_type = elem_type,
            resize_to_sprite = false,
            name = name_prefix .. (elem_type == "signal" and (proto_type .. "." .. proto.name) or proto.name),
        })
        button.style.margin = 0

        button.locked = true
        button.elem_value = elem_type == "signal" and {
            type = proto_type,
            name = proto.name,
        } or proto.name
    end
end

function component.update_selections(
    container,
    selected_group_name,
    selected_button_name,
    prev_selected_button_name
)
    for _, group_button in pairs(container.groups_table.children) do
        group_button.style = group_button.name == selected_group_name and "image_tab_selected_slot" or "image_tab_slot"
    end

    for _, subgroup_table in pairs(container.buttons_scroll.children) do
        for _, button in pairs(subgroup_table.children) do
            if prev_selected_button_name == nil or (selected_button_name == button.name or prev_selected_button_name == button.name) then
                button.style = button.name == selected_button_name and "blueprint_editor_selected_recipe_button" or "blueprint_editor_recipe_button"
            end
        end
    end
end

function component.clear(container)
    container.buttons_scroll.clear()
    container.groups_table.clear()
end

return component
