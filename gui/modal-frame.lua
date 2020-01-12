local modal_defines = require("defines")

local function build_frame(player, container)
    local modal_frame = container.add({
        type = "frame",
        name = modal_defines.modal_name,
        style = "frame",
        direction = "vertical",
    })

    modal_frame.style.width = modal_defines.frame_width
    modal_frame.style.minimal_height = modal_defines.min_frame_height
    modal_frame.style.maximal_height = math.min(600, player.display_resolution.height - 200)

    -- Space for the shadow.
    modal_frame.style.margin = 10

    -- Header row
    local header = modal_frame.add({
        type = "flow",
        direction = "horizontal",
    })
    header.drag_target = modal_frame
    header.style.vertical_align = "center"

    -- Header title
    local header_title = header.add({
        type = "label",
        caption = {"blueprint-editor.modal-title"},
        style = "frame_title",
    })
    header_title.drag_target = modal_frame

    -- Drag handle filler
    local drag_filler = header.add({
        type = "empty-widget",
        style = "draggable_space_header",
    })
    drag_filler.style.height = 26
    drag_filler.style.horizontally_stretchable = true
    drag_filler.drag_target = modal_frame

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

    local tabbed_pane = modal_frame.add({
        type = "tabbed-pane",
        name = "tabbed_pane",
    })
    tabbed_pane.style.horizontally_stretchable = true
    tabbed_pane.style.top_margin = 8
    tabbed_pane.style.left_margin = -10
    tabbed_pane.style.right_margin = -10

    local tab_protos = tabbed_pane.add({
        type = "tab",
        name = "tab_protos",
        caption = { "blueprint-editor.tab-protos" },
    })

    local tab_protos_content = tabbed_pane.add({
        type = "frame",
        name = "tab_protos_content",
        direction = "vertical",
        style = "blueprint_editor_tab_content",
    })

    tabbed_pane.add_tab(tab_protos, tab_protos_content)

    local tab_colors = tabbed_pane.add({
        type = "tab",
        name = "tab_colors",
        caption = { "blueprint-editor.tab-colors" },
    })

    local tab_colors_content = tabbed_pane.add({
        type = "flow",
        name = "tab_colors_content",
        direction = "horizontal",
    })

    tabbed_pane.add_tab(tab_colors, tab_colors_content)

    local tab_strings = tabbed_pane.add({
        type = "tab",
        name = "tab_strings",
        caption = { "blueprint-editor.tab-strings" },
    })

    local tab_strings_content = tabbed_pane.add({
        type = "frame",
        name = "tab_strings_content",
        direction = "vertical",
        style = "blueprint_editor_tab_content",
    })

    tabbed_pane.add_tab(tab_strings, tab_strings_content)

    local tab_recipes = tabbed_pane.add({
        type = "tab",
        name = "tab_recipes",
        caption = { "blueprint-editor.tab-recipes" },
    })

    local tab_recipes_content = tabbed_pane.add({
        type = "flow",
        name = "tab_recipes_content",
        direction = "horizontal",
    })

    tabbed_pane.add_tab(tab_recipes, tab_recipes_content)

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

    return modal_frame
end

return build_frame
