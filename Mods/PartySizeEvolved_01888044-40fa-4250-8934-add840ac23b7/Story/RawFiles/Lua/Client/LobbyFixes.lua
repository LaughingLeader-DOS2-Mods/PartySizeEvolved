Ext.AddPathOverride("Public/Game/GUI/serverlist.swf", "Public/PartySizeEvolved_01888044-40fa-4250-8934-add840ac23b7/GUI/Overrides/serverlist.swf")
Ext.AddPathOverride("Public/Game/GUI/serverlist_c.swf", "Public/PartySizeEvolved_01888044-40fa-4250-8934-add840ac23b7/GUI/Overrides/serverlist_c.swf")

local addedDropdowns = false

--This adds more slot dropdowns (5-10), then selects 10, which updates the engine's player slot limit
Ext.RegisterUITypeCall(26, "registerAnchorId", function (ui, event)
	if not addedDropdowns then
		local this = ui:GetRoot()
		for i=3,8 do
			this.addFilterDropDownOption(10, i, tostring(i + 2))
		end
		this.selectFilterDropDownEntry(10, 8)
		addedDropdowns = true
	end
end)

-- Ext.RegisterUITypeInvokeListener(26, "setSlotClient", function (ui, event, index, playerType, teamId, title, isReady, isMine)
-- Ext.RegisterUITypeInvokeListener(26, "addFilterDropDownOption", function (ui, event, index, value, label)
-- Ext.RegisterUITypeInvokeListener(26, "selectFilterDropDownEntry", function (ui, event, id, id2)
-- Ext.RegisterUITypeInvokeListener(26, "setHotSeat", function (ui, event, isHotSeat)
-- Ext.RegisterUITypeInvokeListener(26, "setMasterPlayer", function (ui, event, isHost)