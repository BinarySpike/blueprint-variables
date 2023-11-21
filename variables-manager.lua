local mgr = {}

--local oldMatch = "virtual%-signal%=(.-)%]"
--local oldDoubleMatch = "(virtual%-signal%=(.-))%]"

--local newMatch = "item=(blueprint%-variable%-.-)%]"
local newNewMatch = "%[.-%=(blueprint%-variable%-.-)%]"
local newTrainMatch = "(blueprint%-variable%-.+)"

local newDoubleMatch = "%[(.-%=(blueprint%-variable%-.-))%]"

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
    if e.supports_backer_name() and e.valid then
        for w in e.backer_name:gmatch("%[.-%]") do
            table.insert(results, getVariable(w:match(newNewMatch))) -- if variable, insert into results
        end
    end
    return results
end

function mgr.getTrainVariables(eArr)
  local results = {}
  for eKey, e in pairs(eArr) do
    if e.name == 'locomotive' then
      if e.schedule then
        for scheduleKey, schedule in pairs(e.schedule) do
          for w in schedule.station:gmatch("%[.-%]") do
            table.insert(results, getVariable(w:match(newNewMatch))) -- if variable, insert into results
          end
          if schedule.wait_conditions then
            for waitConditionKey, waitCondition in pairs(schedule.wait_conditions) do
              if waitCondition.type == 'item_count' or waitCondition.type == 'fluid_count' or waitCondition.type == 'circuit' then
                if waitCondition.condition.first_signal then
                  table.insert(results, getVariable(waitCondition.condition.first_signal.name:match(newTrainMatch)));
                end
                if waitCondition.condition.second_signal then
                  table.insert(results, getVariable(waitCondition.condition.second_signal.name:match(newTrainMatch)));
                end
              end
            end
          end
        end
      end
    end
  end
  return results
end

function mgr.getInventoryFilterVariables(eArr)
  local results = {}
  
  for eKey, e in pairs(eArr) do
    local filters
    if e.inventory and e.inventory.filters then
      filters = e.inventory.filters
    elseif e.filters then
      filters = e.filters
    else
      goto continue
    end

    for invFilterKey, invFilter in pairs(filters) do
      table.insert(results, getVariable(invFilter.name))
    end
    ::continue::
  end
  return results
end

function mgr.getLogisticVariables(e)
  local results = {}
  if e.request_slot_count > 0 then
    for i=1,e.request_slot_count do
      table.insert(results, getVariable((e.get_request_slot(i) or {}).name));
    end
    return results
  end
  return results
end

function mgr.getFilterVariables(e)
  local results = {}

  local eType

  if e.type == 'entity-ghost' then
    eType = e.ghost_type
  else
    eType = e.type
  end

  if e.filter_slot_count > 0 and eType ~= 'infinity-container' then    
    for i=1,e.filter_slot_count do
      table.insert(results, getVariable(e.get_filter(i)));
    end
  end

  if eType == 'splitter' and e.splitter_filter then
    table.insert(results, getVariable(e.splitter_filter.name));
  end

  if eType == 'programmable-speaker' then
    table.insert(results, getVariable((e.alert_parameters.icon_signal_id or {}).name))
    
    for w in e.alert_parameters.alert_message:gmatch("%[.-%]") do
      table.insert(results, getVariable(w:match(newNewMatch))) -- if variable, insert into results
    end
  end

  return results
end

function mgr.getBlueprintVariables(e)
    local cb = e.get_control_behavior()
    if cb then
        if cb.type == defines.control_behavior.type.generic_on_off then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.inserter then
          local results = { table.unpack(checkGenericVariables(cb)) }
            table.insert(results, getVariable((cb.circuit_stack_control_signal or {}).name))
            return results
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
            local results = { table.unpack(checkGenericVariables(cb)) }
            table.insert(results, getVariable((cb.stopped_train_signal or {}).name))
            table.insert(results, getVariable((cb.trains_count_signal or {}).name))
            table.insert(results, getVariable((cb.trains_limit_signal or {}).name))
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
            if type(cb.parameters) == "table" then
              for _, v in pairs(cb.parameters) do
                  table.insert(results, getVariable((v.signal or {}).name))
              end
            end

            return results
            ---
        elseif cb.type == defines.control_behavior.type.transport_belt then
            return checkGenericVariables(cb)
            ---
        elseif cb.type == defines.control_behavior.type.accumulator then
            return { getVariable((cb.output_signal or {}).name) }
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
            return results
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

local function updateSignal(signal, settings, dontReturnSpecialSignals)
  local result = {}
  if signal and getVariable(signal.name) and settings[signal.name] then
    if dontReturnSpecialSignals and (settings[signal.name].name == 'signal-everything' or settings[signal.name].name == 'signal-anything' or settings[signal.name].name == 'signal-each') then
      return signal
    end
    signal.type = settings[signal.name].type
    signal.name = settings[signal.name].name
  end
  return signal
end

local function updateCircuitCondition(def, settings)
    local result = def;
    local d = {}
    if def.condition then
      d = result.condition
    else
      d = result
    end

    d.first_signal = updateSignal(d.first_signal, settings)
    
    if d.second_signal and d.second_signal.name and d.second_signal.name:match("^blueprint%-variable%-%d%-stack%-size$") then
      local num = d.second_signal.name:match("^blueprint%-variable%-(%d)")
      local varName = string.format("blueprint-variable-%s-entity", num)
      local itemName = settings[varName].name
      local stackSize = game.item_prototypes[itemName].stack_size;
      d.second_signal = nil;
      d.constant = stackSize;
    elseif d.second_signal and d.second_signal.name then
      d.second_signal = updateSignal(d.second_signal, settings)
    end

    if d.output_signal then
      d.output_signal = updateSignal(d.output_signal, settings, true)
    end

    return result
end

local function updateControlBehavior(cb, settings)
    if cb.type == defines.control_behavior.type.generic_on_off then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.inserter then
        cb.circuit_stack_control_signal = updateSignal(cb.circuit_stack_control_signal or {}, settings)
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.lamp then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.roboport then
        cb.available_logistic_output_signal = updateSignal(cb.available_logistic_output_signal or {}, settings)
        cb.total_logistic_output_signal = updateSignal(cb.total_logistic_output_signal or {}, settings)
        cb.available_construction_output_signal = updateSignal(cb.available_construction_output_signal or {}, settings)
        cb.total_construction_output_signal = updateSignal(cb.total_construction_output_signal or {}, settings)
        ---
    elseif cb.type == defines.control_behavior.type.train_stop then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        cb.stopped_train_signal = updateSignal(cb.stopped_train_signal or {}, settings)
        cb.trains_count_signal = updateSignal(cb.trains_count_signal or {}, settings)
        cb.trains_limit_signal = updateSignal(cb.trains_limit_signal or {}, settings)
        ---
    elseif cb.type == defines.control_behavior.type.decider_combinator then
        cb.parameters = updateCircuitCondition(cb.parameters, settings)
        ---
    elseif cb.type == defines.control_behavior.type.arithmetic_combinator then
        cb.parameters = updateCircuitCondition(cb.parameters, settings)
        ---
    elseif cb.type == defines.control_behavior.type.constant_combinator then
        local p = cb.parameters
        for _, v in pairs(p) do
            if v.signal.name and v.signal.name:match("^blueprint%-variable%-%d%-stack%-size$") then
              local num = v.signal.name:match("^blueprint%-variable%-(%d)")
              local varName = string.format("blueprint-variable-%s-entity", num)
              if settings[varName] == nil then goto continue end
              local itemName = settings[varName].name
              if itemName == nil then goto continue end
              local stackSize = game.item_prototypes[itemName].stack_size;
              v.count = stackSize * v.count
              v.signal.name = varName

              ::continue::
            end
            v.signal = updateSignal(v.signal, settings, true)
        end
        cb.parameters = p
        ---
    elseif cb.type == defines.control_behavior.type.transport_belt then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.logistic_condition = updateCircuitCondition(cb.logistic_condition, settings)
        ---
    elseif cb.type == defines.control_behavior.type.accumulator then
        cb.output_signal = updateSignal(cb.output_signal or {}, settings)
        ---
    elseif cb.type == defines.control_behavior.type.rail_signal then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.red_signal = updateSignal(cb.red_signal or {}, settings)
        cb.orange_signal = updateSignal(cb.orange_signal or {}, settings)
        cb.green_signal = updateSignal(cb.green_signal or {}, settings)
        ---
    elseif cb.type == defines.control_behavior.type.rail_chain_signal then
        cb.red_signal = updateSignal(cb.red_signal or {}, settings)
        cb.orange_signal = updateSignal(cb.orange_signal or {}, settings)
        cb.green_signal = updateSignal(cb.green_signal or {}, settings)
        cb.blue_signal = updateSignal(cb.blue_signal or {}, settings)
        ---
    elseif cb.type == defines.control_behavior.type.wall then
        cb.circuit_condition = updateCircuitCondition(cb.circuit_condition, settings)
        cb.output_signal = updateSignal(cb.output_signal or {}, settings)
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

function mgr.calculateVariableSettings(settings)

  for varNum = 1, 9, 1 do
    local entityName = string.format("blueprint-variable-%s-entity", varNum);
    local furnaceName = string.format("blueprint-variable-%s-furnace-result", varNum);
    if settings[entityName] ~= nil then
      local furnaceResult = game.get_filtered_recipe_prototypes(
        {
          {filter = "has-ingredient-item", elem_filters = {{filter = "name", name = settings[entityName].name}}},
          {filter = "category", category = "smelting", mode = "and"}
        }
      )

      if furnaceResult and #furnaceResult == 1 then
        for furnaceKey, furnaceValue in pairs(furnaceResult) do
          settings[furnaceName] = { name = furnaceKey, type="item" }
          break
        end
      end
    end
  end

  return settings
end

function mgr.applyNames(settings, entities)
    for k, v in pairs(entities) do
        if v.valid then
            for w in v.backer_name:gmatch("%[.-%]") do -- find all variables
                local vg, vv = w:match(newDoubleMatch) -- get the replacement text (vg) and the variable name (vv)
                if vg and vv then
                    vg = vg:gsub("%-", "%%-") -- escape the replament text
                    if settings[vv] then
                        local name = settings[vv].name
                        local type = settings[vv].type
                        if type == "virtual" then type = "virtual-signal" end
                        if name == nil then goto continue end
                        v.backer_name = v.backer_name:gsub(vg, type .. "=" .. name) -- replace variable with value from settings
                        ::continue::
                    end
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

function mgr.applyLogisticVariables(settings, entities)
  for _, e in ipairs(entities) do
    if e.valid and e.request_slot_count > 0 then
      for i=1,e.request_slot_count do
        local slot = e.get_request_slot(i)
        if slot then
          if slot.name:match("^blueprint%-variable%-%d%-stack%-size$") then
            local num = slot.name:match("^blueprint%-variable%-(%d)")
            local varName = string.format("blueprint-variable-%s-entity", num)
            if settings[varName] == nil then goto continue end
            local itemName = settings[varName].name
            if itemName == nil then goto continue end
            local stackSize = game.item_prototypes[itemName].stack_size;
            slot.count = stackSize * slot.count;
            slot.name = settings[varName].name
          elseif settings[slot.name] then
            slot.name = settings[slot.name].name
          end
          if slot.name == nil then goto continue end
          e.set_request_slot(slot, i);
          ::continue::
        end
      end
    end
  end
end

function mgr.applyFilterVariables(settings, entities)
  for _, e in ipairs(entities) do
    if e.valid then
      local eType

      if e.type == 'entity-ghost' then
        eType = e.ghost_type
      else
        eType = e.type
      end

      if e.filter_slot_count > 0 then
        for i=1,e.filter_slot_count do
          local slot = e.get_filter(i)

          if slot and settings[slot] then
            e.set_filter(i, settings[slot].name)
          end
        end
      end

      if e.valid and eType == 'splitter' and e.splitter_filter and settings[e.splitter_filter.name] then
        e.splitter_filter = settings[e.splitter_filter.name].name
      end

      if e.valid and eType == 'programmable-speaker' then
        
        local alert_parameters = e.alert_parameters

        if e.valid and alert_parameters.icon_signal_id and settings[alert_parameters.icon_signal_id.name] then
          alert_parameters.icon_signal_id.type = settings[alert_parameters.icon_signal_id.name].type
          alert_parameters.icon_signal_id.name = settings[alert_parameters.icon_signal_id.name].name
          e.alert_parameters = alert_parameters
        end
        
        for w in alert_parameters.alert_message:gmatch("%[.-%]") do
          local vg, vv = w:match(newDoubleMatch)
          if vg and vv then
            if settings[vv] then
              vg = vg:gsub("%-", "%%-") -- escape the replament text
              local name = settings[vv].name
              local type = settings[vv].type
              if type == "virtual" then type = "virtual-signal" end
              if name == nil then goto continue end
              alert_parameters.alert_message = alert_parameters.alert_message:gsub(vg, type .. "=" .. name) -- replace variable with value from settings
              ::continue::
            end
          end
          e.alert_parameters = alert_parameters
        end
      end
    end
  end
end

function mgr.applyTrainVariables(settings, entities)
  for _, e in ipairs(entities) do
    if e.valid and e.train then
      local trainSchedule = e.train.schedule
      for recordKey, record in ipairs(trainSchedule.records) do
        -- schedule station name
        for w in record.station:gmatch("%[.-%]") do
          local vg, vv = w:match(newDoubleMatch)
          if vg and vv then
            if settings[vv] then
              vg = vg:gsub("%-", "%%-") -- escape the replament text
              local name = settings[vv].name
              local type = settings[vv].type
              if type == "virtual" then type = "virtual-signal" end
              if name == nil then goto continue end
              trainSchedule.records[recordKey].station = record.station:gsub(vg, type .. "=" .. name) -- replace variable with value from settings
              ::continue::
            end
          end
        end

        -- schedule wait conditions
        for waitConditionKey, waitCondition in pairs(record.wait_conditions) do
          if waitCondition.type == 'item_count' or waitCondition.type == 'fluid_count' or waitCondition.type == 'circuit' then
            if waitCondition.condition.first_signal then
              if settings[waitCondition.condition.first_signal.name] then
                waitCondition.condition.first_signal.type = settings[waitCondition.condition.first_signal.name].type
                waitCondition.condition.first_signal.name = settings[waitCondition.condition.first_signal.name].name
              end
            end
            if waitCondition.condition.second_signal then
              if settings[waitCondition.condition.second_signal.name] then
                waitCondition.condition.second_signal.type = settings[waitCondition.condition.second_signal.name].type
                waitCondition.condition.second_signal.name = settings[waitCondition.condition.second_signal.name].name
              end
            end
          end
        end
      end
      e.train.schedule = trainSchedule
    end

    if e.valid and e.type == 'entity-ghost' then
      local tags = e.tags
      if not tags then tags = {} end
      if not tags.bvsettings then tags.bvsettings = {} end
      
      tags.bvsettings = settings

      e.tags = tags
    end
  end
end

function mgr.applyInventoryFilterVariables(settings, entities)
  for _, e in pairs(entities) do
    if e.valid and e.type ~= 'entity-ghost' then
      for i = 1,e.get_max_inventory_index(),1 do
        local inv = e.get_inventory(i)
        if inv and inv.supports_filters() and inv.is_filtered() then
          for n = 1, #inv, 1 do
            local variable = inv.get_filter(n)
            if variable and settings[variable] then
              inv.set_filter(n, settings[variable].name)
            end
          end
        end
      end
    elseif e.valid and e.type == 'entity-ghost' then
      local tags = e.tags
      if not tags then tags = {} end
      if not tags.bvsettings then tags.bvsettings = {} end
      
      tags.bvsettings = settings

      e.tags = tags
    end
  end
end

return mgr
