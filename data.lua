data:extend({

	-- Fonts
	{
		type = "font",
		name = "blueprint-editor_color-icon",
		from = "blueprint-editor_SquareIcon-normal",
		size = 28
	},
	{
		type = "font",
		name = "blueprint-editor_color-icon_small",
		from = "blueprint-editor_SquareIcon-normal",
		size = 14
	},

	-- Sprites
	{
		type = "sprite",
		name = "blueprint-editor_blueprint-export",
		filename = "__base__/graphics/icons/shortcut-toolbar/mip/new-blueprint-x32-white.png",
		size = 32,
		mipmap_count = 2,
		priority = "extra-high-no-scale",
		flags = {"gui-icon"}
	},
})

local gui_styles = data.raw["gui-style"]["default"]

local function selection_shadow(tint_value)
	return {
		position = {463, 86},
		corner_size = 8,
		tint = tint_value,
		scale = 0.35,
		draw_type = "outer"
	}
end

local slot_positions = {
	[""] = {
		default = {111, 0},
		hovered = {148, 0},
		clicked = {185, 0},
	},
	["green_"] = {
		default = {111, 108},
		hovered = {148, 108},
		clicked = {185, 108},
	},
}

local function create_button(positions, shadow, selected_shadow)
	return {
		type = "button_style",
		parent = "button",
		size = 36,
		padding = 1,
		margin = 1,
		default_graphical_set = {
			base = {
				border = 1,
				filename = "__core__/graphics/gui.png",
				position = positions.default,
				size = 36,
				scale = 1
			},
			shadow = shadow,
		},
		hovered_graphical_set = {
			base = {
				border = 1,
				filename = "__core__/graphics/gui.png",
				position = positions.hovered,
				size = 36,
				scale = 1
			},
			shadow = shadow,
		},
		clicked_graphical_set = {
			base = {
				border = 1,
				filename = "__core__/graphics/gui.png",
				position = positions.clicked,
				size = 36,
				scale = 1
			},
			shadow = shadow,
		},
		selected_graphical_set = {
			base = {
				border = 1,
				filename = "__core__/graphics/gui.png",
				position = positions.default,
				size = 36,
				scale = 1
			},
			shadow = selected_shadow or shadow,
		},
		selected_hovered_graphical_set = {
			base = {
				border = 1,
				filename = "__core__/graphics/gui.png",
				position = positions.hovered,
				size = 36,
				scale = 1
			},
			shadow = selected_shadow or shadow,
		},
		selected_clicked_graphical_set = {
			base = {
				border = 1,
				filename = "__core__/graphics/gui.png",
				position = positions.clicked,
				size = 36,
				scale = 1
			},
			shadow = selected_shadow or shadow,
		},
		pie_progress_color = {0.98, 0.66, 0.22, 0.5},
		left_click_sound = {},
	}
end

gui_styles["blueprint_editor_recipe_button"] = create_button(
	{
		default = {111, 144},
		hovered = {148, 144},
		clicked = {185, 144},
	}
)
gui_styles["blueprint_editor_recipe_button"].margin = 0

gui_styles["blueprint_editor_selected_recipe_button"] = create_button(
	{
		default = {185, 144},
		hovered = {185, 144},
		clicked = {185, 144},
	}
)
gui_styles["blueprint_editor_selected_recipe_button"].margin = 0

for color_prefix, positions in pairs(slot_positions) do
	gui_styles["blueprint_editor_" .. color_prefix .. "slot_button"] = create_button(
		positions,
		nil,
		selection_shadow({ r = 1, g = 0.9, b = 0.15 })
	)
	
	gui_styles["blueprint_editor_selected_" .. color_prefix .. "slot_button"] = create_button(
		positions,
		selection_shadow({ r = 1, g = 0.9, b = 0.15 })
	)

	local color_slot_button = "blueprint_editor_" .. color_prefix .. "color_slot_button"
	gui_styles[color_slot_button] = create_button(
		positions
	)
	gui_styles[color_slot_button].font = "blueprint-editor_color-icon"
	gui_styles[color_slot_button].horizontal_align = "center"
	gui_styles[color_slot_button].vertical_align = "center"

	local selected_color_slot_button = "blueprint_editor_selected_" .. color_prefix .. "color_slot_button"
	gui_styles[selected_color_slot_button] = create_button(
		positions,
		selection_shadow({ r = 1, g = 0.9, b = 0.15 })
	)
	gui_styles[selected_color_slot_button].font = "blueprint-editor_color-icon"
	gui_styles[selected_color_slot_button].horizontal_align = "center"
	gui_styles[selected_color_slot_button].vertical_align = "center"
end

gui_styles.blueprint_editor_color_button = {
	type = "button_style",
	parent = "slot_button",
	width = 32,
	height = 32,
	top_padding = 4,
	left_padding = 2,
	horizontal_align = "center",
	vertical_align = "center",
	font = "blueprint-editor_color-icon"
}

gui_styles.blueprint_editor_color_changed_button = {
	type = "button_style",
	parent = "green_slot_button",
	width = 32,
	height = 32,
	top_padding = 4,
	left_padding = 2,
	horizontal_align = "center",
	vertical_align = "center",
	font = "blueprint-editor_color-icon"
}

gui_styles.blueprint_editor_create_blueprint_button = {
	type = "button_style",
	parent = "button",
	default_font_color = {r=255, g=255, b=255},
	hovered_font_color = {r=255, g=255, b=255},
	clicked_font_color = {r=255, g=255, b=255},
	default_graphical_set = {
		base = {
			position = {329, 48},
			corner_size = 8,
		},
	},
	hovered_graphical_set = {
		base = {
			position = {346, 48},
			corner_size = 8,
		},
        glow = {
			position = {200, 128},
			corner_size = 8,
			tint = {106, 177, 225, 255},
			scale = 0.5,
			draw_type = "outer"
		},
	},
	clicked_graphical_set = {
		base = {
			position = {363, 48},
			corner_size = 8,
		},
	},
}

gui_styles.blueprint_editor_tab_content = {
	type = "frame_style",
	vertically_stretchable = "on",
    horizontally_stretchable = "on",
	vertical_flow_style = { type = "vertical_flow_style" },
	horizontal_scrollbar_style = { type = "horizontal_scrollbar_style" },
	vertical_scrollbar_style = { type = "vertical_scrollbar_style" },
	padding = 0,
	left_margin = 6,
	right_margin = 6,
	graphical_set = {
		base = {
			position = {85, 0},
			corner_size = 8,
			center = {position = {42, 8}, size = 1},
			draw_type = "outer"
		},
		shadow = default_inner_shadow
	},
}

gui_styles.blueprint_editor_controls_content = {
	type = "frame_style",
	vertically_stretchable = "on",
    horizontally_stretchable = "on",
	vertical_flow_style = { type = "vertical_flow_style" },
	horizontal_scrollbar_style = { type = "horizontal_scrollbar_style" },
	vertical_scrollbar_style = { type = "vertical_scrollbar_style" },
	padding = 0,
	left_margin = 6,
	right_margin = 6,
	graphical_set = {
		base = {
			position = {85, 0},
			corner_size = 8,
			center = {position = {8, 8}, size = 1},
			draw_type = "outer"
		},
		shadow = default_inner_shadow
	},
}

gui_styles.blueprint_editor_scroll_pane = {
	type = "scroll_pane_style",
	vertically_squashable = "on",
	horizontally_squashable = "on",
    horizontally_stretchable = "on",
    padding = 8,
	extra_padding_when_activated = 0,
	graphical_set = {},
	background_graphical_set = {},
}

gui_styles.blueprint_editor_textfield_changed = {
	type = "textbox_style",
	parent = "stretchable_textfield",
	maximal_width = 0,
	horizontally_stretchable = "on",
	default_background = {
        base = {
			position = {265, 0},
			corner_size = 8,
			tint = {64, 128, 64, 1},
		},
    },
	active_background = {
        base = {
			position = {265, 0},
			corner_size = 8,
			tint = {128, 200, 128, 1},
		},
    },
}

gui_styles.blueprint_editor_close_button = {
	type = "button_style",
	parent = "close_button",
	left_margin = 4,
	width = 24,
	height = 24
}
