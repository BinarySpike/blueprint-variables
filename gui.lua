local gui = require("__flib__/gui-lite")
local mgr = require("variables-manager")

gui.handle_events()

local mygui = {}

function mygui.gui_closed(event)
    if event.name == defines.events.on_gui_location_changed then
        game.players[event.player_index].clear_cursor() -- does it work??
    end
    if (event.name == defines.events.on_gui_closed) then
        mygui.close(event)
    end
end

function mygui.elem_selected(event)
    if event.name == defines.events.on_gui_elem_changed then
        global.players[event.player_index].settings[event.element.name] = event.element.elem_value
    end
end

function mygui.close(event)
    global.players[event.player_index].refs.bv_window.destroy()
    global.players[event.player_index] = nil
end

function mygui.confirm(event)
    mgr.applyVariables(global.players[event.player_index].settings, global.players[event.player_index].entities)
    mgr.applyNames(global.players[event.player_index].settings, global.players[event.player_index].entities_with_names)

    global.players[event.player_index].refs.bv_window.destroy()
    global.players[event.player_index] = nil
end

function mygui.create_window(player_index)
    if not global.players[player_index] then
        error("Attempt to create Blueprint Variable GUI without an existing session")
    end

    local player = global.players[player_index].player

    local i = 1;
    local variable_elems = {}

    while i <= 9 do
        table.insert(variable_elems,
            {
                type = "flow",
                direction = "horizontal",
                style = "slot_table_spacing_horizontal_flow",
                children = {
                    {
                        type = "sprite",
                        sprite = string.format("virtual-signal/signal-%s", i),
                        style_mods = {
                            width = 32,
                            height = 32,
                            stretch_image_to_widget_size = true,
                            margin = { 4, 4 }
                        }
                    },
                    {
                        type = "choose-elem-button",
                        name = string.format("blueprint-variable-%s-entity", i),
                        elem_type = "signal",
                        signal = { type = "virtual", name = string.format("blueprint-variable-%s-entity", i) },
                        handler = mygui.elem_selected
                    },
                    {
                        type = "empty-widget",
                        style_mods = {
                            width = 40,
                            padding = 0,
                        }
                    },
                    {
                        type = "choose-elem-button",
                        name = string.format("blueprint-variable-%s-arithmetic-1", i),
                        elem_type = "signal",
                        signal = { type = "virtual", name = string.format("blueprint-variable-%s-arithmetic-1", i) },
                        handler = mygui.elem_selected
                    },
                    {
                        type = "choose-elem-button",
                        name = string.format("blueprint-variable-%s-arithmetic-2", i),
                        elem_type = "signal",
                        signal = { type = "virtual", name = string.format("blueprint-variable-%s-arithmetic-2", i) },
                        handler = mygui.elem_selected
                    },
                    {
                        type = "choose-elem-button",
                        name = string.format("blueprint-variable-%s-arithmetic-3", i),
                        elem_type = "signal",
                        signal = { type = "virtual", name = string.format("blueprint-variable-%s-arithmetic-3", i) },
                        handler = mygui.elem_selected
                    },
                    {
                        type = "choose-elem-button",
                        name = string.format("blueprint-variable-%s-arithmetic-4", i),
                        elem_type = "signal",
                        signal = { type = "virtual", name = string.format("blueprint-variable-%s-arithmetic-4", i) },
                        handler = mygui.elem_selected
                    },
                }
            }
        )
        i = i + 1
    end

    gui.add(player.gui.screen, {
        {
            name = "bv_window",
            type = "frame",
            direction = "vertical",
            handler = mygui.gui_closed,
            auto_center = true,
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    style_mods = {
                        vertical_spacing = 6
                    },
                    children = {
                        {
                            name = "bv_titlebar",
                            type = "flow",
                            style = "flib_titlebar_flow",
                            children = {
                                { type = "label", style = "frame_title", caption = "Blueprint Variables",
                                    ignored_by_interaction = true },
                                { type = "empty-widget", style = "flib_titlebar_drag_handle",
                                    ignored_by_interaction = true },
                                {
                                    type = "sprite-button",
                                    name = "close",
                                    style = "frame_action_button",
                                    sprite = "utility/close_white",
                                    hovered_sprite = "utility/close_black",
                                    clicked_sprite = "utility/close_black",
                                    mouse_button_filter = { "left" },
                                    handler = mygui.close
                                }
                            }
                        },
                        {
                            name = "bv_content",
                            type = "flow",
                            style = "horizontal_flow",
                            children = {
                                {
                                    type = "frame",
                                    style = "inside_shallow_frame_with_padding",
                                    children = {
                                        {
                                            name = "slot_frame",
                                            type = "frame",
                                            style = "slot_button_deep_frame",
                                            direction = "vertical",
                                            children = variable_elems
                                        }
                                    }
                                }
                            }
                        },
                        {
                            type = "flow",
                            name = "bv_dialog_bar",
                            style_mods = {
                                padding = {6,0,0,0}
                            },
                            children = {
                                {
                                    name = "cancel_button",
                                    type = "button",
                                    style = "red_back_button",
                                    caption = "Clear",
                                    handler = mygui.close
                                },
                                {
                                    type = "empty-widget",
                                    style = "flib_dialog_footer_drag_handle",
                                    ignored_by_interaction = true
                                },
                                {
                                    name = "confirm_button",
                                    type = "button",
                                    style = "confirm_button",
                                    caption = "Apply",
                                    handler = mygui.confirm
                                }
                            }
                        }
                    }
                }
            }
        }
    }, global.players[player_index].refs)

    global.players[player_index].refs.bv_window.auto_center = true
    global.players[player_index].refs.slot_frame.style.width = 224 * 2

    global.players[player_index].refs.bv_titlebar.drag_target = global.players[player_index].refs.bv_window
    global.players[player_index].refs.bv_dialog_bar.drag_target = global.players[player_index].refs.bv_window

    player.opened = global.players[player_index].refs.bv_window

end

gui.add_handlers(mygui)

return mygui
