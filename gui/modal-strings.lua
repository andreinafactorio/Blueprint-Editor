local blueprint = require("lib.blueprint")
local modal_defines = require("./defines")

local screen_strings = {}

function screen_strings.build(player, modal_frame, blueprint_data)
    local container = modal_frame.tabbed_pane.tab_strings_content
    container.clear()

    local inner_content = container.add({
        type = "scroll-pane",
        name = "inner_content",
        direction = "vertical",
        style = "blueprint_editor_scroll_pane",
    })

    local has_content = false

    if #blueprint_data.references.stations > 0 then
        has_content = true

        local group_frame = inner_content.add({
            type = "flow",
            direction = "vertical",
            name = "frame_stations",
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-stations"},
            style = "caption_label",
        })

        local textfields_flow = group_frame.add({
            type = "table",
            name = "textfields",
            column_count = 2,
        })
        textfields_flow.style.horizontally_stretchable = true

        for _, station in ipairs(blueprint_data.references.stations) do
            local station_change = blueprint_data.changes.stations[station] or nil

            local replaced_station = blueprint.replace_text_references(station, function(type, value)
                return blueprint.get_text_tag_replacment(blueprint_data.changes, type, value)
            end)

            local text_input = textfields_flow.add({
                type = "textfield",
                name = modal_defines.textfield_prefix .. "stations--" .. station,
                style = (station_change == nil or station_change == replaced_station) and "stretchable_textfield" or "blueprint_editor_textfield_changed",
            })

            if station_change ~= nil then
                text_input.text = station_change
            else
                text_input.text = replaced_station
            end

            textfields_flow.add({
                type = "sprite-button",
                name = modal_defines.button_prefix .. "stations_reset--" .. station,
                sprite = "utility/reset_white",
                style = "control_settings_section_button",
                tooltip = { "blueprint-editor.reset-text" },
            })
        end
    end

    if #blueprint_data.references.alert_messages > 0 then
        has_content = true

        local group_frame = inner_content.add({
            type = "flow",
            direction = "vertical",
            name = "frame_alert_messages",
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-alert-messages"},
            style = "caption_label",
        })

        local textfields_flow = group_frame.add({
            type = "table",
            name = "textfields",
            column_count = 2,
        })
        textfields_flow.style.horizontally_stretchable = true

        for _, alert_message in ipairs(blueprint_data.references.alert_messages) do
            local alert_message_change = blueprint_data.changes.alert_messages[alert_message] or nil

            local replaced_alert_message = blueprint.replace_text_references(alert_message, function(type, value)
                return blueprint.get_text_tag_replacment(blueprint_data.changes, type, value)
            end)

            local text_input = textfields_flow.add({
                type = "textfield",
                name = modal_defines.textfield_prefix .. "alert_messages--" .. alert_message,
                style = (alert_message_change == nil or alert_message_change == replaced_alert_message) and "stretchable_textfield" or "blueprint_editor_textfield_changed",
            })

            if alert_message_change ~= nil then
                text_input.text = alert_message_change
            else
                text_input.text = replaced_alert_message
            end

            textfields_flow.add({
                type = "sprite-button",
                name = modal_defines.button_prefix .. "alert_messages_reset--" .. alert_message,
                sprite = "utility/reset_white",
                style = "control_settings_section_button",
                tooltip = { "blueprint-editor.reset-text" },
            })
        end
    end

    if not has_content then
        inner_content.add({
            type = "label",
            caption = {"blueprint-editor.screen-strings-no-content"},
        })
    end
end

function screen_strings.update(player, modal_frame, blueprint_data, event_element_name)
    local inner_content = modal_frame.tabbed_pane.tab_strings_content.inner_content

    if inner_content ~= nil then
        if #blueprint_data.references.stations > 0 then
            local group = inner_content.frame_stations
            local textfields = group.textfields

            for _, station in ipairs(blueprint_data.references.stations) do
                local station_change = blueprint_data.changes.stations[station] or nil

                local textfield_name = modal_defines.textfield_prefix .. "stations--" .. station
                local textfield = textfields[textfield_name]

                if station_change == nil and event_element_name ~= textfield_name then
                    textfield.text = blueprint.replace_text_references(station, function(type, value)
                        return blueprint.get_text_tag_replacment(blueprint_data.changes, type, value)
                    end)
                end

                textfield.style = station_change == nil and "stretchable_textfield" or "blueprint_editor_textfield_changed"
            end
        end

        if #blueprint_data.references.alert_messages > 0 then
            local group = inner_content.frame_alert_messages
            local textfields = group.textfields

            for _, alert_message in ipairs(blueprint_data.references.alert_messages) do
                local alert_message_change = blueprint_data.changes.alert_messages[alert_message] or nil

                local textfield_name = modal_defines.textfield_prefix .. "alert_messages--" .. alert_message
                local textfield = textfields[textfield_name]

                if alert_message_change == nil and event_element_name ~= textfield_name then
                    textfield.text = blueprint.replace_text_references(alert_message, function(type, value)
                        return blueprint.get_text_tag_replacment(blueprint_data.changes, type, value)
                    end)
                end

                textfield.style = alert_message_change == nil and "stretchable_textfield" or "blueprint_editor_textfield_changed"
            end
        end
    end
end

return screen_strings
