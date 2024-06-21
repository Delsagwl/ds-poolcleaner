local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local limpiando = false
local puntosLimpios = 0
local PuntosLimpieza = {}
local npc = nil
local van = nil
local blip = nil
local jobBlip = nil

-- Blip para el trabajo
local function createJobBlip()
    if jobBlip ~= nil then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
    jobBlip = AddBlipForCoord(Config.NPC.x, Config.NPC.y, Config.NPC.z)
    SetBlipSprite(jobBlip, 408)
    SetBlipDisplay(jobBlip, 4)
    SetBlipScale(jobBlip, 0.9)
    SetBlipColour(jobBlip, 3)
    SetBlipAsShortRange(jobBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Trabajo de Limpiador")
    EndTextCommandSetBlipName(jobBlip)
end

-- Quitar Blip para el trabajo
local function removeJobBlip()
    if jobBlip ~= nil then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
end

local function createNPC()
    local model = GetHashKey("s_m_m_gardener_01")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    npc = CreatePed(4, model, Config.NPC.x, Config.NPC.y, Config.NPC.z - 1.0, Config.NPC.h, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports['qb-target']:AddEntityZone("cleaning_npc", npc, {
        name = "cleaning_npc",
        heading = 0,
        debugPoly = false,
        minZ = Config.NPC.z - 1,
        maxZ = Config.NPC.z + 1
    }, {
        options = {
            {
                type = "client",
                event = "qb-cleaning:client:startCleaning",
                icon = "fas fa-broom",
                label = "Recibir tarea de limpieza",
                job = "poolcleaner" -- Solo disponible para trabajadores con este job
            }
        },
        distance = 2.5
    })
end

-- Función para crear la furgoneta en el punto de spawn
local function spawnVan()
    local model = GetHashKey("burrito3") -- Modelo de la furgoneta
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    van = CreateVehicle(model, Config.Furgoneta.x, Config.Furgoneta.y, Config.Furgoneta.z, Config.Furgoneta.h, true, false)
    SetEntityAsMissionEntity(van, true, true)
    SetVehicleOnGroundProperly(van)
    SetVehicleDoorsLocked(van, 1)
    SetVehicleNumberPlateText(van, QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2))
    exports['ps-fuel']:SetFuel(van, 100.0)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(van))
    TaskWarpPedIntoVehicle(PlayerPedId(), van, -1)
end

-- Función para barajar una tabla
local function shuffleTable(t)
    local rand = math.random
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Evento para cuando el trabajo cambia
RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    if JobInfo.name == "poolcleaner" then
        createJobBlip()
    else
        removeJobBlip()
    end
end)

-- Evento para cuando el jugador se carga
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == "poolcleaner" then
        createJobBlip()
    else
        removeJobBlip()
    end
end)

-- Evento para iniciar la tarea de limpieza
RegisterNetEvent('qb-cleaning:client:startCleaning')
AddEventHandler('qb-cleaning:client:startCleaning', function()
    if not limpiando then
        limpiando = true
        puntosLimpios = 0
        PuntosLimpieza = {}

        -- Obtener las claves de las zonas de limpieza
        local keys = {}
        for k in pairs(Config.ZonasLimpieza) do
            table.insert(keys, k)
        end

        -- Seleccionar una clave aleatoria
        local randomKey = keys[math.random(#keys)]
        local zonaAleatoria = Config.ZonasLimpieza[randomKey]

        -- Barajar los puntos del grupo para asegurarnos de que sean únicos y seleccionarlos todos
        shuffleTable(zonaAleatoria)
        for i = 1, math.min(10, #zonaAleatoria) do
            table.insert(PuntosLimpieza, zonaAleatoria[i])
        end

        spawnVan()

        -- Marcar el primer punto en el mapa
        local primero = PuntosLimpieza[1]
        blip = AddBlipForCoord(primero.x, primero.y, primero.z)
        SetBlipSprite(blip, 318)
        SetBlipRoute(blip, true)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false) -- Mostrar blip en el radar a larga distancia

        -- Establecer el waypoint al primer punto
        SetNewWaypoint(primero.x, primero.y)

        QBCore.Functions.Notify("Has recibido una tarea de limpieza. Ve a los puntos indicados usando la furgoneta.", "success")
    else
        QBCore.Functions.Notify("Ya tienes una tarea de limpieza en curso.", "error")
    end
end)

-- Función para limpiar una zona
local function limpiarZona(zona)
    ExecuteCommand("e broom")
    Citizen.Wait(10000) -- 10 segundos
    ClearPedTasks(PlayerPedId())
    puntosLimpios = puntosLimpios + 1
    local recompensa = math.random(Config.RecompensaMin, Config.RecompensaMax)
    TriggerServerEvent('qb-cleaning:server:recompensa', recompensa)

    -- Eliminar el punto limpiado de la lista
    for i, punto in ipairs(PuntosLimpieza) do
        if punto.x == zona.x and punto.y == zona.y and punto.z == zona.z then
            table.remove(PuntosLimpieza, i)
            break
        end
    end

    if puntosLimpios >= 10 then
        limpiando = false
        RemoveBlip(blip)
        DeleteVehicle(van)
        QBCore.Functions.Notify("Has completado la tarea de limpieza. Vuelve para recibir una nueva ubicación.", "success")

        -- Marcar la ruta de vuelta al NPC
        blip = AddBlipForCoord(Config.NPC.x, Config.NPC.y, Config.NPC.z)
        SetBlipSprite(blip, 318)
        SetBlipRoute(blip, true)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false) -- Mostrar blip en el radar a larga distancia

        -- Establecer el waypoint al NPC
        SetNewWaypoint(Config.NPC.x, Config.NPC.y)
    else
        -- Marca el siguiente punto en el mapa
        if #PuntosLimpieza > 0 then
            local nextLocation = PuntosLimpieza[1]
            SetBlipCoords(blip, nextLocation.x, nextLocation.y, nextLocation.z)
            SetNewWaypoint(nextLocation.x, nextLocation.y)
        end
    end
end

-- Detección de zonas de limpieza y mostrar marcador
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())

        if limpiando then
            sleep = 100
            for _, zona in pairs(PuntosLimpieza) do
                local dist = GetDistanceBetweenCoords(playerCoords, zona.x, zona.y, zona.z, true)
                if dist < 15.0 then
                    sleep = 0
                    DrawMarker(21, zona.x, zona.y, zona.z, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.6, 0.6, 0.6, 28, 149, 255, 100, true, true, 2, false, false, false, false)

                    if dist < 2.0 then
                        if IsControlJustReleased(0, 38) then
                            limpiarZona(zona)
                        end
                    end
                end
            end
        end
        local spawnDist = GetDistanceBetweenCoords(playerCoords, Config.Furgoneta.x, Config.Furgoneta.y, Config.Furgoneta.z, true)
        if spawnDist < 5.0 then
            DrawMarker(1, Config.Furgoneta.x, Config.Furgoneta.y, Config.Furgoneta.z - 1.0, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.0, 255, 0, 0, 100, false, false, 2, true, nil, nil, false)
            if spawnDist < 2.0 then
                QBCore.Functions.DrawText3D(Config.Furgoneta.x, Config.Furgoneta.y, Config.Furgoneta.z, "[E] Devolver Furgoneta")
                if IsControlJustReleased(0, 38) then
                    if van then
                        DeleteVehicle(van)
                        van = nil
                        QBCore.Functions.Notify("Furgoneta devuelta.", "success")
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Manejar onResourceStop para eliminar el NPC y la furgoneta
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if npc then
            DeleteEntity(npc)
        end
        if van then
            DeleteVehicle(van)
        end
        if blip then
            RemoveBlip(blip)
        end
        removeJobBlip()
    end
end)

-- Manejar onResourceStarting para crear el NPC
AddEventHandler('onResourceStarting', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        createNPC()
    end
end)

-- Crear NPC cuando el script se carga
Citizen.CreateThread(function()
    createNPC()
end)