local QBCore = exports.af_core:GetCoreObject()

local function showCDU(data)
    if not data or not data.metadata then return end
    local isRunning = (data.metadata.state == true)
    local cduTemp = data.metadata.temp or 0
    local cduGal = data.metadata.oil_storage or 0

    lib.registerContext({
        id = 'oilwell_cdu_menu',
        title = ('Crude Distillation Unit [%s]'):format(isRunning and 'ACTIVE' or 'OFFLINE'),
        options = {
            {
                title = 'Operating Temperature',
                description = ('Current Temperature: %d °C'):format(cduTemp),
                icon = 'temperature-high',
                readOnly = true
            },
            {
                title = 'Crude Oil in CDU Tank',
                description = ('Current Volume: %d Gallons'):format(cduGal),
                icon = 'oil-can',
                readOnly = true
            },
            {
                title = 'Pump Crude Oil to CDU',
                description = 'Transfer crude oil from main storage into this CDU unit',
                icon = 'arrows-spin',
                onSelect = function()
                    local input = lib.inputDialog('Pump Crude Oil to CDU', {
                        { type = 'number', label = 'Amount (Gallons)', min = 1, required = true }
                    })
                    if input and input[1] and tonumber(input[1]) > 0 then
                        QBCore.Functions.TriggerCallback('keep-oilrig:server:pumpCrudeOil_to_CDU', function(result)
                            showCDU(result)
                        end, { amount = tonumber(input[1]) })
                    end
                end
            },
            {
                title = 'Set CDU Temperature',
                description = 'Adjust the distillation temperature (controls fraction boiling points)',
                icon = 'temperature-arrow-up',
                onSelect = function()
                    local input = lib.inputDialog('CDU Temperature Settings', {
                        { type = 'number', label = 'Target Temperature (°C)', default = cduTemp, min = 0, max = 600, required = true }
                    })
                    if input and input[1] then
                        QBCore.Functions.TriggerCallback('keep-oilrig:server:set_CDU_temp', function(result)
                            showCDU(result)
                        end, { temp = tonumber(input[1]) })
                    end
                end
            },
            {
                title = isRunning and 'Shut Down Distillation (Turn Off)' or 'Start Distillation (Turn On)',
                description = isRunning and 'Stop heating and boiling crude fractions' or 'Begin heating crude oil into refined fractions',
                icon = isRunning and 'circle-stop' or 'circle-play',
                colorScheme = isRunning and 'red' or 'green',
                onSelect = function()
                    QBCore.Functions.TriggerCallback('keep-oilrig:server:switchPower_of_CDU', function(result)
                        showCDU(result)
                    end)
                end
            }
        }
    })
    lib.showContext('oilwell_cdu_menu')
end

AddEventHandler('keep-oilrig:CDU_menu:ShowCDU', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:get_CDU_Data', function(result)
        showCDU(result)
    end)
end)

AddEventHandler('keep-oilrig:CDU_menu:switchPower_of_CDU', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:switchPower_of_CDU', function(result)
        showCDU(result)
    end)
end)

AddEventHandler('keep-oilrig:CDU_menu:set_CDU_temp', function()
    local input = lib.inputDialog('CDU Temperature', {
        { type = 'number', label = 'Temperature (°C)', min = 0, max = 600, required = true }
    })
    if input and input[1] then
        QBCore.Functions.TriggerCallback('keep-oilrig:server:set_CDU_temp', function(result)
            showCDU(result)
        end, { temp = tonumber(input[1]) })
    end
end)

AddEventHandler('keep-oilrig:CDU_menu:pumpCrudeOil_to_CDU', function()
    local input = lib.inputDialog('Pump Crude Oil to CDU', {
        { type = 'number', label = 'Amount (Gallons)', min = 1, required = true }
    })
    if input and input[1] and tonumber(input[1]) > 0 then
        QBCore.Functions.TriggerCallback('keep-oilrig:server:pumpCrudeOil_to_CDU', function(result)
            showCDU(result)
        end, { amount = tonumber(input[1]) })
    end
end)
