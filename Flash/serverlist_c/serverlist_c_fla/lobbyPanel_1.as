package serverlist_c_fla
{
	import LS_Classes.GameMode;
	import LS_Classes.grid;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class lobbyPanel_1 extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var buttonHint_mc:BtnHintContainer;
		public var filters_mc:MovieClip;
		public var gmCampaignPreviewBG_mc:MovieClip;
		public var gmCampaignPreview_mc:MovieClip;
		public var gmHolder_mc:MovieClip;
		public var map_mc:MovieClip;
		public var mutators_bg:MovieClip;
		public var mutators_mc:MovieClip;
		public var playerCount_txt:TextField;
		public var playerHolder_mc:empty;
		public var settings_txt:TextField;
		public var title_txt:TextField;
		public const arenaListPosY:Number = 314;
		public const listPosY:Number = 85;
		public const gmTitlePosY:Number = 50;
		public const titlePosY:Number = 60;
		public var root_mc:MovieClip;
		public var textArray:Array;
		public var slotGrid:grid;
		public var currentElement:MovieClip;
		public var gameMode:int;
		public var _isMaster:Boolean;
		public var _isHotSeat:Boolean;
		public var _userId:Number;
		
		public function lobbyPanel_1()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function get userId() : *
		{
			return this._userId;
		}
		
		public function set userId(param1:Number) : *
		{
			this._userId = param1;
		}
		
		//PartySizeEvolved - Added/Set totalSlots to 10
		public function onInit(totalSlots:uint = 10) : *
		{
			var slot_mc:PlayerSlot = null;
			this.root_mc = root as MovieClip;
			this.gameMode = this.root_mc.gameMode;
			this._isHotSeat = false;
			this.map_mc.visible = this.gameMode == GameMode.Arena;
			this.filters_mc.y = this.gameMode == GameMode.Arena?Number(this.arenaListPosY):Number(this.listPosY);
			this.gmHolder_mc.visible = this.gameMode == GameMode.GameMaster;
			this.title_txt.multiline = this.title_txt.wordWrap = false;
			this.title_txt.autoSize = TextFieldAutoSize.CENTER;
			this.playerCount_txt.multiline = this.playerCount_txt.wordWrap = false;
			this.playerCount_txt.autoSize = TextFieldAutoSize.LEFT;
			this.title_txt.y = this.playerCount_txt.y = this.gameMode == GameMode.GameMaster?Number(this.gmTitlePosY):Number(this.titlePosY);
			this.settings_txt.multiline = this.settings_txt.wordWrap = false;
			this.settings_txt.autoSize = TextFieldAutoSize.CENTER;
			this.gmCampaignPreview_mc.visible = false;
			this.gmCampaignPreviewBG_mc.visible = false;
			this.gmHolder_mc.gamemaster_txt.multiline = this.gmHolder_mc.gamemaster_txt.wordWrap = false;
			this.gmHolder_mc.gamemaster_txt.autoSize = TextFieldAutoSize.LEFT;
			this.gmHolder_mc.portrait_mc.initialize();
			this.gmHolder_mc.portrait_mc.disabled = false;
			this.textArray = new Array(this.settings_txt,this.gmHolder_mc.gamemaster_txt,this.mutators_bg.lbl_txt,null);
			this.filters_mc.onInit(this.onDropDownFilterValueSelected);
			this.filters_mc.isMaster = this._isMaster;
			this.mutators_mc.onInit(this.onDropDownMutatorValueSelected,this.onSliderMutatorValueChanged);
			this.mutators_mc.isMaster = this._isMaster;
			this.mutators_mc.selectable = this.gameMode == GameMode.Arena;
			this.mutators_mc.visible = this.gameMode == GameMode.Arena;
			this.mutators_bg.visible = this.gameMode == GameMode.Arena;
			this.mutators_bg.lbl_txt.multiline = this.settings_txt.wordWrap = false;
			this.mutators_bg.lbl_txt.autoSize = TextFieldAutoSize.CENTER;
			this.slotGrid = new grid();
			this.slotGrid.col = 2;
			this.slotGrid.row = 2;
			this.playerHolder_mc.addChild(this.slotGrid);
			this.slotGrid.EL_SPACING = -4;
			this.slotGrid.ROW_SPACING = -2;
			var i:uint = 0;
			//Swap from root_mc.maxOpenSlots to totalSlots
			//while(i < this.root_mc.maxOpenSlots)
			while(i < totalSlots)
			{
				slot_mc = new PlayerSlot();
				this.slotGrid.addElement(slot_mc,false);
				slot_mc.initialize(i);
				slot_mc.isMaster = this._isMaster;
				slot_mc.isHotSeat = this._isHotSeat;
				slot_mc.selectable = true;
				i++;
			}
			this.slotGrid.positionElements();
			this.currentElement = null;
			this.buttonHint_mc.centerButtons = true;
			this.buttonHint_mc.buttonhintContY = this.buttonHint_mc.y;
			this.buttonHint_mc.centerPanelPosX = 478;
			this.buttonHint_mc.leftPanelPosX = 38;
			this.buttonHint_mc.buttonhintFrameWidth = 880;
			this.buttonHint_mc.bounceTreshHold = 20;
		}

		//PartySizeEvolved - New Addition
		public function addSlot(reposition:Boolean = false) : uint
		{
			var i:uint = this.slotList.length;
			var slot_mc:PlayerSlot = new PlayerSlot();
			this.slotGrid.addElement(slot_mc,false);
			slot_mc.initialize(i);
			slot_mc.isMaster = this._isMaster;
			slot_mc.isHotSeat = this._isHotSeat;
			slot_mc.selectable = true;
			if(reposition) {
				this.slotGrid.positionElements();
			}
			return i;
		}
		
		public function onEventUp(id:Number) : *
		{
			var isHandled:Boolean = false;
			if(this.currentElement != null)
			{
				isHandled = this.currentElement.onEventUp(id);
			}
			return isHandled;
		}
		
		public function onEventDown(id:Number) : *
		{
			var isHandled:Boolean = false;
			if(this.currentElement != null)
			{
				isHandled = this.currentElement.onEventDown(id);
			}
			if(!isHandled && id < this.root_mc.events.length)
			{
				switch(this.root_mc.events[id])
				{
					case "IE UIUp":
						if(this._isMaster)
						{
							this.navigationUp();
						}
						isHandled = true;
						break;
					case "IE UIDown":
						if(this._isMaster)
						{
							this.navigationDown();
						}
						isHandled = true;
						break;
					case "IE UILeft":
						if(this._isMaster)
						{
							this.navigationLeft();
						}
						isHandled = true;
						break;
					case "IE UIRight":
						if(this._isMaster)
						{
							this.navigationRight();
						}
						isHandled = true;
						break;
					case "IE UIShowTooltip":
						if(this._isMaster && !this.isHotSeat)
						{
							ExternalInterface.call("invitePressed");
						}
						else if(this.gameMode == GameMode.GameMaster)
						{
							this.ToggleCampaignDesc();
						}
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						isHandled = true;
						break;
					case "IE UIStartGame":
						if(this._isMaster)
						{
							ExternalInterface.call("startPressed");
							ExternalInterface.call("PlaySound","UI_Gen_BigButton_Click");
						}
						isHandled = true;
						break;
					case "IE ConnectivityMenu":
						if(!this.isHotSeat)
						{
							ExternalInterface.call("showConnectionMenu");
							ExternalInterface.call("PlaySound","UI_Gen_BigButton_Click");
						}
						isHandled = true;
						break;
					case "IE UIAccept":
						if(!this.isHotSeat)
						{
							this.playerReady();
						}
						isHandled = true;
						break;
					case "IE UICancel":
						ExternalInterface.call("PlaySound","UI_Generic_Close");
						ExternalInterface.call("requestCloseUI");
						isHandled = true;
				}
			}
			return isHandled;
		}
		
		public function onDropDownFilterValueSelected(param1:Number, param2:Number, param3:Number) : *
		{
			ExternalInterface.call("filterDDChange",param1,param2,param3);
		}
		
		public function onDropDownMutatorValueSelected(param1:Number, param2:Number, param3:Number) : *
		{
			ExternalInterface.call("mutatorValueChanged",param1,param2,param3);
		}
		
		public function onSliderMutatorValueChanged(param1:Number, param2:Number, param3:Number) : *
		{
			ExternalInterface.call("mutatorValueChanged",param1,param2,param3);
		}
		
		public function addPeer(param1:Number, iggyID:Number, param3:Boolean, name:String, param5:Boolean = false) : *
		{
			this.gmHolder_mc.portrait_mc.texture = "s" + iggyID;
			this.gmHolder_mc.portrait_mc.portraitShown = true;
			this.gmHolder_mc.name_txt.htmlText = name;
			this.gmHolder_mc.gamemaster_txt.width = this.gmHolder_mc.gamemaster_txt.textWidth + 10;
			this.gmHolder_mc.name_txt.width = this.gmHolder_mc.name_txt.textWidth + 10;
			var val6:* = this.gmHolder_mc.gamemaster_txt.width + this.gmHolder_mc.name_txt.width;
			this.gmHolder_mc.gamemaster_txt.x = 478 - val6 / 2;
			this.gmHolder_mc.name_txt.x = this.gmHolder_mc.gamemaster_txt.x + this.gmHolder_mc.gamemaster_txt.width;
		}
		
		public function updateBtnHints(arr:*) : *
		{
			var val3:Number = NaN;
			var val4:String = null;
			this.buttonHint_mc.clearElements();
			var val2:uint = 0;
			while(val2 < arr.length)
			{
				val3 = arr[val2++];
				val4 = arr[val2++];
				this.buttonHint_mc.addBtnHint(val3,val4,val3,200);
			}
		}
		
		public function playerReady() : *
		{
			var player_mc:MovieClip = null;
			if(this.currentElement != this.filters_mc)
			{
				player_mc = this.slotGrid.getCurrentMovieClip();
				if(player_mc && player_mc.taken && player_mc.isMine)
				{
					ExternalInterface.call("PlaySound","UI_Gen_Accept");
					ExternalInterface.call("readyPressed",player_mc.id);
				}
			}
		}
		
		public function setText(textType:Number, text:String) : *
		{
			var slot_mc:MovieClip = null;
			if(textType == 3)
			{
				for each(slot_mc in this.slotGrid.content_array)
				{
					slot_mc.host_mc.setLabel(text);
				}
			}
			else if(this.textArray.length > textType)
			{
				this.textArray[textType].htmlText = text;
			}
		}
		
		public function addFilterDropDown(param1:Number, param2:String) : *
		{
			this.filters_mc.addFilterDropDown(param1,param2);
		}
		
		public function addFilterDropDownOption(param1:Number, param2:Number, param3:String) : *
		{
			this.filters_mc.addFilterDropDownOption(param1,param2,param3);
		}
		
		public function selectFilterDropDownEntry(param1:Number, param2:Number) : *
		{
			this.filters_mc.selectFilterDropDownEntry(param1,param2);
		}
		
		public function setLabelContent(param1:uint, param2:String) : *
		{
			this.filters_mc.setLabelContent(param1,param2);
		}
		
		public function setFilterCheckbox(param1:Number, param2:String, param3:Boolean, param4:Boolean) : *
		{
			this.filters_mc.setFilterCheckbox(param1,param2,param3,param4);
		}
		
		public function addFilterInput(param1:Number, param2:String, param3:String) : *
		{
			this.filters_mc.addFilterInput(param1,param2,param3);
		}
		
		public function setFilterInputText(param1:Number, param2:String) : *
		{
			this.filters_mc.setFilterInputText(param1,param2);
		}
		
		public function setFilterEnabled(param1:Number, param2:Boolean) : *
		{
			this.filters_mc.setFilterEnabled(param1,param2);
		}
		
		public function addFilterNumberbox(param1:Number, param2:String, param3:Number, param4:Number) : *
		{
			this.filters_mc.addFilterNumberbox(param1,param2,param3,param4);
		}
		
		public function setFilterNumberbox(param1:Number, param2:Number, param3:Boolean) : *
		{
			this.filters_mc.setFilterNumberbox(param1,param2,param3);
		}
		
		public function addMutatorDropDown(param1:Number, param2:String) : *
		{
			this.mutators_mc.addFilterDropDown(param1,param2);
		}
		
		public function addMutatorDropDownOption(param1:Number, param2:Number, param3:String) : *
		{
			this.mutators_mc.addFilterDropDownOption(param1,param2,param3);
		}
		
		public function selectMutatorDropDownEntry(param1:Number, param2:Number) : *
		{
			this.mutators_mc.selectFilterDropDownEntry(param1,param2);
		}
		
		public function addMutatorSlider(param1:Number, param2:String, param3:Number, param4:Number, param5:String = "", param6:String = "") : *
		{
			this.mutators_mc.addFilterSlider(param1,param2,param3,param4,param5,param6);
		}
		
		public function setMutatorSliderValue(param1:Number, param2:Number) : *
		{
			this.mutators_mc.setFilterSliderValue(param1,param2);
		}
		
		public function ToggleCampaignDesc() : *
		{
			this.gmCampaignPreview_mc.visible = !this.gmCampaignPreview_mc.visible;
			this.gmCampaignPreviewBG_mc.visible = !this.gmCampaignPreviewBG_mc.visible;
			this.playerHolder_mc.visible = !this.playerHolder_mc.visible;
			this.gmHolder_mc.visible = !this.gmHolder_mc.visible;
			this.title_txt.y = this.playerCount_txt.y = !!this.gmCampaignPreview_mc.visible?Number(this.titlePosY):Number(this.gmTitlePosY);
		}
		
		public function getCurrentSlot() : int
		{
			var slot_mc:MovieClip = null;
			var id:int = -1;
			if(this.currentElement != this.filters_mc && this.currentElement != this.mutators_mc)
			{
				slot_mc = this.currentElement as PlayerSlot;
				if(slot_mc)
				{
					id = slot_mc.id;
				}
			}
			return id;
		}
		
		public function setVoiceChatIcons(index:int, enabled:Boolean) : *
		{
			var slot_mc:PlayerSlot = null;
			if(index >= 0)
			{
				slot_mc = this.slotGrid.getAt(index) as PlayerSlot;
				if(slot_mc)
				{
					slot_mc.setVoiceChat(enabled);
				}
			}
			else
			{
				for each(slot_mc in this.slotGrid.content_array)
				{
					slot_mc.setVoiceChat(enabled);
				}
			}
		}
		
		public function setSlotClient(index:Number, slotType:Number, elementID:Number, slotName:String, isReady:Boolean, isMine:Boolean) : *
		{
			var slot_mc:PlayerSlot = this.slotGrid.getAt(index) as PlayerSlot;
			if(slot_mc)
			{
				switch(slotType)
				{
					case 1:
						slot_mc.setPlayer(slotName,elementID);
						break;
					case 2:
						slot_mc.setAI(slotName,elementID);
						break;
					case 5:
						slot_mc.setLocalPlayer(slotName,elementID);
				}
				if(isMine == true)
				{
					this.root_mc.slotPlayer = index;
				}
				slot_mc.isMine = isMine;
				slot_mc.isMaster = this._isMaster;
				slot_mc.isHotSeat = this._isHotSeat;
				slot_mc.ready = isReady;
				slot_mc.selectable = true;
				slot_mc.updateReadyMC();
				slot_mc.updateTeamMC();
				slot_mc.updateActionMC();
				slot_mc.portrait_mc.texture = "p" + index;
				if(slot_mc.isMine && this.currentElement == null)
				{
					this.slotGrid.clearSelection();
					this.slotGrid.select(index);
					this.currentElement = this.slotGrid.getCurrentMovieClip();
				}
			}
		}
		
		public function setSlotName(index:Number, slotName:String) : *
		{
			var slot_mc:PlayerSlot = this.slotGrid.getAt(index) as PlayerSlot;
			if(slot_mc && slot_mc.taken)
			{
				slot_mc.setSlotName(slotName);
			}
		}
		
		public function setSlotDisabled(index:Number, isDisabled:Boolean, updateName:Boolean) : *
		{
			var slot_mc:PlayerSlot = this.slotGrid.getAt(index) as PlayerSlot;
			if(slot_mc)
			{
				if(updateName)
				{
					if(isDisabled)
					{
						slot_mc.setDisabled();
					}
					else
					{
						slot_mc.setClosed();
					}
					slot_mc.setSlotName(this.root_mc.slot_types[3]);
				}
				slot_mc.selectable = !isDisabled;
			}
		}
		
		public function setSlotReady(index:Number, isReady:Boolean) : *
		{
			var slot_mc:PlayerSlot = this.slotGrid.getAt(index) as PlayerSlot;
			if(slot_mc)
			{
				slot_mc.ready = isReady;
			}
		}
		
		public function addTeam(id:Number, teamName:String) : *
		{
			var slot_mc:MovieClip = null;
			for each(slot_mc in this.slotGrid.content_array)
			{
				slot_mc.team_mc.addElement(id,teamName);
			}
		}
		
		public function addSlotDropDownOptions(param1:String) : *
		{
		}
		
		public function setSlotEmpty(index:Number) : *
		{
			var slot_mc:PlayerSlot = this.slotGrid.getAt(index) as PlayerSlot;
			if(slot_mc)
			{
				slot_mc.setOpen();
				slot_mc.setSlotName(this.root_mc.slot_types[0]);
				slot_mc.selectable = true;
			}
		}
		
		public function get isHotSeat() : Boolean
		{
			return this._isHotSeat;
		}
		
		public function set isHotSeat(enabled:Boolean) : *
		{
			var slot_mc:PlayerSlot = null;
			this._isHotSeat = enabled;
			var i:int = 0;
			while(i < this.slotGrid.length)
			{
				slot_mc = this.slotGrid.getAt(i) as PlayerSlot;
				if(slot_mc)
				{
					slot_mc.isHotSeat = this._isHotSeat;
				}
				i++;
			}
		}
		
		public function get isMaster() : Boolean
		{
			return this._isMaster;
		}
		
		public function set isMaster(enabled:Boolean) : *
		{
			var i:int = 0;
			var slot_mc:PlayerSlot = null;
			if(this._isMaster != enabled)
			{
				this._isMaster = enabled;
				this.filters_mc.isMaster = this._isMaster;
				this.mutators_mc.isMaster = this._isMaster;
				i = 0;
				while(i < this.slotGrid.length)
				{
					slot_mc = this.slotGrid.getAt(i) as PlayerSlot;
					if(slot_mc)
					{
						slot_mc.isMaster = this._isMaster;
					}
					i++;
				}
			}
		}
		
		public function navigationLeft() : *
		{
			if(this.currentElement == this.filters_mc || this.currentElement == this.mutators_mc)
			{
				this.currentElement.deselect();
				this.slotGrid.selectPos(0,1);
				this.currentElement = this.slotGrid.getCurrentMovieClip();
			}
			else
			{
				this.slotGrid.previousCol();
				this.currentElement = this.slotGrid.getCurrentMovieClip();
			}
		}
		
		public function navigationRight() : *
		{
			var cycleSuccess:Boolean = false;
			if(this.currentElement != this.filters_mc && this.currentElement != this.mutators_mc)
			{
				cycleSuccess = this.slotGrid.nextCol();
				if(cycleSuccess && this.currentElement != this.slotGrid.getCurrentMovieClip())
				{
					this.currentElement = this.slotGrid.getCurrentMovieClip();
				}
				else
				{
					this.slotGrid.clearSelection();
					this.currentElement = this.filters_mc;
					this.currentElement.select();
				}
			}
		}
		
		public function navigationUp() : *
		{
			var slot_mc:MovieClip = null;
			if(this.currentElement == this.mutators_mc)
			{
				this.currentElement.deselect();
				this.currentElement = this.filters_mc;
				this.currentElement.select(true);
			}
			else if(this.currentElement != this.filters_mc)
			{
				slot_mc = this.slotGrid.getCurrentMovieClip();
				this.slotGrid.previousRow();
				this.currentElement = this.slotGrid.getCurrentMovieClip();
				if(slot_mc != this.currentElement)
				{
					this.currentElement._list.selectLastElement();
				}
			}
		}
		
		public function navigationDown() : *
		{
			if(this.currentElement == this.filters_mc && this.mutators_mc.selectable)
			{
				this.currentElement.deselect();
				this.currentElement = this.mutators_mc;
				this.currentElement.select();
			}
			else if(this.currentElement != this.filters_mc && this.currentElement != this.mutators_mc)
			{
				this.slotGrid.nextRow();
				this.currentElement = this.slotGrid.getCurrentMovieClip();
			}
		}
		
		private function frame1() : * { }
	}
}
