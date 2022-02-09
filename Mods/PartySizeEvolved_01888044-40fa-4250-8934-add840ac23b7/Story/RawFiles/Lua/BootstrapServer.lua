Ext.Require("Shared.lua")
Ext.Require("Server/PartySize.lua")

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
	if subcmd == "sizetest" then
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		local x,y,z = table.unpack(host.WorldPos)
		for i=0,8 do
			local player = Ext.GetCharacter(CharacterCreateAtPosition(x,y,z, "024d1763-b2aa-46ec-b705-6338059838be", 0))
			--Osi.PROC_GLO_PartyMembers_Add(player.MyGuid, host.MyGuid)
			DebugConfigurePlayer(player.MyGuid, host.ReservedUserID, false)
		end
	elseif subcmd == "addorigins" then
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		for i,entry in pairs(Osi.DB_Origins:Get(nil)) do
			local origin = Ext.GetCharacter(entry[1])
			print(origin.DisplayName, origin.IsPlayer)
			if origin and not origin.IsPlayer then
				TeleportTo(origin.MyGuid, host.MyGuid, "", 1, 0, 1)
				Osi.PROC_GLO_PartyMembers_Add(origin.MyGuid, host.MyGuid)
			end
		end
	end
end)