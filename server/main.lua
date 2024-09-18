Locales = {}

local function loadLocale(locale)
    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.lua')
    if file then
        local fn, err = load(file)
        if fn then
            fn()
        end
    end
end

loadLocale(Config.Locale)

function _U(key, ...)
    local locale = Config.Locale
    return string.format(Locales[locale][key] or key, ...)
end

ESX.RegisterCommand('givecar', Config.AdminGroups, function(xPlayer, args, showError)
    local targetPlayer = ESX.GetPlayerFromId(args.playerId)
    local vehicleModel = args.model
    local plate = args.plate

    if targetPlayer then
        local playerIdentifier = targetPlayer.getIdentifier()

        MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
            playerIdentifier,
            plate,
            json.encode({model = GetHashKey(vehicleModel), plate = plate})
        })

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

ESX.RegisterCommand('savecar', Config.AdminGroups, function(xPlayer)
    local playerPed = GetPlayerPed(xPlayer.source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle then
        local plate = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)

        MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
            xPlayer.getIdentifier(),
            plate,
            json.encode({model = model, plate = plate})
        })

        xPlayer.showNotification(_U('savecar_success', plate))
    else
        xPlayer.showNotification(_U('not_in_vehicle'))
    end
end, false, {help = _U('save_command_car')})
