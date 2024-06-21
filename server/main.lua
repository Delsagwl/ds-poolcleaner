QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-cleaning:server:recompensa')
AddEventHandler('qb-cleaning:server:recompensa', function(recompensa)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem('efectivo', recompensa)

    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['efectivo'], 'add', recompensa)

    TriggerClientEvent('QBCore:Notify', src, 'Has recibido ' .. recompensa .. ' de efectivo', 'success')
end)
