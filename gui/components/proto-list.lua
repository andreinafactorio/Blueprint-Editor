local proto_util = require("lib.proto")
local mod_util = require("lib.util")
local text_util = require("lib.text")

local component = {}

local function get_proto_tooltip(reference_type, reference_name, changed_type, changed_name, sources)
    changed_type = changed_type or reference_type
    changed_name = changed_name or reference_name

    local localised_name = { changed_type .. "-name." .. changed_name }
    if changed_type == "item" then
        localised_name = proto_util.get_item_localised_name(changed_name)
    elseif changed_type == "fluid" then
        localised_name = proto_util.get_fluid_localised_name(changed_name)
    elseif changed_type == "virtual" or changed_type == "virtual-signal" then
        localised_name = proto_util.get_virtual_signal_localised_name(changed_name)
    end

    local tooltip = text_util.font("default-bold", localised_name)

    if reference_type ~= changed_type or reference_name ~= changed_name then
        local reference_localised_name = { reference_type .. "-name." .. reference_name }
        if reference_type == "item" then
            reference_localised_name = proto_util.get_item_localised_name(reference_name)
        elseif reference_type == "fluid" then
            reference_localised_name = proto_util.get_fluid_localised_name(reference_name)
        elseif reference_type == "virtual" or reference_type == "virtual-signal" then
            localised_name = proto_util.get_virtual_signal_localised_name(reference_name)
        end

        tooltip = text_util.two_lines(
            tooltip,
            text_util.ctooltip(
                {
                    "blueprint-editor.right-click-reset",
                    text_util.font("default-bold", text_util.cmousebutton({ "control-keys.mouse-button-2" })),
                    text_util.cwhite(text_util.icon_text(
                        reference_type,
                        reference_name,
                        reference_localised_name
                    )),
                }
            )
        )
    end

    if sources ~= nil and #sources > 0 then
        local source_tags = {}

        for _, entity_name in ipairs(sources) do
            if entity_name == "" then
                table.insert(source_tags, "[item=blueprint]")
            else
                table.insert(source_tags, "[entity=" .. entity_name .. "]")
            end
        end

        tooltip = text_util.two_lines(
            tooltip,
            {
                "blueprint-editor.reference-sources",
                table.concat(source_tags, " ")
            }
        )
    end

    return tooltip
end

function component.build(container, list_name, header_caption, header_tooltip, max_per_row)
    local list_flow = container.add({
        type = "flow",
        direction = "vertical",
        name = list_name,
    })

    list_flow.style.horizontally_stretchable = true
    list_flow.style.margin = 4

    -- Header
    list_flow.add({
        type = "label",
        caption = header_caption,
        tooltip = header_tooltip,
        style = "blueprint_editor_large_caption_label",
    })

    local buttons_table = list_flow.add({
        type = "table",
        name = "buttons_table",
        column_count = max_per_row,
    })

    return list_flow
end

function component.populate_buttons(list_flow, protos, button_name_prefix)
    local buttons_table = list_flow.buttons_table
    buttons_table.clear()

    for _, proto_name in ipairs(protos) do
        buttons_table.add({
            type = "sprite-button",
            name = button_name_prefix .. proto_name,
        })
    end
end

function component.update_buttons(
    list_flow,
    references,
    references_sources,
    changes,
    parse_value,
    selection_value,
    button_name_prefix
)
    for _, reference_value in ipairs(references) do
        local button_name = button_name_prefix .. reference_value
        local button = list_flow.buttons_table[button_name]
        local changed_value = changes[reference_value] or reference_value

        local is_changed = changed_value ~= reference_value
        local is_selected = selection_value == reference_value

        local reference_type, reference_name = parse_value(reference_value)
        local changed_type, changed_name = parse_value(changed_value)

        button.style = "blueprint_editor_" .. (is_selected and "selected_" or "") .. (is_changed and "green_" or "") .. "slot_button"
        button.sprite = (changed_type == "virtual" and "virtual-signal" or changed_type) .. "." .. changed_name
        button.tooltip = get_proto_tooltip(
            reference_type,
            reference_name,
            changed_type,
            changed_name,
            references_sources ~= nil and references_sources[reference_value] or nil
        )
    end
end

return component
