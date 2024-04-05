local TriggerClientEvent, pairs, ipairs, PerformHttpRequest, json_encode = TriggerClientEvent, pairs, ipairs, PerformHttpRequest, json.encode


local function SendLog(webhook, name, title, color, message, tagEveryone, player)      
     local playerName, playerJob

     if Config.Framework == "esx" then 
        local xPlayer = ESX.GetPlayerFromId(source)

        local firstname = xPlayer.get('firstName')
        local lastname = xPlayer.get('lastName')
        playerName = firstname .. ' ' .. lastname
    
        playerJob = xPlayer.job.name
    elseif Config.Framework == "qbcore" then
        xPlayer = QBCore.Functions.GetPlayer(source)
        playerName = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
        playerJob = xPlayer.PlayerData.job.name
    end

     local embedData = { 
         {
             ['title'] = title,
             ['color'] = Config.embedcolor,
             ['footer'] = {
                 ['text'] = Config.Servername .. " | Logs | ".. os.date(),
             },
             ['description'] = playerName.. " Job: " .. playerJob,
             ['author'] = {
                 ['name'] = name .. ' | Logs', 
             },
         }
     }

     PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json_encode({ username = 'Logs', embeds = embedData}), { ['Content-Type'] = 'application/json' })

     if tagEveryone then
         Wait(100)
         PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json_encode({ username = 'Logs', content = '|| @everyone @here ||'}), { ['Content-Type'] = 'application/json' })
     end
end

local function GetPlayerDetails(source)
    if Config.Framework == "esx" then
        return ESX.GetPlayerFromId(source)
    end
    return QBCore.Functions.GetPlayer(source)
end

RegisterNetEvent('panicButton:syncPosition')
AddEventHandler('panicButton:syncPosition', function(position)
    local src = source

    if Config.Framework == "esx" then
        local sourcePlayer = ESX.GetPlayerFromId(src)
        if not sourcePlayer then
            print("Failed to get source player data for ESX!")
            return
        end
        
        local firstname = sourcePlayer.get('firstName')
        local lastname = sourcePlayer.get('lastName') 
        local playerName = firstname .. ' ' .. lastname

        local targetPlayers = ESX.GetPlayers()
        for _, playerId in ipairs(targetPlayers) do
            local targetPlayer = ESX.GetPlayerFromId(playerId)
            if targetPlayer then
                local targetPlayerJob = targetPlayer.job and targetPlayer.job.name
                for _, job in pairs(Config.Jobs) do
                    if targetPlayerJob == job then
                        TriggerClientEvent('panicButton:alarm', playerId, playerName, position)
                        SendLog(Webhook.TRIGGERED, Config.Webhooktitle, Config.Translation["panic_triggered"]:format(playerName))
                    end
                end
            end
        end

        return 
    end

    if Config.Framework == "qbcore" then
        local sourcePlayer = QBCore.Functions.GetPlayer(src)
        if not sourcePlayer then
            print("Failed to get source player data for QBCore!")
            return
        end
        
        local firstname = sourcePlayer.PlayerData.charinfo.firstname or "Unknown"
        local lastname = sourcePlayer.PlayerData.charinfo.lastname or "Unknown"
        local playerName = firstname .. ' ' .. lastname

        local targetPlayers = QBCore.Functions.GetPlayers()
        for _, playerId in ipairs(targetPlayers) do
            local targetPlayer = QBCore.Functions.GetPlayer(playerId)
            if targetPlayer then
                local targetPlayerJob = targetPlayer.job and targetPlayer.job.name or targetPlayer.PlayerData.job.name
                for _, job in pairs(Config.Jobs) do
                    if targetPlayerJob == job then
                        TriggerClientEvent('panicButton:alarm', targetPlayer.PlayerData.source, playerName, position)
                        SendLog(Webhook.TRIGGERED, Config.Webhooktitle, Config.Translation["panic_triggered"]:format(playerName))
                    end
                end
            end
        end

        return 
    end

    print("Invalid Framework Configuration!")
end)
