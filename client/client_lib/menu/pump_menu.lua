local QBCore = exports.af_core:GetCoreObject()

local function showInfo(data)
    if not data or not data.oilrig_hash then return end
    QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(selected_oilrig)
        if not selected_oilrig then return end
        local partInfo = selected_oilrig.part_info or {}
        local belt = partInfo.belt or 0
        local polish = partInfo.polish or 0
        local clutch = partInfo.clutch or 0
        local durationMin = math.floor((selected_oilrig.duration or 0) / 60)
        local oilStorage = selected_oilrig.oil_storage or 0
        local speed = selected_oilrig.speed or 0
        local temp = selected_oilrig.temp or 0

        lib.registerContext({
            id = 'oilwell_pump_info_menu',
            title = ('Pumpjack Rig: %s'):format(data.name or "Oil Pump"),
            options = {
                {
                    title = 'Operating Speed',
                    description = ('Current Speed: %d RPM'):format(speed),
                    icon = 'gauge',
                    readOnly = true
                },
                {
                    title = 'Running Duration',
                    description = ('Uptime: %d Minutes'):format(durationMin),
                    icon = 'clock',
                    readOnly = true
                },
                {
                    title = 'Temperature',
                    description = ('Core Temp: %d °C'):format(temp),
                    icon = 'temperature-high',
                    readOnly = true
                },
                {
                    title = 'Extracted Crude Storage',
                    description = ('Buffer: %d Gallons'):format(oilStorage),
                    icon = 'oil-can',
                    readOnly = true
                },
                {
                    title = 'Mechanical Condition',
                    description = ('Belt: %d%% | Polish: %d%% | Clutch: %d%%'):format(belt, polish, clutch),
                    icon = 'screwdriver-wrench',
                    readOnly = true
                },
                {
                    title = 'Pump Oil to Main Storage',
                    description = 'Transfer all crude oil from pumpjack buffer into company crude storage',
                    icon = 'arrows-spin',
                    onSelect = function()
                        TriggerEvent('keep-oilrig:storage_menu:PumpOilToStorage', { oilrig_hash = data.oilrig_hash })
                    end
                },
                {
                    title = 'Manage Rig Crew & Employees',
                    description = 'Authorize coworkers and contractors to operate this oilwell',
                    icon = 'people-group',
                    onSelect = function()
                        TriggerEvent('keep-oilwell:menu:ManageEmployees', data.oilrig_hash)
                    end
                }
            }
        })
        lib.showContext('oilwell_pump_info_menu')
    end, data.oilrig_hash)
end

RegisterNetEvent('keep-oilwell:menu:ManageEmployees', function(oilrig_hash)
    QBCore.Functions.TriggerCallback('keep-oilwell:server:employees_list', function(result)
        if not result then return end
        local options = {
            {
                title = 'Hire New Worker',
                description = 'Add a worker by their Server ID (State ID)',
                icon = 'person-circle-plus',
                onSelect = function()
                    local input = lib.inputDialog('Hire Rig Worker', {
                        { type = 'number', label = 'Worker Server ID', min = 1, required = true }
                    })
                    if input and input[1] then
                        TriggerServerEvent('keep-oilwell:server:add_employee', oilrig_hash, tonumber(input[1]))
                    end
                end
            }
        }

        for index, employee in ipairs(result) do
            local charinfo = employee.charinfo or {}
            local name = (charinfo.firstname or "") .. " " .. (charinfo.lastname or "")
            local onlineStatus = employee.online and '🟢 Online' or '🔴 Offline'
            table.insert(options, {
                title = ('%s (%s)'):format(name, onlineStatus),
                description = ('Citizen ID: %s | Phone: %s\nClick to dismiss from crew'):format(employee.citizenid or 'N/A', charinfo.phone or 'N/A'),
                icon = 'user-tie',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Remove Rig Worker',
                        content = ('Are you sure you want to dismiss %s from this oil rig?'):format(name),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('keep-oilwell:server:remove_employee', oilrig_hash, employee.citizenid)
                    end
                end
            })
        end

        lib.registerContext({
            id = 'oilwell_crew_menu',
            title = 'Oil Rig Crew Management',
            options = options
        })
        lib.showContext('oilwell_crew_menu')
    end, oilrig_hash)
end)

local function show_oilwell_stash(data)
    if not data or not data.oilrig_hash then return end
    QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(selected_oilrig)
        if not selected_oilrig then return end
        local partInfo = selected_oilrig.part_info or {}
        local belt = partInfo.belt or 0
        local polish = partInfo.polish or 0
        local clutch = partInfo.clutch or 0

        lib.registerContext({
            id = 'oilwell_parts_menu',
            title = ('Rig Maintenance: %s'):format(data.name or "Oil Pump"),
            options = {
                {
                    title = 'Component Wear & Tear',
                    description = ('Belt: %d%% | Polish: %d%% | Clutch: %d%%'):format(belt, polish, clutch),
                    icon = 'gears',
                    readOnly = true
                },
                {
                    title = 'Open Maintenance Stash',
                    description = 'Store repair tools, replacement belts, chains, and spare parts',
                    icon = 'toolbox',
                    onSelect = function()
                        TriggerEvent('keep-oilwell:client:openOilPump', { oilrig_hash = data.oilrig_hash })
                    end
                },
                {
                    title = 'Repair & Service Rig',
                    description = 'Use required spare parts from maintenance stash or inventory to restore condition',
                    icon = 'screwdriver-wrench',
                    onSelect = function()
                        TriggerEvent('keep-oilwell:client:fix_oilwell', { oilrig_hash = data.oilrig_hash })
                    end
                }
            }
        })
        lib.showContext('oilwell_parts_menu')
    end, data.oilrig_hash)
end

-- Events
AddEventHandler('keep-oilrig:storage_menu:PumpOilToStorage', function(data)
    QBCore.Functions.TriggerCallback('keep-oilrig:server:PumpOilToStorageCallback', function(result)
        if result then
            lib.notify({ type = 'success', description = 'Crude oil transferred to storage!' })
        end
    end, data.oilrig_hash)
end)

AddEventHandler('keep-oilrig:client:viewPumpInfo', function(data)
    local entity = data and data.entity
    if not entity then return end
    OilRigs:startUpdate(function()
        showInfo(OilRigs:getByEntityHandle(entity))
    end)
end)

AddEventHandler('keep-oilrig:client:show_oilwell_stash', function(data)
    local entity = data and data.entity
    if not entity then return end
    OilRigs:startUpdate(function()
        show_oilwell_stash(OilRigs:getByEntityHandle(entity))
    end)
end)

-- Open oil pump stash via ox_inventory
RegisterNetEvent("keep-oilwell:client:openOilPump", function(data)
    if not data or not data.oilrig_hash then return end
    exports.af_inventory:openInventory('stash', 'oilPump_' .. data.oilrig_hash)
end)

AddEventHandler('keep-oilwell:client:fix_oilwell', function(data)
    if not data or not data.oilrig_hash then return end
    QBCore.Functions.TriggerCallback('keep-oilwell:server:fix_oil_well', function(result)
        if result then
            lib.notify({ type = 'success', description = 'Oilwell serviced and restored!' })
        else
            lib.notify({ type = 'error', description = 'Missing required replacement parts in stash or inventory.' })
        end
    end, data.oilrig_hash)
end)
