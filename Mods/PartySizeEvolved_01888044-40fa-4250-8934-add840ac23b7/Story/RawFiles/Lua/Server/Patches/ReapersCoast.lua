--[[
This is a fix for the RC_DW_Meistr script, where DB_RC_DB_Meistr_Dream only has 4 triggers, and each player is assigned to 1 trigger, making any player after the initial 4 unable to teleport to the dream.

]]


--DB_RC_DB_Meistr_Dream(Trigger, _Portal, _God)
--[[ 
DB_RC_DB_Meistr_Dream((TRIGGERGUID)TRIGGERGUID_S_RC_DW_Meistr_Dream_Arrive1_c451bc1a-4269-4d3b-b26e-e690e0e12b1f,(ITEMGUID)ITEMGUID_S_RC_DW_Meistr_Dream_Portal1_1b653e20-1b67-48d9-8554-55e20f12dbc3,(CHARACTERGUID)S_RC_DW_Meistr_God1_b72eed9a-e178-4e6b-b425-13c177e9a9ae);
DB_RC_DB_Meistr_Dream(TRIGGERGUID_S_RC_DW_Meistr_Dream_Arrive2_a3f32814-386f-417e-937a-7602843020e1,ITEMGUID_S_RC_DW_Meistr_Dream_Portal2_3938eaad-4bad-46c1-987a-d1497051752d,CHARACTERGUID_S_RC_DW_Meistr_God2_8b5641e3-606c-49e9-9e29-59e688049d88);
DB_RC_DB_Meistr_Dream(TRIGGERGUID_S_RC_DW_Meistr_Dream_Arrive3_a50bd114-a1ae-4248-9ec1-92287781c6ce,ITEMGUID_S_RC_DW_Meistr_Dream_Portal3_af329720-37eb-4776-a5c8-b3158103a8ad,CHARACTERGUID_S_RC_DW_Meistr_God3_233040fc-0f84-4c4c-acbe-f9a4cad8ac29);
DB_RC_DB_Meistr_Dream(TRIGGERGUID_S_RC_DW_Meistr_Dream_Arrive4_c8ce6ef2-8f5c-4fbd-8ea4-a0b865fc15fa,ITEMGUID_S_RC_DW_Meistr_Dream_Portal4_f11a1691-8939-463c-a1f3-933463eee64e,CHARACTERGUID_S_RC_DW_Meistr_God4_027f3423-2845-4a61-a506-f0ef4df1f693);
]]

local RC_DreamTriggers = {
	{Trigger="c451bc1a-4269-4d3b-b26e-e690e0e12b1f", Target="b72eed9a-e178-4e6b-b425-13c177e9a9ae", Item="1b653e20-1b67-48d9-8554-55e20f12dbc3"},
	{Trigger="a3f32814-386f-417e-937a-7602843020e1", Target="8b5641e3-606c-49e9-9e29-59e688049d88", Item="3938eaad-4bad-46c1-987a-d1497051752d"},
	{Trigger="a50bd114-a1ae-4248-9ec1-92287781c6ce", Target="233040fc-0f84-4c4c-acbe-f9a4cad8ac29", Item="af329720-37eb-4776-a5c8-b3158103a8ad"},
	{Trigger="c8ce6ef2-8f5c-4fbd-8ea4-a0b865fc15fa", Target="027f3423-2845-4a61-a506-f0ef4df1f693", Item="f11a1691-8939-463c-a1f3-933463eee64e"},
}

---@param guid Guid
local function PlayerIsInDream(guid)
	--TRIGGERGUID_S_RC_DW_Meistr_DreamScene_f206d532-488e-469f-bb2a-5fb4270aa438
	local isInTrigger = Osi.DB_InRegion:Get(guid, "f206d532-488e-469f-bb2a-5fb4270aa438")
	if isInTrigger and isInTrigger[1] then
		return true
	end
	return false
end

local function AnyPlayersInDream()
	for i,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if PlayerIsInDream(GetUUID(entry[1])) then
			return true
		end
	end
	return false
end

local function AssignedPlayerInDream(db)
	for i,entry in pairs(db) do
		if PlayerIsInDream(GetUUID(entry[1])) then
			return true
		end
	end
	return false
end

local function PlayerHasAssignedTrigger(playerGUID)
	local db = Osi.DB_RC_DW_Meistr_Dream_AssignedChamber:Get(playerGUID, nil)
	if db and db[1] then
		return true
	end
	return false
end

---@param playerGuid Guid
---@param trigger Guid
---@param target Guid
local function AddToPointsDB(playerGuid, trigger, target)
	Osi.DB_RC_DW_Meistr_Dream_AssignedChamber(playerGuid, trigger)
	--[[
	The DialogEnded rule checks for DB_RC_DW_Meistr_TeleportToDreamScene(_Player),
	and then DB_RC_DW_Meistr_Dream_AssignedChamber(_Player, _Trigger).
	]]
end

---@param playerGUID Guid
---@param force? boolean
local function ProvideDestination(playerGUID, force)
	if not AnyPlayersInDream() or force then
		local entry = RC_DreamTriggers[Ext.Utils.Random(1,4)]
		AddToPointsDB(playerGUID, entry.Trigger, entry.Target)
		return true
	end
	for i,v in pairs(RC_DreamTriggers) do
		-- DB_RC_DB_Meistr_Dream_Occupied(_Trigger,_Player,_X,_Y,_Z);
		-- DB_RC_DW_Meistr_Dream_AssignedChamber(_Player, _Trigger);
		local db = Osi.DB_RC_DW_Meistr_Dream_AssignedChamber:Get(nil, v.Trigger)
		if not db or db[1] == nil or not AssignedPlayerInDream(db) then -- No assigned player to this god is in the dream
			AddToPointsDB(playerGUID, v.Trigger, v.Target)
			return true
		end
	end
	return false
end

local function IsTeleportingToDream(guid)
	local db = Osi.DB_RC_DW_Meistr_TeleportToDreamScene:Get(guid)
	return db ~= nil and db[1] ~= nil
end

---@param dialog string
---@param inst integer
local function OnDialogEnded(dialog, inst)
	if dialog == "RC_DW_Meistr_Artefact" then
		--Player,Trigger
		local db = Osi.DB_RC_DW_Meistr_Dream_AssignedChamber:Get(nil,nil)
		if db and #db >= 4 then -- 4 players were assigned to all 4 triggers
			local playerGUID = GetUUID(DialogGetInvolvedPlayer(inst, 1)) or ""
			--QuestUpdate_FTJ_Voice_HOEArrive is set when they get teleported, so we don't want to keep teleporting avatars back here.
			if ObjectExists(playerGUID) == 1
			and CharacterIsControlled(playerGUID) == 1 -- Same check as the original script. They don't look for AVATAR
			and IsTeleportingToDream(playerGUID)
			and not PlayerHasAssignedTrigger(playerGUID)
			and not ProvideDestination(playerGUID) then
				OpenMessageBox(playerGUID, "LLPARTY_RC_DreamInUse")
				Osi.ProcObjectTimer(playerGUID, "LLPARTY_RC_CheckForDreamAvailability", 10000)
			end
		end
	end
end

local _registeredListener = false

Patcher.AddRegionListener("GameStarted", "RC_Main", function (region)
	if not _registeredListener then
		Ext.Osiris.RegisterListener("DialogEnded", 2, "before", OnDialogEnded)

		Ext.Osiris.RegisterListener("ProcObjectTimerFinished", 2, "after", function (guid, timerName)
			if timerName == "LLPARTY_RC_CheckForDreamAvailability" then
				local playerGUID = GetUUID(guid)
				if ObjectExists(playerGUID) == 1
				and IsTeleportingToDream(playerGUID)
				and not PlayerIsInDream(playerGUID)
				and not PlayerHasAssignedTrigger(playerGUID)
				then
					--Force teleport as a fallback, though this will transform the related god again
					ProvideDestination(playerGUID, true)
				end
			end
		end)
		_registeredListener = true
	end
end)