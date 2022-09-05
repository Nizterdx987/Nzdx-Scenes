Config = {}

Config.Locale = 'id'
Config.AdminOnly = false -- Only Admins will be able to use this NUI
Config.CreateSceneKey = 'K' -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.DeleteSceneKey = 'DELETE' -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.MaxPlacementDistance = 25.0
Config.AuditInterval = 1000 * 60 * 15 -- Timeframe in milisections on how often the database will be queried to check for expired drawtexts

function n(msg)
	exports['okokNotify']:Alert('Scenes Information', msg, 5000, 'success')
end

function ne(msg)
	exports['okokNotify']:Alert('Scenes Information', msg, 5000, 'error')
end