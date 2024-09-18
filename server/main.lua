local maxPlateLength = Config.PlateLength

function validatePlateLength(plate)
    if #plate > maxPlateLength then
        return false, _U('plate_length_exceeded')
    end
    return true
end

local function generateRandomPlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local plate = ''
    for _ = 1, Config.PlateLength do
        local rand = math.random(1, #chars)
        plate = plate .. chars:sub(rand, rand)
    end
    return plate
end

ESX.RegisterCommand('givecar', Config.AdminGroups, function(xPlayer, args, showError)
    local targetPlayer = ESX.GetPlayerFromId(args.playerId)
    local vehicleModel = args.model
    local plate = args.plate or generateRandomPlate()

    if not targetPlayer then
        return showError(_U('player_not_found'))
    end

    if not vehicleModel or vehicleModel == '' then
        return showError(_U('invalid_vehicle_model'))
    end

    local isValid, errorMsg = validatePlateLength(plate)
    if not isValid then
        return showError(errorMsg)
    end

    local playerPed = GetPlayerPed(targetPlayer.source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if not vehicle then
        return showError(_U('not_in_vehicle'))
    end

    local vehicleProps = {
        model = GetHashKey(vehicleModel),
        plate = plate
    }

    local existingVehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})

    if existingVehicle[1] then
        MySQL.update.await('UPDATE owned_vehicles SET model = ?, owner = ?, vehicle = ? WHERE plate = ?', {
            vehicleModel,
            targetPlayer.getIdentifier(),
            json.encode(vehicleProps),
            plate
        })
    else
        MySQL.insert.await('INSERT INTO owned_vehicles (model, owner, plate, vehicle, type) VALUES (?, ?, ?, ?, ?)', {
            vehicleModel,
            targetPlayer.getIdentifier(),
            plate,
            json.encode(vehicleProps),
            'car'
        })
    end

    xPlayer.showNotification(_U('givecar_success', args.playerId))
    targetPlayer.showNotification(_U('receive_car', vehicleModel, plate))
end, true, {help = _U('givecar'), arguments = {
    {name = 'playerId', help = _U('player_id'), type = 'number'},
    {name = 'model', help = _U('vehicle_model'), type = 'string'},
    {name = 'plate', help = _U('plate'), type = 'string', optional = true}
}})

ESX.RegisterCommand('savecar', 'user', function(xPlayer)
    local playerPed = GetPlayerPed(xPlayer.source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not vehicle then
        return xPlayer.showNotification(_U('not_in_vehicle'))
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

    MySQL.insert.await('INSERT INTO owned_vehicles (model, owner, plate, vehicle, type, state) VALUES (?, ?, ?, ?, ?, ?)', {
        vehicleProps.model,
        xPlayer.getIdentifier(),
        plate,
        json.encode(vehicleProps),
        'car',
        json.encode(vehicleProps.state or {})
    })

    xPlayer.showNotification(_U('savecar_success', plate))
end, false, {help = _U('save_command_car')})
