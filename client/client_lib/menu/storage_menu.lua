local QBCore = exports.af_core:GetCoreObject()

local function showStorage(storage_data)
    if not storage_data or not storage_data.metadata then return end
    local meta = storage_data.metadata
    local crude = meta.crudeOil or 0
    local gasoline = meta.gasoline or 0
    local octane = meta.avg_gas_octane or 87
    local fuelOil = meta.fuel_oil or 0

    local options = {
        {
            title = 'Crude Oil',
            description = ('Stock: %d Gallons\nClick to withdraw into barrels or tanker truck'):format(crude),
            icon = 'oil-can',
            onSelect = function()
                TriggerEvent('keep-oilrig:storage_menu:StorageWithdraw', { type = 'crudeOil', storage_data = storage_data })
            end
        },
        {
            title = 'Refined Gasoline',
            description = ('Stock: %d Gallons (Octane: %s)\nClick to withdraw for gas station delivery'):format(gasoline, octane),
            icon = 'gas-pump',
            onSelect = function()
                TriggerEvent('keep-oilrig:storage_menu:StorageWithdraw', { type = 'gasoline', storage_data = storage_data })
            end
        },
        {
            title = 'Residual Fuel Oil',
            description = ('Stock: %d Gallons\nClick to withdraw into barrels or tanker truck'):format(fuelOil),
            icon = 'barrel',
            onSelect = function()
                TriggerEvent('keep-oilrig:storage_menu:StorageWithdraw', { type = 'fuel_oil', storage_data = storage_data })
            end
        }
    }

    lib.registerContext({
        id = 'oilwell_storage_main',
        title = storage_data.name or 'Company Oil Storage',
        options = options
    })
    lib.showContext('oilwell_storage_main')
end

local function showStorageWithdraw(data)
    local fuelType = data.type
    local currentStock = data.storage_data.metadata[fuelType] or 0

    lib.registerContext({
        id = 'oilwell_storage_withdraw',
        title = ('Withdraw: %s (Available: %d Gal)'):format(fuelType, currentStock),
        menu = 'oilwell_storage_main',
        options = {
            {
                title = 'Withdraw into Industrial Barrels',
                description = 'Container Capacity: 5,000 Gal per barrel (Deposit: $500)',
                icon = 'bottle-droplet',
                onSelect = function()
                    local input = lib.inputDialog(('Withdraw %s into Barrels'):format(fuelType), {
                        { type = 'number', label = 'Gallons to withdraw', min = 1, max = currentStock, required = true }
                    })
                    if input and input[1] and tonumber(input[1]) > 0 then
                        QBCore.Functions.TriggerCallback('keep-oilrig:server:Withdraw', function(res)
                            if res then
                                lib.notify({ type = 'success', description = 'Barrels prepared in withdraw stash!' })
                            end
                        end, {
                            citizenid = data.storage_data.citizenid,
                            type = fuelType,
                            truck = false,
                            amount = tonumber(input[1])
                        })
                    end
                end
            },
            {
                title = 'Dispatch Transport Tanker Truck',
                description = 'Capacity: 100,000 Gal hauler (Deposit: $25,000)',
                icon = 'truck-droplet',
                onSelect = function()
                    local input = lib.inputDialog(('Load %s into Tanker Truck'):format(fuelType), {
                        { type = 'number', label = 'Gallons to load', min = 1, max = currentStock, required = true }
                    })
                    if input and input[1] and tonumber(input[1]) > 0 then
                        QBCore.Functions.TriggerCallback('keep-oilrig:server:Withdraw', function(res)
                            if res then
                                lib.notify({ type = 'info', description = 'Transport tanker queued for pickup at depot!' })
                            end
                        end, {
                            citizenid = data.storage_data.citizenid,
                            type = fuelType,
                            truck = true,
                            amount = tonumber(input[1])
                        })
                    end
                end
            }
        }
    })
    lib.showContext('oilwell_storage_withdraw')
end

local function MakeVehicle(model, Coord, TriggerLocation, DinstanceToTrigger, items)
    local plyped = PlayerPedId()
    local pedCoord = GetEntityCoords(plyped)
    local finished = false
    local distance = #(pedCoord - vector3(TriggerLocation.x, TriggerLocation.y, TriggerLocation.z))

    CreateThread(function()
        while distance > DinstanceToTrigger do
            local pCoord = GetEntityCoords(PlayerPedId())
            distance = #(pCoord - vector3(TriggerLocation.x, TriggerLocation.y, TriggerLocation.z))
            Wait(1000)
        end
        finished = true
    end)

    while not finished do
        DrawMarker(2, TriggerLocation.x, TriggerLocation.y, TriggerLocation.z + 2.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
        Wait(0)
    end

    local vehiclePlate = "SWK" .. math.random(100, 999)
    local modelHash = type(model) == "string" and GetHashKey(model) or model
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local veh = CreateVehicle(modelHash, Coord.x, Coord.y, Coord.z, Coord.w, true, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, "OFF")
    SetVehicleNumberPlateText(veh, vehiclePlate)

    if GetResourceState('af_fuel') == 'started' then
        exports.af_fuel:SetFuel(veh, math.random(80, 90))
    end
    SetVehicleEngineOn(veh, true, true)

    TriggerEvent("vehiclekeys:client:SetOwner", vehiclePlate)
    if GetResourceState('af_vehiclekeys') == 'started' then
        pcall(function() exports.af_vehiclekeys:GiveKeys(vehiclePlate) end)
    end

    SetModelAsNoLongerNeeded(modelHash)
    Targets.qb_target.truck(vehiclePlate, veh)

    TriggerServerEvent('keep-oilwell:server_lib:update_vehicle', vehiclePlate, items)
    lib.notify({ type = 'success', description = ('Tanker truck spawned with plate %s!'):format(vehiclePlate) })
end

RegisterNetEvent('keep-oilrig:client_lib:withdraw_from_queue', function(data)
    QBCore.Functions.TriggerCallback('keep-oilrig:server:withdraw_from_queue', function(result)
        if not result or result == false then return end
        if not result.truck then return end

        local SpawnLocation = Oilwell_config.Delivery.SpawnLocation
        local TriggerLocation = Oilwell_config.Delivery.TriggerLocation
        local DinstanceToTrigger = Oilwell_config.Delivery.DinstanceToTrigger
        local model = Oilwell_config.Delivery.vehicleModel

        MakeVehicle(model, SpawnLocation, TriggerLocation, DinstanceToTrigger, result)
    end, data and data.truck)
end)

AddEventHandler('keep-oilrig:storage_menu:ShowStorage', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:getStorageData', function(result)
        showStorage(result)
    end)
end)

AddEventHandler('keep-oilrig:storage_menu:StorageWithdraw', function(data)
    showStorageWithdraw(data)
end)

AddEventHandler("keep-oilwell:client:openWithdrawStash", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.citizenid then return end
    exports.af_inventory:openInventory('stash', 'Withdraw_' .. PlayerData.citizenid)
end)

AddEventHandler('keep-oilwell:client:open_purge_menu', function()
    local alert = lib.alertDialog({
        header = 'Purge Withdraw Stash',
        content = 'Are you sure you want to completely empty and purge your withdraw stash? Any unclaimed barrels will be deleted!',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('keep-oilwell:server:purgeWithdrawStash')
        lib.notify({ type = 'info', description = 'Withdraw stash purged.' })
    end
end)
