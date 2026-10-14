-- Edit Menu for adjusting entity rotation and placement during oilwell creation
AddEventHandler('keep-oilwell:menu:OPENMENU', function()
    if not OBJECT or not DoesEntityExist(OBJECT) then
        return lib.notify({ type = 'error', description = 'No active rig object to edit.' })
    end

    local rot = GetEntityRotation(OBJECT, 2)
    local input = lib.inputDialog('Oil Rig Placement Adjuster', {
        { type = 'number', label = 'Rotate X (Pitch)', default = math.floor(rot.x), min = -180, max = 180 },
        { type = 'number', label = 'Rotate Y (Roll)', default = math.floor(rot.y), min = -180, max = 180 },
        { type = 'number', label = 'Rotate Z (Heading)', default = math.floor(rot.z), min = -180, max = 180 },
    })

    if input then
        SetEntityRotation(OBJECT, input[1] + 0.0, input[2] + 0.0, input[3] + 0.0, 2, true)
        lib.notify({ type = 'info', description = 'Updated oil rig rotation.' })
    end
end)
