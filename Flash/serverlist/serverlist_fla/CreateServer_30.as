package serverlist_fla
{
	import LS_Classes.GameMode;
	import LS_Classes.horizontalList;
	import LS_Classes.scrollList;
	import LS_Classes.textHelpers;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public dynamic class CreateServer_30 extends MovieClip
	{
		public var gmName_txt:TextField;
		public var gmSlot_mc:MovieClip;
		public var peerList_mc:MovieClip;
		public var playerHeader_txt:TextField;
		public var spectatorLabel_txt:TextField;
		public var tabHolder_mc:MovieClip;
		public var teamList_mc:MovieClip;
		public var inviteText:String;
		public var slotList:scrollList;
		public var tabList:horizontalList;
		public var peerList:horizontalList;
		public var joinText:String;
		public var slotDD_array:Array;
		public var isMaster:Boolean;
		public var base:MovieClip;
		public var _maxOpenSlots:Number;
		public var _isHotSeat:Boolean;
		public var gameMode:int;
		
		public function CreateServer_30()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init(gameMode:int, isHotSeat:Boolean, totalSlots:Number = 10) : *
		{
			var slot_mc:PlayerSlot = null;
			this.gameMode = gameMode;
			this._isHotSeat = isHotSeat;
			this.base = parent as MovieClip;
			this.slotDD_array = new Array();
			this.peerList = new horizontalList();
			this.peerList.EL_SPACING = 0;
			this.peerList_mc.addChild(this.peerList);
			this.isMaster = false;
			this.slotList.EL_SPACING = -8;
			var main:MovieClip = (root as MovieClip);
			var i:Number = 0;
			while(i < totalSlots)
			{
				slot_mc = new PlayerSlot();
				this.slotList.addElement(slot_mc,false);
				slot_mc.id = i;
				slot_mc.filled_mc.id = i;
				slot_mc.initialize(main.slot_types,main.strings,this.gameMode);
				slot_mc.canChangeType = i < this._maxOpenSlots;
				slot_mc.isMaster = this.isMaster;
				slot_mc.playerCombo.visible = this.isMaster && this.gameMode == GameMode.Arena;
				slot_mc.teamCombo.visible = false;
				slot_mc.readyButton.visible = !this._isHotSeat;
				i++;
			}
			this.gmSlot_mc.visible = this.gameMode == GameMode.GameMaster;
			this.slotList.positionElements();
		}
		
		public function updatePlayerComboBoxes(param1:Array, param2:Array) : *
		{
			var content_mc:MovieClip = null;
			for each(content_mc in this.slotList.content_array)
			{
				content_mc.updatePlayerCombo(param1,param2);
			}
		}
		
		public function closeAllOpenComboBoxes() : *
		{
			var content_mc:MovieClip = null;
			for each(content_mc in this.slotList.content_array)
			{
				content_mc.playerCombo.dropDown_mc.close();
				content_mc.teamCombo.dropDown_mc.close();
			}
		}
		
		public function set maxOpenSlots(amount:Number) : *
		{
			var content_mc:* = undefined;
			if(this._maxOpenSlots != amount)
			{
				this._maxOpenSlots = amount;
				for(content_mc in this.slotList.content_array)
				{
					this.slotList.content_array[content_mc].canChangeType = content_mc < this._maxOpenSlots;
				}
			}
		}
		
		public function setMasterPlayer(isHost:Boolean) : *
		{
			var slot_mc:PlayerSlot = null;
			var i:uint = 0;
			var peer_mc:MovieClip = null;
			if(this.isMaster != isHost)
			{
				this.isMaster = isHost;
				for each(slot_mc in this.slotList.content_array)
				{
					slot_mc.isMaster = this.isMaster;
				}
				i = 0;
				while(i < this.peerList.length)
				{
					peer_mc = this.peerList.getAt(i);
					if(peer_mc)
					{
						peer_mc.kick_mc.visible = this.isMaster && !peer_mc.localUser;
					}
					i++;
				}
			}
		}
		
		public function addSlotDropDownOptions(param1:String) : *
		{
		}
		
		public function setSlotJoinText(param1:String) : *
		{
			this.joinText = param1;
		}
		
		public function addPeer(id:Number, iggyId:Number, localUser:Boolean, name:String, unused:Boolean = false) : *
		{
			var peer_mc:MovieClip = this.peerList.getElementByNumber("peerId",id);
			if(peer_mc == null)
			{
				peer_mc = new PeerPortrait();
				peer_mc.id = id;
				peer_mc.tooltip = name;
				peer_mc.peerId = id;
				peer_mc.localUser = localUser;
				this.peerList.addElement(peer_mc);
			}
			this.gmName_txt.htmlText = name;
			this.spectatorLabel_txt.width = 10 + this.spectatorLabel_txt.textWidth;
			this.gmName_txt.x = this.spectatorLabel_txt.x + this.spectatorLabel_txt.width;
			textHelpers.capTextFieldWidth(this.gmName_txt,400);
			this.setIggyImage(peer_mc,"s" + iggyId);
		}
		
		public function setPeerAssigned(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.peerList.getElementByNumber("peerId",param1);
			if(val3)
			{
				val3.assigned_mc.visible = param2;
			}
		}
		
		public function removePeer(param1:Number) : *
		{
			var val2:MovieClip = this.peerList.getElementByNumber("peerId",param1);
			if(val2)
			{
				this.peerList.removeElement(val2.list_pos);
			}
		}
		
		public function clearPeers() : *
		{
			this.peerList.clearElements();
		}
		
		public function setPeerAmount(param1:Number) : *
		{
			if(this.peerList.length != param1)
			{
			}
		}
		
		public function addTab(param1:Number, param2:String) : *
		{
			var val3:MovieClip = new Tab();
			val3.disable_mc.visible = false;
			val3.id = param1;
			val3.text_txt.htmlText = param2;
			this.tabList.addElement(val3);
			if(this.tabList.length == 1)
			{
				val3.active_mc.visible = true;
				val3.inactive_mc.visible = false;
			}
			val3.enable();
		}
		
		public function selectTab(param1:Number) : *
		{
			var val2:MovieClip = this.tabList.getElementByNumber("id",param1);
			this.tabList.selectMC(val2);
		}
		
		public function setTabText(param1:Number, param2:String) : *
		{
			var val3:MovieClip = this.tabList.getElementByNumber("id",param1);
			if(val3)
			{
				val3.text_txt.htmlText = param2;
			}
		}
		
		public function setTabEnabled(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.tabList.getElementByNumber("id",param1);
			if(val3)
			{
				val3.disable_mc.visible = !param2;
			}
		}
		
		public function setTabInput(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.tabList.getElementByNumber("id",param1);
			if(val3)
			{
				if(param2)
				{
					val3.enable();
				}
				else
				{
					val3.disable();
				}
			}
		}
		
		public function clearTabs() : *
		{
			this.tabList.clearElements();
		}
		
		public function removeTab(param1:Number) : *
		{
			var val2:MovieClip = this.tabList.getElementByNumber("id",param1);
			if(val2)
			{
				this.tabList.removeElementByListId(val2.list_id);
			}
		}
		
		public function addTeam(param1:Number, param2:String) : *
		{
			var val3:PlayerSlot = null;
			for each(val3 in this.slotList.content_array)
			{
				val3.teamCombo.dropDown_mc.addItem({
					"id":param1,
					"label":textHelpers.toUpperCase(param2)
				});
			}
		}
		
		public function setSlotDisabled(param1:Number) : *
		{
			var val2:PlayerSlot = this.slotList.getAt(param1) as PlayerSlot;
			val2.dismiss();
			val2.playerType = 3;
		}
		
		public function setSlotClient(index:Number, playerType:Number, teamId:Number, title:String, isReady:Boolean, isMine:Boolean) : *
		{
			var slot_mc:PlayerSlot = this.slotList.getAt(index) as PlayerSlot;
			if(slot_mc)
			{
				slot_mc.team = teamId;
				slot_mc.take(title);
				slot_mc.ready = isReady;
				slot_mc.isMine = isMine;
				slot_mc.isAI = playerType == 2;
				slot_mc.isLocalPlayer = playerType == 5;
				slot_mc.playerType = playerType;
				slot_mc.portrait_mc.texture = "p" + index;
			}
		}
		
		public function setSlotName(param1:Number, param2:String) : *
		{
			var val3:PlayerSlot = this.slotList.getAt(param1) as PlayerSlot;
			if(val3)
			{
				val3.setName(param2);
			}
		}
		
		public function setSlotReady(param1:Number, param2:Boolean) : *
		{
			var val3:PlayerSlot = this.slotList.getAt(param1) as PlayerSlot;
			if(val3)
			{
				val3.ready = param2;
			}
		}
		
		public function setSlotEmpty(param1:Number) : *
		{
			var val2:PlayerSlot = this.slotList.getAt(param1) as PlayerSlot;
			val2.dismiss();
			val2.playerType = 0;
		}
		
		public function set isHotSeat(param1:Boolean) : *
		{
			var val2:PlayerSlot = null;
			this._isHotSeat = param1;
			for each(val2 in this.slotList.content_array)
			{
				val2.readyButton.visible = !this._isHotSeat;
			}
		}
		
		public function get isHotSeat() : Boolean
		{
			return this._isHotSeat;
		}
		
		public function setInvitesDisabled(param1:Boolean) : *
		{
			var val2:PlayerSlot = null;
			for each(val2 in this.slotList.content_array)
			{
				val2.invitesDisabled = param1;
			}
		}
		
		public function cancelEditing() : *
		{
			var val1:PlayerSlot = null;
			for each(val1 in this.slotList.content_array)
			{
				if(val1.taken && val1.filled_mc._editing)
				{
					val1.filled_mc.cancelEditing();
				}
			}
		}
		
		public function setIggyImage(param1:MovieClip, param2:String) : *
		{
			var val3:MovieClip = null;
			if(!param1.texture || param1.texture != param2)
			{
				this.removeChildrenOf(param1.icon_mc);
				val3 = new IggyIcon();
				val3.name = "iggy_" + param2;
				param1.icon_mc.addChild(val3);
				param1.texture = param2;
			}
		}
		
		public function removeChildrenOf(param1:MovieClip) : void
		{
			var val2:int = 0;
			if(param1.numChildren != 0)
			{
				val2 = param1.numChildren;
				while(val2 > 0)
				{
					val2--;
					param1.removeChildAt(val2);
				}
			}
		}
		
		public function frame1() : *
		{
			this.inviteText = "";
			this.slotList = new scrollList();
			this.slotList.SB_SPACING = 0;
			this.slotList.TOP_SPACING = 0;
			this.slotList.EL_SPACING = -3;
			this.slotList.SIDE_SPACING = 0;
			this.slotList.x = -12;
			this.slotList.y = 2;
			this.slotList.setFrame(924,478);
			this.slotList.m_scrollbar_mc.m_SCROLLSPEED = 20;
			this.slotList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.slotList.mouseWheelWhenOverEnabled = true;
			this.slotList.m_cyclic = true;
			addChild(this.slotList);
			this.tabList = new horizontalList();
			this.tabHolder_mc.addChild(this.tabList);
			this.gameMode = GameMode.Normal;
		}
	}
}
