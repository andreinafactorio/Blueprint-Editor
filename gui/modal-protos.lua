local blueprint = require("lib.blueprint")
local proto_util = require("lib.proto")
local modal_defines = require("defines")
local text_util = require("lib.text")

local screen_protos = {}

local function get_elem_tooltip(default_type, default_name, value_type, value_name, sources)

    local localised_name = { value_type .. "-name." .. value_name }
    if value_type == "item" then
        localised_name = proto_util.get_item_localised_name(value_name)
    elseif value_type == "fluid" then
        localised_name = proto_util.get_fluid_localised_name(value_name)
    elseif value_type == "virtual" then
        localised_name = proto_util.get_virtual_signal_localised_name(value_name)
    end

    local tooltip = text_util.font("default-bold", localised_name)

    if default_type ~= value_type or default_name ~= value_name then
        local default_localised_name = { default_type .. "-name." .. default_name }
        if default_type == "item" then
            default_localised_name = proto_util.get_item_localised_name(default_name)
        elseif default_type == "fluid" then
            default_localised_name = proto_util.get_fluid_localised_name(default_name)
        elseif default_type == "virtual" then
            localised_name = proto_util.get_virtual_signal_localised_name(default_name)
        end

        tooltip = text_util.two_lines(
            tooltip,
            text_util.ctooltip(
                {
                    "blueprint-editor.right-click-reset",
                    text_util.font("default-bold", text_util.cmousebutton({ "control-keys.mouse-button-2" })),
                    text_util.cwhite(text_util.icon_text(
                        default_type,
                        default_name,
                        default_localised_name
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

function screen_protos.build(player, modal_frame, blueprint_data)
    local container = modal_frame.tabbed_pane.tab_protos_content
    container.clear()

    local inner_content = container.add({
        type = "scroll-pane",
        name = "inner_content",
        direction = "vertical",
        style = "blueprint_editor_scroll_pane",
    })

    local has_content = false

    if #blueprint_data.references.items > 0 then
        has_content = true

        local group_frame = inner_content.add({
            type = "flow",
            direction = "vertical",
            name = "frame_items",
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        -- Header
        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-items"},
            tooltip ={"blueprint-editor.group-title-items-tooltip"},
            style = "caption_label",
        })

        local group_table = group_frame.add({
            type = "table",
            name = "table_items",
            column_count = modal_defines.max_protos_per_row,
        })

        for _, item_name in ipairs(blueprint_data.references.items) do
            local elem_value = item_name

            if blueprint_data.changes.items[item_name] ~= nil then
                elem_value = blueprint_data.changes.items[item_name]
            end

            local button = group_table.add({
                type = "choose-elem-button",
                elem_type = "item",
                name = modal_defines.button_prefix .. "items--" .. item_name,
                tooltip = get_elem_tooltip("item", item_name, "item", elem_value),
            })

            button.elem_value = elem_value
        end
    end

    if #blueprint_data.references.fluids > 0 then
        has_content = true

        local group_frame = inner_content.add({
            type = "flow",
            direction = "vertical",
            name = "frame_fluids",
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-fluids"},
            tooltip ={"blueprint-editor.group-title-fluids-tooltip"},
            style = "caption_label",
        })

        local group_table = group_frame.add({
            type = "table",
            name = "table_fluids",
            column_count = modal_defines.max_protos_per_row,
        })

        for _, fluid_name in ipairs(blueprint_data.references.fluids) do
            local elem_value = fluid_name

            if blueprint_data.changes.fluids[fluid_name] ~= nil then
                elem_value = blueprint_data.changes.fluids[fluid_name]
            end

            local button = group_table.add({
                type = "choose-elem-button",
                elem_type = "fluid",
                name = modal_defines.button_prefix .. "fluids--" .. fluid_name,
                tooltip = get_elem_tooltip("fluid", fluid_name, "fluid", elem_value),
            })
            
            button.elem_value = elem_value
        end
    end

    if #blueprint_data.references.signals > 0 then
        has_content = true

        local group_frame = inner_content.add({
            type = "flow",
            direction = "vertical",
            name = "frame_signals",
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-signals"},
            style = "caption_label",
        })

        local group_table = group_frame.add({
            type = "table",
            name = "table_signals",
            column_count = modal_defines.max_protos_per_row,
        })

        for _, signal in ipairs(blueprint_data.references.signals) do
            local signal_change = blueprint_data.changes.signals[signal] or nil
            local default_signal_type, default_signal_name = string.match(signal, "(.+)%.(.+)")
            local signal_type, signal_name = string.match(signal_change or signal, "(.+)%.(.+)")

            local button = group_table.add({
                type = "choose-elem-button",
                elem_type = "signal",
                name = modal_defines.button_prefix .. "signals--" .. signal,
                tooltip = get_elem_tooltip(
                    default_signal_type == "virtual" and "virtual-signal" or default_signal_type,
                    default_signal_name,
                    signal_type == "virtual" and "virtual-signal" or signal_type,
                    signal_name
                )
            })

            button.elem_value = {
                type = signal_type,
                name = signal_name,
            }
        end
    end

    if not has_content then
        inner_content.add({
            type = "label",
            caption = {"blueprint-editor.screen-protos-no-content"},
        })
    end
end

function screen_protos.update(player, modal_frame, blueprint_data)
    local inner_content = modal_frame.tabbed_pane.tab_protos_content.inner_content

    if #blueprint_data.references.items > 0 then
        local group_table = inner_content.frame_items.table_items

        for _, item_name in ipairs(blueprint_data.references.items) do
            local button_name = modal_defines.button_prefix .. "items--" .. item_name
            local button = group_table[button_name]
            local elem_value = item_name

            if blueprint_data.changes.items[item_name] ~= nil then
                elem_value = blueprint_data.changes.items[item_name]
            end
            
            local is_changed = elem_value ~= item_name

            button.style = "blueprint_editor_" .. (is_changed and "green_" or "") .. "slot_button"
            button.elem_value = elem_value
            button.tooltip = get_elem_tooltip(
                "item",
                item_name,
                "item",
                elem_value,
                blueprint_data.references.items_sources[item_name]
            )
        end
    end

    if #blueprint_data.references.fluids > 0 then
        local group_table = inner_content.frame_fluids.table_fluids

        for _, fluid_name in ipairs(blueprint_data.references.fluids) do
            local button_name = modal_defines.button_prefix .. "fluids--" .. fluid_name
            local button = group_table[button_name]
            local elem_value = fluid_name

            if blueprint_data.changes.fluids[fluid_name] ~= nil then
                elem_value = blueprint_data.changes.fluids[fluid_name]
            end
            
            local is_changed = elem_value ~= fluid_name

            button.style = "blueprint_editor_" .. (is_changed and "green_" or "") .. "slot_button"
            button.elem_value = elem_value
            button.tooltip = get_elem_tooltip(
                "fluid",
                fluid_name,
                "fluid",
                elem_value,
                blueprint_data.references.fluids_sources[fluid_name]
            )
        end
    end

    if #blueprint_data.references.signals > 0 then
        local group_table = inner_content.frame_signals.table_signals

        for _, signal in ipairs(blueprint_data.references.signals) do
            local signal_change = blueprint_data.changes.signals[signal] or nil
            local default_signal_type, default_signal_name = string.match(signal, "(.+)%.(.+)")
            local signal_type, signal_name = string.match(signal_change or signal, "(.+)%.(.+)")
            local button_name = modal_defines.button_prefix .. "signals--" .. signal
            local button = group_table[button_name]
            local is_changed = signal_change ~= nil and signal_change ~= signal

            button.style = "blueprint_editor_" .. (is_changed and "green_" or "") .. "slot_button"

            button.elem_value = {
                type = signal_type,
                name = signal_name,
            }

            button.tooltip = get_elem_tooltip(
                default_signal_type == "virtual" and "virtual-signal" or default_signal_type,
                default_signal_name,
                signal_type == "virtual" and "virtual-signal" or signal_type,
                signal_name,
                blueprint_data.references.signals_sources[signal]
            )
        end
    end
end

return screen_protos
