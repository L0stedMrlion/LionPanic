local PlayerData = {}
local Framework = Config.Framework

if Framework == "esx" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
    end)
end

RegisterCommand("panic", function()
    local ped = PlayerPedId()

    if Config.AllowCommand then
        local jobName = PlayerData.job and PlayerData.job.name or nil
        if jobName and jobName == 'police' then
            RequestAnimDict("random@arrests")
            while (not HasAnimDictLoaded("random@arrests")) do
                Wait(100)
            end
            TaskPlayAnim(ped, "random@arrests", "generic_radio_chatter", 8.0, 2.5, -1, 49, 0, 0, 0, 0)
            SetCurrentPedWeapon(ped, GetHashKey("GENERIC_RADIO_CHATTER"), true)
            local playerCoords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('panicButton:syncPosition', playerCoords)
            Wait(1000)
            ClearPedTasks(ped)
        else
            lib.notify({
                title = 'PANIC BUTTON',
                description = 'You need to be a police officer to use panic!',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'PANIC BUTTON',
            description = Config.CommandNotAllowed,
            type = 'error'
        })
    end
end)

RegisterNetEvent('panicbutton:sendCoords')
AddEventHandler('panicbutton:sendCoords', function()
    local ped = PlayerPedId()
    RequestAnimDict("random@arrests")
    while (not HasAnimDictLoaded("random@arrests")) do
        Wait(100)
    end
    TaskPlayAnim(ped, "random@arrests", "generic_radio_chatter", 8.0, 2.5, -1, 49, 0, 0, 0, 0)
    SetCurrentPedWeapon(ped, GetHashKey("GENERIC_RADIO_CHATTER"), true)
    local playerCoords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('panicButton:syncPosition', playerCoords)
    Wait(1000) 
    ClearPedTasks(ped) 
end)

RegisterNetEvent('panicButton:alarm')
AddEventHandler('panicButton:alarm', function(playername, pos)
    local ped = PlayerPedId()

    lib.notify({
        id = 'panicbutton',
        title = "PANIC BUTTON",
        description = 'Officer is in danger! Immediate help is needed!',
        position = 'top',
        iconAnimation = "beat",
        type = "error",
        duration = "6000",
        icon = "fa-solid fa-user",
    })

    SendNUIMessage({
        PayloadType = {"Panic", "ExternalPanic"}, 
        Payload = PlayerId() 
    })

    local Blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(Blip, 280)
    SetBlipScale(Blip, 1.0)
    SetBlipColour(Blip, 1)
    SetBlipFlashes(Blip, true)
    SetBlipFlashInterval(Blip, 500)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Panic Button")
    EndTextCommandSetBlipName(Blip)

    SetBlipRoute(Blip, true)

    CreateThread(function()
        local blipTime = Config.BlipTime * 1000
        local endTime = GetGameTimer() + blipTime

        while GetGameTimer() < endTime do
            SetBlipRouteColour(Blip, 1)
            Wait(150) 
            SetBlipRouteColour(Blip, 6)
            Wait(150)
            SetBlipRouteColour(Blip, 35)
            Wait(150)
            SetBlipRouteColour(Blip, 6)
        end

        RemoveBlip(Blip)
    end)
end)

RegisterNetEvent('panicButton:error')
AddEventHandler('panicButton:error', function()
    ShowNotification(Config.NotAllowedNotification)
end)
