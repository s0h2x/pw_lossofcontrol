--- copyright; Blizzard Entertainment // BlizzardInterfaceCode /
-- /@ loss of control; // s0h2x, pretty_wow @/

local select = select;
local unpack = unpack;
local next = next;
local pairs = pairs;
local tInsert = table.insert;
local tWipe = table.wipe;
local max = math.max;

local private = select(2,...);
local Timer = private.Timer;
local RegisterCMD = private.SetSlashCMD;
local PlaySound = PlaySound;
local GetTime = GetTime;
local UnitAura = UnitAura;
local UnitAffectingCombat = UnitAffectingCombat;
local GetSchoolString = GetSchoolString;

local MECHANIC_CHARM			= 1;
local MECHANIC_DISORIENTED      = 2;
local MECHANIC_DISARM           = 3;
local MECHANIC_DISTRACT         = 4;
local MECHANIC_FEAR             = 5;
local MECHANIC_GRIP             = 6;
local MECHANIC_ROOT             = 7;
local MECHANIC_SLOW_ATTACK      = 8;
local MECHANIC_SILENCE          = 9;
local MECHANIC_SLEEP            = 10;
local MECHANIC_SNARE            = 11;
local MECHANIC_STUN             = 12;
local MECHANIC_FREEZE           = 13;
local MECHANIC_KNOCKOUT         = 14;
local MECHANIC_BLEED            = 15;
local MECHANIC_BANDAGE          = 16;
local MECHANIC_POLYMORPH        = 17;
local MECHANIC_BANISH           = 18;
local MECHANIC_SHIELD           = 19;
local MECHANIC_SHACKLE          = 20;
local MECHANIC_MOUNT            = 21;
local MECHANIC_INFECTED         = 22;
local MECHANIC_TURN             = 23;
local MECHANIC_HORROR           = 24;
local MECHANIC_INVULNERABILITY  = 25;
local MECHANIC_INTERRUPT        = 26;
local MECHANIC_DAZE             = 27;
local MECHANIC_DISCOVERY        = 28;
local MECHANIC_IMMUNE_SHIELD    = 29;
local MECHANIC_SAPPED           = 30;
local MECHANIC_ENRAGED          = 31;

local TEXT_OVERRIDE = {
	[33786] = LOSS_OF_CONTROL_DISPLAY_CYCLONE
};
local TIME_LEFT_FRAME_WIDTH = 200;
local LOSS_OF_CONTROL_TIME_OFFSET = 6;
local DISPLAY_TYPE_FULL = 2;
local DISPLAY_TYPE_ALERT = 1;
local DISPLAY_TYPE_NONE = 0;
local ACTIVE_INDEX = 1;
local LOC_DATA = private.LOSS_OF_CONTROL_SPELL_DATA;
local C_MSG = "|cff00b5ff[LoC]:|r "..MSG_CHAT_RESET;

-- animation
local function LossOfControlFrame_AnimPlay(self)
	self.RedLineTop.Anim:Play();
	self.RedLineBottom.Anim:Play();
	self.Icon.Anim:Play();
end

local function LossOfControlFrame_AnimStop(self)
	self.RedLineTop.Anim:Play();
	self.RedLineBottom.Anim:Play();
	self.Icon.Anim:Play();
end

local function LossOfControlFrame_AnimIsPlaying(self)
	local isPlaying = false;
	if self.RedLineTop.Anim:IsPlaying() then
		isPlaying = true;
	end
	if self.RedLineBottom.Anim:IsPlaying() then
		isPlaying = true;
	end
	if self.Icon.Anim:IsPlaying() then
		isPlaying = true;
	end
	return isPlaying;
end

local LOCMechanicData = {
    [MECHANIC_CHARM]            = {LOCALE_SPELL_MECHANIC_CHARM, 8},
    [MECHANIC_DISORIENTED]      = {LOCALE_SPELL_MECHANIC_DISORIENTED, 5},
    [MECHANIC_DISARM]           = {LOCALE_SPELL_MECHANIC_DISARM, 2},
    [MECHANIC_DISTRACT]         = {LOCALE_SPELL_MECHANIC_DISTRACT, 0},
    [MECHANIC_FEAR]             = {LOCALE_SPELL_MECHANIC_FEAR, 6},
    [MECHANIC_GRIP]             = {LOCALE_SPELL_MECHANIC_GRIP, 0},
    [MECHANIC_ROOT]             = {LOCALE_SPELL_MECHANIC_ROOT, 1},
    [MECHANIC_SLOW_ATTACK]      = {LOCALE_SPELL_MECHANIC_SLOW_ATTACK, 0},
    [MECHANIC_SILENCE]          = {LOCALE_SPELL_MECHANIC_SILENCE, 4},
    [MECHANIC_SLEEP]            = {LOCALE_SPELL_MECHANIC_SLEEP, 4},
    [MECHANIC_SNARE]            = {LOCALE_SPELL_MECHANIC_SNARE, 0},
    [MECHANIC_STUN]             = {LOCALE_SPELL_MECHANIC_STUN, 7},
    [MECHANIC_FREEZE]           = {LOCALE_SPELL_MECHANIC_FREEZE, 7},
    [MECHANIC_KNOCKOUT]         = {LOCALE_SPELL_MECHANIC_KNOCKOUT, 7},
    [MECHANIC_BLEED]            = {LOCALE_SPELL_MECHANIC_BLEED, 0},
    [MECHANIC_BANDAGE]          = {LOCALE_SPELL_MECHANIC_BANDAGE, 0},
    [MECHANIC_POLYMORPH]        = {LOCALE_SPELL_MECHANIC_POLYMORPH, 5},
    [MECHANIC_BANISH]           = {LOCALE_SPELL_MECHANIC_BANISH, 1},
    [MECHANIC_SHIELD]           = {LOCALE_SPELL_MECHANIC_SHIELD, 0},
    [MECHANIC_SHACKLE]          = {LOCALE_SPELL_MECHANIC_SHACKLE, 1},
    [MECHANIC_MOUNT]            = {LOCALE_SPELL_MECHANIC_MOUNT, 0},
    [MECHANIC_INFECTED]         = {LOCALE_SPELL_MECHANIC_INFECTED, 0},
    [MECHANIC_TURN]             = {LOCALE_SPELL_MECHANIC_TURN, 6},
    [MECHANIC_HORROR]           = {LOCALE_SPELL_MECHANIC_HORROR, 6},
    [MECHANIC_INVULNERABILITY]  = {LOCALE_SPELL_MECHANIC_INVULNERABILITY, 0},
    [MECHANIC_INTERRUPT]        = {LOCALE_SPELL_MECHANIC_INTERRUPT, 0},
    [MECHANIC_DAZE]             = {LOCALE_SPELL_MECHANIC_DAZE, 0},
    [MECHANIC_DISCOVERY]        = {LOCALE_SPELL_MECHANIC_DISCOVERY, 0},
    [MECHANIC_IMMUNE_SHIELD]    = {LOCALE_SPELL_MECHANIC_IMMUNE_SHIELD, 0},
    [MECHANIC_SAPPED]           = {LOCALE_SPELL_MECHANIC_SAPPED, 7},
    [MECHANIC_ENRAGED]          = {LOCALE_SPELL_MECHANIC_ENRAGED, 0},
};

local lossOfControlData = {};
local tempLossOfControlData = {};

function LossOfControlFrame_OnLoad(self)
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("VARIABLES_LOADED");

	self.AnimPlay = LossOfControlFrame_AnimPlay;
	self.AnimStop = LossOfControlFrame_AnimStop;
	self.AnimIsPlaying = LossOfControlFrame_AnimIsPlaying;

	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth();

	LossOfControlFrame_OnEvent(self, "UNIT_AURA", "player");
end

local function LossOfControlFrame_UpdateData()
	lossOfControlData = {};
	
	for _, spellData in pairs(tempLossOfControlData) do
		tInsert(lossOfControlData, spellData);
	end

	local self = LossOfControlFrame;
	local eventIndex = #lossOfControlData;
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(eventIndex);
	local isEnable = true;
	
	if isEnable and isEnable == 0 then return; end
	if displayType == DISPLAY_TYPE_ALERT then
		if (not self:IsShown() or priority > self.priority or (priority == self.priority and timeRemaining and (not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining))) then
			LossOfControlFrame_SetUpDisplay(self, true, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType);
		end
		return;
	end
	if eventIndex == ACTIVE_INDEX then
		self.fadeTime = nil;
		LossOfControlFrame_SetUpDisplay(self, true);
	end
end

function LossOfControlGetEventInfo(index)
	if not index then
		return nil;
	end
	
	local data = lossOfControlData[index];
	if not data then
		return nil;
	end

	local locType 		= data.locType;
	local spellID 		= data.spellID;
	local text 			= data.text;
	local iconTexture 	= data.iconTexture;
	local startTime 	= data.startTime;
	local timeRemaining = data.expirationTime ~= 0 and data.expirationTime - GetTime() or nil;
	local duration 		= data.duration;
	local lockoutSchool = "lockoutSchool";
	local priority 		= data.priority;
	local displayType 	= data.displayType;

	return locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType;
end

local function LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime)
	local LOCSpellMechanic = LOC_DATA[spellID];
	if LOCSpellMechanic then
		local startTime = GetTime();
		local priority = LOCMechanicData[LOCSpellMechanic][2] or 0;
		local text = LOCMechanicData[LOCSpellMechanic][1] or name;

		tempLossOfControlData[spellID] = {
			locType 		= LOCSpellMechanic,
			spellID 		= spellID,
			text 			= text,
			name 			= name,
			iconTexture 	= icon,
			startTime 		= startTime,
			duration 		= duration,
			priority 		= priority,
			expirationTime  = expirationTime,
			displayType 	= DISPLAY_TYPE_FULL
		};
		LossOfControlFrame_UpdateData();
	end
end

local function LossOfControlRemoveDebuff(spellID)
	tempLossOfControlData[spellID] = nil;
	LossOfControlFrame_UpdateData();
end

local auraTrackerStorage = {};
function LossOfControlFrame_OnEvent(self, event, unit)
	if event == "UNIT_AURA" and unit == "player" then
		for i=1, 40 do
			local name, _, icon, _, _, duration, expirationTime, _, _, _, spellID = UnitAura("player", i, "HARMFUL");
			if name and spellID then
				local hasAura = auraTrackerStorage[spellID] and auraTrackerStorage[spellID][1];
				if hasAura == nil then
					LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime);
				else
					local saveDuration = auraTrackerStorage[spellID][2] - GetTime();
					local newBuffDuation = expirationTime - GetTime();

					if newBuffDuation > saveDuration then
						LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime);
					end
				end
				auraTrackerStorage[spellID] = {false, expirationTime};
			end
		end

		for spellID, auraData in pairs(auraTrackerStorage) do
			if not auraData[1] then
				auraTrackerStorage[spellID][1] = true;
			else
				LossOfControlRemoveDebuff(spellID);
				auraTrackerStorage[spellID] = nil;
			end
		end
	end
	
	if event == "VARIABLES_LOADED" then
		if not LosOfControl then
			LosOfControl = {};
		end
		
		if LosOfControl.position ~= nil then
			local point, relativePoint, offsetx, offsety = unpack(LosOfControl.position);
			self:ClearAllPoints();
			self:SetPoint(point, "UIParent", relativePoint, offsetx, offsety);
		end
		
		if LosOfControl.scale ~= nil then
			self:SetScale(LosOfControl.scale);
		end
	end
end

function LossOfControlFrame_OnUpdate(self, elapsed)
	if self.unlocked and UnitAffectingCombat("player") then
		LossOfControlFrame_Lock(self);
		return;
	end
	
	-- handle alert type
	if self.fadeTime then
		self.fadeTime = self.fadeTime - elapsed
		self:SetAlpha(max(self.fadeTime*2, 0.0))
		if (self.fadeTime < 0) then
			self:Hide();
		else
			-- no need to do any other work
			return;
		end
	else
		self:SetAlpha(1.0);
	end
	LossOfControlFrame_UpdateDisplay(self);
end

function LossOfControlFrame_OnHide(self)
	self.fadeTime = nil;
	self.priority = nil;
end

function LossOfControlFrame_SetUpDisplay(self, animate, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
	if not locType then
		locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX);
	end
	if (text and displayType ~= DISPLAY_TYPE_NONE) then
		text = TEXT_OVERRIDE[spellID] or text;
		if (locType == "SCHOOL_INTERRUPT") then
			-- replace text with school-specific lockout text
			if (lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, GetSchoolString(lockoutSchool));
			end
		end
		self.AbilityName:SetText(text);
		self.Icon:SetTexture(iconTexture);
		
		local timeLeftFrame = self.TimeLeft;
		if (displayType == DISPLAY_TYPE_ALERT) then
			timeRemaining = duration;
			-- CooldownFrame_Clear(self.Cooldown);
			-- print("displayType = 1")
		elseif (not startTime) then
			-- CooldownFrame_Clear(self.Cooldown);
			-- print("not startTime")
		else
			CooldownFrame_SetTimer(self.Cooldown, startTime, duration, 1);
		end
		LossOfControlSetTimeLeft(timeLeftFrame, timeRemaining);
		-- align stuff
		local abilityWidth = self.AbilityName:GetWidth();
		local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth));
		local xOffset = (abilityWidth - longestTextWidth) / 2 + 27;
		self.AbilityName:SetPoint("CENTER", xOffset, 11);
		self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0);
		
		-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
		xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2;
		timeLeftFrame:SetPoint("CENTER", xOffset, -12);

		if (animate) then
			if (displayType == DISPLAY_TYPE_ALERT) then
				self.fadeTime = 1.5;
			end
			self:AnimStop();
			self.AbilityName.scrollTime = 0;
			self.TimeLeft.NumberText.scrollTime = 0;
			self.TimeLeft.SecondsText.scrollTime = 0;
			self.Cooldown:Hide();
			self:AnimPlay();
			PlaySound(34468);
		end
		self.priority = priority;
		self.spellID = spellID;
		self.startTime = startTime;
		self:Show();
	end
end

function LossOfControlFrame_UpdateDisplay(self)
	-- if displaying an alert, wait for it to go away on its own
	if self.fadeTime then return; end

	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX);
	if (text and displayType == DISPLAY_TYPE_FULL) then
		if (spellID ~= self.spellID or startTime ~= self.startTime) then
			LossOfControlFrame_SetUpDisplay(self, false, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType);
		end
		if (not self:AnimIsPlaying() and startTime) then
			CooldownFrame_SetTimer(self.Cooldown, startTime, duration, 1);
		end
		LossOfControlSetTimeLeft(self.TimeLeft, timeRemaining);
	else
		self:Hide();
	end
end

function LossOfControlSetTimeLeft(self, timeRemaining)
	if timeRemaining then
		if (timeRemaining >= 10) then
			self.NumberText:SetFormattedText("%d", timeRemaining);
		elseif (timeRemaining < 9.95) then
			self.NumberText:SetFormattedText("%.1F", timeRemaining);
		end
		if (timeRemaining > 0) then
			self:Show();
		else
			self:Hide();
		end
		
		self.timeRemaining = timeRemaining;
		self.numberWidth = self.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	else
		self:Hide();
		self.numberWidth = 0;
	end
end

local function LossOfControlFrame_Unlock(self)
	self:EnableMouse(true);
	self:EnableMouseWheel(true);
	self:RegisterForDrag("LeftButton");
	self.unlocked = true;

	local timer = Timer.NewTimer(10, function()
		LossOfControlFrame_Lock(self);
	end)

	tempLossOfControlData["UNLOCK"] = {
		locType 		= LOCALE_SPELL_MECHANIC_DAZE,
		spellID 		= 692,
		text			= DRAG_TO_MOVE_SCROLL_TO_SIZE,
		name 			= "UNLOCK",
		iconTexture		= "Interface\\ICONS\\Spell_Frost_Stun",
		startTime 		= GetTime(),
		duration		= 10,
		priority 		= 100,
		expirationTime 	= GetTime() + 10,
		displayType		= DISPLAY_TYPE_FULL,
		timer 			= timer
	};

	self:SetScript("OnDragStart", function(self)
		self:StartMoving();
		self:SetUserPlaced(false);
		local data = tempLossOfControlData["UNLOCK"];

		if data.timer then
			data.timer:Cancel();
			data.timer = nil;
		end

		data.duration = 0;
		data.startTime = 0;
		data.expirationTime = 0;

		LossOfControlFrame_UpdateDisplay(self);
	end);

	self:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing();
		local data = tempLossOfControlData["UNLOCK"];

		if data.timer then
			data.timer:Cancel();
			data.timer = nil;
		end

		local timer = Timer.NewTimer(10, function()
			LossOfControlFrame_Lock(self);
		end);

		data.timer = timer;

		data.duration = 10;
		data.startTime = GetTime();
		data.expirationTime = GetTime() + data.duration;
		
		LossOfControlFrame_UpdateDisplay(self);
	end);

	self:SetScript("OnMouseWheel", function(self, value)
		if value ~= 0 then
			local scale = self:GetScale();
			if value > 0 then
				self:SetScale(scale + 0.05);
			elseif value < 0 then
				self:SetScale(scale - 0.05);
			end

			local data = tempLossOfControlData["UNLOCK"];

			if data.timer then
				data.timer:Cancel();
				data.timer = nil;
			end

			local timer = Timer.NewTimer(10, function()
				LossOfControlFrame_Lock(self);
			end);

			data.timer = timer;

			data.duration = 10;
			data.startTime = GetTime();
			data.expirationTime = GetTime() + data.duration;

			LossOfControlFrame_UpdateDisplay(self);
		end
	end);

	local data = tempLossOfControlData["UNLOCK"];
	LossOfControlAddOrUpdateDebuff(data.spellID, data.name, data.iconTexture, data.duration, data.expirationTime);
	LossOfControlFrame_UpdateDisplay(self);
end

function LossOfControlFrame_Lock(self)
	self:EnableMouse(false);
	self:EnableMouseWheel(false);
	self:RegisterForDrag();
	self.unlocked = nil;

	if tempLossOfControlData["UNLOCK"] then
		local data = tempLossOfControlData["UNLOCK"];
		if data.timer then
			data.timer:Cancel();
			data.timer = nil;
		end
	end

	tempLossOfControlData["UNLOCK"] = nil;
	if self.spellID == 692 then
		self.spellID = nil;
	end
	LossOfControlRemoveDebuff(692);
	
	local point, _, relativePoint, offsetX, offsetY = self:GetPoint();
	LosOfControl = {
		position = { point, relativePoint, offsetX, offsetY };
		scale = self:GetScale();
	};
	
	self:SetScript("OnDragStart", nil);
	self:SetScript("OnDragStop", nil);
	self:SetScript("OnMouseWheel", nil);
end

local function ResetPositionAndSize(self)
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
	self:SetScale(1);

	tWipe(LosOfControl);
end

RegisterCMD("LOC", function() LossOfControlFrame_Unlock(LossOfControlFrame); end, "loc");
RegisterCMD("LOC1", function() ResetPositionAndSize(LossOfControlFrame); print(C_MSG); end, "locreset");