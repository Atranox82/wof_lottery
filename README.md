# World of Freedom - Lottery System (wof_lottery)

**Author:** atranox_tv  
**Framework:** VorpCore (RedM)

## Features
- Tägliche Ziehung fest um **17:00 Uhr**
- Lose kaufen (mit Limit pro Spieler)
- Jackpot wächst mit verkauften Losen
- Zufälliger Gewinner
- Gewinn abholen (auch offline möglich)
- Schönes Western-UI im World of Freedom Stil
- Blips an Lotterie-Standorten
- Vollständig konfigurierbar

## Installation
1. Ordner `wof_lottery` in deinen `resources` Ordner legen
2. SQL-Datei aus dem `sql/` Ordner in deiner Datenbank ausführen
3. In der `server.cfg` eintragen:
   ```
   ensure wof_lottery
   ```
4. Config anpassen (`config.lua`) – besonders die Locations!

## Dependencies
- vorp_core
- vorp_inventory
- oxmysql

## Config
In `config.lua` kannst du anpassen:
- Ticketpreis
- Maximale Lose pro Spieler
- Start-Jackpot
- Ziehung-Uhrzeit
- Standorte
- **Discord Webhook** (Los-Käufe, Ziehungen, Gewinn-Abholungen)

### Webhook einrichten
1. Erstelle einen Discord Webhook in deinem Server
2. Trage die URL in `Config.Webhook.url` ein
3. `Config.Webhook.enabled = true` setzen
4. Einzelne Logs kannst du an/ausschalten unter `Config.Webhook.logs`

## Commands
- `/forcedraw` (nur Konsole) – Manuelle Ziehung auslösen

---
**World of Freedom** • Viel Erfolg mit dem Script!