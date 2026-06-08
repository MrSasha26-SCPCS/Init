local PluginAPI = CS.Akequ.Plugins.PluginAPI
local GameObject = CS.UnityEngine.GameObject

local function getConfigBool(id, default_val)
    local file = io.open("config.ini", "r")
    local STRdefault_value = false

    if file then
        for line in file:lines() do
            local pattern = id .. ":"
            if string.find(line, pattern) then
                if string.find(line, "true") then
                    return true
                else
                    return false
                end
            end
        end             
        file:close()
    end
    return default_val
end

local function getIndex(tab, val)
    for i, value in ipairs(tab) do
        if value == val then
            return i
        end
    end
    return -1
end

local function toTable(g)
    local myTable = {}
    for i = 0, g.Length - 1 do
        table.insert(myTable, g[i])
    end
    return myTable
end

---@class Init:CS.Akequ.Plugins.PluginInitializator
Init = {}

function Init:GlobalInit()
    PluginAPI.RegisterAdminPanel("AAA", "aaa")

    PluginAPI.RegisterRoomEvent("EZ_Lockroom_event")
    PluginAPI.RegisterRoomEvent("PD_event")
    PluginAPI.RegisterRoomEvent("AWRoom_event")
    PluginAPI.RegisterRoomEvent("mrs_RoundTimer")
    PluginAPI.RegisterRoomEvent("NewRoundManager")
    PluginAPI.RegisterRoomEvent("NewSupportManager")
    PluginAPI.RegisterRoomEvent("IntercomLoot")
    PluginAPI.RegisterRoomEvent("HC079Loot")
    PluginAPI.RegisterRoomEvent("SCPSwaper")
    PluginAPI.RegisterRoomEvent("Tips")
    PluginAPI.RegisterRoomEvent("WaitingPVP")

    PluginAPI.RegisterRoomEvent("SCPHole")

    PluginAPI.RegisterPlayerClass("TutorialClass", false)
    PluginAPI.RegisterPlayerClass("SerpentsHand", false)
    PluginAPI.RegisterPlayerClass("PVPClass", false)
    PluginAPI.RegisterPlayerClass("ChaosInsurgency", false)

    PluginAPI.RegisterItem("SCP420J", false, CS.ResourcesManager.GetSprite("inv_item_scp420j"))
end

function Init:InitClient()
    self:GlobalInit()

    local room_bundle = CS.ScriptHelper.LoadBundle("adminroom")
    if room_bundle then    
        local shader = room_bundle:LoadAsset("shader.shader", typeof(CS.UnityEngine.Shader))
        local room = GameObject.Instantiate(room_bundle:LoadAsset("adminroom.prefab", typeof(GameObject)))
        local mat = room_bundle:LoadAsset("plant.mat", typeof(CS.UnityEngine.Material))

        room.transform.position = CS.UnityEngine.Vector3(1000, -355, 0)

        local meshRenderers = room:GetComponentsInChildren(typeof(CS.UnityEngine.MeshRenderer))
        for i = 0, meshRenderers.Length - 1 do
            local meshRenderer = meshRenderers[i]
            if not meshRenderer.name:find("Plane") then
                meshRenderer.material.shader = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
            else
                meshRenderer.material = mat
                meshRenderer.material.shader = shader
            end
        end
    end
end

function Init:InitServer()
    self:GlobalInit()

    if getConfigBool("updated_rooms", false) then        
        PluginAPI.AddPreMapGenerationCallback(function(zones)
            --Setting PD
            local pdzone = zones[6]
            local pdroom = pdzone.rooms[0]
            pdroom.eventScript = "PD_event"

            --Setting Lockroom
            local ezone = zones[2]
            for i = 0, ezone.rooms.Length - 1 do
                local room = ezone.rooms[i]
                if room.roomName == "EZ_Lockroom" then
                    room.spawnOnce = true
                    room.eventScript = "EZ_Lockroom_event"
                    local hcz = toTable(zones[1].rooms)
                    local lcz = toTable(zones[0].rooms)
                    if getIndex(lcz, room) == -1 then
                        table.insert(lcz, room)
                    end
                    if getIndex(hcz, room) == -1 then
                        table.insert(hcz, room)
                    end
                    zones[0].rooms = lcz
                    zones[1].rooms = hcz
                    break
                end
            end
            return zones
        end)
    end

    local room_bundle = CS.ScriptHelper.LoadBundle("adminroom")
    if room_bundle then    
        local room = GameObject.Instantiate(room_bundle:LoadAsset("adminroom.prefab", typeof(GameObject)))
        room.transform.position = CS.UnityEngine.Vector3(1000, -355, 0)
        room.name = "AdminRoom"
    end

    CS.HookManager.Add("onMapGenerationComplete", function(obj)
        PluginAPI.SpawnNetworkedEvent("NewRoundManager") 
        PluginAPI.SpawnNetworkedEvent("NewSupportManager")   
        PluginAPI.SpawnNetworkedEvent("IntercomLoot")   
        PluginAPI.SpawnNetworkedEvent("HC079Loot")  
        PluginAPI.SpawnNetworkedEvent("SCPSwaper")  
        if CS.Config.GetBool("updated_rooms", false) then
            PluginAPI.SpawnNetworkedEvent("AWRoom_event")
        end
    end)
    CS.HookManager.Add("onRoundStart", function(obj)
        PluginAPI.SpawnNetworkedEvent("mrs_RoundTimer") 
        PluginAPI.SpawnNetworkedEvent("Tips") 
        PluginAPI.SpawnNetworkedEvent("SCPHole")

        if GameObject.FindObjectsOfType(typeof(CS.Player)).Length < CS.Config.GetInt("start_round_minimum_players", 2) + 2 then
            PluginAPI.SpawnNetworkedEvent("WaitingPVP")
        end
    end)
end

return Init