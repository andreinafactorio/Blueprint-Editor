local constants = require("state.constants")
local blueprint = require("lib.blueprint")
local proto_util = require("lib.proto")
local modal_defines = require("defines")
local text_util = require("lib.text")
local mod_util = require("lib.util")
local proto_list = require("gui.components.proto-list")
local proto_select = require("gui.components.proto-select")

local screen_protos = {}

local function get_elem_tooltip(default_type, default_name, value_type, value_name, sources)

    local localised_name = { value_type .. "-name." .. value_name }
    if value_type == "item" then
        localised_name = proto_util.get_item_localised_name(value_name)
    elseif value_type == "fluid" then
        localised_name = proto_util.get_fluid_localised_name(value_name)
    elseif value_type == "virtual" or value_type == "virtual-signal" then
        localised_name = proto_util.get_virtual_signal_localised_name(value_name)
    end

    local tooltip = text_util.font("default-bold", localised_name)

    if default_type ~= value_type or default_name ~= value_name then
        local default_localised_name = { default_type .. "-name." .. default_name }
        if default_type == "item" then
            default_localised_name = proto_util.get_item_localised_name(default_name)
        elseif default_type == "fluid" then
            default_localised_name = proto_util.get_fluid_localised_name(default_name)
        elseif default_type == "virtual" or default_type == "virtual-signal" then
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

function screen_protos.build(player, modal_flow, blueprint_data)
    local inner_scroll = modal_flow.modal_frame.inner_content.inner_scroll
    local controls_flow = modal_flow.controls_flow

    for _, references_name in ipairs({ "items", "fluids", "signals" }) do
        if #blueprint_data.references[references_name] > 0 then
            -- Create the list of buttons.
            local list_flow = proto_list.build(
                inner_scroll,
                "frame_" .. references_name,
                {"blueprint-editor.group-title-" .. references_name},
                {"blueprint-editor.group-title-" .. references_name .. "-tooltip"},
                modal_defines.max_protos_per_row
            )
            proto_list.populate_buttons(
                list_flow,
                blueprint_data.references[references_name],
                modal_defines.button_prefix .. references_name .. "--"
            )
    
            -- Create the controls frame for changing the value.
            local control_frame = proto_select.build_frame(
                modal_flow,
                controls_flow,
                references_name .. "_controls",
                {"blueprint-editor.controls-title-" .. references_name}
            )
            control_frame.style.maximal_height = math.min(modal_defines.frame_maximal_height, player.display_resolution.height - 400)
            proto_select.build(control_frame)
        end
    end
end

function screen_protos.update(player, modal_flow, prev_blueprint_data, blueprint_data, action, element)
    local inner_scroll = modal_flow.modal_frame.inner_content.inner_scroll

    local items_collection = {
        type = "item",
        collection = game.item_prototypes,
        is_valid = function(proto) return not proto.has_flag("hidden") end
    }
    
    local fluids_collection = {
        type = "fluid",
        collection = game.fluid_prototypes,
        is_valid = function(proto) return not proto.hidden end
    }
    
    local virtuals_collection = {
        type = "virtual",
        collection = game.virtual_signal_prototypes,
        is_valid = function(proto) return not proto.special end
    }

    for references_name, opts in pairs({
        items = {
            prototype_collections = { items_collection },
            parse_value = function(value) return "item", value end,
            elem_type = "item"
        },
        fluids = {
            prototype_collections = { fluids_collection },
            parse_value = function(value) return "fluid", value end,
            elem_type = "fluid"
        },
        signals = {
            prototype_collections = { items_collection, fluids_collection, virtuals_collection },
            parse_value = function(value) return string.match(value, "^(.+)%.(.+)$") end,
            elem_type = "signal"
        },
    }) do
        local selected_value = blueprint_data.selection ~= nil and blueprint_data.selection.type == references_name and blueprint_data.selection.value or nil
        local list_flow = inner_scroll["frame_" .. references_name]
        local control_frame = modal_flow.controls_flow[references_name .. "_controls"]
        local button_name_prefix = modal_defines.button_prefix .. references_name .. "_change--"
        local group_name_prefix = modal_defines.button_prefix .. "proto_group--"

        if #blueprint_data.references[references_name] > 0 then
            proto_list.update_buttons(
                list_flow,
                blueprint_data.references[references_name],
                blueprint_data.references[references_name .. "_sources"],
                blueprint_data.changes[references_name],
                opts.parse_value,
                selected_value,
                modal_defines.button_prefix .. references_name .. "--"
            )
        end

        if selected_value ~= nil then
            if not control_frame.visible then
                control_frame.visible = true
            end

            local selected_type, selected_name = string.match(selected_value, "^(.+)%.(.+)$")
            local changed_value = blueprint_data.changes[references_name][selected_value] or selected_value
            local groups = {}

            -- Recreate the icons if the view has changed.
            if action == nil or action.type == constants.REFERENCE_SELECTION or action.type == constants.PROTO_GROUP_SELECTION then
                local protos = {}
                for _, prototype_collection in ipairs(opts.prototype_collections) do
                    for _, proto in pairs(prototype_collection.collection) do
                        if prototype_collection.type == selected_type and proto.name == selected_name or prototype_collection.is_valid(proto) then
                            groups[proto.subgroup.group.name] = proto.subgroup.group

                            if proto.subgroup.group.name == blueprint_data.selection.group then
                                table.insert(protos, {
                                    type = prototype_collection.type,
                                    proto = proto,
                                })
                            end
                        end
                    end
                end

                table.sort(protos, function(a, b) return proto_util.order_comparator(a.proto, b.proto) end)
                groups = mod_util.get_table_values(groups)
                table.sort(groups, proto_util.group_comparator)

                proto_select.populate_buttons(
                    control_frame,
                    protos,
                    opts.elem_type,
                    button_name_prefix,
                    10
                )
            end

            -- Recreate the group icons if the selection has changed.
            if action == nil or action.type == constants.REFERENCE_SELECTION then
                proto_select.populate_groups(
                    control_frame,
                    groups,
                    group_name_prefix,
                    6
                )
            end

            proto_select.update_selections(
                control_frame,
                group_name_prefix .. blueprint_data.selection.group,
                button_name_prefix .. changed_value,
                nil --prev_selected_button_name -- TODO
            )

        elseif control_frame ~= nil and control_frame.visible then
            control_frame.visible = false
            proto_select.clear(control_frame)
        end
    end
end

return screen_protos
