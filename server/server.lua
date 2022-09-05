-----------------------
----   Variables   ----
-----------------------
local scenes = {}

-----------------------
----   Threads     ----
-----------------------

CreateThread(function()
    UpdateAllScenes()
    while true do
        DeleteExpiredScenes()
        Wait(Config.AuditInterval)
    end
end)

-----------------------
---- Server Events ----
-----------------------

ESX.RegisterServerCallback('IP-Scenes:server:GetScenes', function(_, cb)
    cb(scenes)
end)

-----------------------
----   Functions   ----
-----------------------

function UpdateAllScenes()
    scenes = {}
    MySQL.Async.fetchAll('SELECT * FROM scenes', {}, function(result)
        if result[1] then
            for _, v in pairs(result) do
                local newCoords = json.decode(v.coords)
                scenes[#scenes+1] = {
                    id = v.id,
                    text = v.text,
                    color = v.color,
                    viewdistance = v.viewdistance,
                    expiration = v.expiration,
                    fontsize = v.fontsize,
                    fontstyle = v.fontstyle,
                    coords = vector3(newCoords.x, newCoords.y, newCoords.z),
                }
            end
        end
        TriggerClientEvent('IP-Scenes:client:UpdateAllScenes', -1, scenes)
    end)
end

function DeleteExpiredScenes()
    MySQL.Async.execute('DELETE FROM scenes WHERE date_deletion < NOW()', {}, function(result)
        if result > 0 then
            print('Deleted '..result..' expired scenes from the database.')
            UpdateAllScenes()
        end
    end)
end

RegisterNetEvent('IP-Scenes:server:DeleteScene', function(id)
    MySQL.Async.execute('DELETE FROM scenes WHERE id = ?', {id}, function()
        UpdateAllScenes()
    end)
end)

RegisterNetEvent('IP-Scenes:server:CreateScene', function(sceneData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    MySQL.Async.insert('INSERT INTO scenes (creator, text, color, viewdistance, expiration, fontsize, fontstyle, coords, date_creation, date_deletion) VALUES (? ,?, ?, ?, ?, ?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? HOUR))', {
        Player.identifier,
        sceneData.text,
        sceneData.color,
        sceneData.viewdistance,
        sceneData.expiration,
        sceneData.fontsize,
        sceneData.fontstyle,
        json.encode(sceneData.coords),
        sceneData.expiration
    }, function()
        UpdateAllScenes()
    end)
end)
