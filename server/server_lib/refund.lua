local QBCore = exports.af_core:GetCoreObject()
local vehicles = {}

RegisterNetEvent('keep-oilwell:server_lib:update_vehicle', function(vehiclePlate, items)
     local src = source
     if not vehicles[src] then
          vehicles[src] = {}
     end
     vehicles[src][vehiclePlate] = vehiclePlate

     CreateThread(function()
          Wait(500)
          local trunkId = 'trunk' .. string.strtrim(vehiclePlate)
          if type(items) == 'table' then
               for _, item in ipairs(items) do
                    if item and item.name then
                         local metadata = item.info or item.metadata or {}
                         if not metadata.description and metadata.gal and metadata.type then
                              metadata.description = string.format('Type: %s | %d Gal | Octane: %d', metadata.type, metadata.gal, metadata.avg_gas_octane or 0)
                         end
                         exports.af_inventory:AddItem(trunkId, item.name, item.amount or 1, metadata)
                    end
               end
          end
     end)
end)

QBCore.Functions.CreateCallback('keep-oilwell:server:refund_truck', function(source, cb, vehiclePlate)
     if vehicles[source] then
          if vehicles[source][vehiclePlate] then
               local player = QBCore.Functions.GetPlayer(source)
               player.Functions.AddMoney('bank', Oilwell_config.Delivery.refund, 'oil_barells')
               vehicles[source][vehiclePlate] = nil
               local trunkId = 'trunk' .. string.strtrim(vehiclePlate)
               pcall(function() exports.af_inventory:ClearInventory(trunkId) end)
               cb(true)
               return
          end
     end
     cb(false)
end)
