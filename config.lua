Config = {}

-- General
Config.Locale = 'de'
Config.Debug = false

-- Lottery Settings
Config.TicketPrice = 5.00              -- Preis pro Los in $
Config.MaxTicketsPerPlayer = 10        -- Maximale Lose pro Spieler pro Ziehung
Config.JackpotStart = 50.00            -- Start-Jackpot wenn keine Lose verkauft wurden
Config.JackpotPercentage = 80          -- Wie viel Prozent der Ticket-Einnahmen in den Jackpot gehen

-- Draw Time (24h Format)
Config.DrawHour = 17                   -- Ziehung um 17:00 Uhr
Config.DrawMinute = 0

-- Locations where players can buy tickets (vector3)
Config.Locations = {
    {
        coords = vector3(-272.0, 804.0, 119.0),  -- Beispiel: Valentine
        heading = 180.0,
        blip = true,
        blipName = "Lotterie"
    },
    {
        coords = vector3(-813.0, -1324.0, 43.0), -- Beispiel: Blackwater
        heading = 90.0,
        blip = true,
        blipName = "Lotterie"
    },
    -- Weitere Orte hier hinzufügen
}

-- Blip Settings
Config.BlipSprite = 1879260108  -- Western style blip
Config.BlipScale = 0.8
Config.BlipColor = 0xFFD700

-- Webhook (Discord)
Config.Webhook = {
    enabled = true,                          -- true = Webhook aktiv
    url = "",                                -- Discord Webhook URL hier einfügen
    botName = "World of Freedom Lotterie",
    botAvatar = "https://i.imgur.com/example.png", -- Optional Avatar URL
    color = 16766720,                        -- Gold Farbe (Decimal)
    logs = {
        ticketBought = true,                 -- Los gekauft
        draw = true,                         -- Ziehung (Gewinner oder keine Lose)
        claim = true                         -- Gewinn abgeholt
    }
}

-- Messages (German)
Config.Messages = {
    notEnoughMoney = "Du hast nicht genug Geld!",
    ticketBought = "Los erfolgreich gekauft! Nummer: %s",
    maxTickets = "Du hast bereits die maximale Anzahl an Losen gekauft!",
    noTickets = "Es wurden keine Lose für diese Ziehung verkauft.",
    winner = "🎉 Gewinner der Lotterie: %s mit %s$",
    youWon = "Glückwunsch! Du hast die Lotterie gewonnen! Gewinn: %s$",
    alreadyClaimed = "Du hast deinen Gewinn bereits abgeholt.",
    claimSuccess = "Gewinn erfolgreich ausgezahlt: %s$",
    drawSoon = "Die nächste Ziehung ist um 17:00 Uhr!",
    noWinnerYet = "Noch kein Gewinner für die letzte Ziehung."
}