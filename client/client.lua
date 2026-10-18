local QBCore = exports.af_core:GetCoreObject()

PlayerJob = {}
OnDuty = nil
OBJECT = nil
local rigmodel = `p_oil_pjack_03_s`

function CheckJob()
     return (PlayerJob.name == 'oilwell')
end

function CheckOnduty()
     return (PlayerJob.name == 'oilwell' and PlayerJob.onduty)
end

-- class
OilRigs = {
     dynamicSpawner_state = false,
     data_table = {}, -- this table holds oilwells data and defined by server
     core_entities = {} -- this table holds objects that has some functions to them and filled by dynamic spawner
}

function OilRigs:add(s_res, id)
     if self.data_table[id] ~= nil then
          return
     end
     self.data_table[id] = {}
     self.data_table[id] = s_res
     if self.data_table[id].isOwner == true then
          local blip_settings = Oilwell_config.Settings.oil_well.blip
          blip_settings.type = 'oil_well'
          blip_settings.id = id
          self.data_table[id].blip_handle = createCustom(self.data_table[id].position.coord, blip_settings)
     end
end

function OilRigs:update(s_res, id)
     if self.data_table[id] == nil then return end
     s_res.entity = self.data_table[id].entity
     s_res.Qbtarget = self.data_table[id].Qbtarget
     self.data_table[id] = s_res
     QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(metadata)
          self:syncSpeed(self.data_table[id].entity, metadata.speed)
     end, self.data_table[id].oilrig_hash)
end

function OilRigs:startUpdate(cb)
     QBCore.Functions.TriggerCallback('keep-oilrig:server:getNetIDs', function(result)
          for key, value in pairs(result) do
               self:update(value, key)
               Wait(15)
          end
          cb(true)
     end)
end

function OilRigs:syncSpeed(entity, speed)
     local anim_speed = Round((speed / Oilwell_config.AnimationSpeedDivider), 2)
     SetEntityAnimSpeed(entity, 'p_v_lev_des_skin', 'p_oil_pjack_03_s', anim_speed + .0)
end

function OilRigs:getById(id)
     for key, value in pairs(self.data_table) do
          if value.id == id then
               return value
          end
     end
     return false
end

function OilRigs:getByEntityHandle(handle)
     for key, value in pairs(self.data_table) do
          if value.entity == handle then
               return value
          end
     end
     return false
end

function OilRigs:readAll()
     return self.data_table
end

function OilRigs:DynamicSpawner()
     self.dynamicSpawner_state = true
     local object_spawn_distance = 125.0

     CreateThread(function()
          -- create core blips
          Wait(50)
          for index, value in pairs(Oilwell_config.locations) do
               value.blip.type = index
               if not value.blip.handle and PlayerJob.name == 'oilwell' then
                    value.blip.handle = createCustom(value.position, value.blip)
               end
               if not value.qbtarget then
                    Add_3rd_eye(value.position, index)
                    value.qbtarget = true
               end
          end

          for _, oilwell in pairs(self.data_table) do
               if not oilwell.qbtarget then
                    local c = oilwell.position.coord
                    local coord = vector3(c.x, c.y, c.z)
                    createOwnerQbTarget(oilwell.oilrig_hash, coord)
                    oilwell.qbtarget = true
               end
          end

          while self.dynamicSpawner_state do
               local pedCoord = cache.coords or GetEntityCoords(cache.ped)
               -- oilwells/pumps
               for index, value in pairs(self.data_table) do
                    local c = value.position.coord
                    c = vector3(c.x, c.y, c.z)
                    local distance = #(c - pedCoord)
                    if distance < object_spawn_distance and self.data_table[index].entity == nil then
                         self.data_table[index].entity = spawnObjects(rigmodel, self.data_table[index].position)
                         QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(metadata)
                              self:syncSpeed(self.data_table[index].entity, metadata.speed)
                         end, self.data_table[index].oilrig_hash)
                    elseif distance > object_spawn_distance and self.data_table[index].entity ~= nil then
                         DeleteEntity(self.data_table[index].entity)
                         self.data_table[index].entity = nil
                    end
               end

               for index, value in pairs(Oilwell_config.locations) do
                    local position = vector3(value.position.x, value.position.y, value.position.z)
                    local distance = #(position - pedCoord)
                    if self.core_entities[index] == nil then
                         self.core_entities[index] = {}
                    end
                    if distance < object_spawn_distance and self.core_entities[index].entity == nil then
                         self.core_entities[index].entity = spawnObjects(value.model, {
                              coord = { x = position.x, y = position.y, z = position.z, },
                              rotation = { x = value.rotation.x, y = value.rotation.y, z = value.rotation.z, }
                         })
                    elseif distance > object_spawn_distance and self.core_entities[index].entity ~= nil then
                         DeleteEntity(self.core_entities[index].entity)
                         self.core_entities[index].entity = nil
                    end
               end
               Wait(1250)
          end
     end)
end

function OilRigs:Flush_Entities()
     for _, oilwell in pairs(self.data_table) do
          if oilwell.entity then
               DeleteObject(oilwell.entity)
          end
          RemoveBlip(oilwell.blip_handle)
     end
     self.dynamicSpawner_state = false
     Wait(5)
     self.data_table = {}
end

--
RegisterNetEvent('keep-oilrig:client:changeRigSpeed', function(data)
     local entity = data and data.entity
     if not entity then return end
     if not CheckJob() then
          lib.notify({ type = 'error', description = 'You are not hired by the oil company.' })
          return false
     end
     if not CheckOnduty() then
          lib.notify({ type = 'error', description = 'You must be on duty!' })
          return false
     end
     local rig = OilRigs:getByEntityHandle(entity)
     if not rig then
          return print('oilwell not found')
     end
     QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(metadata)
          OilRigs:startUpdate(function()
               local inputData = lib.inputDialog('Configure Pumpjack Speed', {
                    {
                         type = 'number',
                         label = 'Pump Speed (0-100 RPM)',
                         default = metadata and metadata.speed or 50,
                         min = 0,
                         max = 100,
                         required = true
                    }
               })
               if inputData and inputData[1] then
                    local speed = tonumber(inputData[1])
                    lib.notify({ type = 'success', description = ('Oilwell pump speed updated to %d RPM'):format(speed) })
                    TriggerServerEvent('keep-oilrig:server:updateSpeed', { speed = tostring(speed) }, rig.id)
               end
          end)
     end, rig.oilrig_hash)
end)

local function loadData()
     OilRigs:Flush_Entities()
     QBCore.Functions.GetPlayerData(function(PlayerData)
          PlayerJob = PlayerData.job
          OnDuty = PlayerData.job.onduty
          QBCore.Functions.TriggerCallback('keep-oilrig:server:getNetIDs', function(result)
               for key, value in pairs(result) do
                    OilRigs:add(value, key)
               end

               OilRigs:DynamicSpawner()
          end)
     end)
end

RegisterNetEvent('keep-oilrig:client:syncSpeed', function(id, speed)
     local rig = OilRigs:getById(id)
     if rig then
          OilRigs:syncSpeed(rig.entity, speed)
     end
end)

function spawnObjects(model, position)
     TriggerEvent('keep-oilrig:client:clearArea', position.coord)
     -- every oilwell exist only on client side!
     local entity = CreateObject(model, position.coord.x, position.coord.y, position.coord.z, 0, 0, 0)
     while not DoesEntityExist(entity) do Wait(10) end
     SetEntityRotation(entity, position.rotation.x, position.rotation.y, position.rotation.z, 0.0, true)
     FreezeEntityPosition(entity, true)
     SetEntityProofs(entity, 1, 1, 1, 1, 1, 1, 1, 1)
     return entity
end

-- --------------------------------------------------------------

RegisterNetEvent('keep-oilrig:client:spawn')
AddEventHandler('keep-oilrig:client:spawn', function()
     local coords = ChooseSpawnLocation()
     QBCore.Functions.TriggerCallback('keep-oilrig:server:createNewOilrig', function(NetId)
          if NetId ~= nil then
               local entity = NetworkGetEntityFromNetworkId(NetId)
               OBJECT = entity
               exports.af_target:addLocalEntity(entity, {
                    {
                         name = "oil-rig-assign-" .. entity,
                         icon = "fa-regular fa-file-lines",
                         label = "Assign to player",
                         canInteract = function(entity)
                              if not CheckJob() then return false end
                              if not (PlayerJob and PlayerJob.grade and PlayerJob.grade.level == 4) then return false end
                              if not CheckOnduty() then return false end
                              return true
                         end,
                         onSelect = function(data)
                              TriggerEvent('keep-oilrig:client:enterInformation', data)
                         end,
                         distance = 2.5
                    },
                    {
                         name = "oil-rig-adjust-" .. entity,
                         icon = "fa-regular fa-file-lines",
                         label = "Adjust position",
                         canInteract = function(entity)
                              if not CheckJob() then return false end
                              if not (PlayerJob and PlayerJob.grade and PlayerJob.grade.level == 4) then return false end
                              if not CheckOnduty() then return false end
                              return true
                         end,
                         onSelect = function(data)
                              TriggerEvent('keep-oilwell:menu:OPENMENU', data)
                         end,
                         distance = 2.5
                    }
               })
          end
     end, coords)
end)


RegisterNetEvent('keep-oilrig:client:enterInformation', function(data)
     local entity = data and data.entity
     if not entity then return end
     local inputData = lib.inputDialog('Assign & Register Oil Rig', {
          { type = 'input', label = 'Rig Name', required = true },
          { type = 'input', label = 'Owner Citizen ID', required = true }
     })
     if inputData and inputData[1] and inputData[2] then
          local netId = NetworkGetNetworkIdFromEntity(entity)
          local regData = {
               name = inputData[1],
               cid = inputData[2],
               netId = netId
          }
          QBCore.Functions.TriggerCallback('keep-oilrig:server:regiserOilrig', function(result)
               DeleteEntity(entity)
               if result == true then
                    Wait(1500)
                    lib.notify({ type = 'success', description = 'Registered oilwell to: ' .. regData.cid })
                    loadData()
               end
          end, regData)
     end
end)

RegisterNetEvent('keep-oilwell:client:force_reload', function()
     Wait(25)
     loadData()
end)

AddEventHandler('onResourceStart', function(resourceName)
     if (GetCurrentResourceName() ~= resourceName) then
          return
     end
     Wait(500)

     QBCore.Functions.GetPlayerData(function(PlayerData)
          PlayerJob = PlayerData.job
          OnDuty = PlayerData.job.onduty
          loadData()
     end)
     if StartBarellAnimation then
          StartBarellAnimation()
     end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
     Wait(3000)
     QBCore.Functions.GetPlayerData(function(PlayerData)
          PlayerJob = PlayerData.job
          OnDuty = PlayerData.job.onduty
          loadData()
     end)
     if StartBarellAnimation then
          StartBarellAnimation()
     end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
     OilRigs.dynamicSpawner_state = false
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
     PlayerJob = JobInfo
     OnDuty = PlayerJob.onduty
     loadData()
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
     OnDuty = duty
     loadData()
end)

RegisterNetEvent('keep-oilrig:client:local_mail_sender', function(data)
     local Lang = Oilwell_config.Locale
     Lang.mail.message = string.format(Lang.mail.message, data.gender, data.charinfo.lastname, data.money, data.amount,
          data.refund)
     TriggerServerEvent('qb-phone:server:sendNewMail', {
          sender = Lang.mail.sender,
          subject = Lang.mail.subject,
          message = Lang.mail.message,
          button = {}
     })
end)

RegisterNetEvent('keep-oilwell:server_lib:AddExplosion', function(bullding_type)
     local c = Oilwell_config.locations[bullding_type].position
     local t = 0
     for i = 1, 5, 1 do
          AddExplosion(c.x, c.y, c.z + 0.5, 9, 10.0, true, false, true)
          t = t + 1000
          Wait(t)
     end
end)
