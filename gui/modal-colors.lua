local blueprint = require("lib.blueprint")
local modal_defines = require("defines")
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
        style = "blueprint_editor_hue_slider",
        tooltip = {"blueprint-editor.color-hue"},
        max_value = 359,
        has_textfield = false,
        frame = "blueprint_editor_hue_frame",
    },
    {
        caption = "S",
        prop = "saturation",
        style = "slider",
        tooltip = {"blueprint-editor.color-saturation"},
        max_value = 1000,
        has_textfield = false,
    },
    {
        caption = "L",
        prop = "lightness",
        style = "slider",
        tooltip = {"blueprint-editor.color-lightness"},
        max_value = 1000,
        has_textfield = false,
    },
}

function screen_colors.build(player, modal_flow, blueprint_data)
    local inner_scroll = modal_flow.modal_frame.inner_content.inner_scroll
    local controls_flow = modal_flow.controls_flow

    local has_content = false

    if #blueprint_data.references.colors > 0 then
        has_content = true

        local colors_flow = inner_scroll.add({
            type = "flow",
            direction = "vertical",
            name = "colors_flow"
        })

        colors_flow.style.horizontally_stretchable = true
        colors_flow.style.margin = 4

        colors_flow.add({
            type = "label",
            caption = {"blueprint-editor.group-title-colors"},
            style = "large_caption_label",
        })

        local group_table = colors_flow.add({
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

    if has_content then
        local color_controls = controls_flow.add({
            type = "frame",
            name = "color_controls",
            style = "frame",
            direction = "vertical",
        })

        color_controls.visible = false
        color_controls.style.maximal_height = math.min(modal_defines.frame_maximal_height, player.display_resolution.height - 400)
    
        -- Header row
        local header = color_controls.add({
            type = "flow",
            direction = "horizontal",
        })
        header.drag_target = modal_flow
        header.style.vertical_align = "center"
    
        -- Header title
        local header_title = header.add({
            type = "label",
            caption = {"blueprint-editor.controls-title-colors"},
            style = "frame_title",
        })
        header_title.drag_target = modal_flow
    
        -- Drag handle filler
        local drag_filler = header.add({
            type = "empty-widget",
            style = "draggable_space_header",
        })
        drag_filler.style.height = 26
        drag_filler.style.horizontally_stretchable = true
        drag_filler.drag_target = modal_flow

        local color_boxes_table = color_controls.add({
            type = "table",
            name = "color_boxes_table",
            column_count = 2,
        })

        color_boxes_table.add({
            type = "label",
            caption = { "blueprint-editor.color-selected" },
        })

        color_boxes_table.add({
            type = "label",
            caption = { "blueprint-editor.color-changed" },
        })

        color_boxes_table.add({
            name = "color_selected",
            type = "label",
            caption = "A",
            style = "blueprint_editor_color_label",
        })

        color_boxes_table.add({
            name = "color_changed",
            type = "label",
            caption = "A",
            style = "blueprint_editor_color_label",
        })

        local color_sliders_table = color_controls.add({
            type = "table",
            name = "color_sliders_table",
            column_count = 3,
        })
        color_sliders_table.style.top_margin = 4
        color_sliders_table.style.bottom_margin = 4

        for _, color_data in pairs(colors) do
            color_sliders_table.add({
                type = "label",
                caption = color_data.caption,
                tooltip = color_data.tooltip,
            })

            local slider_container = color_sliders_table
            local slider_name = modal_defines.slider_prefix .. "colors--" .. color_data.prop

            if color_data.frame ~= nil then
                slider_container = color_sliders_table.add({
                    type = "frame",
                    style = color_data.frame,
                    name = "colors_frame--" .. color_data.prop,
                })
            end

            local slider = slider_container.add({
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

function screen_colors.update(player, modal_flow, prev_blueprint_data, blueprint_data, action, element)
    local inner_scroll = modal_flow.modal_frame.inner_content.inner_scroll
    local color_controls = modal_flow.controls_flow.color_controls
    local selected_color = blueprint_data.selection ~= nil and blueprint_data.selection.type == "colors" and blueprint_data.selection.value or nil

    local colors_flow = inner_scroll.colors_flow
    if colors_flow ~= nil then
        for _, button in pairs(colors_flow.table_colors.children) do
            local color = string.sub(button.name, string.len(modal_defines.button_prefix .. "colors--") + 1)
            local color_change = blueprint_data.changes.colors[color] or nil
            local default_color_values = blueprint.parse_color(color)
            local color_values = blueprint.parse_color(color_change or color)
            local is_changed = color_change ~= nil and color_change ~= color
            local is_selected = selected_color == color

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

    if selected_color ~= nil then
        if not color_controls.visible then
            color_controls.visible = true
        end

        local default_color_values = blueprint.parse_color(selected_color)
        local color_change = blueprint_data.changes.colors[selected_color] or nil
        local color_values = blueprint.parse_color(color_change or selected_color)

        local color_sliders_table = color_controls.color_sliders_table
        local color_boxes_table = color_controls.color_boxes_table

        if color_sliders_table ~= nil then

            for _, color_data in pairs(colors) do
                local slider_name = modal_defines.slider_prefix .. "colors--" .. color_data.prop
                if element == nil or element.name ~= slider_name then
                    local slider_container = color_data.frame and color_sliders_table["colors_frame--" .. color_data.prop] or color_sliders_table
                    local slider = slider_container[slider_name]

                    if slider.slider_value ~= color_values[color_data.prop] then
                        slider.slider_value = color_values[color_data.prop]
                    end
                end
                
                if color_data.has_textfield ~= false then
                    local textfield_name = modal_defines.textfield_prefix .. "colors--" .. color_data.prop
                    if element == nil or element.name ~= textfield_name then
                        local textfield = color_sliders_table[textfield_name]

                        if textfield.text ~= color_values[color_data.prop] then
                            textfield.text = color_values[color_data.prop]
                        end
                    end
                end
            end
        end

        if color_boxes_table ~= nil then
            color_boxes_table.color_selected.style.font_color = {
                r = default_color_values.red / 255,
                g = default_color_values.green / 255,
                b = default_color_values.blue / 255,
                a = 1, --color_values.alpha / 255,
            }
            
            color_boxes_table.color_changed.style.font_color = {
                r = color_values.red / 255,
                g = color_values.green / 255,
                b = color_values.blue / 255,
                a = 1, --color_values.alpha / 255,
            }
        end
    elseif color_controls ~= nil and color_controls.visible then
        color_controls.visible = false
    end
end

return screen_colors
