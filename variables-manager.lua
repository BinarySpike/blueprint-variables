local mgr = {}

local function getVariable(str)
    if not str then return nil end
    local Start = "blueprint-variable"
    if string.sub(str, 1, str.len(Start)) == Start then
        return str
    end

    return nil
end

local function checkGenericVariables(controlBehavior)
    local results = {}
    table.insert(results, getVariable((controlBehavior.circuit_condition.condition.first_signal or {}).name))
    table.insert(results, getVariable((controlBehavior.circuit_condition.condition.second_signal or {}).name))
    table.insert(results, getVariable((controlBehavior.logistic_condition.condition.first_signal or {}).name))
    table.insert(results, getVariable((controlBehavior.logistic_condition.condition.second_signal or {}).name))
    return results
end

function mgr.getNameVariables(e)
    local results = {}
    -- if e.supports_backer_name() and e.valid then
    --     for w in e.backer_name:gmatch("%[.-%]") do
    --         table.insert(results, getVariable(w:match("virtual%-signal%=(.-)%]"))) -- if variable, insert into results
    --     end
    -- end
    return results
end

function mgr.getLogisticVariables(e)
return {} -- not implemented
end

function mgr.getBlueprintVariables(e)
    local cb = e.get_control_behavior()
    if cb then
        if cb.type == defines.control_behavior.type.generic_on_off then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.inserter then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.lamp then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.roboport then
            local results = {}
            table.insert(results, getVariable((cb.available_logistic_output_signal or {}).name))
            table.insert(results, getVariable((cb.total_logistic_output_signal or {}).name))
            table.insert(results, getVariable((cb.available_construction_output_signal or {}).name))
            table.insert(results, getVariable((cb.total_construction_output_signal or {}).name))
            return results
            ---
        elseif cb.type == defines.control_behavior.type.train_stop then
            local results = {table.unpack(checkGenericVariables(cb))}
            table.insert(results,getVariable((cb.stopped_train_signal or {}).name))
            table.insert(results,getVariable((cb.trains_count_signal or {}).name))
            table.insert(results,getVariable((cb.trains_limit_signal or {}).name))
            return results
            ---
        elseif cb.type == defines.control_behavior.type.decider_combinator then
            local results = {}
            table.insert(results, getVariable((cb.parameters.first_signal or {}).name))
            table.insert(results, getVariable((cb.parameters.second_signal or {}).name))
            table.insert(results, getVariable((cb.parameters.output_signal or {}).name))
            return results
            ---
        elseif cb.type == defines.control_behavior.type.arithmetic_combinator then
            local results = {}
            table.insert(results, getVariable((cb.parameters.first_signal or {}).name))
            table.insert(results, getVariable((cb.parameters.second_signal or {}).name))
            table.insert(results, getVariable((cb.parameters.output_signal or {}).name))
            return results
            ---
        elseif cb.type == defines.control_behavior.type.constant_combinator then
            local results = {}
            for _, v in pairs(cb.parameters) do
                table.insert(results, getVariable((v.signal or {}).name))
            end

            return results
            ---
        elseif cb.type == defines.control_behavior.type.transport_belt then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.accumulator then
            return {getVariable((cb.output_signal or {}).name)}
            ---
        elseif cb.type == defines.control_behavior.type.rail_signal then
            local results = {}
            table.insert(results, getVariable((cb.red_signal or {}).name))
            table.insert(results, getVariable((cb.orange_signal or {}).name))
            table.insert(results, getVariable((cb.green_signal or {}).name))
            table.insert(results, getVariable((cb.circuit_condition.condition.first_signal or {}).name))
            table.insert(results, getVariable((cb.circuit_condition.condition.second_signal or {}).name))
            return results
            ---
        elseif cb.type == defines.control_behavior.type.rail_chain_signal then
            local results = {}
            table.insert(results, getVariable((cb.red_signal or {}).name))
            table.insert(results, getVariable((cb.orange_signal or {}).name))
            table.insert(results, getVariable((cb.green_signal or {}).name))
            table.insert(results, getVariable((cb.blue_signal or {}).name))
            ---
        elseif cb.type == defines.control_behavior.type.wall then
            local results = {}
            table.insert(results, getVariable((cb.output_signal or {}).name))
            table.insert(results, getVariable((cb.circuit_condition.condition.first_signal or {}).name))
            table.insert(results, getVariable((cb.circuit_condition.condition.second_signal or {}).name))
            return results
            ---
        elseif cb.type == defines.control_behavior.type.mining_drill then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.programmable_speaker then
            local results = {}
            table.insert(results, getVariable((cb.circuit_condition.condition.first_signal or {}).name))
            table.insert(results, getVariable((cb.circuit_condition.condition.second_signal or {}).name))
            return results
            ---
        end
    end
    return {}
end

local function updateSignal(signal, settings)
    if signal and getVariable(signal.name) and settings[signal.name] then
        signal.type = settings[signal.name].type
        signal.name = settings[signal.name].name
    end
    return signal
end

local function updateCombinatorParameters(parameters, settings)
    local p = parameters
    p.first_signal = updateSignal(p.first_signal, settings)
    p.second_signal = updateSignal(p.second_signal, settings)
    p.output_signal = updateSignal(p.output_signal, settings)
    return p
end

local function updateCircuitCondition(def, settings)
    local d = def
    d.condition.first_signal = updateSignal(d.condition.first_signal, settings)
    d.condition.second_signal = updateSignal(d.condition.second_signal, settings)
    return d
end

local function updateControlBehavior(cb, settings)
    if cb.type == defines.control_behavior.type.generic_on_off then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.inserter then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.lamp then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.roboport then
        cb.available_logistic_output_signal = updateSignal(cb.available_logistic_output_signal, settings)
        cb.total_logistic_output_signal = updateSignal(cb.total_logistic_output_signal, settings)
        cb.available_construction_output_signal = updateSignal(cb.available_construction_output_signal, settings)
        cb.total_construction_output_signal = updateSignal(cb.total_construction_output_signal, settings)
        ---
    elseif cb.type == defines.control_behavior.type.train_stop then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        cb.stopped_train_signal = updateSignal(cb.stopped_train_signal, settings)
        cb.trains_count_signal = updateSignal(cb.trains_count_signal, settings)
        cb.trains_limit_signal = updateSignal(cb.trains_limit_signal, settings)
        ---
    elseif cb.type == defines.control_behavior.type.decider_combinator then
        cb.parameters = updateCombinatorParameters(cb.parameters, settings)
        ---
    elseif cb.type == defines.control_behavior.type.arithmetic_combinator then
        cb.parameters = updateCombinatorParameters(cb.parameters, settings)
        ---
    elseif cb.type == defines.control_behavior.type.constant_combinator then
        local p = cb.parameters
        for _, v in pairs(p) do
            v.signal = updateSignal(v.signal, settings)
        end
        cb.parameters = p
        ---
    elseif cb.type == defines.control_behavior.type.transport_belt then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.accumulator then
        cb.output_signal = updateSignal(cb.output_signal, settings)
        ---
    elseif cb.type == defines.control_behavior.type.rail_signal then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.red_signal = updateSignal(cb.red_signal, settings)
        cb.orange_signal = updateSignal(cb.orange_signal, settings)
        cb.green_signal = updateSignal(cb.green_signal, settings)
        ---
    elseif cb.type == defines.control_behavior.type.rail_chain_signal then
        cb.red_signal = updateSignal(cb.red_signal, settings)
        cb.orange_signal = updateSignal(cb.orange_signal, settings)
        cb.green_signal = updateSignal(cb.green_signal, settings)
        cb.blue_signal = updateSignal(cb.blue_signal, settings)
        ---
    elseif cb.type == defines.control_behavior.type.wall then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.output_signal = updateSignal(cb.output_signal, settings)
        ---
    elseif cb.type == defines.control_behavior.type.mining_drill then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.programmable_speaker then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        ---
    end
end

function mgr.applyNames(settings, entities)
    for k, v in pairs(entities) do
        if v.valid then
            for w in v.backer_name:gmatch("%[.-%]") do -- find all variables
                local vg,vv = w:match("(virtual%-signal%=(.-))%]") -- get the replacement text (vg) and the variable name (vv)
                vg = vg:gsub("%-", "%%-") -- escape the replament text
                if settings[vv] then
                    local name = settings[vv].name
                    local type = settings[vv].type
                    if type == "virtual" then type = "virtual-signal" end
                    v.backer_name = v.backer_name:gsub(vg, type.."="..name) -- replace variable with value from settings
                end
            end
        end
    end
end

function mgr.applyVariables(settings, entities)
    for _, e in ipairs(entities) do
        if e.valid then
            local cb = e.get_control_behavior()
            if cb and cb.valid then
                updateControlBehavior(cb, settings)
            end
        end
    end
end

return mgr
