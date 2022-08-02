local function ShouldFixFreezeBug()
	local count = 0
	--This checks for counter == total players, but the counter will only go up to 4
	local db = Osi.DB_GlobalCounter:Get("TUT_PlayersWokenUp", nil)
	if db and db[1] and db[1][2] then
		count = db[1][2]
	end
	local playerCount = #Osi.DB_IsPlayer:Get(nil)
	if count >= 4 and playerCount > 4 then
		return true
	end
	return false
end

-- Tutorial 4 Player limitations
Ext.Osiris.RegisterListener("Proc_TUT_CheckPlayersWokenUp", 1, "after", function (guid)
	if ShouldFixFreezeBug() then
		Ext.Utils.Print("[PartySizeEvolved:Proc_TUT_CheckPlayersWokenUp] Fixing a story freeze issue in the tutorial. Unfreezing all players.")
		Osi.Proc_TUT_UnfreezePlayers()
	end
end)

Patcher.AddRegionListener("GameStarted", "TUT_Tutorial_A", function (region)
	if ShouldFixFreezeBug() then
		local hasFreeze = false
		for player in Utils.GetPlayers() do
			if player:GetStatus("STORY_FROZEN") then
				hasFreeze = true
				break
			end
		end
		if hasFreeze then
			Ext.Utils.Print("[PartySizeEvolved:GameStarted] Fixing a story freeze issue in the tutorial. Unfreezing all players.")
			Osi.Proc_TUT_UnfreezePlayers()
		end
	end
end)