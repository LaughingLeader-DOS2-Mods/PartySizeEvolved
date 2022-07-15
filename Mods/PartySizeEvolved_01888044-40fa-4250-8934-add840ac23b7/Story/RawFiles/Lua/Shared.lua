local _ISCLIENT = Ext.IsClient()

MAX_PLAYERS = 10

---@return ModSettings
function GetSettings()
	if Mods.LeaderLib ~= nil then
		local settings = Mods.LeaderLib.SettingsManager.GetMod(ModuleUUID, false, true)
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
	Ext.RegisterNetListener("LLPARTY_SetMaxPlayers", function(cmd, payload)
		local amount = tonumber(payload)
		if amount then
			MAX_PLAYERS = math.ceil(amount)
			SetNumPlayers(MAX_PLAYERS)
		end
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

function TryLoadMultiplayerLimit()
	local b,partySizeSettings = pcall(Ext.IO.LoadFile, "PartySizeEvolved_MultiplayerLimit.json")
	if b and partySizeSettings ~= nil and partySizeSettings ~= "" then
		local settings = Ext.Json.Parse(partySizeSettings)
		if settings and type(settings.Max) == "number" then
			local maxCount = math.ceil(settings.Max)
			MAX_PLAYERS = maxCount
		end
	end
end

function SetNumPlayers(maxCount)
	if not maxCount then
		TryLoadMultiplayerLimit()
		maxCount = MAX_PLAYERS
	end
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
			SetNumPlayers()
		end
	elseif e.FromState == "LoadModule" then
		SetNumPlayers()
	end
end)

Ext.Events.ResetCompleted:Subscribe(function (e)
	SetNumPlayers()
end)

---@param amount integer
local function OnPartySizeChanged(amount)
	if amount > 0 then
		MAX_PLAYERS = amount
		if not _ISCLIENT then
			Osi.DB_LLPARTY_MaxPartySize:Delete(nil)
			Osi.DB_Origins_MaxPartySize:Delete(nil)
			Osi.DB_Origins_MaxPartySize(amount)
			Osi.DB_LLPARTY_MaxPartySize(amount)
			Osi.Proc_CheckPartyFull()
			Osi.LLPARTY_InstallMod()
			Osi.LLPARTY_Settings_UpdateDialogVars()
			GlobalClearFlag("GEN_MaxPlayerCountReached")
		end
	end
end

---@param partySizeVar VariableData
local function RegisterVariableChangedListener(partySizeVar)
	if partySizeVar then
		OnPartySizeChanged(partySizeVar.Value)
		if partySizeVar.Subscribe then
			partySizeVar:Subscribe(function (e)
				OnPartySizeChanged(e.Value)
			end)
		elseif partySizeVar.AddListener then
			partySizeVar:AddListener(function (id, value, data, settings)
				OnPartySizeChanged(value)
			end)
		end
	end
end

Ext.Events.SessionLoaded:Subscribe(function (e)
	if Mods.LeaderLib then
		if Mods.LeaderLib.Events and Mods.LeaderLib.Events.ModSettingsLoaded then
			local index = nil
			index = Mods.LeaderLib.Events.ModSettingsLoaded:Subscribe(function (e)
				RegisterVariableChangedListener(e.Settings.Global.Variables.PartySize)
				Mods.LeaderLib.Events.ModSettingsLoaded:Unsubscribe(index)
			end, {MatchArgs={UUID = ModuleUUID}})
		else
			Ext.OnNextTick(function (e)
				local settings = GetSettings()
				if settings then
					RegisterVariableChangedListener(settings.Global.Variables.PartySize)
				end
			end)
		end
	end
end, {Priority=1000})