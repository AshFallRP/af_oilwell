local QBCore = exports.af_core:GetCoreObject()

local function disableCombat()
    DisablePlayerFiring(PlayerId(), true)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(1, 37, true)
    DisableControlAction(0, 47, true)
    DisableControlAction(0, 58, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 143, true)
    DisableControlAction(0, 263, true)
    DisableControlAction(0, 264, true)
    DisableControlAction(0, 257, true)
end

local function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function LoadPropDict(model)
    local hash = GetHashKey(model)
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(10)
    end
end

local active_prop = nil
local function AttachProp(model, bone, x, y, z, rot1, rot2, rot3)
    local playerped = PlayerPedId()
    local model_hash = GetHashKey(model)
    local playercoord = GetEntityCoords(playerped)
    local bone_index = GetPedBoneIndex(playerped, bone)
    local _x, _y, _z = table.unpack(playercoord)

    if not HasModelLoaded(model) then
        LoadPropDict(model)
    end

    active_prop = CreateObject(model_hash, _x, _y, _z + 0.2, true, true, true)
    AttachEntityToEntity(active_prop, playerped, bone_index, x, y, z, rot1, rot2, rot3, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
end

local function start_barell_animation()
    local playerped = PlayerPedId()
    local dict = 'anim@heists@box_carry@'
    local anim = 'idle'
    local PropName = 'prop_barrel_exp_01a'
    local PropBone = 60309

    LoadAnim(dict)
    ClearPedTasks(playerped)
    RemoveAnimDict(dict)
    Wait(250)
    AttachProp(PropName, PropBone, 0.0, 0.41, 0.3, 130.0, 290.0, 0.0)

    CreateThread(function()
        while active_prop do
            local not_animation = IsEntityPlayingAnim(playerped, dict, anim, 3)
            if not_animation ~= 1 then
                TaskPlayAnim(playerped, dict, anim, 2.0, 2.0, -1, 51, 0, false, false, false)
                DisableControlAction(0, 22, true)
            end
            Wait(1500)
        end
    end)

    CreateThread(function()
        while active_prop do
            disableCombat()
            Wait(1)
        end
    end)
end

local function end_barell_animaiton()
    local playerped = PlayerPedId()
    local dict = 'anim@heists@box_carry@'
    local anim = 'idle'

    if active_prop then
        DeleteObject(active_prop)
        active_prop = nil
    end
    StopAnimTask(playerped, dict, anim, 1.0)
end

local function show_transport_menu()
    lib.registerContext({
        id = 'oilwell_transport_menu',
        title = 'Wholesale Oil Transport & Logistics',
        options = {
            {
                title = 'Check Harbor Export Rates & Quota',
                description = 'Inspect current municipal export rates for crude oil and refined products',
                icon = 'hand-holding-dollar',
                onSelect = function()
                    TriggerServerEvent('keep-oilrig:server:oil_transport:checkPrice')
                end
            },
            {
                title = 'Sell Barrels to Harbor Terminal',
                description = 'Offload crude or fuel oil barrels at the municipal port',
                icon = 'ship',
                onSelect = function()
                    local input = lib.inputDialog('Sell Oil Barrels to Harbor', {
                        { type = 'number', label = 'Number of Barrels to Sell', min = 1, required = true }
                    })
                    if input and input[1] and tonumber(input[1]) > 0 then
                        local amount = math.floor(tonumber(input[1]))
                        if lib.progressBar({
                            duration = (Oilwell_config.Transport.duration or 5) * 1000,
                            label = 'Offloading Barrels to Cargo Well...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = { move = true, car = true, combat = true }
                        }) then
                            QBCore.Functions.TriggerCallback('keep-oilrig:server:oil_transport:fillTransportWell', function(res)
                            end, amount)
                        end
                    end
                end
            },
            {
                title = 'Deliver Wholesale Fuel to Gas Stations',
                description = 'Transport refined gasoline to privately owned or State gas stations for top profit margins',
                icon = 'gas-pump',
                onSelect = function()
                    if GetResourceState('af_fuel') == 'started' then
                        local stations = exports.af_fuel:GetStations()
                        if stations and next(stations) then
                            local stationOptions = {}
                            for sid, sdata in pairs(stations) do
                                local sName = sdata.name or "Gas Station"
                                local sMode = sdata.supply_mode == 'state' and 'State-Controlled' or 'Self-Stocked'
                                local stockInfo = ('Stock: %d / %d L'):format(sdata.stock or 0, sdata.capacity or 2000)
                                table.insert(stationOptions, {
                                    title = ('%s (%s)'):format(sName, sMode),
                                    description = stockInfo .. '\nClick to set GPS waypoint to delivery drop-off point',
                                    icon = 'location-dot',
                                    onSelect = function()
                                        -- Find delivery coords
                                        local Settings = lib.load('shared.settings')
                                        if Settings and Settings.Stations then
                                            for _, st in ipairs(Settings.Stations) do
                                                local coords = st.blip
                                                local genId = string.format("station_%.2f_%.2f", coords.x, coords.y)
                                                if genId == sid then
                                                    local targetPos = st.delivery or st.blip
                                                    SetNewWaypoint(targetPos.x, targetPos.y)
                                                    lib.notify({ type = 'info', description = ('GPS Waypoint marked for %s delivery point!'):format(sName) })
                                                    return
                                                end
                                            end
                                        end
                                    end
                                })
                            end

                            lib.registerContext({
                                id = 'oilwell_stations_list',
                                title = 'Select Gas Station Delivery',
                                menu = 'oilwell_transport_menu',
                                options = stationOptions
                            })
                            lib.showContext('oilwell_stations_list')
                        else
                            lib.notify({ type = 'info', description = 'No registered stations found.' })
                        end
                    else
                        lib.notify({ type = 'error', description = 'Fuel resource not started.' })
                    end
                end
            }
        }
    })
    lib.showContext('oilwell_transport_menu')
end

AddEventHandler('keep-oilwell:menu:show_transport_menu', function()
    show_transport_menu()
end)

AddEventHandler('keep-oilwell:menu:show_transport_menu:ask_stock_price', function()
    TriggerServerEvent('keep-oilrig:server:oil_transport:checkPrice')
end)
