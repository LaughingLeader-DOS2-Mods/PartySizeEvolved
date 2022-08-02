Ext.Require("Shared.lua")
Ext.Require("Server/PartySize.lua")
Ext.Require("Server/Patcher.lua")

---@alias OriginsRegions "TUT_Tutorial_A"|"FJ_FortJoy_Main"|"LV_HoE_Main"|"RC_Main"|"CoS_Main"|"ARX_Main"|"ARX_Endgame"



local function DebugConfigurePlayer(uuid, id, makeGlobal)
	if makeGlobal then
		NRD_CharacterSetGlobal(uuid, 1)
	end
	Osi.CharacterMakePlayer(uuid)
	SetTag(uuid,"GENERIC")
	SetTag(uuid,"REALLY_GENERIC")
	SetTag(uuid,"AVATAR")
	Osi.DB_IsPlayer(uuid)
	Osi.ProcRegisterPlayerTriggers(uuid)
	Osi.ProcCharacterDisableAllCrimes(uuid)
	CharacterSetCorpseLootable(uuid, 0)
	if id then
		CharacterAssignToUser(id, uuid)
	end
	SetFaction(uuid, "Hero")
end

--!llparty sizetest
Ext.RegisterConsoleCommand("llparty", function(cmd, subcmd)
	local host = Ext.Entity.GetCharacter(CharacterGetHostCharacter())
	if subcmd == "sizetest" then
		local x,y,z = table.unpack(host.WorldPos)
		for i=0,8 do
			local player = Ext.Entity.GetCharacter(CharacterCreateAtPosition(x,y,z, "024d1763-b2aa-46ec-b705-6338059838be", 0))
			--Osi.PROC_GLO_PartyMembers_Add(player.MyGuid, host.MyGuid)
			DebugConfigurePlayer(player.MyGuid, host.ReservedUserID, false)
		end
	elseif subcmd == "addorigins" then
		for i,entry in pairs(Osi.DB_Origins:Get(nil)) do
			local origin = Ext.Entity.GetCharacter(entry[1])
			if origin and not origin.IsPlayer then
				TeleportTo(origin.MyGuid, host.MyGuid, "", 1, 0, 1)
				Osi.PROC_GLO_PartyMembers_Add(origin.MyGuid, host.MyGuid)
			end
		end
	end
end)