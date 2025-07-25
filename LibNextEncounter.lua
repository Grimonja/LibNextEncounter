local MAJOR, MINOR = "LibNextEncounter", 10;
local lib = LibStub:NewLibrary(MAJOR, MINOR);

if not lib then return end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib);
if not lib.callbacks then error(MAJOR.." requires CallbackHandler"); end

local LibRangeCheck = LibStub("LibRangeCheck-3.0");

local engageTable =
{
	---------- Raids ----------
	-- SoD
	[2423] = {175611}, 										-- The Tarragrue
	[2429] = {177095, 177094, 175726},						-- The Nine
	[2433] = {175725},										-- The Eye of The Jailer
	[2432] = {175729, 177117},								-- Remnant Of Herazul
	[2434] = {175727, 175728},								-- Soulrender Dormazain
	[2430] = {176523},										-- Painsmith Raznal
	[2436] = {175731},										-- Guardian of The First Ones
	[2431] = {175730},										-- Fatescribe Roh Kalo
	[2422] = {175559, 176703, 176973, 176974, 176929},		-- KelThuzad
	[2435] = {175732},										-- Sylvanas Windrunner
	-- SotF
	[2512] = {180773, 184445},								-- Vigilant Guardian
	[2542] = {181395},										-- Skolex, the Insatiable Ravener
	[2553] = {183501},										-- Artificer Xy'mox
	[2540] = {181224},										-- Dausegne, the Fallen Oracle
	[2544] = {181549, 181548, 181546, 181551},				-- Prototype Pantheon
	[2539] = {182169},										-- Lihuvim, Principal Architect
	[2529] = {180906},										-- Halondrus the Reclaimer
	[2546] = {181954},										-- Anduin Wrynn
	[2543] = {181399,181398},								-- Lords of Dread
	[2549] = {182777},										-- Rygelon
	[2537] = {180990},										-- The Jailer
	-- Vot
	[2587] = {184972},										-- Eranog
	[2639] = {190496},										-- Terros
	[2590] = {187771,189816,187772,187767},					-- The Primal Council
	[2592] = {187967},										-- Sennarth, The Cold Breath
	[2635] = {189813},										-- Dathea, Ascended
	[2605] = {184986},										-- Kurog Grimtotem
	[2614] = {190245},										-- Broodkeeper Diurna
	[2607] = {182492},										-- Raszageth the Storm-Eater

	-- Aberrus
	[2688] = {201261},										-- Kazzara
	[2687] = {201774, 201773, 201934},						-- The Amalgamation Chamber
	[2693] = {200912, 200913, 200918},						-- The Forgotten Experiments
	[2680] = {201320},										-- Rashok, the Elder
	[2682] = {199659, 202791},								-- Assault of the Zaqali
	[2689] = {202375},										-- The Vigilant Steward, Zskarn
	[2683] = {201579},										-- Magmorax
	[2684] = {201668},										-- Echo of Neltharion
	[2685] = {205319},										-- Scalecommander Sarkareth

	-- Amirdrassil
	[2820] = {209333},										-- Gnarlroot
	[2709] = {200926},										-- Igira the Cruel
	[2737] = {208478},										-- Volcoross
	[2728] = {208363, 208365, 208367},						-- Council of Dreams
	[2731] = {208445}, 										-- Larodar, Keeper of the Flame
	[2708] = {206172},										-- Nymue, Weaver of the Cycle
	[2824] = {200927}, 										-- Smolderon
	[2786] = {209090}, 										-- Tindral Sageswift, Seer of the Flame
	[2677] = {204931},										-- Fyrakk the Blazing

	-- Nerub'ar Palace
	[2902] = {215657}, 										-- Ulgrax the Devourer
	[2917] = {214502}, 										-- The Bloodbound Horror
	[2898] = {214503},										-- Sikran, Captain of the Sureki
	[2918] = {214504}, 										-- Rasha'nan
	[2919] = {214506}, 										-- Broodtwister Ovi'nax
	[2920] = {217748}, 										-- Nexus-Princess Ky'veza
	[2921] = {217489, 217491}, 								-- The Silken Court
	[2922] = {218370},										-- Queen Ansurek

	-- Liberation Of Undermine
	[3009] = {225821}, 										-- The Geargrinder
	[3010] = {229181, 229177}, 								-- Flarendo, Torq
	[3011] = {228648}, 										-- Rik Reverb
	[3012] = {230322}, 										-- Stix Bunkjunker
	[3013] = {230583}, 										-- Sprocketmonger Lockenstock
	[3014] = {228458}, 										-- The One-Armed Bandit
	[3015] = {229953}, 										-- Mug'Zee, Heads of Security
	[3016] = {231075}, 										-- Chrome King Gallywix

	-- ManaForge Omega 
	[3132] = {247989}, 										-- Forgeweaver Araz
	[3135] = {225821}, 										-- Dimensius, the All-Devourin @TODO CHECK THIS
	[3133] = {237861},                                      -- Fractillus
	[3122] = {237661, 248404, 237662},                      -- The Soul Hungers
	[3131] = {233815},                                      -- Loom'ithar
	[3130] = {233816},                                      -- Soulbinder Naazindhri
	[3134] = {237763},                                      -- Nexus-King Salhadaar
	[3129] = {233814},                                      -- Plexus Sentinel
};

local activationTable = {};
for encounterID,mobIDs in pairs(engageTable) do
	for _,mobID in ipairs(mobIDs) do
		activationTable[mobID] = encounterID;
	end
end

-- Range Activation ----------------------------------------------------------------------
local defaultActivationRangeCheck = 80;
local rangeActivationOverrides =
{
	-- [npcID] = range,
	[175732] = 50,			-- Sylvanas Windrunner
};

-- HP Overrides -------------------------------------------------------------------------
local function kelThuzadHPCheck(unit)
	local hp = UnitHealth(unit);
	return hp > 10000;
end

local customCheck =
{
	[175559] = kelThuzadHPCheck,
};

-- Zone Overrides -----------------------------------------------------------------------
local zoneOverrides =
{

};

-- Core ---------------------------------------------------------------------------------
local lastEncounterActivation = nil;
local function checkUnit(unit)
	if(UnitExists(unit) and not UnitIsDeadOrGhost(unit) and not UnitPlayerControlled(unit))then
		local guid = UnitGUID(unit);
		if(guid)then
			local type, _, _, _, _, npcIDString = strsplit("-",guid);
			if((type == "Creature" or type == "Vehicle") and npcIDString)then
				local npcID = tonumber(npcIDString);
				local encounterID = activationTable[npcID];
				local customCheckFunc = customCheck[npcID];
				if(encounterID and encounterID ~= lastEncounterActivation and (not customCheckFunc or customCheckFunc(unit)))then
					local zoneIDTarget = zoneOverrides[npcID];
					if(not zoneIDTarget or C_Map.GetBestMapForUnit("player") == zoneIDTarget)then
						local range = LibRangeCheck:GetRange(unit);
						local rangeOverride = rangeActivationOverrides[npcID];
						if(range <= (rangeOverride or defaultActivationRangeCheck))then

							if(lastEncounterActivation ~= nil)then
								lib.callbacks:Fire("ENCOUNTER_CANCELED",lastEncounterActivation);
							end

							lastEncounterActivation = encounterID;

							lib.callbacks:Fire("ENCOUNTER_SOON",encounterID,unit);
						end
					end
				end
			end
		end
	end
end

local function checkAllUnits()
	local isInRaid = IsInRaid();
	for i=1,GetNumGroupMembers() do
		local unit = isInRaid and ("raid"..i) or (i == 1 and "player" or ("party"..i-1));
		checkUnit(unit.."target");
	end
end

local listenFrame = CreateFrame("Frame");
listenFrame:SetScript("OnEvent",function(self,event,...)
	if(IsInInstance())then
		if(event == "UNIT_TARGET")then
			local unit = ...;
			checkUnit(unit.."target");
		elseif(event == "READY_CHECK")then
			if(not lastEncounterActivation)then
				checkAllUnits();
			end
		elseif(event == "PLAYER_ENTERING_WORLD")then
			checkAllUnits();
		elseif(event == "ENCOUNTER_END")then
			local encounterID = ...;

			local lastEncounterActivationPrevious = lastEncounterActivation;
			lastEncounterActivation = nil;

			if(lastEncounterActivationPrevious ~= nil and encounterID ~= lastEncounterActivationPrevious)then
				local errorMsg = MAJOR.." ENCOUNTER_END: encounterID("..encounterID..") missmatch with last registered lastEncounterActivation("..lastEncounterActivationPrevious..")";
				error(errorMsg);
			end
		end
	end
end);

listenFrame:RegisterEvent("UNIT_TARGET");
listenFrame:RegisterEvent("READY_CHECK");
listenFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
listenFrame:RegisterEvent("ENCOUNTER_END");

function lib:GetCurrentPendingEncounter()
	return lastEncounterActivation;
end
