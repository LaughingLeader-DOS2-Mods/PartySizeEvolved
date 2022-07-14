Ext.RegisterOsirisListener("DB_Origins_MaxPartySize", 1, "after", function(size)
	if size == 4 then
		Osi.DB_Origins_MaxPartySize:Delete(4)
		local settings = GetSettings()
		if settings then
			local partySize = settings.Global:GetVariable("PartySize", MAX_PLAYERS) or MAX_PLAYERS
			Osi.DB_Origins_MaxPartySize(partySize)
		else
			Osi.DB_Origins_MaxPartySize(MAX_PLAYERS)
		end
		GlobalClearFlag("GEN_MaxPlayerCountReached")
	end
end)