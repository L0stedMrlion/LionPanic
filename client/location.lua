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

RegisterCommand("loc", function()
    local ped = PlayerPedId()

        local jobName = PlayerData.job and PlayerData.job.name or nil
        if jobName and jobName == 'police' then
            RequestAnimDict("random@arrests")
            while (not HasAnimDictLoaded("random@arrests")) do
                Wait(100)
            end
            TaskPlayAnim(ped, "random@arrests", "generic_radio_chatter", 8.0, 2.5, -1, 49, 0, 0, 0, 0)
            SetCurrentPedWeapon(ped, GetHashKey("GENERIC_RADIO_CHATTER"), true)
            local playerCoords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('location:syncPosition', playerCoords)
            Wait(1000)
            ClearPedTasks(ped)
        else
            lib.notify({
                title = 'Location',
                description = 'You need to be a police officer to use location!',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Location',
            description = Config.CommandNotAllowed,
            type = 'error'
        })
    end
end)

RegisterNetEvent('location:sendCoords')
AddEventHandler('location:sendCoords', function()
    local ped = PlayerPedId()
    RequestAnimDict("random@arrests")
    while (not HasAnimDictLoaded("random@arrests")) do
        Wait(100)
    end
    TaskPlayAnim(ped, "random@arrests", "generic_radio_chatter", 8.0, 2.5, -1, 49, 0, 0, 0, 0)
    SetCurrentPedWeapon(ped, GetHashKey("GENERIC_RADIO_CHATTER"), true)
    local playerCoords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('location:syncPosition', playerCoords)
    Wait(1000) 
    ClearPedTasks(ped) 
end)

RegisterNetEvent('location:alarm')
AddEventHandler('location:alarm', function(playername, pos)
    local ped = PlayerPedId()

    lib.notify({
        id = 'location',
        title = "Location",
        description = 'Officer sent his location at GPS!',
        position = 'top-right',
        type = "inform",
        icon = "fa-solid fa-user",
    })


    local Blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(Blip, 280)
    SetBlipScale(Blip, 1.0)
    SetBlipColour(Blip, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Location)
    EndTextCommandSetBlipName(Blip)

    SetBlipRoute(Blip, false)

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

RegisterNetEvent('location:error')
AddEventHandler('location:error', function()
    ShowNotification(Config.NotAllowedNotification)
end)
