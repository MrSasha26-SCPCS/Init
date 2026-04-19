local PluginAPI = CS.Akequ.Plugins.PluginAPI
local GameObject = CS.UnityEngine.GameObject
local Config = CS.Config

local function tableLength(t)
    local count = 0
    if t ~= nil then    
        for _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

local function getIndex(tab, val)
    for i, value in ipairs(tab) do
        if value == val then
            return i
        end
    end
    return -1
end

local function removeDublicates(rooms)
    local new_rooms = {}
    local names = {}
    for i = 0, rooms.Length - 1 do
        room = rooms[i]
        if getIndex(names, room.name) == -1 then
            table.insert(names, room.name)
            table.insert(new_rooms, room)
        end
    end
    return new_rooms
end

---@class Init:CS.Akequ.Plugins.PluginInitializator
Init = {}

local function MapGeneratorCallback(zones)
    print("MapGeneratorCallback")

    local lcz_count = Config.GetInt("lcz_4rooms_count", 5)
    local hcz_count = Config.GetInt("hcz_4rooms_count", 7)
    local ez_count = Config.GetInt("ez_4rooms_count", 7)

    local lcz_rooms = zones[0].rooms
    local hcz_rooms = zones[1].rooms
    local ez_rooms = zones[2].rooms

    lcz_rooms = removeDublicates(lcz_rooms)
    for i = 1, #lcz_rooms do
        local room = lcz_rooms[i]
        if room.name == "LC_Room4" then
            room.spawnOnce = true
            for j = 0, lcz_count do
                table.insert(lcz_rooms, room)
            end
            print(room.name .. " dublicated")
            break
        end
    end

    hcz_rooms = removeDublicates(hcz_rooms)
    for i = 1, #hcz_rooms do
        local room = hcz_rooms[i]
        if room.name == "HC_Room4" then
            room.spawnOnce = true
            for j = 0, hcz_count do
                table.insert(hcz_rooms, room)
            end
            print(room.name .. " dublicated")
            break
        end
    end

    ez_rooms = removeDublicates(ez_rooms)
    for i = 1, #ez_rooms do
        local room = ez_rooms[i]
        if room.name == "EZ_Room4" then
            room.spawnOnce = true
            for j = 0, ez_count do
                table.insert(ez_rooms, room)
            end
            print(room.name .. " dublicated")
            break
        end
    end

    zones[0].rooms = lcz_rooms
    zones[1].rooms = hcz_rooms
    zones[2].rooms = ez_rooms

    return zones
end

function Init:GlobalInit()
    PluginAPI.RegisterRoomEvent("mrs_RoundTimer")
    PluginAPI.RegisterRoomEvent("NewRoundManager")
    PluginAPI.RegisterRoomEvent("NewSupportManager")
    PluginAPI.RegisterRoomEvent("IntercomLoot")
    PluginAPI.RegisterRoomEvent("HC079Loot")
    PluginAPI.RegisterRoomEvent("SCPSwaper")
    PluginAPI.RegisterRoomEvent("Tips")

    PluginAPI.RegisterRoomEvent("SCPHole")

    PluginAPI.RegisterPlayerClass("TutorialClass", false)
    PluginAPI.RegisterPlayerClass("SerpentsHand", false)

    PluginAPI.RegisterItem("SCP420JPlus", false, CS.ResourcesManager.GetSprite("inv_item_scp420j"))
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

    PluginAPI.AddPreMapGenerationCallback(MapGeneratorCallback)

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
        
    end)
    CS.HookManager.Add("onRoundStart", function(obj)
        PluginAPI.SpawnNetworkedEvent("mrs_RoundTimer") 
        PluginAPI.SpawnNetworkedEvent("Tips") 

        PluginAPI.SpawnNetworkedEvent("SCPHole")
    end)
end

return Init