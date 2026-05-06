# War1gus Modding Guide

## Overview

War1gus is a re-implementation of Warcraft: Orcs & Humans using the Stratagus engine. The game is highly moddable through Lua scripts and can be extended with:

- **New Units** - Custom military units for each faction
- **New Buildings** - Structures with unique abilities
- **New Spells** - Magical abilities and special powers
- **New Mechanics** - Modified game rules and balance
- **New Graphics** - Custom unit/building sprites
- **New Campaigns** - Custom story missions

## File Structure

```
war1gus/
├── scripts/
│   ├── stratagus.lua          # Main configuration
│   ├── wc1.lua               # Game-specific settings
│   ├── units.lua             # Base unit definitions
│   ├── buildings.lua         # Base building definitions
│   ├── spells.lua            # Spell system
│   ├── upgrade.lua           # Tech tree
│   ├── commands.lua          # Command system
│   ├── balancing.lua         # Balance settings
│   ├── human/
│   │   ├── units.lua         # Human faction units
│   │   ├── buildings.lua     # Human faction buildings
│   │   └── ai.lua           # Human AI behavior
│   ├── orc/
│   │   ├── units.lua         # Orc faction units
│   │   ├── buildings.lua     # Orc faction buildings
│   │   └── ai.lua           # Orc AI behavior
│   ├── menus/
│   │   ├── campaign.lua      # Campaign menus
│   │   ├── ingame.lua        # In-game UI
│   │   └── ...
│   └── ai/                   # AI scripts
├── campaigns/
│   ├── human/                # Human campaign missions
│   └── orc/                  # Orc campaign missions
├── maps/                     # Multiplayer maps
└── contrib/
    ├── graphics/             # Custom graphics
    └── fonts/               # Custom fonts
```

## Modding Guide

### 1. Creating a New Unit

Edit `scripts/human/units.lua` or `scripts/orc/units.lua`:

```lua
-- Define a new unit
DefineUnitType("unit-knight", {
    Name = "Knight",
    File = "human/knight",           -- Sprite file
    Width = 32,
    Height = 32,
    Animations = "animations-human-knight",
    Icon = "icon-human-knight",
    
    -- Stats
    MaxHP = 60,
    Points = 55,                     -- Kill reward
    
    -- Combat
    BasicDamage = 8,
    PiercingDamage = 2,
    Armor = 3,
    
    -- Movement
    Speed = 10,
    
    -- Cost and time
    Cost = { 100 },                  -- Gold cost
    BuildTime = 60,                  -- Frames to build
    
    -- Abilities
    CanAttack = true,
    CanMove = true,
    CanPatrol = true,
    CanStand = true,
    
    -- Production
    TrainedIn = { "unit-human-barracks" },
    
    -- Sounds
    Sound = {
        click = "sounds/knight-what",
        ready = "sounds/knight-ready",
        acknowledge = "sounds/knight-yessir",
        attack = "sounds/knight-attack"
    }
})
```

### 2. Creating a New Building

Edit `scripts/human/buildings.lua` or `scripts/orc/buildings.lua`:

```lua
DefineUnitType("unit-human-stable", {
    Name = "Stable",
    File = "human/stable",
    Width = 64,
    Height = 64,
    Animations = "animations-human-stable",
    Icon = "icon-human-stable",
    
    -- Stats
    MaxHP = 300,
    Armor = 20,
    
    -- Production
    Produces = { "unit-knight", "unit-paladin" },
    
    -- Requirements
    RequiredUnits = { "unit-human-barracks" },
    
    -- Cost and time
    Cost = { 150 },
    BuildTime = 200,
    
    -- Building properties
    CanMove = false,
    CanAttack = false,
    
    -- Graphic
    NeutralMinimapColorIndex = 12
})
```

### 3. Modifying Unit Stats

Edit `scripts/balancing.lua` to adjust game balance:

```lua
-- Adjust unit HP
SetUnitTypeData("unit-footman", "MaxHitPoints", 40)

-- Adjust armor
SetUnitTypeData("unit-footman", "Armor", 2)

-- Adjust damage
SetUnitTypeData("unit-footman", "BasicDamage", 6)

-- Adjust cost
SetUnitTypeData("unit-footman", "CostGold", 50)

-- Adjust build time
SetUnitTypeData("unit-human-barracks", "BuildTime", 150)
```

### 4. Adding a New Spell

Edit `scripts/spells.lua`:

```lua
DefineSpell("lightning-strike", {
    Name = "Lightning Strike",
    ManaCost = 50,
    CoolDown = 10,
    Range = 8,
    
    -- Visual effects
    ImpactParticle = "lightning",
    SoundWhenCast = "sounds/lightning-cast",
    SoundHitGround = "sounds/lightning-hit",
    
    -- Damage
    Damage = 30,
    DamageType = "lightning",
    
    -- Area of effect
    AffectsArea = true,
    AreaRadius = 2,
    
    -- Restrictions
    TargetUnit = true,
    TargetGround = true
})
```

### 5. Modifying Game Mechanics

Edit `scripts/commands.lua` to change command behavior:

```lua
-- Change attack speed
SetVariable("AttackSpeed", 1.5)  -- 50% faster

-- Change movement speed
SetVariable("MovementSpeed", 1.2)  -- 20% faster

-- Change building speed
SetVariable("BuildingSpeed", 1.1)  -- 10% faster
```

### 6. Campaign Missions

Create custom campaign missions in `campaigns/human/` or `campaigns/orc/`:

```lua
-- Mission definition
DefinePlayerData(0, {
    Name = "Human",
    Race = "human",
    -- ... other settings
})

-- Mission objectives
-- ... define objectives, triggers, etc.
```

## Working with Graphics

### Unit Sprites
- Store graphics in `contrib/graphics/`
- Reference in unit definition with `File = "path/to/sprite"`
- Stratagus uses 8-bit indexed color PNG files
- Typical unit sprite: 32x32 pixels with directional frames

### Creating Player-Color Unit Sprites

War1gus player colors use palette indices `200..207`. To make a unit sprite react to player color, the pixels that should change by player must end up in that reserved range.

The easiest workflow is:

1. Finish the unit art first.
2. Decide which cloth, trim, banner, shield, or saddle areas should use player color.
3. If the sprite already uses reserved player-color indices, run `dev_scripts/remap_reserved_palette.py` first so those pixels are moved out of the reserved range.
4. Convert only the intended player-color pixels into up to 8 temporary shades.
5. Run `dev_scripts/map_to_player_colors.py` to remap those shades into `200..207`.

### Creating the Mask in GIMP

Use GIMP when you want a clean mask before the final remap.

1. Open your indexed unit sprite in GIMP.
2. Duplicate the sprite or duplicate the layer.
3. On the duplicate, erase everything that should not become player-colored.
4. Keep only the areas that should change by player.
5. Paint those remaining areas with up to 8 shades, from lightest highlight to darkest shadow.
6. Keep the background transparent. In this repo the helper script defaults to transparent index `0`.
7. Export that image as an 8-bit indexed PNG.

Practical rule:

- If you are editing the final sprite directly, the script can remap that sprite in place.
- If you are building a separate mask image, the script can remap the mask first, and then you can paste that remapped mask back over the base sprite in GIMP before exporting the final PNG.

### Using `map_to_player_colors.py`

The helper script is here:

```bash
dev_scripts/map_to_player_colors.py
```

Basic usage:

```bash
python3 dev_scripts/map_to_player_colors.py input.png output.png
```

What it does:

- Reads an 8-bit indexed PNG
- Detects up to 8 non-transparent source indices, unless you pass them explicitly
- Sorts them from light to dark
- Remaps them to player-color indices `200,201,202,203,204,205,206,207`

Example: remap a sprite copy directly

```bash
python3 dev_scripts/map_to_player_colors.py contrib/graphics/units/orc/warbeast-work.png contrib/graphics/units/orc/warbeast.png
```

Use `--source-indices` when the image contains more than just the player-color shades:

```bash
python3 dev_scripts/map_to_player_colors.py \
    contrib/graphics/units/orc/warbeast-work.png \
    contrib/graphics/units/orc/warbeast.png \
    --source-indices 57,58,59,60,61,62,63,64
```

### Separate Mask Workflow with `--palette-from`

When the mask is a separate indexed image, its own palette may not reflect the real light-to-dark order you want. In that case, tell the script to use the palette from another indexed reference image.

Typical use:

1. Keep a normal indexed copy of the sprite with the intended shading.
2. Export a second indexed image that contains only the player-color mask.
3. Run the mask through the script, but borrow shade ordering from the reference sprite.

```bash
python3 dev_scripts/map_to_player_colors.py \
    contrib/graphics/units/orc/warbeast-mask.png \
    contrib/graphics/units/orc/warbeast-mask-pc.png \
    --source-indices 57,58,59,60,61,62,63,64 \
    --palette-from contrib/graphics/units/orc/warbeast-reference.png
```

This is useful when:

- the mask uses arbitrary palette entries
- the mask was painted as a separate helper image
- you want the final player-color ramp to follow the shading of another indexed sprite instead of the mask's own palette

After that, paste the remapped mask back onto the base sprite in GIMP and export the final indexed PNG.

### Verification

Before using the sprite in game, verify these points:

1. The final PNG is still 8-bit indexed.
2. Only the intended player-color pixels use indices `200..207`.
3. Transparent background pixels still use the expected transparent index.
4. The sprite loads in game with different player slots showing different colors.

### Icons
- Store in `contrib/graphics/icons/`
- Size: typically 32x32 or 46x46 pixels
- Used in UI for unit/building selection

## Working with Sounds

- Store WAV files in appropriate sound directories
- Reference in unit/building definitions
- Example: `Sound = { click = "sounds/unit-click" }`

## Testing Your Mods

1. **Location:** Place modified scripts in:
   - `/usr/local/share/games/stratagus/war1gus/scripts/` (if installed via make install)
   - Or in `War1gus.app/Resources/scripts/` (if using app bundle)

2. **Testing:** Run war1gus and load custom maps/campaigns

3. **Debugging:** Check console output for Lua errors

## Common Runtime Pitfall

When testing local changes on macOS, War1gus runs from the runtime data directory under `~/Library/Application Support/Stratagus/data.War1gus/`.

If you changed files in the repository (for example `scripts/units.lua`) but forget to deploy them, the game may still run stale data and crash in ways that look unrelated.

Always sync before test runs:

```bash
./dev_scripts/copy_to_data.sh
```

Example from this project: a scout training-completion crash was resolved after copying the updated `scripts/units.lua` into the runtime data directory.

## Verified API Notes (from this codebase)

The notes below are based on helper usage in this repository and are useful for day-to-day modding in `scripts/*.lua`.

### Frequently Used Helper Functions

- `GetUnitsAroundUnit(centerUnit, radius, includeAll)`
    - Returns nearby units.
    - Used for aura/heal checks, ownership checks, and local target scans.
    - Example patterns:
        - `GetUnitsAroundUnit(unit, 1, true)` for immediate neighbors.
        - `GetUnitsAroundUnit(unit, 4, false)` for wider area effects.

- `GetUnitVariable(unit, name[, field])`
    - Reads unit state like `"HitPoints"`, `"Mana"`, `"Player"`, `"PosX"`, `"PosY"`, `"Ident"`, `"PixelPos"`.
    - Use optional `field` for metadata, such as:
        - `GetUnitVariable(unit, "HitPoints", "Max")`
        - `GetUnitVariable(unit, "Mana", "Max")`

- `SetUnitVariable(unit, name, value[, field])`
    - Writes unit state.
    - Common patterns:
        - `SetUnitVariable(unit, "HitPoints", hp + 1)`
        - `SetUnitVariable(unit, "Supply", 0, "Max")`

- `GetUnitBoolFlag(unit, flagName)`
    - Boolean checks for flags like `"Building"`.
    - Useful when filtering neighbors returned by `GetUnitsAroundUnit`.

- `CreateMissile(missileIdent, fromPos, toPos, sourceUnit, goalUnit, mapRelative, alwaysDisplay)`
    - Spawns a missile/effect.
    - Common use in this mod: visual effects and scripted area retaliation.

- `DamageUnit(attackerUnitOrMinusOne, targetUnit, amount)`
    - Applies direct scripted damage.
    - `-1` is commonly used for script/system damage.

- `OrderUnit(player, unitIdent, fromRect, toRect, orderString)`
    - Issues scripted orders such as `"attack"` and `"explore"`.

- `ChangeUnitsOwner(topLeft, bottomRight, oldPlayer, newPlayer, unitTypeIdent)`
    - Transfers ownership in an area for a unit type.

### Unit Callback Hooks Confirmed in Engine + Used Here

These hooks are supported by Stratagus unit definitions and are used in War1gus scripts:

- `OnInit(unit)`
- `OnReady(unit)`
- `OnDeath(unit, x, y)`
- `OnHit(unit, attacker, damage)`
- `OnEachCycle(unit)`
- `OnEachSecond(unit)`

Practical note: `OnHit` is a hit-event callback (not every frame for all units).

## DefineUnitType Options Reference

Complete list of all parameters available when defining a unit type with `DefineUnitType("unit-id", {...})`:

### Basic Properties
- `Name` — Display name of the unit
- `Image` — `{file, "path", size, {w, h}}` or `{alt-file, "path"}` — Sprite file and dimensions
- `Shadow` — `{file, "path", size, {w, h}, offset, {x, y}, sprite-frame, scale}` — Shadow graphics
- `Offset` — `{x, y}` — Sprite offset from unit center
- `Flip` — boolean — Mirror sprite horizontally
- `DrawLevel` — Layer for rendering (higher = drawn on top; buildings ~10-40, units ~30-180)
- `Icon` — Icon identifier for UI
- `Animations` — Animation set name

### Combat & Targeting
- `CanAttack` — boolean — Unit can attack
- `MaxAttackRange` — Range in tiles
- `MinAttackRange` — Minimum range (prevents melee)
- `Missile` — Missile type name (e.g., "missile-arrow")
- `MissileOffsets` — `{ { {x1,y1}, {x2,y2}, ... } }` — Pixel positions where missiles spawn per direction (8 directions per frame)
- `Impact` — `{general, "missile", shield, "missile"}` — Visual effects on unit death
- `Priority` — Targeting priority (0-255, higher = targeted first)
- `RightMouseAction` — "attack", "harvest", etc.
- `CanTargetLand` — boolean
- `CanTargetSea` — boolean
- `CanTargetAir` — boolean
- `CanTargetFlag` — `{flag-name, condition, ...}` — Complex targeting rules

### Combat Stats
- `BasicDamage` — Melee/base damage
- `PiercingDamage` — Armor-piercing damage
- `Armor` — Defense value

### Hit Points & Regeneration
- `RegenerationRate` — HP restored per tick
- `RegenerationFrequency` — Seconds between regeneration ticks
- `RepairRange` — Distance for repairs
- `RepairHp` — HP restored per repair action
- `RepairCosts` — `{resource, amount, ...}` — Cost per repair
- `BurnPercent` — Burn damage threshold
- `BurnDamageRate` — HP/tick when burning
- `PoisonDrain` — Poison damage/tick
- `ShieldPoints` — `{Max, Enable, Value, Increase}` — Shield stats

### Size & Collision
- `TileSize` — `{w, h}` in tiles (typically {1,1})
- `BoxSize` — `{w, h}` collision box dimensions
- `BoxOffset` — `{x, y}` collision box offset
- `PersonalSpace` — `{w, h}` personal space for pathfinding

### Movement
- `Speed` — Movement speed (pixels per tick)
- `Type` — "land", "sea", "air"
- `LandUnit` — boolean
- `AirUnit` — boolean
- `SeaUnit` — boolean

### Reactions & AI
- `ComputerReactionRange` — AI detection range
- `PersonReactionRange` — Player detection range
- `AnnoyComputerFactor` — AI targeting priority adjustment
- `AiAdjacentRange` — Grouping distance for AI units
- `RandomMovementProbability` — Idle movement chance
- `RandomMovementDistance` — Max idle movement distance
- `RotationSpeed` — Turning speed (1-128)

### Resources & Costs
- `Costs` — `{resource, amount, ...}` — Unit train/build cost
- `Storing` — `{resource, amount, ...}` — Resource storage capacity
- `ImproveProduction` — `{resource, amount, ...}` — Income bonuses
- `GivesResource` — Resource type this unit produces/gives
- `CanStore` — `{resource, ...}` — Which resources can be stored
- `CanGatherResources` — `{resource-id, ..., wait-at-resource, wait-at-depot, ...}` — Harvesting rules

### Building-Only Properties
- `Building` — boolean (is a building)
- `BuildingRules` — Placement restrictions
- `AiBuildingRules` — AI placement rules
- `AutoBuildRate` — Auto-construction speed
- `Construction` — Construction graphics reference
- `MaxOnBoard` — Transport capacity (if applicable)
- `BoardSize` — Unit size when transported
- `CanTransport` — `{unit-type, condition, ...}` — What can be transported

### Special Abilities
- `CanCastSpell` — `{spell-name, ...}` — Available spells
- `AutoCastActive` — `{spell-name, ...}` — Auto-cast spells

### Lifecycle & Death
- `OnInit` — `function(unit)` — Called when unit spawns
- `OnDeath` — `function(unit)` — Called when unit dies
- `OnHit` — `function(unit, attacker)` — Called when unit is hit
- `OnEachCycle` — `function(unit)` — Called every game cycle (30/sec)
- `OnEachSecond` — `function(unit)` — Called every second
- `OnReady` — `function(unit)` — Called when unit finishes building/training
- `Corpse` — Unit type name for corpse when killed
- `ExplodeWhenKilled` — `"missile-name"` — Explosion on death
- `DamageType` — Death type identifier
- `DecayRate` — Speed of decay

### Other Properties
- `Neutral` — boolean (neutral player unit)
- `organic` — boolean (organic vs mechanical)
- `Points` — Kill reward (VP)
- `Demand` — Supply cost
- `SightRange` — Vision range
- `Priority` — Targeting priority (0-255)
- `Vanishes` — boolean (disappear when idle/dead)
- `NonSolid` — boolean (no collision)
- `IsNotSelectable` — boolean (can't be selected)
- `Indestructible` — boolean (can't be killed)
- `SelectableByRectangle` — boolean (include in drag-select)
- `TeleportCost` — Cost to teleport unit
- `TeleportEffectIn` — Visual effect when teleporting in
- `TeleportEffectOut` — Visual effect when teleporting out
- `ClicksToExplode` — Clicks before explosion (for bombs)
- `NumDirections` — Sprite directions (8, 16, etc.)
- `Sounds` — `{event, sound, ...}` — Sound effects (attack, selected, ready, help, dead, acknowledge)

### Example with MissileOffsets
```lua
DefineUnitType("unit-human-war-wagon", {
  Name = "War Wagon",
  Image = {"file", "contrib/graphics/units/war-wagon.png", "size", {64, 64}},
  Animations = "animations-war-wagon",
  
  -- Missile firing positions (one per direction)
  Missile = "missile-cannonball",
  MissileOffsets = {
    { {0, -32}, {22, -18}, {32, 0}, {22, 26}, {0, 32}, {-22, 26}, {-32, 0}, {-22, -18} }
  },
  
  -- Stats
  MaxAttackRange = 6,
  MinAttackRange = 2,
  BasicDamage = 20,
  Armor = 2,
  HitPoints = 200,
  
  -- Movement
  Speed = 3,
  Type = "land",
  
  -- Callbacks
  OnInit = function(self)
    -- Custom initialization
  end,
  OnDeath = function(self)
    -- Custom death behavior
  end,
})
```

## Missile Types and Classes

Missiles are defined via `DefineMissileType("id", { ... })` in `scripts/missiles.lua`.

### Common Definition Fields

- `File`, `Size`, `Frames`, `NumDirections`
- `Class`
- `Sleep`, `Speed`, `Range`
- Optional behavior fields seen in this mod:
    - `ImpactSound`, `ImpactMissile`, `SplashFactor`, `NumBounces`, `DrawLevel`

### Missile Classes Currently Used by War1gus

The following classes are present in this repository's missile definitions:

- `missile-class-point-to-point`
- `missile-class-parabolic`
- `missile-class-fire`
- `missile-class-stay`
- `missile-class-point-to-point-with-hit`
- `missile-class-none`
- `missile-class-hit`
- `missile-class-cycle-once`
- `missile-class-flame-shield`
- `missile-class-clip-to-target`

For concrete examples, review `scripts/missiles.lua` and `scripts/balancing.lua` (for custom missile usage like `missile-demon-hate`).

## Common Modding Tasks

### Change Unit Appearance
Modify the `Icon` and `File` properties to point to new graphics

### Adjust Difficulty
Modify `scripts/balancing.lua` or create faction-specific balance files

### Add New Abilities
Define new spells and add them to unit `Abilities` list

### Create Custom Campaigns
Use mission scripting in `campaigns/` directory

### Balance Multiplayer
Adjust costs, build times, and stats in `balancing.lua`

## Resources

### Key Files for Modding
- `scripts/units.lua` - Unit definitions
- `scripts/human/units.lua` - Human-specific units
- `scripts/orc/units.lua` - Orc-specific units
- `scripts/buildings.lua` - Building definitions
- `scripts/spells.lua` - Spell system
- `scripts/upgrade.lua` - Tech tree
- `scripts/balancing.lua` - Game balance

### Stratagus Documentation
- [Stratagus Scripting Documentation](https://github.com/Wargus/stratagus/blob/master/doc/scripts/index.html) - Official Lua API reference
- See `/usr/local/include/stratagus/` header files
- Lua API documented in game scripts
- Examples in existing unit/building definitions

## Tips for Success

1. **Start Small** - Begin with adjusting existing units before creating new ones
2. **Backup** - Keep backups of original files before modifying
3. **Test Often** - Test changes frequently to catch issues early
4. **Reference Existing Code** - Use existing unit/building definitions as templates
5. **Comment Your Code** - Add comments to explain your changes
6. **Join Community** - Share mods and get feedback on the Wargus/Stratagus community

## Next Steps

1. Copy war1gus data to a development directory
2. Modify `scripts/balancing.lua` to start
3. Add new unit or building definition
4. Test in-game
5. Iterate and expand

Good luck with your War1gus mods!
