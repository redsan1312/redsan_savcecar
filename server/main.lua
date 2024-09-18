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

local function isPlateTaken(plate, callback)
    MySQL.query('SELECT 1 FROM owned_vehicles WHERE plate = ?', {plate}, function(result)
        callback(#result > 0)
    end)
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

    plate = plate or generateRandomPlate()

    isPlateTaken(plate, function(plateTaken)
        if plateTaken then
            MySQL.update('UPDATE owned_vehicles SET model = ?, owner = ?, plate = ? WHERE plate = ?', {
                vehicleModel,
                targetPlayer.getIdentifier(),
                plate
            }, function(affectedRows)
                if affectedRows > 0 then
                    xPlayer.showNotification(_U('givecar_success', args.playerId))
                    targetPlayer.showNotification(_U('receive_car', vehicleModel, plate))
                else
                    showError(_U('vehicle_update_failed'))
                end
            end)
        else
            MySQL.insert('INSERT INTO owned_vehicles (model, owner, plate, vehicle, type) VALUES (?, ?, ?, ?, ?)', {
                vehicleModel,
                targetPlayer.getIdentifier(),
                plate,
                '{}',
                'car'
            }, function(insertId)
                if insertId then
                    xPlayer.showNotification(_U('givecar_success', args.playerId))
                    targetPlayer.showNotification(_U('receive_car', vehicleModel, plate))
                else
                    showError(_U('vehicle_insert_failed'))
                end
            end)
        end
    end)
end, true, {help = _U('givecar'), arguments = {
    {name = 'playerId', help = _U('player_id'), type = 'number'},
    {name = 'model', help = _U('vehicle_model'), type = 'string'},
    {name = 'plate', help = _U('plate'), type = 'string', optional = true}
}})

RegisterNetEvent('esx_giveownedcar:setVehicleProperties')
AddEventHandler('esx_giveownedcar:setVehicleProperties', function(vehicleProps, plate)
    MySQL.update('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {
        json.encode(vehicleProps),
        plate
    })
end)

ESX.RegisterCommand('savecar', 'user', function(xPlayer)
    local playerPed = GetPlayerPed(xPlayer.source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not vehicle then
        return xPlayer.showNotification(_U('not_in_vehicle'))
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local vehicleProps = {
        model = GetEntityModel(vehicle)wwwww,
        plate = plate,
        state = {}
    }

    MySQL.insert('INSERT INTO owned_vehicles (model, owner, plate, vehicle, type, state) VALUES (?, ?, ?, ?, ?, ?)', {
        vehicleProps.model,
        xPlayer.getIdentifier(),
        plate,
        json.encode(vehicleProps),
        'car',
        json.encode(vehicleProps.state or {})
    }, function(insertId)
        if insertId then
            xPlayer.showNotification(_U('savecar_success', plate))
        else
            xPlayer.showNotification(_U('savecar_failed'))
        end
    end)
end, false, {help = _U('save_command_car')})
