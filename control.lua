local gui = require("gui")
local mgr = require("variables-manager")

local function getSessionId(player_index, tick)
    return tostring(player_index) .. " " .. tostring(tick)
end

local function processEntityBuiltEvent(event)
    local tags = event.tags

    if tags and tags.bv and tags.bv.hasBlueprintVariable then
        if global.players[tags.bv.player_index] then -- if the session exists, build it
            table.insert(global.players[tags.bv.player_index].entities, event.created_entity)
        else
            tags.bv = nil -- session no longer exists, remove the tag
            event.created_entity.tags = tags
        end
    end
    if tags and tags.bv and tags.bv.hasVariableInName then
        if global.players[tags.bv.player_index] then
            table.insert(global.players[tags.bv.player_index].entities_with_names, event.created_entity)
        else
            tags.bv = nil
            event.created_entity.tags = tags
        end
    end
end

script.on_event(defines.events.on_built_entity, function(event)
    if (event.stack.is_blueprint or event.stack.is_blueprint_book or game.players[event.player_index].is_cursor_blueprint()) then

        local player = game.players[event.player_index]
        local playerData = global.players[event.player_index]
        local session_id = getSessionId(event.player_index, event.tick)

        if playerData and playerData.session_id ~= session_id then
            error("Player has existing session and is trying to create another")
        end

        local bpVariables = mgr.getBlueprintVariables(event.created_entity)
        local nameVariables = mgr.getNameVariables(event.created_entity)
        local logisticVariables = mgr.getLogisticVariables(event.created_entity);

        if next(bpVariables) or next(nameVariables) or next(logisticVariables) then
            local tags = event.created_entity.tags
            if not tags then tags = {} end
            if not tags.bv then tags.bv = {} end

            tags.bv = {
                hasBlueprintVariable = next(bpVariables) ~= nil,
                hasVariableInName = next(nameVariables) ~= nil,
                hasLogisticVariables = next(logisticVariables) ~= nil,
                session_id = session_id,
                player_index = event.player_index
            }

            event.created_entity.tags = tags

            if not playerData then
                global.players[event.player_index] = {
                    initialized = false,
                    session_id = session_id,
                    entities = {},
                    entities_with_names = {},
                    logistic_entities = {},
                    --player = player,
                    settings = {},
                    refs = {},
                    activeVariables = {}
                }
                playerData = global.players[event.player_index]

                gui.create_window(event.player_index)
            end

            if next(bpVariables) then
                table.insert(playerData.entities, event.created_entity)
            end
            if next(nameVariables) then
                table.insert(playerData.entities_with_names, event.created_entity)
            end
            if next(logisticVariables) then
                table.insert(playerData.logistic_entities, event.created_entity)
            end

            for _,v in pairs(bpVariables) do
                playerData.activeVariables[v] = true
            end
            for _,v in pairs(nameVariables) do
                playerData.activeVariables[v] = true
            end
            for _,v in pairs(logisticVariables) do
                playerData.activeVariables[v] = true
            end
        end
    else
        processEntityBuiltEvent(event)
    end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    processEntityBuiltEvent(event)
end)

script.on_event(defines.events.script_raised_built, function(event)
    //processEntityBuiltEvent(event);
end)

script.on_event(defines.events.script_raised_revive, function(event)
    //processEntityBuiltEvent(event);
end)

function on_init()
    if not global.players then
        global.players = {}
    end
end

script.on_init(on_init)
