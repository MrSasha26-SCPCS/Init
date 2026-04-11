local PluginAPI = CS.Akequ.Plugins.PluginAPI

---@class Init:CS.Akequ.Plugins.PluginInitializator
Init = {}

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
end

function Init:InitServer()
    self:GlobalInit()
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