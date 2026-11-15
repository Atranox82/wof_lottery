local VorpCore = {}
local VorpInv = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local currentJackpot = Config.JackpotStart
local lastDrawDate = nil

-- Discord Webhook Function
function SendWebhook(title, description, fields)
    if not Config.Webhook.enabled or Config.Webhook.url == "" or Config.Webhook.url == nil then
        return
    end

    local embed = {
        {
            title = title,
            description = description,
            color = Config.Webhook.color,
            fields = fields or {},
            footer = {
                text = "World of Freedom • Lotterie",
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.Webhook.url, function(err, text, headers) end, 'POST', json.encode({
        username = Config.Webhook.botName,
        avatar_url = Config.Webhook.botAvatar,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Initialize
Citizen.CreateThread(function()
    Wait(2000)
    LoadJackpot()
    CheckDrawTime()
end)

function LoadJackpot()
    MySQL.Async.fetchScalar('SELECT current_jackpot FROM wof_lottery_jackpot WHERE id = 1', {}, function(result)
        if result then
            currentJackpot = tonumber(result)
        else
            currentJackpot = Config.JackpotStart
            MySQL.Async.execute('INSERT INTO wof_lottery_jackpot (id, current_jackpot) VALUES (1, @jackpot)', {
                ['@jackpot'] = currentJackpot
            })
        end
        if Config.Debug then print("[wof_lottery] Jackpot loaded: " .. currentJackpot) end
    end)
end

function GetTodayDate()
    return os.date("%Y-%m-%d")
end

function GetPlayerTickets(charid, date)
    local result = MySQL.Sync.fetchAll('SELECT * FROM wof_lottery_tickets WHERE charid = @charid AND draw_date = @date', {
        ['@charid'] = charid,
        ['@date'] = date
    })
    return result or {}
end

function BuyTicket(source)
    local User = VorpCore.getUser(source)
    if not User then return end
    
    local Character = User.getUsedCharacter
    local charid = Character.charIdentifier
    local identifier = Character.identifier
    local money = Character.money
    local today = GetTodayDate()

    if money < Config.TicketPrice then
        TriggerClientEvent("vorp:TipRight", source, Config.Messages.notEnoughMoney, 4000)
        return
    end

    local tickets = GetPlayerTickets(charid, today)
    if #tickets >= Config.MaxTicketsPerPlayer then
        TriggerClientEvent("vorp:TipRight", source, Config.Messages.maxTickets, 4000)
        return
    end

    -- Generate unique ticket number for today
    local ticketNumber = math.random(1000, 9999)
    local exists = true
    while exists do
        local check = MySQL.Sync.fetchScalar('SELECT id FROM wof_lottery_tickets WHERE ticket_number = @num AND draw_date = @date', {
            ['@num'] = ticketNumber,
            ['@date'] = today
        })
        if not check then exists = false else ticketNumber = math.random(1000, 9999) end
    end

    Character.removeCurrency(0, Config.TicketPrice)

    MySQL.Async.execute('INSERT INTO wof_lottery_tickets (charid, identifier, ticket_number, draw_date) VALUES (@charid, @identifier, @ticket, @date)', {
        ['@charid'] = charid,
        ['@identifier'] = identifier,
        ['@ticket'] = ticketNumber,
        ['@date'] = today
    })

    -- Add to jackpot
    local addToJackpot = Config.TicketPrice * (Config.JackpotPercentage / 100)
    currentJackpot = currentJackpot + addToJackpot

    MySQL.Async.execute('UPDATE wof_lottery_jackpot SET current_jackpot = @jackpot WHERE id = 1', {
        ['@jackpot'] = currentJackpot
    })

    TriggerClientEvent("vorp:TipRight", source, string.format(Config.Messages.ticketBought, ticketNumber), 5000)
    TriggerClientEvent("wof_lottery:updateUI", source, currentJackpot, #tickets + 1)

    -- Webhook: Ticket bought
    if Config.Webhook.logs.ticketBought then
        local playerName = Character.firstname .. " " .. Character.lastname
        SendWebhook(
            "🎫 Neues Los gekauft",
            "**" .. playerName .. "** hat ein Lotterie-Los gekauft.",
            {
                { name = "Spieler", value = playerName .. " (CharID: " .. charid .. ")", inline = true },
                { name = "Los Nummer", value = tostring(ticketNumber), inline = true },
                { name = "Preis", value = "$" .. Config.TicketPrice, inline = true },
                { name = "Neuer Jackpot", value = "$" .. string.format("%.2f", currentJackpot), inline = true },
                { name = "Lose des Spielers", value = (#tickets + 1) .. " / " .. Config.MaxTicketsPerPlayer, inline = true }
            }
        )
    end
end

function DoDraw()
    local today = GetTodayDate()
    
    -- Check if already drawn today
    local alreadyDrawn = MySQL.Sync.fetchScalar('SELECT id FROM wof_lottery_draws WHERE draw_date = @date', {
        ['@date'] = today
    })
    if alreadyDrawn then return end

    local tickets = MySQL.Sync.fetchAll('SELECT * FROM wof_lottery_tickets WHERE draw_date = @date', {
        ['@date'] = today
    })

    local totalTickets = #tickets

    if totalTickets > 0 then
        local winnerIndex = math.random(1, totalTickets)
        local winnerTicket = tickets[winnerIndex]
        
        local winnerName = "Unbekannt"

        -- Announce
        TriggerClientEvent("vorp:TipBottom", -1, string.format(Config.Messages.winner, winnerName, currentJackpot), 10000)
        
        -- Save draw
        MySQL.Async.execute('INSERT INTO wof_lottery_draws (draw_date, jackpot, total_tickets, winner_charid, winner_identifier, winner_name, winning_ticket) VALUES (@date, @jackpot, @tickets, @charid, @identifier, @name, @ticket)', {
            ['@date'] = today,
            ['@jackpot'] = currentJackpot,
            ['@tickets'] = totalTickets,
            ['@charid'] = winnerTicket.charid,
            ['@identifier'] = winnerTicket.identifier,
            ['@name'] = winnerName,
            ['@ticket'] = winnerTicket.ticket_number
        })

        -- Webhook: Draw with winner
        if Config.Webhook.logs.draw then
            SendWebhook(
                "🎉 Lotterie Ziehung",
                "Die tägliche Ziehung um 17:00 Uhr ist abgeschlossen!",
                {
                    { name = "Gewinner", value = winnerName .. " (CharID: " .. winnerTicket.charid .. ")", inline = false },
                    { name = "Gewinnendes Los", value = tostring(winnerTicket.ticket_number), inline = true },
                    { name = "Jackpot", value = "$" .. string.format("%.2f", currentJackpot), inline = true },
                    { name = "Verkaufte Lose", value = tostring(totalTickets), inline = true },
                    { name = "Datum", value = today, inline = true }
                }
            )
        end
    else
        MySQL.Async.execute('INSERT INTO wof_lottery_draws (draw_date, jackpot, total_tickets) VALUES (@date, @jackpot, 0)', {
            ['@date'] = today,
            ['@jackpot'] = currentJackpot
        })
        TriggerClientEvent("vorp:TipBottom", -1, Config.Messages.noTickets, 8000)

        -- Webhook: No tickets
        if Config.Webhook.logs.draw then
            SendWebhook(
                "📭 Keine Lose verkauft",
                "Die Ziehung um 17:00 Uhr fand statt, aber es wurden keine Lose verkauft.",
                {
                    { name = "Jackpot", value = "$" .. string.format("%.2f", currentJackpot), inline = true },
                    { name = "Datum", value = today, inline = true }
                }
            )
        end
    end

    -- Reset jackpot for next day
    currentJackpot = Config.JackpotStart
    MySQL.Async.execute('UPDATE wof_lottery_jackpot SET current_jackpot = @jackpot WHERE id = 1', {
        ['@jackpot'] = currentJackpot
    })

    lastDrawDate = today
    if Config.Debug then print("[wof_lottery] Draw completed for " .. today) end
end

function CheckDrawTime()
    Citizen.CreateThread(function()
        while true do
            local hour = tonumber(os.date("%H"))
            local minute = tonumber(os.date("%M"))
            local today = GetTodayDate()

            if hour == Config.DrawHour and minute == Config.DrawMinute and lastDrawDate ~= today then
                DoDraw()
            end

            Wait(30000) -- Check every 30 seconds
        end
    end)
end

-- Events
RegisterNetEvent("wof_lottery:buyTicket")
AddEventHandler("wof_lottery:buyTicket", function()
    BuyTicket(source)
end)

RegisterNetEvent("wof_lottery:claimWinnings")
AddEventHandler("wof_lottery:claimWinnings", function()
    local source = source
    local User = VorpCore.getUser(source)
    if not User then return end
    
    local Character = User.getUsedCharacter
    local charid = Character.charIdentifier

    -- Check last draw
    local lastDraw = MySQL.Sync.fetchAll('SELECT * FROM wof_lottery_draws WHERE winner_charid = @charid AND claimed = 0 ORDER BY id DESC LIMIT 1', {
        ['@charid'] = charid
    })

    if #lastDraw > 0 then
        local draw = lastDraw[1]
        Character.addCurrency(0, draw.jackpot)
        
        MySQL.Async.execute('UPDATE wof_lottery_draws SET claimed = 1 WHERE id = @id', {
            ['@id'] = draw.id
        })

        TriggerClientEvent("vorp:TipRight", source, string.format(Config.Messages.claimSuccess, draw.jackpot), 6000)

        -- Webhook: Claim
        if Config.Webhook.logs.claim then
            local playerName = Character.firstname .. " " .. Character.lastname
            SendWebhook(
                "💰 Gewinn abgeholt",
                "**" .. playerName .. "** hat seinen Lotterie-Gewinn abgeholt.",
                {
                    { name = "Spieler", value = playerName .. " (CharID: " .. charid .. ")", inline = true },
                    { name = "Betrag", value = "$" .. string.format("%.2f", draw.jackpot), inline = true },
                    { name = "Ziehungsdatum", value = draw.draw_date, inline = true }
                }
            )
        end
    else
        TriggerClientEvent("vorp:TipRight", source, Config.Messages.noWinnerYet, 4000)
    end
end)

RegisterNetEvent("wof_lottery:getData")
AddEventHandler("wof_lottery:getData", function()
    local source = source
    local User = VorpCore.getUser(source)
    if not User then return end
    
    local Character = User.getUsedCharacter
    local charid = Character.charIdentifier
    local today = GetTodayDate()
    local tickets = GetPlayerTickets(charid, today)

    TriggerClientEvent("wof_lottery:receiveData", source, {
        jackpot = currentJackpot,
        myTickets = #tickets,
        maxTickets = Config.MaxTicketsPerPlayer,
        ticketPrice = Config.TicketPrice,
        drawTime = string.format("%02d:%02d", Config.DrawHour, Config.DrawMinute)
    })
end)

-- Admin command to force draw (optional)
RegisterCommand("forcedraw", function(source, args, rawCommand)
    if source == 0 then -- Console only
        DoDraw()
        print("[wof_lottery] Forced draw executed")
    end
end, true)