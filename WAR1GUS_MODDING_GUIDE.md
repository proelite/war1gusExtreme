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
