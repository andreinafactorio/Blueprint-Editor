data:extend({

	-- Fonts
	{
		type = "font",
		name = "blueprint-editor_color-icon_large",
		from = "blueprint-editor_SquareIcon-normal",
		size = 75,
	},
	{
		type = "font",
		name = "blueprint-editor_color-icon",
		from = "blueprint-editor_SquareIcon-normal",
		size = 28,
	},
	{
		type = "font",
		name = "blueprint-editor_color-icon_small",
		from = "blueprint-editor_SquareIcon-normal",
		size = 14,
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
	{
		type = "sprite",
		name = "blueprint-editor_blueprint-white",
		filename = "__Blueprint-Editor__/graphics/shortcut-edit-x32-white.png",
		size = 32,
		mipmap_count = 2,
		priority = "extra-high-no-scale",
		flags = {"gui-icon"}
	},

	-- Shortcuts
	{
		type = "shortcut",
		name = "blueprint-editor-shortcut",
		order = "b[blueprints]-g[edit]",
		action = "lua",
		localised_name = {"blueprint-editor.shortcut-caption"},
		technology_to_unlock = "personal-roboport-equipment",
		style = "blue",
		icon = {
			filename = "__Blueprint-Editor__/graphics/shortcut-edit-x32-white.png",
			priority = "extra-high-no-scale",
			size = 32,
			scale = 0.5,
			mipmap_count = 2,
			flags = {"gui-icon"}
		},
		small_icon = {
			filename = "__Blueprint-Editor__/graphics/shortcut-x24.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 0.5,
			mipmap_count = 2,
			flags = {"gui-icon"}
		},
		disabled_small_icon = {
			filename = "__Blueprint-Editor__/graphics/shortcut-x24-white.png",
			priority = "extra-high-no-scale",
			size = 24,
			scale = 1,
			mipmap_count = 2,
			flags = {"gui-icon"}
		},
	  },
})

local gui_styles = data.raw["gui-style"]["default"]

gui_styles["blueprint_editor_slot_table"] = {
	type = "table_style",
	horizontal_spacing = 0,
	vertical_spacing = 0,
	cell_padding = 1,
	top_margin = -2,
	bottom_margin = -2,
}

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

gui_styles.blueprint_editor_large_caption_label = {
	type = "label_style",
	parent = "caption_label",
	font = "default-large-bold"
}

gui_styles.blueprint_editor_top_button = {
	type = "button_style",
	parent = "button",
	size = 38,
	top_padding = 3,
	right_padding = 3,
	bottom_padding = 3,
	left_padding = 3,
	default_graphical_set = {
		base = {position = {329, 48}, corner_size = 8},
		shadow = default_dirt
	},
	hovered_graphical_set = {
		base = {position = {346, 48}, corner_size = 8},
		shadow = default_dirt,
		glow = default_glow(red_arrow_button_glow_color, 0.5)
	},
	clicked_graphical_set = {
		base = {position = {363, 48}, corner_size = 8},
		shadow = default_dirt
	},
}

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
	parent = "slot_button",
	width = 32,
	height = 32,
	top_padding = 4,
	left_padding = 2,
	horizontal_align = "center",
	vertical_align = "center",
	font = "blueprint-editor_color-icon",
	default_graphical_set = {
		border = 1,
		center =
		{
		filename = "__core__/graphics/gui.png",
		position = {111, 108},
		size = {36, 36},
		scale = 1
		}
	},
	hovered_graphical_set = {
		border = 1,
		center =
		{
		filename = "__core__/graphics/gui.png",
		position = {148, 108},
		size = {36, 36},
		scale = 1
		}
	},
	clicked_graphical_set = {
		border = 1,
		center =
		{
		filename = "__core__/graphics/gui.png",
		position = {185, 108},
		size = {36, 36},
		scale = 1
		}
	}
}

gui_styles.blueprint_editor_color_label = {
	type = "label_style",
	parent = "frame_title",
	font = "blueprint-editor_color-icon_large",
	horizontal_align = "center",
	vertical_align = "center",
	height = 77,
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
			position = {17, 0},
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
    parent = "frame_button",
	left_margin = 4,
	width = 24,
	height = 24
}

gui_styles.blueprint_editor_hue_frame = {
	type = "frame_style",
	left_padding = -6,
	right_padding = -6,
	top_padding = -5,
	bottom_padding = -6,
	graphical_set = {
		base = {
			center = {
				filename = "__Blueprint-Editor__/graphics/hue.png",
				position = {0, 0},
				size = {360, 1},
				scale = 1,
			},
			left = { position = {59, 8}, size = {1, 1}, scale = 6},
			right = { position = {59, 8}, size = {1, 1}, scale = 6},
			top = { position = {59, 8}, size = {1, 1}, scale = 5 },
			bottom = { position = {59, 8}, size = {1, 1}, scale = 6 },
		},
	},
}

gui_styles.blueprint_editor_hue_slider = {
	type = "slider_style",
	parent = "slider",
	height = 20,
	button = {
		type = "button_style",
		width = 12,
		height = 17,
		padding = 0,
		default_graphical_set = {
			base = {
				top = {position = {0, 189}, size = {1, 1}, scale = 5},
				center = {position = {0, 189}, size = {24, 11}, scale = 0.5 },
				bottom = {position = {0, 220}, size = {24, 4}},
			},
			shadow =  {
				top = {position = {0, 184}, size = {1, 1}, scale = 5},
				center = {position = {96, 184}, size = {40, 16}, scale = 0.5 },
				bottom = {position = {96, 224}, size = {40, 8}},
				left_outer_border_shift = -4,
				right_outer_border_shift = 4,
				tint = {0, 0, 0, 0.55},
				draw_type = "outer"
			}
        },
        hovered_graphical_set = {
			base = {
				top = {position = {48, 189}, size = {1, 1}, scale = 5},
				center = {position = {48, 189}, size = {24, 11}, scale = 0.5 },
				bottom = {position = {48, 220}, size = {24, 4}},
			},
			shadow =  {
				top = {position = {0, 184}, size = {1, 1}, scale = 5},
				center = {position = {96, 184}, size = {40, 16}, scale = 0.5 },
				bottom = {position = {96, 224}, size = {40, 8}},
				left_outer_border_shift = -4,
				right_outer_border_shift = 4,
				tint = default_glow_color,
				draw_type = "outer"
			}
		},
		clicked_graphical_set = {
			base = {
				top = {position = {72, 189}, size = {1, 1}, scale = 5},
				center = {position = {72, 189}, size = {24, 11}, scale = 0.5 },
				bottom = {position = {72, 220}, size = {24, 4}},
			},
			shadow =  {
				top = {position = {0, 184}, size = {1, 1}, scale = 5},
				center = {position = {96, 184}, size = {40, 16}, scale = 0.5 },
				bottom = {position = {96, 224}, size = {40, 8}},
				left_outer_border_shift = -4,
				right_outer_border_shift = 4,
				tint = {0, 0, 0, 0.35},
				draw_type = "outer"
			}
		},
        disabled_graphical_set = {
			base = {position = {24, 189}, size = {24, 35}},
        },
        left_click_sound = {},
	},
	full_bar = {
		base = {
			left = {position = {59, 8}, size = {1, 1}},
			right = {position = {59, 8}, size = {1, 1}},
			center = {position = {59, 8}, size = {1, 1}},
		}
	},
	full_bar_disabled = {
		base = {
			left = {position = {59, 8}, size = {1, 1}},
			right = {position = {59, 8}, size = {1, 1}},
			center = {position = {59, 8}, size = {1, 1}},
		}
	},
	empty_bar = {
		base = {
			left = {position = {59, 8}, size = {1, 1}},
			right = {position = {59, 8}, size = {1, 1}},
			center = {position = {59, 8}, size = {1, 1}},
		}
	},
	empty_bar_disabled = {
		base = {
			left = {position = {59, 8}, size = {1, 1}},
			right = {position = {59, 8}, size = {1, 1}},
			center = {position = {59, 8}, size = {1, 1}},
		}
	},
}

gui_styles.blueprint_editor_import_textbox = {
	type = "textbox_style",
	parent = "stretchable_textfield",
	margin = 0,
	height = 200,
}
