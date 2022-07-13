local ID = {
	playerInfo = 38,
	playerInfo_c = 61,
}

---@class PlayerInfo
---@field Instance UIObject
---@field Root FlashMainTimeline
PlayerInfo = {}
setmetatable(PlayerInfo, {
	__index = function(tbl,k)
		if k == "Root" or k == "Instance" then
			local ui = Ext.GetUIByType(ID.playerInfo) or Ext.GetUIByType(ID.playerInfo_c)
			if ui then
				if k == "Root" then
					return ui:GetRoot()
				end
				return ui
			end
		end
	end
})

local function OnAddInfo(ui, event, id, characterHandle, iggyImage, hp, controlled, groupId, pos, equipState, unused, actionFrame, spCurrent, spMax, isAvatar, guiStatus)
	print(event, string.format("id(%s) characterHandle(%s) iggyImage(%s) hp(%s) controlled(%s) groupId(%s) pos(%s) equipState(%s) unused(%s) actionFrame(%s) spCurrent(%s) spMax(%s) isAvatar(%s) guiStatus", id, characterHandle, iggyImage, hp, controlled, groupId, pos, equipState, unused, actionFrame, spCurrent, spMax, isAvatar, guiStatus))
end

local function OnUpdateDone(ui, event)
	local this = PlayerInfo.Root
	if this then
		for i=0,#this.player_array-1 do
			---@type FlashMovieClip
			local playerInfo = this.player_array[i]
			if playerInfo then
				playerInfo.scaleX = 0.5
				playerInfo.scaleY = 0.5
				playerInfo.spacing_mc.height = 0
			end
		end
	end
end

function PlayerInfo.RepositionPortraits(ui, event)
	local this = PlayerInfo.Root
	if this then
		local y = 20
		for i=0,#this.player_array-1 do
			---@type FlashMovieClip
			local playerInfo = this.player_array[i]
			if playerInfo then
				playerInfo.y = y
				y = y + (playerInfo.height * playerInfo.scaleY)
			end
		end
	end
end

Ext.RegisterConsoleCommand("llparty", function(cmd, subcmd)
	if subcmd == "updateui" then
		PlayerInfo.RepositionPortraits()
	end
end)

-- Ext.RegisterUITypeInvokeListener(ID.playerInfo, "addInfo", OnAddInfo)
-- Ext.RegisterUITypeInvokeListener(ID.playerInfo_c, "addInfo", OnAddInfo)
--Ext.RegisterUITypeInvokeListener(ID.playerInfo, "updateDone", OnUpdateDone)
--Ext.RegisterUITypeInvokeListener(ID.playerInfo_c, "updateDone", OnUpdateDone)

-- local function DeferPortraitUpdating(ui, event)
-- 	Ext.PostMessageToServer("LLPARTY_RequestPortraitsUpdate", "")
-- end
-- Ext.RegisterUITypeInvokeListener(ID.playerInfo, "updateInfos", DeferPortraitUpdating)
-- Ext.RegisterUITypeInvokeListener(ID.playerInfo_c, "updateInfos", DeferPortraitUpdating)