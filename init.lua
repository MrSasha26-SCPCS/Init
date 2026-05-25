local PluginAPI = CS.Akequ.Plugins.PluginAPI
local GameObject = CS.UnityEngine.GameObject
local Config = CS.Config

---@class Init:CS.Akequ.Plugins.PluginInitializator
Init = {}

function Init:GlobalInit()
    PluginAPI.RegisterAdminPanel("AAA", "aaa")

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

    PluginAPI.RegisterItem("CS.Akequ.Items.SCP420J", false, CS.ResourcesManager.GetSprite("inv_item_scp420j"))
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
    CS.HookManager.Add("startRound", function(obj)
        if GameObject.FindObjectsOfType(typeof(CS.Player)).Length < CS.Config.GetInt("start_round_minimum_players", 2) + 2 then
            CS.Config.SetConfig("friendly_fire", true)
            PluginAPI.SpawnNetworkedEvent("WaitingPVP")
        end
    end)
end

return Init