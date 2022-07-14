local _ISCLIENT = Ext.IsClient()

MAX_PLAYERS = 10

function GetSettings()
	if Mods.LeaderLib ~= nil then
		local settings = Mods.LeaderLib.SettingsManager.GetMod(ModuleUUID, false)
		if settings then
			return settings
		end
	end
	return nil
end

if not _ISCLIENT then
	local updateUsers = {}

	Ext.RegisterNetListener("LLPARTY_RequestPortraitsUpdate", function(cmd, payload, user)
		if user ~= nil then
			updateUsers[user] = true
		else
			updateUsers[CharacterGetReservedUserID(CharacterGetHostCharacter())] = true
		end
		TimerCancel("Timers_LLPARTY_UpdatePortraits")
		TimerLaunch("Timers_LLPARTY_UpdatePortraits", 250)
	end)
	
	Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(timerName)
		if timerName == "Timers_LLPARTY_UpdatePortraits" then
			for id,b in pairs(updateUsers) do
				Ext.PostMessageToUser(id, "LLPARTY_RepositionPortraits", "")
			end
			updateUsers = {}
		end
	end)
else
	Ext.RegisterNetListener("LLPARTY_RepositionPortraits", function()
		PlayerInfo.RepositionPortraits()
	end)
end

local GetCampaignInfo = function()
	local manager = nil
	if _ISCLIENT then
		manager = Ext.Client.GetModManager()
	else
		manager = Ext.Server.GetModManager()
	end
	if manager and manager.BaseModule then
		return manager.BaseModule.Info
	end
end

local function SetNumPlayers(maxCount)
	maxCount = maxCount or MAX_PLAYERS
	if maxCount then
		local info = GetCampaignInfo()
		if info then
			info.NumPlayers = maxCount
		end
	end
end

Ext.Events.GameStateChanged:Subscribe(function(e)
	if _ISCLIENT then
		if e.ToState == "Menu" then
			SetNumPlayers(MAX_PLAYERS)
		end
	elseif e.FromState == "LoadModule" then
		SetNumPlayers(MAX_PLAYERS)
	end
end)