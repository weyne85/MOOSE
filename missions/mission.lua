---@diagnostic disable: need-check-nil
----------------------------------------------------------------------------------------
---
-- Name: BOS-100 - Stennis Hornet and Tomcat
-- Author: funkyfranky
-- Date Created: 17 August 2019
--
-- # Situation:
-- 
-- Practice Case I/II/III recovery using the F/A-18C Hornet or F-14B Tomcat.
-- 
-- See mission briefing for further details.
-- 
-- *** IMPORTANT ***
-- If you run the mission in single player, hit ESC twice before entering a slot!
-- Otherwise the script will not load due to a long standing DCS bug.
--
----------------------------------------------------------------------------------------

-- No MOOSE settings menu. Comment out this line if required.
_SETTINGS:SetPlayerMenuOff()

-- S-3B Recovery Tanker spawning in air.
local tanker=RECOVERYTANKER:New("USS Stennis", "Texaco Group")
tanker:SetTakeoffAir()
tanker:SetRadio(250)
tanker:SetModex(511)
tanker:SetTACAN(1, "TEX")
tanker:__Start(1)

-- E-2D AWACS spawning on Stennis.
local awacs=RECOVERYTANKER:New("USS Stennis", "E-2D Wizard Group")
awacs:SetAWACS()
awacs:SetRadio(260)
awacs:SetAltitude(20000)
awacs:SetCallsign(CALLSIGN.AWACS.Wizard)
awacs:SetRacetrackDistances(30, 15)
awacs:SetModex(611)
awacs:SetTACAN(2, "WIZ")
awacs:__Start(1)

-- Rescue Helo with home base Lake Erie. Has to be a global object!
local rescuehelo=RESCUEHELO:New("USS Stennis", "Rescue Helo")
rescuehelo:SetHomeBase(AIRBASE:FindByName("Lake Erie"))
rescuehelo:SetModex(42)
rescuehelo:__Start(1)
  
-- Create AIRBOSS object.
local AirbossStennis=AIRBOSS:New("USS Stennis")

-- Add recovery windows:
-- Case I from 9 to 10 am.
local window1=AirbossStennis:AddRecoveryWindow( "9:00", "10:00", 1, nil, true, 25)
-- Case II with +15 degrees holding offset from 15:00 for 60 min.
local window2=AirbossStennis:AddRecoveryWindow("15:00", "16:00", 2,  15, true, 23)
-- Case III with +30 degrees holding offset from 2100 to 2200.
local window3=AirbossStennis:AddRecoveryWindow("21:00", "22:00", 3,  30, true, 21)

-- Set folder of airboss sound files within miz file.
AirbossStennis:SetSoundfilesFolder("Airboss Soundfiles/")

-- Single carrier menu optimization.
AirbossStennis:SetMenuSingleCarrier()

-- Skipper menu.
AirbossStennis:SetMenuRecovery(30, 20, false)

-- Remove landed AI planes from flight deck.
AirbossStennis:SetDespawnOnEngineShutdown()

-- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
AirbossStennis:Load()

-- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
AirbossStennis:SetAutoSave()

-- Enable trap sheet.
AirbossStennis:SetTrapSheet()

-- Start airboss class.
AirbossStennis:Start()


--- Function called when recovery tanker is started.
function tanker:OnAfterStart(From,Event,To)

  -- Set recovery tanker.
  AirbossStennis:SetRecoveryTanker(tanker)  


  -- Use tanker as radio relay unit for LSO transmissions.
  AirbossStennis:SetRadioRelayLSO(self:GetUnitName())
  
end

--- Function called when AWACS is started.
function awacs:OnAfterStart(From,Event,To)
  -- Set AWACS.
  AirbossStennis:SetAWACS(awacs)
end


--- Function called when rescue helo is started.
function rescuehelo:OnAfterStart(From,Event,To)
  -- Use rescue helo as radio relay for Marshal.
  AirbossStennis:SetRadioRelayMarshal(self:GetUnitName())
end

--- Function called when a player gets graded by the LSO.
function AirbossStennis:OnAfterLSOGrade(From, Event, To, playerData, grade)
  local PlayerData=playerData --Ops.Airboss#AIRBOSS.PlayerData
  local Grade=grade --Ops.Airboss#AIRBOSS.LSOgrade
end


---------------------------
--- Generate AI Traffic ---
---------------------------

-- Spawn some AI flights as additional traffic.
local F181=SPAWN:New("FA-18C Group 1"):InitModex(111) -- Coming in from NW after ~ 6 min
local F182=SPAWN:New("FA-18C Group 2"):InitModex(112) -- Coming in from NW after ~20 min
local F183=SPAWN:New("FA-18C Group 3"):InitModex(113) -- Coming in from W  after ~18 min
local F14=SPAWN:New("F-14B 2ship"):InitModex(211)     -- Coming in from SW after ~ 4 min
local E2D=SPAWN:New("E-2D Group"):InitModex(311)      -- Coming in from NE after ~10 min
local S3B=SPAWN:New("S-3B Group"):InitModex(411)      -- Coming in from S  after ~16 min
  
-- Spawn always 9 min before the recovery window opens.
local spawntimes={"8:51", "14:51", "20:51"}
for _,spawntime in pairs(spawntimes) do
  local _time=UTILS.ClockToSeconds(spawntime)-timer.getAbsTime()
  if _time>0 then
    SCHEDULER:New(nil, F181.Spawn, {F181}, _time)
    SCHEDULER:New(nil, F182.Spawn, {F182}, _time)
    SCHEDULER:New(nil, F183.Spawn, {F183}, _time)
    SCHEDULER:New(nil, F14.Spawn,  {F14},  _time)
    SCHEDULER:New(nil, E2D.Spawn,  {E2D},  _time)
    SCHEDULER:New(nil, S3B.Spawn,  {S3B},  _time)
  end
end

-- Name: RAT-006 - Continue Journey
-- Author: funkyfranky
-- Date Created: 24 Sep 2017
--
-- # Situation:
--
-- Spawn several aircraft of the same type at Gudauta. Each will get a random destination.
-- Once the aircraft arrives at its destination, it will be respawned there and continue its journey to another random airport.
-- Note that we do NOT have to set a departure airport.
-- 
-- # Test cases:
-- 
-- 1. Observe five Yak-40 aircraft being spawned at Gudauta. From there they will hop from airport to airport on the map.

-- Create RAT object. The only required parameter is the name of the template group in the mission editor.
local yak=RAT:New("RAT_Yak")

-- Set Gudauta as departure airport for all spawned aircraft. (Not required for ContinueJourney() to work.)
yak:SetDeparture("Gudauta")

-- This makes aircraft respawn at their destination airport instead of another random airport.
yak:ContinueJourney()

-- Spawn five aircraft.
yak:Spawn(10)


 -- Strafe pits. Each pit can consist of multiple targets. Here we have two pits and each of the pits has two targets.
 -- These are names of the corresponding units defined in the ME.
 local strafepit_left={"GWR Strafe Pit Left"}
 local strafepit_right={"GWR Strafe Pit Right"}

 -- Table of bombing target names. Again these are the names of the corresponding units as defined in the ME.
 local bombtargets={"GWR Bomb Target Circle Left", "GWR Bomb Target Circle Right"}

 -- Create a range object.
 GoldwaterRange=RANGE:New("Goldwater Range")

 -- Set and enable the range ceiling altitude in feet MSL.  If aircraft are above this altitude they are not considered to be in the range.
 GoldwaterRange:SetRangeCeiling(20000)
 GoldwaterRange:EnableRangeCeiling(true)

 -- Distance between strafe target and foul line. You have to specify the names of the unit or static objects.
 -- Note that this could also be done manually by simply measuring the distance between the target and the foul line in the ME.
 GoldwaterRange:GetFoullineDistance("GWR Strafe Pit Left", "GWR Foul Line Left")

 -- Add strafe pits. Each pit (left and right) consists of two targets. Where "nil" is used as input, the default value is used.
 GoldwaterRange:AddStrafePit(strafepit_left, 3000, 300, nil, true, 30, 500)
 GoldwaterRange:AddStrafePit(strafepit_right, nil, nil, nil, true, nil, 500)

 -- Add Instructor Radio (AM in MHz)
 GoldwaterRange.SetInstructorRadio(123)

 -- Add Range Control Radio (AM in MHz)
 GoldwaterRange.SetRangeControl(124)

 -- Add bombing targets. A good hit is if the bomb falls less then 50 m from the target.
 GoldwaterRange:AddBombingTargets(bombtargets, 50)

 -- Add Soundfiles to .miz
 GoldwaterRange:SetSoundfilesPath("Range Soundfiles/")

 -- Start range.
 GoldwaterRange:Start()