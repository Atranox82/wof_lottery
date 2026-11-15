local isUIOpen = false
local nearLocation = false

-- Blips
Citizen.CreateThread(function()
    for _, loc in pairs(Config.Locations) do
        if loc.blip then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, loc.coords.x, loc.coords.y, loc.coords.z)
            SetBlipSprite(blip, Config.BlipSprite, true)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, loc.blipName)
            SetBlipScale(blip, Config.BlipScale)
        end
    end
end)

-- Interaction loop
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        nearLocation = false

        for _, loc in pairs(Config.Locations) do
            local dist = #(coords - loc.coords)
            if dist < 2.0 then
                sleep = 0
                nearLocation = true
                DrawText3D(loc.coords.x, loc.coords.y, loc.coords.z + 1.0, "~e~[E]~q~ Lotterie öffnen")
                
                if IsControlJustReleased(0, 0xCEFD9220) then -- E key
                    OpenLotteryUI()
                end
                break
            end
        end

        Wait(sleep)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFontForCurrentCommand(1)
        SetTextColor(255, 215, 0, 215)
        SetTextCentre(1)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), _x, _y)
    end
end

function OpenLotteryUI()
    if isUIOpen then return end
    isUIOpen = true
    SetNuiFocus(true, true)
    TriggerServerEvent("wof_lottery:getData")
end

function CloseLotteryUI()
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

-- NUI Callbacks
RegisterNUICallback("close", function(data, cb)
    CloseLotteryUI()
    cb("ok")
end)

RegisterNUICallback("buyTicket", function(data, cb)
    TriggerServerEvent("wof_lottery:buyTicket")
    cb("ok")
end)

RegisterNUICallback("claim", function(data, cb)
    TriggerServerEvent("wof_lottery:claimWinnings")
    cb("ok")
end)

-- Receive data from server
RegisterNetEvent("wof_lottery:receiveData")
AddEventHandler("wof_lottery:receiveData", function(data)
    SendNUIMessage({
        action = "open",
        data = data
    })
end)

RegisterNetEvent("wof_lottery:updateUI")
AddEventHandler("wof_lottery:updateUI", function(jackpot, tickets)
    if isUIOpen then
        SendNUIMessage({
            action = "update",
            jackpot = jackpot,
            tickets = tickets
        })
    end
end)

-- Close with ESC
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if isUIOpen and IsControlJustReleased(0, 0x156F7119) then -- ESC
            CloseLotteryUI()
        end
    end
end)