Targets = Targets or {}
Targets['qb_target'] = {}

function Targets.qb_target.storage(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 2.0)
    exports.af_target:addSphereZone({
        coords = tmp_coord,
        radius = 1.5,
        debug = false,
        options = {
            {
                name = name,
                icon = "fa-solid fa-arrows-spin",
                label = "View Storage",
                canInteract = function()
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        lib.notify({ type = 'error', description = 'You must be on duty!' })
                        return false
                    end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:storage_menu:ShowStorage")
                end
            }
        }
    })
end

function Targets.qb_target.distillation(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 1.1)
    exports.af_target:addSphereZone({
        coords = tmp_coord,
        radius = 1.8,
        debug = false,
        options = {
            {
                name = name,
                icon = "fa-solid fa-gear",
                label = "Open CDU panel",
                canInteract = function()
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        lib.notify({ type = 'error', description = 'You must be on duty!' })
                        return false
                    end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:CDU_menu:ShowCDU")
                end
            }
        }
    })
end

function Targets.qb_target.toggle_job(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 1.1)
    exports.af_target:addSphereZone({
        coords = tmp_coord,
        radius = 1.2,
        debug = false,
        options = {
            {
                name = name,
                icon = "fa-solid fa-boxes-packing",
                label = "Toggle Duty",
                canInteract = function()
                    return CheckJob()
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:client:goOnDuty")
                end
            }
        }
    })
end

function Targets.qb_target.barrel_withdraw(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 1.1)
    exports.af_target:addSphereZone({
        coords = tmp_coord,
        radius = 1.5,
        debug = false,
        options = {
            {
                name = name .. "_withdraw",
                icon = "fa-solid fa-boxes-packing",
                label = "Transfer withdraw to stash",
                canInteract = function()
                    if not CheckJob() or not CheckOnduty() then return false end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:client_lib:withdraw_from_queue", { truck = false })
                end
            },
            {
                name = name .. "_stash",
                icon = "fa-solid fa-boxes-packing",
                label = "Open Withdraw Stash",
                canInteract = function()
                    if not CheckJob() or not CheckOnduty() then return false end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilwell:client:openWithdrawStash")
                end
            },
            {
                name = name .. "_purge",
                icon = "fa-solid fa-trash-can",
                label = "Purge Withdraw Stash",
                canInteract = function()
                    if not CheckJob() or not CheckOnduty() then return false end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilwell:client:open_purge_menu")
                end
            }
        }
    })
end

function Targets.qb_target.blender(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 2.5)
    exports.af_target:addSphereZone({
        coords = tmp_coord,
        radius = 3.5,
        debug = false,
        options = {
            {
                name = name,
                icon = "fa-solid fa-gear",
                label = "Open blender panel",
                canInteract = function()
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        lib.notify({ type = 'error', description = 'You must be on duty!' })
                        return false
                    end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:blender_menu:ShowBlender")
                end
            }
        }
    })
end

function Targets.qb_target.crude_oil_transport(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 2.5)
    exports.af_target:addSphereZone({
        coords = tmp_coord,
        radius = 2.5,
        debug = false,
        options = {
            {
                name = name,
                icon = "fa-solid fa-ship",
                label = "Oil Export Terminal",
                canInteract = function()
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        lib.notify({ type = 'error', description = 'You must be on duty!' })
                        return false
                    end
                    return true
                end,
                onSelect = function()
                    TriggerEvent("keep-oilwell:menu:show_transport_menu")
                end
            }
        }
    })
end

function Targets.qb_target.oilwell(coords, name)
    local coord = vector3(coords.x, coords.y, coords.z + 2.5)
    exports.af_target:addSphereZone({
        coords = coord,
        radius = 3.5,
        debug = false,
        options = {
            {
                name = "oil_well_info_" .. name,
                icon = "fa-solid fa-info",
                label = "View Pump Info",
                onSelect = function()
                    TriggerEvent("keep-oilrig:client:viewPumpInfo")
                end
            },
            {
                name = "oil_well_settings_" .. name,
                icon = "fa-solid fa-gauge-high",
                label = "Modify Pump Settings",
                canInteract = function(entity)
                    if not CheckJob() or not CheckOnduty() then return false end
                    return isOwner(entity)
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:client:changeRigSpeed")
                end
            },
            {
                name = "oil_well_parts_" .. name,
                icon = "fa-solid fa-gears",
                label = "Manage Parts",
                canInteract = function(entity)
                    if not CheckJob() or not CheckOnduty() then return false end
                    return isOwner(entity)
                end,
                onSelect = function()
                    TriggerEvent("keep-oilrig:client:show_oilwell_stash")
                end
            },
            {
                name = "oil_well_remove_" .. name,
                icon = "fa-regular fa-file-lines",
                label = "Remove Oilwell",
                canInteract = function(entity)
                    if not CheckJob() or not CheckOnduty() then return false end
                    return PlayerJob and PlayerJob.grade and PlayerJob.grade.level >= 4
                end,
                onSelect = function()
                    TriggerEvent("keep-oilwell:client:remove_oilwell")
                end
            }
        }
    })
end

function Targets.qb_target.truck(plate, truck)
    if not DoesEntityExist(truck) then return end
    exports.af_target:addLocalEntity(truck, {
        {
            name = "cargo_truck_" .. tostring(plate),
            icon = "fa-solid fa-boxes-packing",
            label = "Open Tanker Cargo",
            onSelect = function()
                exports.af_inventory:openInventory('trunk', {
                    netid = NetworkGetNetworkIdFromEntity(truck),
                    entity = truck
                })
            end
        },
        {
            name = "refund_truck_" .. tostring(plate),
            icon = "fa-solid fa-location-arrow",
            label = "Refund Truck",
            onSelect = function()
                TriggerEvent("keep-oilwell:client:refund_truck", {
                    entity = truck,
                    vehiclePlate = plate
                })
            end
        }
    })
end
