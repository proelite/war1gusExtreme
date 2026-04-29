--       _________ __                 __                               
--      /   _____//  |_____________ _/  |______     ____  __ __  ______
--      \_____  \\   __\_  __ \__  \\   __\__  \   / ___\|  |  \/  ___/
--      /        \|  |  |  | \// __ \|  |  / __ \_/ /_/  >  |  /\___ \ 
--     /_______  /|__|  |__|  (____  /__| (____  /\___  /|____//____  >
--             \/                  \/          \//_____/            \/ 
--  ______________________                           ______________________
--                        T H E   W A R   B E G I N S
--         Stratagus - A free fantasy real time strategy game engine
--
--      units.lua - Define the used unit-types.
--
--      (c) Copyright 1998-2004 by Lutz Sammer and Jimmy Salmon
--
--      This program is free software; you can redistribute it and/or modify
--      it under the terms of the GNU General Public License as published by
--      the Free Software Foundation; either version 2 of the License, or
--      (at your option) any later version.
--  
--      This program is distributed in the hope that it will be useful,
--      but WITHOUT ANY WARRANTY; without even the implied warranty of
--      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--      GNU General Public License for more details.
--  
--      You should have received a copy of the GNU General Public License
--      along with this program; if not, write to the Free Software
--      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--
--      $Id$

--=============================================================================
--      Define unit-types.
--

local units = {
   {Names = {neutral = "Sorceress"},
    Image = {"file", "contrib/graphics/units/sorceress.png", "size", {32, 32}},
    HitPoints = 40,
    Armor = 4,
    PiercingDamage = 1,
    BasicDamage = 9},
   {Names = {neutral = "Brigand"},
    HitPoints = 40,
    Armor = 4,
    PiercingDamage = 1,
    BasicDamage = 9},
   {Names = {neutral = "Daemon"},
    Size = {neutral = {48, 48}},
    HitPoints = 300,
    Armor = 0,
    BasicDamage = 65,
    organic = false},
   {Names = {neutral = "Fire elemental"},
    Size = {neutral = {48, 48}},
    HitPoints = 200,
    Armor = 0,
    Speed = 5,
    BasicDamage = 40,
    Missile = "missile-catapult-rock",
    organic = false},
   {Names = {neutral = "Water elemental"},
    Size = {neutral = {48, 48}},
    HitPoints = 250,
    Armor = 0,
    Speed = 5,
    PiercingDamage = 40,
    BasicDamage = 0,
    MaxAttackRange = 3,
    Missile = "missile-water",
    organic = false},
   {Names = {orc = "Grizelda"},
    Image = {"file", "neutral/units/grizelda,garona.png", "size", {32, 32}},
    HitPoints = 30,
    Armor = 0,
    BasicDamage = 0,
    Coward = true},
   {Names = {orc = "Garona"},
    Image = {"file", "neutral/units/grizelda,garona.png", "size", {32, 32}},
    HitPoints = 30,
    Armor = 0,
    BasicDamage = 0,
    Coward = true},
   {Names = {neutral = "Ogre"},
    HitPoints = 60,
    Armor = 3,
    PiercingDamage = 1,
    BasicDamage = 12,
    Size = {neutral = {48, 48}}},
   {Names = {neutral = "Scorpion"},
    HitPoints = 30,
    Speed = 5,
    Armor = 0,
    PiercingDamage = 3,
    BasicDamage = 0,
    CanCastSpell = {
       neutral = {"spell-poison"},
       },
    organic = false},
   {Names = {neutral = "Skeleton"}, -- "Dungeon Skeleton"
    HitPoints = 30,
    Armor = 2,
    PiercingDamage = 1,
    BasicDamage = 9,
    organic = false},
   {Names = {neutral = "Slime"},
    HitPoints = 150,
    Armor = 10,
    Speed = 2,
    PiercingDamage = 1,
    BasicDamage = 0,
    organic = false},
   {Names = {neutral = "Spider"},
    HitPoints = 30,
    Armor = 0,
    Speed = 5,
    PiercingDamage = 1,
    BasicDamage = 3,
    CanCastSpell = {
       neutral = {"spell-slow" },
       },	
    organic = false},
   {Names = {neutral = "The dead"}, -- "Orc conjured skeleton"
    HitPoints = 40,
    Armor = 1,
    PiercingDamage = 1,
    BasicDamage = 4,
    organic = false},
   {Names = {neutral = "Wounded"},
    HitPoints = 60,
    Corpse = nil},

   {Names = {orc = "Peon", human = "Peasant"},
    Costs = {"time", 75, "gold", 400},
    HitPoints = 40,
    CanAttack = false,
    Coward = true,
    AnnoyComputerFactor = 100,
    Armor = 0,
    RightMouseAction = "harvest",
    RepairRange = 1,
    CanGatherResources = {
       {"resource-id", "gold",
        "resource-capacity", 100,
        "wait-at-resource", 300,
        "wait-at-depot", 150},
       {"resource-id", "wood",
        "resource-capacity", 100,
        "resource-step", 2,
        "wait-at-resource", 24,
        "wait-at-depot", 150,
        --"lose-resources",
        "terrain-harvester"},
       {"resource-id", "lumber", -- dungeon's harvest wood outside
        "resource-capacity", 100,
        "wait-at-resource", 1200,
        "wait-at-depot", 150,
        "final-resource", "wood"},
       {"resource-id", "treasure", -- dungeon's have treasure chests to plunder
        "resource-capacity", 100,
        "resource-step", 2,
        "wait-at-resource", 8,
        "wait-at-depot", 150,
        "terrain-harvester",
        "final-resource", "gold"},
      }},
   {Names = {orc = "Grunt", human = "Footman"},
    Costs = {"time", 60, "gold", 400},
    HitPoints = 60,
    Armor = 2,
    AnnoyComputerFactor = 80,
    PiercingDamage = 1,
    BasicDamage = 9,
    Size = {human = {48, 48}}},
   {Names = {orc = "Spearman", human = "Archer"},
    Costs = {"time", 70, "gold", 450, "wood", 50},
    HitPoints = 60,
    Armor = 1,
	AnnoyComputerFactor = 140,
    PiercingDamage = {orc = 5, human = 4},
    BasicDamage = 0,
    Missile = "missile-arrow",
    MaxAttackRange = {human = 5, orc = 4},
    Dependencies = {orc = {"lumber-mill"}, human = {"lumber-mill"}}},
   {Names = {orc = "Catapult", human = "Catapult"},
    Costs = {"time", 100, "gold", 900, "wood", 200},
    HitPoints = 120,
    Speed = 2,
    BasicDamage = 255,
	AnnoyComputerFactor = 160,
    MaxAttackRange = 8,
    Armor = 0,
    organic = false,
    Missile = "missile-catapult-rock",
   Dependencies = {orc = {"war-camp"},
                    human = {"siege-workshop"}}},
   {Names = {orc = "Warlock", human = "Conjurer"},
    Costs = {"time", 90, "gold", 900},
    HitPoints = 40,
    Speed = 3,
    Armor = 0,
    Mana = {Max = 100, Enable = true},
	AnnoyComputerFactor = 200,
    CanCastSpell = {
       human = {
          "spell-summon-scorpions",
          "spell-summon-elemental",
          "spell-rain-of-fire"},
       orc = {
          "spell-summon-spiders",
          "spell-summon-daemon",
          "spell-poison-cloud" } },
    Missile = {orc = "missile-fireball", human = "missile-water"},
    PiercingDamage = 6,
    BasicDamage = 0,
    MaxAttackRange = {human = 3, orc = 2}},
   {Names = {orc = "Necrolyte", human = "Cleric"},
    Speed = 3,
    Costs = {"time", 80, "gold", 700},
    HitPoints = 40,
    Armor = 0,
    Coward = true,
    Mana = {Max = 100, Enable = true},
    AnnoyComputerFactor = 180,
    CanCastSpell = {
       human = {
          "spell-healing",
          "spell-far-seeing",
          "spell-invisibility"},
       orc = {
          "spell-raise-dead",
          "spell-dark-vision",
          "spell-unholy-armor" } },
    PiercingDamage = 6,
    Missile = {orc = "missile-shadow", human = "missile-magic-fireball"},
    BasicDamage = 0,
    MaxAttackRange = {orc = 2, human = 1}},

   {Names = {human = "Lothar"},
    Size = {human = {48, 48}},
    HitPoints = 50,
    Animations = "animations-medivh",
    Armor = 5,
    PiercingDamage = 1,
    BasicDamage = 15},

   {Names = {human = "Wounded Lothar"},
    Name = "Wounded",
    HitPoints = 60,
    Icon = "icon-wounded",
    Image = {
       "file", "neutral/units/wounded.png",
       "size", {32, 32}},
    Animations = "animations-wounded"},

   {Names = {human = "Medivh"},
    HitPoints = 110,
    Armor = 0,
    Mana = {Max = 100, Enable = true},
    Missile = "missile-fireball",
    PiercingDamage = 10,
    BasicDamage = 0,
    MaxAttackRange = 8,
    CanCastSpell = {
       human = {"spell-summon-spiders",
                "spell-summon-daemon"}}}
}

-- build units from specs
for idx,unit in ipairs(units) do
   DefineUnitFromSpec(unit)
end

local EarlyMount = "blacksmith"           --this is to skip blacksmith req for knights and raiders, if you using Rebalanced stats
if preferences.RebalancedStats then
EarlyMount = "farm"
end

DefineUnitFromSpec({
   Names = {orc = "Raider", human = "Knight"},
   Name = {orc = "Raider", human = "Knight"},
   Image = {orc = {"file", "orc/units/raider.png", "size", {48, 48}},
            human = {"file", "human/units/knight.png", "size", {32, 32}}},
   Costs = {"time", 80, "gold", 850},
   HitPoints = 90,
   Armor = 5,
   Speed = 5,
   AnnoyComputerFactor = 120,
   PiercingDamage = 1,
   BasicDamage = 13,
   Dependencies = {orc = {EarlyMount, "kennel"},
                   human = {EarlyMount, "stable"}}})

local scout_anim = BuildAnimations(
    GetFrameNumbers(5, {5, 5, 5}),
    {
         attackspeed = 5,
         coolofftime = 14,
    }
)
DefineAnimations("animations-scout", scout_anim)

DefineUnitType("unit-human-scout", {
   Name = "Scout",
   Image = {"file", "contrib/graphics/units/scout.png", "size", {32, 32}},
   Animations = "animations-scout",
   Icon = "icon-human-scout",
   Costs = {"time", 60, "gold", 450},
   HitPoints = 55,
   DrawLevel = 180,
   MaxAttackRange = 1,
   TileSize = {1, 1},
   BoxSize = {15, 15},
   Armor = 0,
   Speed = 6,
   AnnoyComputerFactor = 120,
   PiercingDamage = 1,
   BasicDamage = 1,
   Missile = "missile-none",
   Priority = 50,
   Points = 30,
   SightRange = 9,
   DetectCloak = true,
   organic = true,
   ComputerReactionRange = 3,
   PersonReactionRange = 3,
   Demand = 1,
   Type = "land",
   RightMouseAction = "attack",
   CanAttack = true,
   CanTargetLand = true,
   CanTargetSea = true,
   CanTargetAir = true,
   SelectableByRectangle = true,
   Sounds = {
      "attack", "human acknowledge",
      "selected", "human selected",
      "acknowledge", "human acknowledge",
      "ready", "human ready",
      "help", "human help 3",
      "dead", "human dead"
   }
})

table.insert(wc1_units.human, "unit-human-scout")
DefineAllow("unit-human-scout", "AAAAAAAAAAAAAAAA")

DefineUnitType("unit-orc-tracker", {
   Name = "Tracker",
   Image = {"file", "contrib/graphics/units/tracker.png", "size", {48, 48}},
   Animations = "animations-scout",
   Icon = "icon-orc-tracker",
   Costs = {"time", 60, "gold", 450},
   HitPoints = 55,
   DrawLevel = 180,
   MaxAttackRange = 1,
   TileSize = {1, 1},
   BoxSize = {24, 24},
   Armor = 0,
   Speed = 6,
   AnnoyComputerFactor = 120,
   PiercingDamage = 1,
   BasicDamage = 1,
   Missile = "missile-none",
   Priority = 50,
   Points = 30,
   SightRange = 9,
   DetectCloak = true,
   organic = true,
   ComputerReactionRange = 3,
   PersonReactionRange = 3,
   Demand = 1,
   Type = "land",
   RightMouseAction = "attack",
   CanAttack = true,
   CanTargetLand = true,
   CanTargetSea = true,
   CanTargetAir = true,
   SelectableByRectangle = true,
   Sounds = {
      "attack", "orc acknowledge",
      "selected", "orc selected",
      "acknowledge", "orc acknowledge",
      "ready", "orc ready",
      "help", "orc help 3",
      "dead", "orc dead"
   }
})

table.insert(wc1_units.orc, "unit-orc-tracker")
DefineAllow("unit-orc-tracker", "AAAAAAAAAAAAAAAA")

DefineUnitType("unit-human-sapper", {
   Name = "Sapper",
   Image = {"file", "contrib/graphics/units/sapper.png", "size", {32, 32}},
   Animations = "animations-sapper",
   Icon = "icon-human-sapper",
   Costs = {"time", 250, "gold", 600, "wood", 100},
   HitPoints = 60,
   DrawLevel = 180,
   MaxAttackRange = 2,
   TileSize = {1, 1},
   BoxSize = {15, 15},
   Armor = 1,
   Speed = 3,
   AnnoyComputerFactor = 150,
   PiercingDamage = 0,
   BasicDamage = 40,
   Missile = "missile-shotgun-blast",
   Priority = 55,
   Points = 80,
   SightRange = 5,
   organic = true,
   ComputerReactionRange = 3,
   PersonReactionRange = 4,
   Demand = 2,
   Type = "land",
   RightMouseAction = "attack",
   CanAttack = true,
   CanTargetLand = true,
   CanTargetSea = true,
   CanTargetAir = true,
   SelectableByRectangle = true,
   Sounds = {
      "attack", "human acknowledge",
      "selected", "human selected",
      "acknowledge", "human acknowledge",
      "ready", "human ready",
      "help", "human help 3",
      "dead", "human dead"
   }
})

table.insert(wc1_units.human, "unit-human-sapper")
DefineAllow("unit-human-sapper", "AAAAAAAAAAAAAAAA")
DefineDependency("unit-human-sapper", {"unit-human-barracks", "unit-human-blacksmith"})

DefineUnitType("unit-orc-ogre", {
   Name = "Ogre",
   Image = {"file", "neutral/units/ogre.png", "size", {48, 48}},
   Animations = "animations-ogre",
   Icon = "icon-ogre",
   Costs = {"time", 300, "gold", 800, "wood", 100},
   HitPoints = 100,
   DrawLevel = 180,
   MaxAttackRange = 1,
   TileSize = {1, 1},
   BoxSize = {24, 24},
   Armor = 2,
   Speed = 3,
   AnnoyComputerFactor = 150,
   PiercingDamage = 4,
   BasicDamage = 40,
   Missile = "missile-ogre-smash",
   Priority = 60,
   Points = 100,
   SightRange = 4,
   organic = true,
   ComputerReactionRange = 3,
   PersonReactionRange = 4,
   Demand = 3,
   Type = "land",
   RightMouseAction = "attack",
   CanAttack = true,
   CanTargetLand = true,
   CanTargetSea = true,
   CanTargetAir = true,
   SelectableByRectangle = true,
   Sounds = {
      "attack", "orc acknowledge",
      "selected", "orc selected",
      "acknowledge", "orc acknowledge",
      "ready", "orc ready",
      "help", "orc help 3",
      "dead", "orc dead"
   }
})

table.insert(wc1_units.orc, "unit-orc-ogre")
DefineAllow("unit-orc-ogre", "AAAAAAAAAAAAAAAA")
DefineDependency("unit-orc-ogre", {"unit-orc-barracks", "unit-orc-blacksmith"})

DefineUnitType("unit-orc-warbeast", {
  Name = "Warbeast",
  Image = {"file", "contrib/graphics/units/warbeast.png", "size", {64, 64}},
  Animations = "animations-warbeast",
  Icon = "icon-orc-warbeast",
  Costs = {"time", 500, "gold", 2000, "wood", 500},
  HitPoints = 300,
  DrawLevel = 180,
  MaxAttackRange = 5,
  TileSize = {1, 1},
  BoxSize = {31, 31},
  SightRange = 5,
  Speed = 3,
  organic = true,
  ComputerReactionRange = 4,
  PersonReactionRange = 6,
  Armor = 1,
  BasicDamage = 9,
  PiercingDamage = 3,
  Missile = "missile-arrow",
  DecayRate = 0,
  Priority = 63,
  Points = 250,
  Demand = 5,
  Type = "land",
  RightMouseAction = "attack",
  CanAttack = true,
  Coward = false,
  CanTargetLand = true,
  Vanishes = false,
  NonSolid = false,
  IsNotSelectable = false,
  RepairRange = 0,
  Corpse = nil,
  Impact = {"general", "missile-blood-in-impact"},
  Sounds = {
    "attack", "orc acknowledge",
    "selected", "orc selected",
    "acknowledge", "orc acknowledge",
    "ready", "orc ready",
    "help", "orc help 3",
    "dead", "orc warbeast dead"
  },
  SelectableByRectangle = true,
  OnEachSecond = function (warbeast)
      local freq = GetUnitVariable(warbeast, "RegenerationFrequency")
      local doheal = freq <= 1
      local dodraw = (freq % 2 == 1)
      if dodraw then
         for i,unit in ipairs(GetUnitsAroundUnit(warbeast, 4, false)) do
            if GetUnitVariable(unit, "organic") then
               local hp = GetUnitVariable(unit, "HitPoints")
               local maxhp = GetUnitVariable(unit, "HitPoints", "Max")
               if hp < maxhp then
                  if doheal then
                     SetUnitVariable(unit, "HitPoints", hp + 1)
                  end
                  CreateMissile("missile-heal", {8, 8}, {8, 8}, unit, unit, false)
               end
            end
         end
      end
      if doheal then
         SetUnitVariable(warbeast, "RegenerationFrequency", 2)
      else
         SetUnitVariable(warbeast, "RegenerationFrequency", freq - 1)
      end
   end
})
table.insert(wc1_units.orc, "unit-orc-warbeast")
DefineAllow("unit-orc-warbeast", "AAAAAAAAAAAAAAAA")
DefineDependency("unit-orc-warbeast", {"unit-orc-war-camp", "unit-orc-tower"})

DefineUnitType("unit-human-war-wagon", {
  Name = "War Wagon",
  Image = {"file", "contrib/graphics/units/war-wagon.png", "size", {64, 64}},
  Animations = "animations-war-wagon",
  Icon = "icon-war-wagon",
  Costs = {"time", 400, "gold", 1000, "wood", 1000},
  RepairHp = 4,
  RepairCosts = {"gold", 1, "wood", 1},
  PoisonDrain = 0,
  HitPoints = 200,
  DrawLevel = 180,
  MaxAttackRange = 6,
  MinAttackRange = 2,
  TileSize = {1, 1},
  BoxSize = {32, 32},
  SightRange = 6,
  Speed = 3,
  organic = false,
  ComputerReactionRange = 4,
  PersonReactionRange = 6,
  Armor = 2,
  BasicDamage = 40,
  PiercingDamage = 0,
  Missile = "missile-cannonball",
  Impact = {"general", "missile-hit"},
  Priority = 63,
  Points = 200,
  Demand = 4,
  Type = "land",
  RightMouseAction = "attack",
  CanAttack = true,
  CanTargetLand = true,
  CanTargetSea = true,
  CanTargetAir = true,
  Vanishes = false,
  NonSolid = false,
  IsNotSelectable = false,
  RepairRange = 0,
  Corpse = nil,
  ExplodeWhenKilled = "missile-explosion",
  Sounds = {
    "attack", "human acknowledge",
    "selected", "human-selected",
    "acknowledge", "human acknowledge",
    "ready", "human work complete",
    "help", "human help 1",
    "dead", "human dead"
  },
  SelectableByRectangle = true,
  OnEachSecond = function (war_wagon)
      local freq = GetUnitVariable(war_wagon, "RepairFrequency")
      local doRepair = freq <= 1
      local dodraw = (freq % 2 == 1)
      if dodraw then
         for i,unit in ipairs(GetUnitsAroundUnit(war_wagon, 4, false)) do
            if not GetUnitVariable(unit, "organic") then
               local hp = GetUnitVariable(unit, "HitPoints")
               local maxhp = GetUnitVariable(unit, "HitPoints", "Max")
               if hp < maxhp then
                  if doRepair then
                     SetUnitVariable(unit, "HitPoints", hp + 1)
                  end
                  CreateMissile("missile-heal", {8, 8}, {8, 8}, unit, unit, false)
               end
            end
         end
      end
      if doRepair then
         SetUnitVariable(war_wagon, "RepairFrequency", 3)
      else
         SetUnitVariable(war_wagon, "RepairFrequency", freq - 1)
      end
   end
})
table.insert(wc1_units.human, "unit-human-war-wagon")
DefineDependency("unit-human-war-wagon", {"unit-human-siege-workshop", "unit-human-tower"})

DefineUnitType("unit-human-cannon", {
   Name = "Cannon",
   Image = {"file", "contrib/graphics/units/cannon.png", "size", {32, 32}},
   Animations = "animations-human-cannon",
   Icon = "icon-human-cannon",
   Costs = {"time", 400, "gold", 800, "wood", 400},
   HitPoints = 150,
   DrawLevel = 180,
   MaxAttackRange = 9,
   MinAttackRange = 2,
   TileSize = {1, 1},
   BoxSize = {15, 15},
   Armor = 1,
   Speed = 2,
   AnnoyComputerFactor = 150,
   PiercingDamage = 0,
   BasicDamage = 100,
   Missile = "missile-cannonball",
   Priority = 60,
   Points = 150,
   SightRange = 5,
   RepairHp = 4,
   RepairCosts = {"gold", 1, "wood", 1},
   PoisonDrain = 0,
   organic = false,
   Corpse = nil,
   ComputerReactionRange = 5,
   PersonReactionRange = 6,
   Demand = 3,
   Type = "land",
   RightMouseAction = "attack",
   CanAttack = true,
   GroundAttack = true,
   CanTargetLand = true,
   CanTargetSea = true,
   CanTargetAir = false,
   SelectableByRectangle = true,
   Sounds = {
      "attack", "human acknowledge",
      "selected", "human selected",
      "acknowledge", "human acknowledge",
      "ready", "human ready",
      "help", "human help 3",
      "dead", "human dead"
   }
})
table.insert(wc1_units.human, "unit-human-cannon")
DefineAllow("unit-human-cannon", "AAAAAAAAAAAAAAAA")

local dead_bodies = { Name = "Dead Body",
  Image = {"file", "neutral/units/dead_bodies.png", "size", {32, 32}},
  Animations = "animations-human-dead-body", Icon = "icon-peasant",
  Speed = 0,
  HitPoints = 255,
  DrawLevel = 30,
  TileSize = {1, 1}, BoxSize = {15, 15},
  SightRange = 1,
  BasicDamage = 0, PiercingDamage = 0, Missile = "missile-none",
  Priority = 0,
  Type = "land",
  Vanishes = true,
  Sounds = {} }
DefineUnitType("unit-human-dead-body", dead_bodies)
dead_bodies.Animations = "animations-orc-dead-body"
DefineUnitType("unit-orc-dead-body", dead_bodies)
