local modal_defines = require("defines")

local function build_frame(player, container, has_blueprint)
    local modal_flow = container.add({
        type = "frame",
        name = modal_defines.modal_name,
        direction = "horizontal",
        style = "outer_frame_without_shadow",
    })

    -- Space for the shadow.
    modal_flow.style.margin = 10

    local modal_frame = modal_flow.add({
        type = "frame",
        name = "modal_frame",
        style = "frame",
        direction = "vertical",
    })

    modal_frame.style.width = modal_defines.frame_width
    modal_frame.style.minimal_height = modal_defines.min_frame_height
    modal_frame.style.maximal_height = math.min(modal_defines.frame_maximal_height, player.display_resolution.height - 200)
    modal_frame.style.vertically_stretchable = false

    -- Header row
    local header = modal_frame.add({
        type = "flow",
        direction = "horizontal",
    })
    header.drag_target = modal_flow
    header.style.vertical_align = "center"

    -- Header title
    local header_title = header.add({
        type = "label",
        caption = {"blueprint-editor.modal-title"},
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

    -- header.add({ -- TODO DEBUG
    --     type = "button",
    --     name = "REFRESH",
    --     caption = "Refresh"
    -- })

    local close_button = header.add({
        type = "sprite-button",
        name = modal_defines.button_modal_close,
        style = "blueprint_editor_close_button",
        sprite = "utility/close_white",
    })

    if has_blueprint then
        local inner_content = modal_frame.add({
            type = "frame",
            name = "inner_content",
            direction = "vertical",
            style = "blueprint_editor_tab_content",
        })
        inner_content.style.horizontally_stretchable = true
        inner_content.style.top_margin = 8
    
        inner_content.add({
            type = "scroll-pane",
            name = "inner_scroll",
            direction = "vertical",
            style = "blueprint_editor_scroll_pane",
        })

        local export_button = modal_frame.add({
            type = "button",
            name = modal_defines.button_export_name,
            caption = { "blueprint-editor.export-button" },
            style = "blueprint_editor_create_blueprint_button",
        })
        export_button.style.top_margin = 6
        export_button.style.horizontally_stretchable = true
        export_button.style.padding = 3
        export_button.style.left_padding = 8
        export_button.style.right_padding = 8
    end

    local controls_flow = modal_flow.add({
        type = "flow",
        name = "controls_flow",
        direction = "vertical",
    })

    return modal_flow
end

return build_frame
