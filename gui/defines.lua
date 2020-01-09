local modal_defines = {}

modal_defines.max_protos_per_row = 20
modal_defines.max_icons_per_row = 10
modal_defines.max_recipes_per_row = 10
modal_defines.frame_width = 925
modal_defines.min_frame_height = 400
modal_defines.left_frame_width = 450

modal_defines.modal_name = "blueprint-editor-modal"
modal_defines.button_modal_close = modal_defines.modal_name .. "-close"
modal_defines.button_prefix = modal_defines.modal_name .. "-button--"
modal_defines.slider_prefix = modal_defines.modal_name .. "-slider--"
modal_defines.textfield_prefix = modal_defines.modal_name .. "-textfield--"
modal_defines.button_export_name = modal_defines.modal_name .. "-export-button"

modal_defines.on_set_change = script.generate_event_name()
modal_defines.on_unset_change = script.generate_event_name()
modal_defines.on_selected_change = script.generate_event_name()

return modal_defines
