local ID = {
	playerInfo = 38,
	playerInfo_c = 61,
}

---@class PlayerInfo
---@field Root FlashMainTimeline
local PlayerInfo = {}
setmetatable(PlayerInfo, {
	__index = function(tbl,k)
		if k == "Root" or k == "Instance" then
			local ui = Ext.GetUIByType(ID.playerInfo) or Ext.GetUIByType(ID.playerInfo_c)
			if ui then
				return ui:GetRoot()
			end
		end
	end
})

local function OnAddInfo(ui, event, id, characterHandle, iggyImage, hp, controlled, groupId, pos, equipState, unused, actionFrame, spCurrent, spMax, isAvatar, guiStatus)
	print(event, id, characterHandle, iggyImage, hp, controlled, groupId, pos, equipState, unused, actionFrame, spCurrent, spMax, isAvatar, guiStatus)
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
			end
		end
	end
end

Ext.RegisterUITypeInvokeListener(ID.playerInfo, "addInfo", OnAddInfo)
Ext.RegisterUITypeInvokeListener(ID.playerInfo_c, "addInfo", OnAddInfo)
Ext.RegisterUITypeInvokeListener(ID.playerInfo, "updateDone", OnUpdateDone)
Ext.RegisterUITypeInvokeListener(ID.playerInfo_c, "updateDone", OnUpdateDone)