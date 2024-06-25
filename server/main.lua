QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('ds-poolcleaning:server:recompensa')
AddEventHandler('ds-poolcleaning:server:recompensa', function(reward)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    player.Functions.AddItem('efectivo', recompensa)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['efectivo'], 'add')
    TriggerClientEvent('QBCore:Notify', src, 'Has recibido ' .. recompensa .. ' de efectivo', 'success')
end)

RegisterServerEvent('ds-poolcleaning:server:downfianza')
AddEventHandler('ds-poolcleaning:server:downfianza', function(plate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if plate == Config.Furgoneta.matricula then
        player.Functions.AddMoney('bank', 250, 'fianza')
        TriggerClientEvent('QBCore:Notify', src, "Se te ha devuelto la fianza", 'success')
    end
end)
RegisterServerEvent('ds-poolcleaning:server:upfianza')
AddEventHandler('ds-poolcleaning:server:upfianza', function(plate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if plate == Config.Furgoneta.matricula then
        player.Functions.RemoveMoney("bank", 250, 'fianza')
        TriggerClientEvent('QBCore:Notify', src, "Entregas la fianza", 'success')
    end
end)