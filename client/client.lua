local scenes = {}
local closestScenes = {}

local creationLaser = false
local deletionLaser = false

CreateThread(function()
    while true do
        closestScenes = {}
        for i=1, #scenes do
            local currentScene = scenes[i]
            local plyPosition = GetEntityCoords(PlayerPedId())
            local distance = #(plyPosition - currentScene.coords)
            if distance < Config.MaxPlacementDistance then
                closestScenes[#closestScenes+1] = currentScene
            end
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local wait = 1000
        if #closestScenes > 0 then
            wait = 0
            for i=1, #closestScenes do
                local currentScene = closestScenes[i]
                local plyPosition = GetEntityCoords(PlayerPedId())
                local distance = #(plyPosition - currentScene.coords)
                if distance <= currentScene.viewdistance then
                    DrawScene(closestScenes[i])
                end
            end
        end

        Wait(wait)
    end
end)

--- [REGISTER COMMANDS] ---
RegisterCommand('createscene', function()
    OpenMenu()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "monkeyopening", 0.05)
end, false)

RegisterCommand('deletescene', function()
    ToggleDeletionLaser()
end, false)

RegisterKeyMapping('createscene', 'Create Scene', 'keyboard', Config.CreateSceneKey)
RegisterKeyMapping('deletescene', 'Delete Scene', 'keyboard', Config.DeleteSceneKey)

--- [UI MENU] ---

RegisterNUICallback('CloseMenu', function(_, cb)
    CloseMenu()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "catclosing", 0.05)
    cb('ok')
end)

RegisterNUICallback('DeleteLaser', function(_, cb)
    CloseMenu()
    ToggleDeletionLaser()
    cb('ok')
end)

RegisterNUICallback('CreateScene', function(data, cb)
    creationLaser = false
    Wait(100)
    ToggleCreationLaser(data)
    cb('ok')
end)

RegisterNetEvent('IP-Scenes:client:UpdateAllScenes', function(list)
    scenes = list
end)

RegisterNetEvent('esx:playerLoaded', function()
    GetScenes()
end)

--- [FUNCTIONS SCRIPT] ---

function GetScenes()
    ESX.TriggerServerCallback('IP-Scenes:server:GetScenes', function(list)
        scenes = list
    end)
end

function OpenMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open"})
end

function CloseMenu()
    SetNuiFocus(false, false)
end

function ToggleCreationLaser(data)
    deletionLaser = false
    creationLaser = not creationLaser

    if creationLaser then
        CreateThread(function()
            while creationLaser do
                local hit, coords = DrawLaser('TEKAN ~g~E~w~ UNTUK MEMASANG\nTEKAN ~g~G~w~ UNTUK MENGEDIT', {r = 2, g = 241, b = 181, a = 200})

                data.coords = coords
                DrawScene(data)

                if IsControlJustReleased(0, 38) then
                    creationLaser = false
                    if hit then
                        TriggerServerEvent('IP-Scenes:server:CreateScene', data)
                    else
                        ne(_U('laser_error'))
                    end
                elseif IsControlJustReleased(0, 47) then
                    creationLaser = false
                    OpenMenu()
                end

                Wait(0)
            end
        end)
    end
end

function ToggleDeletionLaser()
    creationLaser = false
    deletionLaser = not deletionLaser

    if deletionLaser then
        CreateThread(function()
            while deletionLaser do
                local hit, coords = DrawLaser('TEKAN ~r~E~w~ UNTUK MENGHAPUS\nTEKAN ~r~G~w~ UNTUK CANCLE', {r = 255, g = 0, b = 0, a = 200})

                if IsControlJustReleased(0, 38) then
                    deletionLaser = false
                    if hit then
                        DeleteScene(coords)
                    else
                        ne(_U('laser_error'))
                    end
                elseif IsControlJustReleased(0, 47) then
                    deletionLaser = false
                end

                Wait(0)
            end
        end)
    end
end

function DeleteScene(coords)
    local closestScene = nil
    local shortestDistance = nil
    for i=1,#scenes do
        local currentScene = scenes[i]
        local distance =  #(coords - currentScene.coords)
        if distance < 1 and (shortestDistance == nil or distance < shortestDistance) then
            closestScene = currentScene.id
            shortestDistance = distance
        end
    end

    if closestScene then
        n(_U("scene_delete"))
        TriggerServerEvent('IP-Scenes:server:DeleteScene', closestScene)
    else
        ne(_U('laser_error'))
    end
end


--- [FUNCTIONS ASSET] ---

function DrawLaser(message, color)
    local hit, coords = RayCastGamePlayCamera(Config.MaxPlacementDistance)
    Draw2DText(message, 4, {255, 255, 255}, 0.4, 0.43, 0.888 + 0.025)

    if hit then
        local position = GetEntityCoords(PlayerPedId())
        DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
        DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
    end

    return hit, coords
end

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local _, hit, endCoords, _, _ = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return hit == 1, endCoords
end

function rgbToHex(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

function DrawScene(currentScene)
    local onScreen, screenX, screenY = World3dToScreen2d(currentScene.coords.x, currentScene.coords.y, currentScene.coords.z)
    if onScreen then
        local camCoords = GetGameplayCamCoords()
        local distance = #(currentScene.coords - camCoords)
        local fov = (1 / GetGameplayCamFov()) * 75
        local scale = (1 / distance) * (4) * fov * (currentScene.fontsize)
        local r,g,b=rgbToHex(currentScene.color)

        SetTextScale(0.0, scale)
        SetTextFont(currentScene.fontstyle)
        SetTextProportional(true)
        SetTextColour(r, g, b, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(currentScene.text)
        DrawText(screenX, screenY)
    end
end

--- [STOP RESOURCE] ---
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        GetScenes()
    end
end)