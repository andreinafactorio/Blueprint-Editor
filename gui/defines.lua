local modal_defines = {}

modal_defines.max_protos_per_row = 10
modal_defines.max_icons_per_row = 10
modal_defines.max_recipes_per_row = 10
modal_defines.frame_width = 500
modal_defines.frame_maximal_height = 700
modal_defines.min_frame_height = 400
modal_defines.left_frame_width = 450

modal_defines.modal_name = "blueprint-editor-modal"
modal_defines.button_drop_target = modal_defines.modal_name .. "-drop_target"
modal_defines.button_import_blueprint_string = modal_defines.modal_name .. "-import_string"
modal_defines.label_invalid_blueprint_string = modal_defines.modal_name .. "-invalid-import_string"
modal_defines.textbox_blueprint_string = modal_defines.modal_name .. "-import_string_textbox"
modal_defines.button_modal_close = modal_defines.modal_name .. "-close"
modal_defines.button_prefix = modal_defines.modal_name .. "-button--"
modal_defines.slider_prefix = modal_defines.modal_name .. "-slider--"
modal_defines.textfield_prefix = modal_defines.modal_name .. "-textfield--"
modal_defines.button_export_name = modal_defines.modal_name .. "-export-button"

return modal_defines
