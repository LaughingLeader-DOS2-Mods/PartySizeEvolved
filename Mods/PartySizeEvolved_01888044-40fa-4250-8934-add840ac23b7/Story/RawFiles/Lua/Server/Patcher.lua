Patcher = {
	Listeners = {
		GameStarted = {},
		RegionStarted = {},
		RegionEnded = {},
	}
}

---@param event "GameStarted"|"RegionStarted"|"RegionEnded"
---@param region OriginsRegions
---@param callback fun(region:string)
function Patcher.AddRegionListener(event, region, callback)
	local tbl = Patcher.Listeners[event][region]
	if not tbl then
		tbl = {}
		Patcher.Listeners[event][region] = tbl
	end
	tbl[#tbl+1] = callback
end

Ext.Require("Server/Patches/Tutorial.lua")
Ext.Require("Server/Patches/FortJoy.lua")

local function OnGameStarted(region)
	local tbl = Patcher.Listeners.GameStarted[region]
	if tbl then
		for i=1,#tbl do
			local callback = tbl[i]
			local b,err = xpcall(callback, debug.traceback, region)
			if not b then
				Ext.Utils.PrintError(err)
			end
		end
	end
end

Ext.Osiris.RegisterListener("GameStarted", 2, "after", function (region, isEditor)
	OnGameStarted(region)
end)

Ext.Osiris.RegisterListener("RegionStarted", 1, "after", function (region)
	local tbl = Patcher.Listeners.RegionStarted[region]
	if tbl then
		for i=1,#tbl do
			local callback = tbl[i]
			local b,err = xpcall(callback, debug.traceback, region)
			if not b then
				Ext.Utils.PrintError(err)
			end
		end
	end
end)

Ext.Osiris.RegisterListener("RegionEnded", 1, "after", function (region)
	local tbl = Patcher.Listeners.RegionEnded[region]
	if tbl then
		for i=1,#tbl do
			local callback = tbl[i]
			local b,err = xpcall(callback, debug.traceback, region)
			if not b then
				Ext.Utils.PrintError(err)
			end
		end
	end
end)

Ext.Events.ResetCompleted:Subscribe(function (e)
	local region = Ext.Entity.GetCurrentLevelData().LevelName
	OnGameStarted(region)
end)