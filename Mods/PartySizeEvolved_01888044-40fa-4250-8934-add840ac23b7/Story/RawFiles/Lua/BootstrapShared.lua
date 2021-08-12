function GetSettings()
	if Mods.LeaderLib ~= nil then
		local settings = Mods.LeaderLib.SettingsManager.GetMod(ModuleUUID, false)
		if settings then
			return settings
		end
	end
	return nil
end