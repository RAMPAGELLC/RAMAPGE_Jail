local Timers = {}

function SaveFile(data)
    SaveResourceFile(GetCurrentResourceName(), "database.json", json.encode(data, {
        indent = true
    }), -1)
end

function LoadFile()
    return json.decode(LoadResourceFile(GetCurrentResourceName(), "database.json"));
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

RegisterCommand('jail', function(src, args, raw)
    if Config.RequireAcePermissions and not IsPlayerAceAllowed(src, Config.JailAcePermission) then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Invalid permissions to run this command",
            "error");
    end

    if #args < 2 then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Invalid usage. /jail <id> <time>",
            "error");
    end

    local id = args[1]
    local time = tonumber(args[2])

    if GetPlayerIdentifiers(id)[1] == nil then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Invalid player id", "error");
    end

    if time <= 0 then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Jail time must be above 0", "error");
    end

    if time > Config.MaxJailTime then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System",
            "Jail time must not be above the max jail time of " .. tostring(Config.MaxJailTime), "error");
    end

    local Identifiers = ExtractIdentifiers(id);
    Timers[id] = time

    TriggerClientEvent('RAMPAGE_Jail:Jail', id, Config.Cells[math.random(#Config.Cells, 1)], time);
    TriggerClientEvent('RAMAPGE_Jail:Notification', "Jail System", GetPlayerName(id) .. " has been jailed!", "success");
end)

RegisterCommand('release', function(src, args, raw)
    if Config.RequireAcePermissions and not IsPlayerAceAllowed(src, Config.ReleaseAcePermission) then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Invalid permissions to run this command",
            "error");
    end

    if #args < 1 then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Invalid usage. /release <id>", "error");
    end

    local id = args[1]

    if GetPlayerIdentifiers(id)[1] == nil then
        return TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", "Invalid player id", "error");
    end

    local Identifiers = ExtractIdentifiers(id);
    Timers[id] = 0

    TriggerClientEvent('RAMPAGE_Jail:Release', id, Config.Release);
    TriggerClientEvent('RAMAPGE_Jail:Notification', src, "Jail System", GetPlayerName(id) .. " has been released!", "success");
end)

RegisterNetEvent("RAMPAGE_Jail:Connected")
AddEventHandler("RAMPAGE_Jail:Connected", function()
    local Identifiers = ExtractIdentifiers(source);
    local Database = LoadFile();

    if Database[Identifiers.license] ~= nil then
        Timers[source] = tonumber(Database[Identifiers.license].Time) + (Config.DisconnectPunishment or 0)
        TriggerClientEvent('RAMPAGE_Jail:Jail', source, Config.Cells[math.random(#Config.Cells, 1)], Timers[source]);
    end
end)

AddEventHandler("playerDropped", function()
    local Identifiers = ExtractIdentifiers(source);
    local Database = LoadFile();

    if Timers[source] ~= nil and Timers[source] > 0 then
        Database[Identifiers.license] = {
            Time = Timers[source]
        }
        SaveFile(Database)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1 * 1000);

        for i, v in pairs(Timers) do
            if Timers[i] ~= nil and Timers[i] > 0 then
                Timers[i] = Timers[i] - 1;
            end

            if Timers[i] ~= nil and Timers[i] == 0 then
                TriggerClientEvent('RAMPAGE_Jail:Release', i, Config.Release);
                Timers[i] = nil;
            end
        end
    end
end)