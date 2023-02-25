local _ISCLIENT = Ext.IsClient()

MAX_PLAYERS = 10

Utils = {}

---@param asTable boolean|nil if true, a regular table is returned, which needs to be used with pairs/ipairs.
---@return (fun():EsvCharacter|EclCharacter)|table<integer, EsvCharacter|EclCharacter>
function Utils.GetPlayers(asTable)
	local players = {}
	if not _ISCLIENT then
		if Ext.Osiris.IsCallable() then
			for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
				local player = Ext.Entity.GetCharacter(db[1])
				if player then
					players[#players+1] = player
				end
			end
		else
			for _,v in pairs(Ext.Entity.GetAllCharacterGuids()) do
				local character = Ext.Entity.GetCharacter(v)
				if character and character.IsPlayer or character.ReservedUserID > -1 then
					players[#players+1] = character
				end
			end
		end
		if Ext.Utils.GetGameMode() == "GameMaster" then
			local gm = Ext.Entity(CharacterGetHostCharacter())
			if gm then
				local hasGM = false
				for _,v in pairs(players) do
					if v.MyGuid == gm.MyGuid then
						hasGM = true
						break
					end
				end
				if not hasGM then
					players[#players+1] = gm
				end
			end
		end
	else
		local ui = Ext.UI.GetByPath("Public/Game/GUI/playerInfo.swf")
		if ui then
			local this = ui:GetRoot()
			if this then
				for i=0,#this.player_array-1 do
					local player_mc = this.player_array[i]
					if player_mc then
						if not Ext.Math.IsNaN(player_mc.characterHandle) then
							local handle = Ext.UI.DoubleToHandle(player_mc.characterHandle)
							if Ext.Utils.IsValidHandle(handle) then
								players[#players+1] = Ext.Entity.GetCharacter(handle)
							end
						end
					end
				end
			end
		end
	end

	if not asTable then
		local i = 0
		local count = #players
		return function ()
			i = i + 1
			if i <= count then
				return players[i]
			end
		end
	else
		return players
	end
end

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
				Ext.Net.PostMessageToUser(id, "LLPARTY_RepositionPortraits", "")
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

--print(Ext.Server.GetModManager().BaseModule.Info.NumPlayers)
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
			return maxCount
		end
	end
end

function SetNumPlayers(maxCount)
	if not maxCount then
		maxCount = TryLoadMultiplayerLimit()
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

local function _UpdateInternals(amount)
	GlobalClearFlag("GEN_MaxPlayerCountReached")
	Osi.DB_LLPARTY_MaxPartySize:Delete(nil)
	Osi.DB_Origins_MaxPartySize:Delete(nil)
	Osi.DB_Origins_MaxPartySize(amount)
	Osi.DB_LLPARTY_MaxPartySize(amount)
	Osi.Proc_CheckPartyFull()
	Osi.LLPARTY_InstallMod()
	Osi.LLPARTY_Settings_UpdateDialogVars()
end

---@param amount integer
local function OnPartySizeChanged(amount)
	if amount > 0 then
		MAX_PLAYERS = amount
		SetNumPlayers(MAX_PLAYERS)
		if not _ISCLIENT then
			if Ext.Osiris.IsCallable() then
				_UpdateInternals(amount)
			else
				Ext.OnNextTick(function (e)
					if Ext.Osiris.IsCallable() then
						_UpdateInternals(amount)
					end
				end)
			end
		else
			UpdateLobby()
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
end, {Priority=1})