QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-cleaning:server:recompensa')
AddEventHandler('qb-cleaning:server:recompensa', function(reward)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)

    xPlayer.Functions.AddItem('efectivo', reward)

    TriggerClientEvent('qb-inventory:client:ItemBox', _source, QBCore.Shared.Items['efectivo'], 'add')

    TriggerClientEvent('QBCore:Notify', _source, 'Has recibido ' .. reward .. ' de efectivo', 'success')
end)
