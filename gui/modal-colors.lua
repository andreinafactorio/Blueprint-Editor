local blueprint = require("lib.blueprint")
local modal_defines = require("./defines")
local text_util = require("lib.text")

local screen_colors = {}

local colors = {
    {
        caption = "R",
        prop = "red",
        style = "red_slider",
    },
    {
        caption = "G",
        prop = "green",
        style = "green_slider",
    },
    {
        caption = "B",
        prop = "blue",
        style = "blue_slider",
    },
    -- {
    --     caption = "A",
    --     prop = "alpha",
    --     style = "slider",
    -- },
    {
        caption = "H",
        prop = "hue",
        style = "slider",
        max_value = 359,
        has_textfield = false,
    },
    {
        caption = "S",
        prop = "saturation",
        style = "slider",
        max_value = 1000,
        has_textfield = false,
    },
    {
        caption = "L",
        prop = "lightness",
        style = "slider",
        max_value = 1000,
        has_textfield = false,
    },
}

function screen_colors.build(player, modal_frame, blueprint_data)
    local container = modal_frame.tabbed_pane.tab_colors_content
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

    if #blueprint_data.references.colors > 0 then
        has_content = true

        local group_frame = inner_content_scroll.add({
            type = "flow",
            direction = "vertical",
            name = "frame_colors"
        })

        group_frame.style.horizontally_stretchable = true
        group_frame.style.margin = 4

        group_frame.add({
            type = "label",
            caption = {"blueprint-editor.group-title-colors"},
            style = "caption_label",
        })

        local group_table = group_frame.add({
            type = "table",
            name = "table_colors",
            column_count = modal_defines.max_icons_per_row,
        })

        for _, color in ipairs(blueprint_data.references.colors) do
            group_table.add({
                type = "button",
                name = modal_defines.button_prefix .. "colors--" .. color,
                caption = "A",
            })
        end
    end

    if not has_content then
        inner_content_scroll.add({
            type = "label",
            caption = {"blueprint-editor.screen-colors-no-content"},
        })
    else
        local color_controls = container.add({
            type = "frame",
            name = "color_controls",
            direction = "vertical",
            style = "blueprint_editor_controls_content",
        })
        color_controls.style.vertically_stretchable = true
        color_controls.style.horizontally_stretchable = false
        color_controls.style.width = 430
        color_controls.style.padding = 8

        local color_sliders_table = color_controls.add({
            type = "table",
            name = "color_sliders_table",
            column_count = 3,
        })

        for _, color_data in pairs(colors) do
            color_sliders_table.add({
                type = "label",
                caption = color_data.caption,
            })

            local slider = color_sliders_table.add({
                type = "slider",
                name = modal_defines.slider_prefix .. "colors--" .. color_data.prop,
                minimum_value = 0,
                maximum_value = color_data.max_value or 255,
                value_step = 1,
                discrete_slider = true,
                discrete_values = true,
                style = color_data.style,
            })
            slider.style.width = 300

            if color_data.has_textfield ~= false then
                local textfield = color_sliders_table.add({
                    type = "textfield",
                    name = modal_defines.textfield_prefix .. "colors--" .. color_data.prop,
                    numeric = true,
                    allow_decimal = false,
                    allow_negative = false,
                })
                textfield.style.width = 50
            else
                color_sliders_table.add({
                    type = "empty-widget",
                })
            end
        end
    end
end

function screen_colors.update(player, modal_frame, blueprint_data, event_element_name)
    local container = modal_frame.tabbed_pane.tab_colors_content
    
    local frame_colors = container.inner_content.inner_content_scroll.frame_colors
    if frame_colors ~= nil then

        for _, button in pairs(frame_colors.table_colors.children) do
            local color = string.sub(button.name, string.len(modal_defines.button_prefix .. "colors--") + 1)
            local color_change = blueprint_data.changes.colors[color] or nil
            local default_color_values = blueprint.parse_color(color)
            local color_values = blueprint.parse_color(color_change or color)
            local is_changed = color_change ~= nil and color_change ~= color
            local is_selected = blueprint_data.selection.color == color

            local tooltip = ""
            if is_changed then
                tooltip = text_util.ctooltip({
                    "blueprint-editor.right-click-reset",
                    text_util.cmousebutton({ "control-keys.mouse-button-2" }),
                    text_util.font(
                        "blueprint-editor_color-icon_small",
                        text_util.color(
                            default_color_values.red,
                            default_color_values.green,
                            default_color_values.blue,
                            "A"
                        )
                    ),
                })
            end

            button.tooltip = tooltip

            button.style = "blueprint_editor_" .. (is_selected and "selected_" or "") .. (is_changed and "green_color_slot_button" or "color_slot_button")
            button.style.font_color = {
                r = color_values.red / 255,
                g = color_values.green / 255,
                b = color_values.blue / 255,
                a = 1, --color_values.alpha / 255,
            }
            button.style.hovered_font_color = button.style.font_color
            button.style.clicked_font_color = button.style.font_color
            button.style.disabled_font_color = button.style.font_color
        end
    end

    local color_controls = container.color_controls
    if color_controls ~= nil then
        local color_sliders_table = color_controls.color_sliders_table

        if color_sliders_table ~= nil then
            local color_change = blueprint_data.changes.colors[blueprint_data.selection.color] or nil
            local color_values = blueprint.parse_color(color_change or blueprint_data.selection.color)

            for _, color_data in pairs(colors) do
                local slider_name = modal_defines.slider_prefix .. "colors--" .. color_data.prop
                if event_element_name ~= slider_name then
                    local slider = color_sliders_table[slider_name]

                    if slider.slider_value ~= color_values[color_data.prop] then
                        slider.slider_value = color_values[color_data.prop]
                    end
                end
                
                if color_data.has_textfield ~= false then
                    local textfield_name = modal_defines.textfield_prefix .. "colors--" .. color_data.prop
                    if event_element_name ~= textfield_name then
                        local textfield = color_sliders_table[textfield_name]

                        if textfield.text ~= color_values[color_data.prop] then
                            textfield.text = color_values[color_data.prop]
                        end
                    end
                end
            end
        end
    end
end

return screen_colors
