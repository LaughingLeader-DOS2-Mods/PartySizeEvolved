--Update global settings when the DB changes from the dialog menu
Ext.Osiris.RegisterListener("DialogEnded", 2, "after", function(dialog, id)
	if dialog == "LLPARTY_SettingsMenu" then
		local db = Osi.DB_LLPARTY_MaxPartySize:Get(nil)
		if db and db[1] and type(db[1][1]) == "number" then
			local amount = db[1][1]
			if MAX_PLAYERS ~= amount then
				MAX_PLAYERS = amount
				Ext.Net.BroadcastMessage("LLPARTY_SetMaxPlayers", tostring(MAX_PLAYERS))
				local settings = GetSettings()
				if settings then
					settings:SetVariable("PartySize", MAX_PLAYERS)
					if Mods.LeaderLib.SaveGlobalSettings then
						Mods.LeaderLib.SaveGlobalSettings()
					end
				end
				SetNumPlayers(MAX_PLAYERS)
			end
		end
	end
end)