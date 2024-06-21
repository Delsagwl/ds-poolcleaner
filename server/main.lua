QBCore = exports['qb-core']:GetCoreObject()

-- Evento para entregar la recompensa
RegisterServerEvent('qb-cleaning:server:recompensa')
AddEventHandler('qb-cleaning:server:recompensa', function(reward)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)

    -- Aquí asumimos que 'efectivo' es el nombre del ítem en tu configuración
    xPlayer.Functions.AddItem('efectivo', reward)

    -- Notificación al jugador
    TriggerClientEvent('qb-inventory:client:ItemBox', _source, QBCore.Shared.Items['efectivo'], 'add')

    -- Puedes agregar un mensaje adicional si lo deseas
    TriggerClientEvent('QBCore:Notify', _source, 'Has recibido ' .. reward .. ' de efectivo', 'success')
end)
