local QBCore = exports.af_core:GetCoreObject()

local function showblender(data)
    if not data or not data.metadata then return end
    local isRunning = (data.metadata.state == true)
    local stateTitle = isRunning and 'ACTIVE' or 'OFFLINE'

    local heavy_naphtha = data.metadata.heavy_naphtha or 0
    local light_naphtha = data.metadata.light_naphtha or 0
    local other_gases = data.metadata.other_gases or 0
    local diesel = data.metadata.diesel or 0
    local kerosene = data.metadata.kerosene or 0
    local fuel_oil = data.metadata.fuel_oil or 0

    local options = {
        {
            title = 'Heavy Naphtha',
            description = ('Stock: %d Gallons'):format(heavy_naphtha),
            icon = 'flask',
            readOnly = true
        },
        {
            title = 'Light Naphtha',
            description = ('Stock: %d Gallons'):format(light_naphtha),
            icon = 'flask-vial',
            readOnly = true
        },
        {
            title = 'Petroleum Gases',
            description = ('Stock: %d Gallons'):format(other_gases),
            icon = 'fire-flame-simple',
            readOnly = true
        },
        {
            title = 'Diesel Fraction',
            description = ('Stock: %d Gallons'):format(diesel),
            icon = 'oil-can',
            readOnly = true
        },
        {
            title = 'Kerosene Fraction',
            description = ('Stock: %d Gallons'):format(kerosene),
            icon = 'droplet',
            readOnly = true
        },
        {
            title = 'Fuel Oil Fraction',
            description = ('Stock: %d Gallons (Bypass stock)'):format(fuel_oil),
            icon = 'barrel',
            readOnly = true
        },
        {
            title = 'Set Blending Recipe',
            description = 'Configure the ratio percentages of hydrocarbons for finished fuel',
            icon = 'scroll',
            onSelect = function()
                local input = lib.inputDialog('Fuel Blending Recipe Ratios (%)', {
                    { type = 'number', label = 'Heavy Naphtha (0-100%)', min = 0, max = 100, default = 25, required = true },
                    { type = 'number', label = 'Light Naphtha (0-100%)', min = 0, max = 100, default = 35, required = true },
                    { type = 'number', label = 'Petroleum Gases (0-100%)', min = 0, max = 100, default = 10, required = true },
                    { type = 'number', label = 'Diesel (0-100%)', min = 0, max = 100, default = 15, required = true },
                    { type = 'number', label = 'Kerosene (0-100%)', min = 0, max = 100, default = 15, required = true },
                })
                if input then
                    local recipeData = {
                        heavy_naphtha = input[1],
                        light_naphtha = input[2],
                        other_gases = input[3],
                        diesel = input[4],
                        kerosene = input[5]
                    }
                    QBCore.Functions.TriggerCallback('keep-oilrig:server:recipe_blender', function(result)
                        showblender(result)
                    end, recipeData)
                end
            end
        },
        {
            title = isRunning and 'Halt Blending (Stop)' or 'Initiate Blending (Start)',
            description = isRunning and 'Stop the blending process' or 'Begin combining hydrocarbon fractions into refined fuel',
            icon = isRunning and 'circle-stop' or 'circle-play',
            colorScheme = isRunning and 'red' or 'green',
            onSelect = function()
                QBCore.Functions.TriggerCallback('keep-oilrig:server:toggle_blender', function(result)
                    showblender(result)
                end)
            end
        },
        {
            title = 'Pump Fuel-Oil to Storage',
            description = 'Transfer heavy residual fuel-oil from blender to main storage',
            icon = 'arrows-spin',
            onSelect = function()
                QBCore.Functions.TriggerCallback('keep-oilrig:server:pump_fueloil', function(result)
                    showblender(result)
                end)
            end
        }
    }

    lib.registerContext({
        id = 'oilwell_blender_menu',
        title = ('Fuel Blending Unit [%s]'):format(stateTitle),
        options = options
    })
    lib.showContext('oilwell_blender_menu')
end

AddEventHandler('keep-oilrig:blender_menu:pump_fueloil', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:pump_fueloil', function(result)
        showblender(result)
    end)
end)

AddEventHandler('keep-oilrig:blender_menu:ShowBlender', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:ShowBlender', function(result)
        showblender(result)
    end)
end)

AddEventHandler('keep-oilrig:blender_menu:toggle_blender', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:toggle_blender', function(result)
        showblender(result)
    end)
end)
