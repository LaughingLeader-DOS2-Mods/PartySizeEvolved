function GetSettings()
	if Mods.LeaderLib ~= nil then
		local settings = Mods.LeaderLib.SettingsManager.GetMod(ModuleUUID, false)
		if settings then
			return settings
		end
	end
	return nil
end

local isClient = Ext.IsClient()

if not isClient then
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
	
	Ext.RegisterOsirisListener("TimerFinished", 1, "after", function(timerName)
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

if Ext.Version() >= 56 then
	local _getBaseInfo = function()
		local manager = nil
		if isClient then
			manager = Ext.Client.GetModManager()
		else
			manager = Ext.Server.GetModManager()
		end
		if manager and manager.BaseModule then
			return manager.BaseModule.Info
		end
	end

	local function SetNumPlayers(maxCount)
		local info = _getBaseInfo()
		if info then
			info.NumPlayers = maxCount or 10
		end
	end

	Ext.RegisterListener("GameStateChanged", function (lastState, nextState)
		if isClient then
			if nextState == "Menu" then
				SetNumPlayers(10)
			end
		elseif lastState == "LoadModule" then
			SetNumPlayers(10)
		end
	end)
end