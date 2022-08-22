--[[
This is a fix for the fact that DB_FTJ_HoE_ToPoints only has 4 entries,
and each entry is removed when it's used, preventing any further avatars from teleporting to the Hall of Echoes.

All this does is add an extra entry to DB_FTJ_HoE_ToPoints if an avatar is trying to use the shrine and the DB is empty.
]]


--HoE Trigger, God Ghost
--DB_FTJ_HoE_ToPoints(_Trigger, _Ghost)

local FTJ_HoE_ToPoints = {
	--S_FTJ_SW_TowerShrineHoE_Point_c1f62b46-38c9-43e2-a52e-048726c60076 => S_FTJ_SW_Lucian_TowerShrine_011c4afd-38a9-4412-b6b5-e497ed7704cc
	{Trigger = "c1f62b46-38c9-43e2-a52e-048726c60076", Target = "011c4afd-38a9-4412-b6b5-e497ed7704cc"},
	--S_FTJ_SW_ShelterShrineHoE_Point_bd705640-26aa-4102-85a6-f2d3ac94d831 => S_FTJ_SW_Lucian_ShelterShrine_7555e91b-7184-4fb5-98a5-cc02fa6a235b
	{Trigger = "bd705640-26aa-4102-85a6-f2d3ac94d831", Target = "7555e91b-7184-4fb5-98a5-cc02fa6a235b"},
	--S_FTJ_SW_VoidwokenShrineHoE_Point_8df25722-6724-4fa5-9d0e-a4e93d378cb0 => S_FTJ_SW_Lucian_VoidwokenShrine_c99ea947-1920-4c3c-8253-858796869544
	{Trigger = "8df25722-6724-4fa5-9d0e-a4e93d378cb0", Target = "c99ea947-1920-4c3c-8253-858796869544"},
	--S_FTJ_SW_GarethShrineHoE_Point_f4a1e725-effe-4a82-89c4-c92c47f1643a => S_FTJ_SW_Lucian_GarethStatue_295b92ad-fd83-4e50-b1d5-f6fbf76e4a04
	{Trigger = "f4a1e725-effe-4a82-89c4-c92c47f1643a", Target = "295b92ad-fd83-4e50-b1d5-f6fbf76e4a04"},
}

---@param guid UUID
local function PlayerIsInHoE(guid)
	--S_FTJ_SW_SUB_HallOfEchoes_3451f5d3-5b43-49d7-876b-82f5b7c9b65d
	local isInTrigger = Osi.DB_InRegion:Get(guid, "3451f5d3-5b43-49d7-876b-82f5b7c9b65d")
	if isInTrigger and isInTrigger[1] then
		return true
	end
	return false
end

local function AnyPlayersInHoE()
	for i,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if PlayerIsInHoE(GetUUID(entry[1])) then
			return true
		end
	end
	return false
end

local function AssignedPlayerInHOE(db)
	for i,entry in pairs(db) do
		if PlayerIsInHoE(GetUUID(entry[1])) then
			return true
		end
	end
	return false
end

local function AddToPointsDB(trigger, target)
	Osi.DB_FTJ_HoE_ReturnPoints:Delete(nil, trigger, nil, target) -- Clear previous players
	-- The DB_FTJ_HoE_ReturnPoints database event checks if they have a dialog before transforming. Need to delete the previous dialog set
	Osi.ProcRemoveAllDialogEntriesForSpeaker(target)
	--Finally add to the DB the DialogEnded rule needs
	Osi.DB_FTJ_HoE_ToPoints(trigger, target)
end

local function ProvideAvatarDestination()
	if not AnyPlayersInHoE() then
		local entry = FTJ_HoE_ToPoints[Ext.Random(1,4)]
		AddToPointsDB(entry.Trigger, entry.Target)
		return true
	end
	for i,v in pairs(FTJ_HoE_ToPoints) do
		-- DB_FTJ_HoE_ReturnPoints(_Player,_HoETrigger,_ReturnTrigger,_God);
		local db = Osi.DB_FTJ_HoE_ReturnPoints:Get(nil, v.Trigger, nil, v.Target)
		if not db or db[1] == nil or not AssignedPlayerInHOE(db) then -- No assigned player to this god is in HoE
			AddToPointsDB(v.Trigger, v.Target)
			return true
		end
	end
	return false
end

---@param dialog string
---@param inst integer
local function OnDialogEnded(dialog, inst)
	if dialog == "FTJ_SW_HoEStatue_001" or dialog == "FTJ_SW_HoEStatue_002" or dialog == "FTJ_SW_HoEStatue_003" then
		local db = Osi.DB_FTJ_HoE_ToPoints:Get(nil,nil)
		if not db or db[1] == nil or db[1][1] == nil then
			local playerGUID = DialogGetInvolvedPlayer(inst, 1) or ""
			--QuestUpdate_FTJ_Voice_HOEArrive is set when they get teleported, so we don't want to keep teleporting avatars back here.
			if ObjectExists(playerGUID) == 1
			and ObjectGetFlag(playerGUID, "FTJ_SW_HoEReturnToShrine") == 0
			and IsTagged(playerGUID, "AVATAR") == 1 then
				if not ProvideAvatarDestination() then
					OpenMessageBox(playerGUID, "LLPARTY_FTJ_HallOfEchoesInUse")
					ObjectClearFlag(playerGUID, "FTJ_SW_ShrineSendToHoE", 0) -- Clear so the dialog repeats the previous lines again
				end
			end
		end
	end
end

local _registeredListener = false

Patcher.AddRegionListener("GameStarted", "FJ_FortJoy_Main", function (region)
	if not _registeredListener then
		Ext.Osiris.RegisterListener("DialogEnded", 2, "before", OnDialogEnded)
		_registeredListener = true
	end
end)