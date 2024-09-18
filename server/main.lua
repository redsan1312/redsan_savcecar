Locales = {}

local function loadLocale(locale)
    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.lua')
    if file then
        local fn, err = load(file)
        if fn then
            fn()
        else
            print("Błąd ładowania pliku językowych: " .. err)
        end
    else
        print("Nie znaleziono pliku języka: " .. locale)
    end
end

loadLocale(Config.Locale)

function _U(key, ...)
    local locale = Config.Locale
    return string.format(Locales[locale][key] or key, ...)
end

local maxPlateLength = Config.PlateLength

function validatePlateLength(plate)
    if #plate > maxPlateLength then
        return false, _U('plate_length_exceeded')
    end
    return true
end

function getVehicleModifications(vehicle)
    local modifications = {}
    
    for i = 0, 50 do
        local mod = GetVehicleMod(vehicle, i)
        if mod and mod > -1 then
            table.insert(modifications, {modType = i, modId = mod})
        end
    end
    
    return modifications
end

function getVehicleState(vehicle)
    local state = {}
    state.fuelLevel = GetVehicleFuelLevel(vehicle)
    state.engineHealth = GetVehicleEngineHealth(vehicle)
    state.bodyHealth = GetVehicleBodyHealth(vehicle)
    state.tireHealth = {}
    
    for i = 0, 5 do
        state.tireHealth[i] = GetVehicleWheelHealth(vehicle, i)
    end
    
    return state
end

ESX.RegisterCommand('givecar', Config.AdminGroups, function(xPlayer, args, showError)
    local targetPlayer = ESX.GetPlayerFromId(args.playerId)
    local vehicleModel = args.model
    local plate = args.plate

    local isValid, errorMsg = validatePlateLength(plate)
    if not isValid then
        showError(errorMsg)
        return
    end

    if targetPlayer then
        local playerIdentifier = targetPlayer.getIdentifier()
        local existingVehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})
        
        local vehicleData = {
            model = vehicleModel,
            plate = plate,
            modifications = getVehicleModifications(GetVehiclePedIsIn(GetPlayerPed(targetPlayer.source), false)),
            state = getVehicleState(GetVehiclePedIsIn(GetPlayerPed(targetPlayer.source), false)))
        }

        if existingVehicle[1] then
            MySQL.update.await('UPDATE owned_vehicles SET model = ?, owner = ?, vehicle = ? WHERE plate = ?', {
                vehicleModel,
                playerIdentifier,
                json.encode(vehicleData),
                plate
            })
        else
            MySQL.insert.await('INSERT INTO owned_vehicles (model, owner, plate, vehicle, type) VALUES (?, ?, ?, ?, ?)', {
                vehicleModel,
                playerIdentifier,
                plate,
                json.encode(vehicleData),
                'car'
            })
        end

        xPlayer.showNotification(_U('givecar_success', args.playerId))
        targetPlayer.showNotification(_U('receive_car', vehicleModel, plate))
    else
        showError(_U('player_not_found'))
    end
end, true, {help = _U('givecar'), arguments = {
    {name = 'playerId', help = _U('player_id'), type = 'number'},
    {name = 'model', help = _U('vehicle_model'), type = 'string'},
    {name = 'plate', help = _U('plate'), type = 'string'}
}})

ESX.RegisterCommand('savecar', 'user', function(xPlayer)
    local playerPed = GetPlayerPed(xPlayer.source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle then
        local plate = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)
        
        local modifications = getVehicleModifications(vehicle)
        local vehicleState = getVehicleState(vehicle)
        
        local vehicleData = {
            model = model,
            plate = plate,
            modifications = modifications,
            state = vehicleState
        }

        MySQL.insert.await('INSERT INTO owned_vehicles (model, owner, plate, vehicle, type, state) VALUES (?, ?, ?, ?, ?, ?)', {
            model,
            xPlayer.getIdentifier(),
            plate,
            json.encode(vehicleData),
            'car',
            json.encode(vehicleState)
        })

        xPlayer.showNotification(_U('savecar_success', plate))
    else
        xPlayer.showNotification(_U('not_in_vehicle'))
    end
end, false, {help = _U('save_command_car')})
