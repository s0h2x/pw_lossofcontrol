local setmetatable = setmetatable;
local ipairs = ipairs;
local type = type;
local select = select;
local tInsert = table.insert;
local tRemove = table.remove;

local private = select(2,...);
private.Timer = {};
private.Timer._version = 3;

local Timer = private.Timer;

local TickerPrototype = {};
local TickerMetatable = {__index = TickerPrototype, __metatable = true};

local waitTable = {};
local secureWaitTable = {};
local waitCombat = {};
local secureWaitCombat = {};

local UnitIsDead = UnitIsDead;
local UnitAffectingCombat = UnitAffectingCombat;
local UIParent = UIParent;

local waitFrame = CreateFrame("Frame", "PrettyTimer", UIParent);
waitFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
waitFrame:RegisterEvent("PLAYER_UNGHOST");
waitFrame:RegisterEvent("PLAYER_ALIVE");

local function RunCallback(ticker)
	ticker._callback(ticker);
end

local function OnUpdate(self, elapsed, tickers)
	local total = #tickers;
	local i = 1;

	while i <= total do
		local ticker = tickers[i];
		if ticker._cancelled then
			tRemove(tickers, i);
			total = total - 1;
		elseif ticker._delay > elapsed then
			ticker._delay = ticker._delay - elapsed;
			i = i + 1;
		else
			securecall(RunCallback, ticker);
			if ticker._remainingIterations == -1 then
				ticker._delay = ticker._duration;
				i = i + 1;
			elseif ticker._remainingIterations > 1 then
				ticker._remainingIterations = ticker._remainingIterations - 1;
				ticker._delay = ticker._duration;
				i = i + 1;
			elseif ticker._remainingIterations == 1 then
				ticker._cancelled = true;
				tRemove(tickers, i);
				total = total - 1;
			end
		end
	end
end

local function OnEvent(event, combatTimers)
	if event == "PLAYER_REGEN_ENABLED" then
		if not UnitIsDead("player") then
			for _, waiter in ipairs(combatTimers) do
				securecall(RunCallback, waiter);
			end
			wipe(combatTimers);
		end
	elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
		if not UnitIsDead("player") and not UnitAffectingCombat("player") or InCombatLockdown() then
			for _, waiter in ipairs(combatTimers) do
				securecall(RunCallback, waiter);
			end
			wipe(combatTimers);
		end
	end
end

waitFrame:SetScript("OnUpdate", function(self, elapsed)
	OnUpdate(self, elapsed, secureWaitTable);
	securecall(OnUpdate, self, elapsed, waitTable);
	
	if #waitTable == 0 and #secureWaitTable == 0 then
		self:Hide();
	end
end);

waitFrame:SetScript("OnEvent", function(self, event)
	OnEvent(event, secureWaitCombat);
	securecall(OnEvent, event, waitCombat);
end);

local function DelayedCall(ticker, oldTicker)
	if oldTicker and type(oldTicker) == "table" then
		ticker = oldTicker;
	end

	if issecure() then
		ticker._secure = true;
		tInsert(secureWaitTable, ticker);
	else
		tInsert(waitTable, ticker);
	end

	waitFrame:Show();
end

local function CreateTicker(duration, callback, iterations)
	local ticker = setmetatable({}, TickerMetatable);
	ticker._remainingIterations = iterations or -1;
	ticker._duration = duration;
	ticker._delay = duration;
	ticker._callback = callback;

	DelayedCall(ticker);

	return ticker;
end

function Timer.NewTimer(duration, callback)
    return CreateTicker(duration, callback, 1);
end

function TickerPrototype:Cancel()
    self._cancelled = true;
end

function private.SetSlashCMD(name, func, ...)
	SlashCmdList[name] = func;
	for i=1, select('#', ...) do
		_G['SLASH_'..name..i] = '/'..select(i, ...);
	end
end