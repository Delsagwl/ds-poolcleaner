local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local limpiando = false
local puntosLimpios = 0
local PuntosLimpieza = {}
local npc = nil
local van = nil
local blip = nil
local jobBlip = nil

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end

-- Blip para el trabajo
function createJobBlip()
    if jobBlip ~= nil then
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
    jobBlip = AddBlipForCoord(Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z)
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
function removeJobBlip()
    if jobBlip ~= nil then
        RemoveBlip(jobBlip)
        jobBlip = nil
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

function createNPC()
    local model = GetHashKey("a_m_y_stbla_02")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    npc = CreatePed(4, model, Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z - 1.0, Config.NPCLocation.h, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports['qb-target']:AddEntityZone("cleaning_npc", npc, {
        name="cleaning_npc",
        heading=0,
        debugPoly=false,
        minZ=Config.NPCLocation.z - 1,
        maxZ=Config.NPCLocation.z + 1
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
function spawnVan()
    local model = GetHashKey("burrito3") -- Modelo de la furgoneta, puedes cambiarlo
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    van = CreateVehicle(model, Config.VanSpawnPoint.x, Config.VanSpawnPoint.y, Config.VanSpawnPoint.z, Config.VanSpawnPoint.h, true, false)
    SetEntityAsMissionEntity(van, true, true)
    SetVehicleOnGroundProperly(van)
    SetVehicleDoorsLocked(van, 1)
    SetVehicleNumberPlateText(van, "CLEANER")
    TaskWarpPedIntoVehicle(PlayerPedId(), van, -1)
end

-- Función para barajar una tabla
function shuffleTable(t)
    local rand = math.random 
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Evento para iniciar la tarea de limpieza
RegisterNetEvent('qb-cleaning:client:startCleaning')
AddEventHandler('qb-cleaning:client:startCleaning', function()
    if not limpiando then
        limpiando = true
        puntosLimpios = 0
        PuntosLimpieza = {}

        local keys = {}
        for k in pairs(Config.ZonasLimpieza) do
            table.insert(keys, k)
        end

        -- Seleccionar un grupo de puntos de limpieza aleatorio
        local randomGroup = keys[math.random(#keys)]
        local group = Config.ZonasLimpieza[randomGroup]

        -- Barajar los puntos del grupo para asegurarnos de que sean únicos y seleccionarlos todos
        shuffleTable(group)
        for i = 1, math.min(10, #group) do
            table.insert(PuntosLimpieza, group[i])
        end

        spawnVan()

        -- Marcar el primer punto en el mapa
        local primero = PuntosLimpieza[1]
        blip = AddBlipForCoord(primero.x, primero.y, primero.z)
        SetBlipSprite(blip, 318) -- Sprite de la ruta estándar
        SetBlipRoute(blip, true) -- Marcar la ruta en el minimapa
        SetBlipColour(blip, 1) -- Color del blip (azul)
        SetBlipScale(blip, 0.8) -- Tamaño del blip
        SetBlipAsShortRange(blip, false) -- Mostrar blip en el radar a larga distancia

        -- Establecer el waypoint al primer punto
        SetNewWaypoint(primero.x, primero.y)

        QBCore.Functions.Notify("Has recibido una tarea de limpieza. Ve a los puntos indicados usando la furgoneta.", "success")
    else
        QBCore.Functions.Notify("Ya tienes una tarea de limpieza en curso.", "error")
    end
end)

-- Función para limpiar una zona
function limpiarZona(coords)
    TaskStartScenarioInPlace(PlayerPedId(), "world_human_janitor", 0, true)
    Citizen.Wait(10000) -- 10 segundos
    ClearPedTasks(PlayerPedId())
    puntosLimpios = puntosLimpios + 1
    local recompensa = math.random(Config.RecompensaMin, Config.RecompensaMax)
    TriggerServerEvent('qb-cleaning:server:recompensa', recompensa)

    if puntosLimpios >= 10 then
        limpiando = false
        RemoveBlip(blip)
        DeleteVehicle(van)
        QBCore.Functions.Notify("Has completado la tarea de limpieza. Vuelve para recibir una nueva ubicación.", "success")

        -- Marcar la ruta de vuelta al NPC
        blip = AddBlipForCoord(Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z)
        SetBlipSprite(blip, 318)
        SetBlipRoute(blip, true)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false) -- Mostrar blip en el radar a larga distancia

        -- Establecer el waypoint al NPC
        SetNewWaypoint(Config.NPCLocation.x, Config.NPCLocation.y)
    else
        -- Marca el siguiente punto en el mapa
        local nextLocation = PuntosLimpieza[puntosLimpios + 1]
        SetBlipCoords(blip, nextLocation.x, nextLocation.y, nextLocation.z)
        SetNewWaypoint(nextLocation.x, nextLocation.y)
    end
end

-- Detección de zonas de limpieza y mostrar texto
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if limpiando then
            local playerCoords = GetEntityCoords(PlayerPedId())
            for _, zona in pairs(PuntosLimpieza) do
                local dist = GetDistanceBetweenCoords(playerCoords, zona.x, zona.y, zona.z, true)
                if dist < 10.0 then
                    DrawText3D(zona.x, zona.y, zona.z, "[E] Limpiar")
                    if dist < 2.0 then
                        if IsControlJustReleased(0, 38) then
                            limpiarZona(zona)
                        end
                    end
                end
            end
        end
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
