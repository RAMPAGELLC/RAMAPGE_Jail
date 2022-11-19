local Time = 0;
local Cell = {};

RegisterNetEvent('RAMAPGE_Jail:Jail')
AddEventHandler('RAMAPGE_Jail:Jail', function(cords, time)
    Time = time;
    Cell = cords;
    SetEntityCoords(GetPlayerPed(-1), cords.x, cords.y, cords.z, 1, 0, 0, 1)
end)

RegisterNetEvent('RAMAPGE_Jail:Notification')
AddEventHandler('RAMAPGE_Jail:Notification', function(title, desc, type)
    lib.notify({
        title = title,
        description = desc,
        type = type
    })
end)

RegisterNetEvent('RAMAPGE_Jail:Release')
AddEventHandler('RAMAPGE_Jail:Release', function(cords)
    Time = 0;
    Cell = {};
    SetEntityCoords(GetPlayerPed(-1), cords.x, cords.y, cords.z, 1, 0, 0, 1)
    lib.showTextUI("You have been released from jail", {
        position = "top-center",
        icon = 'clock',
        style = {
            borderRadius = 8,
            backgroundColor = '#48BB78',
            color = 'white'
        }
    })
    Citizen.SetTimeout((3 * 1000), function()
        lib.hideTextUI()
    end)
end)

Citizen.CreateThread(function()
    TriggerServerEvent("RAMAPGE_Jail:Connected");
    while true do
        Citizen.Wait(1000);

        if Time > 0 then
            Time = Time - 1;
        end

        if mod(Time, 5) == 0 and Time ~= 0 then
            lib.showTextUI(tostring(Time) .. "s left in jail", {
                position = "top-center",
                icon = 'clock',
                style = {
                    borderRadius = 8,
                    backgroundColor = '#ba1420',
                    color = 'white'
                }
            })

            SetEntityCoords(GetPlayerPed(-1), Cell.x, Cell.y, Cell.z, 1, 0, 0, 1)

            Citizen.SetTimeout((3 * 1000), function()
                lib.hideTextUI()
            end)
        end
    end
end)